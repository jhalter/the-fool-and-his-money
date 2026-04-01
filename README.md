# The Fool and his Money — Web Port

A web port of Cliff Johnson's 2012 puzzle game
*[The Fool and his Money](http://www.fools-errand.com/09-TFAHM/index.htm)*,
originally built as a Macromedia Director 11 Projector.

The original binary is long dead on modern macOS. This project extracts all
assets and scripts from the Director projector and rebuilds the runtime in
JavaScript, rendering the game's 68 Flash SWF puzzle modules via
[Ruffle](https://ruffle.rs) (a Rust/WASM Flash emulator).

## How it works

JavaScript replaces Director as the orchestrator: puzzle sequencing, navigation,
save/load, menus, and state management. The 68 original Flash SWFs remain as
puzzle UIs, rendered by Ruffle in the browser. An ExternalInterface bridge
(injected into each SWF by `scripts/patch_swfs.sh`) enables JS to read/write
SWF variables, send commands, and poll for state changes.

No build step — vanilla ES6 modules loaded directly by the browser.

## Repository structure

```
poc/                        Web player
  index.html                  800x600 game area + sidebar navigation
  package.json                @ruffle-rs/ruffle + serve
  src/
    orchestrator.js              Navigation, polling, request dispatch
    game-state.js                Save/load, puzzle state arrays (localStorage)
    puzzle-data.js               128 puzzle definitions
    swf-loader.js                Ruffle player wrapper + ExternalInterface bridge
    frame-swf-map.js             Maps frameId -> SWF filename + stage heights
    prologue-controller.js       Two-SWF synchronized prologue FSM
  swf/                        Patched SWFs (gitignored; rebuild via scripts/patch_swfs.sh)

extracted_chunks/decompiled/  Decompiled Lingo scripts (authoritative reference)
extracted_media/              68 original (unpatched) SWF files
scripts/
  patch_swfs.sh                 Batch-patches SWFs with ExternalInterface bridge
  build-pages.sh                GitHub Pages deploy script
```

## Running

```sh
cd poc && npm install && npm start   # http://localhost:3000
```

SWF patching (only needed after modifying bridge code or re-extracting):

```sh
# Requires Java + JPEXS FFDec at ~/Downloads/ffdec/ffdec-cli.jar
./scripts/patch_swfs.sh              # extracted_media/*.swf -> poc/swf/*.swf
```

## Status

**Working:**
- All 128 puzzles loadable and playable via sidebar navigation
- ExternalInterface bridge (JS <-> SWF communication)
- Puzzle state persistence across navigation (gFlashCommand=4 save handshake)
- Save/load system (localStorage)
- Puzzle completion detection and progression engine
- Prologue sequence (two-SWF synchronized state machine)
- Menu bar, help overlay, scroll frame overlays
- Mansion tiered progression, Moon's Map, tarot/wager navigation
- Layout system (three modes by SWF stage height)

**Not implemented:**
- Audio
