// Two-SWF state machine for The Prologue.
// Replicates Director's frame-loop orchestration of _prologue1 (foreground)
// and _prologue2 (background), coordinated via the prologueCue variable.
//
// Director used two sprite channels whose SWF assignments SWAP between phases:
//   Phase 1 (PRO-1): sprite(1)=swf_023, sprite(2)=swf_024
//   Phase 2 (PRO-2): sprite(1)=swf_024, sprite(2)=swf_023
//
// swf_024 timeline: frame 1: cue=1,stop  73: cue=3  146: cue=4  364: cue=5  392: cue=6  408: stop
// swf_023 timeline: frame 1: stop  316: openCurtains  381: cue=2  387: stop

import { OverlayLoader } from './swf-loader.js';
import { PROLOGUE_SWF_1, SWF_DIR } from './frame-swf-map.js';

const POLL_MS = 100;

const S = {
  LOADING:       0,
  // Phase 1: swf_024 plays background, swf_023 plays foreground
  PHASE1_CUE1:   1,  // wait for swf_024 prologueCue == 1, then play swf_023
  PHASE1_CUE2:   2,  // wait for swf_023 prologueCue == 2, then enter Phase 2
  // Phase 2: sprites swap — swf_024 replays as main, swf_023 is overlay
  PHASE2_WAIT1:  3,  // restart swf_024, wait for its prologueCue == 1
  PHASE2_SET2:   4,  // set prologueCue=2 on swf_024, wait for cue == 3
  PHASE2_CUE4:   5,  // wait for swf_024 prologueCue == 4
  PHASE2_CUE5:   6,  // wait for swf_024 prologueCue == 5
  PHASE2_CUE6:   7,  // wait for swf_024 prologueCue == 6
  DONE:          8,
};

export class PrologueController {
  /**
   * @param {Function} onComplete - called when the Prologue finishes naturally
   * @param {Function} onAbort    - called when the user skips (click/key)
   */
  constructor(onComplete, onAbort) {
    this.onComplete = onComplete;
    this.onAbort = onAbort;

    // Loaders stay bound to their SWF for the lifetime of the Prologue.
    // "prologue1" = swf_023 (OverlayLoader in #prologue-container)
    // "prologue2" = swf_024 (main SwfLoader in #player-container)
    this.prologue1 = null;
    this.prologue2 = null;
    this.container = null;
    this.state = S.LOADING;
    this.timer = null;
    this.stopped = false;

    this._handleInput = this._handleInput.bind(this);
  }

  /**
   * @param {SwfLoader} mainLoader - the main SwfLoader (already has swf_024 loaded)
   * @param {HTMLElement} container - the #prologue-container element
   */
  async start(mainLoader, container) {
    this.prologue2 = mainLoader;   // swf_024
    this.container = container;

    // Load swf_023 into the overlay container
    this.prologue1 = new OverlayLoader(container);
    await this.prologue1.load(PROLOGUE_SWF_1, { letterbox: 'on' });

    if (this.stopped) return;

    // Phase 1 init (pro_Play_1):
    // - swf_023 stopped at frame 1 (its ActionScript has stop())
    // - swf_024 needs to play past frame 1's stop()
    this.prologue1.gotoFrame(1);
    this.container.style.display = 'block';

    // swf_024 loaded with autoplay but stop() on frame 1 halts it.
    // Director called sprite(2).play() to override. We skip to frame 2.
    this.prologue2.callFrame(2);

    // Register abort listeners (any input skips the Prologue)
    document.addEventListener('mousedown', this._handleInput, true);
    document.addEventListener('keydown', this._handleInput, true);

    this.state = S.PHASE1_CUE1;
    this.timer = setInterval(() => this._tick(), POLL_MS);
  }

  stop() {
    if (this.stopped) return;
    this.stopped = true;

    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }

    document.removeEventListener('mousedown', this._handleInput, true);
    document.removeEventListener('keydown', this._handleInput, true);

    if (this.container) {
      this.container.style.display = 'none';
      this.container.innerHTML = '';
    }

