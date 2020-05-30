## This module provides common unicode operations

from std/unicode import
  Rune, runes, `==`, fastRuneAt, fastToUtf8Copy, toUtf8

import pkg/unicodedb/properties
import pkg/unicodedb/types
import pkg/unicodedb/casing
import pkg/segmentation

export Rune

func genNums(): array[128, bool] =
  for i in '0'.ord .. '9'.ord:
    result[i] = true
func genLetters(): array[128, bool] =
  for i in 'a'.ord .. 'z'.ord:
    result[i] = true
  for i in 'A'.ord .. 'Z'.ord:
    result[i] = true
func genAlphaNums(): array[128, bool] =
  for i in '0'.ord .. '9'.ord:
    result[i] = true
  for i in 'a'.ord .. 'z'.ord:
    result[i] = true
  for i in 'A'.ord .. 'Z'.ord:
    result[i] = true

# this is faster than a case-of all cases
const
  nums = genNums()
  letters = genLetters()
  alphaNums = genAlphaNums()

iterator runes(s: seq[Rune]): Rune {.inline.} =
  # no-op
  for r in s:
    yield r

template runeCheck(s, runeProc) =
  ## Check all characters in `s`
  ## passes `runeProc` test.
  for r in runes(s):
    result = runeProc(r)
    if not result:
      break

func isDecimal*(c: Rune): bool =
  result = if c.int < 128:
    nums[c.int]
  else:
    utmDecimal in c.unicodeTypes()

func isDecimal*(s: string): bool =
  ## Return `true` if all characters in the
  ## string are decimal characters and there
  ## is at least one character, false otherwise.
  ## Decimal characters are those that can be
  ## used to form numbers in base 10, e.g. U+0660,
  ## ARABIC-INDIC DIGIT ZERO. Formally, a decimal
  ## is a character that has the property
  ## value `Numeric_Type=Decimal`
  runeCheck(s, isDecimal)

func isDecimal*(s: seq[Rune]): bool {.deprecated: "Use isDecimal(string)".} =
  runeCheck(s, isDecimal)

func isDigit*(c: Rune): bool =
  result = if c.int < 128:
    nums[c.int]
  else:
    utmDigit+utmDecimal in c.unicodeTypes()

func isDigit*(s: string): bool =
  ## Return `true` if all characters in the
  ## string are digits and there is at least
  ## one character, `false` otherwise. Digits
  ## include decimal characters and digits that
  ## need special handling, such as the
  ## compatibility superscript digits. This
  ## covers digits which cannot be used to
  ## form numbers in base 10, like the Kharosthi
  ## numbers. Formally, a digit is a character
  ## that has the property value `Numeric_Type=Digit`
  ## or `Numeric_Type=Decimal`
  runeCheck(s, isDigit)

func isDigit*(s: seq[Rune]): bool {.deprecated: "Use isDigit(string)".} =
  runeCheck(s, isDigit)

func isNumeric*(c: Rune): bool =
  result = if c.int < 128:
    nums[c.int]
  else:
    utmDigit+utmDecimal+utmNumeric in c.unicodeTypes()

func isNumeric*(s: string): bool =
  ## Return `true` if all characters in the
  ## string are numeric, and there
  ## is at least one character, `false` otherwise.
  ## Numeric characters include digit characters,
  ## and all characters that have the Unicode
  ## numeric value property, e.g. U+2155,
  ## VULGAR FRACTION ONE FIFTH. Formally,
  ## numeric characters are those with the
  ## property value Numeric_Type=Digit,
  ## Numeric_Type=Decimal or Numeric_Type=Numeric
  runeCheck(s, isNumeric)

func isNumeric*(s: seq[Rune]): bool {.deprecated: "Use isNumeric(string)".} =
  runeCheck(s, isNumeric)

func isAlpha*(c: Rune): bool =
  result = if c.int < 128:
    letters[c.int]
  else:
    c.unicodeCategory() in ctgL

