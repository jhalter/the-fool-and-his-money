global cPrologue, cGameMenus, cActiveSN, c_Interface_Mode, currRollOver, lastRollOver, currMenuDisplay, currPuzzle, pStat, playMode, pmZero, pmPlay, pmHelp, pmClick, pmSave, pmDeActivate, pmActivate

on pro_Play_1
  init_Window_Title("The Prologue")
  misc_HidePuzzleSprites()
  pro_Interface()
  _player.cursor(-1)
  playMode = pmZero
  currRollOver = 0
  lastRollOver = 0
  currMenuDisplay = 0
  noCommandKeys()
  misc_ClearQueue(0)
  setDirectToStage(1)
  misc_SetFlashVolume(1, 65)
  sprite(1).goToFrame(1)
  sprite(1).visible = 1
  sprite(1).stop()
  misc_SetFlashVolume(2, 65)
  sprite(2).goToFrame(1)
  sprite(2).visible = 1
  sprite(2).play()
end

on pro_Play_2
  case playMode of
    pmDeActivate:
      pro_DeActivate()
    otherwise:
      cActiveSN = 2
      if misc_GetFlash("prologueCue", 1) = 1 then
        sprite(1).play()
      else
        _movie.go(_movie.frame)
      end if
  end case
end

on pro_Play_3
  case playMode of
    pmDeActivate:
      pro_DeActivate()
    otherwise:
      cActiveSN = 1
      if misc_GetFlash("prologueCue", 1) = 2 then
        sprite(1).visible = 0
        sprite(2).visible = 0
        _movie.go("PRO-2")
      else
        _movie.go(_movie.frame)
      end if
  end case
end

on pro_Play_4
  case playMode of
    pmDeActivate:
      pro_DeActivate()
    otherwise:
      setDirectToStage(1)
      cActiveSN = 1
      if misc_GetFlash("prologueCue", 1) = 1 then
        misc_SetFlashVolume(1, 60)
        sprite(1).visible = 1
        sprite(1).goToFrame(1)
        sprite(1).play()
        misc_SetFlash("prologueCue", 2)
      end if
      if misc_GetFlash("prologueCue", 1) = 3 then
        misc_SetFlashVolume(2, 0)
        sprite(2).visible = 1
        exit
      end if
      _movie.go(_movie.frame)
  end case
end

on pro_Play_5
  case playMode of
    pmDeActivate:
      pro_DeActivate()
    otherwise:
      cActiveSN = 1
      if misc_GetFlash("prologueCue", 1) = 4 then
        sprite(2).setFlashProperty("dim1", #visible, 1)
        sprite(2).setFlashProperty("dim2", #visible, 1)
        sprite(2).setFlashProperty("dim3", #visible, 1)
      else
        _movie.go(_movie.frame)
      end if
  end case
end

on pro_Play_6
  case playMode of
    pmDeActivate:
      pro_DeActivate()
    otherwise:
      cActiveSN = 1
      if misc_GetFlash("prologueCue", 1) = 5 then
        sprite(2).setFlashProperty("dim2", #visible, 0)
        sprite(2).setFlashProperty("and1", #visible, 0)
        sprite(2).setFlashProperty("and2", #visible, 0)
      else
        _movie.go(_movie.frame)
      end if
  end case
end

on pro_Play_7
  case playMode of
    pmDeActivate:
      pro_DeActivate()
    otherwise:
      cActiveSN = 1
      if misc_GetFlash("prologueCue", 1) = 6 then
        pStat[cPrologue] = 100
        pro_Abort()
      else
        _movie.go(_movie.frame)
      end if
  end case
end

on pro_Play_8
  _movie.go(_movie.frame)
  if playMode = pmZero then
    initLaunch(cGameMenus, 0)
  end if
end

on pro_Interface
  c_Interface_Mode = 3
  _player.flushInputEvents()
  set the mouseDownScript to "pro_Abort"
  set the mouseUpScript to "pro_Abort"
  set the keyDownScript to "pro_Abort"
  set the keyUpScript to "pro_Abort"
  _player.cursor(-1)
end

on pro_Zero_Variables
  cActiveSN = 2
  misc_SetFlash("prologueCue", 0)
  cActiveSN = 1
  misc_SetFlash("prologueCue", 0)
end

on pro_Abort
  if escapeKey("ESC ignore") = 1 then
    exit
  end if
  pro_Zero_Variables()
  initLaunch(cGameMenus, 0)
end

on pro_DeActivate
  pro_Zero_Variables()
  noInterface()
  _movie.go("P-FOCUS")
end

on pro_Activate
  _movie.go(_movie.frame)
  if playMode = pmActivate then
    initLaunch(cGameMenus, 0)
  end if
end

on pro_Quit
  currPuzzle = 99
  _movie.go(_movie.frame)
  if playMode = pmActivate then
    initLaunch(cGameMenus, 0)
  end if
end
