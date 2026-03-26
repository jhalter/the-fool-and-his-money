global cSwords1, cSwords2, cWands1, cWands2, cCups1, cCups2, cPentacles1, cPentacles2, cMansion1, cMansion2, cPrologue, cPuzzleTotal, cMenuPuzzles, cHighPriestess, cSevenCups, cPreHP, cMoonMorph, cMoonsMap, cMoonsPuzzles, cGameMenus, cTokens, cPreFinale, cFinale, cHelpTokens, pNum, pStat, pData, pFrame, pVolume, pDone, chunkMenuStat, pMiscellaneous, pWindowCode, pInfo, pSeven, pWordStat63, pSwords, pWands, pCups, pPentacles, pTotalSwords, pTotalWands, pTotalCups, pTotalPentacles, token1, token2, token3, menuStat, currGame, currPuzzle, lastPuzzle, CR, theDataStatus, csGrid, csJumble, csClickCode, csPhrase, csConcat, csLetterSlide, csPatchPirate, csPatchStamp, csMorphText, csHerb, csTracer, csInventory, csSeven, csAuction, csWager, csTarot, csWagerTarot, csPentacle, csFillin, csPreFinale, thePuzzlesSolved, _Read_Only_Mansion, csDEL, csHEX, csREM, pPage

on updateGameStats GN
  if theDataStatus = 1 then
  end if
  if currPuzzle < cGameMenus then
    if pStat[currPuzzle] < 2 then
      pStat[currPuzzle] = 2
    end if
  end if
  if theDataStatus = 0 then
    if pWindowCode = EMPTY then
      if calcMapPiecesRemaining(3) > 4 then
        makeWindowCode()
      end if
    end if
  else
    pWindowCode = "12345671111111"
    if (currPuzzle = cGameMenus) and (pStat[cGameMenus] = 20) then
      S = pWindowCode.char[1]
      repeat with x = 2 to 7
        S = S & "-" & pWindowCode.char[x]
      end repeat
      _PUT(S)
      S = pWindowCode.char[8]
      repeat with x = 9 to 14
        S = S & "-" & pWindowCode.char[x]
      end repeat
      _PUT(S)
    end if
  end if
  puzzAvail = 0
  thePuzzlesSolved = 0
  repeat with x = cSwords1 to cPentacles2
    if pStat[x] > 0 then
      puzzAvail = puzzAvail + 1
    end if
    if pStat[x] >= 100 then
      thePuzzlesSolved = thePuzzlesSolved + 1
    end if
  end repeat
  puzzReady = thePuzzlesSolved - 3
  if puzzReady > 0 then
    repeat with x = cWands1 to cPentacles2
      if puzzReady = 0 then
        exit repeat
      else
        if pStat[x] = 0 then
          if puzzReady > 0 then
            pStat[x] = 1
          end if
        end if
      end if
      puzzReady = puzzReady - 1
    end repeat
  end if
  if pStat[cGameMenus] >= 95 then
    if pStat[cSevenCups] < 100 then
      pStat[cGameMenus] = 95
    else
      pStat[cGameMenus] = 100
    end if
  end if
  case pStat[cGameMenus] of
    0:
      repeat with x = cSwords1 to cSwords2
        if pStat[x] < 1 then
          pStat[x] = 1
        end if
      end repeat
      _Set_Game_Menu_Status(10)
    10:
      updateMansionWindows(1, 0, 1)
      updateForMansionPhase(100, 20)
    20:
    30:
      updateMansionWindows(2, 100, 101)
      updateForMansionPhase(200, 60)
      highest = 0
      repeat with x = cMansion1 to cMansion2
        if pStat[x] > highest then
          highest = pStat[x]
        end if
      end repeat
      if highest >= 150 then
        repeat with x = cMansion1 to cMansion2
          if (pStat[x] > 100) and (pStat[x] < 150) then
            pStat[x] = 150
          end if
        end repeat
      else
        if highest = 108 then
          repeat with x = cMansion1 to cMansion2
            if (pStat[x] > 100) and (pStat[x] < 108) then
              pStat[x] = 108
            end if
          end repeat
        end if
      end if
    60:
    70, 75:
      if pStat[cGameMenus] = 70 then
        if pStat[cHighPriestess] >= 100 then
          pStat[cGameMenus] = 75
        end if
      end if
      updateMansionWindows(3, 200, 201)
      updateForMansionBeam()
    80:
    90:
    95:
      updateMansionWindows(4, 300, 301)
    100:
  end case
  if pStat[cPrologue] = 0 then
    pStat[cPrologue] = 1
  end if
  if pStat[csPatchPirate[1]] >= 400 then
    pStat[csPatchPirate[4]] = 700
  end if
  _Update_Solved_Tarot()
  if pStat[cMoonsMap] < 100 then
    PR = calcMapPiecesRemaining(3)
    if PR > 0 then
      pStat[cMoonsMap] = 2
      pStat[cMoonsPuzzles] = 0
    end if
  end if
  if pStat[cGameMenus] < 95 then
    pStat[cSevenCups] = 0
  end if
  if pStat[cGameMenus] = 95 then
    if pStat[cSevenCups] > 20 then
      pStat[cSevenCups] = 10
    end if
  end if
  if (pStat[cMoonsPuzzles] < 700) or (pStat[cSevenCups] < 700) then
    if pStat[cPreFinale] = 0 then
      pStat[cPreFinale] = 2
    end if
    if pStat[cPreFinale] > 10 then
      pStat[cPreFinale] = 10
    end if
    pData[cPreFinale] = "empty"
    pStat[cFinale] = 0
  else
    if pStat[cPreFinale] < 100 then
      pStat[cPreFinale] = 100
    end if
  end if
  grabWordStat63()
  setTokenDescription(GN)
  CP = currPuzzle
  c3 = CP & " of 100"
  c4 = EMPTY
  c5 = EMPTY
  c6 = pSwords[CP] && "of" && pTotalSwords && "Swords"
  c7 = pWands[CP] && "of" && pTotalWands && "Wands"
  c8 = pCups[CP] && "of" && pTotalCups && "Cups"
  c9 = pPentacles[CP] && "of" && pTotalPentacles && "Pentacles"
  if (CP >= cSwords1) and (CP <= cSwords2) then
    c4 = CP - cSwords1 + 1 && "of" && cSwords2 - cSwords1 + 1 && "SWORDS"
  end if
  if (CP >= cWands1) and (CP <= cWands2) then
    c4 = CP - cWands1 + 1 && "of" && cWands2 - cWands1 + 1 && "WANDS"
  end if
  if (CP >= cCups1) and (CP <= cCups2) then
    c4 = CP - cCups1 + 1 && "of" && cCups2 - cCups1 + 1 && "CUPS"
  end if
  if (CP >= cPentacles1) and (CP <= cPentacles2) then
    c4 = CP - cPentacles1 + 1 && "of" && cPentacles2 - cPentacles1 + 1 && "PENTACLES"
  end if
  if (CP >= cMansion1) and (CP <= cMansion2) then
    c4 = CP - cMansion1 + 1 && "of" && cMansion2 - cMansion1 + 1 && "MANSION"
  end if
  if menuStat[CP] >= 3 then
    c5 = "--- SOLVED ---"
  end if
  if GN = 0 then
    exit
  end if
  pInfo = c3 & CR & c4 & CR & token1[GN] & CR & token2[GN] & CR & c5 & CR & c6 & CR & c7 & CR & c8 & CR & c9
  updatePages()
