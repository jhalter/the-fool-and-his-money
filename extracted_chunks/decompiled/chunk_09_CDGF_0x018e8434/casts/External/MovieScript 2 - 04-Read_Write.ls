global theDirectorVersion, CR, createNewGameData, playMode, pmPlay, pmClick, pmSave, _Save_Stat, _Save_Type, pClickToContinue, cPuzzleTotal, cSavePuzzleTotal, cNewGameNum, cTarotTotal, cRevGameNum, cOpenGameNum, c_Interface_Mode, cFileTotal, cGameDirectory, cXtraDirectory, cSaveDirectoryCliff, cFileIO, cTestIO, prefNumber, cPreHP, cHighPriestess, cTarotCards, cScrollSN, cHelpSN, cTokens, cPreFinale, cHelpTokens, cPrologue, cFinale, tName, fName, fData, pStat, pData, pDone, pPage, pSwords, pWands, pCups, pPentacles, pWindowCode, pWordStat63, token1, token2, token3, currGame, currPuzzle, prefTotal, prefChunk, grab1, grab2, grab3, grab4, aaaa1, aaaa2, aaaa3, aaaa4, bbbb1, bbbb2, bbbb3, bbbb4, cccc1, cccc2, cccc3, cccc4, csWager, csWagerTarot

on calc_File_Name_From_Path FN
  S = EMPTY
  L = FN.length
  repeat with x = L down to 1
    if FN.char[x] <> "\" then
      S = FN.char[x] & S
      next repeat
    end if
    exit repeat
  end repeat
  return S
end

on getFoolFile GN
  openfile(cFileIO, fName[GN], 0)
  if status(cFileIO) <> 0 then
    closeFile(cFileIO)
    return EMPTY
  end if
  L = getLength(cFileIO)
  if L > 99999 then
    closeFile(cFileIO)
    return EMPTY
  end if
  chunk = errorReadFile()
  if zipTest(chunk) = 0 then
    closeFile(cFileIO)
    chunk = EMPTY
  end if
  closeFile(cFileIO)
  return chunk
end

on getOpenFile FP
  openfile(cFileIO, FP, 0)
  if status(cFileIO) <> 0 then
    return EMPTY
  end if
  L = getLength(cFileIO)
  if L > 66666 then
    closeFile(cFileIO)
    return EMPTY
  end if
  chunk = errorReadFile()
  if zipTest(chunk) = 0 then
    closeFile(cFileIO)
    return EMPTY
  end if
  closeFile(cFileIO)
  return chunk
end

on putFoolFile GN
  putFoolFileSavedGamesFolder(GN)
  putFoolFileSavedCliff(GN)
  putRevertFoolFile(GN)
end

on putFoolFileSavedGamesFolder GN
  S = fName[GN]
  cTestIO.openfile(S, 0)
  delete cTestIO
  createFile(cTestIO, S)
  cTestIO.openfile(S, 0)
  setPosition(cTestIO, 0)
  cTestIO.writeString(fData[GN])
  cTestIO.closeFile()
end

on putFoolFileSavedCliff GN
  if prefChunk[GN] <> prefNumber[GN] then
    S = cSaveDirectoryCliff & prefChunk[GN]
    cTestIO.openfile(S, 0)
    delete cTestIO
    createFile(cTestIO, S)
    cTestIO.openfile(S, 0)
    setPosition(cTestIO, 0)
    cTestIO.writeString(fData[GN])
    cTestIO.closeFile()
  end if
end

on openFoolFileCliff GN
  if theDirectorVersion = 10 then
    fName[cOpenGameNum] = EMPTY
    fData[cOpenGameNum] = EMPTY
    setFilterMask(cFileIO, "TEXT ttxt")
    theFilePath = cFileIO.displayOpen()
    if theFilePath = EMPTY then
      misc_SetFlash("openWaitCount", 2)
      exit
    end if
    theFileName = calc_File_Name_From_Path(theFilePath)
    L = theFileName.length
    if theFileName.char[L - 3..L] <> ".txt" then
      theFileName = EMPTY
    end if
    if theFileName = EMPTY then
      exit
    end if
    theFileData = getOpenFile(theFilePath)
    if theFileData = EMPTY then
      exit
    end if
    if zipTest(theFileData) = 0 then
      exit
    end if
    fName[cOpenGameNum] = theFileName
    fData[cOpenGameNum] = theFileData
    if fName[cOpenGameNum] <> EMPTY then
      _movie.go(4)
      xferFoolFileCliff()
    end if
  end if
end

