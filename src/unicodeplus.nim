## This module provides common unicode operations

import unicode except
  isTitle, isLower, isUpper, isAlpha, isWhiteSpace

import unicodedb

iterator runes(s: seq[Rune]): Rune =
  # no-op
  for r in s:
    yield r

template runeCheck(s, runeProc) =
  ## Check all characters in `s`
  ## passes `runeProc` test. Return
  ## `false` if `s` is empty
  result = false
  for r in s.runes:
    if not runeProc(r):
      return false
    result = true

proc isDecimal*(c: Rune): bool =
  ## Return `true` if the given character
  ## is decimal characters and there.
  ## Decimal characters are those that can be
  ## used to form numbers in base 10, e.g. U+0660,
  ## ARABIC-INDIC DIGIT ZERO. Formally, a decimal
  ## is a character that has the property
  ## value `Numeric_Type=Decimal`
  utmDecimal in c.unicodeTypes()

proc isDecimal*(s: string | seq[Rune]): bool =
  ## Return `true` if all characters in the
  ## string are decimal characters and there
  ## is at least one character, false otherwise.
  ## Decimal characters are those that can be
  ## used to form numbers in base 10, e.g. U+0660,
  ## ARABIC-INDIC DIGIT ZERO. Formally, a decimal
  ## is a character that has the property
  ## value `Numeric_Type=Decimal`
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
  let ut = c.unicodeTypes()
  result = (
    utmDigit in ut or
    utmDecimal in ut)

proc isDigit*(s: string | seq[Rune]): bool =
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

proc isNumeric*(c: Rune): bool =
  ## Return `true` if the given character is numeric.
  ## Numeric characters include digit characters,
  ## and all characters that have the Unicode
  ## numeric value property, e.g. U+2155,
  ## VULGAR FRACTION ONE FIFTH. Formally,
  ## numeric characters are those with the
  ## property value `Numeric_Type=Digit`,
  ## `Numeric_Type=Decimal` or `Numeric_Type=Numeric`
  let ut = c.unicodeTypes()
  result = (
    utmDigit in ut or
    utmDecimal in ut or
    utmNumeric in ut)

proc isNumeric*(s: string | seq[Rune]): bool =
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

proc isAlpha*(c: Rune): bool =
  ## Return `true` if the given characters
  ## is alphabetic and there.
  ## Alphabetic characters are those
  ## characters defined in the UCD as “Letter”.
  ## This is not the same as the “Alphabetic”
  ## property defined in the UCD
  c.category()[0] == 'L'

proc isAlpha*(s: string | seq[Rune]): bool =
  ## Return `true` if all characters in
  ## the string are alphabetic and there
  ## is at least one character, `false` otherwise.
  ## Alphabetic characters are those
  ## characters defined in the UCD as “Letter”.
  ## This is not the same as the “Alphabetic”
  ## property defined in the UCD
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

proc isAlnum*(s: string | seq[Rune]): bool =
  ## Return `true` if all characters in
  ## the string are alphanumeric and
  ## there is at least one character,
  ## `false` otherwise. A `c` character is
  ## alphanumeric if one of the following
  ## returns `true`: `c.isAlpha()`,
  ## `c.isDecimal()`, `c.isDigit()`,
  ## or `c.isNumeric()`
  runeCheck(s, isAlnum)

proc isPrintable*(c: Rune): bool =
  ## Nonprintable characters are those characters
  ## defined in the UCD as “Other” or “Separator”,
  ## except for the ASCII space (0x20)
  let cat = c.category()
  result = (
    c == Rune(0x20) or
    cat[0] notin {'C', 'Z'})

proc isPrintable*(s: string | seq[Rune]): bool =
  ## Nonprintable characters are those characters
  ## defined in the UCD as “Other” or “Separator”,
  ## except for the ASCII space (0x20). Return `true` if all
  ## characters meet this condition or the string is empty
  result = true
  for r in s.runes:
    if not r.isPrintable():
      return false
    result = true

proc isWhiteSpace*(c: Rune): bool =
  ## Whitespace characters are those characters
  ## defined in the Unicode character database
  ## as “Other” or “Separator” and those with
  ## bidirectional property being one of
  ## “WS”, “B”, or “S”. Return `true` if the
  ## character meets this condition
  let cat = c.category()
  result = (
    cat[0] in {'C', 'Z'} or
    c.bidirectional() in ["WS", "B", "S"])

