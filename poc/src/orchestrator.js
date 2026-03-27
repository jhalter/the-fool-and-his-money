// Main orchestrator tying together game state, SWF loading, and navigation.
// Polls SWFs via ExternalInterface for completion detection and navigation requests.

import { PUZZLES, SECTION_RANGES, C } from './puzzle-data.js';
import { GameState } from './game-state.js';
import { SwfLoader, OverlayLoader } from './swf-loader.js';

export class Orchestrator {
  constructor() {
    this.state = new GameState();
    this.loader = null;
    this.menuLoader = null;
    this.navEl = null;
    this.pollTimer = null;
    this.lastGStat = null;
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
      this.helpLoader.load('chunk_05_CDGF_0x00a7c7a8_swf_011_v8.swf'),
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
    const puzzle = PUZZLES[puzzleIndex];
    if (!puzzle) return;

    this.stopPolling();

    this.state.lastPuzzle = this.state.currPuzzle;
    this.state.currPuzzle = puzzleIndex;
    this.state.save();

    document.title = `The Fool and his Money - ${puzzle.titleName}`;

    const ok = await this.loader.loadPuzzle(puzzleIndex, this.state);
    if (ok) {
      this.refreshNav();
      this.lastGStat = null;

      // Tokens screen needs gFlashCommand=666 to signal Director is ready
      if (puzzleIndex === C.TOKENS) {
        setTimeout(() => {
          this.loader.setVar('gFlashCommand', '666');
        }, 300);
      }

      // Switch layout based on puzzle type
      const playerContainer = document.getElementById('player-container');
      const helpContainer = document.getElementById('help-container');
      const menuContainer = document.getElementById('menu-container');
      const isFullHeight = puzzleIndex === C.TOKENS || puzzleIndex === C.GAME_MENUS
        || puzzleIndex === C.PROLOGUE;
      if (isFullHeight) {
        playerContainer.style.height = '600px';
        helpContainer.style.display = 'none';
        menuContainer.style.display = 'none';
      } else {
        playerContainer.style.height = '320px';
        helpContainer.style.display = 'flex';
        menuContainer.style.display = 'block';
      }

      this.startPolling();
    }
  }

  startPolling() {
    this.pollTimer = setInterval(() => this.poll(), 500);
  }

  stopPolling() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer);
      this.pollTimer = null;
    }
  }

  poll() {
    const puzzleIndex = this.state.currPuzzle;

    // Poll gStat for completion detection
    const gStatRaw = this.loader.getVar('gStat');
    if (gStatRaw !== undefined && gStatRaw !== null) {
      const gStat = parseInt(gStatRaw, 10);
      if (!isNaN(gStat) && gStat !== this.lastGStat) {
        this.lastGStat = gStat;
        if (gStat >= 100 && this.state.pStat[puzzleIndex] < 100) {
          this.onPuzzleSolved(puzzleIndex, gStat);
        }
      }
    }

    // Poll gFlashRequest for navigation
    const req = this.loader.getVar('gFlashRequest');
    if (req && req !== '' && req !== 'undefined' && req !== 'null') {
      this.loader.setVar('gFlashRequest', '');
      this.handleRequest(req);
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
        case 88: // go to game menus
          this.launchPuzzle(C.GAME_MENUS);
          break;
        case 98: // go to Moon's Map
          this.launchPuzzle(C.MOONS_MAP);
          break;
        case 19: // update menu key — 1 param (menu string like "12345--8")
          i++; // consume the menu key param
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
