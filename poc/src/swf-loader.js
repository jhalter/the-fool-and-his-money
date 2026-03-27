// SWF loader wrapping Ruffle player instantiation.
// Handles loading SWFs with FlashVars and ExternalInterface bridge.

import { FRAME_TO_SWF, SWF_DIR } from './frame-swf-map.js';
import { PUZZLES } from './puzzle-data.js';

export class SwfLoader {
  constructor(containerEl, statusEl) {
    this.container = containerEl;
    this.statusEl = statusEl;
    this.player = null;
    this.ruffleApi = null;
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
    return this.loadSwf(SWF_DIR + swfFile, flashVars, puzzle.titleName);
  }

  async loadSwf(swfUrl, parameters = {}, label = '') {
    this.ruffleApi = null;
    this.container.innerHTML = '';
    this.setStatus(`Loading ${label || swfUrl}...`);

    try {
      const ruffle = window.RufflePlayer.newest();
      this.player = ruffle.createPlayer();
      this.player.style.width = '100%';
      this.player.style.height = '100%';
      this.container.appendChild(this.player);

      await this.player.load({
        url: swfUrl,
        allowScriptAccess: true,
        autoplay: 'on',
        unmuteOverlay: 'hidden',
        logLevel: 'warn',
        letterbox: 'on',
        parameters,
      });

      this.ruffleApi = this.player.ruffle();
      this.currentSwf = swfUrl;

      // Force standalone mouse listeners for SWFs that hardcode DirectorInControl=1
      // (e.g., Tokens hub). No-op for SWFs already in standalone mode.
      setTimeout(() => this.enableStandaloneMode(), 200);

      this.setStatus(`${label || swfUrl} | Click inside to interact`);
      return true;
    } catch (e) {
      this.setStatus(`Error loading ${swfUrl}: ${e.message}`);
      console.error(e);
      return false;
    }
  }

  getVar(name) {
    if (!this.ruffleApi) return undefined;
    try {
      return this.ruffleApi.callExternalInterface('getVar', name);
    } catch (e) {
      return undefined;
    }
  }

  setVar(name, value) {
    if (!this.ruffleApi) return;
    try {
      this.ruffleApi.callExternalInterface('setVar', name, String(value));
    } catch (e) {
      // Silently ignore — SWF may not have bridge
    }
  }

  enableStandaloneMode() {
    if (!this.ruffleApi) return;
    try {
      this.ruffleApi.callExternalInterface('enableStandaloneMode');
    } catch (e) {
      // Silently ignore
    }
  }

  setStatus(text) {
    if (this.statusEl) {
      this.statusEl.textContent = text;
    }
  }
}