end

on makeWindowCode
  R = list()
  repeat with x = 1 to 7
    R[x] = x
  end repeat
  repeat with x = 1 to 7
    N = random(7)
    r1 = R[x]
    r2 = R[N]
    R[x] = r2
    R[N] = r1
  end repeat
  pWindowCode = EMPTY
  repeat with x = 1 to 7
    pWindowCode = pWindowCode & R[x]
  end repeat
  repeat with x = 1 to 7
    R[x] = random(4)
  end repeat
  repeat with x = 1 to 7
    pWindowCode = pWindowCode & R[x]
  end repeat
end

on updateMansionWindows which, closeW, openW
  windowStat = []
  case which of
    1:
      base = 17
    2:
      base = 17 + 19
    3:
      base = 17 + 19 + 18
    4:
      base = 17 + 19 + 18 + 16
  end case
  repeat with x = 7 down to 1
    windowStat[x] = base
    base = base - 2
  end repeat
  repeat with x = 1 to 7
    N = cMansion1 + (x - 1)
    if thePuzzlesSolved < windowStat[x] then
      pStat[N] = closeW
      next repeat
    end if
    if pStat[N] < openW then
      pStat[N] = openW
    end if
  end repeat
end

on updateForMansionPhase goal, stat
  ct = 0
  repeat with x = cMansion1 to cMansion2
    if pStat[x] = goal then
      ct = ct + 1
    end if
  end repeat
  if ct = 7 then
    _Set_Game_Menu_Status(stat)
  end if
