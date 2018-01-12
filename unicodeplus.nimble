# Package

version       = "0.1.0"
author        = "Esteban Castro Borsani (@nitely)"
description   = "Common unicode operations"
license       = "MIT"
srcDir = "src"

# Dependencies

requires "nim >= 0.17.2"
requires "unicodedb >= 0.2 & <= 0.3"

task test, "Test":
  exec "nim c -r src/unicodeplus"

task docs, "Docs":
  exec "nim doc2 -o:./docs/index.html ./src/unicodeplus.nim"
