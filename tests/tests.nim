import unittest
from unicode import Rune, toUTF8

from unicodedb/casing import caseFold

import unicodeplus

test "isLower":
  check(not "".isLower())
  check(not "A".isLower())
  check(not "aBC".isLower())
  check("abc".isLower())
  check("abc def".isLower())
  check(not Rune(0x1FFC).isLower())
  check(not Rune(0x2167).isLower())
  check(Rune(0x2177).isLower())
  # non-BMP, uppercase
  check(not Rune(0x10401).isLower())
  check(not Rune(0x10427).isLower())
  # non-BMP, lowercase
  check(Rune(0x10429).isLower())
  check(Rune(0x1044E).isLower())
  # non-BMP, non-cased
  check(not Rune(0x1F40D).isLower())
  check(not Rune(0x1F46F).isLower())

test "isUpper":
  check(not "".isUpper())
  check(not "a".isUpper())
  check(not "aBC".isUpper())
  check("ABC".isUpper())
  check("ABC DEF".isUpper())
  check(not Rune(0x1FFC).isUpper())
  check(Rune(0x2167).isUpper())
  check(not Rune(0x2177).isUpper())
  # non-BMP, uppercase
  check(Rune(0x10401).isUpper())
  check(Rune(0x10427).isUpper())
  # non-BMP, lowercase
  check(not Rune(0x10429).isUpper())
  check(not Rune(0x1044E).isUpper())
  # non-BMP, non-cased
  check(not Rune(0x1F40D).isUpper())
  check(not Rune(0x1F46F).isUpper())

test "isTitle":
  check(Rune(0x1FFC).isTitle())
  check(not "".isTitle())
  check("Greek \u1FFCitlecases ...".isTitle())
  check(not "not A title".isTitle())
  check("A Nice Title".isTitle())
  check("A Title - Yes!".isTitle())
  check("> A > Title >".isTitle())
  check("ǅ".isTitle())
  # non-BMP, uppercase + lowercase
  check(@[Rune(0x10401), Rune(0x10429)].isTitle())
  check(@[Rune(0x10427), Rune(0x1044E)].isTitle())
  check(not Rune(0x10429).isTitle())
  check(not Rune(0x1044E).isTitle())
  check(not Rune(0x1F40D).isTitle())
  check(not Rune(0x1F46F).isTitle())

test "isWhiteSpace":
  check(not "".isWhiteSpace())
  check("   ".isWhiteSpace())
  check("  \L".isWhiteSpace())
  check(Rune(0x2000).isWhiteSpace())
  check(Rune(0x200A).isWhiteSpace())
  check(not Rune(0x2014).isWhiteSpace())
  check(not Rune(0x10401).isWhiteSpace())
  check(not Rune(0x10427).isWhiteSpace())
  check(not Rune(0x10429).isWhiteSpace())
  check(not Rune(0x1044E).isWhiteSpace())
  check(not Rune(0x1F40D).isWhiteSpace())
  check(not Rune(0x1F46F).isWhiteSpace())

test "isAlnum":
  check(not "".isAlnum())
  check("abc123۲⅕".isAlnum())
  check(not "abc123!".isAlnum())
  check(Rune(0x10401).isAlnum())
  check(Rune(0x10427).isAlnum())
  check(Rune(0x10429).isAlnum())
  check(Rune(0x1044E).isAlnum())
  check(Rune(0x1D7F6).isAlnum())
  check(Rune(0x11066).isAlnum())
  check(Rune(0x104A0).isAlnum())
  check(Rune(0x1F107).isAlnum())
  check(not Rune(0x2000).isAlnum())
  check(not "@".isAlnum())

test "isAlpha":
  check(not "".isAlpha())
  check("abcd".isAlpha())
  check(not "0123".isAlpha())
  check(Rune(0x1FFC).isAlpha())
  # non-BMP, cased
  check(Rune(0x10401).isAlpha())
  check(Rune(0x10427).isAlpha())
  check(Rune(0x10429).isAlpha())
  check(Rune(0x1044E).isAlpha())
  # non-BMP, non-cased
  check(not Rune(0x1F40D).isAlpha())
  check(not Rune(0x1F46F).isAlpha())

