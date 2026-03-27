// Main orchestrator tying together game state, SWF loading, and navigation.
// Polls SWFs via ExternalInterface for completion detection and navigation requests.

import { PUZZLES, SECTION_RANGES, C } from './puzzle-data.js';
import { GameState } from './game-state.js';
import { SwfLoader } from './swf-loader.js';

export class Orchestrator {
  constructor() {
    this.state = new GameState();
    this.loader = null;
    this.navEl = null;
    this.pollTimer = null;
    this.lastGStat = null;
  }

  init() {
    this.loader = new SwfLoader(
      document.getElementById('player-container'),
      document.getElementById('status')
    );
    this.navEl = document.getElementById('nav-list');

    this.state.load();
    this.buildNav();
    this.bindControls();

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

  handleRequest(reqString) {
    const parts = reqString.split('|').filter(s => s !== '');
    if (parts.length === 0) return;

    const code = parseInt(parts[0], 10);
    console.log(`gFlashRequest: code=${code} parts=${JSON.stringify(parts)}`);

    // Tokens screen sends requests as "100|subcode|params..."
    if (code === 100) {
      this.handleTokensRequest(parts);
      return;
    }

    switch (code) {
      case 1:  // launch puzzle from map (with transition)
      case 2:  // launch puzzle from map (no transition)
      case 8:  // launch specific puzzle
      case 9:  // launch specific puzzle
      case 10:
        if (parts[1]) this.launchPuzzle(parseInt(parts[1], 10));
        break;
      case 17: // save current puzzle
        this.saveCurrent();
        break;
      case 88: // go to game menus
        this.launchPuzzle(C.GAME_MENUS);
        break;
      case 98: // go to Moon's Map
        this.launchPuzzle(C.MOONS_MAP);
        break;
      default:
        console.log(`Unhandled request code: ${code}`);
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
        this.launchPuzzle(2);
      }
    });
  }
}
