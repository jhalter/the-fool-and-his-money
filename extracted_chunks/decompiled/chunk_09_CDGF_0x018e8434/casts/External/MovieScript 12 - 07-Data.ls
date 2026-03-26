global QU, pNum, pVolume, pFrame, pSeven, pWordStat63, menuName, titleName, dataCount, chunkMenuName, cPuzzleTotal, currPuzzle, csGrid, csJumble, csClickCode, csPhrase, csConcat, csLetterSlide, csPatchPirate, csPatchStamp, csMorphText, csHerb, csTracer, csInventory, csSeven, csAuction, csWager, csTarot, csWagerTarot, csPentacle, csPreFinale, csMorph, csCoins, csHalves, csFillin, csPatchSlider, csMansion, csDEL, csHEX, csREM, csCON

on getData MN, N, V, S, TN, spriteName
  dataCount = dataCount + 1
  if dataCount <= cPuzzleTotal then
    menuName[dataCount] = MN
    titleName[dataCount] = TN
    pNum[dataCount] = N
    pVolume[dataCount] = V
    pFrame[dataCount] = S
    if dataCount <= 72 then
      chunkMenuName = chunkMenuName & menuName[dataCount] & "|"
    end if
    if 0 = 666 then
      S = EMPTY
      repeat with x = 1 to MN.length
        if MN.char[x] = "-" then
          S = S & "_"
          next repeat
        end if
        if MN.char[x] = "'" then
          next repeat
        end if
        if MN.char[x] = " " then
          next repeat
        end if
        S = S & MN.char[x]
      end repeat
      _PUT("_e_" & S && "=" && dataCount)
    end if
  else
    showAlert(1, dataCount && "too many of Puzzle Data")
  end if
end

