// Game state management, mirroring Director's global state arrays.
// Persistence via localStorage.

import { PUZZLES, PUZZLE_TYPES, C } from './puzzle-data.js';

const STORAGE_KEY = 'tfahm_game_state';

export class GameState {
  constructor() {
    this.currGame = 1;
    this.currPuzzle = C.TOKENS;
    this.lastPuzzle = C.TOKENS;
    this.pStat = new Array(C.PUZZLE_TOTAL + 1).fill(0);
    this.pData = new Array(C.PUZZLE_TOTAL + 1).fill('empty');
    this.pPage = new Array(C.PUZZLE_TOTAL + 1).fill(0);
    this.pDone = new Array(C.PUZZLE_TOTAL + 1).fill('-');
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

    // Wager ↔ Tarot pairing: csWagerTarot[x] starts equal to csWager[x]
    // Index 1-5 maps to the 5 wager puzzle indices
    this.csWagerTarot = [null, ...PUZZLE_TYPES.wager];

    // Word state tracking for jumble/morphtext puzzles (1-indexed, 4 entries)
    this.pWordStat63 = [null, '', '', '', ''];

    // Token descriptions for 15 slots (12 games + new + revert + open)
    this.token1 = new Array(16).fill('77 Bewitchments remain');
    this.token2 = new Array(16).fill("and the Moon's Map is a mystery.");
    this.token3 = new Array(16).fill(1); // 1 = new/fresh game
    this.token1[0] = ''; this.token2[0] = ''; this.token3[0] = 0;

    // Internal working state (not persisted)
    this.menuStat = new Array(C.PUZZLE_TOTAL + 1).fill(0);
    this.thePuzzlesSolved = 0;
    this.pInfo = '';
    this.pSeven = '-';
    this.windowCode = null;
  }

  // -----------------------------------------------------------------------
  // FlashVars — sent to SWF at load time
  // -----------------------------------------------------------------------

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
      // Totals across all puzzles (Director sends 0 in sendFlashData)
      pTotalSwords: '0',
      pTotalWands: '0',
      pTotalCups: '0',
      pTotalPentacles: '0',
      // Menu and miscellaneous
      pMenu: this.getChunkMenuStat(),
      pMisc: this.getMisc(puzzleIndex),
      pInfo: this.pInfo,
      pSeven: this.pSeven,
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
  getTokenStrings() {
    const parts = [];
    for (let x = 1; x <= 15; x++) {
      parts.push(this.token1[x] || '77 Bewitchments remain');
      parts.push(this.token2[x] || "and the Moon's Map is a mystery.");
      parts.push(String(this.token3[x] ?? 1));
    }
    return parts.join('|') + '|';
  }

  // Build 128-char status string matching putMenuStatsFromFlash() in 06-Update-Stats.ls.
  // Each character is a digit 0-9 representing the completion level of that puzzle.
  // Side effect: populates this.menuStat[] array for use by other methods.
  getChunkMenuStat() {
    for (let x = 1; x <= C.PUZZLE_TOTAL; x++) {
      if (x >= C.MANSION1 && x <= C.MANSION2) continue; // handled below
      const s = this.pStat[x];
      if (s === 0)       { this.menuStat[x] = 0; continue; }
      if (s === 1)       { this.menuStat[x] = 1; continue; }
      if (s < 100)       { this.menuStat[x] = 2; continue; }
      if (s < 200)       { this.menuStat[x] = 3; continue; }
      if (s < 300)       { this.menuStat[x] = 4; continue; }
      if (s < 400)       { this.menuStat[x] = 5; continue; }
      if (s < 500)       { this.menuStat[x] = 6; continue; }
      if (s < 600)       { this.menuStat[x] = 7; continue; }
      if (s < 700)       { this.menuStat[x] = 8; continue; }
      this.menuStat[x] = 9;
    }

    // Mansion puzzles: thresholds shift based on game-menus progress
    const gmStat = this.pStat[C.GAME_MENUS];
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      let s = this.pStat[x];
      if (gmStat <= 20) {
        if (s === 0)      this.menuStat[x] = 0;
        else if (s === 1) this.menuStat[x] = 1;
        else if (s < 100) this.menuStat[x] = 2;
        else              this.menuStat[x] = 3;
      } else if (gmStat <= 60) {
        if (s < 100) { this.pStat[x] = 100; s = 100; }
        if (s === 100)     this.menuStat[x] = 0;
        else if (s <= 110) this.menuStat[x] = 1;
        else if (s < 200)  this.menuStat[x] = 2;
        else               this.menuStat[x] = 3;
      } else if (gmStat <= 90) {
        if (s < 200) { this.pStat[x] = 200; s = 200; }
        if (s === 200)     this.menuStat[x] = 0;
        else if (s <= 201) this.menuStat[x] = 1;
        else if (s < 300)  this.menuStat[x] = 2;
        else               this.menuStat[x] = 3;
      } else {
        if (s < 300) { this.pStat[x] = 300; s = 300; }
        if (s === 300)     this.menuStat[x] = 0;
        else if (s <= 310) this.menuStat[x] = 1;
        else if (s < 400)  this.menuStat[x] = 2;
        else               this.menuStat[x] = 3;
      }
    }

