// Maps Director frame identifiers to SWF filenames.
// Derived from special_VerifyCast() in 09-Special.ls and CASt binary extraction.
// SWFs are served from the swf/ subdirectory (patched with ExternalInterface bridge).

export const SWF_DIR = 'swf/';

export const FRAME_TO_SWF = {
  // Puzzle SWFs (one SWF shared by multiple puzzles via pNum)
  '4x4':        'chunk_01_CDGF_0x00011ca6_swf_000_v8.swf',
  'cross-slide': 'chunk_11_CDGF_0x01a05d92_swf_026_v8.swf',
  'patchwork':  'chunk_12_CDGF_0x01e47f96_swf_027_v8.swf',
  'phrase':     'chunk_27_CDGF_0x04ebd710_swf_050_v8.swf',
  'concat':     'chunk_31_CDGF_0x05711c76_swf_054_v8.swf',
  'morph-moon': 'chunk_15_CDGF_0x0270021e_swf_030_v8.swf',
  'morph-text': 'chunk_34_CDGF_0x05d9f3b8_swf_057_v8.swf',
  'wager':      'chunk_41_CDGF_0x0788e9e6_swf_065_v8.swf',
  'coins':      'chunk_16_CDGF_0x028c64b2_swf_031_v8.swf',
  'stamp':      'chunk_25_CDGF_0x049e162c_swf_048_v8.swf',
  'jumble':     'chunk_26_CDGF_0x04c85ea2_swf_049_v8.swf',
  'auction':    'chunk_43_CDGF_0x081976a2_swf_067_v8.swf',
  'code-grid':  'chunk_17_CDGF_0x02a085fc_swf_032_v8.swf',
  'sevens':     'chunk_14_CDGF_0x022f8aba_swf_029_v8.swf',
  'halves':     'chunk_33_CDGF_0x05cb3be6_swf_056_v8.swf',
  'herbs':      'chunk_36_CDGF_0x069a0bc4_swf_060_v8.swf',
  'fill-in':    'chunk_28_CDGF_0x0518cec2_swf_051_v8.swf',
  'tracer':     'chunk_22_CDGF_0x0393ff56_swf_039_v8.swf',
  'inventory':  'chunk_32_CDGF_0x059ec06c_swf_055_v8.swf',
  'market':     'chunk_29_CDGF_0x052fcff0_swf_052_v8.swf',
  'slider':     'chunk_30_CDGF_0x0558b056_swf_053_v8.swf',

  // Mansion puzzles
  'passwords':  'chunk_19_CDGF_0x02ee2282_swf_035_v8.swf',
  'DEL':        'chunk_19_CDGF_0x02ee2282_swf_036_v8.swf',
  'hex-words':  'chunk_18_CDGF_0x02c51a72_swf_033_v8.swf',
  'HEX':        'chunk_18_CDGF_0x02c51a72_swf_034_v8.swf',
  'unnecessary':'chunk_35_CDGF_0x060358b0_swf_058_v8.swf',
  'REM':        'chunk_35_CDGF_0x060358b0_swf_059_v8.swf',
  'CON':        'chunk_42_CDGF_0x07c93878_swf_066_v8.swf',

  // Special puzzles
  'pre-Finale': 'chunk_10_CDGF_0x018f2842_swf_025_v8.swf',
  'HP':         'chunk_20_CDGF_0x036b565a_swf_037_v8.swf',
  'Pre-HP':     'chunk_07_CDGF_0x0137328c_swf_019_v8.swf',
  'End-HP':     'chunk_07_CDGF_0x0137328c_swf_018_v8.swf',
  'seven-cups': 'chunk_21_CDGF_0x037b605e_swf_038_v8.swf',
  'tarot-1':    'chunk_13_CDGF_0x020ee5da_swf_028_v8.swf',
  'tarot-2':    'chunk_37_CDGF_0x06e9124e_swf_061_v8.swf',
  'tarot-3':    'chunk_38_CDGF_0x0712e0cc_swf_062_v8.swf',
  'tarot-4':    'chunk_39_CDGF_0x073e5a36_swf_063_v8.swf',
  'tarot-5':    'chunk_40_CDGF_0x07682ae6_swf_064_v8.swf',

  // Navigation/hub SWFs
  'map':          'chunk_03_CDGF_0x007769d8_swf_005_v8.swf',
  'map-puzzles':  'chunk_24_CDGF_0x04800914_swf_047_v8.swf',
  'game-menus':   'chunk_04_CDGF_0x008369ca_swf_006_v8.swf',
  'tokens':       'chunk_02_CDGF_0x0026ce60_swf_001_v8.swf',
  'tokens-help':  'chunk_02_CDGF_0x0026ce60_swf_003_v8.swf',

  // Prologue (two SWFs: _prologue2 is background, _prologue1 is foreground)
  'PRO-1':        'chunk_08_CDGF_0x014566d6_swf_024_v8.swf',

  // Finale sequence
  'F01':          'chunk_23_CDGF_0x03b5de28_swf_041_v8.swf',
};

// Secondary SWF for the Prologue's foreground animation (sprite 1 / _prologue1)
export const PROLOGUE_SWF_1 = 'chunk_08_CDGF_0x014566d6_swf_023_v8.swf';

// SWF stage heights extracted from binary headers (twips / 20 → pixels).
// Director checked sprite(cActiveSN).height to determine layout mode:
//   320 → regular (menu + help + arrows)
//   580 → special (menu visible, help overlays puzzle)
//   600 → full screen (no menu, no help)
// Only non-320 entries listed; all unlisted frameIds default to 320.
export const FRAME_STAGE_HEIGHT = {
  'HP':         580,
  'seven-cups': 580,
  'tarot-1':    580,
  'tarot-2':    580,
  'tarot-3':    580,
  'tarot-4':    580,
  'tarot-5':    580,
  'map':        580,
  'map-puzzles':580,
  'game-menus': 580,
  'tokens':     600,
  'tokens-help':600,
  'Pre-HP':     600,
  'End-HP':     600,
};
