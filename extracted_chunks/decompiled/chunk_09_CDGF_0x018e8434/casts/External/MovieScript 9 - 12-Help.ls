global cActiveSN, cHelpSN, pHelp, currPuzzle, directToScreenHelp, cFinale, playMode, pmZero, pmPlay, pmHelp, pmClick, pmSave, pmActivate

on help_Init
  directToScreenHelp = 0
  _Set_DirectorInControl(cHelpSN)
  misc_VisStaticSprite(cHelpSN, 0)
  sprite(cHelpSN).locH = 402
  sprite(cHelpSN).locV = 472
end

on help_Show
  arrow_F_Show(1)
  arrow_R_Show(1)
  playMode = pmHelp
  _Set_DirectorInControl(cHelpSN)
  sprite(cActiveSN).setVariable("gHelpInProgress", "1")
  sprite(cHelpSN).setVariable("gHelpInProgress", "1")
  if sprite(cActiveSN).height = 580 then
    sprite(1).directToStage = 0
    directToScreenHelp = 666
  end if
  misc_SetFlash("gFlashCommand", 5)
  if pHelp[currPuzzle] contains "/" then
    sprite(cHelpSN).setVariable("chunkHelp", pHelp[currPuzzle])
    misc_CallSprite(cHelpSN)
    misc_VisStaticSprite(cHelpSN, 1)
  else
    _PUT("Help -" && pHelp[currPuzzle])
  end if
  misc_ClearQueue(5)
end

on help_Hide
  _Set_DirectorInControl(cHelpSN)
  sprite(cActiveSN).setVariable("gHelpInProgress", "0")
  sprite(cHelpSN).setVariable("gHelpInProgress", "0")
  misc_VisStaticSprite(cHelpSN, 0)
  misc_ClearQueue(5)
  menu_Display(0)
  if _movie.rollover() = cHelpSN then
    menu_MouseOver(_mouse.mouseH, _mouse.mouseV)
  else
    menu_ExitDisplay()
  end if
  if directToScreenHelp = 666 then
    directToScreenHelp = 5
  else
    playMode = pmPlay
  end if
end

on help_RefreshAfterClose
  if sprite(cActiveSN).directToStage = 0 then
    if directToScreenHelp = 0 then
      sprite(cActiveSN).directToStage = 1
      playMode = pmPlay
    else
      if directToScreenHelp <= 5 then
        directToScreenHelp = directToScreenHelp - 1
      end if
    end if
  end if
end
