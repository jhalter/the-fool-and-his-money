// Game state management, mirroring Director's global state arrays.
// Persistence via localStorage.

import { PUZZLES, C } from './puzzle-data.js';

const STORAGE_KEY = 'tfahm_game_state';

export class GameState {
  constructor() {
    this.currGame = 1;
    this.currPuzzle = C.TOKENS;
    this.lastPuzzle = C.TOKENS;
    this.pStat = new Array(C.PUZZLE_TOTAL + 1).fill(0);
    this.pData = new Array(C.PUZZLE_TOTAL + 1).fill('empty');
    this.pPage = new Array(C.PUZZLE_TOTAL + 1).fill(0);
    this.pSwords = new Array(C.PUZZLE_TOTAL + 1).fill(0);
    this.pWands = new Array(C.PUZZLE_TOTAL + 1).fill(0);
    this.pCups = new Array(C.PUZZLE_TOTAL + 1).fill(0);
    this.pPentacles = new Array(C.PUZZLE_TOTAL + 1).fill(0);
    this.pMenu = new Array(C.PUZZLE_TOTAL + 1).fill('12345--8');

    // Special menu defaults from 01-Initialization.ls
    this.pMenu[C.MOONS_MAP] = '12-45--8';
    this.pMenu[C.MOONS_PUZZLES] = '12-45--8';
    this.pMenu[C.GAME_MENUS] = '1-345--8';
    this.pMenu[C.HELP_TOKENS] = '1234---8';
  }

  // Build FlashVars object for a puzzle launch, matching sendFlashData() in 02-Misc.ls
  getFlashVars(puzzleIndex) {
    const puzzle = PUZZLES[puzzleIndex];
    if (!puzzle) return {};

    // Tokens screen needs special pData (token strings, not puzzle state)
    const pData = puzzleIndex === C.TOKENS
      ? this.getTokenStrings()
      : this.pData[puzzleIndex];

    return {
      // Core puzzle identity
      pNum: String(puzzleIndex === C.TOKENS ? this.currGame : puzzle.pNum),
      pGameNum: String(puzzleIndex),
      pStat: String(this.pStat[puzzleIndex]),
      pData: pData,
      pVolume: String(puzzle.volume),
      // Suit progress for this puzzle
      pSwords: String(this.pSwords[puzzleIndex]),
      pWands: String(this.pWands[puzzleIndex]),
      pCups: String(this.pCups[puzzleIndex]),
      pPentacles: String(this.pPentacles[puzzleIndex]),
      // Totals across all puzzles
      pTotalSwords: '0',
      pTotalWands: '0',
      pTotalCups: '0',
      pTotalPentacles: '0',
      // Menu and miscellaneous
      pMenu: this.getChunkMenuStat(),
      pMisc: this.getMisc(puzzleIndex),
      pInfo: '',
      pSeven: '-',
      // Control flags
      pClickToContinue: '0',
      pTraceMenu: '0',
      pStatusTest: '0',
      pIdleX: '400',
      pIdleY: '300',
      // Set DirectorInControl=1 to prevent built-in _CHEAT() from activating.
      // Mouse listeners are added separately via enableStandaloneMode bridge callback.
      DirectorInControl: '1',
    };
  }

  // Generate pipe-delimited token strings for the Tokens hub screen.
  // Format: token1|token2|token3| repeated for 15 slots
  // (12 game slots + new game template + revert + open game)
  // Mirrors getTokenStrings() from 03-Launch.ls
  getTokenStrings() {
    const parts = [];
    for (let x = 1; x <= 15; x++) {
      if (x <= 12) {
        // Game slots — show progress summary
        parts.push('77 Bewitchments remain');
        parts.push("and the Moon's Map is a mystery.");
        parts.push('1'); // 1 = new/fresh game
      } else {
        // Slots 13-15: new game template, revert, open
        parts.push('77 Bewitchments remain');
        parts.push("and the Moon's Map is a mystery.");
        parts.push('1');
      }
    }
    return parts.join('|') + '|';
  }