func isAlpha*(s: string): bool =
  ## Return `true` if all characters in
  ## the string are alphabetic and there
  ## is at least one character, `false` otherwise.
  ## Alphabetic characters are those
  ## characters defined in the UCD as “Letter”.
  ## This is not the same as the “Alphabetic”
  ## property defined in the UCD
  runeCheck(s, isAlpha)

func isAlpha*(s: seq[Rune]): bool {.deprecated: "Use isAlpha(string)".} =
  runeCheck(s, isAlpha)

func isAlnum*(c: Rune): bool =
  result = if c.int < 128:
    alphaNums[c.int]
  else:
    (c.unicodeCategory() in ctgL or
      utmDigit+utmDecimal+utmNumeric in c.unicodeTypes())

func isAlnum*(s: string): bool =
  ## Return `true` if all characters in
  ## the string are alphanumeric and
  ## there is at least one character,
  ## `false` otherwise. A `c` character is
  ## alphanumeric if one of the following
  ## returns `true`: `c.isAlpha()`,
  ## `c.isDecimal()`, `c.isDigit()`,
  ## or `c.isNumeric()`
  runeCheck(s, isAlnum)

func isAlnum*(s: seq[Rune]): bool {.deprecated: "Use isAlnum(string)".} =
  runeCheck(s, isAlnum)

func isPrintable*(c: Rune): bool =
  result =
    c == Rune(0x20) or
    c.unicodeCategory() notin ctgC+ctgZ

func isPrintable*(s: string): bool =
  ## Nonprintable characters are those characters
  ## defined in the UCD as “Other” or “Separator”,
  ## except for the ASCII space (0x20). Return `true` if all
  ## characters meet this condition or the string is empty
  result = true
  runeCheck(s, isPrintable)

func isPrintable*(s: seq[Rune]): bool {.deprecated: "Use isPrintable(string)".} =
  result = true
  runeCheck(s, isPrintable)

func isWhiteSpace*(c: Rune): bool =
  result =
    c.unicodeCategory() in ctgC+ctgZ or
    c.bidirectional() in ["WS", "B", "S"]

func isWhiteSpace*(s: string): bool =
  ## Whitespace characters are those characters
  ## defined in the Unicode character database
  ## as “Other” or “Separator” and those with
  ## bidirectional property being one of
  ## “WS”, “B”, or “S”. Return `true` if all
  ## characters meet this condition. Return
  ## `false` if the string is empty
  runeCheck(s, isWhiteSpace)

func isWhiteSpace*(s: seq[Rune]): bool {.deprecated: "Use isWhiteSpace(string)".} =
  runeCheck(s, isWhiteSpace)

func isUpper*(c: Rune): bool =
  utmUppercase in c.unicodeTypes()

func isUpper*(s: string): bool =
  ## return `true` if all cased runes are
  ## upper-case and there is at least one cased rune
  result = false
  for r in s.runes:
    let ut = r.unicodeTypes()
    if utmCased in ut:
      result = utmUppercase in ut
      if not result:
        break

func isUpper*(s: seq[Rune]): bool {.deprecated: "Use isUpper(string)".} =
  result = false
  for r in s.runes:
    let ut = r.unicodeTypes()
    if utmCased in ut:
      result = utmUppercase in ut
      if not result:
        break

func isLower*(c: Rune): bool =
  utmLowercase in c.unicodeTypes()

func isLower*(s: string): bool =
  ## return `true` if all cased runes are
  ## lower-case and there is at least one cased rune
  result = false
  for r in s.runes:
    let ut = r.unicodeTypes()
    if utmCased in ut:
      result = utmLowercase in ut
      if not result:
        break

func isLower*(s: seq[Rune]): bool {.deprecated: "Use isLower(string)".} =
  result = false
  for r in s.runes:
    let ut = r.unicodeTypes()
    if utmCased in ut:
      result = utmLowercase in ut
      if not result:
        break

