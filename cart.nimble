import std/[os, strformat]

# Package
version = "0.1.0"
author = "William Guimont-Martin (willGuimont) and Samuel Rouleau (samX500)"
description = "Rolly Dango, an isometric rolling puzzle made with [WASM-4]"
license = "MIT"
srcDir = "src"

# Dependencies
# requires ""

# Build
let outFile = "build" / "cart.wasm"
requires "nim >= 1.4.0"

# Tests
before test:
  exec "nimformat"

# Debug
before dbg:
  exec "nimformat"

task dbg, "Build the cartridge in debug mode":
  exec &"nim c -o:{outFile} src/cart.nim"

# Release
before rel:
  exec "nimformat"

task rel, "Build the cartridge with all optimizations":
  exec &"nim c -d:danger -o:{outFile} src/cart.nim"

after rel:
  let exe = findExe("wasm-opt")
  if exe != "":
    exec(&"wasm-opt -Oz --strip-producers {outFile} -o {outFile}")
  else:
    echo "Tip: wasm-opt was not found. Install it from binaryen for smaller builds!"
