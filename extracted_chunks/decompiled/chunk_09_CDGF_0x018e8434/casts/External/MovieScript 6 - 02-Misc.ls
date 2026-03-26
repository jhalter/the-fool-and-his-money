global theDirectorVersion, csDEL, csHEX, csREM, csMansion, titleName, cActiveSN, cScrollSN, cHelpSN, cMenuSN, cForwardSN, cReverseSN, cInitFreeBytes, cInitMemorySize, pNum, pStat, pData, pPage, pMenu, pInfo, pSeven, pMiscellaneous, pVolume, chunkMenuStat, pSwords, pWands, pCups, pPentacles, pTotalSwords, pTotalWands, pTotalCups, pTotalPentacles, pWordStat63, pVolumeOff, pClickToContinue, pTraceMenu, theDataStatus, token1, token2, token3, menu_Key, currMenuDisplay, startTicks, CR, QU, rectTotal, r1, r2, r3, R4, currRollOver, lastRollOver, currPuzzle, nextPuzzle, loadPuzzleCount, requestBlock, menu_HiliteCountDown, _Save_Type, _Save_Stat, mouseChunk, lastMouseX, lastMouseY, keyChunk, activity_Array, activity_Count, activity_Total, activity_Launch, playMode, pmZero, pmPlay, pmHelp, pmClick, pmSave, pmActivate, _Pause_Play, _Pause_Goal, menuClick_Array, menuClick_Count, snd_Channel_Array, snd_Channel_Count, c_Interface_DoubleClick, cFileIO, cTestIO

on misc_Less N, V
  if N < V then
    N = V
  end if
  return N
end

on misc_More N, V
  if N > V then
    N = V
  end if
  return N
end

on misc_StringToBoolean S
  if S = "false" then
    return 0
  end if
  if S = "true" then
    return 1
  end if
end

on misc_IncreLimits N, L1, L2
  N = N + 1
  if N > L2 then
    N = L1
  end if
  return N
end

on misc_PadNumber N, hundreds, thousands
  if N < 10 then
    S = "0" & N
  else
    S = EMPTY & N
  end if
  if (hundreds = 1) and (N < 100) then
    S = "0" & S
  end if
  if (thousands = 1) and (N < 1000) then
    S = "0" & S
  end if
  return S
end

on misc_ClearQueue N
  _player.flushInputEvents()
  requestBlock = EMPTY
  _Set_Ticks(N)
end

on misc_MakeRect x1, y1, W, h
  rectTotal = rectTotal + 1
  r1[rectTotal] = x1
  r2[rectTotal] = y1
  r3[rectTotal] = x1 + W
  R4[rectTotal] = y1 + h
end

on misc_UpdateStaticSprite L, f, b
  if (L >= cScrollSN) and (L <= cReverseSN) then
    sprite(L).goToFrame(f)
    sprite(L).stop()
    sprite(L).static = 1
    misc_VisStaticSprite(L, b)
  end if
end

on misc_VisStaticSprite L, b
  misc_NoScaleSprite(L)
  if b = 0 then
    sprite(L).static = 1
    sprite(L).visible = 0
  else
    sprite(L).static = 0
    sprite(L).visible = 1
  end if
end

on misc_NoScaleSprite L
  sprite(L).scaleMode = #noScale
end

on misc_CallSprite L
  sprite(L).callframe(1)
  sprite(L).goToFrame(1)
  sprite(L).stop()
end

on misc_SetFlash V, S
  if cActiveSN > 0 then
    if sprite(cActiveSN).memberNum > 0 then
      sprite(cActiveSN).setVariable(V, string(S))
    else
      _PUT("misc_SetFlash - " && V && "no sprite level" && cActiveSN)
    end if
  end if
end

on misc_GetFlash S, b
  if cActiveSN > 0 then
    if sprite(cActiveSN).memberNum > 0 then
      V = sprite(cActiveSN).getVariable(S)
      if b = 1 then
        V = integer(V)
      end if
    else
      showAlert(1, "misc_GetFlash", "There is nothing on sprite level" && cActiveSN)
    end if
  end if
  return V
end

on misc_SndFlash S, V
  if pVolumeOff = 0 then
    sprite(cMenuSN).setVariable("gFlashVolume", string(V))
    sprite(cMenuSN).setVariable("gFlashSound", string(S))
    sprite(cMenuSN).callframe(1)
  else
  end if
end

on misc_StopSndFlash
  sprite(cMenuSN).callframe(2)
end

on copyTokens n1, n2
  token1[n1] = token1[n2]
  token2[n1] = token2[n2]
  token3[n1] = token3[n2]
end

