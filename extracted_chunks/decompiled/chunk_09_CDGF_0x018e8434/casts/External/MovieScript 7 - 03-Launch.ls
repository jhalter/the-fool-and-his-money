global theDirectorVersion, cPrologue, cPreFinale, cFinale, cMoonMorph, cMoonsMap, cMoonsPuzzles, cGameMenus, cTokens, cPreHP, cEndHP, cHighPriestess, cMansion1, cMansion2, cPuzzleTotal, cRevGameNum, cNewGameNum, cFileTotal, cTarotTotal, cTypeCurrPuzzle, cSevenCups, cTarotCards, pNum, pStat, pData, pMiscellaneous, pWindowCode, pFrame, pTransition, fName, fData, token1, token2, token3, prefTotal, prefChunk, CR, chunkMenuStat, chunkMenuName, currGame, lastPuzzle, currPuzzle, nextPuzzle, loadPuzzleCount, csSeven, csWager, csTarot, csWagerTarot, csDEL, requestBlock, playMode, menuName, pmZero, theDataStatus, cTestIO, cSavedGamesDirectory, activity_Array, activity_Count, activity_Total, activity_Launch, _Read_Only_Mansion

on readGameFile N
  if N = 0 then
    exit
  end if
  currGame = N
  parseGameFile(currGame)
  putRevertFoolFile(currGame)
end

on launchGame N, b
  putLastGamePref(N)
  readGameFile(currGame)
  if b = 1 then
    initLaunch(currPuzzle, 0)
  end if
end

on initLaunch N, savePuzzle
  nextPuzzle = N
  if (nextPuzzle < 1) or (nextPuzzle > cPuzzleTotal) then
    if lastPuzzle = cTokens then
      nextPuzzle = cGameMenus
    else
      nextPuzzle = cTokens
    end if
  end if
  if savePuzzle = 0 then
    executeLaunch()
  else
    misc_SetFlash("gExitPending", 1)
    _Set_Save_Mode(1, 0)
  end if
end

on executeLaunch
  requestBlock = EMPTY
  if nextPuzzle = cTokens then
    _Launch_Tokens(0, 0)
  else
    launchPuzzle(nextPuzzle)
  end if
  nextPuzzle = 0
end

on _Launch_Tokens quitFromOther, startTheGame
  init_Window_Title("The Twelve Tokens")
  noInterface()
  cTypeCurrPuzzle = 1
  if sprite(1).memberNum > 0 then
    sprite(1).visible = 1
  end if
  lastPuzzle = exceptionPuzzleLaunch(currPuzzle, 0)
  currPuzzle = lastPuzzle
  pNum[cTokens] = currGame
  pStat[cTokens] = 0
  if currGame > 0 then
    setTokenDescription(currGame)
    if quitFromOther = 0 then
      if startTheGame = 0 then
        if compareLastSavedGameData() = 0 then
          pStat[cTokens] = 1
          copyTokens(cRevGameNum, currGame)
        end if
      end if
    else
      pStat[cTokens] = 999
    end if
  end if
  pMiscellaneous = getTokenStrings()
  unloadLastPuzzle()
  _movie.go(pFrame[cTokens])
end

on getTokenStrings
  S = EMPTY
  repeat with x = 1 to cFileTotal
    S = S & token1[x] & "|" & token2[x] & "|" & token3[x] & "|"
  end repeat
  return S
end

on launchPuzzle N
  noInterface()
  cTypeCurrPuzzle = 2
  loadPuzzleCount = 0
  lastPuzzle = exceptionPuzzleLaunch(currPuzzle, 0)
  currPuzzle = exceptionPuzzleLaunch(N, 0)
  init_Window_Title("-")
  pMiscellaneous = EMPTY
  if theDataStatus = 1 then
    if (lastPuzzle = cGameMenus) and (currPuzzle <> cGameMenus) and (pollSpecialKeys() = "111") then
      pStat[currPuzzle] = 0
      pData[currPuzzle] = "empty"
      _PUT("puzzle" && currPuzzle && "cleared")
    end if
  end if
  updateGameStats(currGame)
  if ((currPuzzle >= cMansion1) and (currPuzzle <= cMansion2)) = 0 then
    _Read_Only_Mansion = 0
  end if
  case currPuzzle of
    cPrologue:
      misc_HidePuzzleSprites()
      pTransition = 9
    cPreHP:
      pNum[cPreHP] = currGame
      pMiscellaneous = getTokenStrings()
    cEndHP:
      pNum[cEndHP] = currGame
      pMiscellaneous = getTokenStrings()
    cMoonsMap:
      if pStat[cMoonsMap] < 100 then
        pMiscellaneous = tallyMapPieces()
      else
        if lastPuzzle = cMoonsMap then
          lastPuzzle = cMoonsPuzzles
        end if
        currPuzzle = cMoonsPuzzles
      end if
    cMoonsPuzzles:
      if lastPuzzle = cMoonsMap then
        lastPuzzle = cMoonsPuzzles
      end if
    cPreFinale:
      if (pStat[cMoonsPuzzles] = 700) and (pStat[cSevenCups] = 700) and (pStat[cPreFinale] < 100) then
        pStat[cPreFinale] = 100
      end if
    cGameMenus:
      pMiscellaneous = chunkMenuName & pWindowCode & "|"
    otherwise:
      if (currPuzzle >= cMansion1) and (currPuzzle <= cMansion2) then
        launchMansionPuzzle()
      else
        repeat with x = 1 to 5
          if currPuzzle = csWager[x] then
            currPuzzle = csWagerTarot[x]
          end if
        end repeat
      end if
      if (currPuzzle >= csDEL[1]) and (currPuzzle <= csDEL[7]) then
        pMiscellaneous = pWindowCode
      end if
  end case
  unloadLastPuzzle()
  if pTransition > 0 then
    _movie.puppetTransition(pTransition, 1, 20, 0)
    pTransition = 0
  end if
  _PUT("launch-" & currPuzzle & "-" & pStat[currPuzzle])
  if activity_Launch = 0 then
    activity_Store(currPuzzle)
  else
    activity_Launch = 0
  end if
  _movie.go(pFrame[currPuzzle])
