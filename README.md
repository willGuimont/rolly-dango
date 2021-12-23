# wasm4-game-jam-2022

Rolly Dango, an isometric rolling puzzle made with [WASM-4](https://wasm4.org/)

## Game plan

Here's the plan for the development of the game:

Phase 1:
- Implement a basic isometric renderer
- Implement a controllable character
- Implement the rolling mechanism with slopes

Phase 2:
- Implement sticky rice that stops the player's rolling
- Implement spikes that kill you on contact
- Implement breakable obstacles

Phase 3:
- Implement doors that open with keys
- Implement moving tiles (elevator, moving platform)
- Implement buttons to control game objects

## Dependencies

Install [WASM-4](https://wasm4.org/docs/getting-started/setup).

Optionally, you can install binaryen to optimize further the binary size.

## Build cartridge

```bash
# Debug mode
nimble dbg
# Release mode
nimble rel
```

## Running the cartridge

```bash
# Run compiled cartridge in your web browser
w4 run build/cart.wasm
# Run with hot reloading
w4 watch
# Run natively
w4 run-native build/cart.wasm
```

## Useful tools

### [png2src](https://wasm4.org/docs/reference/cli#png2src)

```bash
w4 png2src --nim top.png down.png left.png right.png
```

### [bundle](https://wasm4.org/docs/reference/cli#bundle)
```bash
w4 bundle --html dango.html --title Dango --description "Rolling puzzle game" --icon-file "dango.png" build/cart.wasm
w4 bundle --linux dango carts/cart.wasm
```
