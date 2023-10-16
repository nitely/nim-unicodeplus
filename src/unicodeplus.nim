## This module provides common unicode operations

from std/unicode import
  Rune, runes, `==`, fastRuneAt,
  fastToUtf8Copy

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
  result = newString(s.len + 16)
  result.setLen(0)
  for r in s.runes:
    for rr in caseProc(r):
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

# ref https://arxiv.org/pdf/2010.03090.pdf
func verifyUtf8*(s: openArray[char]): int =
  ## Returns the position of the invalid byte in `s` if
  ## the string `s` does not hold valid UTF-8 data.
  ## Otherwise -1 is returned.
  var i = 0
  let L = s.len
  while i < L:
    if uint(s[i]) <= 127:
      inc(i)
    elif uint(s[i]) shr 5 == 0b110:
      if uint(s[i]) < 0xc2:  # Overlong
        return i
      if i+1 < L and uint(s[i+1]) shr 6 == 0b10: inc(i, 2)
      else: return i
    elif uint(s[i]) shr 4 == 0b1110:
      if (uint(s[i]) and 0xf) == 0 and i+1 < L and uint(s[i+1]) < 0x9f.uint:  # Overlong
        return i
      if (uint(s[i]) and 0xf) == 0b1101 and i+1 < L and uint(s[i+1]) > 0x9f.uint:  # Surrogate
        return i
      if i+2 < L and uint(s[i+1]) shr 6 == 0b10 and uint(s[i+2]) shr 6 == 0b10:
        inc i, 3
      else: return i
    elif uint(s[i]) shr 3 == 0b11110:
      if (uint(s[i]) and 0xf) == 0 and i+1 < L and uint(s[i+1]) < 0x90.uint:  # Overlong
        return i
      if (uint(s[i]) and 0xf) == 0b100 and i+1 < L and uint(s[i+1]) > 0x8f.uint:  # Too large
        return i
      if i+3 < L and uint(s[i+1]) shr 6 == 0b10 and
                    uint(s[i+2]) shr 6 == 0b10 and
                    uint(s[i+3]) shr 6 == 0b10:
        inc i, 4
      else: return i
    else:  # Too long
      return i
  return -1

func add2(s: var string, x: openArray[char]) =
  for c in x:
    s.add c

func toValidUtf8*(s: string, replacement = "\uFFFD"): string =
  ## Return `s` with all invalid utf-8 bytes replaced by the
  ## `replacement` value.
  if verifyUtf8(s) == -1:
    return s
  result = ""
  var i = 0
  var j = 0
  while i < s.len:
    j = verifyUtf8 toOpenArray(s, i, s.len-1)
    if j == -1: break
    result.add2 toOpenArray(s, i, i+j-1)
    result.add replacement
    i += j+1
  result.add2 toOpenArray(s, i, s.len-1)