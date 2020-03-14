# Package

version = "0.7.0"
author = "Esteban Castro Borsani (@nitely)"
description = "Common unicode operations"
license = "MIT"
srcDir = "src"

# Dependencies

requires "nim >= 0.19.0"
requires "unicodedb >= 0.8"
requires "segmentation >= 0.1"

task test, "Test":
  exec "nim c -r tests/tests"

task docs, "Docs":
  exec "nim doc2 -o:./docs/index.html ./src/unicodeplus.nim"
