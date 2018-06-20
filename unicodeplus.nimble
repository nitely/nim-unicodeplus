# Package

version = "0.3.2"
author = "Esteban Castro Borsani (@nitely)"
description = "Common unicode operations"
license = "MIT"
srcDir = "src"

# Dependencies

requires "nim >= 0.17.2"
requires "unicodedb >= 0.4 & < 0.6"

task test, "Test":
  exec "nim c -r tests/tests"

task docs, "Docs":
  exec "nim doc2 -o:./docs/index.html ./src/unicodeplus.nim"
