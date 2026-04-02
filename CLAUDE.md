# The Fool and his Money — Web Port

Port of Cliff Johnson's 2012 puzzle game from Macromedia Director 11 to the web.
The original is a Director Projector embedding 68 Flash SWFs for puzzle UIs. This
project extracts all assets and rebuilds the Director runtime in JavaScript,
rendering SWFs via [Ruffle](https://ruffle.rs) (Rust/WASM Flash emulator).

## Directory Layout

    poc/                      Web player (the thing we're building)
      index.html                Game mode entry point (/ route)
      debug.html                Debug mode with sidebar nav (/debug route)
      package.json              @ruffle-rs/ruffle + serve
      src/
        orchestrator.js           Main coordinator: navigation, polling, request dispatch
        game-state.js             Save/load system, puzzle state arrays (localStorage)
        puzzle-data.js            128 puzzle definitions (from Director's gatherAllData)
        swf-loader.js             Ruffle player wrapper + ExternalInterface bridge
        frame-swf-map.js          Maps frameId → SWF filename + stage heights
        prologue-controller.js    Two-SWF synchronized prologue FSM
      swf/                      Patched SWFs (gitignored; rebuild via scripts/patch_swfs.sh)

    extracted_chunks/decompiled/  Decompiled Lingo scripts — authoritative reference for game logic
      chunk_09_CDGF_*/casts/External/  Core game logic (MovieScripts 01-24)
      chunk_00_MDGF_*/              Main Director movie (init, loops)
      chunk_02_CDGF_*/              Tokens hub scripts
      chunk_05_CDGF_*/              Overlay/UI scripts
      chunk_06_CDGF_*/              Compendium scripts
      chunk_08_CDGF_*/              Prologue scripts
      chunk_23_CDGF_*/              Finale scripts

    extracted_media/              68 original (unpatched) SWF files
    scripts/patch_swfs.sh         Batch-patches SWFs with ExternalInterface bridge (requires Java + FFDec)

## Running

```sh
cd poc && npm install && npm start   # Serves at http://localhost:3000
```

SWF patching (only needed after modifying bridge code or re-extracting):
```sh
# Requires Java + JPEXS FFDec at ~/Downloads/ffdec/ffdec-cli.jar
./scripts/patch_swfs.sh              # extracted_media/*.swf → poc/swf/*.swf
```

## Architecture

JavaScript replaces Director as the orchestrator; 68 Flash SWFs (rendered by Ruffle)
remain as puzzle UIs. No build step — vanilla ES6 modules loaded directly by the browser.

### JS ↔ SWF Communication (ExternalInterface Bridge)

Bridge callbacks injected by patch_swfs.sh into each SWF's frame_1/DoAction:

| Callback | Purpose |
|----------|---------|
| `getVar(name)` | Read `_root[name]` (always returns string) |
| `setVar(name, value)` | Write to `_root` (supports dot-paths like `dim1._visible`) |
| `gotoFrame(n)` / `callFrame(n)` | gotoAndStop / gotoAndPlay |
| `processChunkHelp` / `processChunkPage` | Trigger help/page rendering |
| `enableStandaloneMode` | Register mouse/keyboard listeners (call only after gListener=666) |

Polled variables (orchestrator reads every 500ms):
- `gListener=666` — SWF initialized and ready
- `gStat>=100` — puzzle solved
- `gFlashRequest` — pipe-delimited navigation/action codes
- `gClickToContinue` — triggers click-to-continue overlay
- `gData` — puzzle state string

JS writes: `gFlashCommand` (0=idle, 6=reset, 7=undo), `chunkPage`, `chunkHelp`

### gFlashRequest Codes

Pipe-delimited, parsed sequentially. Key codes:
- **1/2/8/9/10** — launch puzzle (next token = puzzle index)
- **13** — calc scroll page
- **14** — set help chunk (next token = help path like "30/1/")
- **17** — save current puzzle
- **19** — update menu items (next token = 8-char menu string)
- **88** — go to Game Menus
- **98** — go to Moon's Puzzles
- **100** — Tokens hub (next token = subcode: 1=play, 3=save+switch, 8=quit, 10=return, 16=help)

Full reference: `extracted_chunks/decompiled/chunk_09_*/casts/External/MovieScript 5 - 05-Requests.ls`

### Layout System (3 modes by SWF stage height)

| Height | Mode | Visible overlays |
|--------|------|------------------|
| 320px (default) | Regular puzzle | Menu bar + help area + scroll arrows |
| 580px | Special (HP, Tarot, Map) | Menu bar; help overlays puzzle |
| 600px | Full-screen (Tokens, Pre/End-HP) | None |

Heights defined in `FRAME_STAGE_HEIGHT` in frame-swf-map.js.

### Overlay SWFs (from chunk_05)

Loaded once at startup as separate Ruffle instances:
- `swf_010` — menu bar (passive display; click detection by x-coordinate in JS)
- `swf_011` — help display
- `swf_012` — scroll frame
- `swf_008`/`swf_009` — scroll arrows

## Game State

128 puzzles (1-indexed), defined in `PUZZLES` array in puzzle-data.js.

State arrays mirror Director globals: `pStat[]`, `pData[]`, `pPage[]`, `pMenu[]`,
`pSwords[]`, `pWands[]`, `pCups[]`, `pPentacles[]`. Persisted to single localStorage key `tfahm_game_state`.

Named constants in `C` object: `PROLOGUE=1, TOKENS=100, GAME_MENUS=99, MOONS_MAP=97, PUZZLE_TOTAL=128`

Sections: Prologue(1), Swords(2-18), Wands(19-37), Cups(38-55), Pentacles(56-71),
PreFinale(72), Mansion(73-79), Finale(80-81), Special(87-100), Deliveries(101-107),
Hexes(108-114), Remainders(115-121), Connections(122-128)

### FlashVars (JS → SWF at load time)

`GameState.getFlashVars()` builds parameters matching Director's `sendFlashData()`:
`pNum`, `pGameNum`, `pStat`, `pData`, `pVolume`, suit progress, `pMenu`, `pMisc`, `DirectorInControl=1`.

SWFs are shared across puzzles — differentiated by `pNum` (e.g., morph-text SWF serves 3 puzzles with pNum 1/2/3).

## Lingo Reference (chunk_09 MovieScripts)

| Script | Content |
|--------|---------|
| `01-Initialization` | Global init, menu rects, default pMenu |
| `02-Misc` | sendFlashData, calcPage, get/setFlash helpers |
| `03-Launch` | initLaunch, launchPuzzle, _Launch_Tokens |
| `04-Read_Write` | Save game file I/O |
| `05-Requests` | gFlashRequest dispatch (doSpecialRequests) |
| `06-Update-Stats` | chunkMenuStat, mansion tiers, window codes |
| `07-Data` | gatherAllData — all 128 puzzle definitions |
| `08-StartUp` | Director startup sequence |
| `09-Special` | Special puzzle handling |
| `10-Menu` | Menu bar logic |
| `11-Arrows` | Scroll arrow logic |
| `12-Help` | Help system |
| `20-Tokens` | Tokens hub |
| `22-Prologue` | Prologue cue sequencing |
| `24-Finale` | Finale sequence |

Full path: `extracted_chunks/decompiled/chunk_09_CDGF_0x018e8434/casts/External/`

## Pitfalls

- **All ExternalInterface values are strings.** getVar returns strings; setVar coerces "true"/"false" and numeric strings. Use parseInt() when reading numbers.
- **gListener=666 is the SWF ready signal.** enableStandaloneMode must only be called after this.
- **gFlashCommand=666 is Tokens-only** — it tells the Tokens SWF that "Director" is ready. Don't send to puzzle SWFs.
- **DirectorInControl** stays at 1 (set in FlashVars). SWFs use this flag to decide whether to send `gFlashRequest` for navigation — when 0, functions like `_Launch_Tarot_Game()` skip sending requests and only call `$.debug()`. To compensate for the pMouseChunk hover fallback (which the SWFs only apply when DirectorInControl==0), the bridge installs a `_root.watch("pMouseChunk")` callback that fills the last known position whenever the SWF clears it. The flag also gates `_CHEAT()` (harmless in the port).
- **Prologue is special**: two SWFs synchronized via `prologueCue` variable, swapping roles between phases. See prologue-controller.js.
- **Mansion puzzles have tiered progression**: pStat thresholds unlock deliveries→hexes→remainders→connections based on Game Menus progress.
- **Menu bar is passive**: the SWF renders visuals but JS handles click detection via hardcoded x-coordinate rectangles from Director's misc_MakeRect calls.
- **Patched SWFs are gitignored** (poc/swf/). Run scripts/patch_swfs.sh after cloning.
