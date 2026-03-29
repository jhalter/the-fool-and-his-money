// Main orchestrator tying together game state, SWF loading, and navigation.
// Polls SWFs via ExternalInterface for completion detection and navigation requests.

import { PUZZLES, PUZZLE_TYPES, SECTION_RANGES, C } from './puzzle-data.js';
import { GameState } from './game-state.js';
import { SwfLoader, OverlayLoader } from './swf-loader.js';
import { PrologueController } from './prologue-controller.js';

export class Orchestrator {
  constructor() {
    this.state = new GameState();
    this.loader = null;
    this.menuLoader = null;
    this.navEl = null;
    this.pollTimer = null;
    this.lastGStat = null;
    this.prologueController = null;
    this.clickToContinue = false;
    this._ctcHandler = null;
  }

  async init() {
    this.loader = new SwfLoader(
      document.getElementById('player-container'),
      document.getElementById('status')
    );
    this.menuLoader = new OverlayLoader(
      document.getElementById('menu-container')
    );
    this.helpLoader = new OverlayLoader(
      document.getElementById('help-player')
    );
    this.navEl = document.getElementById('nav-list');

    this.state.load();
    this.buildNav();
    this.bindControls();

    // Load the overlay SWFs
    this.scrollFrame = new OverlayLoader(document.getElementById('scroll-frame'));
    const scrollLeft = new OverlayLoader(document.getElementById('scroll-left'));
    const scrollRight = new OverlayLoader(document.getElementById('scroll-right'));
    await Promise.all([
      this.menuLoader.load('chunk_05_CDGF_0x00a7c7a8_swf_010_v8.swf'),
      this.helpLoader.load('chunk_05_CDGF_0x00a7c7a8_swf_011_v8.swf', { wmode: 'transparent' }),
      scrollLeft.load('chunk_05_CDGF_0x00a7c7a8_swf_008_v8.swf'),
      this.scrollFrame.load('chunk_05_CDGF_0x00a7c7a8_swf_012_v8.swf'),
      scrollRight.load('chunk_05_CDGF_0x00a7c7a8_swf_009_v8.swf'),
    ]);
    // Hide menu text overlays after init
    setTimeout(() => {
      this.menuLoader.setVar('saveText._visible', 'false');
      this.menuLoader.setVar('saveBG._visible', 'false');
      this.menuLoader.setVar('clickText._visible', 'false');
      this.menuLoader.setVar('clickBG._visible', 'false');
      this.menuLoader.setVar('clickBG-Full._visible', 'false');
    }, 500);

    // Load last puzzle or default to Tokens hub (the game's main screen)
    const startPuzzle = this.state.currPuzzle || C.TOKENS;
    this.launchPuzzle(startPuzzle);
  }

  buildNav() {
    this.navEl.innerHTML = '';

    for (const section of SECTION_RANGES) {
      const header = document.createElement('div');
      header.className = 'nav-section';
      header.textContent = section.name;
      header.addEventListener('click', () => {
        const list = header.nextElementSibling;
        list.classList.toggle('collapsed');
      });
      this.navEl.appendChild(header);

      const list = document.createElement('div');
      list.className = 'nav-items';

      for (let i = section.start; i <= section.end; i++) {
        const puzzle = PUZZLES[i];
        if (!puzzle || puzzle.frameId === '---') continue;

        const item = document.createElement('div');
        item.className = 'nav-item';
        item.dataset.puzzleId = i;
        this.updateNavItem(item, i);

        item.addEventListener('click', () => this.launchPuzzle(i));

        item.addEventListener('contextmenu', (e) => {
          e.preventDefault();
          this.toggleSolved(i);
        });

        list.appendChild(item);
      }

      this.navEl.appendChild(list);
    }
  }

  updateNavItem(item, puzzleIndex) {
    const puzzle = PUZZLES[puzzleIndex];
    const stat = this.state.pStat[puzzleIndex];
    const isCurrent = puzzleIndex === this.state.currPuzzle;

    let statusIcon = '\u25CB'; // empty circle
    if (stat >= 100) statusIcon = '\u25CF'; // filled circle

    item.textContent = `${statusIcon} ${puzzle.titleName}`;
    item.className = 'nav-item';
    if (isCurrent) item.classList.add('current');
    if (stat >= 100) item.classList.add('solved');
  }

