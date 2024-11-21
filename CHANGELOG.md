v0.14.2
==================

* Fix display `width`

v0.14.0
==================

* Add display `width`

v0.13.0
==================

* Add utf-8 validation to every API taking a string. Only in debug mode.

v0.12.0
==================

* Change `findBadSeqUtf8` to include continuation bytes

v0.11.1
==================

* Fix `findBadSeqUtf8` off by one result

v0.11.0
==================

* Add `findBadSeqUtf8(openArray[char]): Slice[int]`
  to get the bad char bounds not just the start index
* Change `toValidUtf8` behaviour to replace bad byte sequences
  by a single replacement value

v0.10.0
==================

* Add `verifyUtf8`
* Add `toValidUtf8` for all supported Nim versions

v0.9.1
==================

* Fix unused func

v0.9.0
==================

* Add `toValidUtf8(string, string): string`
* Drop support for Nim < 1.0

v0.8.0
==================

* Deprecate all funcs taking `seq[Rune]`

v0.7.0
==================

* Add `cmpCaseless`

v0.6.0
==================

* Add `toTitle`, `toUpper`, and `toLower`
* Drop Nim 0.18 support

v0.5.1
==================

* Fixes index error when checking ascii char 127
* Add Nim 0.20 to CI config

v0.5.0
==================

* Update to unicode 12.1

v0.4.0
==================

* Drop Nim 0.17 support
* Add Nim 0.19 support
* Update dependencies

v0.3.2
==================

* ASCII optimizations

v0.3.0
==================

* Export stdlib `unicode` module

v0.2.0
==================

* Update to unicode 11

v0.1.1
==================

* Improves compilation time

v0.1.0
==================

* Initial release