  // Build 128-char status string matching putMenuStatsFromFlash() in 06-Update-Stats.ls.
  // Each character is a digit 0-9 representing the completion level of that puzzle.
  getChunkMenuStat() {
    const menuStat = new Array(C.PUZZLE_TOTAL + 1).fill(0);

    for (let x = 1; x <= C.PUZZLE_TOTAL; x++) {
      if (x >= C.MANSION1 && x <= C.MANSION2) continue; // handled below
      const s = this.pStat[x];
      if (s === 0)       { menuStat[x] = 0; continue; }
      if (s === 1)       { menuStat[x] = 1; continue; }
      if (s < 100)       { menuStat[x] = 2; continue; }
      if (s < 200)       { menuStat[x] = 3; continue; }
      if (s < 300)       { menuStat[x] = 4; continue; }
      if (s < 400)       { menuStat[x] = 5; continue; }
      if (s < 500)       { menuStat[x] = 6; continue; }
      if (s < 600)       { menuStat[x] = 7; continue; }
      if (s < 700)       { menuStat[x] = 8; continue; }
      menuStat[x] = 9;
    }

    // Mansion puzzles: thresholds shift based on game-menus progress
    const gmStat = this.pStat[C.GAME_MENUS];
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      let s = this.pStat[x];
      if (gmStat <= 20) {
        // Tier 0: passwords
        if (s === 0)      menuStat[x] = 0;
        else if (s === 1) menuStat[x] = 1;
        else if (s < 100) menuStat[x] = 2;
        else              menuStat[x] = 3;
      } else if (gmStat <= 60) {
        // Tier 1: deliveries
        if (s < 100) { this.pStat[x] = 100; s = 100; }
        if (s === 100)     menuStat[x] = 0;
        else if (s <= 110) menuStat[x] = 1;
        else if (s < 200)  menuStat[x] = 2;
        else               menuStat[x] = 3;
      } else if (gmStat <= 90) {
        // Tier 2: hexes
        if (s < 200) { this.pStat[x] = 200; s = 200; }
        if (s === 200)     menuStat[x] = 0;
        else if (s <= 201) menuStat[x] = 1;
        else if (s < 300)  menuStat[x] = 2;
        else               menuStat[x] = 3;
      } else {
        // Tier 3: remainders/connections
        if (s < 300) { this.pStat[x] = 300; s = 300; }
        if (s === 300)     menuStat[x] = 0;
        else if (s <= 310) menuStat[x] = 1;
        else if (s < 400)  menuStat[x] = 2;
        else               menuStat[x] = 3;
      }
    }

    let result = '';
    for (let x = 1; x <= C.PUZZLE_TOTAL; x++) {
      result += String(menuStat[x]);
    }
    return result;
  }

  // Build pipe-delimited string of the first 72 puzzle menuNames,
  // matching chunkMenuName from 07-Data.ls.
  getChunkMenuName() {
    let s = '';
    for (let x = 1; x <= 72; x++) {
      s += PUZZLES[x].menuName + '|';
    }
    return s;
  }

  // Generate the 14-character mansion window code matching makeWindowCode()
  // in 06-Update-Stats.ls. Cached per session; persisted to localStorage.
  getWindowCode() {
    if (this.windowCode) return this.windowCode;
    const R = [0, 1, 2, 3, 4, 5, 6, 7]; // 1-based: indices 1-7
    for (let x = 1; x <= 7; x++) {
      const n = Math.floor(Math.random() * 7) + 1;
      [R[x], R[n]] = [R[n], R[x]];
    }
    let code = '';
    for (let x = 1; x <= 7; x++) code += String(R[x]);
    for (let x = 0; x < 7; x++) code += String(Math.floor(Math.random() * 4) + 1);
    this.windowCode = code;
    return code;
  }

  // Build pMisc value for a puzzle, matching the case statement in launchPuzzle()
  // in 03-Launch.ls.
  getMisc(puzzleIndex) {
    if (puzzleIndex === C.GAME_MENUS) {
      return this.getChunkMenuName() + this.getWindowCode() + '|';
    }
    if (puzzleIndex >= 101 && puzzleIndex <= 107) {
      // DEL (Delivery) puzzles receive the window code
      return this.getWindowCode();
    }
    return '';
  }

  markSolved(puzzleIndex) {
    this.pStat[puzzleIndex] = 100;
    this.save();
  }

  markUnsolved(puzzleIndex) {
    this.pStat[puzzleIndex] = 0;
    this.pData[puzzleIndex] = 'empty';
    this.save();
  }

  save() {
    const data = {
      currGame: this.currGame,
      currPuzzle: this.currPuzzle,
      lastPuzzle: this.lastPuzzle,
      pStat: this.pStat,
      pData: this.pData,
      pPage: this.pPage,
      pSwords: this.pSwords,
      pWands: this.pWands,
      pCups: this.pCups,
      pPentacles: this.pPentacles,
      windowCode: this.windowCode || null,
    };
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    } catch (e) {
      console.warn('Failed to save game state:', e);
    }
  }

  load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return false;
      const data = JSON.parse(raw);
      this.currGame = data.currGame ?? 1;
      this.currPuzzle = data.currPuzzle ?? C.TOKENS;
      this.lastPuzzle = data.lastPuzzle ?? C.TOKENS;
      if (data.pStat) this.pStat = data.pStat;
      if (data.pData) this.pData = data.pData;
      if (data.pPage) this.pPage = data.pPage;
      if (data.pSwords) this.pSwords = data.pSwords;
      if (data.pWands) this.pWands = data.pWands;
      if (data.pCups) this.pCups = data.pCups;
      if (data.pPentacles) this.pPentacles = data.pPentacles;
      if (data.windowCode) this.windowCode = data.windowCode;
      return true;
    } catch (e) {
      console.warn('Failed to load game state:', e);
      return false;
    }
  }

  reset() {
    localStorage.removeItem(STORAGE_KEY);
    Object.assign(this, new GameState());
  }
}