    this.prologue1 = null;
  }

  _handleInput(e) {
    if (e.type === 'keydown' && e.key === 'Escape') return;
    this._abort();
  }

  _abort() {
    if (this.stopped) return;

    // Zero prologueCue on both SWFs (pro_Zero_Variables)
    if (this.prologue2) this.prologue2.setVar('prologueCue', '0');
    if (this.prologue1) this.prologue1.setVar('prologueCue', '0');

    this.stop();
    this.onAbort();
  }

  _getCue(loader) {
    const raw = loader.getVar('prologueCue');
    if (raw === undefined || raw === null) return -1;
    const n = parseInt(raw, 10);
    return isNaN(n) ? -1 : n;
  }

  _tick() {
    if (this.stopped) return;

    switch (this.state) {
      // ── Phase 1 ─────────────────────────────────────────────
      // Director: sprite(1)=swf_023, sprite(2)=swf_024

      case S.PHASE1_CUE1: {
        // pro_Play_2: poll swf_024 for prologueCue == 1, then play swf_023
        const cue = this._getCue(this.prologue2);
        if (cue === 1) {
          // Start swf_023 playing — use frame 2 to skip frame 1's stop()
          this.prologue1.callFrame(2);
          this.state = S.PHASE1_CUE2;
        }
        break;
      }

      case S.PHASE1_CUE2: {
        // pro_Play_3: poll swf_023 for prologueCue == 2
        const cue = this._getCue(this.prologue1);
        if (cue === 2) {
          // Hide both, enter Phase 2
          this.container.style.display = 'none';
          this.state = S.PHASE2_WAIT1;
        }
        break;
      }

      // ── Phase 2 ─────────────────────────────────────────────
      // Director swaps sprites: sprite(1)=swf_024, sprite(2)=swf_023
      // Now we read cues from swf_024 and set clip properties on swf_023.

      case S.PHASE2_WAIT1: {
        // pro_Play_4 entry: restart swf_024 from frame 1 and play
        this.prologue2.gotoFrame(1);   // reset to frame 1 (prologueCue=1, stop)
        this.prologue2.callFrame(2);   // play from frame 2
        // Show swf_023 overlay (Director's prepareFrame makes sprite visible)
        this.container.style.display = 'block';
        this.state = S.PHASE2_SET2;
        break;
      }

      case S.PHASE2_SET2: {
        // pro_Play_4: wait for swf_024 prologueCue == 1 (set on its frame 1),
        // then set it to 2 and wait for cue == 3
        const cue = this._getCue(this.prologue2);
        if (cue >= 1) {
          this.prologue2.setVar('prologueCue', '2');
          this.state = S.PHASE2_CUE4;
        }
        break;
      }

      case S.PHASE2_CUE4: {
        // pro_Play_4→5: wait for swf_024 to reach frame 73 (cue=3), then 146 (cue=4)
        const cue = this._getCue(this.prologue2);
        if (cue === 3) {
          // pro_Play_4 second check: sprite(2) visible — swf_023 overlay is already shown
        }
        if (cue === 4) {
          // pro_Play_5: show dim clips on swf_023 (the Phase 2 "sprite(2)")
          this.prologue1.setVar('dim1._visible', 'true');
          this.prologue1.setVar('dim2._visible', 'true');
          this.prologue1.setVar('dim3._visible', 'true');
          this.state = S.PHASE2_CUE5;
        }
        break;
      }

      case S.PHASE2_CUE5: {
        // pro_Play_6: wait for swf_024 prologueCue == 5
        const cue = this._getCue(this.prologue2);
        if (cue === 5) {
          this.prologue1.setVar('dim2._visible', 'false');
          this.prologue1.setVar('and1._visible', 'false');
          this.prologue1.setVar('and2._visible', 'false');
          this.state = S.PHASE2_CUE6;
        }
        break;
      }

      case S.PHASE2_CUE6: {
        // pro_Play_7: wait for swf_024 prologueCue == 6, mark solved
        const cue = this._getCue(this.prologue2);
        if (cue === 6) {
          this.state = S.DONE;
          this.stop();
          this.onComplete();
        }
        break;
      }
    }
  }
}