on xferFoolFileCliff
  putAltGamePref(currGame, fName[cOpenGameNum])
  fData[currGame] = fData[cOpenGameNum]
  fName[cOpenGameNum] = EMPTY
  fData[cOpenGameNum] = EMPTY
  putFoolFile(currGame)
  launchGame(currGame, 1)
end

on saveAsFoolFileCliff GN
  if theDirectorVersion = 10 then
    setFilterMask(cFileIO, "TEXT ttxt")
    FN = prefChunk[GN]
    theFilePath = cFileIO.displaySave(FN, cSaveDirectoryCliff & FN)
    if theFilePath = EMPTY then
      return 0
    end if
    theFileName = calc_File_Name_From_Path(theFilePath)
    if theFilePath = EMPTY then
      return 0
    end if
    currGame = GN
    putAltGamePref(currGame, theFileName)
    putFoolFile(GN)
    return 1
  end if
  return 0
end

on getRevertFoolFile GN
  fData[GN] = fData[cRevGameNum]
  copyTokens(GN, cRevGameNum)
  readGameFile(GN)
  initLaunch(currPuzzle, 0)
end

on putRevertFoolFile GN
  fData[cRevGameNum] = fData[GN]
  parseTokenDescriptions(cRevGameNum)
end

on errorFoolFile e, S
  if e <> 0 then
    _PUT(S && "ERROR" && e)
  end if
end

on errorCreateFile GN
  createFile(cFileIO, fName[GN])
  errorFoolFile(status(cFileIO), "CREATE")
end

on errorOpenFile GN
  openfile(cFileIO, fName[GN], 0)
  errorFoolFile(status(cFileIO), "OPEN")
end

on errorReadFile
  setPosition(cFileIO, 0)
  chunk = readFile(cFileIO)
  errorFoolFile(status(cFileIO), "READ")
  return chunk
end

on errorWriteFile chunk
  setPosition(cFileIO, 0)
  setFinderInfo(cFileIO, "TEXT ttxt")
  writeString(cFileIO, chunk)
  errorFoolFile(status(cFileIO), "WRITE")
end

on eraseFoolFile GN
  fName[GN] = tName[GN]
  putAltGamePref(GN, prefNumber[GN])
  fData[GN] = fData[cNewGameNum]
  putFoolFileSavedGamesFolder(GN)
  copyTokens(GN, cNewGameNum)
  putLastGamePref(0)
end

on eraseAllFoolFiles
  repeat with x = 1 to cTarotTotal
    eraseFoolFile(x)
  end repeat
end

on saveCurrentPuzzle
  if (currPuzzle >= 1) and (currPuzzle <= 100) then
    getMenuStatsFromFlash()
    pSwords[currPuzzle] = misc_GetFlash("gSwords", 1)
    pWands[currPuzzle] = misc_GetFlash("gWands", 1)
    pCups[currPuzzle] = misc_GetFlash("gCups", 1)
    pPentacles[currPuzzle] = misc_GetFlash("gPentacles", 1)
    if pSwords[currPuzzle] = VOID then
      pSwords[currPuzzle] = 0
    end if
    if pWands[currPuzzle] = VOID then
      pWands[currPuzzle] = 0
    end if
    if pCups[currPuzzle] = VOID then
      pCups[currPuzzle] = 0
    end if
    if pPentacles[currPuzzle] = VOID then
      pPentacles[currPuzzle] = 0
    end if
    pStat[currPuzzle] = misc_GetFlash("gStat", 1)
    pData[currPuzzle] = misc_GetFlash("gData", 0)
    pDone[currPuzzle] = misc_GetFlash("gDone", 0)
    if pDone[currPuzzle] = EMPTY then
      pDone[currPuzzle] = "-"
    end if
    saveWordStat63()
  end if
end

on saveCurrentGame
  if currGame > 0 then
    if createNewGameData = 1 then
      initWordStat63()
    end if
    fData[currGame] = encodeZip(createGameChunk(currGame))
    putLastGamePref(currGame)
    putFoolFile(currGame)
    if createNewGameData = 1 then
      init_NewGameData(fData[currGame])
    end if
  end if
end

on createGameChunk GN
  if (GN >= 1) and (GN <= cFileTotal) then
    updateGameStats(GN)
    CP = exceptionPuzzleLaunch(currPuzzle, 1)
    S = getFileKeyWord() & "*"
    S = S & CP & "*" & token1[GN] & "*" & token2[GN] & "*" & token3[GN] & "*"
    pStat[cTokens] = 0
    pData[cTokens] = "empty"
    repeat with x = 1 to cSavePuzzleTotal
      S = S & pPage[x] & "*" & pStat[x] & "*" & pData[x] & "*" & pDone[x] & "*"
      S = S & pSwords[x] & "*" & pWands[x] & "*" & pCups[x] & "*" & pPentacles[x] & "*"
    end repeat
    repeat with x = 1 to 5
      S = S & csWagerTarot[x] & "*"
    end repeat
    S = S & pWindowCode & "*"
    repeat with x = 1 to 4
      S = S & pWordStat63[x] & "*"
    end repeat
    return S
  else
    showAlert(1, GN && "is out of range 1-" & cFileTotal, "createGameChunk(GN)")
  end if