  refreshNav() {
    const items = this.navEl.querySelectorAll('.nav-item');
    for (const item of items) {
      const id = parseInt(item.dataset.puzzleId);
      if (id) this.updateNavItem(item, id);
    }
  }

  async launchPuzzle(puzzleIndex) {
    // Apply launch exception redirects (Finale→PreFinale, PreHP→HP, etc.)
    // Skip for Tokens — Director uses a separate _Launch_Tokens() path that
    // bypasses exceptionPuzzleLaunch. The Tokens redirect in exceptionPuzzleLaunch
    // is only used when saving (to convert currPuzzle to a resume-safe value).
    if (puzzleIndex !== C.TOKENS) {
      puzzleIndex = this.state.exceptionPuzzleLaunch(puzzleIndex, false);
    }

    const puzzle = PUZZLES[puzzleIndex];
    if (!puzzle) return;

    this.stopPolling();
    this.exitClickToContinue();

    // Clean up any running Prologue controller
    if (this.prologueController) {
      this.prologueController.stop();
      this.prologueController = null;
    }
    // Always ensure prologue container is hidden — the completion/abort
    // callbacks null prologueController before calling launchPuzzle,
    // so the check above may not catch it.
    document.getElementById('prologue-container').style.display = 'none';

    this.state.lastPuzzle = this.state.currPuzzle;
    this.state.currPuzzle = puzzleIndex;

    // Run the core progression engine before loading the SWF
    this.state.updateGameStats(this.state.currGame);
    this.state.save();

    document.title = `The Fool and his Money - ${puzzle.titleName}`;

    // Mansion puzzles use dynamic frameId based on game menu phase
    let frameIdOverride;
    if (puzzleIndex >= C.MANSION1 && puzzleIndex <= C.MANSION2) {
      frameIdOverride = this.state.getMansionFrameId();
    }

    const ok = await this.loader.loadPuzzle(puzzleIndex, this.state, frameIdOverride);
    if (ok) {
      this.refreshNav();
      this.lastGStat = null;

      // Tokens screen needs gFlashCommand=666 to signal Director is ready
      if (puzzleIndex === C.TOKENS) {
        setTimeout(() => {
          this.loader.setVar('gFlashCommand', '666');
        }, 300);
      }

      // Prologue needs its own two-SWF controller instead of normal polling
      if (puzzleIndex === C.PROLOGUE) {
        const prologueContainer = document.getElementById('prologue-container');
        this.prologueController = new PrologueController(
          () => {
            this.state.pStat[C.PROLOGUE] = 100;
            this.state.save();
            this.refreshNav();
            this.prologueController = null;
            this.launchPuzzle(C.GAME_MENUS);
          },
          () => {
            this.prologueController = null;
            this.launchPuzzle(C.GAME_MENUS);
          }
        );
        this.prologueController.start(this.loader, prologueContainer);
      }

      // Switch layout based on SWF stage dimensions (mirrors Director's
      // sprite(cActiveSN).height checks in misc_InitPuzzle / menu_Init / arrow_F_Init)
      this.applyLayout(this.loader.getStageHeight());

      // Update menu item visibility based on pMenu[currPuzzle], matching
      // Director's menu_Set_Items() which hides/shows m1-m8 per-puzzle.
      this.updateMenuItems(puzzleIndex);

      // Prologue uses its own polling via PrologueController
      if (puzzleIndex !== C.PROLOGUE) {
        this.startPolling();
      }
    }
  }

  startPolling() {
    // Director polled at 15ms (idleHandlerPeriod=15). 500ms was too slow —
    // the SWF overwrites gFlashRequest each frame, so we missed codes.
    // Uses a single batched ExternalInterface call (getPolledState) to minimize
    // WASM boundary crossings, which interfere with Ruffle's mouse event processing.
    this.pollTimer = setInterval(() => this.poll(), 100);
  }

