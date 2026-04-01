// Puzzle definitions translated from gatherAllData() in MovieScript 12 - 07-Data.ls.
// Each entry: { id (1-128), menuName, pNum, volume, frameId, titleName, section }

export const SECTIONS = {
  PROLOGUE: 'Prologue',
  SWORDS: 'Swords',
  WANDS: 'Wands',
  CUPS: 'Cups',
  PENTACLES: 'Pentacles',
  PRE_FINALE: 'Pre-Finale',
  MANSION: 'Mansion',
  FINALE: 'Finale',
  SPECIAL: 'Special',
  DEL: 'Deliveries',
  HEX: 'Hexes',
  REM: 'Remainders',
  CON: 'Connections',
};

// Puzzle type groups (indices into PUZZLES array, 1-based to match Director)
export const PUZZLE_TYPES = {
  patchPirate: [],   // patchwork
  morph: [],
  phrase: [],
  wager: [],
  tarot: [],
  concat: [],
  grid: [],          // 4x4
  coins: [],
  morphText: [],
  stamp: [],
  jumble: [],
  auction: [],
  letterSlide: [],   // cross-slide
  clickCode: [],     // code-grid
  seven: [],         // sevens
  halves: [],
  herb: [],          // herbs
  fillIn: [],
  tracer: [],
  inventory: [],
  pentacle: [],      // market
  slider: [],
  mansion: [],
  wagerTarot: [],
  DEL: [],
  HEX: [],
  REM: [],
  CON: [],
};

function definePuzzle(id, menuName, pNum, volume, frameId, titleName, section) {
  return { id, menuName, pNum, volume, frameId, titleName, section };
}

