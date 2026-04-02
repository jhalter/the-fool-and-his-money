// SWF loader wrapping Ruffle player instantiation.
// Handles loading SWFs with FlashVars and ExternalInterface bridge.

import { FRAME_TO_SWF, FRAME_STAGE_HEIGHT, SWF_DIR } from './frame-swf-map.js';
import { PUZZLES } from './puzzle-data.js';

export class SwfLoader {
  constructor(containerEl, statusEl) {
    this.container = containerEl;
    this.statusEl = statusEl;
    this.player = null;
    this.ruffleApi = null;
    this.currentSwf = null;
  }

  async loadPuzzle(puzzleIndex, gameState, frameIdOverride) {
    const puzzle = PUZZLES[puzzleIndex];
    if (!puzzle) {
      this.setStatus(`Invalid puzzle index: ${puzzleIndex}`);
      return false;
    }

    const frameId = frameIdOverride || puzzle.frameId;
    const swfFile = FRAME_TO_SWF[frameId];
    if (!swfFile) {
      this.setStatus(`No SWF mapping for frame: ${frameId}`);
      return false;
    }

    this.stageHeight = FRAME_STAGE_HEIGHT[frameId] ?? 320;

    const flashVars = gameState.getFlashVars(puzzleIndex);
    return this.loadSwf(SWF_DIR + swfFile, flashVars, puzzle.titleName);
  }

  async loadSwf(swfUrl, parameters = {}, label = '') {
    this.ruffleApi = null;
    this.pendingFlashVars = parameters;
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
        splashScreen: false,
        allowScriptAccess: true,
        autoplay: 'on',
        unmuteOverlay: 'hidden',
        logLevel: 'warn',
        letterbox: 'on',
        parameters,
      });

      this.ruffleApi = this.player.ruffle();
      this.currentSwf = swfUrl;

      // Wait for SWF to signal readiness (gListener=666), then push saved
      // state and enable standalone mouse listeners.
      // Mirrors Director's puzz_ExitInit → sendFlashData → enableStandaloneMode.
      this.waitForReady();

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

  getPolledState() {
    if (!this.ruffleApi) return null;
    try {
      return this.ruffleApi.callExternalInterface('getPolledState');
    } catch (e) {
      return null;
    }
  }

  getStageHeight() {
    return this.stageHeight ?? 320;
  }

  enableStandaloneMode() {
    if (!this.ruffleApi) return;
    try {
      this.ruffleApi.callExternalInterface('enableStandaloneMode');
    } catch (e) {
      // Silently ignore
    }
  }

  waitForReady() {
    const swfAtStart = this.currentSwf;
    let attempts = 0;
    const maxAttempts = 50; // 5s at 100ms intervals
    const check = () => {
      if (!this.ruffleApi || this.currentSwf !== swfAtStart) return;
      attempts++;
      try {
        const listener = this.ruffleApi.callExternalInterface('getVar', 'gListener');
        if (String(listener) === '666') {
          // Mirror Director's sendFlashData(): re-push saved state via
          // ExternalInterface after the SWF's init code has run, since
          // initFlashEvents() may overwrite FlashVars with defaults.
          this.sendFlashData();
          this.enableStandaloneMode();
          return;
        }
      } catch (e) { /* ignore */ }
      if (attempts >= maxAttempts) {
        this.sendFlashData();
        this.enableStandaloneMode();
      } else {
        setTimeout(check, 100);
      }
    };
    setTimeout(check, 100);
  }

  // Push saved state to SWF via setVar, matching Director's sendFlashData()
  // in 02-Misc.ls. Called after gListener=666 so it overwrites any defaults
  // the SWF's init code set.
  sendFlashData() {
    const vars = this.pendingFlashVars;
    if (!vars || !this.ruffleApi) return;
    for (const [key, value] of Object.entries(vars)) {
      this.setVar(key, value);
    }
    this.pendingFlashVars = null;
  }

  gotoFrame(n) {
    if (!this.ruffleApi) return;
    try {
      this.ruffleApi.callExternalInterface('gotoFrame', String(n));
    } catch (e) { /* ignore */ }
  }

  callFrame(n) {
    if (!this.ruffleApi) return;
    try {
      this.ruffleApi.callExternalInterface('callFrame', String(n));
    } catch (e) { /* ignore */ }
  }

  setStatus(text) {
    if (this.statusEl) {
      this.statusEl.textContent = text;
    }
  }
}

// Lightweight loader for overlay SWFs (menu, help, scroll, arrows)
export class OverlayLoader {
  constructor(containerEl) {
    this.container = containerEl;
    this.player = null;
    this.ruffleApi = null;
  }

  async load(swfFile, options = {}) {
    this.container.innerHTML = '';
    try {
      const ruffle = window.RufflePlayer.newest();
      this.player = ruffle.createPlayer();
      this.player.style.width = '100%';
      this.player.style.height = '100%';
      this.container.appendChild(this.player);
      await this.player.load({
        url: SWF_DIR + swfFile,
        splashScreen: false,
        allowScriptAccess: true,
        autoplay: 'on',
        unmuteOverlay: 'hidden',
        logLevel: 'warn',
        letterbox: 'off',
        parameters: {},
        ...options,
      });
      this.ruffleApi = this.player.ruffle();
      return true;
    } catch (e) {
      console.warn('Overlay load failed:', swfFile, e);
      return false;
    }
  }

  setVar(name, value) {
    if (!this.ruffleApi) return;
    try {
      this.ruffleApi.callExternalInterface('setVar', name, String(value));
    } catch (e) { /* ignore */ }
  }

  getVar(name) {
    if (!this.ruffleApi) return undefined;
    try {
      return this.ruffleApi.callExternalInterface('getVar', name);
    } catch (e) {
      return undefined;
    }
  }

  gotoFrame(n) {
    if (!this.ruffleApi) return;
    try {
      this.ruffleApi.callExternalInterface('gotoFrame', String(n));
    } catch (e) { /* ignore */ }
  }

  callFrame(n) {
    if (!this.ruffleApi) return;
    try {
      this.ruffleApi.callExternalInterface('callFrame', String(n));
    } catch (e) { /* ignore */ }
  }
}
