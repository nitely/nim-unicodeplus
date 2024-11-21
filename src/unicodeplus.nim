## This module provides common unicode operations

from std/unicode import
  Rune, runes, `==`, fastRuneAt, fastToUtf8Copy

import pkg/unicodedb/properties
import pkg/unicodedb/types
import pkg/unicodedb/casing
import pkg/unicodedb/widths
import pkg/segmentation

const enableWidth = (NimMajor, NimMinor) >= (2, 0)
when enableWidth:
  import pkg/graphemes

export Rune

type
  verifyUtf8State = enum
    vusError, vusStart, vusA, vusB, vusC, vusD, vusE, vusF, vusG

# Ref http://unicode.org/mail-arch/unicode-ml/y2003-m02/att-0467/01-The_Algorithm_to_Valide_an_UTF-8_String
# and https://www.unicode.org/versions/Unicode15.0.0/ch03.pdf
# Table 3-7. Well-Formed UTF-8 Byte Sequences
func verifyUtf8*(s: openArray[char]): int =
  ## Return `-1` if `s` is a valid utf-8 string.
  ## Otherwise, return the index of the first bad char.
  var state = vusStart
  var i = 0
  let L = s.len
  while i < L:
    case state:
    of vusStart:
      result = i
      state = if uint8(s[i]) in 0x00'u8 .. 0x7F'u8: vusStart
      elif uint8(s[i]) in 0xC2'u8 .. 0xDF'u8: vusA
      elif uint8(s[i]) in 0xE1'u8 .. 0xEC'u8 or uint8(s[i]) in 0xEE'u8 .. 0xEF'u8: vusB
      elif uint8(s[i]) == 0xE0'u8: vusC
      elif uint8(s[i]) == 0xED'u8: vusD
      elif uint8(s[i]) in 0xF1'u8 .. 0xF3'u8: vusE
      elif uint8(s[i]) == 0xF0'u8: vusF
      elif uint8(s[i]) == 0xF4'u8: vusG
      else: vusError
    of vusA:
      state = if uint8(s[i]) in 0x80'u8 .. 0xBF'u8: vusStart else: vusError
    of vusB:
      state = if uint8(s[i]) in 0x80'u8 .. 0xBF'u8: vusA else: vusError
    of vusC:
      state = if uint8(s[i]) in 0xA0'u8 .. 0xBF'u8: vusA else: vusError
    of vusD:
      state = if uint8(s[i]) in 0x80'u8 .. 0x9F'u8: vusA else: vusError
    of vusE:
      state = if uint8(s[i]) in 0x80'u8 .. 0xBF'u8: vusB else: vusError
    of vusF:
      state = if uint8(s[i]) in 0x90'u8 .. 0xBF'u8: vusB else: vusError
    of vusG:
      state = if uint8(s[i]) in 0x80'u8 .. 0x8F'u8: vusB else: vusError
    of vusError:
      break
    inc i
  if state == vusStart:
    result = -1

template debugVerifyUtf8(s: string): untyped =
  when not defined(release):
    assert(verifyUtf8(s) == -1, "Invalid utf-8 input")

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
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(s)
  runeCheck(s, isWhiteSpace)

func isWhiteSpace*(s: seq[Rune]): bool {.deprecated: "Use isWhiteSpace(string)".} =
  runeCheck(s, isWhiteSpace)

func isUpper*(c: Rune): bool =
  utmUppercase in c.unicodeTypes()

func isUpper*(s: string): bool =
  ## return `true` if all cased runes are
  ## upper-case and there is at least one cased rune
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(s)
  caseConversionImpl(s, upperCase)

func toLower*(s: string): string {.inline.} =
  ## Return `s` in lower case.
  ## Beware the result may be
  ## longer than `s`
  debugVerifyUtf8(s)
  caseConversionImpl(s, lowerCase)

func toTitle*(s: string): string {.inline.} =
  ## Return `s` in title case.
  ## Beware the result may be
  ## longer than `s`
  debugVerifyUtf8(s)
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
  debugVerifyUtf8(a)
  debugVerifyUtf8(b)
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
    if idxA < idxB:  # only increase one buffer
      while idxA < idxB and riA < a.len:
        fillBuffA()
    elif idxB < idxA:
      while idxB < idxA and riB < b.len:
        fillBuffB()
    if idxA != idxB:
      return false
    if toOpenArray(buffA, 0, idxA) != toOpenArray(buffB, 0, idxB):
      return false
    idxA = 0
    idxB = 0
  return riA == a.len and riB == b.len

func findBadSeqUtf8*(s: openArray[char]): Slice[int] =
  ## Return a zero len `Slice` if `s` is a valid utf-8 string.
  ## Otherwise, return the first invalid bytes sequence bounds.
  let start = verifyUtf8(s)
  if start == -1:
    return 0 .. -1
  var i = start+1
  let L = s.len
  # skip continuations
  while i < L:
    if uint8(s[i]) shr 6 != 0b10:
      break
    inc i
  return start .. i-1

func add2(s: var string, x: openArray[char]) =
  for c in x:
    s.add c

func toValidUtf8*(s: string, replacement = "\uFFFD"): string =
  ## Return `s` with invalid utf-8 bytes sequences replaced by the
  ## `replacement` value.
  if verifyUtf8(s) == -1:
    return s
  result = newStringOfCap(s.len)
  var oldLen = -1
  var i = 0
  var j = 0
  var i2 = -1
  while i < s.len:
    doAssert i > i2; i2 = i
    j = verifyUtf8 toOpenArray(s, i, s.len-1)
    if j == -1:
      break
    result.add2 toOpenArray(s, i, i+j-1)
    if oldLen != result.len:
      result.add replacement
      oldLen = result.len
    i += j+1
  result.add2 toOpenArray(s, i, s.len-1)

when enableWidth:
  func width(c: Rune, cjk: bool): int =
    if c.int == 0xFE0F:  # emoji style
      return 2
    result = case c.unicodeWidth()
      of uwdtFull, uwdtWide: 2
      of uwdtAmbiguous:
        if cjk: 1 else: 2
      else: 1

  func width*(s: string, cjk = false): int =
    ## Return the display width of `s`.
    ## This is usually correct for monospaced fonts,
    ## but it may not be accurate in some cases.
    ## Requires Nim >= 2.
    result = 0
    var i = 0
    var i2 = 0
    var c = Rune(0)
    var w = 0
    for bounds in s.graphemeBounds:
      i = 0
      i2 = -1
      c = Rune(0)
      w = 0
      while i < bounds.b-bounds.a+1:
        doAssert i > i2, "invalid utf8"
        i2 = i
        fastRuneAt(toOpenArray(s, bounds.a, bounds.b), i, c)
        w = max(w, c.width(cjk))
      result += w
