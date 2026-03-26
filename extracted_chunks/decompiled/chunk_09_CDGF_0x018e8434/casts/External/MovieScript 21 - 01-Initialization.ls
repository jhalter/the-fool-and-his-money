global cPuzzleTotal, cSavePuzzleTotal, cInterface, mouseChunk, lastMouseX, lastMouseY, keyChunk, menuName, titleName, menuStat, CR, QU, rectTotal, r1, r2, r3, R4, token1, token2, token3, zipCode, currGame, lastPuzzle, currPuzzle, nextPuzzle, directToScreenHelp, chunkMenuStat, chunkMenuName, loadPuzzleCount, startTicks, currRollOver, lastRollOver, currMenuDisplay, cSwords1, cSwords2, cWands1, cWands2, cCups1, cCups2, cPentacles1, cPentacles2, cMansion1, cMansion2, cPrologue, cPreHP, cEndHP, cHighPriestess, cSevenCups, cMoonMorph, cMoonsMap, cMoonsPuzzles, cGameMenus, cTokens, cPreFinale, cFinale, cActiveSN, cScrollSN, cHelpSN, cMenuSN, cForwardSN, cReverseSN, cMoneySN, cTarotTotal, cNewGameNum, cOpenGameNum, cRevGameNum, cFileTotal, cTarot1, cTarot2, cTarot3, cTarot4, cTarot5, cHelpTokens, cMenuPuzzles, cInitFreeBytes, cInitMemorySize, cTarotCards, cTypeCurrPuzzle, cGameDirectory, cWork, cLink, cXtraDirectory, cFileIO, tName, fName, fData, pNum, pStat, pData, pDone, pPage, pHelp, pMenu, pVolume, pFrame, pWindowCode, pWordStat63, prefNumber, prefTotal, prefChunk, pSwords, pWands, pCups, pPentacles, pTotalSwords, pTotalWands, pTotalCups, pTotalPentacles, theDataStatus, pFin_Count, pFin_Incre, pFin_Total, pClickToContinue, snd_Channel_Array, snd_Channel_Count, _Save_Stat, _Save_Type, c_Interface_Mode, c_Interface_MouseDown, c_Interface_DoubleClick, c_Interface_KeyDown, activity_Array, activity_Count, activity_Total, activity_Launch, playMode, pmZero, pmPlay, pmHelp, pmClick, pmSave, pmDeActivate, pmActivate, pz_Available, pz_Total, pz_LastLaunch, menu_Key, menuClick_Array, menuClick_Count, theDirectorVersion, createNewGameData, csGrid, csJumble, csClickCode, csPhrase, csConcat, csLetterSlide, csPatchPirate, csPatchStamp, csMorphText, csHerb, csTracer, csInventory, csSeven, csAuction, csWager, csTarot, csWagerTarot, csPentacle, csPreFinale, csMorph, csCoins, csHalves, csFillin, csPatchSlider, csMansion, csDEL, csHEX, csREM, csCON, totalName, cSavedGamesDirectory, cSaveDirectoryCliff, status_Quit_The_Game, status_First_Launch