  stopPolling() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer);
      this.pollTimer = null;
    }
  }

  poll() {
    // Single batched ExternalInterface call returns gStat, gFlashRequest,
    // and gClickToContinue separated by \x01. The bridge also clears
    // gFlashRequest atomically, eliminating a separate setVar call.
    const raw = this.loader.getPolledState();
    if (raw == null) return;

    const [gStatStr, reqStr, ctcStr] = raw.split('\x01');
    const puzzleIndex = this.state.currPuzzle;

    // gStat — completion detection
    if (gStatStr) {
      const gStat = parseInt(gStatStr, 10);
      if (!isNaN(gStat) && gStat !== this.lastGStat) {
        this.lastGStat = gStat;
        if (gStat >= 100 && this.state.pStat[puzzleIndex] < 100) {
          this.onPuzzleSolved(puzzleIndex, gStat);
        }
      }
    }

    // gFlashRequest — navigation (already cleared by bridge)
    if (reqStr && reqStr !== '' && reqStr !== 'undefined' && reqStr !== 'null') {
      this.handleRequest(reqStr);
    }

    // gClickToContinue
    const ctcBool = (ctcStr === 'true' || ctcStr === '1');
    if (ctcBool !== this.clickToContinue) {
      if (ctcBool) {
        this.enterClickToContinue();
      } else {
        this.exitClickToContinue();
      }
    }
  }

  onPuzzleSolved(puzzleIndex, gStat) {
    const gData = this.loader.getVar('gData') || 'empty';
    this.state.pStat[puzzleIndex] = gStat;
    this.state.pData[puzzleIndex] = gData;
    this.state.save();
    this.refreshNav();
    console.log(`Puzzle ${puzzleIndex} solved (gStat=${gStat})`);
  }

  enterClickToContinue() {
    this.clickToContinue = true;
    this.menuLoader.setVar('clickText._visible', 'true');
    this.menuLoader.setVar('clickBG._visible', 'true');
    this._ctcHandler = () => this.dismissClickToContinue();
    document.getElementById('player-container')
      .addEventListener('click', this._ctcHandler, { once: true });
  }

  dismissClickToContinue() {
    this.loader.setVar('gClickToContinue', '0');
    this.exitClickToContinue();
  }

  exitClickToContinue() {
    if (!this.clickToContinue && !this._ctcHandler) return;
    this.clickToContinue = false;
    this.menuLoader.setVar('clickText._visible', 'false');
    this.menuLoader.setVar('clickBG._visible', 'false');
    if (this._ctcHandler) {
      document.getElementById('player-container')
        .removeEventListener('click', this._ctcHandler);
      this._ctcHandler = null;
    }
  }

  // Parse and dispatch a gFlashRequest string which may contain multiple
  // sequential codes: "13|0|14|30/1/|17|" = three requests (13, 14, 17)
  handleRequest(reqString) {
    const parts = reqString.split('|').filter(s => s !== '');
    if (parts.length === 0) return;

    // Tokens screen sends "100|subcode|params..."
    if (parseInt(parts[0], 10) === 100) {
      this.handleTokensRequest(parts);
      return;
    }

    // Process sequential request codes
    let i = 0;
    while (i < parts.length) {
      const code = parseInt(parts[i], 10);
      i++;
      if (isNaN(code)) continue;

      switch (code) {
        case 1: case 2: case 8: case 9: case 10: // launch puzzle
          if (i < parts.length) {
            this.launchPuzzle(parseInt(parts[i], 10));
            i++;
          }
          break;
        case 3: { // stat update — 1 param
          if (i < parts.length) i++; // consume param
          this.state.updateGameStats(this.state.currGame);
          break;
        }
        case 4: // go to Moon's Map
          this.launchPuzzle(C.MOONS_MAP);
          break;
        case 5: // go to Moon's Puzzles
          this.launchPuzzle(C.MOONS_PUZZLES);
          break;
        case 6: // go to Seven Cups
          this.launchPuzzle(C.SEVEN_CUPS);
          break;
        case 7: // go to Pre-Finale (with page=2)
          this.state.pPage[C.PRE_FINALE] = 2;
          this.launchPuzzle(C.PRE_FINALE);
          break;
        case 13: { // calc page — 1 param (page number)
          if (i < parts.length) {
            const page = parseInt(parts[i], 10) + 1;
            const puzzleNum = String(this.state.currPuzzle).padStart(2, '0');
            const chunkPage = puzzleNum + '/' + page + '/';
            this.scrollFrame.setVar('chunkPage', chunkPage);
            try {
              this.scrollFrame.ruffleApi.callExternalInterface('processChunkPage');
            } catch (e) { /* ignore */ }
            i++;
          }
          break;
        }
        case 14: { // set help — 1 param (helpChunk like "30/1/")
          if (i < parts.length) {
            this.helpLoader.setVar('chunkHelp', parts[i]);
            try {
              this.helpLoader.ruffleApi.callExternalInterface('processChunkHelp');
            } catch (e) { /* ignore */ }
            i++;
          }
          break;
        }
        case 17: // save current puzzle
          this.saveCurrent();
          break;
        case 18: // go to Pre-High Priestess
          this.launchPuzzle(C.PRE_HP);
          break;
        case 19: { // update menu key — 1 param (menu string like "12345--8")
          if (i < parts.length) {
            const menuStr = parts[i];
            if (menuStr.length === 8) {
              this.state.pMenu[this.state.currPuzzle] = menuStr;
              this.updateMenuItems(this.state.currPuzzle);
            }
            i++;
          }
          break;
        }
        case 20: { // game menu status update + compendium
          const gStat = parseInt(this.loader.getVar('gStat'), 10);
          if (!isNaN(gStat)) {
            this.state._setGameMenuStatus(gStat);
          }
          // Minimal compendium: update stats and return to game menus
          this.state.updateGameStats(this.state.currGame);
          this.launchPuzzle(C.GAME_MENUS);
          break;
        }
        case 30: // launch Finale
          this.launchPuzzle(C.FINALE);
          break;
        case 88: // go to game menus
          this.launchPuzzle(C.GAME_MENUS);
          break;
        case 89: // HP sequence from Pre-HP
          this.state._setGameMenuStatus(69);
          this.launchPuzzle(C.HIGH_PRIESTESS);
          break;
        case 90: // end HP
          this.launchPuzzle(C.END_HP);
          break;
        case 91: // moon morph from End-HP
          this.state.pStat[C.MOON_MORPH] = 190;
          this.launchPuzzle(C.MOON_MORPH);
          break;
        case 95: { // tarot launch — 1 param (tarot index 1-5)
          if (i < parts.length) {
            const n = parseInt(parts[i], 10);
            i++;
            if (n >= 1 && n <= 5) {
              this.state.csWagerTarot[n] = PUZZLE_TYPES.tarot[n - 1];
              this.launchPuzzle(this.state.csWagerTarot[n]);
            }
          }
          break;
        }
        case 96: { // wager launch — 1 param (wager index 1-5)
          if (i < parts.length) {
            const n = parseInt(parts[i], 10);
            i++;
            if (n >= 1 && n <= 5) {
              this.state._updateSolvedTarot();
              this.state.csWagerTarot[n] = PUZZLE_TYPES.wager[n - 1];
              this.launchPuzzle(this.state.csWagerTarot[n]);
            }
          }
          break;
        }
        case 98: // go to Moon's Map
          this.launchPuzzle(C.MOONS_MAP);
          break;
        default:
          console.log(`Unhandled request code: ${code}`);
      }
    }
  }

  handleTokensRequest(parts) {
    const subcode = parseInt(parts[1], 10);
    const param1 = parts[2] ? parseInt(parts[2], 10) : 0;
    const param2 = parts[3] ? parseInt(parts[3], 10) : 0;
    console.log(`Tokens request: subcode=${subcode} param1=${param1} param2=${param2}`);

    switch (subcode) {
      case 1: // Play game — launch from selected slot
        this.state.currGame = param1 || this.state.currGame;
        this.state.save();
        // Launch the last puzzle for this game, or default to first puzzle
        this.launchPuzzle(this.state.lastPuzzle > 0 && this.state.lastPuzzle !== C.TOKENS
          ? this.state.lastPuzzle : 2);
        break;
      case 3: // Save game (yes)
        this.state.currGame = param2 || param1;
        this.saveCurrent();
        // Signal save complete so SWF can continue
        this.loader.setVar('gFlashCommand', '0');
        break;
      case 4: // Don't save (no) — switch game without saving
        this.state.currGame = param2 || param1;
        this.state.save();
        this.loader.setVar('gFlashCommand', '0');
        break;
      case 5: // Revert game
        this.state.save();
        this.loader.setVar('gFlashCommand', '0');
        break;
      case 9: // Quit
        console.log('Quit requested — reloading Tokens screen');
        this.launchPuzzle(C.TOKENS);
        break;
      case 10: // Return to last puzzle
        if (this.state.lastPuzzle > 0 && this.state.lastPuzzle !== C.TOKENS) {
          this.launchPuzzle(this.state.lastPuzzle);
        }
        break;
      case 16: // Help
        this.launchPuzzle(C.HELP_TOKENS);
        break;
      default:
        console.log(`Unhandled Tokens subcode: ${subcode}`);
        // Acknowledge by clearing command
        this.loader.setVar('gFlashCommand', '0');
    }
  }

  saveCurrent() {
    const idx = this.state.currPuzzle;
    const gStat = this.loader.getVar('gStat');
    const gData = this.loader.getVar('gData');
    if (gStat) this.state.pStat[idx] = parseInt(gStat, 10) || this.state.pStat[idx];
    if (gData && gData !== 'undefined') this.state.pData[idx] = gData;

    // Read suit progress from SWF
    const gSwords = this.loader.getVar('gSwords');
    const gWands = this.loader.getVar('gWands');
    const gCups = this.loader.getVar('gCups');
    const gPentacles = this.loader.getVar('gPentacles');
    if (gSwords) this.state.pSwords[idx] = parseInt(gSwords, 10) || 0;
    if (gWands) this.state.pWands[idx] = parseInt(gWands, 10) || 0;
    if (gCups) this.state.pCups[idx] = parseInt(gCups, 10) || 0;
    if (gPentacles) this.state.pPentacles[idx] = parseInt(gPentacles, 10) || 0;

    // Read completion marker
    const gDone = this.loader.getVar('gDone');
    if (gDone && gDone !== 'undefined') this.state.pDone[idx] = gDone;

    // Sync completion data from Game Menus SWF
    const gMenuUpdate = this.loader.getVar('gMenuUpdate');
    if (gMenuUpdate) this.state.getMenuStatsFromFlash(gMenuUpdate);

    // Run progression engine after saving state
    this.state.updateGameStats(this.state.currGame);
    this.state.save();
    this.refreshNav();
  }

  toggleSolved(puzzleIndex) {
    if (this.state.pStat[puzzleIndex] >= 100) {
      this.state.markUnsolved(puzzleIndex);
    } else {
      this.state.markSolved(puzzleIndex);
    }
    this.refreshNav();
  }

  // Show/hide individual menu items (m1-m8) in the menu SWF based on
  // pMenu[currPuzzle], matching Director's menu_Set_Items().
  // pMenu is an 8-char string: each position corresponds to m1-m8.
  // A dash "-" means hidden; any other char means visible.
  //
  // Note: Director also changed the menu SWF's visual frame per puzzle
  // (tan scroll for regular, blue for Game Menus, etc.) via sprite.goToFrame().
  // That was a Director-level operation on the sprite timeline, not the Flash
  // timeline, so we can't replicate it via gotoAndStop on the SWF directly.
  updateMenuItems(puzzleIndex) {
    const menuKey = this.state.pMenu[puzzleIndex] || '12345--8';
    for (let x = 1; x <= 8; x++) {
      // Positions 6 (Reset) and 7 (Undo) are always kept visible.
      // The SWFs never send code 19 to enable them — they handled reset/undo
      // internally in Director. In our web port the menu bar is the primary
      // UI for these actions, so we keep them available.
      const visible = (x === 6 || x === 7) || menuKey[x - 1] !== '-';
      this.menuLoader.setVar(`m${x}._visible`, visible ? 'true' : 'false');
    }
  }

  applyLayout(stageHeight) {
    const playerContainer = document.getElementById('player-container');
    const helpContainer = document.getElementById('help-container');
    const menuContainer = document.getElementById('menu-container');
    const helpPlayer = document.getElementById('help-player');

    this.currentStageHeight = stageHeight;

    if (stageHeight >= 600) {
      // Full screen (600px SWFs): menu hidden, help hidden
      playerContainer.style.height = '600px';
      helpContainer.style.display = 'none';
      menuContainer.style.display = 'none';
      helpPlayer.style.display = 'none';
    } else if (stageHeight > 320) {
      // Special mode (580px SWFs): menu visible, help overlays puzzle when shown
      playerContainer.style.height = '580px';
      helpContainer.style.display = 'none';
      menuContainer.style.display = 'block';
      helpPlayer.style.display = 'none';
      // Position help-player for overlay mode (over bottom of puzzle area)
      helpPlayer.style.top = '364px';
      helpPlayer.style.left = '100px';
    } else {
      // Regular puzzles (320px SWFs): menu visible, help area visible, arrows active
      playerContainer.style.height = '320px';
      helpContainer.style.display = 'flex';
      menuContainer.style.display = 'block';
      helpPlayer.style.display = 'none';
      // Position help-player within the help-container zone
      helpPlayer.style.top = '342px';
      helpPlayer.style.left = '124px';
    }
  }

  bindControls() {
    document.getElementById('btn-reset').addEventListener('click', () => {
      if (confirm('Reset all game progress?')) {
        this.state.reset();
        this.buildNav();
        this.launchPuzzle(C.TOKENS);
      }
    });

    // Menu bar click handling — the menu SWF is a passive display,
    // so we detect clicks in JS based on x-position.
    // Menu rects from Lingo misc_MakeRect calls in 01-Initialization.ls:
    // Items are within y=571-599 in Director coords, but our menu container
    // is the full menu SWF (800x20), so any click in it counts.
    const menuRects = [
      { x1: 57,  x2: 131, action: 'tokens' },   // 1: Tokens
      { x1: 163, x2: 228, action: 'menus' },     // 2: Menus
      { x1: 260, x2: 301, action: 'map' },       // 3: Map
      { x1: 338, x2: 387, action: 'save' },      // 4: Save
      { x1: 423, x2: 471, action: 'help' },      // 5: Help
      { x1: 508, x2: 580, action: 'reset' },     // 6: Reset
      { x1: 611, x2: 664, action: 'undo' },      // 7: Undo
      { x1: 696, x2: 739, action: 'quit' },      // 8: Quit
    ];

    document.getElementById('menu-container').addEventListener('click', (e) => {
      const rect = e.currentTarget.getBoundingClientRect();
      const x = (e.clientX - rect.left) / rect.width * 800;
      for (const item of menuRects) {
        if (x >= item.x1 && x <= item.x2) {
          this.handleMenuClick(item.action);
          return;
        }
      }
    });
  }

  handleMenuClick(action) {
    console.log('Menu click:', action);
    if (this.clickToContinue) {
      if (action === 'help' || action === 'reset' || action === 'undo') return;
      this.dismissClickToContinue();
    }
    switch (action) {
      case 'tokens':
        this.launchPuzzle(C.TOKENS);
        break;
      case 'menus':
        this.launchPuzzle(C.GAME_MENUS);
        break;
      case 'map':
        this.launchPuzzle(C.MOONS_MAP);
        break;
      case 'save':
        this.saveCurrent();
        break;
      case 'help': {
        if (this.currentStageHeight >= 600) break; // no help in full-screen mode
        const helpEl = document.getElementById('help-player');
        helpEl.style.display = helpEl.style.display === 'none' ? 'block' : 'none';
        break;
      }
      case 'reset':
        // Send reset command to active puzzle via gFlashCommand
        this.loader.setVar('gFlashCommand', '6');
        break;
      case 'undo':
        this.loader.setVar('gFlashCommand', '7');
        break;
      case 'quit':
        this.launchPuzzle(C.TOKENS);
        break;
    }
  }
}
