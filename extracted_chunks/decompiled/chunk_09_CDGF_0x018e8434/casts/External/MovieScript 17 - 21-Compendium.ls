global cActiveSN, cTokens, cGameMenus, pStat, theDataStatus, c_Interface_Mode, compFrame, playMode, pmZero, pmPlay, pmHelp, pmClick, pmSave, pmDeActivate, pmActivate

on comp_Interface
  c_Interface_Mode = 4
  _player.flushInputEvents()
  set the mouseDownScript to "comp_MouseDown"
  set the mouseUpScript to "comp_MouseUp"
  set the keyDownScript to "comp_KeyDown"
  set the keyUpScript to "comp_KeyUp"
  _player.cursor(-1)
end

on comp_MouseDown
  misc_SetFlash("gMouseDown", 1)
  misc_SetFlash("gMouseUp", 0)
end

on comp_MouseUp
  misc_SetFlash("gMouseDown", 0)
  misc_SetFlash("gMouseUp", 1)
end

on comp_KeyDown
  if escapeKey("ESC ignore") = 1 then
    exit
  end if
  K = charToNum(_key.key)
  misc_SetFlash("gKeyDown", K)
  misc_SetFlash("gKeyUp", 0)
end

on comp_KeyUp
  misc_SetFlash("gKeyDown", 0)
  misc_SetFlash("gKeyUp", 1)
end

on comp_Main_Launch
  noInterface()
  _movie.go("COMP")
  init_Window_Title("The Compendium of True Believers")
end

on comp_Splash_Launch
  noInterface()
  _movie.go("SPLASH")
end

on comp_Drown_Launch
  noInterface()
  _movie.go("DROWN")
end

on comp_Main_PrepareInit
  if playMode <> pmZero then
    misc_HidePuzzleSprites()
    misc_SetFlash("pVolume", 75)
    if pStat[cGameMenus] < 90 then
      if pStat[cGameMenus] <> 25 then
        misc_SetFlash("pStat", 0)
      else
        misc_SetFlash("pStat", 25)
      end if
    else
      if pStat[cGameMenus] = 90 then
        misc_SetFlash("pStat", 50)
      else
        if pStat[cGameMenus] >= 94 then
          misc_SetFlash("pStat", 100)
        end if
      end if
    end if
  end if
end

on comp_Main_ExitInit
  if playMode <> pmZero then
    playMode = pmZero
    cActiveSN = 1
    noCommandKeys()
    misc_SetFlashVolume(cActiveSN, 80)
    comp_PollListener()
    sprite(2).static = 1
    sprite(2).visible = 1
    compFrame = 3
  end if
end

on comp_Next_Column f
  sprite(2).setVariable("which", string(f - 1))
  sprite(2).goToFrame(compFrame)
  sprite(2).stop()
  if compFrame = 3 then
    compFrame = 4
  else
    compFrame = 3
  end if
end

on comp_Splash_ExitInit
  playMode = pmZero
  cActiveSN = 1
  noCommandKeys()
  misc_SetFlashVolume(cActiveSN, 80)
  comp_PollListener()
end

on comp_Drown_ExitInit
  playMode = pmZero
  cActiveSN = 1
  noCommandKeys()
  misc_SetFlashVolume(cActiveSN, 80)
  comp_PollListener()
end

on comp_Main_ExitPlay
  if playMode = pmDeActivate then
    comp_DeActivate()
  else
    pollFlashRequest()
  end if
  _movie.go(_movie.frame)
end

on comp_Splash_ExitPlay
  if playMode = pmDeActivate then
    comp_DeActivate()
  else
    pollFlashRequest()
  end if
  _movie.go(_movie.frame)
end

on comp_Drown_ExitPlay
  if playMode = pmDeActivate then
    comp_DeActivate()
  else
    pollFlashRequest()
  end if
  if pStat[cGameMenus] < 94 then
    updateStatCompendiumToMoonMenu()
  end if
  _movie.go(_movie.frame)
end

on comp_PollListener
  misc_ClearQueue(0)
  if misc_GetFlash("gListener", 1) <> 666 then
    _movie.go(_movie.frame)
  else
    playMode = pmPlay
    comp_Interface()
    setDirectToStage(1)
  end if
end

on comp_DeActivate
  noInterface()
  _movie.go("C-FOCUS")
end

on comp_Activate
  _movie.go(_movie.frame)
  if playMode = pmActivate then
    initLaunch(cGameMenus, 0)
  end if
end
