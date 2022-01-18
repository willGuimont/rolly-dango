# wasm4-game-jam-2022

Rolly Dango, an isometric rolling puzzle made with [WASM-4](https://wasm4.org/).

[Try the game here](https://willguimont.github.io/wasm4-game-jam-2022/) or on [itch.io](https://willguimont.itch.io/rolly-dango)!

![rolly dango](assets/game.png)

Here's some key points of our project:

- We made our own ECS (entity-component-systems) from scratch
- To save cartridge space, we built our own Huffman coding algorithm
- To help ourselves make levels, we built our own level editor using [p5.js](https://p5js.org/)
- Made all of our sprites using [Aseprite](https://www.aseprite.org/)

Our level editor:
![level editor](assets/editor.png)

## Dependencies

If you want to play from the cartridge, you'll need to install our fork ([willGuimont/wasm4](https://github.com/willGuimont/wasm4)) of wasm4. Since we used Nim, we found that we needed to add a function to the [WASM-4](https://wasm4.org/docs/getting-started/setup) runtime (`wasi_snapshot_preview1.proc_exit`), to use any of the standard library.

Otherwise, we'd get `Uncaught (in promise) TypeError: import object field 'wasi_snapshot_preview1' is not an Object` errors while running the game. This is the only modification we did to the WASM-4 runtime.

So to run this game from the cartridge, you'll need to install [willGuimont/wasm4](https://github.com/willGuimont/wasm4).

To install it, run the following commands:

```bash
git clone https://github.com/willGuimont/wasm4
cd wasm4/runtimes/web
npm install && npm run build
cd ../../cli
npm install && npm link
```

Optionally, you can install [binaryen](https://github.com/WebAssembly/binaryen) to optimize further the binary size.

## Build cartridge

```bash
# Debug mode
nimble dbg
# Release mode
nimble rel
```

## Run the tests

```bash
nimble test
```

## Deploy to GitHub-Pages

```bash
./deploy.sh
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
w4 bundle --html build/html/index.html --title Dango --description "Rolling puzzle game" --icon-file "assets/sprites/dangoBeeg.png" build/cart.wasm
w4 bundle --linux dango carts/cart.wasm
```