on gatherAllData
  repeat with x = 1 to cPuzzleTotal
    menuName[x] = EMPTY
    pNum[x] = 0
    pVolume[x] = 0
    pFrame[x] = EMPTY
  end repeat
  dataCount = 0
  chunkMenuName = EMPTY
  getData("Prologue", 1, 80, "PRO-1", "The Prologue", "xxx")
  getData("Payne", 1, 100, "patchwork", "Payne's Patchwork", "xxx")
  csPatchPirate[1] = dataCount
  getData("Ursula", 1, 100, "morph-moon", "Ursula's Umbrage", "_morph")
  csMorph[1] = dataCount
  getData("Lawley", 1, 100, "phrase", "Lawley's Literals", "xxx")
  csPhrase[1] = dataCount
  getData("Wyck", 1, 100, "wager", "Wyck's Wager", "_wager")
  csWager[1] = dataCount
  getData("Needham", 1, 100, "concat", "Needham's Knowledge", "xxx")
  csConcat[1] = dataCount
  getData("Garrison", 1, 100, "4x4", "Garrison's Gridlock", "xxx")
  csGrid[1] = dataCount
  getData("Quintin", 1, 100, "coins", "Quintin's Quandary", "xxx")
  csCoins[1] = dataCount
  getData("Moxley", 1, 100, "morph-text", "Moxley's Metamorphosis", "_morph-text")
  csMorphText[1] = dataCount
  getData("Sabina", 1, 100, "stamp", "Sabina's Scramble", "xxx")
  csPatchStamp[1] = dataCount
  getData("Jasper", 1, 100, "jumble", "Jasper Junction", "xxx")
  csJumble[1] = dataCount
  getData("Agar", 1, 100, "auction", "Agar's Auction", "xxx")
  csAuction[1] = dataCount
  getData("McGucken", 2, 100, "morph-text", "McGucken's Metamorphosis", "_morph-text")
  csMorphText[2] = dataCount
  getData("Horton", 1, 100, "cross-slide", "Horton's Horizontals", "xxx")
  csLetterSlide[1] = dataCount
  getData("Caine", 1, 100, "code-grid", "Caine's Curses", "xxx")
  csClickCode[1] = dataCount
  getData("Voorst", 1, 100, "sevens", "Voorst's Vendition", "xxx")
  csSeven[1] = dataCount
  getData("Massey", 3, 100, "morph-text", "Massey's Metamorphosis", "_morph-text")
  csMorphText[3] = dataCount
  getData("Wallop", 2, 100, "wager", "Wallop's Wager", "_wager")
  csWager[2] = dataCount
  getData("Pringle", 2, 100, "patchwork", "Pringle's Patchwork", "xxx")
  csPatchPirate[2] = dataCount
  getData("Buckbee", 1, 100, "halves", "Buckbee's Bones", "xxx")
  csHalves[1] = dataCount
  getData("Radcliff", 1, 100, "herbs", "Radcliff's Reminiscences", "xxx")
  csHerb[1] = dataCount
  getData("Norfolk", 2, 100, "concat", "Norfolk's Knowledge", "xxx")
  csConcat[2] = dataCount
  getData("Gliston", 2, 100, "4x4", "Gliston's Gridlock", "xxx")
  csGrid[2] = dataCount
  getData("Yapp", 1, 100, "fill-in", "Yapp's Yearning", "xxx")
  csFillin[1] = dataCount
  getData("Hayden", 2, 100, "cross-slide", "Hayden's Horizontals", "xxx")
  csLetterSlide[2] = dataCount
  getData("Roderick", 2, 100, "herbs", "Roderick's Reminiscences", "xxx")
  csHerb[2] = dataCount
  getData("Vibbard", 2, 100, "sevens", "Vibbard's Vendition", "xxx")
  csSeven[2] = dataCount
  getData("Lommis", 2, 100, "phrase", "Lommis's Literals", "xxx")
  csPhrase[2] = dataCount
  getData("Cutting", 2, 100, "code-grid", "Cutting's Curses", "xxx")
  csClickCode[2] = dataCount
  getData("Jost", 2, 100, "jumble", "Jost Junction", "xxx")
  csJumble[2] = dataCount
  getData("Rymore", 3, 100, "herbs", "Rymore's Reminiscences", "xxx")
  csHerb[3] = dataCount
  getData("Argyle", 2, 100, "auction", "Argyle's Auction", "xxx")
  csAuction[2] = dataCount
  getData("Snodgrass", 2, 100, "stamp", "Snodgrass's Scramble", "xxx")
  csPatchStamp[2] = dataCount
  getData("Ingram", 1, 100, "inventory", "Ingram's Inventory", "xxx")
  csInventory[1] = dataCount
  getData("Wentworth", 3, 100, "wager", "Wentworth's Wager", "_wager")
  csWager[3] = dataCount
  getData("Riason", 4, 100, "herbs", "Riason's Reminiscences", "xxx")
  csHerb[4] = dataCount
  getData("Handel", 3, 100, "cross-slide", "Handel's Horizontals", "xxx")
  csLetterSlide[3] = dataCount
  getData("Percy", 3, 100, "patchwork", "Percy's Patchwork", "xxx")
  csPatchPirate[3] = dataCount
  getData("Telfair", 1, 100, "tracer", "Telfair's Tracer", "xxx")
  csTracer[1] = dataCount
  getData("Nairne", 3, 100, "concat", "Nairne's Knowledge", "xxx")
  csConcat[3] = dataCount
  getData("Harleigh", 4, 100, "cross-slide", "Harleigh's Horizontals", "xxx")
  csLetterSlide[4] = dataCount
  getData("Girdwood", 3, 100, "4x4", "Girdwood's Gridlock", "xxx")
  csGrid[3] = dataCount
  getData("Soule", 3, 100, "stamp", "Soule's Scramble", "xxx")
  csPatchStamp[3] = dataCount
  getData("Thwaite", 2, 100, "tracer", "Thwaite's Tracer", "xxx")
  csTracer[2] = dataCount
  getData("Augustine", 3, 100, "auction", "Augustine's Auction", "xxx")
  csAuction[3] = dataCount
  getData("Crichton", 3, 100, "code-grid", "Crichton's Curses", "xxx")
  csClickCode[3] = dataCount
  getData("Huddleston", 5, 100, "cross-slide", "Huddleston's Horizontals", "xxx")
  csLetterSlide[5] = dataCount
  getData("Iacobbe", 2, 100, "inventory", "Iacobbe's Inventory", "xxx")
  csInventory[2] = dataCount
  getData("Tilton", 3, 100, "tracer", "Tilton's Tracer", "xxx")
  csTracer[3] = dataCount
  getData("Vranken", 3, 100, "sevens", "Vranken's Vendition", "xxx")
  csSeven[3] = dataCount
  getData("Jeckel", 3, 100, "jumble", "Jeckel Junction", "xxx")
  csJumble[3] = dataCount
  getData("Lydia", 3, 100, "phrase", "Lydia's Literals", "xxx")
  csPhrase[3] = dataCount
  getData("Hyde", 6, 100, "cross-slide", "Hyde's Horizontals", "xxx")
  csLetterSlide[6] = dataCount
  getData("Tassel", 4, 100, "tracer", "Tassel's Tracer", "xxx")
  csTracer[4] = dataCount
  getData("Weir", 4, 100, "wager", "Weir's Wager", "_wager")
  csWager[4] = dataCount
  getData("Playfair", 4, 100, "patchwork", "Playfair's Patchwork", "xxx")
  csPatchPirate[4] = dataCount
  getData("Zachariah", 4, 100, "slider", "Zachariah's Zigzags", "xxx")
  csPatchSlider[1] = dataCount
  getData("Granville", 4, 100, "4x4", "Granville's Gridlock", "xxx")
  csGrid[4] = dataCount
  getData("Jurchik", 4, 100, "jumble", "Jurchik Junction", "xxx")
  csJumble[4] = dataCount
  getData("Vanderveer", 4, 100, "sevens", "Vanderveer's Vendition", "xxx")
  csSeven[4] = dataCount
  getData("Ostheim", 1, 100, "market", "Ostheim's Orchestration", "xxx")
  csPentacle[1] = dataCount
  getData("Iver", 3, 100, "inventory", "Iver's Inventory", "xxx")
  csInventory[3] = dataCount
  getData("Conklin", 4, 100, "code-grid", "Conklin's Curses", "xxx")
  csClickCode[4] = dataCount
  getData("Skidmore", 4, 100, "stamp", "Skidmore's Scramble", "xxx")
  csPatchStamp[4] = dataCount
  getData("Ockley", 2, 100, "market", "Ockley's Orchestration", "xxx")
  csPentacle[2] = dataCount
  getData("Laroche", 4, 100, "phrase", "Laroche's Literals", "xxx")
  csPhrase[4] = dataCount
  getData("Hernshaw", 7, 100, "cross-slide", "Hernshaw's Horizontals", "xxx")
  csLetterSlide[7] = dataCount
  getData("Nisbett", 4, 100, "concat", "Nisbett's Knowledge", "xxx")
  csConcat[4] = dataCount
  getData("Olmstead", 3, 100, "market", "Olmstead's Orchestration", "xxx")
  csPentacle[3] = dataCount
  getData("Aldridge", 4, 100, "auction", "Aldridge's Auction", "xxx")
  csAuction[4] = dataCount
  getData("Wickliff", 5, 100, "wager", "Wickliff's Wager", "_wager")
  csWager[5] = dataCount
  getData("Finale", 72, 100, "pre-Finale", "The Finale Awaits", "_pre-Finale")
  csPreFinale = dataCount
  getData("Pierpont", 1, 100, "passwords", "The First ", "_passwords")
  csMansion[1] = dataCount
  getData("Ingraham", 2, 100, "passwords", "The Second ", "_passwords")
  csMansion[2] = dataCount
  getData("Rosencrans", 3, 100, "passwords", "The Third ", "_passwords")
  csMansion[3] = dataCount
  getData("Abercrombie", 4, 100, "passwords", "The Fourth ", "_passwords")
  csMansion[4] = dataCount
  getData("Tremaine", 5, 100, "passwords", "The Fifth ", "_passwords")
  csMansion[5] = dataCount
  getData("Ethelbert", 6, 100, "passwords", "The Sixth ", "_passwords")
  csMansion[6] = dataCount
  getData("Schermerhorn", 7, 100, "passwords", "The Seventh ", "_passwords")
  csMansion[7] = dataCount
  getData("Finale", 1, 100, "F01", "The Finale", "_finale-01")
  getData("xxx", 1, 100, "---", "xxx")
  getData("xxx", 2, 100, "---", "xxx")
  getData("xxx", 3, 100, "---", "xxx")
  getData("xxx", 4, 100, "---", "xxx")
  getData("xxx", 5, 100, "---", "xxx")
  getData("xxx", 6, 100, "---", "xxx")
  getData("Tokens-Help", 1, 100, "tokens-help", "General Help", "_tokens-help")
  getData("Pre-HP", 1, 75, "Pre-HP", "The Twelve Tokens", "_pre-HP")
  getData("End-HP", 1, 75, "End-HP", "The Twelve Tokens", "_end-HP")
  getData("HP", 1, 90, "HP", "The High Priestess", "_HP")
  getData("SevenCups", 1, 100, "seven-cups", "The Seven Cups", "_seven-cups")
  getData("Tarot-1", 1, 100, "tarot-1", "Imperial Tarot", "_tarot-1")
  csTarot[1] = dataCount
  getData("Tarot-2", 2, 100, "tarot-2", "Cutthroat Tarot", "_tarot-2")
  csTarot[2] = dataCount
  getData("Tarot-3", 3, 100, "tarot-3", "Remedial Tarot", "_tarot-3")
  csTarot[3] = dataCount
  getData("Tarot-4", 4, 100, "tarot-4", "Drunken Tarot", "_tarot-4")
  csTarot[4] = dataCount
  getData("Tarot-5", 5, 100, "tarot-5", "Kingdom Tarot", "_tarot-5")
  csTarot[5] = dataCount
  getData("Moon's Map", 1, 100, "map", "The Moon's Map", "_map")
  getData("Moon's Map Solved", 17, 100, "map-puzzles", "The Moon's Map", "_map-puzzles")
  getData("Game Menus", 1, 70, "game-menus", "The Seventh House", "_game-menu")
  getData("Tokens", 1, 75, "tokens", "The Twelve Tokens", "_tokens")
  getData("Pierpont", 1, 100, "DEL", "The First Delivery", "_DEL-stub")
  csDEL[1] = dataCount
  getData("Ingraham", 2, 100, "DEL", "The Second Delivery", "_DEL-stub")
  csDEL[2] = dataCount
  getData("Rosencrans", 3, 100, "DEL", "The Third Delivery", "_DEL-stub")
  csDEL[3] = dataCount
  getData("Abercrombie", 4, 100, "DEL", "The Fourth Delivery", "_DEL-stub")
  csDEL[4] = dataCount
  getData("Tremaine", 5, 100, "DEL", "The Fifth Delivery", "_DEL-stub")
  csDEL[5] = dataCount
  getData("Ethelbert", 6, 100, "DEL", "The Sixth Delivery", "_DEL-stub")
  csDEL[6] = dataCount
  getData("Schermerhorn", 7, 100, "DEL", "The Seventh Delivery", "_DEL-stub")
  csDEL[7] = dataCount
  getData("Pierpont", 1, 100, "HEX", "The First Hex", "_HEX-stub")
  csHEX[1] = dataCount
  getData("Ingraham", 2, 100, "HEX", "The Second Hex", "_HEX-stub")
  csHEX[2] = dataCount
  getData("Rosencrans", 3, 100, "HEX", "The Third Hex", "_HEX-stub")
  csHEX[3] = dataCount
  getData("Abercrombie", 4, 100, "HEX", "The Fourth Hex", "_HEX-stub")
  csHEX[4] = dataCount
  getData("Tremaine", 5, 100, "HEX", "The Fifth Hex", "_HEX-stub")
  csHEX[5] = dataCount
  getData("Ethelbert", 6, 100, "HEX", "The Sixth Hex", "_HEX-stub")
  csHEX[6] = dataCount
  getData("Schermerhorn", 7, 100, "HEX", "The Seventh Hex", "_HEX-stub")
  csHEX[7] = dataCount
  getData("Pierpont", 1, 100, "REM", "The First Remainder", "_REM-stub")
  csREM[1] = dataCount
  getData("Ingraham", 2, 100, "REM", "The Second Remainder", "_REM-stub")
  csREM[2] = dataCount
  getData("Rosencrans", 3, 100, "REM", "The Third Remainder", "_REM-stub")
  csREM[3] = dataCount
  getData("Abercrombie", 4, 100, "REM", "The Fourth Remainder", "_REM-stub")
  csREM[4] = dataCount
  getData("Tremaine", 5, 100, "REM", "The Fifth Remainder", "_REM-stub")
  csREM[5] = dataCount
  getData("Ethelbert", 6, 100, "REM", "The Sixth Remainder", "_REM-stub")
  csREM[6] = dataCount
  getData("Schermerhorn", 7, 100, "REM", "The Seventh Remainder", "_REM-stub")
  csREM[7] = dataCount
  getData("Pierpont", 1, 100, "CON", "The First Connection", "xxx")
  csCON[1] = dataCount
  getData("Ingraham", 2, 100, "CON", "The Second Connection", "xxx")
  csCON[2] = dataCount
  getData("Rosencrans", 3, 100, "CON", "The Third Connection", "xxx")
  csCON[3] = dataCount
  getData("Abercrombie", 4, 100, "CON", "The Fourth Connection", "xxx")
  csCON[4] = dataCount
  getData("Tremaine", 5, 100, "CON", "The Fifth Connection", "xxx")
  csCON[5] = dataCount
  getData("Ethelbert", 6, 100, "CON", "The Sixth Connection", "xxx")
  csCON[6] = dataCount
  getData("Schermerhorn", 7, 100, "CONs", "The Seventh Connection", "xxx")
  csCON[7] = dataCount
  repeat with x = 1 to 5
    csWagerTarot[x] = csWager[x]
  end repeat