end

on grab b
  grab1 = grab2 + 2
  grab2 = grab1 + offset("*", grab3.char[grab1..grab4]) - 2
  if b = 0 then
    return grab3.char[grab1..grab2]
  else
    return integer(grab3.char[grab1..grab2])
  end if
end

on parseTokenDescriptions GN
  S = decodeZip(fData[GN].char[1..222])
  grab1 = -1
  grab2 = -1
  grab3 = S
  grab4 = grab3.length
  junk = grab(0)
  junk = grab(0)
  token1[GN] = grab(0)
  token2[GN] = grab(0)
  token3[GN] = grab(1)
end

on parseGameFile GN
  grab1 = -1
  grab2 = -1
  grab3 = decodeZip(fData[GN])
  grab4 = grab3.length
  junk = grab(0)
  currPuzzle = grab(1)
  token1[GN] = grab(0)
  token2[GN] = grab(0)
  token3[GN] = grab(1)
  repeat with x = 1 to cSavePuzzleTotal
    pPage[x] = grab(1)
    pStat[x] = grab(1)
    pData[x] = grab(0)
    pDone[x] = grab(0)
    pSwords[x] = grab(1)
    pWands[x] = grab(1)
    pCups[x] = grab(1)
    pPentacles[x] = grab(1)
  end repeat
  repeat with x = 1 to 5
    csWagerTarot[x] = grab(1)
  end repeat
  if csWagerTarot[1] = 0 then
    repeat with x = 1 to 5
      csWagerTarot[x] = csWager[x]
    end repeat
  end if
  pWindowCode = grab(0)
  repeat with x = 1 to 4
    pWordStat63[x] = grab(0)
  end repeat
end

on grabA b
  aaaa1 = aaaa2 + 2
  aaaa2 = aaaa1 + offset("*", aaaa3.char[aaaa1..aaaa4]) - 2
  if b = 0 then
    return aaaa3.char[aaaa1..aaaa2]
  else
    return integer(aaaa3.char[aaaa1..aaaa2])
  end if
end

on grabB b
  bbbb1 = bbbb2 + 2
  bbbb2 = bbbb1 + offset("*", bbbb3.char[bbbb1..bbbb4]) - 2
  if b = 0 then
    return bbbb3.char[bbbb1..bbbb2]
  else
    return integer(bbbb3.char[bbbb1..bbbb2])
  end if
end

on grabC b
  cccc1 = cccc2 + 2
  cccc2 = cccc1 + offset("_", cccc3.char[cccc1..cccc4]) - 2
  if b = 0 then
    return cccc3.char[cccc1..cccc2]
  else
    return integer(cccc3.char[cccc1..cccc2])
  end if
end

on analyzeC S
  cccc3 = S
  if cccc3 <> "empty" then
    cccc1 = -1
    cccc2 = -1
    cccc4 = cccc3.length
    total = grabC(1)
    repeat with x = 1 to total
      num = grabC(1)
    end repeat
    return cccc3.char[cccc2 + 2..cccc4]
  end if
  return cccc3
end