end

on unloadLastPuzzle
  misc_StopSndFlash()
end

on activity_Init
  repeat with x = 1 to 1000
    activity_Array[x] = 0
  end repeat
end

on activity_Store nextPZ
  prevPZ = 0
  if activity_Count > 0 then
    prevPZ = activity_Array[activity_Count]
  end if
  if prevPZ = nextPZ then
    exit
  end if
  activity_Count = activity_Count + 1
  if activity_Count = 1001 then
    repeat with x = 1 to 900
      activity_Array[x] = activity_Array[x + 100]
    end repeat
    repeat with x = 901 to 1000
      activity_Array[x] = 0
    end repeat
    activity_Count = 901
  end if
  if activity_Count < activity_Total then
    if activity_Array[activity_Count] <> nextPZ then
      repeat with x = activity_Count to 1000
        activity_Array[x] = 0
      end repeat
      activity_Total = activity_Count
    end if
  else
    activity_Array[activity_Count] = nextPZ
    activity_Total = activity_Count
  end if
end

on activity_Check
  if activity_Array[activity_Count] = 0 then
    return 0
  end if
  if activity_Array[activity_Count] = cPrologue then
    return 0
  end if
  if activity_Array[activity_Count] = cFinale then
    return 0
  end if
  return 1
end

on activity_Prev
  if activity_Count > 1 then
    activity_Launch = 1
    repeat while activity_Count > 0
      activity_Count = activity_Count - 1
      if activity_Count = 0 then
        activity_Count = 1
        return 0
      end if
      if activity_Array[activity_Count] = 0 then
        return 0
      end if
      if activity_Check() = 1 then
        return activity_Array[activity_Count]
      end if
    end repeat
  end if
  return 0
end

on activity_Next
  if activity_Count < activity_Total then
    activity_Launch = 1
    repeat while activity_Count <= activity_Total
      activity_Count = activity_Count + 1
      if activity_Count > activity_Total then
        activity_Count = activity_Total
        return 0
      end if
      if activity_Array[activity_Count] = 0 then
        return 0
      end if
      if activity_Check() = 1 then
        return activity_Array[activity_Count]
      end if
    end repeat
  end if
  return 0
end

on getPrefList
  FN = cSavedGamesDirectory & "13-Book of Thoth.txt"
  cTestIO.openfile(FN, 1)
  chunk = cTestIO.readFile()
  cTestIO.closeFile()
  if chunk = VOID then
    setPrefList()
  else
    if zipTest(chunk) = 0 then
      setPrefList()
    else
      chunk = decodeZip(chunk)
      repeat with x = 1 to prefTotal + 1
        prefChunk[x] = line (x + 1) of chunk
      end repeat
      repeat with x = 1 to prefTotal + 1
      end repeat
    end if
  end if
end

on setPrefList
  chunk = getFileKeyWord() & CR
  repeat with x = 1 to prefTotal
    chunk = chunk & prefChunk[x] & CR
  end repeat
  chunk = encodeZip(chunk)
  FN = cSavedGamesDirectory & "13-Book of Thoth.txt"
  cTestIO.openfile(FN, 0)
  delete cTestIO
  createFile(cTestIO, FN)
  cTestIO.openfile(FN, 0)
  setPosition(cTestIO, 0)
  cTestIO.writeString(chunk)
  cTestIO.closeFile()
end

on putAltGamePref GN, FN
  prefChunk[GN] = FN
  setPrefList()
end

on putLastGamePref GN
  currGame = GN
  prefChunk[prefTotal - 1] = misc_PadNumber(currGame, 0, 0)
  setPrefList()
end

on getLastGamePref
  return integer(prefChunk[prefTotal - 1])
end
