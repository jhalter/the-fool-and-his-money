global cActiveSN, cScrollSN, cHelpSN, cMenuSN, cForwardSN, cReverseSN, cGameMenus, currGame, currPuzzle, nextPuzzle, startTicks, currRollOver, lastRollOver, loadPuzzleCount, currMenuDisplay, c_Interface_Mode, c_Interface_MouseDown, c_Interface_KeyDown, playMode, pmZero, pmPlay, pmHelp, pmClick, pmSave, pmDeActivate, pmActivate, activity_Launch, pClickToContinue, F_Arrow_Active, R_Arrow_Active

on puzz_PrepInit
  cActiveSN = 1
  if loadPuzzleCount = 0 then
    noInterface()
    misc_SetFlash("gPhase", 0)
    misc_InitPuzzle()
    misc_InitPage()
    help_Init()
    menu_Init(currPuzzle)
    arrow_F_Init()
    arrow_R_Init()
    money_Init()
    playMode = pmPlay
    launch_InitList()
  end if
  sendFlashData()
end

on puzz_ExitInit
  if misc_GetFlash("gListener", 1) <> 666 then
    _movie.go(_movie.frame)
  else
    nullMouseChunk()
    playMode = pmPlay
    misc_ClearQueue(0)
    puzz_Interface()
    setDirectToStage(cActiveSN)
  end if
end

on puzz_PrepPlay
  _Check_for_StartUp_Switched()
  if (playMode = pmPlay) or (playMode = pmClick) then
    setMouseIdle()
    sendMouseKeyChunk()
    pollShiftKey()
    case playMode of
      pmPlay, pmClick:
        puzz_RollOver()
        checkRollOverStatus()
    end case
  end if
end

on puzz_ExitPlay
  case playMode of
    pmPlay:
      if the mouseDownScript <> "puzz_MouseDown" then
        puzz_Interface()
      end if
      pollFlashRequest()
      menu_pmPlay_Poll_ClickToContinue()
      pollShiftKey()
      case currRollOver of
        cForwardSN:
          if _mouse.mouseDown = 1 then
            launch_GameKey(999)
          end if
        cReverseSN:
          if _mouse.mouseDown = 1 then
            launch_GameKey(666)
          end if
      end case
    pmHelp:
      help_RefreshAfterClose()
    pmSave:
      check_No_Interface()
      pollSaveStageStatus()
    pmClick:
      if the mouseDownScript <> "puzz_MouseDown" then
        puzz_Interface()
      end if
    pmDeActivate:
      check_DeActivate_Interface()
      _valid_Save_Progress()
    pmActivate:
      puzz_Interface()
      _Test_Activate("puzz_MouseDown", 1)
    otherwise:
      playMode = pmPlay
  end case
  _movie.go(_movie.frame)
end

on puzz_RollOver
  currRollOver = _movie.rollover()
  case currRollOver of
    cMenuSN:
      menu_MouseOver(_mouse.mouseH, _mouse.mouseV)
    cForwardSN:
      arrow_F_Show(0)
    cReverseSN:
      arrow_R_Show(0)
  end case
end

on puzz_Interface
  c_Interface_Mode = 2
  _player.flushInputEvents()
  set the mouseDownScript to "puzz_MouseDown"
  set the mouseUpScript to "puzz_MouseUp"
  set the keyDownScript to "puzz_KeyDown"
  set the keyUpScript to "puzz_KeyUp"
  _player.cursor(-1)
end

on puzz_MouseDown
  puzz_Interface_Activate()
  if _movie.ticks() < startTicks then
    exit
  end if
  c_Interface_MouseDown = 1
  case playMode of
    pmPlay:
      case currRollOver of
        cActiveSN, cScrollSN:
          setMouseDown()
        cMenuSN:
          if currMenuDisplay = 0 then
            setMouseDown()
          else
            menu_Action(0, 1)
          end if
        cForwardSN:
          if F_Arrow_Active = 0 then
            setMouseDown()
          else
            launch_GameKey(999)
          end if
        cReverseSN:
          if R_Arrow_Active = 0 then
            setMouseDown()
          else
            launch_GameKey(666)
          end if
      end case
    pmClick:
      case currRollOver of
        cActiveSN, cScrollSN:
          menu_ClickToContinue(0)
        cMenuSN:
          if currMenuDisplay = 0 then
            menu_ClickToContinue(0)
          else
            menu_Action(0, 1)
          end if
        cForwardSN:
          if launch_GameKey(999) = 0 then
            menu_ClickToContinue(0)
          end if
        cReverseSN:
          if launch_GameKey(666) = 0 then
            menu_ClickToContinue(0)
          end if
      end case
    pmHelp:
      help_Hide()
  end case
end

on puzz_MouseUp
  if c_Interface_MouseDown = 1 then
    case playMode of
      pmPlay:
        setMouseIdle()
        misc_SetFlash("pMouseDown", 0)
        if test_DoubleClick() = 0 then
          misc_SetFlash("pMouseUp", 1)
        else
          misc_SetFlash("pMouseUp", 2)
        end if
        zero_DoubleClick()
    end case
    c_Interface_MouseDown = 0
  end if
end

on puzz_KeyDown
  puzz_Interface_Activate()
  if _movie.ticks() < startTicks then
    exit
  end if
  if check_Quit_Keys_from_Interface(1) = 1 then
    exit
  end if
  c_Interface_KeyDown = 1
  K = charToNum(_key.keyPressed())
  PK = pollSpecialKeys()
  case playMode of
    pmPlay:
      if launch_GameKey(K) = 1 then
        exit
      end if
      if K = 32 then
        if PK = "000" then
          if misc_GetFlash("gSpaceUndo", 0) = "true" then
            K = menu_KeyCommand(85, 1)
            _Set_Ticks(10)
            exit
          end if
        end if
        if (PK = "100") and (misc_GetFlash("gSpaceReset", 0) = "true") then
          K = menu_KeyCommand(82, 1)
          exit
        end if
      end if
      if K = 8 then
        if (PK = "000") and (misc_GetFlash("gBackSpaceUndo", 0) = "true") then
          K = menu_KeyCommand(85, 1)
          _Set_Ticks(10)
          exit
        end if
        if (PK = "100") and (misc_GetFlash("gBackSpaceReset", 0) = "true") then
          K = menu_KeyCommand(82, 1)
          exit
        end if
      end if
      K = menu_Poll_KeyCommand(PK, K, 1)
      if K = 0 then
        exit
      end if
      if (PK = "100") and (K = RETURN) then
        K = 1313
      end if
      case _key.keyCode of
        123:
          K = 28
        124:
          K = 29
        125:
          K = 31
        126:
          K = 30
        BACKSPACE:
          K = 8
      end case
      if (K = 8) and (PK = "100") then
        K = 888
      end if
      if K > 0 then
        calcKeyChunk(K)
        misc_SetFlash("pKeyDown", K)
        misc_SetFlash("pKeyUp", 0)
      end if
    pmHelp:
      help_Hide()
    pmClick:
      menu_pmClick_Poll_SpecialKeys(PK, K, 1)
  end case
end

on puzz_KeyUp
  if c_Interface_KeyDown = 1 then
    case playMode of
      pmPlay:
        misc_SetFlash("pKeyDown", 0)
        misc_SetFlash("pKeyUp", 1)
    end case
    c_Interface_KeyDown = 0
  end if
end

on puzz_Interface_Activate
  if (playMode = pmDeActivate) or (playMode = pmActivate) then
    puzz_Interface()
    _Test_Activate("puzz_MouseDown", 1)
  end if
end