on init_StartGame
  createNewGameData = 0
  status_First_Launch = 1
  _sound.soundKeepDevice = 0
  _sound.soundMixMedia = 0
  cInitMemorySize = integer(the memorysize / 1024)
  cInitFreeBytes = integer(the freeBytes / 1024)
  activeState = 1
  activeStatePuzzle = 0
  noInterface()
  c_Interface_Mode = 0
  cTypeCurrPuzzle = 0
  c_Interface_MouseDown = 0
  c_Interface_KeyDown = 0
  c_Interface_DoubleClick = 0
  zero_DoubleClick()
  cTarotTotal = 12
  cNewGameNum = 13
  cRevGameNum = 14
  cOpenGameNum = 15
  cFileTotal = 15
  cMenuPuzzles = 77
  cPuzzleTotal = 128
  cSavePuzzleTotal = 100
  cPrologue = 1
  cSwords1 = 2
  cMoonMorph = 3
  cSwords2 = 18
  cWands1 = 19
  cWands2 = 37
  cCups1 = 38
  cCups2 = 55
  cPentacles1 = 56
  cPentacles2 = 71
  cPreFinale = 72
  cMansion1 = 73
  cMansion2 = 79
  cFinale = 80
  cHelpTokens = 87
  cPreHP = 88
  cEndHP = 89
  cHighPriestess = 90
  cSevenCups = 91
  cTarot1 = 92
  cTarot2 = 93
  cTarot3 = 94
  cTarot4 = 95
  cTarot5 = 96
  cMoonsMap = 97
  cMoonsPuzzles = 98
  cGameMenus = 99
  cTokens = 100
  cActiveSN = 1
  cScrollSN = 3
  cHelpSN = 4
  cMenuSN = 5
  cForwardSN = 6
  cReverseSN = 7
  cMoneySN = 8
  _Set_DirectorInControl(cScrollSN)
  _Set_DirectorInControl(cHelpSN)
  CR = numToChar(13)
  QU = numToChar(34)
  tName = list()
  fName = list()
  fData = list()
  pNum = list()
  pStat = list()
  pData = list()
  pDone = list()
  pPage = list()
  pHelp = list()
  pMenu = list()
  pVolume = list()
  pFrame = list()
  pSwords = list()
  pWands = list()
  pCups = list()
  pPentacles = list()
  pVolumeOff = 0
  pWordStat63 = list()
  initWordStat63()
  csMorph = list()
  csCoins = list()
  csHalves = list()
  csFillin = list()
  csPatchSlider = list()
  csGrid = list()
  csJumble = list()
  csClickCode = list()
  csPhrase = list()
  csConcat = list()
  csLetterSlide = list()
  csPatchPirate = list()
  csPatchStamp = list()
  csMorphText = list()
  csHerb = list()
  csTracer = list()
  csPentacle = list()
  csInventory = list()
  csSeven = list()
  csAuction = list()
  csWager = list()
  csTarot = list()
  csWagerTarot = list()
  csMansion = list()
  csDEL = list()
  csHEX = list()
  csREM = list()
  csCON = list()
  pTotalSwords = 0
  pTotalWands = 0
  pTotalCups = 0
  pTotalPentacles = 0
  mouseChunk = EMPTY
  lastMouseX = 0
  lastMouseY = 0
  keyChunk = EMPTY
  pClickToContinue = 0
  pTraceMenu = 0
  status_Quit_The_Game = 0
  pz_Total = 0
  pz_LastLaunch = 0
  pz_Available = list()
  menuName = list()
  menuStat = list()
  titleName = list()
  token1 = list()
  token2 = list()
  token3 = list()
  activity_Array = list()
  activity_Count = 0
  activity_Total = 0
  activity_Launch = 0
  activity_Init()
  r1 = list()
  r2 = list()
  r3 = list()
  R4 = list()
  rectTotal = 0
  misc_MakeRect(57, 571, 74, 28)
  misc_MakeRect(163, 571, 65, 28)
  misc_MakeRect(260, 571, 41, 28)
  misc_MakeRect(338, 571, 49, 28)
  misc_MakeRect(423, 571, 48, 28)
  misc_MakeRect(508, 571, 72, 28)
  misc_MakeRect(611, 571, 53, 28)
  misc_MakeRect(696, 571, 43, 28)
  menu_Key = "--------"
  menuClick_Array = [1, 6, 2, 7, 3, 8, 4, 9, 5]
  menuClick_Count = 0
  snd_Channel_Array = list()
  snd_Channel_Count = 0
  repeat with x = 1 to 8
    snd_Channel_Array[x] = _sound.channel(x)
  end repeat
  currRollOver = 0
  lastRollOver = 0
  currMenuDisplay = 0
  chunkMenuName = EMPTY
  chunkMenuStat = EMPTY
  directToScreenHelp = 0
  loadPuzzleCount = 0
  pWindowCode = EMPTY
  currGame = 0
  lastPuzzle = cTokens
  currPuzzle = cGameMenus
  nextPuzzle = 0
  playMode = 0
  pmZero = 0
  pmPlay = 1
  pmHelp = 2
  pmClick = 3
  pmSave = 5
  pmDeActivate = 9999
  pmActivate = 10000
  _Pause_Play = 0
  _Pause_Goal = 0
  pFin_Count = 0
  pFin_Incre = 0
  pFin_Total = 0
  startTicks = _movie.ticks()
  the randomSeed = _movie.ticks()
  _Save_Stat = 0
  _Save_Type = 0
  repeat with x = 1 to cPuzzleTotal
    pNum[x] = 1
    pStat[x] = 0
    pData[x] = "empty"
    pDone[x] = "-"
    pSwords[x] = 0
    pWands[x] = 0
    pCups[x] = 0
    pPentacles[x] = 0
    pPage[x] = 0
    pMenu[x] = "12345--8"
    menuName[x] = EMPTY
    menuStat[x] = 0
    pHelp[x] = EMPTY
  end repeat
  pMenu[cMoonsMap] = "12-45--8"
  pMenu[cMoonsPuzzles] = "12-45--8"
  pMenu[cGameMenus] = "1-345--8"
  pMenu[cHelpTokens] = "1234---8"
  pTotalSwords = 0
  pTotalWands = 0
  pTotalCups = 0
  pTotalPentacles = 0
  repeat with x = 1 to cFileTotal
    token1[x] = EMPTY
    token2[x] = EMPTY
    token3[x] = 0
  end repeat
  token_ClearSaved()
  gatherAllData()
  cTarotCards = ["The Tower", "The Magician", "The Star", "The Hermit", "Strength", "The Devil", "The Hierophant", "The Empress", "The Chariot", "Justice", "Death", "The Lovers"]
  shortened = ["Tower", "Magician", "Star", "Hermit", "Strength", "Devil", "Hierophant", "Empress", "Chariot", "Justice", "Death", "Lovers"]
  repeat with x = 1 to 12
    tName[x] = cSavedGamesDirectory & prefNumber[x].char[1..2] & "-" & shortened[x] & ".txt"
    fName[x] = tName[x]
    fData[x] = EMPTY
  end repeat
  fData[cNewGameNum] = field("new-game")
  parseTokenDescriptions(cNewGameNum)
  fName[cOpenGameNum] = EMPTY
  fData[cOpenGameNum] = EMPTY
  currGame = getLastGamePref()
  repeat with x = 1 to cTarotTotal
    savedGamesFolder = 0
    fData[x] = getFoolFile(x)
    if fData[x] <> EMPTY then
      if zipTest(fData[x]) = 1 then
        savedGamesFolder = 1
      end if
    end if
    if savedGamesFolder = 0 then
      _PUT("NO save" && prefNumber[x])
      fData[x] = fData[cNewGameNum]
      putFoolFileSavedGamesFolder(x)
    end if
    parseTokenDescriptions(x)
  end repeat
  readGameFile(currGame)
  _movie.go(3)
end

on init_NewGameData chunk
  fData[cNewGameNum] = chunk
  member("new-game").text = chunk
  _PUT("New Game Data created")
  halt()
end

on init_LaunchGame
  b1 = 0
  b2 = 0
  if sprite(cScrollSN).getVariable("initPage", 1) <> "666" then
    misc_CallSprite(cScrollSN)
  else
    b1 = 1
  end if
  if sprite(cHelpSN).getVariable("initHelp", 1) <> "666" then
    misc_CallSprite(cHelpSN)
  else
    b2 = 1
  end if
  currPuzzle = _Help_Tokens_Exception(currPuzzle)
  if (b1 = 1) and (b2 = 1) then
    if theDataStatus = 0 then
      _Launch_Tokens(0, 0)
    else
      if (currPuzzle = 0) or (currGame = 0) then
        _Launch_Tokens(0, 0)
      else
        status_First_Launch = 0
        initLaunch(currPuzzle, 0)
      end if
    end if
  end if
end
