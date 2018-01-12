# UnicodePlus

[![Build Status](https://img.shields.io/travis/nitely/nim-unicodeplus.svg?style=flat-square)](https://travis-ci.org/nitely/nim-unicodeplus)
[![licence](https://img.shields.io/github/license/nitely/nim-unicodeplus.svg?style=flat-square)](https://raw.githubusercontent.com/nitely/nim-unicodeplus/master/LICENSE)

A replacement for Nim's unicode module. It closely
follows Python's API behavior for each operation.

> Note: this is a WIP! But what's
> implemented is already ready to use.

## Usage

```nim
# This won't be required when unicodeplus is complete
import unicode except
  isTitle, isLower, isUpper, isAlpha, isWhiteSpace
import unicodeplus

assert "abc".isLower()
assert "ABC".isUpper()
assert "A Title - Yes!".isTitle()
assert "  \L".isWhiteSpace()
assert "abc123۲⅕".isAlnum()
assert "abcd".isAlpha()
assert "0123456789".isDecimal()
assert "0123456789۲".isDigit()
assert "0123456789۲⅕".isNumeric()
assert "abcd".isPrintable()
```

[docs](https://nitely.github.io/nim-unicodeplus/)

## vs Nim's stdlib

Although this library will be a replacement
for Nim's unicode module, it's not a *drop-in replacement*.
Some of the APIs don't show the same behavior.

To illustrate:

```nim
import unicode

echo "A Title - Maybe?".isTitle()
# false
```

```nim
import unicodeplus

echo "A Title - Maybe?".isTitle()
# true
```

## Tests

```
nimble test
```

## LICENSE

MIT
