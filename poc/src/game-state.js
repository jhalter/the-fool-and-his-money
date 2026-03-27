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
      pMenu: this.pMenu[puzzleIndex],
      pMisc: '',
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
