global playMode, currPuzzle, lastPuzzle, loadPuzzleCount, menu_Key, startTicks, cInterface, cActiveSN, cTokens, cHelpTokens, cGameMenus, c_Interface_Mode, pNum, pStat, pData, pMenu, pMiscellaneous, pVolume, c_Interface_MouseDown, c_Interface_KeyDown, tokens_LastPuzzle, tokens_CurrentGame, tokens_NeedToSave, pmPlay, pmSave, pmDeActivate, pmActivate, _Window_Switched

on token_RestoreSaved
  if tokens_LastPuzzle = -1 then
    lastPuzzle = _Help_Tokens_Exception(lastPuzzle)
    currPuzzle = _Help_Tokens_Exception(currPuzzle)
  else
    tokens_LastPuzzle = _Help_Tokens_Exception(tokens_LastPuzzle)
    lastPuzzle = tokens_LastPuzzle
    currPuzzle = tokens_LastPuzzle
    pNum[cTokens] = tokens_CurrentGame
    pStat[cTokens] = tokens_NeedToSave
  end if
  token_ClearSaved()
end

on token_ClearSaved
  tokens_LastPuzzle = -1
  tokens_CurrentGame = -1
  tokens_NeedToSave = -1
  _Zero_Save_Mode()
end

on token_PrepInit
  playMode = 0
  cActiveSN = 1
  misc_HidePuzzleSprites()
  pData[cTokens] = pMiscellaneous
  misc_SetFlash("pNum", pNum[cTokens])
  misc_SetFlash("pStat", pStat[cTokens])
  misc_SetFlash("pData", pData[cTokens])
  misc_SetFlashVolume(1, pVolume[cTokens])
  if lastPuzzle > 0 then
    misc_SetFlash("gFlashCommand", 666)
  end if
end

on token_ExitInit
  misc_ClearQueue(0)
  if misc_GetFlash("gListener", 1) <> 666 then
    _movie.go(_movie.frame)
  else
    playMode = pmPlay
    token_Interface()
    setDirectToStage(cActiveSN)
  end if
end

on token_PrepPlay
  _Check_for_StartUp_Switched()
  if playMode = pmPlay then
    token_Idle_XY()
    misc_SetFlash("gShiftKey", _key.shiftDown)
  end if
end

on token_ExitPlay
  if pStat[cHelpTokens] = 666 then
    misc_SetFlash("gFlashRequest", "100|16|1|1|")
    exit
  end if
  case playMode of
    pmPlay:
      if the mouseDownScript <> "token_MouseDown" then
        token_Interface()
      end if
      pollFlashRequest()
    pmDeActivate:
      token_DeActivate()
    pmActivate:
      token_Interface()
      _Test_Activate("token_MouseDown", 0)
    otherwise:
      playMode = pmPlay
  end case
  _movie.go(_movie.frame)
end

on token_Interface
  c_Interface_Mode = 1
  _player.flushInputEvents()
  set the mouseDownScript to "token_MouseDown"
  set the mouseUpScript to "token_MouseUp"
  set the keyDownScript to "token_KeyDown"
  set the keyUpScript to "token_KeyUp"
  _player.cursor(-1)
end

on token_Idle_XY
  misc_SetFlash("gIdleX", _mouse.mouseH)
  misc_SetFlash("gIdleY", _mouse.mouseV)
end

on token_MouseDown
  token_Idle_XY()
  misc_SetFlash("gMouseDown", 1)
  misc_SetFlash("gMouseUp", 0)
  c_Interface_MouseDown = 1
end

on token_MouseUp
  if c_Interface_MouseDown = 1 then
    c_Interface_MouseDown = 0
    token_Idle_XY()
    misc_SetFlash("gMouseDown", 0)
    if test_DoubleClick() = 0 then
      misc_SetFlash("gMouseUp", 1)
    else
      misc_SetFlash("gMouseUp", 2)
    end if
    zero_DoubleClick()
  end if
end

on token_KeyDown
  if check_Quit_Keys_from_Interface(0) = 0 then
    K = charToNum(_key.key)
  else
    K = 81
  end if
  case K of
    81, 113, 87, 119:
      K = 81
  end case
  if (K >= 65) and (K <= 90) then
    K = K + 32
  end if
  if (pollSpecialKeys() = "100") and (K = 13) then
    K = 1313
  end if
  if (pollSpecialKeys() = "111") and (K = 107) then
    K = 9999
  end if
  misc_SetFlash("gKeyDown", K)
  misc_SetFlash("gKeyUp", 0)
  c_Interface_KeyDown = 1
end

on token_KeyUp
  if c_Interface_KeyDown = 1 then
    c_Interface_KeyDown = 0
    misc_SetFlash("gKeyDown", 0)
    misc_SetFlash("gKeyUp", 1)
  end if
end

on token_Save b, S
  saveCurrentGame()
  if b = 1 then
    finally_Quit()
  end if
end

on token_DeActivate
  deActivateInterface()
  _movie.go("T-FOCUS")
end

on token_Activate
  _movie.go(_movie.frame)
  if playMode = pmActivate then
    _Launch_Tokens(0, 0)
  end if
end

on tokenHelp_PrepInit
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

on tokenHelp_ExitInit
  if misc_GetFlash("gListener", 1) <> 666 then
    _movie.go(_movie.frame)
  else
    playMode = pmPlay
    tokenHelp_Interface()
    setDirectToStage(cActiveSN)
  end if
end

on tokenHelp_PrepPlay
  if playMode = pmPlay then
    setMouseIdle()
    sendMouseKeyChunk()
    pollShiftKey()
  end if
end

on tokenHelp_ExitPlay
  case playMode of
    pmPlay:
      if the mouseDownScript <> "tokenHelp_MouseDown" then
        tokenHelp_Interface()
      end if
      pollFlashRequest()
    pmSave:
      check_No_Interface()
    pmDeActivate:
      check_DeActivate_Interface()
    pmActivate:
      tokenHelp_Interface()
      _Test_Activate("tokenHelp_MouseDown", 1)
  end case
  pollFlashRequest()
  pollShiftKey()
  _movie.go(_movie.frame)
end

on tokenHelp_Interface
  c_Interface_Mode = 6
  _player.flushInputEvents()
  set the mouseDownScript to "tokenHelp_MouseDown"
  set the mouseUpScript to "tokenHelp_MouseUp"
  set the keyDownScript to "tokenHelp_KeyDown"
  set the keyUpScript to "tokenHelp_KeyUp"
  _player.cursor(-1)
end

on tokenHelp_MouseDown
  setMouseDown()
end

on tokenHelp_MouseUp
  setMouseIdle()
  misc_SetFlash("pMouseDown", 0)
  misc_SetFlash("pMouseUp", 1)
end

on tokenHelp_KeyDown
  if escapeKey("ESC ignore") = 1 then
    exit
  end if
  misc_SetFlash("pKeyDown", 1)
end

on tokenHelp_KeyUp
end
