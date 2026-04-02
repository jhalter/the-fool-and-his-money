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

    this.pDone = new Array(C.PUZZLE_TOTAL + 1).fill('-');
    // csWagerTarot tracks which wager puzzle is paired with each tarot slot.
    // Initialized to csWager values; swapped to tarot index on tarot launch.
    this.csWagerTarot = [0, 5, 18, 35, 55, 71]; // 1-indexed

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
    if (puzzleIndex === C.MOONS_MAP) {
      return this._tallyMapPieces();
    }
    if (puzzleIndex >= 101 && puzzleIndex <= 107) {
      // DEL (Delivery) puzzles receive the window code
      return this.getWindowCode();
    }
    return '';
  }

  // Redirect certain puzzle launches based on game state, matching
  // exceptionPuzzleLaunch() in 06-Update-Stats.ls.
  // b=true is "save mode" (prevents launching Prologue/Finale directly).
  exceptionPuzzleLaunch(n, b) {
    if (n === C.FINALE && this.lastPuzzle === C.FINALE) {
      n = C.PRE_FINALE;
    }
    if (n === C.TOKENS) {
      n = (this.lastPuzzle !== C.TOKENS) ? this.lastPuzzle : C.GAME_MENUS;
    }
    if (n < 1 || n > C.PUZZLE_TOTAL) {
      n = C.GAME_MENUS;
    }
    if (b) {
      if (n === C.PROLOGUE) n = C.GAME_MENUS;
      if (n === C.FINALE) n = C.PRE_FINALE;
    }
    if (n === C.PRE_HP && this.pStat[C.PRE_HP] === 100) {
      n = C.HIGH_PRIESTESS;
    }
    if (n === C.HIGH_PRIESTESS && this.pStat[C.HIGH_PRIESTESS] === 100) {
      n = C.MOON_MORPH;
    }
    return n;
  }

  // Core progression engine — translates updateGameStats() from 06-Update-Stats.ls.
  // Called before every puzzle launch and after saving puzzle state.
  updateGameStats(gameNum) {
    // Mark current puzzle as visited
    if (this.currPuzzle < C.GAME_MENUS && this.pStat[this.currPuzzle] < 2) {
      this.pStat[this.currPuzzle] = 2;
    }

    // Count available and solved puzzles (Swords through Pentacles)
    let puzzAvail = 0;
    let puzzlesSolved = 0;
    for (let x = C.SWORDS1; x <= C.PENTACLES2; x++) {
      if (this.pStat[x] > 0) puzzAvail++;
      if (this.pStat[x] >= 100) puzzlesSolved++;
    }

    // Unlock puzzles: for each solved beyond 3, open one locked puzzle
    let puzzReady = puzzlesSolved - 3;
    if (puzzReady > 0) {
      for (let x = C.WANDS1; x <= C.PENTACLES2; x++) {
        if (puzzReady <= 0) break;
        if (this.pStat[x] === 0) {
          this.pStat[x] = 1;
        }
        puzzReady--;
      }
    }

    // Seven Cups gate
    if (this.pStat[C.GAME_MENUS] >= 95) {
      if (this.pStat[C.SEVEN_CUPS] < 100) {
        this.pStat[C.GAME_MENUS] = 95;
      } else {
        this.pStat[C.GAME_MENUS] = 100;
      }
    }

    // Game menu phase progression
    const gmStat = this.pStat[C.GAME_MENUS];
    if (gmStat === 0) {
      // Phase 0: open all Swords, advance to 10
      for (let x = C.SWORDS1; x <= C.SWORDS2; x++) {
        if (this.pStat[x] < 1) this.pStat[x] = 1;
      }
      this._setGameMenuStatus(10);
    }
    if (gmStat === 10) {
      this._updateMansionWindows(1, 0, 1, puzzlesSolved);
      this._updateForMansionPhase(100, 20);
    }
    // Phase 20: no special action (fall through)
    if (gmStat === 30) {
      this._updateMansionWindows(2, 100, 101, puzzlesSolved);
      this._updateForMansionPhase(200, 60);
      // Sync delivery progress across mansion puzzles
      let highest = 0;
      for (let x = C.MANSION1; x <= C.MANSION2; x++) {
        if (this.pStat[x] > highest) highest = this.pStat[x];
      }
      if (highest >= 150) {
        for (let x = C.MANSION1; x <= C.MANSION2; x++) {
          if (this.pStat[x] > 100 && this.pStat[x] < 150) this.pStat[x] = 150;
        }
      } else if (highest === 108) {
        for (let x = C.MANSION1; x <= C.MANSION2; x++) {
          if (this.pStat[x] > 100 && this.pStat[x] < 108) this.pStat[x] = 108;
        }
      }
    }
    // Phase 60: no special action
    if (gmStat === 70 || gmStat === 75) {
      if (this.pStat[C.GAME_MENUS] === 70 && this.pStat[C.HIGH_PRIESTESS] >= 100) {
        this.pStat[C.GAME_MENUS] = 75;
      }
      this._updateMansionWindows(3, 200, 201, puzzlesSolved);
      this._updateForMansionBeam();
    }
    // Phase 80, 90: no special action
    if (gmStat === 95) {
      this._updateMansionWindows(4, 300, 301, puzzlesSolved);
    }
    // Phase 100: no special action

    // Special gates
    if (this.pStat[C.PROLOGUE] === 0) {
      this.pStat[C.PROLOGUE] = 1;
    }
    // PatchPirate[1] (puzzle 2) >= 400 → PatchPirate[4] (puzzle 56) = 700
    if (this.pStat[C.PATCH_PIRATE[1]] >= 400) {
      this.pStat[C.PATCH_PIRATE[4]] = 700;
    }
    this._updateSolvedTarot();

    // Moon's Map gate
    if (this.pStat[C.MOONS_MAP] < 100) {
      const remaining = this._calcMapPiecesRemaining(3);
      if (remaining > 0) {
        this.pStat[C.MOONS_MAP] = 2;
        this.pStat[C.MOONS_PUZZLES] = 0;
      }
    }

    // Seven Cups availability
    if (this.pStat[C.GAME_MENUS] < 95) {
      this.pStat[C.SEVEN_CUPS] = 0;
    }
    if (this.pStat[C.GAME_MENUS] === 95 && this.pStat[C.SEVEN_CUPS] > 20) {
      this.pStat[C.SEVEN_CUPS] = 10;
    }

    // Pre-Finale / Finale gate
    if (this.pStat[C.MOONS_PUZZLES] < 700 || this.pStat[C.SEVEN_CUPS] < 700) {
      if (this.pStat[C.PRE_FINALE] === 0) this.pStat[C.PRE_FINALE] = 2;
      if (this.pStat[C.PRE_FINALE] > 10) this.pStat[C.PRE_FINALE] = 10;
      this.pData[C.PRE_FINALE] = 'empty';
      this.pStat[C.FINALE] = 0;
    } else {
      if (this.pStat[C.PRE_FINALE] < 100) this.pStat[C.PRE_FINALE] = 100;
    }

    this._updatePages();
  }

  // Only advance game menu status, never go backward.
  // Matches _Set_Game_Menu_Status() in 06-Update-Stats.ls:273-277.
  _setGameMenuStatus(n) {
    if (this.pStat[C.GAME_MENUS] < n) {
      this.pStat[C.GAME_MENUS] = n;
    }
  }

  // When a tarot puzzle's pData reaches 100, auto-complete its paired wager.
  // Matches _Update_Solved_Tarot() in 06-Update-Stats.ls:279-287.
  _updateSolvedTarot() {
    for (let x = 1; x <= 5; x++) {
      if (parseInt(this.pData[C.TAROT[x]]) === 100) {
        if (parseInt(this.pData[C.WAGER[x]]) < 100) {
          this.pData[C.WAGER[x]] = '100';
        }
      }
    }
  }

  // Open/close mansion puzzles based on total solved count.
  // Matches updateMansionWindows() in 06-Update-Stats.ls:210-236.
  _updateMansionWindows(which, closeW, openW, puzzlesSolved) {
    let base;
    switch (which) {
      case 1: base = 17; break;
      case 2: base = 17 + 19; break;
      case 3: base = 17 + 19 + 18; break;
      case 4: base = 17 + 19 + 18 + 16; break;
    }
    const windowStat = [];
    for (let x = 7; x >= 1; x--) {
      windowStat[x] = base;
      base -= 2;
    }
    for (let x = 1; x <= 7; x++) {
      const n = C.MANSION1 + (x - 1);
      if (puzzlesSolved < windowStat[x]) {
        this.pStat[n] = closeW;
        continue;
      }
      if (this.pStat[n] < openW) {
        this.pStat[n] = openW;
      }
    }
  }

  // Check if all 7 mansion puzzles reached a goal → advance game menu status.
  // Matches updateForMansionPhase() in 06-Update-Stats.ls:238-248.
  _updateForMansionPhase(goal, stat) {
    let ct = 0;
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      if (this.pStat[x] === goal) ct++;
    }
    if (ct === 7) this._setGameMenuStatus(stat);
  }

  // HP-gated mansion beam progression.
  // Matches updateForMansionBeam() in 06-Update-Stats.ls:250-264.
  _updateForMansionBeam() {
    if (this.pStat[C.HIGH_PRIESTESS] >= 100) {
      let ct = 0;
      for (let x = C.MANSION1; x <= C.MANSION2; x++) {
        if (this.pStat[x] === 300) ct++;
      }
      if (ct < 7) {
        this._setGameMenuStatus(75);
      } else {
        this._setGameMenuStatus(80);
      }
    }
  }

  // Count unsolved puzzles for moon's map.
  // Matches calcMapPiecesRemaining() in 06-Update-Stats.ls:505-519.
  _calcMapPiecesRemaining(byMenuStat) {
    const menuStatStr = this.getChunkMenuStat();
    let t = 0;
    for (let x = C.SWORDS1; x <= C.PENTACLES2; x++) {
      if (parseInt(menuStatStr[x - 1]) < byMenuStat) t++;
    }
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      if (this.pStat[x] < 400) t++;
    }
    return t;
  }

  // Build binary string of solved puzzles for Moon's Map star display.
  // Matches tallyMapPieces() in 06-Update-Stats.ls:521-541.
  _tallyMapPieces() {
    let s = '';
    for (let x = C.SWORDS1; x <= C.PENTACLES2; x++) {
      s += this.pStat[x] >= 100 ? '1' : '0';
    }
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      s += this.pStat[x] >= 400 ? '1' : '0';
    }
    return s;
  }

  // Set pPage values for mansion-tier puzzles.
  // Matches updatePages() in 06-Update-Stats.ls:619-660.
  _updatePages() {
    for (let x = C.DEL1; x <= C.DEL7; x++) this.pPage[x] = 2;
    for (let x = C.HEX1; x <= C.HEX7; x++) this.pPage[x] = 4;
    for (let x = C.REM1; x <= C.REM7; x++) this.pPage[x] = 6;
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      const s = this.pStat[x];
      if (s < 100)      { this.pPage[x] = 1; continue; }
      if (s === 100)     { this.pPage[x] = 2; continue; }
      if (s < 200)       { this.pPage[x] = 3; continue; }
      if (s === 200)     { this.pPage[x] = 4; continue; }
      if (s < 300)       { this.pPage[x] = 5; continue; }
      if (s === 300)     { this.pPage[x] = 6; continue; }
      if (s < 400)       { this.pPage[x] = 7; continue; }
      this.pPage[x] = 8;
    }
  }

  // Return mansion frame ID based on game menu progression phase.
  // Matches launchMansionPuzzle() in 06-Update-Stats.ls:322-341.
  getMansionFrameId() {
    const gmStat = this.pStat[C.GAME_MENUS];
    if (gmStat <= 20) return 'passwords';
    if (gmStat <= 60) return 'hex-words';
    if (gmStat <= 90) return 'unnecessary';
    return 'connects';
  }

  // Sync completion data from Game Menus SWF back into pStat.
  // Matches getMenuStatsFromFlash() in 06-Update-Stats.ls:466-503.
  getMenuStatsFromFlash(menuUpdateStr) {
    if (!menuUpdateStr || menuUpdateStr.length < 100) return;
    let s = menuUpdateStr;
    // Pad to 128 chars if only 100 (older format)
    if (s.length === 100) {
      for (let x = 101; x <= C.PUZZLE_TOTAL; x++) s += '3';
    }
    const chunkMenuStat = this.getChunkMenuStat();
    if (s === chunkMenuStat || s.substring(0, 3) === 'NaN' || chunkMenuStat === '') return;
    for (let x = 1; x <= C.PUZZLE_TOTAL; x++) {
      const m1 = parseInt(chunkMenuStat[x - 1]);
      const m2 = parseInt(s[x - 1]);
      if (m2 > m1) {
        switch (m2) {
          case 3: this.pStat[x] = 100; break;
          case 4: this.pStat[x] = 200; break;
          case 5: this.pStat[x] = 300; break;
          case 6: this.pStat[x] = 400; break;
          case 7: this.pStat[x] = 500; break;
          case 8: this.pStat[x] = 600; break;
          case 9: this.pStat[x] = 700; break;
        }
      }
    }
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
      pDone: this.pDone,
      csWagerTarot: this.csWagerTarot,
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
      if (data.pDone) this.pDone = data.pDone;
      if (data.csWagerTarot) this.csWagerTarot = data.csWagerTarot;
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