export const PUZZLES = [
  null, // index 0 unused (Director is 1-based)
  // 1: Prologue
  definePuzzle(1, 'Prologue', 1, 80, 'PRO-1', 'The Prologue', SECTIONS.PROLOGUE),
  // 2-18: Swords
  definePuzzle(2, 'Payne', 1, 100, 'patchwork', "Payne's Patchwork", SECTIONS.SWORDS),
  definePuzzle(3, 'Ursula', 1, 100, 'morph-moon', "Ursula's Umbrage", SECTIONS.SWORDS),
  definePuzzle(4, 'Lawley', 1, 100, 'phrase', "Lawley's Literals", SECTIONS.SWORDS),
  definePuzzle(5, 'Wyck', 1, 100, 'wager', "Wyck's Wager", SECTIONS.SWORDS),
  definePuzzle(6, 'Needham', 1, 100, 'concat', "Needham's Knowledge", SECTIONS.SWORDS),
  definePuzzle(7, 'Garrison', 1, 100, '4x4', "Garrison's Gridlock", SECTIONS.SWORDS),
  definePuzzle(8, 'Quintin', 1, 100, 'coins', "Quintin's Quandary", SECTIONS.SWORDS),
  definePuzzle(9, 'Moxley', 1, 100, 'morph-text', "Moxley's Metamorphosis", SECTIONS.SWORDS),
  definePuzzle(10, 'Sabina', 1, 100, 'stamp', "Sabina's Scramble", SECTIONS.SWORDS),
  definePuzzle(11, 'Jasper', 1, 100, 'jumble', "Jasper Junction", SECTIONS.SWORDS),
  definePuzzle(12, 'Agar', 1, 100, 'auction', "Agar's Auction", SECTIONS.SWORDS),
  definePuzzle(13, 'McGucken', 2, 100, 'morph-text', "McGucken's Metamorphosis", SECTIONS.SWORDS),
  definePuzzle(14, 'Horton', 1, 100, 'cross-slide', "Horton's Horizontals", SECTIONS.SWORDS),
  definePuzzle(15, 'Caine', 1, 100, 'code-grid', "Caine's Curses", SECTIONS.SWORDS),
  definePuzzle(16, 'Voorst', 1, 100, 'sevens', "Voorst's Vendition", SECTIONS.SWORDS),
  definePuzzle(17, 'Massey', 3, 100, 'morph-text', "Massey's Metamorphosis", SECTIONS.SWORDS),
  definePuzzle(18, 'Wallop', 2, 100, 'wager', "Wallop's Wager", SECTIONS.SWORDS),
  // 19-37: Wands
  definePuzzle(19, 'Pringle', 2, 100, 'patchwork', "Pringle's Patchwork", SECTIONS.WANDS),
  definePuzzle(20, 'Buckbee', 1, 100, 'halves', "Buckbee's Bones", SECTIONS.WANDS),
  definePuzzle(21, 'Radcliff', 1, 100, 'herbs', "Radcliff's Reminiscences", SECTIONS.WANDS),
  definePuzzle(22, 'Norfolk', 2, 100, 'concat', "Norfolk's Knowledge", SECTIONS.WANDS),
  definePuzzle(23, 'Gliston', 2, 100, '4x4', "Gliston's Gridlock", SECTIONS.WANDS),
  definePuzzle(24, 'Yapp', 1, 100, 'fill-in', "Yapp's Yearning", SECTIONS.WANDS),
  definePuzzle(25, 'Hayden', 2, 100, 'cross-slide', "Hayden's Horizontals", SECTIONS.WANDS),
  definePuzzle(26, 'Roderick', 2, 100, 'herbs', "Roderick's Reminiscences", SECTIONS.WANDS),
  definePuzzle(27, 'Vibbard', 2, 100, 'sevens', "Vibbard's Vendition", SECTIONS.WANDS),
  definePuzzle(28, 'Lommis', 2, 100, 'phrase', "Lommis's Literals", SECTIONS.WANDS),
  definePuzzle(29, 'Cutting', 2, 100, 'code-grid', "Cutting's Curses", SECTIONS.WANDS),
  definePuzzle(30, 'Jost', 2, 100, 'jumble', "Jost Junction", SECTIONS.WANDS),
  definePuzzle(31, 'Rymore', 3, 100, 'herbs', "Rymore's Reminiscences", SECTIONS.WANDS),
  definePuzzle(32, 'Argyle', 2, 100, 'auction', "Argyle's Auction", SECTIONS.WANDS),
  definePuzzle(33, 'Snodgrass', 2, 100, 'stamp', "Snodgrass's Scramble", SECTIONS.WANDS),
  definePuzzle(34, 'Ingram', 1, 100, 'inventory', "Ingram's Inventory", SECTIONS.WANDS),
  definePuzzle(35, 'Wentworth', 3, 100, 'wager', "Wentworth's Wager", SECTIONS.WANDS),
  definePuzzle(36, 'Riason', 4, 100, 'herbs', "Riason's Reminiscences", SECTIONS.WANDS),
  definePuzzle(37, 'Handel', 3, 100, 'cross-slide', "Handel's Horizontals", SECTIONS.WANDS),
  // 38-55: Cups
  definePuzzle(38, 'Percy', 3, 100, 'patchwork', "Percy's Patchwork", SECTIONS.CUPS),
  definePuzzle(39, 'Telfair', 1, 100, 'tracer', "Telfair's Tracer", SECTIONS.CUPS),
  definePuzzle(40, 'Nairne', 3, 100, 'concat', "Nairne's Knowledge", SECTIONS.CUPS),
  definePuzzle(41, 'Harleigh', 4, 100, 'cross-slide', "Harleigh's Horizontals", SECTIONS.CUPS),
  definePuzzle(42, 'Girdwood', 3, 100, '4x4', "Girdwood's Gridlock", SECTIONS.CUPS),
  definePuzzle(43, 'Soule', 3, 100, 'stamp', "Soule's Scramble", SECTIONS.CUPS),
  definePuzzle(44, 'Thwaite', 2, 100, 'tracer', "Thwaite's Tracer", SECTIONS.CUPS),
  definePuzzle(45, 'Augustine', 3, 100, 'auction', "Augustine's Auction", SECTIONS.CUPS),
  definePuzzle(46, 'Crichton', 3, 100, 'code-grid', "Crichton's Curses", SECTIONS.CUPS),
  definePuzzle(47, 'Huddleston', 5, 100, 'cross-slide', "Huddleston's Horizontals", SECTIONS.CUPS),
  definePuzzle(48, 'Iacobbe', 2, 100, 'inventory', "Iacobbe's Inventory", SECTIONS.CUPS),
  definePuzzle(49, 'Tilton', 3, 100, 'tracer', "Tilton's Tracer", SECTIONS.CUPS),
  definePuzzle(50, 'Vranken', 3, 100, 'sevens', "Vranken's Vendition", SECTIONS.CUPS),
  definePuzzle(51, 'Jeckel', 3, 100, 'jumble', "Jeckel Junction", SECTIONS.CUPS),
  definePuzzle(52, 'Lydia', 3, 100, 'phrase', "Lydia's Literals", SECTIONS.CUPS),
  definePuzzle(53, 'Hyde', 6, 100, 'cross-slide', "Hyde's Horizontals", SECTIONS.CUPS),
  definePuzzle(54, 'Tassel', 4, 100, 'tracer', "Tassel's Tracer", SECTIONS.CUPS),
  definePuzzle(55, 'Weir', 4, 100, 'wager', "Weir's Wager", SECTIONS.CUPS),
  // 56-71: Pentacles
  definePuzzle(56, 'Playfair', 4, 100, 'patchwork', "Playfair's Patchwork", SECTIONS.PENTACLES),
  definePuzzle(57, 'Zachariah', 4, 100, 'slider', "Zachariah's Zigzags", SECTIONS.PENTACLES),
  definePuzzle(58, 'Granville', 4, 100, '4x4', "Granville's Gridlock", SECTIONS.PENTACLES),
  definePuzzle(59, 'Jurchik', 4, 100, 'jumble', "Jurchik Junction", SECTIONS.PENTACLES),
  definePuzzle(60, 'Vanderveer', 4, 100, 'sevens', "Vanderveer's Vendition", SECTIONS.PENTACLES),
  definePuzzle(61, 'Ostheim', 1, 100, 'market', "Ostheim's Orchestration", SECTIONS.PENTACLES),
  definePuzzle(62, 'Iver', 3, 100, 'inventory', "Iver's Inventory", SECTIONS.PENTACLES),
  definePuzzle(63, 'Conklin', 4, 100, 'code-grid', "Conklin's Curses", SECTIONS.PENTACLES),
  definePuzzle(64, 'Skidmore', 4, 100, 'stamp', "Skidmore's Scramble", SECTIONS.PENTACLES),
  definePuzzle(65, 'Ockley', 2, 100, 'market', "Ockley's Orchestration", SECTIONS.PENTACLES),
  definePuzzle(66, 'Laroche', 4, 100, 'phrase', "Laroche's Literals", SECTIONS.PENTACLES),
  definePuzzle(67, 'Hernshaw', 7, 100, 'cross-slide', "Hernshaw's Horizontals", SECTIONS.PENTACLES),
  definePuzzle(68, 'Nisbett', 4, 100, 'concat', "Nisbett's Knowledge", SECTIONS.PENTACLES),
  definePuzzle(69, 'Olmstead', 3, 100, 'market', "Olmstead's Orchestration", SECTIONS.PENTACLES),
  definePuzzle(70, 'Aldridge', 4, 100, 'auction', "Aldridge's Auction", SECTIONS.PENTACLES),
  definePuzzle(71, 'Wickliff', 5, 100, 'wager', "Wickliff's Wager", SECTIONS.PENTACLES),
  // 72: Pre-Finale
  definePuzzle(72, 'Finale', 72, 100, 'pre-Finale', 'The Finale Awaits', SECTIONS.PRE_FINALE),
  // 73-79: Mansion
  definePuzzle(73, 'Pierpont', 1, 100, 'passwords', 'The First ', SECTIONS.MANSION),
  definePuzzle(74, 'Ingraham', 2, 100, 'passwords', 'The Second ', SECTIONS.MANSION),
  definePuzzle(75, 'Rosencrans', 3, 100, 'passwords', 'The Third ', SECTIONS.MANSION),
  definePuzzle(76, 'Abercrombie', 4, 100, 'passwords', 'The Fourth ', SECTIONS.MANSION),
  definePuzzle(77, 'Tremaine', 5, 100, 'passwords', 'The Fifth ', SECTIONS.MANSION),
  definePuzzle(78, 'Ethelbert', 6, 100, 'passwords', 'The Sixth ', SECTIONS.MANSION),
  definePuzzle(79, 'Schermerhorn', 7, 100, 'passwords', 'The Seventh ', SECTIONS.MANSION),
  // 80-81: Finale
  definePuzzle(80, 'Finale', 1, 100, 'F01', 'The Finale', SECTIONS.FINALE),
  definePuzzle(81, 'xxx', 1, 100, '---', 'xxx', SECTIONS.FINALE),
  // 82-86: Unused stubs
  definePuzzle(82, 'xxx', 2, 100, '---', 'xxx', SECTIONS.SPECIAL),
  definePuzzle(83, 'xxx', 3, 100, '---', 'xxx', SECTIONS.SPECIAL),
  definePuzzle(84, 'xxx', 4, 100, '---', 'xxx', SECTIONS.SPECIAL),
  definePuzzle(85, 'xxx', 5, 100, '---', 'xxx', SECTIONS.SPECIAL),
  definePuzzle(86, 'xxx', 6, 100, '---', 'xxx', SECTIONS.SPECIAL),
  // 87: Tokens Help
  definePuzzle(87, 'Tokens-Help', 1, 100, 'tokens-help', 'General Help', SECTIONS.SPECIAL),
  // 88-89: Pre/End High Priestess
  definePuzzle(88, 'Pre-HP', 1, 75, 'Pre-HP', 'The Twelve Tokens', SECTIONS.SPECIAL),
  definePuzzle(89, 'End-HP', 1, 75, 'End-HP', 'The Twelve Tokens', SECTIONS.SPECIAL),
  // 90: High Priestess
  definePuzzle(90, 'HP', 1, 90, 'HP', 'The High Priestess', SECTIONS.SPECIAL),
  // 91: Seven Cups
  definePuzzle(91, 'SevenCups', 1, 100, 'seven-cups', 'The Seven Cups', SECTIONS.SPECIAL),
  // 92-96: Tarot
  definePuzzle(92, 'Tarot-1', 1, 100, 'tarot-1', 'Imperial Tarot', SECTIONS.SPECIAL),
  definePuzzle(93, 'Tarot-2', 2, 100, 'tarot-2', 'Cutthroat Tarot', SECTIONS.SPECIAL),
  definePuzzle(94, 'Tarot-3', 3, 100, 'tarot-3', 'Remedial Tarot', SECTIONS.SPECIAL),
  definePuzzle(95, 'Tarot-4', 4, 100, 'tarot-4', 'Drunken Tarot', SECTIONS.SPECIAL),
  definePuzzle(96, 'Tarot-5', 5, 100, 'tarot-5', 'Kingdom Tarot', SECTIONS.SPECIAL),
  // 97-98: Moon's Map
  definePuzzle(97, "Moon's Map", 1, 100, 'map', "The Moon's Map", SECTIONS.SPECIAL),
  definePuzzle(98, "Moon's Map Solved", 17, 100, 'map-puzzles', "The Moon's Map", SECTIONS.SPECIAL),
  // 99: Game Menus
  definePuzzle(99, 'Game Menus', 1, 70, 'game-menus', 'The Seventh House', SECTIONS.SPECIAL),
  // 100: Tokens
  definePuzzle(100, 'Tokens', 1, 75, 'tokens', 'The Twelve Tokens', SECTIONS.SPECIAL),
  // 101-107: Deliveries
  definePuzzle(101, 'Pierpont', 1, 100, 'DEL', 'The First Delivery', SECTIONS.DEL),
  definePuzzle(102, 'Ingraham', 2, 100, 'DEL', 'The Second Delivery', SECTIONS.DEL),
  definePuzzle(103, 'Rosencrans', 3, 100, 'DEL', 'The Third Delivery', SECTIONS.DEL),
  definePuzzle(104, 'Abercrombie', 4, 100, 'DEL', 'The Fourth Delivery', SECTIONS.DEL),
  definePuzzle(105, 'Tremaine', 5, 100, 'DEL', 'The Fifth Delivery', SECTIONS.DEL),
  definePuzzle(106, 'Ethelbert', 6, 100, 'DEL', 'The Sixth Delivery', SECTIONS.DEL),
  definePuzzle(107, 'Schermerhorn', 7, 100, 'DEL', 'The Seventh Delivery', SECTIONS.DEL),
  // 108-114: Hexes
  definePuzzle(108, 'Pierpont', 1, 100, 'HEX', 'The First Hex', SECTIONS.HEX),
  definePuzzle(109, 'Ingraham', 2, 100, 'HEX', 'The Second Hex', SECTIONS.HEX),
  definePuzzle(110, 'Rosencrans', 3, 100, 'HEX', 'The Third Hex', SECTIONS.HEX),
  definePuzzle(111, 'Abercrombie', 4, 100, 'HEX', 'The Fourth Hex', SECTIONS.HEX),
  definePuzzle(112, 'Tremaine', 5, 100, 'HEX', 'The Fifth Hex', SECTIONS.HEX),
  definePuzzle(113, 'Ethelbert', 6, 100, 'HEX', 'The Sixth Hex', SECTIONS.HEX),
  definePuzzle(114, 'Schermerhorn', 7, 100, 'HEX', 'The Seventh Hex', SECTIONS.HEX),
  // 115-121: Remainders
  definePuzzle(115, 'Pierpont', 1, 100, 'REM', 'The First Remainder', SECTIONS.REM),
  definePuzzle(116, 'Ingraham', 2, 100, 'REM', 'The Second Remainder', SECTIONS.REM),
  definePuzzle(117, 'Rosencrans', 3, 100, 'REM', 'The Third Remainder', SECTIONS.REM),
  definePuzzle(118, 'Abercrombie', 4, 100, 'REM', 'The Fourth Remainder', SECTIONS.REM),
  definePuzzle(119, 'Tremaine', 5, 100, 'REM', 'The Fifth Remainder', SECTIONS.REM),
  definePuzzle(120, 'Ethelbert', 6, 100, 'REM', 'The Sixth Remainder', SECTIONS.REM),
  definePuzzle(121, 'Schermerhorn', 7, 100, 'REM', 'The Seventh Remainder', SECTIONS.REM),
  // 122-128: Connections
  definePuzzle(122, 'Pierpont', 1, 100, 'CON', 'The First Connection', SECTIONS.CON),
  definePuzzle(123, 'Ingraham', 2, 100, 'CON', 'The Second Connection', SECTIONS.CON),
  definePuzzle(124, 'Rosencrans', 3, 100, 'CON', 'The Third Connection', SECTIONS.CON),
  definePuzzle(125, 'Abercrombie', 4, 100, 'CON', 'The Fourth Connection', SECTIONS.CON),
  definePuzzle(126, 'Tremaine', 5, 100, 'CON', 'The Fifth Connection', SECTIONS.CON),
  definePuzzle(127, 'Ethelbert', 6, 100, 'CON', 'The Sixth Connection', SECTIONS.CON),
  definePuzzle(128, 'Schermerhorn', 7, 100, 'CON', 'The Seventh Connection', SECTIONS.CON),
];

