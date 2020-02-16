## This module provides common unicode operations

from unicode import
  Rune, runes, `==`, fastRuneAt, fastToUtf8Copy, toUtf8

import unicodedb/properties
import unicodedb/types
import unicodedb/casing
import segmentation

export Rune

proc genNums(): array[128, bool] =
  for i in '0'.ord .. '9'.ord:
    result[i] = true
proc genLetters(): array[128, bool] =
  for i in 'a'.ord .. 'z'.ord:
    result[i] = true
  for i in 'A'.ord .. 'Z'.ord:
    result[i] = true
proc genAlphaNums(): array[128, bool] =
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

proc isDecimal*(c: Rune): bool =
  result = if c.int < 128:
    nums[c.int]
  else:
    utmDecimal in c.unicodeTypes()

proc isDecimal*(s: string): bool =
  ## Return `true` if all characters in the
  ## string are decimal characters and there
  ## is at least one character, false otherwise.
  ## Decimal characters are those that can be
  ## used to form numbers in base 10, e.g. U+0660,
  ## ARABIC-INDIC DIGIT ZERO. Formally, a decimal
  ## is a character that has the property
  ## value `Numeric_Type=Decimal`
  runeCheck(s, isDecimal)

proc isDecimal*(s: seq[Rune]): bool =
  runeCheck(s, isDecimal)

proc isDigit*(c: Rune): bool =
  result = if c.int < 128:
    nums[c.int]
  else:
    utmDigit+utmDecimal in c.unicodeTypes()

proc isDigit*(s: string): bool =
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

proc isDigit*(s: seq[Rune]): bool =
  runeCheck(s, isDigit)

proc isNumeric*(c: Rune): bool =
  result = if c.int < 128:
    nums[c.int]
  else:
    utmDigit+utmDecimal+utmNumeric in c.unicodeTypes()

proc isNumeric*(s: string): bool =
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

proc isNumeric*(s: seq[Rune]): bool =
  runeCheck(s, isNumeric)

proc isAlpha*(c: Rune): bool =
  result = if c.int < 128:
    letters[c.int]
  else:
    c.unicodeCategory() in ctgL

proc isAlpha*(s: string): bool =
  ## Return `true` if all characters in
  ## the string are alphabetic and there
  ## is at least one character, `false` otherwise.
  ## Alphabetic characters are those
  ## characters defined in the UCD as “Letter”.
  ## This is not the same as the “Alphabetic”
  ## property defined in the UCD
  runeCheck(s, isAlpha)

proc isAlpha*(s: seq[Rune]): bool =
  runeCheck(s, isAlpha)

proc isAlnum*(c: Rune): bool =
  result = if c.int < 128:
    alphaNums[c.int]
  else:
    (c.unicodeCategory() in ctgL or
      utmDigit+utmDecimal+utmNumeric in c.unicodeTypes())

proc isAlnum*(s: string): bool =
  ## Return `true` if all characters in
  ## the string are alphanumeric and
  ## there is at least one character,
  ## `false` otherwise. A `c` character is
  ## alphanumeric if one of the following
  ## returns `true`: `c.isAlpha()`,
  ## `c.isDecimal()`, `c.isDigit()`,
  ## or `c.isNumeric()`
  runeCheck(s, isAlnum)

proc isAlnum*(s: seq[Rune]): bool =
  runeCheck(s, isAlnum)

proc isPrintable*(c: Rune): bool =
  result =
    c == Rune(0x20) or
    c.unicodeCategory() notin ctgC+ctgZ

proc isPrintable*(s: string): bool =
  ## Nonprintable characters are those characters
  ## defined in the UCD as “Other” or “Separator”,
  ## except for the ASCII space (0x20). Return `true` if all
  ## characters meet this condition or the string is empty
  result = true
  runeCheck(s, isPrintable)

proc isPrintable*(s: seq[Rune]): bool =
  result = true
  runeCheck(s, isPrintable)

proc isWhiteSpace*(c: Rune): bool =
  result =
    c.unicodeCategory() in ctgC+ctgZ or
    c.bidirectional() in ["WS", "B", "S"]

proc isWhiteSpace*(s: string): bool =
  ## Whitespace characters are those characters
  ## defined in the Unicode character database
  ## as “Other” or “Separator” and those with
  ## bidirectional property being one of
  ## “WS”, “B”, or “S”. Return `true` if all
  ## characters meet this condition. Return
  ## `false` if the string is empty
  runeCheck(s, isWhiteSpace)

proc isWhiteSpace*(s: seq[Rune]): bool =
  runeCheck(s, isWhiteSpace)

proc isUpper*(c: Rune): bool =
  utmUppercase in c.unicodeTypes()

proc isUpper*(s: string | seq[Rune]): bool =
  ## return `true` if all cased runes are
  ## upper-case and there is at least one cased rune
  result = false
  for r in s.runes:
    let ut = r.unicodeTypes()
    if utmCased in ut:
      result = utmUppercase in ut
      if not result:
        break

proc isLower*(c: Rune): bool =
  utmLowercase in c.unicodeTypes()

proc isLower*(s: string | seq[Rune]): bool =
  ## return `true` if all cased runes are
  ## lower-case and there is at least one cased rune
  result = false
  for r in s.runes:
    let ut = r.unicodeTypes()
    if utmCased in ut:
      result = utmLowercase in ut
      if not result:
        break

proc isTitle*(c: Rune): bool =
  ## Return ``true`` for ligatures
  ## containing uppercase
  ## followed by lowercase letters
  ## (e.g., ǅ, ǈ, ǋ, and ǲ).
  ## Return ``false`` otherwise
  c.unicodeCategory() == ctgLt

proc isTitle*(s: string | seq[Rune]): bool =
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
proc toUpper*(s: string): string {.inline.} =
  ## Return `s` in upper case.
  ## Beware the result may be
  ## longer than `s`
  caseConversionImpl(s, upperCase)

proc toLower*(s: string): string {.inline.} =
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