end

on updateForMansionBeam
  if pStat[cHighPriestess] >= 100 then
    ct = 0
    repeat with x = cMansion1 to cMansion2
      if pStat[x] = 300 then
        ct = ct + 1
      end if
    end repeat
    if ct < 7 then
      _Set_Game_Menu_Status(75)
    else
      _Set_Game_Menu_Status(80)
    end if
  end if
end

on updateStatCompendiumToMoonMenu
  _Set_Game_Menu_Status(94)
  repeat with x = cMansion1 to cMansion2
    pStat[x] = 300
  end repeat
end

on _Set_Game_Menu_Status N
  if pStat[cGameMenus] < N then
    pStat[cGameMenus] = N
  end if
end

on _Update_Solved_Tarot
  repeat with x = 1 to 5
    if pData[csTarot[x]] = 100 then
      if pData[csWager[x]] < 100 then
        pData[csWager[x]] = 100
      end if
    end if
  end repeat
end

on exceptionPuzzleLaunch N, b
  if N = cFinale then
    if lastPuzzle = cFinale then
      N = cPreFinale
    end if
  end if
  if N = cTokens then
    if lastPuzzle <> cTokens then
      N = lastPuzzle
    else
      N = cGameMenus
    end if
  end if
  if (N < 1) or (N > cPuzzleTotal) then
    N = cGameMenus
  end if
  if b = 1 then
    if N = cPrologue then
      N = cGameMenus
    end if
    if N = cFinale then
      N = cPreFinale
    end if
  end if
  if (N = cPreHP) and (pStat[cPreHP] = 100) then
    N = cHighPriestess
  end if
  if (N = cHighPriestess) and (pStat[cHighPriestess] = 100) then
    N = cMoonMorph
  end if
  return N
end

on launchMansionPuzzle
  repeat with x = cMansion1 to cMansion2
    case pStat[cGameMenus] of
      0, 10, 20:
        pVolume[x] = 100
        pFrame[x] = "passwords"
        pMiscellaneous = pWindowCode
      30, 60:
        pVolume[x] = 100
        pFrame[x] = "hex-words"
      70, 75, 80, 90:
        pVolume[x] = 100
        pFrame[x] = "unnecessary"
        pMiscellaneous = pStat[cGameMenus]
      95, 100:
        pVolume[x] = 100
        pFrame[x] = "connects"
    end case
  end repeat
end

