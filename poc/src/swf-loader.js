// SWF loader wrapping Ruffle player instantiation.
// Handles loading SWFs with FlashVars from game state.

import { FRAME_TO_SWF } from './frame-swf-map.js';
import { PUZZLES } from './puzzle-data.js';

export class SwfLoader {
  constructor(containerEl, statusEl) {
    this.container = containerEl;
    this.statusEl = statusEl;
    this.player = null;
    this.currentSwf = null;
  }

  async loadPuzzle(puzzleIndex, gameState) {
    const puzzle = PUZZLES[puzzleIndex];
    if (!puzzle) {
      this.setStatus(`Invalid puzzle index: ${puzzleIndex}`);
      return false;
    }

    const swfFile = FRAME_TO_SWF[puzzle.frameId];
    if (!swfFile) {
      this.setStatus(`No SWF mapping for frame: ${puzzle.frameId}`);
      return false;
    }

    const flashVars = gameState.getFlashVars(puzzleIndex);
    return this.loadSwf(swfFile, flashVars, puzzle.titleName);
  }

  async loadSwf(swfFile, parameters = {}, label = '') {
    this.container.innerHTML = '';
    this.setStatus(`Loading ${label || swfFile}...`);

    try {
      const ruffle = window.RufflePlayer.newest();
      this.player = ruffle.createPlayer();
      this.player.style.width = '100%';
      this.player.style.height = '100%';
      this.container.appendChild(this.player);

      await this.player.load({
        url: swfFile,
        allowScriptAccess: true,
        autoplay: 'on',
        unmuteOverlay: 'hidden',
        logLevel: 'warn',
        letterbox: 'on',
        parameters,
      });

      this.currentSwf = swfFile;
      this.setStatus(`${label || swfFile} | Standalone mode | Click inside to interact`);
      return true;
    } catch (e) {
      this.setStatus(`Error loading ${swfFile}: ${e.message}`);
      console.error(e);
      return false;
    }
  }

  setStatus(text) {
    if (this.statusEl) {
      this.statusEl.textContent = text;
    }
  }
}