// Named constants matching Director globals
export const C = {
  PROLOGUE: 1,
  SWORDS1: 2,
  MOON_MORPH: 3,
  SWORDS2: 18,
  WANDS1: 19,
  WANDS2: 37,
  CUPS1: 38,
  CUPS2: 55,
  PENTACLES1: 56,
  PENTACLES2: 71,
  PRE_FINALE: 72,
  MANSION1: 73,
  MANSION2: 79,
  FINALE: 80,
  HELP_TOKENS: 87,
  PRE_HP: 88,
  END_HP: 89,
  HIGH_PRIESTESS: 90,
  SEVEN_CUPS: 91,
  TAROT1: 92,
  TAROT5: 96,
  MOONS_MAP: 97,
  MOONS_PUZZLES: 98,
  GAME_MENUS: 99,
  TOKENS: 100,
  PUZZLE_TOTAL: 128,
  // Type arrays (1-indexed to match Director globals)
  TAROT: [0, 92, 93, 94, 95, 96],
  WAGER: [0, 5, 18, 35, 55, 71],
  PATCH_PIRATE: [0, 2, 19, 38, 56],
  DEL1: 101, DEL7: 107,
  HEX1: 108, HEX7: 114,
  REM1: 115, REM7: 121,
};

// Section ranges for the navigation UI
export const SECTION_RANGES = [
  { name: 'Prologue', start: 1, end: 1 },
  { name: 'Swords', start: 2, end: 18 },
  { name: 'Wands', start: 19, end: 37 },
  { name: 'Cups', start: 38, end: 55 },
  { name: 'Pentacles', start: 56, end: 71 },
  { name: 'Mansion', start: 73, end: 79 },
  { name: 'Special', start: 87, end: 100 },
];