on putMenuStatsFromFlash
  repeat with x = 1 to cPuzzleTotal
    if (x < cMansion1) or (x > cMansion2) then
      if pStat[x] = 0 then
        menuStat[x] = 0
        next repeat
      end if
      if pStat[x] = 1 then
        menuStat[x] = 1
        next repeat
      end if
      if pStat[x] < 100 then
        menuStat[x] = 2
        next repeat
      end if
      if pStat[x] < 200 then
        menuStat[x] = 3
        next repeat
      end if
      if pStat[x] < 300 then
        menuStat[x] = 4
        next repeat
      end if
      if pStat[x] < 400 then
        menuStat[x] = 5
        next repeat
      end if
      if pStat[x] < 500 then
        menuStat[x] = 6
        next repeat
      end if
      if pStat[x] < 600 then
        menuStat[x] = 7
        next repeat
      end if
      if pStat[x] < 700 then
        menuStat[x] = 8
        next repeat
      end if
      menuStat[x] = 9
    end if
  end repeat
  repeat with x = cMansion1 to cMansion2
    case pStat[cGameMenus] of
      0, 10, 20:
        if pStat[x] = 0 then
          menuStat[x] = 0
        else
          if pStat[x] = 1 then
            menuStat[x] = 1
          else
            if pStat[x] < 100 then
              menuStat[x] = 2
            else
              if pStat[x] = 100 then
                menuStat[x] = 3
              end if
            end if
          end if
        end if
      30, 60:
        if pStat[x] < 100 then
          pStat[x] = 100
        end if
        if pStat[x] = 100 then
          menuStat[x] = 0
        else
          if pStat[x] <= 110 then
            menuStat[x] = 1
          else
            if pStat[x] < 200 then
              menuStat[x] = 2
            else
              if pStat[x] = 200 then
                menuStat[x] = 3
              end if
            end if
          end if
        end if
      70, 75, 80, 90:
        if pStat[x] < 200 then
          pStat[x] = 200
        end if
        if pStat[x] = 200 then
          menuStat[x] = 0
        else
          if pStat[x] <= 201 then
            menuStat[x] = 1
          else
            if pStat[x] < 300 then
              menuStat[x] = 2
            else
              if pStat[x] = 300 then
                menuStat[x] = 3
              end if
            end if
          end if
        end if
      94, 95, 100:
        if pStat[x] < 300 then
          pStat[x] = 300
        end if
        if pStat[x] = 300 then
          menuStat[x] = 0
        else
          if pStat[x] <= 310 then
            menuStat[x] = 1
          else
            if pStat[x] < 400 then
              menuStat[x] = 2
            else
              menuStat[x] = 3
            end if
          end if
        end if
    end case
  end repeat
  chunkMenuStat = EMPTY
  repeat with x = 1 to cPuzzleTotal
    chunkMenuStat = chunkMenuStat & string(menuStat[x])
  end repeat
end

on getMenuStatsFromFlash
  S = misc_GetFlash("gMenuUpdate", 0)
  if S.length < 100 then
    return 
  end if
  if S.length = 100 then
    repeat with x = 101 to cPuzzleTotal
      S = S & "3"
    end repeat
  end if
  if S <> EMPTY then
    if (S = chunkMenuStat) or (S.char[1..3] = "NaN") or (chunkMenuStat = EMPTY) then
    else
      repeat with x = 1 to cPuzzleTotal
        m1 = integer(chunkMenuStat.char[x])
        m2 = integer(S.char[x])
        if m2 > m1 then
          case m2 of
            3:
              pStat[x] = 100
            4:
              pStat[x] = 200
            5:
              pStat[x] = 300
            6:
              pStat[x] = 400
            7:
              pStat[x] = 500
            8:
              pStat[x] = 600
            9:
              pStat[x] = 700
          end case
        end if
      end repeat
    end if
  end if
end

on calcMapPiecesRemaining byMenuStat
  putMenuStatsFromFlash()
  T = 0
  repeat with x = cSwords1 to cPentacles2
    if menuStat[x] < byMenuStat then
      T = T + 1
    end if
  end repeat
  repeat with x = cMansion1 to cMansion2
    if pStat[x] < 400 then
      T = T + 1
    end if
  end repeat
  return T
