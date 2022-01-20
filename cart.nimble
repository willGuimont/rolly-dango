import std/[os, strformat]

# Package
version = "0.1.0"
author = "willGuimont and samX500"
description = "Rolly Dango, an isometric rolling puzzle made with WASM-4"
license = "MIT"
srcDir = "src"

# Dependencies
# requires "..."

# Build
let outFile = "build" / "cart.wasm"
requires "nim >= 1.4.0"

# Tests
before test:
  exec "./nimformat.sh"

# Debug
before dbg:
  exec "./nimformat.sh"

task dbg, "Build the cartridge in debug mode":
  exec &"nim c -d:nimNoQuit -o:{outFile} src/cart.nim"

# Release
before rel:
  exec "./nimformat.sh"

task rel, "Build the cartridge with all optimizations":
  exec &"nim c -d:nimNoQuit -d:danger -o:{outFile} src/cart.nim"

after rel:
  let exe = findExe("wasm-opt")
  if exe != "":
    exec(&"wasm-opt -Oz --converge --strip-producers --strip-debug --strip-dwarf --strip-target-features -all --zero-filled-memory --traps-never-happen --ignore-implicit-traps --const-hoisting {outFile} -o {outFile}")
  else:
    echo "Tip: wasm-opt was not found. Install it from binaryen for smaller builds!"