test "isDecimal":
  check(not "".isDecimal())
  check(not "a".isDecimal())
  check("0".isDecimal())
  check(not Rune(0x2460).isDecimal())  # CIRCLED DIGIT ONE
  check(not Rune(0xBC).isDecimal())  # VULGAR FRACTION ONE QUARTER
  check(Rune(0x0660).isDecimal())  # ARABIC-INDIC DIGIT ZERO
  check("0123456789".isDecimal())
  check(not "0123456789a".isDecimal())
  check(not Rune(0x10401).isDecimal())
  check(not Rune(0x10427).isDecimal())
  check(not Rune(0x10429).isDecimal())
  check(not Rune(0x1044E).isDecimal())
  check(not Rune(0x1F40D).isDecimal())
  check(not Rune(0x1F46F).isDecimal())
  check(not Rune(0x11065).isDecimal())
  check(not Rune(0x1F107).isDecimal())
  check(Rune(0x1D7F6).isDecimal())
  check(Rune(0x11066).isDecimal())
  check(Rune(0x104A0).isDecimal())

test "isDigit":
  check(not "".isDigit())
  check("0123456789".isDigit())
  check(not "0123456789a".isDigit())
  check("۲".isDigit())  # Kharosthi numeral
  check(not "⅕".isDigit())
  check(Rune(0x2460).isDigit())
  check(not Rune(0xBC).isDigit())
  check(Rune(0x0660).isDigit())
  check(not Rune(0x10401).isDigit())
  check(not Rune(0x10427).isDigit())
  check(not Rune(0x10429).isDigit())
  check(not Rune(0x1044E).isDigit())
  check(not Rune(0x1F40D).isDigit())
  check(not Rune(0x1F46F).isDigit())
  check(not Rune(0x11065).isDigit())
  check(Rune(0x1D7F6).isDigit())
  check(Rune(0x11066).isDigit())
  check(Rune(0x104A0).isDigit())
  check(Rune(0x1F107).isDigit())

test "isNumeric":
  check(not "".isNumeric())
  check(not "a".isNumeric())
  check("0".isNumeric())
  check(Rune(0x2460).isNumeric())
  check(Rune(0xBC).isNumeric())
  check(Rune(0x0660).isNumeric())
  check("0123456789".isNumeric())
  check(not "0123456789a".isNumeric())
  check(not "abcd".isNumeric())
  check("۲".isNumeric())  # Kharosthi numeral
  check("⅕".isNumeric())
  check(not Rune(0x10401).isNumeric())
  check(not Rune(0x10427).isNumeric())
  check(not Rune(0x10429).isNumeric())
  check(not Rune(0x1044E).isNumeric())
  check(not Rune(0x1F40D).isNumeric())
  check(not Rune(0x1F46F).isNumeric())
  check(Rune(0x11065).isNumeric())
  check(Rune(0x1D7F6).isNumeric())
  check(Rune(0x11066).isNumeric())
  check(Rune(0x104A0).isNumeric())
  check(Rune(0x1F107).isNumeric())

test "isPrintable":
  check("".isPrintable())
  check(" ".isPrintable())
  check("abcd".isPrintable())
  check(not "abcd\L".isPrintable())
  check(not "abcd\L".isPrintable())
  # some defined Unicode character
  check(Rune(0x0374).isPrintable())
  # undefined character
  check(not Rune(0x0378).isPrintable())
  # single surrogate character
  check(not Rune(0xD800).isPrintable())
  # non-BMP
  check(Rune(0x1F46F).isPrintable())
  check(not Rune(0xE0020).isPrintable())