    let result = '';
    for (let x = 1; x <= C.PUZZLE_TOTAL; x++) {
      result += String(this.menuStat[x]);
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
    if (puzzleIndex >= C.MANSION1 && puzzleIndex <= C.MANSION2) {
      const gmStat = this.pStat[C.GAME_MENUS];
      if (gmStat <= 20) return this.getWindowCode();
      if (gmStat >= 70 && gmStat <= 90) return String(gmStat);
      return '';
    }
    if (puzzleIndex >= 101 && puzzleIndex <= 107) {
      // DEL (Delivery) puzzles receive the window code
      return this.getWindowCode();
    }
    if (puzzleIndex === C.MOONS_MAP && this.pStat[C.MOONS_MAP] < 100) {
      return this.tallyMapPieces();
    }
    return '';
  }

  // -----------------------------------------------------------------------
  // Game Stats Engine — translated from 06-Update-Stats.ls
  // -----------------------------------------------------------------------

  // Core progression function. Called on every puzzle launch and save.
  // Translates updateGameStats() from MovieScript 4 lines 3-184.
  updateGameStats(gameNumber) {
    // Mark current puzzle as "in progress" if it's a playable puzzle
    if (this.currPuzzle < C.GAME_MENUS) {
      if (this.pStat[this.currPuzzle] < 2) {
        this.pStat[this.currPuzzle] = 2;
      }
    }

    // Generate window code if needed
    if (!this.windowCode) {
      if (this.calcMapPiecesRemaining(3) > 4) {
        this.getWindowCode();
      }
    }

    // Count solved puzzles across main suits (Swords through Pentacles)
    let puzzAvail = 0;
    this.thePuzzlesSolved = 0;
    for (let x = C.SWORDS1; x <= C.PENTACLES2; x++) {
      if (this.pStat[x] > 0) puzzAvail++;
      if (this.pStat[x] >= 100) this.thePuzzlesSolved++;
    }

    // Progressive unlock: every 3 puzzles solved → 1 new puzzle unlocks
    let puzzReady = this.thePuzzlesSolved - 3;
    if (puzzReady > 0) {
      for (let x = C.WANDS1; x <= C.PENTACLES2; x++) {
        if (puzzReady <= 0) break;
        if (this.pStat[x] === 0) {
          this.pStat[x] = 1;
        }
        puzzReady--;
      }
    }

    // Seven Cups / GameMenus interlock (before the case statement)
    if (this.pStat[C.GAME_MENUS] >= 95) {
      if (this.pStat[C.SEVEN_CUPS] < 100) {
        this.pStat[C.GAME_MENUS] = 95;
      } else {
        this.pStat[C.GAME_MENUS] = 100;
      }
    }

    // Game Menus phase progression
    const gmStat = this.pStat[C.GAME_MENUS];
    if (gmStat === 0) {
      // Phase 0: unlock all Swords, advance to 10
      for (let x = C.SWORDS1; x <= C.SWORDS2; x++) {
        if (this.pStat[x] < 1) this.pStat[x] = 1;
      }
      this._setGameMenuStatus(10);
    } else if (gmStat === 10) {
      // Phase 10: mansion tier 1
      this.updateMansionWindows(1, 0, 1);
      this.updateForMansionPhase(100, 20);
    } else if (gmStat === 20 || gmStat === 30) {
      // Phase 20/30: mansion tier 2 + consolidation
      this.updateMansionWindows(2, 100, 101);
      this.updateForMansionPhase(200, 60);
      // Mansion stat consolidation
      let highest = 0;
      for (let x = C.MANSION1; x <= C.MANSION2; x++) {
        if (this.pStat[x] > highest) highest = this.pStat[x];
      }
      if (highest >= 150) {
        for (let x = C.MANSION1; x <= C.MANSION2; x++) {
          if (this.pStat[x] > 100 && this.pStat[x] < 150) {
            this.pStat[x] = 150;
          }
        }
      } else if (highest === 108) {
        for (let x = C.MANSION1; x <= C.MANSION2; x++) {
          if (this.pStat[x] > 100 && this.pStat[x] < 108) {
            this.pStat[x] = 108;
          }
        }
      }
    } else if (gmStat === 60 || gmStat === 70 || gmStat === 75) {
      // Phase 60/70/75: HP gating + mansion tier 3
      if (this.pStat[C.GAME_MENUS] === 70) {
        if (this.pStat[C.HIGH_PRIESTESS] >= 100) {
          this.pStat[C.GAME_MENUS] = 75;
        }
      }
      this.updateMansionWindows(3, 200, 201);
      this.updateForMansionBeam();
    } else if (gmStat === 80 || gmStat === 90 || gmStat === 95) {
      // Phase 80/90/95: mansion tier 4
      this.updateMansionWindows(4, 300, 301);
    }
    // Phase 100: nothing

    // Ensure prologue is always available
    if (this.pStat[C.PROLOGUE] === 0) {
      this.pStat[C.PROLOGUE] = 1;
    }

    // Special rule: patchwork pirate[1] >= 400 → pirate[4] = 700
    if (this.pStat[PUZZLE_TYPES.patchPirate[0]] >= 400) {
      this.pStat[PUZZLE_TYPES.patchPirate[3]] = 700;
    }

    // Propagate tarot completion to paired wager
    this._updateSolvedTarot();

    // Moon's Map gating
    if (this.pStat[C.MOONS_MAP] < 100) {
      const pr = this.calcMapPiecesRemaining(3);
      if (pr > 0) {
        this.pStat[C.MOONS_MAP] = 2;
        this.pStat[C.MOONS_PUZZLES] = 0;
      }
    }

    // Seven Cups gating
    if (this.pStat[C.GAME_MENUS] < 95) {
      this.pStat[C.SEVEN_CUPS] = 0;
    }
    if (this.pStat[C.GAME_MENUS] === 95) {
      if (this.pStat[C.SEVEN_CUPS] > 20) {
        this.pStat[C.SEVEN_CUPS] = 10;
      }
    }

    // Pre-Finale gating: requires both MoonsPuzzles=700 AND SevenCups=700
    if (this.pStat[C.MOONS_PUZZLES] < 700 || this.pStat[C.SEVEN_CUPS] < 700) {
      if (this.pStat[C.PRE_FINALE] === 0) {
        this.pStat[C.PRE_FINALE] = 2;
      }
      if (this.pStat[C.PRE_FINALE] > 10) {
        this.pStat[C.PRE_FINALE] = 10;
      }
      this.pData[C.PRE_FINALE] = 'empty';
      this.pStat[C.FINALE] = 0;
    } else {
      if (this.pStat[C.PRE_FINALE] < 100) {
        this.pStat[C.PRE_FINALE] = 100;
      }
    }

    // Token description update
    this.setTokenDescription(gameNumber);

    // Build pInfo string
    const cp = this.currPuzzle;
    let c3 = cp + ' of 100';
    let c4 = '';
    let c5 = '';
    const c6 = this.pSwords[cp] + ' of 0 Swords';
    const c7 = this.pWands[cp] + ' of 0 Wands';
    const c8 = this.pCups[cp] + ' of 0 Cups';
    const c9 = this.pPentacles[cp] + ' of 0 Pentacles';
    if (cp >= C.SWORDS1 && cp <= C.SWORDS2) {
      c4 = (cp - C.SWORDS1 + 1) + ' of ' + (C.SWORDS2 - C.SWORDS1 + 1) + ' SWORDS';
    } else if (cp >= C.WANDS1 && cp <= C.WANDS2) {
      c4 = (cp - C.WANDS1 + 1) + ' of ' + (C.WANDS2 - C.WANDS1 + 1) + ' WANDS';
    } else if (cp >= C.CUPS1 && cp <= C.CUPS2) {
      c4 = (cp - C.CUPS1 + 1) + ' of ' + (C.CUPS2 - C.CUPS1 + 1) + ' CUPS';
    } else if (cp >= C.PENTACLES1 && cp <= C.PENTACLES2) {
      c4 = (cp - C.PENTACLES1 + 1) + ' of ' + (C.PENTACLES2 - C.PENTACLES1 + 1) + ' PENTACLES';
    } else if (cp >= C.MANSION1 && cp <= C.MANSION2) {
      c4 = (cp - C.MANSION1 + 1) + ' of ' + (C.MANSION2 - C.MANSION1 + 1) + ' MANSION';
    }
    if (this.menuStat[cp] >= 3) {
      c5 = '--- SOLVED ---';
    }
    if (gameNumber !== 0) {
      const t1 = this.token1[gameNumber] || '';
      const t2 = this.token2[gameNumber] || '';
      this.pInfo = [c3, c4, t1, t2, c5, c6, c7, c8, c9].join('\r');
    }

    // Set pPage for mansion/DEL/HEX/REM puzzles
    this.updatePages();
  }