end

on tallyMapPieces
  ct = 0
  S = EMPTY
  repeat with x = cSwords1 to cPentacles2
    if pStat[x] < 100 then
      S = S & "0"
      next repeat
    end if
    ct = ct + 1
    S = S & "1"
  end repeat
  repeat with x = cMansion1 to cMansion2
    if pStat[x] < 400 then
      S = S & "0"
      next repeat
    end if
    ct = ct + 1
    S = S & "1"
  end repeat
  return S
end

on setTokenDescription GN
  if GN = 0 then
    exit
  end if
  putMenuStatsFromFlash()
  newGameStat = 0
  virgin = 0
  solved = 0
  repeat with x = cSwords1 to cPentacles2
    if menuStat[x] >= 2 then
      virgin = virgin + 1
    end if
    if menuStat[x] >= 3 then
      solved = solved + 1
    end if
  end repeat
  repeat with x = cMansion1 to cMansion2
    if menuStat[x] >= 2 then
      virgin = virgin + 1
    end if
    if pStat[x] >= 400 then
      solved = solved + 1
    end if
  end repeat
  if menuStat[cMoonsMap] >= 2 then
    virgin = virgin + 1
  end if
  if solved = 0 then
    if virgin = 0 then
      newGameStat = 1
    end if
    c1 = "77 Bewitchments remain"
    c2 = "and the Moon's Map is a mystery."
  end if
  if (solved > 0) and (solved < 77) then
    if solved < 76 then
      c1 = 77 - solved && "Bewitchments remain"
    else
      c1 = "1 Bewitchment remains"
    end if
    c2 = "and the Moon's Map is muddled."
  end if
  if solved = 77 then
    if menuStat[cMoonsMap] < 3 then
      c1 = "All the pieces are gathered"
      c2 = "yet the Moon's Map is not whole."
    else
      if menuStat[cMoonsPuzzles] < 9 then
        c1 = "The Moon's Map is whole"
        c2 = "yet Spirits and Innominates await."
      else
        if menuStat[cSevenCups] < 9 then
          c1 = "The Moon's Map is complete"
          c2 = "yet the Seven Cups are not restored."
        else
          if menuStat[cPreFinale] < 9 then
            c1 = "The Moon's Map is complete"
            c2 = "and the Finale awaits."
          else
            if menuStat[cFinale] < 9 then
              c1 = "The Moon's Map is complete."
              c2 = "The Book of Thoth remains hidden."
            else
              c1 = "The Fool has earned the Gift of Prophecy."
              c2 = "The Book of Thoth is entombed once again."
            end if
          end if
        end if
      end if
    end if
  end if
  token1[GN] = c1
  token2[GN] = c2
  token3[GN] = newGameStat
end

on updatePages
  repeat with x = csDEL[1] to csDEL[7]
    pPage[x] = 2
  end repeat
  repeat with x = csHEX[1] to csHEX[7]
    pPage[x] = 4
  end repeat
  repeat with x = csREM[1] to csREM[7]
    pPage[x] = 6
  end repeat
  repeat with x = cMansion1 to cMansion2
    if pStat[x] < 100 then
      pPage[x] = 1
      next repeat
    end if
    if pStat[x] = 100 then
      pPage[x] = 2
      next repeat
    end if
    if pStat[x] < 200 then
      pPage[x] = 3
      next repeat
    end if
    if pStat[x] = 200 then
      pPage[x] = 4
      next repeat
    end if
    if pStat[x] < 300 then
      pPage[x] = 5
      next repeat
    end if
    if pStat[x] = 300 then
      pPage[x] = 6
      next repeat
    end if
    if pStat[x] < 400 then
      pPage[x] = 7
      next repeat
    end if
    pPage[x] = 8
  end repeat
end

on _Help_Tokens_Exception N
  if N = cHelpTokens then
    return cGameMenus
  end if
  return N
end
