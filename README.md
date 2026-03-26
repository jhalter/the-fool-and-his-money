# The Fool and his Money — Web Port

An exploration to see if we can run Cliff Johnson's puzzle game
"The Fool and his Money" on a modern platform (the web).

## Background

The original game is a **Macromedia Director 11 Projector** (circa 2012) that
embeds Flash (SWF) modules for its puzzle UIs. Director orchestrates everything:
puzzle sequencing, save/load, menus, audio, and state management. The SWF
modules handle rendering and input for individual puzzles.

Director 11 is long dead, and the PPC/Intel binary won't run on current macOS.
This project extracts the game's assets and scripts and rebuilds the runtime
for the browser.

## Architecture

The game is a two-layer system:

1. **Director layer** (Lingo scripts) — the orchestrator. Manages 128 puzzles
   across tarot-themed sections (Swords, Wands, Cups, Pentacles, Mansion, etc.),
   handles save/load across 12 game slots, and communicates with the Flash
   modules via `getVariable`/`setVariable`.

2. **Flash layer** (68 SWF files) — the puzzle UIs. Each puzzle is a
   self-contained Flash module that receives state from Director and reports
   results back.

## Repository structure

```
extracted_chunks/     Decompiled Director data (44 chunks)
  decompiled/           Lingo scripts (.ls), cast data, binary chunks
extracted_media/      68 SWF files extracted from the Director binary
poc/                  Proof-of-concept web player (Ruffle + static HTML)
TFaHM-Mac/            Original Mac app (not committed, in .gitignore)
```

## Running the POC

The proof of concept loads extracted SWF files in the browser using
[Ruffle](https://ruffle.rs), a Rust/WASM Flash emulator.

```sh
cd poc
npm install
npm start
```

Then open the URL shown in the terminal (typically http://localhost:3000).

Select a SWF from the dropdown and click "Load SWF". Puzzles run in standalone
mode without the Director orchestration layer.

## Status

- **Done**: Asset extraction, Lingo script decompilation, SWF extraction,
  Ruffle-based rendering proof of concept
- **Not started**: Director-to-Flash communication bridge, puzzle state machine,
  save/load system, menu/navigation, audio