  // Only advance game menu status, never retreat (line 273)
  _setGameMenuStatus(n) {
    if (this.pStat[C.GAME_MENUS] < n) {
      this.pStat[C.GAME_MENUS] = n;
    }
  }

  // Open mansion windows based on puzzles-solved thresholds (line 210)
  updateMansionWindows(which, closeW, openW) {
    let base;
    switch (which) {
      case 1: base = 17; break;
      case 2: base = 36; break;
      case 3: base = 54; break;
      case 4: base = 70; break;
      default: return;
    }
    // Build threshold array: base, base-2, base-4, ... (descending, assigned 7→1)
    const windowStat = new Array(8); // 1-indexed
    for (let x = 7; x >= 1; x--) {
      windowStat[x] = base;
      base -= 2;
    }
    for (let x = 1; x <= 7; x++) {
      const n = C.MANSION1 + (x - 1);
      if (this.thePuzzlesSolved < windowStat[x]) {
        this.pStat[n] = closeW;
      } else if (this.pStat[n] < openW) {
        this.pStat[n] = openW;
      }
    }
  }

  // Check if all 7 mansion puzzles are at exactly goal; if so, advance phase (line 238)
  updateForMansionPhase(goal, stat) {
    let ct = 0;
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      if (this.pStat[x] === goal) ct++;
    }
    if (ct === 7) {
      this._setGameMenuStatus(stat);
    }
  }

  // HP + mansion beam completion check (line 250)
  updateForMansionBeam() {
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

  // Count unsolved puzzles for map progress (line 505)
  calcMapPiecesRemaining(byMenuStat) {
    this.getChunkMenuStat(); // refresh menuStat[]
    let t = 0;
    for (let x = C.SWORDS1; x <= C.PENTACLES2; x++) {
      if (this.menuStat[x] < byMenuStat) t++;
    }
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      if (this.pStat[x] < 400) t++;
    }
    return t;
  }

  // Binary string of solved status for map display (line 521)
  tallyMapPieces() {
    let s = '';
    for (let x = C.SWORDS1; x <= C.PENTACLES2; x++) {
      s += this.pStat[x] >= 100 ? '1' : '0';
    }
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      s += this.pStat[x] >= 400 ? '1' : '0';
    }
    return s;
  }

  // Propagate tarot completion to paired wager via pData (line 279).
  // In Director, solving a tarot sets its pData to 100, which then
  // propagates to the paired wager's pData.
  _updateSolvedTarot() {
    for (let x = 0; x < 5; x++) {
      const tarotIdx = PUZZLE_TYPES.tarot[x];
      const wagerIdx = PUZZLE_TYPES.wager[x];
      if (parseInt(this.pData[tarotIdx], 10) === 100) {
        const wagerData = parseInt(this.pData[wagerIdx], 10);
        if (isNaN(wagerData) || wagerData < 100) {
          this.pData[wagerIdx] = '100';
        }
      }
    }
  }

  // Compute dynamic token descriptions based on progress (line 543)
  setTokenDescription(gn) {
    if (!gn) return;
    this.getChunkMenuStat(); // refresh menuStat[]

    let newGameStat = 0;
    let virgin = 0;
    let solved = 0;

    for (let x = C.SWORDS1; x <= C.PENTACLES2; x++) {
      if (this.menuStat[x] >= 2) virgin++;
      if (this.menuStat[x] >= 3) solved++;
    }
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      if (this.menuStat[x] >= 2) virgin++;
      if (this.pStat[x] >= 400) solved++;
    }
    if (this.menuStat[C.MOONS_MAP] >= 2) virgin++;

    let c1, c2;
    if (solved === 0) {
      if (virgin === 0) newGameStat = 1;
      c1 = '77 Bewitchments remain';
      c2 = "and the Moon's Map is a mystery.";
    } else if (solved < 77) {
      c1 = (solved === 76)
        ? '1 Bewitchment remains'
        : (77 - solved) + ' Bewitchments remain';
      c2 = "and the Moon's Map is muddled.";
    } else {
      // All 77 bewitchments solved — check endgame milestones
      if (this.menuStat[C.MOONS_MAP] < 3) {
        c1 = 'All the pieces are gathered';
        c2 = "yet the Moon's Map is not whole.";
      } else if (this.menuStat[C.MOONS_PUZZLES] < 9) {
        c1 = "The Moon's Map is whole";
        c2 = 'yet Spirits and Innominates await.';
      } else if (this.menuStat[C.SEVEN_CUPS] < 9) {
        c1 = "The Moon's Map is complete";
        c2 = 'yet the Seven Cups are not restored.';
      } else if (this.menuStat[C.PRE_FINALE] < 9) {
        c1 = "The Moon's Map is complete";
        c2 = 'and the Finale awaits.';
      } else if (this.menuStat[C.FINALE] < 9) {
        c1 = "The Moon's Map is complete.";
        c2 = 'The Book of Thoth remains hidden.';
      } else {
        c1 = 'The Fool has earned the Gift of Prophecy.';
        c2 = 'The Book of Thoth is entombed once again.';
      }
    }

    this.token1[gn] = c1;
    this.token2[gn] = c2;
    this.token3[gn] = newGameStat;
  }

  // Set pPage values for mansion/DEL/HEX/REM puzzles (line 619)
  updatePages() {
    for (let x = PUZZLE_TYPES.DEL[0]; x <= PUZZLE_TYPES.DEL[6]; x++) {
      this.pPage[x] = 2;
    }
    for (let x = PUZZLE_TYPES.HEX[0]; x <= PUZZLE_TYPES.HEX[6]; x++) {
      this.pPage[x] = 4;
    }
    for (let x = PUZZLE_TYPES.REM[0]; x <= PUZZLE_TYPES.REM[6]; x++) {
      this.pPage[x] = 6;
    }
    for (let x = C.MANSION1; x <= C.MANSION2; x++) {
      const s = this.pStat[x];
      if (s < 100)      { this.pPage[x] = 1; continue; }
      if (s === 100)    { this.pPage[x] = 2; continue; }
      if (s < 200)      { this.pPage[x] = 3; continue; }
      if (s === 200)    { this.pPage[x] = 4; continue; }
      if (s < 300)      { this.pPage[x] = 5; continue; }
      if (s === 300)    { this.pPage[x] = 6; continue; }
      if (s < 400)      { this.pPage[x] = 7; continue; }
      this.pPage[x] = 8;
    }
  }

  // -----------------------------------------------------------------------
  // Launch Logic
  // -----------------------------------------------------------------------

  // Redirect certain puzzle launches (line 289 of 06-Update-Stats.ls)
  exceptionPuzzleLaunch(n, isSaving) {
    if (n === C.FINALE) {
      if (this.lastPuzzle === C.FINALE) n = C.PRE_FINALE;
    }
    if (n === C.TOKENS) {
      if (this.lastPuzzle !== C.TOKENS) {
        n = this.lastPuzzle;
      } else {
        n = C.GAME_MENUS;
      }
    }
    if (n < 1 || n > C.PUZZLE_TOTAL) {
      n = C.GAME_MENUS;
    }
    if (isSaving) {
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

  // Get the effective frameId for mansion puzzles based on game menu phase
  getMansionFrameId() {
    const gmStat = this.pStat[C.GAME_MENUS];
    if (gmStat <= 20) return 'passwords';
    if (gmStat <= 60) return 'hex-words';
    if (gmStat <= 90) return 'unnecessary';
    return 'connects';
  }

  // -----------------------------------------------------------------------
  // SWF State Sync
  // -----------------------------------------------------------------------

  // Sync completion data from Game Menus SWF back to game state (line 466)
  getMenuStatsFromFlash(updateString) {
    if (!updateString || updateString.length < 100) return;
    // Pad to 128 if only 100 chars (Director pads with '3')
    let s = updateString;
    if (s.length === 100) {
      for (let x = 101; x <= C.PUZZLE_TOTAL; x++) s += '3';
    }
    const chunkMenuStat = this.getChunkMenuStat();
    if (s === chunkMenuStat || s.substring(0, 3) === 'NaN' || !chunkMenuStat) return;

    for (let x = 0; x < C.PUZZLE_TOTAL; x++) {
      const m1 = parseInt(chunkMenuStat[x], 10);
      const m2 = parseInt(s[x], 10);
      if (m2 > m1) {
        const puzzIdx = x + 1; // chunkMenuStat is 0-indexed, puzzles are 1-indexed
        switch (m2) {
          case 3: this.pStat[puzzIdx] = 100; break;
          case 4: this.pStat[puzzIdx] = 200; break;
          case 5: this.pStat[puzzIdx] = 300; break;
          case 6: this.pStat[puzzIdx] = 400; break;
          case 7: this.pStat[puzzIdx] = 500; break;
          case 8: this.pStat[puzzIdx] = 600; break;
          case 9: this.pStat[puzzIdx] = 700; break;
        }
      }
    }
  }

  // -----------------------------------------------------------------------
  // Dev Tools
  // -----------------------------------------------------------------------

  markSolved(puzzleIndex) {
    this.pStat[puzzleIndex] = 100;
    this.save();
  }

  markUnsolved(puzzleIndex) {
    this.pStat[puzzleIndex] = 0;
    this.pData[puzzleIndex] = 'empty';
    this.save();
  }

  // -----------------------------------------------------------------------
  // Persistence
  // -----------------------------------------------------------------------

  save() {
    const data = {
      currGame: this.currGame,
      currPuzzle: this.currPuzzle,
      lastPuzzle: this.lastPuzzle,
      pStat: this.pStat,
      pData: this.pData,
      pPage: this.pPage,
      pDone: this.pDone,
      pSwords: this.pSwords,
      pWands: this.pWands,
      pCups: this.pCups,
      pPentacles: this.pPentacles,
      pMenu: this.pMenu,
      csWagerTarot: this.csWagerTarot,
      pWordStat63: this.pWordStat63,
      token1: this.token1,
      token2: this.token2,
      token3: this.token3,
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
      if (data.pDone) this.pDone = data.pDone;
      if (data.pSwords) this.pSwords = data.pSwords;
      if (data.pWands) this.pWands = data.pWands;
      if (data.pCups) this.pCups = data.pCups;
      if (data.pPentacles) this.pPentacles = data.pPentacles;
      if (data.pMenu) this.pMenu = data.pMenu;
      if (data.csWagerTarot) this.csWagerTarot = data.csWagerTarot;
      if (data.pWordStat63) this.pWordStat63 = data.pWordStat63;
      if (data.token1) this.token1 = data.token1;
      if (data.token2) this.token2 = data.token2;
      if (data.token3) this.token3 = data.token3;
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
