// Main orchestrator tying together game state, SWF loading, and navigation.

import { PUZZLES, SECTION_RANGES, C } from './puzzle-data.js';
import { GameState } from './game-state.js';
import { SwfLoader } from './swf-loader.js';

export class Orchestrator {
  constructor() {
    this.state = new GameState();
    this.loader = null;
    this.navEl = null;
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

    // Load last puzzle or default to first playable
    const startPuzzle = this.state.currPuzzle || 2;
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

    this.state.lastPuzzle = this.state.currPuzzle;
    this.state.currPuzzle = puzzleIndex;
    this.state.save();

    document.title = `The Fool and his Money - ${puzzle.titleName}`;

    const ok = await this.loader.loadPuzzle(puzzleIndex, this.state);
    if (ok) {
      this.refreshNav();
    }
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
