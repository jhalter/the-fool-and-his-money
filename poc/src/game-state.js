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
    return {
      pNum: String(puzzle.pNum),
      pGameNum: String(puzzleIndex),
      pStat: String(this.pStat[puzzleIndex]),
      pData: this.pData[puzzleIndex],
      pVolume: String(puzzle.volume),
      pSwords: String(this.pSwords[puzzleIndex]),
      pWands: String(this.pWands[puzzleIndex]),
      pCups: String(this.pCups[puzzleIndex]),
      pPentacles: String(this.pPentacles[puzzleIndex]),
      pMenu: this.pMenu[puzzleIndex],
      // Do NOT set DirectorInControl — standalone mode
    };
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
