## This module provides common unicode operations

from unicode import
  Rune, runes, `==`

import unicodedb/properties
import unicodedb/types

export Rune

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
  ## Return `true` if the given character
  ## is decimal characters and there.
  ## Decimal characters are those that can be
  ## used to form numbers in base 10, e.g. U+0660,
  ## ARABIC-INDIC DIGIT ZERO. Formally, a decimal
  ## is a character that has the property
  ## value `Numeric_Type=Decimal`
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
  ## Return `true` if the given character
  ## is digit and there is at least
  ## one character, `false` otherwise. Digits
  ## include decimal characters and digits that
  ## need special handling, such as the
  ## compatibility superscript digits. This
  ## covers digits which cannot be used to
  ## form numbers in base 10, like the Kharosthi
  ## numbers. Formally, a digit is a character
  ## that has the property value `Numeric_Type=Digit`
  ## or `Numeric_Type=Decimal`
  result = utmDigit+utmDecimal in c.unicodeTypes()

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
  ## Return `true` if the given character is numeric.
  ## Numeric characters include digit characters,
  ## and all characters that have the Unicode
  ## numeric value property, e.g. U+2155,
  ## VULGAR FRACTION ONE FIFTH. Formally,
  ## numeric characters are those with the
  ## property value `Numeric_Type=Digit`,
  ## `Numeric_Type=Decimal` or `Numeric_Type=Numeric`
  result = utmDigit+utmDecimal+utmNumeric in c.unicodeTypes()

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
  ## Return `true` if the given characters
  ## is alphabetic and there.
  ## Alphabetic characters are those
  ## characters defined in the UCD as “Letter”.
  ## This is not the same as the “Alphabetic”
  ## property defined in the UCD
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
  ## Return `true` if the given
  ## characters is alphanumeric.
  ## A `c` character is
  ## alphanumeric if one of the following
  ## returns `true`: `c.isAlpha()`,
  ## `c.isDecimal()`, `c.isDigit()`,
  ## or `c.isNumeric()`
  c.isAlpha() or c.isNumeric()

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
  ## Nonprintable characters are those characters
  ## defined in the UCD as “Other” or “Separator”,
  ## except for the ASCII space (0x20)
  result = (
    c == Rune(0x20) or
    c.unicodeCategory() notin ctgC+ctgZ)

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
  ## Whitespace characters are those characters
  ## defined in the Unicode character database
  ## as “Other” or “Separator” and those with
  ## bidirectional property being one of
  ## “WS”, “B”, or “S”. Return `true` if the
  ## character meets this condition
  result = (
    c.unicodeCategory() in ctgC+ctgZ or
    c.bidirectional() in ["WS", "B", "S"])

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
  ## return `true` if the character is upper-case
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
  ## return `true` if the character is lower-case
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
  ## Ligatures containing uppercase
  ## followed by lowercase letters
  ## (e.g., ǅ, ǈ, ǋ, and ǲ)
  c.unicodeCategory() == ctgLt

proc isTitle*(s: string | seq[Rune]): bool =
  ## a title is a unicode sequence of
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

# todo: needs toLower
#[]
proc cmpCi*(a, b: Rune): int =
  ## Case insensitive comparison
  RuneImpl(a.toLower()) - RuneImpl(b.toLower())

proc cmpCi*(a, b: seq[Rune]): int =
  ## Case insensitive comparison
  result = a.len - b.len
  if result != 0:
    return
  for i in 0 .. a.high:
    result = a[i].toLower() - b[i].toLower()
    if result != 0:
      return

proc cmpCi*(a, b: string): int =
  ## Case insensitive comparison
  var
    i = 0
    j = 0
    ar, br: Rune
  while i < a.len and j < b.len:
    fastRuneAt(a, i, ar)
    fastRuneAt(b, j, br)
    result = RuneImpl(ar.toLower()) - RuneImpl(br.toLower())
    if result != 0:
      return
  result = a.len - b.len
]#