proc isWhiteSpace*(s: string | seq[Rune]): bool =
  ## Whitespace characters are those characters
  ## defined in the Unicode character database
  ## as “Other” or “Separator” and those with
  ## bidirectional property being one of
  ## “WS”, “B”, or “S”. Return `true` if all
  ## characters meet this condition. Return
  ## `false` if the string is empty
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
      if utmUppercase notin ut:
        return false
      result = true

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
      if utmLowercase notin ut:
        return false
      result = true

proc isTitle*(c: Rune): bool =
  ## Ligatures containing uppercase
  ## followed by lowercase letters
  ## (e.g., ǅ, ǈ, ǋ, and ǲ)
  c.category() == "Lt"

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
      return false
    elif utmLowercase in ut and not isLastCased:
      return false
    isLastCased = utmCased in ut
    result = true

when isMainModule:
  doAssert(not "".isLower())
  doAssert(not "A".isLower())
  doAssert(not "aBC".isLower())
  doAssert("abc".isLower())
  doAssert("abc def".isLower())
  doAssert(not Rune(0x1FFC).isLower())
  doAssert(not Rune(0x2167).isLower())
  doAssert(Rune(0x2177).isLower())
  # non-BMP, uppercase
  doAssert(not Rune(0x10401).isLower())
  doAssert(not Rune(0x10427).isLower())
  # non-BMP, lowercase
  doAssert(Rune(0x10429).isLower())
  doAssert(Rune(0x1044E).isLower())
  # non-BMP, non-cased
  doAssert(not Rune(0x1F40D).isLower())
  doAssert(not Rune(0x1F46F).isLower())

  doAssert(not "".isUpper())
  doAssert(not "a".isUpper())
  doAssert(not "aBC".isUpper())
  doAssert("ABC".isUpper())
  doAssert("ABC DEF".isUpper())
  doAssert(not Rune(0x1FFC).isUpper())
  doAssert(Rune(0x2167).isUpper())
  doAssert(not Rune(0x2177).isUpper())
  # non-BMP, uppercase
  doAssert(Rune(0x10401).isUpper())
  doAssert(Rune(0x10427).isUpper())
  # non-BMP, lowercase
  doAssert(not Rune(0x10429).isUpper())
  doAssert(not Rune(0x1044E).isUpper())
  # non-BMP, non-cased
  doAssert(not Rune(0x1F40D).isUpper())
  doAssert(not Rune(0x1F46F).isUpper())

  doAssert(Rune(0x1FFC).isTitle())
  doAssert(not "".isTitle())
  doAssert("Greek \u1FFCitlecases ...".isTitle())
  doAssert(not "not A title".isTitle())
  doAssert("A Nice Title".isTitle())
  doAssert("A Title - Yes!".isTitle())
  doAssert("> A > Title >".isTitle())
  doAssert("ǅ".isTitle())
  # non-BMP, uppercase + lowercase
  doAssert(@[Rune(0x10401), Rune(0x10429)].isTitle())
  doAssert(@[Rune(0x10427), Rune(0x1044E)].isTitle())
  doAssert(not Rune(0x10429).isTitle())
  doAssert(not Rune(0x1044E).isTitle())
  doAssert(not Rune(0x1F40D).isTitle())
  doAssert(not Rune(0x1F46F).isTitle())

  doAssert(not "".isWhiteSpace())
  doAssert("   ".isWhiteSpace())
  doAssert("  \L".isWhiteSpace())
  doAssert(Rune(0x2000).isWhiteSpace())
  doAssert(Rune(0x200A).isWhiteSpace())
  doAssert(not Rune(0x2014).isWhiteSpace())
  doAssert(not Rune(0x10401).isWhiteSpace())
  doAssert(not Rune(0x10427).isWhiteSpace())
  doAssert(not Rune(0x10429).isWhiteSpace())
  doAssert(not Rune(0x1044E).isWhiteSpace())
  doAssert(not Rune(0x1F40D).isWhiteSpace())
  doAssert(not Rune(0x1F46F).isWhiteSpace())

  doAssert(not "".isAlnum())
  doAssert("abc123۲⅕".isAlnum())
  doAssert(not "abc123!".isAlnum())
  doAssert(Rune(0x10401).isAlnum())
  doAssert(Rune(0x10427).isAlnum())
  doAssert(Rune(0x10429).isAlnum())
  doAssert(Rune(0x1044E).isAlnum())
  doAssert(Rune(0x1D7F6).isAlnum())
  doAssert(Rune(0x11066).isAlnum())
  doAssert(Rune(0x104A0).isAlnum())
  doAssert(Rune(0x1F107).isAlnum())
  doAssert(not Rune(0x2000).isAlnum())
  doAssert(not "@".isAlnum())

  doAssert(not "".isAlpha())
  doAssert("abcd".isAlpha())
  doAssert(not "0123".isAlpha())
  doAssert(Rune(0x1FFC).isAlpha())
  # non-BMP, cased
  doAssert(Rune(0x10401).isAlpha())
  doAssert(Rune(0x10427).isAlpha())
  doAssert(Rune(0x10429).isAlpha())
  doAssert(Rune(0x1044E).isAlpha())
  # non-BMP, non-cased
  doAssert(not Rune(0x1F40D).isAlpha())
  doAssert(not Rune(0x1F46F).isAlpha())

  doAssert(not "".isDecimal())
  doAssert(not "a".isDecimal())
  doAssert("0".isDecimal())
  doAssert(not Rune(0x2460).isDecimal())  # CIRCLED DIGIT ONE
  doAssert(not Rune(0xBC).isDecimal())  # VULGAR FRACTION ONE QUARTER
  doAssert(Rune(0x0660).isDecimal())  # ARABIC-INDIC DIGIT ZERO
  doAssert("0123456789".isDecimal())
  doAssert(not "0123456789a".isDecimal())
  doAssert(not Rune(0x10401).isDecimal())
  doAssert(not Rune(0x10427).isDecimal())
  doAssert(not Rune(0x10429).isDecimal())
  doAssert(not Rune(0x1044E).isDecimal())
  doAssert(not Rune(0x1F40D).isDecimal())
  doAssert(not Rune(0x1F46F).isDecimal())
  doAssert(not Rune(0x11065).isDecimal())
  doAssert(not Rune(0x1F107).isDecimal())
  doAssert(Rune(0x1D7F6).isDecimal())
  doAssert(Rune(0x11066).isDecimal())
  doAssert(Rune(0x104A0).isDecimal())

  doAssert(not "".isDigit())
  doAssert("0123456789".isDigit())
  doAssert(not "0123456789a".isDigit())
  doAssert("۲".isDigit())  # Kharosthi numeral
  doAssert(not "⅕".isDigit())
  doAssert(Rune(0x2460).isDigit())
  doAssert(not Rune(0xBC).isDigit())
  doAssert(Rune(0x0660).isDigit())
  doAssert(not Rune(0x10401).isDigit())
  doAssert(not Rune(0x10427).isDigit())
  doAssert(not Rune(0x10429).isDigit())
  doAssert(not Rune(0x1044E).isDigit())
  doAssert(not Rune(0x1F40D).isDigit())
  doAssert(not Rune(0x1F46F).isDigit())
  doAssert(not Rune(0x11065).isDigit())
  doAssert(Rune(0x1D7F6).isDigit())
  doAssert(Rune(0x11066).isDigit())
  doAssert(Rune(0x104A0).isDigit())
  doAssert(Rune(0x1F107).isDigit())

  doAssert(not "".isNumeric())
  doAssert(not "a".isNumeric())
  doAssert("0".isNumeric())
  doAssert(Rune(0x2460).isNumeric())
  doAssert(Rune(0xBC).isNumeric())
  doAssert(Rune(0x0660).isNumeric())
  doAssert("0123456789".isNumeric())
  doAssert(not "0123456789a".isNumeric())
  doAssert(not "abcd".isNumeric())
  doAssert("۲".isNumeric())  # Kharosthi numeral
  doAssert("⅕".isNumeric())
  doAssert(not Rune(0x10401).isNumeric())
  doAssert(not Rune(0x10427).isNumeric())
  doAssert(not Rune(0x10429).isNumeric())
  doAssert(not Rune(0x1044E).isNumeric())
  doAssert(not Rune(0x1F40D).isNumeric())
  doAssert(not Rune(0x1F46F).isNumeric())
  doAssert(Rune(0x11065).isNumeric())
  doAssert(Rune(0x1D7F6).isNumeric())
  doAssert(Rune(0x11066).isNumeric())
  doAssert(Rune(0x104A0).isNumeric())
  doAssert(Rune(0x1F107).isNumeric())

  doAssert("".isPrintable())
  doAssert(" ".isPrintable())
  doAssert("abcd".isPrintable())
  doAssert(not "abcd\L".isPrintable())
  doAssert(not "abcd\L".isPrintable())
  # some defined Unicode character
  doAssert(Rune(0x0374).isPrintable())
  # undefined character
  doAssert(not Rune(0x0378).isPrintable())
  # single surrogate character
  doAssert(not Rune(0xD800).isPrintable())
  # non-BMP
  doAssert(Rune(0x1F46F).isPrintable())
  doAssert(not Rune(0xE0020).isPrintable())
