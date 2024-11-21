# Package

version = "0.14.2"
author = "Esteban Castro Borsani (@nitely)"
description = "Common unicode operations"
license = "MIT"
srcDir = "src"

# Dependencies

requires "nim >= 1.0"
requires "unicodedb >= 0.8"
requires "segmentation >= 0.1"
requires "graphemes >= 0.12"

task test, "Test":
  exec "nim c -r tests/tests"
  exec "nim c -r -d:release tests/tests"

task docs, "Docs":
  exec "nim doc --project -o:./docs ./src/unicodeplus.nim"