func isTitle*(c: Rune): bool =
  ## Return ``true`` for ligatures
  ## containing uppercase
  ## followed by lowercase letters
  ## (e.g., ǅ, ǈ, ǋ, and ǲ).
  ## Return ``false`` otherwise
  c.unicodeCategory() == ctgLt

func isTitle*(s: string): bool =
  ## A title is a unicode sequence of
  ## uncased characters followed by an
  ## uppercase character and cased
  ## characters followed by a lowercase
  ## character. Return `false` if the
  ## string is empty
  result = false
  var isLastCased = false
  for r in s.runes:
    let ut = r.unicodeTypes()
    if utmUppercase in ut and isLastCased:
      result = false
      break
    if utmLowercase in ut and not isLastCased:
      result = false
      break
    isLastCased = utmCased in ut
    result = true

func isTitle*(s: seq[Rune]): bool {.deprecated: "Use isTitle(string)".} =
  result = false
  var isLastCased = false
  for r in s.runes:
    let ut = r.unicodeTypes()
    if utmUppercase in ut and isLastCased:
      result = false
      break
    if utmLowercase in ut and not isLastCased:
      result = false
      break
    isLastCased = utmCased in ut
    result = true

template caseConversionImpl(
  s: string,
  caseProc: untyped
): untyped {.dirty.} =
  const buffCap = 16
  var cap = s.len
  result = newString(cap + buffCap)
  result.setLen(0)
  for r in s.runes:
    for rr in caseProc(r):
      if (result.len >= cap).unlikely:
        cap = result.len
        result.setLen(result.len * 2 + buffCap)
        result.setLen(cap)
        cap = result.len * 2
        # echo "realloc", " ", result.len, " ", cap
      let pos = result.len
      fastToUtf8Copy(rr, result, pos, false)

# This follows Unicode Chapter 3,
# "Default Case Algorithms" section
func toUpper*(s: string): string {.inline.} =
  ## Return `s` in upper case.
  ## Beware the result may be
  ## longer than `s`
  caseConversionImpl(s, upperCase)

func toLower*(s: string): string {.inline.} =
  ## Return `s` in lower case.
  ## Beware the result may be
  ## longer than `s`
  caseConversionImpl(s, lowerCase)

func toTitle*(s: string): string {.inline.} =
  ## Return `s` in title case.
  ## Beware the result may be
  ## longer than `s`
  result = newString(s.len + 16)
  result.setLen(0)
  var r: Rune
  var ra: int
  for wb in s.wordsBounds:
    ra = wb.a
    fastRuneAt(s, ra, r, true)
    for rr in r.titleCase:
      let pos = result.len
      fastToUtf8Copy(rr, result, pos, false)
    # XXX memCopy
    # this will preallocate if needed
    for i in ra .. wb.b:
      result.add s[i]

func cmpCaseless*(a, b: string): bool {.inline.} =
  ## Caseless string comparison. Beware the strings
  ## are not normalized. This is meant for
  ## arbitrary text, do not use it to compare
  ## identifiers
  template fillBuffA: untyped {.dirty.} =
    fastRuneAt(a, riA, rA, true)
    for c in caseFold(rA):
      buffA[idxA] = c
      inc idxA
  template fillBuffB: untyped {.dirty.} =
    fastRuneAt(b, riB, rB, true)
    for c in caseFold(rB):
      buffB[idxB] = c
      inc idxB
  var
    buffA, buffB: array[8, Rune]  # at least 2x max caseFold
    idxA, idxB = 0
    riA, riB = 0
    rA, rB: Rune
  while riA < a.len and riB < b.len:
    fillBuffA()
    fillBuffB()
    while idxA < idxB and riA < a.len:
      fillBuffA()
    while idxB < idxA and riB < b.len:
      fillBuffB()
    if idxA != idxB:
      return false
    if toOpenArray(buffA, 0, idxA) != toOpenArray(buffB, 0, idxB):
      return false
    idxA = 0
    idxB = 0
  return riA == a.len and riB == b.len