test "sanityCheck":
  # I don't care about the results
  # just make sure it does not fail
  for c in 0 .. 0x10FFFF:
    discard Rune(c).isPrintable()
    discard Rune(c).isNumeric()
    discard Rune(c).isDigit()
    discard Rune(c).isDecimal()
    discard Rune(c).isAlpha()
    discard Rune(c).isAlnum()
    discard Rune(c).isWhiteSpace()
    discard Rune(c).isTitle()
    discard Rune(c).isUpper()
    discard Rune(c).isLower()

test "toTitle":
  check "a".toTitle == "A"
  check "1".toTitle == "1"
  check "some title".toTitle == "Some Title"
  check "The quick? (“brown”) fox can’t jump 32.3 feet, right?".toTitle ==
    "The Quick? (“Brown”) Fox Can’t Jump 32.3 Feet, Right?"
  check "a ⓗ Ⓗ ⓗ a".toTitle == "A Ⓗ Ⓗ Ⓗ A"
  check "ⓗola".toTitle == "Ⓗola"
  check "諸".toTitle == "諸"
  check "ab 諸 ab ⓗ ab".toTitle == "Ab 諸 Ab Ⓗ Ab"
  check "abc 弢ⒶΪ def".toTitle == "Abc 弢ⒶΪ Def"
  check "abc 弢Ⓐ def".toTitle == "Abc 弢Ⓐ Def"
  check "abc ⒶΪ def".toTitle == "Abc ⒶΪ Def"
  check "abc 弢Ϊ def".toTitle == "Abc 弢Ϊ Def"
  check "abc 弢 def".toTitle == "Abc 弢 Def"
  check "abc Ⓐ def".toTitle == "Abc Ⓐ Def"
  check "abc Ϊ def".toTitle == "Abc Ϊ Def"
  check "ßear".toTitle == "Ssear"

test "toUpper":
  check "a".toUpper == "A"
  check "1".toUpper == "1"
  check "some title".toUpper == "SOME TITLE"
  check "The quick? (“brown”) fox can’t jump 32.3 feet, right?".toUpper ==
    "THE QUICK? (“BROWN”) FOX CAN’T JUMP 32.3 FEET, RIGHT?"
  check "a ⓗ Ⓗ ⓗ a".toUpper == "A Ⓗ Ⓗ Ⓗ A"
  check "諸".toUpper == "諸"
  check "ab 諸 ab ⓗ ab".toUpper == "AB 諸 AB Ⓗ AB"
  check "abc 弢ⒶΪ def".toUpper == "ABC 弢ⒶΪ DEF"
  check "abc 弢Ⓐ def".toUpper == "ABC 弢Ⓐ DEF"
  check "abc ⒶΪ def".toUpper == "ABC ⒶΪ DEF"
  check "abc 弢Ϊ def".toUpper == "ABC 弢Ϊ DEF"
  check "abc 弢 def".toUpper == "ABC 弢 DEF"
  check "abc Ⓐ def".toUpper == "ABC Ⓐ DEF"
  check "abc Ϊ def".toUpper == "ABC Ϊ DEF"
  check "ßear".toUpper == "SSEAR"
  block testLongerResult:
    const be = "ΐeΐeΐeΐe-ΐeΐeΐeΐe-ΐeΐeΐeΐe-ΐeΐeΐeΐe"
    const se = "Ϊ́EΪ́EΪ́EΪ́E-Ϊ́EΪ́EΪ́EΪ́E-Ϊ́EΪ́EΪ́EΪ́E-Ϊ́EΪ́EΪ́EΪ́E"
    check be.len < se.len
    check (be & be & be & be & be & be & be & be).toUpper ==
          (se & se & se & se & se & se & se & se)