on compareLastSavedGameData
  aaaa3 = decodeZip(fData[cRevGameNum])
  bbbb3 = createGameChunk(currGame)
  p = 0
  identical = 1
  aaaa1 = -1
  aaaa2 = -1
  aaaa4 = aaaa3.length
  bbbb1 = -1
  bbbb2 = -1
  bbbb4 = bbbb3.length
  if p = 1 then
    _PUT("---compareLastSavedGameData()")
  end if
  if aaaa4 <> bbbb4 then
    identical = 0
    if p = 1 then
      _PUT("length---" & aaaa4 & "---" & bbbb4 & "---")
    end if
  end if
  S1 = grabA(0)
  s2 = grabB(0)
  if S1 <> s2 then
    identical = 0
    if p = 1 then
      _PUT("password---" & S1 & "---" & s2 & "---")
    end if
  end if
  S1 = grabA(1)
  s2 = grabB(1)
  if S1 <> s2 then
    identical = 0
    if p = 1 then
      _PUT("currPuzzle---" & S1 & "---" & s2 & "---")
    end if
  end if
  S1 = grabA(0)
  s2 = grabB(0)
  if S1 <> s2 then
    identical = 0
    if p = 1 then
      _PUT("token1[]---" & S1 & "---" & s2 & "---")
    end if
  end if
  S1 = grabA(0)
  s2 = grabB(0)
  if S1 <> s2 then
    identical = 0
    if p = 1 then
      _PUT("token2[]---" & S1 & "---" & s2 & "---")
    end if
  end if
  S1 = grabA(1)
  s2 = grabB(1)
  if S1 <> s2 then
    identical = 0
    if p = 1 then
      _PUT("token3[]---" & S1 & "---" & s2 & "---")
    end if
  end if
  repeat with x = 1 to cSavePuzzleTotal
    S1 = x && "page/stat" && grabA(1) & "*" & grabA(1)
    s2 = x && "page/stat" && grabB(1) & "*" & grabB(1)
    if S1 <> s2 then
      identical = 0
      if p = 1 then
        _PUT(S1)
        _PUT(s2)
      end if
    end if
    data_A = grabA(0)
    done_A = grabA(0)
    data_B = grabB(0)
    done_B = grabB(0)
    if (data_A <> data_B) or (done_A <> done_B) then
      S1 = x && "data/done" && analyzeC(data_A) & "*" & done_A & "*"
      s2 = x && "data/done" && analyzeC(data_B) & "*" & done_B & "*"
      if S1 <> s2 then
        identical = 0
        if p = 1 then
          _PUT(S1)
          _PUT(s2)
        end if
      end if
    end if
    S1 = x && "S/W/C/P" && grabA(1) & "*" & grabA(1) & "*" & grabA(1) & "*" & grabA(1) & "*"
    s2 = x && "S/W/C/P" && grabB(1) & "*" & grabB(1) & "*" & grabB(1) & "*" & grabB(1) & "*"
    if S1 <> s2 then
      identical = 0
      if p = 1 then
        _PUT(S1)
        _PUT(s2)
      end if
    end if
  end repeat
  S1 = grabA(0)
  s2 = grabB(0)
  if S1 <> s2 then
    identical = 0
    if p = 1 then
      _PUT("pWindowCode")
      _PUT(S1)
      _PUT(s2)
    end if
  end if
  if p = 1 then
    _PUT("---compareLastSavedGameData()")
  end if
  return identical
end

on _Set_Save_Mode ST, countDown
  playMode = pmSave
  _Save_Stat = 0
  _Save_Type = ST
  if _Save_Type = 2 then
    menu_SavingGame(1)
  end if
  if countDown = 1 then
    menu_Display(4)
    menu_HiliteCountDown = 10
  end if
end

on _Zero_Save_Mode
  _Save_Stat = 0
  _Save_Type = 0
end

on _valid_Save_Progress
  if _Save_Type > 0 then
    pollSaveStageStatus()
  end if
end

on pollSaveStageStatus
  case _Save_Type of
    0:
      _Zero_Save_Mode()
      exit
    1, 3:
      if (currPuzzle = cTokens) or (currPuzzle = cHelpTokens) or (currPuzzle = cPrologue) then
        case _Save_Type of
          1:
            playMode = pmPlay
          3:
            check_Save_Before_Quit()
        end case
        _Zero_Save_Mode()
        exit
      end if
  end case
  case _Save_Stat of
    0:
      misc_SetFlash("gFlashCommand", 4)
      _Set_Ticks(0)
      _Save_Stat = 1
    1:
      Q = misc_GetFlash("gSaveStages", 0)
      if (Q = EMPTY) or (Q = "4") then
        _Save_Stat = 2
      end if
    2:
      noInterface()
      misc_SetFlash("gSaveStages", 0)
      misc_SetFlash("gFlashCommand", 0)
      saveCurrentPuzzle()
      case _Save_Type of
        1:
          _Zero_Save_Mode()
          executeLaunch()
          exit
        3:
          _Zero_Save_Mode()
          nextPuzzle = 0
          check_Save_Before_Quit()
          exit
        otherwise:
          _Save_Stat = 3
      end case
    3:
      saveCurrentGame()
      _Save_Stat = 4
    4:
      cFileIO.readChar()
      cTestIO.readChar()
      if (status(cFileIO) <> 0) and (status(cTestIO) <> 0) then
        _Save_Stat = 5
      end if
    5:
      menu_SavingGame(0)
      _Zero_Save_Mode()
      if pClickToContinue = 0 then
        if playMode = pmSave then
          playMode = pmPlay
        end if
      else
        menu_SetFlashProperty_ClickToContinue()
        playMode = pmClick
      end if
  end case
end
