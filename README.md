# UnicodePlus

[![Build Status](https://img.shields.io/travis/nitely/nim-unicodeplus.svg?style=flat-square)](https://travis-ci.org/nitely/nim-unicodeplus)
[![licence](https://img.shields.io/github/license/nitely/nim-unicodeplus.svg?style=flat-square)](https://raw.githubusercontent.com/nitely/nim-unicodeplus/master/LICENSE)

Common unicode operations.

## Install

```
nimble install unicodeplus
```

## Compatibility

Nim 0.19, 0.20, +1.0

## Usage

```nim
import unicodeplus

assert "abc def ghi".isLower
assert "ABC DEF GHI".isUpper
assert "A Title - Yes!".isTitle
assert "  \L".isWhiteSpace
assert "abc123۲⅕".isAlnum
assert "abcd".isAlpha
assert "0123456789".isDecimal
assert "0123456789۲".isDigit
assert "0123456789۲⅕".isNumeric
assert "abcd".isPrintable
assert "The quick? (“brown”) fox can’t jump 32.3 feet, right?".toTitle ==
  "The Quick? (“Brown”) Fox Can’t Jump 32.3 Feet, Right?"
assert "The quick? (“brown”) fox can’t jump 32.3 feet, right?".toUpper ==
  "THE QUICK? (“BROWN”) FOX CAN’T JUMP 32.3 FEET, RIGHT?"
assert "The quIck? (“bRown”) fox cAn’T jUMp 32.3 feet, rIGHt?".toLower ==
  "the quick? (“brown”) fox can’t jump 32.3 feet, right?"
assert cmpCaseless("AbCσ", "aBcΣ")
```

[docs](https://nitely.github.io/nim-unicodeplus/)

## Tests

```
nimble test
```

## LICENSE

MIT