test "toLower":
  check "A".toLower == "a"
  check "1".toLower == "1"
  check "SOME TITLE".toLower == "some title"
  check "The quIck? (“bRown”) fox cAn’T jUMp 32.3 feet, rIGHt?".toLower ==
    "the quick? (“brown”) fox can’t jump 32.3 feet, right?"
  check "A ⓗ Ⓗ ⓗ A".toLower == "a ⓗ ⓗ ⓗ a"
  check "諸".toLower == "諸"
  check "AB 諸 AB Ⓗ AB".toLower == "ab 諸 ab ⓗ ab"
  check "ABC 弢ⒶΪ DEF".toLower == "abc 弢ⓐϊ def"
  check "ABC 弢Ⓐ DEF".toLower == "abc 弢ⓐ def"
  check "ABC ⒶΪ DEF".toLower == "abc ⓐϊ def"
  check "ABC 弢Ϊ DEF".toLower == "abc 弢ϊ def"
  check "ABC 弢 DEF".toLower == "abc 弢 def"
  check "ABC Ⓐ DEF".toLower == "abc ⓐ def"
  check "ABC Ϊ DEF".toLower == "abc ϊ def"
  block testLongerResult:
    const be = "İEİEİEİE-İEİEİEİE-İEİEİEİE-İEİEİEİE"
    const se = "i̇ei̇ei̇ei̇e-i̇ei̇ei̇ei̇e-i̇ei̇ei̇ei̇e-i̇ei̇ei̇ei̇e"
    check be.len < se.len
    check (be & be & be & be & be & be & be & be).toLower ==
          (se & se & se & se & se & se & se & se)

test "cmpCaseless":
  check cmpCaseless("a", "a")
  check cmpCaseless("ab", "ab")
  check cmpCaseless("abc", "abc")
  check cmpCaseless("ABC", "abc")
  check(not cmpCaseless("b", "a"))
  check(not cmpCaseless("abc", "abcd"))
  check(not cmpCaseless("abcd", "abc"))
  check cmpCaseless("σ", "Σ")
  check cmpCaseless("ΐe", "Ϊ́E")
  check cmpCaseless("Ϊ́E", "ΐe")
  check cmpCaseless("CafÉ", "Café")
  check cmpCaseless("Caf\u0045\u0301", "Caf\u0065\u0301")
  check cmpCaseless("\u1FA0", "\u1F60\u03B9")  # pre-CaseFolded
  check cmpCaseless("\u1F60\u03B9", "\u1FA0")
  check cmpCaseless("\u1F60\u03B9\u1FA0", "\u1FA0\u1F60\u03B9")
  check cmpCaseless("\u1FA0\u1F60\u03B9", "\u1F60\u03B9\u1FA0")
  check cmpCaseless("\u1FA0\u1F60\u03B9", "\u1FA0\u1F60\u03B9")
  check(not cmpCaseless("\u1FA0", "x"))

test "cmpCaseless all":
  for cp in 0 .. 0x10FFFF:
    var s = ""
    for r in caseFold(cp.Rune):
      s.add r.toUtf8
    let org = cp.Rune.toUtf8
    check cmpCaseless(s, org)
    check cmpCaseless(org, s)
    check cmpCaseless(s & org, org & s)
    check cmpCaseless(org & s, s & org)
    check cmpCaseless(org & s & org, s & org & s)
    check cmpCaseless(s & org & s, org & s & org)
    check(not cmpCaseless(s & "a", org))
    check(not cmpCaseless(org & "a", s))
    check(not cmpCaseless(s & org & "a", org & s))

test "cmpCaseless max":
  var cMax = 0
  var i = 0
  for cp in 0 .. 0x10FFFF:
    i = 0
    for r in caseFold(cp.Rune):
      inc i
    cMax = max(cMax, i)
  # we may have to increase the
  # `cmpCaseless` buffer size if this increases
  doAssert cMax == 3
  # caseFold(0x1FE2) == 3 Runes
  # caseFold(0x1FE4) == 2 Runes
  # max filled buff is 6
  check(not cmpCaseless("\u1FE4\u1FE2", "\u1FE2\u1FE2"))
  check(not cmpCaseless("\u1FE2\u1FE2", "\u1FE4\u1FE2"))