end

on initWordStat63
  pWordStat63[1] = "000000000000001000000000000000010010001100010000100000000010100"
  pWordStat63[2] = "000000001000010000001100000010000010100000000000000000000100000"
  pWordStat63[3] = "000000000000000000001000000000000100100110010001100100001000000"
  pWordStat63[4] = "000000000011000001010001100010000000000000101000000000101001001"
end

on grabWordStat63
  pSeven = "-"
  repeat with x = 1 to 4
    if currPuzzle = csSeven[x] then
      pSeven = pWordStat63[x]
    end if
  end repeat
  repeat with x = 1 to 4
    if currPuzzle = csJumble[x] then
      pSeven = pWordStat63[x]
    end if
  end repeat
  repeat with x = 1 to 3
    if currPuzzle = csMorphText[x] then
      pSeven = pWordStat63[1]
    end if
  end repeat
  if pSeven.length = 63 then
  end if
end

on saveWordStat63
  chunk = misc_GetFlash("pSeven", 0)
  if chunk.length = 63 then
    repeat with x = 1 to 4
      if currPuzzle = csJumble[x] then
        pWordStat63[x] = chunk
      end if
    end repeat
    repeat with x = 1 to 3
      if currPuzzle = csMorphText[x] then
        pWordStat63[1] = chunk
      end if
    end repeat
  end if
end