on sendFlashData
  misc_SetFlash("DirectorInControl", 1)
  misc_SetFlash("pNum", pNum[currPuzzle])
  misc_SetFlash("pGameNum", currPuzzle)
  misc_SetFlash("pStat", pStat[currPuzzle])
  misc_SetFlash("pData", pData[currPuzzle])
  misc_SetFlash("pMisc", pMiscellaneous)
  misc_SetFlash("pMenu", chunkMenuStat)
  misc_SetFlash("pInfo", pInfo)
  misc_SetFlash("pSeven", pSeven)
  misc_SetFlash("pVolume", pVolume[currPuzzle])
  misc_SetFlash("pSwords", pSwords[currPuzzle])
  misc_SetFlash("pWands", pWands[currPuzzle])
  misc_SetFlash("pCups", pCups[currPuzzle])
  misc_SetFlash("pPentacles", pPentacles[currPuzzle])
  misc_SetFlash("pTotalSwords", 0)
  misc_SetFlash("pTotalWands", 0)
  misc_SetFlash("pTotalCups", 0)
  misc_SetFlash("pTotalPentacles", 0)
  misc_SetFlash("pClickToContinue", pClickToContinue)
  misc_SetFlash("pTraceMenu", pTraceMenu)
  misc_SetFlash("pStatusTest", theDataStatus)
  misc_SetFlash("pIdleX", _mouse.mouseH)
  misc_SetFlash("pIdleY", _mouse.mouseV)
  loadPuzzleCount = loadPuzzleCount + 1
  if loadPuzzleCount > 7 then
    _PUT("LOAD-" & currPuzzle & "-" & loadPuzzleCount)
  end if
end

on checkRollOverStatus
  if (lastRollOver <> currRollOver) or (testMouseOffScreen() = 0) then
    if currRollOver <> cMenuSN then
      menu_ExitDisplay()
    end if
    if currRollOver <> cForwardSN then
      arrow_F_Show(1)
    end if
    if currRollOver <> cReverseSN then
      arrow_R_Show(1)
    end if
  end if
  lastRollOver = currRollOver
end

on misc_InitPuzzle
  cActiveSN = 1
  playMode = pmZero
  currRollOver = _movie.rollover()
  lastRollOver = 0
  currMenuDisplay = 0
  pClickToContinue = 0
  sprite(cActiveSN).locH = 400
  if sprite(cActiveSN).height = 320 then
    sprite(cActiveSN).locV = 160
  end if
  if sprite(cActiveSN).height = 580 then
    sprite(cActiveSN).locV = 290
  end if
  if sprite(cActiveSN).height = 600 then
    sprite(cActiveSN).locV = 300
  end if
  misc_NoScaleSprite(cActiveSN)
end

on misc_HidePuzzleSprites
  repeat with x = 3 to 8
    misc_VisStaticSprite(x, 0)
  end repeat
end

on misc_InitPage
  _Set_DirectorInControl(cScrollSN)
  b = 0
  if sprite(cActiveSN).height = 320 then
    b = 1
  end if
  misc_VisStaticSprite(cScrollSN, b)
  sprite(cScrollSN).locH = 400
  sprite(cScrollSN).locV = 450
  if b = 1 then
    misc_SetPage(pPage[currPuzzle])
  end if
end

on misc_CalcPage p
  if p >= 0 then
    p = p + 1
    if p <> pPage[currPuzzle] then
      pPage[currPuzzle] = p
      misc_SetPage(pPage[currPuzzle])
    end if
  end if
end

on misc_SetPage p
  if currPuzzle < 100 then
    S = misc_PadNumber(currPuzzle, 0, 0) & "/" & p & "/"
  else
    repeat with x = 1 to 7
      if currPuzzle = csDEL[x] then
        S = misc_PadNumber(csMansion[x], 0, 0) & "/" & p & "/"
      end if
      if currPuzzle = csHEX[x] then
        S = misc_PadNumber(csMansion[x], 0, 0) & "/" & p & "/"
      end if
      if currPuzzle = csREM[x] then
        S = misc_PadNumber(csMansion[x], 0, 0) & "/" & p & "/"
      end if
    end repeat
  end if
  _Set_DirectorInControl(cScrollSN)
  sprite(cScrollSN).setVariable("chunkPage", S)
  misc_CallSprite(cScrollSN)
end

on noInterface
  _player.flushInputEvents()
  set the mouseDownScript to EMPTY
  set the mouseUpScript to EMPTY
  set the keyDownScript to "noEscape_KeyDown"
  set the keyUpScript to EMPTY
  _player.cursor(-1)
end

on check_No_Interface
  if the mouseDownScript <> EMPTY then
    noInterface()
  end if
end

on noEscape_KeyDown
  if escapeKey("ESC ignore") = 1 then
    exit
  end if
