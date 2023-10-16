# Package

version = "0.10.0"
author = "Esteban Castro Borsani (@nitely)"
description = "Common unicode operations"
license = "MIT"
srcDir = "src"

# Dependencies

requires "nim >= 1.0"
requires "unicodedb >= 0.8"
requires "segmentation >= 0.1"

task test, "Test":
  exec "nim c -r tests/tests"

task docs, "Docs":
  exec "nim doc --project -o:./docs ./src/unicodeplus.nim"
