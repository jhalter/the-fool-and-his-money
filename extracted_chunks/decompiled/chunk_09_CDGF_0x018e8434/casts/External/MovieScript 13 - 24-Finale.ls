global cActiveSN, cScrollSN, cMenuSN, cForwardSN, cReverseSN, cPreFinale, cFinale, cGameMenus, c_Interface_Mode, currPuzzle, loadPuzzleCount, currRollOver, lastRollOver, nextPuzzle, requestBlock, currMenuDisplay, pFin_Count, pFin_Incre, pFin_Total, pFin_Menu, pStat, pPage, pMenu, pHelp, pTransition, menuStat, playMode, pmZero, pmPlay, pmHelp, pmClick, pmSave, pmDeActivate, pmActivate, F_Arrow_Active, R_Arrow_Active, _Finale_After_Click, fin_Before_Stat

on fin_Play
  loadPuzzleCount = 0
  presentation = [1, 2, 9, 13, 17, 18, 19]
  pFin_Total = 7
  pFin_Count = pFin_Count + 1
  if pFin_Count <= pFin_Total then
    if pFin_Count < pFin_Total then
      _movie.puppetTransition(9, 1, 20, 0)
    end if
    FR = "F" & misc_PadNumber(presentation[pFin_Count], 0, 0)
    _movie.go(FR)
  else
    pTransition = 9
    initLaunch(cGameMenus, 1)
  end if
end

on fin_PrepInit
  if loadPuzzleCount = 0 then
    currPuzzle = cFinale
    init_Window_Title("The Finale")
    if _movie.frameLabel = "F01" then
      pFin_Count = 1
      misc_CalcPage(0)
    end if
    misc_InitPuzzle()
    arrow_F_Init()
    arrow_R_Init()
    F_Arrow_Active = 0
    R_Arrow_Active = 0
    pMenu[cFinale] = "--------"
    if pFin_Count = 1 then
      menu_Init(0)
    else
      menu_Init(666)
    end if
    misc_InitPage()
    _Finale_After_Click = 0
  end if
  sendFlashData()
end

on fin_ExitInit
  nullMouseChunk()
  misc_ClearQueue(0)
  L = integer(misc_GetFlash("gListener", 1))
  if L <> 666 then
    _movie.go(_movie.frame)
  else
    playMode = pmPlay
    fin_Interface()
    setDirectToStage(cActiveSN)
  end if
end

on fin_PrepPlay
  if _Finale_After_Click < 15 then
    _Finale_After_Click = _Finale_After_Click + 1
  end if
  if playMode = pmPlay then
    setMouseIdle()
    misc_SetFlash("pShiftKey", _key.shiftDown)
    sendMouseKeyChunk()
    currRollOver = _movie.rollover()
    case currRollOver of
      cActiveSN, cScrollSN, cForwardSN, cReverseSN:
      cMenuSN:
        menu_MouseOver(_mouse.mouseH, _mouse.mouseV)
      otherwise:
        currRollOver = lastRollOver
    end case
    if lastRollOver <> currRollOver then
      if lastRollOver = cMenuSN then
        menu_ExitDisplay()
      end if
    end if
    lastRollOver = currRollOver
  end if
end

on fin_ExitPlay
  case playMode of
    pmPlay:
      check_Fin_Interface()
      pollFlashRequest()
      menu_pmPlay_Poll_ClickToContinue()
    pmClick:
      check_Fin_Interface()
      puzz_RollOver()
      checkRollOverStatus()
    pmSave:
      check_No_Interface()
      pollSaveStageStatus()
    pmDeActivate:
      check_DeActivate_Interface()
      _valid_Save_Progress()
    pmActivate:
      fin_Interface()
      _Test_Activate("fin_MouseDown", 1)
    otherwise:
      playMode = pmPlay
  end case
  _movie.go(_movie.frame)
end

on check_Fin_Interface
  if the mouseDownScript <> "fin_MouseDown" then
    fin_Interface()
  end if
end

on fin_Interface
  c_Interface_Mode = 5
  _player.flushInputEvents()
  set the mouseDownScript to "fin_MouseDown"
  set the mouseUpScript to EMPTY
  set the keyDownScript to "fin_KeyDown"
  set the keyUpScript to "fin_KeyUp"
  _player.cursor(-1)
end

on fin_MouseDown
  case playMode of
    pmPlay:
      _End_Finale()
    pmClick:
      menu_ClickToContinue(0)
      _Finale_After_Click = 0
  end case
end

on fin_KeyDown
  if check_Quit_Keys_from_Interface(1) = 1 then
    initLaunch(cGameMenus, 1)
    exit
  end if
  K = charToNum(_key.keyPressed())
  case playMode of
    pmPlay:
      _End_Finale()
    pmClick:
      menu_ClickToContinue(0)
      _Finale_After_Click = 0
  end case
end

on fin_KeyUp
  c_Interface_KeyDown = 0
  misc_SetFlash("pKeyDown", 0)
  misc_SetFlash("pKeyUp", 1)
end

on _End_Finale
  if _Finale_After_Click = 15 then
    initLaunch(cGameMenus, 1)
  end if
end