end

on noCommandKeys
  menu_Key = "--------"
end

on pollSpecialKeys
  return string(_key.shiftDown & _key.commandDown & _key.optionDown)
end

on calcMouseChunk
  xM = _mouse.mouseH
  yM = _mouse.mouseV
  if playMode <> 1 then
    xM = 0
    yM = 0
  end if
  if (xM <> lastMouseX) or (yM <> lastMouseY) or (mouseChunk = EMPTY) then
    mouseChunk = xM & "," & yM & "," & mouseChunk
    lastMouseX = xM
    lastMouseY = yM
  end if
end

on calcKeyChunk K
  keyChunk = keyChunk & K & ","
end

on sendMouseKeyChunk
  misc_SetFlash("pMouseChunk", mouseChunk)
  misc_SetFlash("pKeyChunk", keyChunk)
  nullMouseChunk()
end

on nullMouseChunk
  mouseChunk = EMPTY
  keyChunk = EMPTY
end

on setMouseIdle
  misc_SetFlash("pIdleX", _mouse.mouseH)
  misc_SetFlash("pIdleY", _mouse.mouseV)
end

on setMouseDown
  setMouseIdle()
  misc_SetFlash("pMouseDown", 1)
  misc_SetFlash("pMouseUp", 0)
end

on testMouseOffScreen
  b = 1
  if (_mouse.mouseH < 0) or (_mouse.mouseH > 800) then
    b = 0
  end if
  if (_mouse.mouseV < 0) or (_mouse.mouseV > 600) then
    b = 0
  end if
  return b
end

on pollFlashRequest
  R = misc_GetFlash("gFlashRequest", 0)
  if R <> EMPTY then
    initRequest(R)
    repeat while requestBlock <> EMPTY
      if requestBlock <> EMPTY then
        doSpecialRequests()
      end if
    end repeat
  end if
  if menu_HiliteCountDown > 0 then
    menu_HiliteCountDown = menu_HiliteCountDown - 1
    if menu_HiliteCountDown = 0 then
      menu_Display(0)
    end if
  end if
  misc_SetFlash("gFlashRequest", EMPTY)
end

on setDirectToStage L
  if sprite(L).directToStage = 0 then
    sprite(L).directToStage = 1
  end if
end

on pollShiftKey
  if pollSpecialKeys() = "100" then
    misc_SetFlash("pShiftKey", "1")
  else
    misc_SetFlash("pShiftKey", "0")
  end if
end

on misc_SetFlashVolume N, V
  if pVolumeOff = 0 then
    obj = sprite(N).newObject("Sound")
    obj.setVolume(V)
  else
    obj = sprite(N).newObject("Sound")
    obj.setVolume(0)
  end if
end

on showAlert b, S1, s2, s3, s4, s5
  spaces = "    "
  S = S1 & spaces
  if s2 <> VOID then
    S = S & CR & CR & s2 & spaces
  end if
  if s3 <> VOID then
    S = S & CR & CR & s3 & spaces
  end if
  if s4 <> VOID then
    S = S & CR & CR & s4 & spaces
  end if
  if s5 <> VOID then
    S = S & CR & CR & s5 & spaces
  end if
  if b = 1 then
    finally_Quit()
  end if
end

on _PUT S
  if theDirectorVersion = 10 then
    put S
  end if
end

on _Set_DirectorInControl which
  sprite(which).setVariable("DirectorInControl", "1")
end

on _Set_Ticks N
  startTicks = _movie.ticks() + N
end

on init_Window_Title S
  base = "The Fool and his Money"
  theName = EMPTY
  if (currPuzzle >= 73) and (currPuzzle <= 79) then
    theName = titleName[currPuzzle]
    if pStat[currPuzzle] <= 100 then
      theName = theName & "Delivery"
    else
      if pStat[currPuzzle] <= 200 then
        theName = theName & "Hex"
      else
        if pStat[currPuzzle] <= 300 then
          theName = theName & "Remainder"
        else
          theName = theName & "Connection"
        end if
      end if
    end if
    base = base && "-" && theName
  else
    if S = "-" then
      theName = titleName[currPuzzle]
      base = base & " - " & theName
    else
      if S <> EMPTY then
        theName = S
        base = base & " - " & theName
      end if
    end if
  end if
  _PUT(theName)
  _movie.stage.title = base
end

on escapeKey S
  if the keyCode = 53 then
    _PUT(S)
    return 1
  end if
  return 0
end

on zero_DoubleClick
  c_Interface_DoubleClick = _movie.ticks()
end

on test_DoubleClick
  if (_movie.ticks() - c_Interface_DoubleClick) > 20 then
    return 0
  end if
  return 1
end
