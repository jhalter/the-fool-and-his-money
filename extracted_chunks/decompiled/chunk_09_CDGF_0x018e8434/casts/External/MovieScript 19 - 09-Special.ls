global cMoneySN, pData, _Save_Type, currPuzzle, currGame, cTypeCurrPuzzle, tokenCurrGame, cGameDirectory, cWork, cLink, playMode, pmZero, pmPlay, pmHelp, pmClick, pmSave, pmDeActivate, pmActivate, pClickToContinue, _StartUp_Switched, _Window_Switched, status_Quit_The_Game

on money_Init
  if sprite(cMoneySN).memberNum > 0 then
    sprite(cMoneySN).locH = 55
    sprite(cMoneySN).locV = 585
    misc_VisStaticSprite(cMoneySN, 0)
  end if
end

on deactivateApplication
  _Game_DeActivate("app")
end

on deactivateWindow
  _Game_DeActivate("sys")
end

on _Check_for_StartUp_Switched
  if _StartUp_Switched = 1 then
    _StartUp_Switched = 0
    _Game_DeActivate("_Switch")
  end if
end

on _Game_DeActivate S
  _Window_Switched = 1
  status_Quit_The_Game = 0
  if _movie.frame < 5 then
    _StartUp_Switched = 1
    exit
  end if
  _PUT("De-Activate" && S)
  playMode = pmDeActivate
  deActivateInterface()
  _Set_Ticks(0)
  misc_SetFlash("gSwitchWindows", string(1))
end

on deActivateInterface
  _player.flushInputEvents()
  set the mouseDownScript to "deActivate_MouseDown"
  set the mouseUpScript to EMPTY
  set the keyDownScript to "deActivate_KeyDown"
  set the keyUpScript to EMPTY
  _player.cursor(-1)
end

on check_DeActivate_Interface
  if the mouseDownScript <> "deActivate_MouseDown" then
    deActivateInterface()
  end if
end

on deActivate_MouseDown
  if _Window_Switched = 1 then
    _Game_Activate("click")
  end if
end

on deActivate_KeyDown
  if escapeKey("ESC ignore") = 1 then
    exit
  end if
  if _Window_Switched = 1 then
    _Game_Activate("key")
  end if
end

on activateApplication
  _Game_Activate("app")
end

on activateWindow
  _Game_Activate("sys")
end

on _Game_Activate S
  _Window_Switched = 0
  status_Quit_The_Game = 0
  if _movie.frame < 5 then
    _StartUp_Switched = 0
    exit
  end if
  _PUT("Activate" && S)
  cActiveSN = 1
  misc_ClearQueue(0)
  misc_SetFlash("gMouseX", -10)
  misc_SetFlash("gMouseY", -10)
  misc_SetFlash("gIdleX", -10)
  misc_SetFlash("gIdleY", -10)
  misc_SetFlash("gShiftKey", 0)
  misc_SetFlash("gMouseDown", 0)
  misc_SetFlash("gMouseUp", 0)
  misc_SetFlash("gSwitchWindows", string(0))
  c_Interface_MouseDown = 0
  zero_DoubleClick()
  c_Interface_KeyDown = 0
  _Set_Ticks(0)
  playMode = pmActivate
end

on _Test_Activate S, notTokens
  if the mouseDownScript = S then
    misc_SetFlash("gSwitchWindows", string(0))
    if notTokens = 0 then
      playMode = pmPlay
    else
      if pClickToContinue = 0 then
        if _Save_Type = 0 then
          playMode = pmPlay
        else
          playMode = pmSave
        end if
      else
        menu_SetFlashProperty_ClickToContinue()
        playMode = pmClick
      end if
    end if
  end if
end

on closeRequest
  if _movie.frame < 4 then
    finally_Quit()
  else
    if the mouseDownScript <> "token_MouseDown" then
      trigger_Quit_Game("close")
    else
      misc_SetFlash("gKeyDown", 113)
      misc_SetFlash("gKeyUp", 0)
    end if
  end if
end

on poll_Quit_Keys
  if _key.commandDown = 1 then
    if _key.key = "q" then
      _PUT("QUIT - CTRL q")
      return 1
    end if
    if _key.key = "w" then
      _PUT("QUIT - CTRL w")
      return 1
    end if
  end if
  if escapeKey("ESC - Quit") = 1 then
    return 1
  end if
  return 0
end

on check_Quit_Keys_from_Interface b
  if poll_Quit_Keys() = 1 then
    if b = 1 then
      trigger_Quit_Game("keys")
    end if
    return 1
  end if
  return 0
end

on trigger_Quit_Game S
  _PUT("QUIT" && S)
  status_Quit_The_Game = 1
  _Set_Save_Mode(3, 0)
end

on check_Save_Before_Quit
  if compareLastSavedGameData() = 1 then
    update_Double_Secret()
  else
    _Launch_Tokens(1, 0)
  end if
end

on update_Double_Secret
  if cTypeCurrPuzzle = 1 then
    tokenCurrGame = misc_GetFlash("currentGame", 1)
    if tokenCurrGame <> currGame then
      currGame = tokenCurrGame
    end if
  end if
  putLastGamePref(currGame)
  finally_Quit()
end

on finally_Quit
  _PUT("QUIT Game")
  if (cGameDirectory = cWork) or (cGameDirectory = cLink) then
    _movie.halt()
  else
    _player.quit()
  end if
end

on special_CheckCastMembers
  if (cGameDirectory <> cWork) and (cGameDirectory <> cLink) then
    exit
  end if
  if 0 = 666 then
    Q = numToChar(34)
    c1 = list(1, 2, 3, 10, 15, 16, 20, 21, 30, 31, 32, 40, 41, 43, 45, 50, 51, 52, 60, 65, 72, 75, 76, 77, 78, 80, 81, 82, 89)
    c2 = list(90, 91, 92, 93, 94, 97, 98, 99, 100, 101, 102, 103, 104)
    repeat with y = 1 to the number of words in string(c1)
      CC = EMPTY & c1[y]
      if c1[y] < 10 then
        CC = "0" & CC
      end if
      repeat with x = 1 to 100
        S = member(x, CC).name
        if S <> EMPTY then
          _PUT("special_VerifyCast(" & Q & CC & Q & "," && Q & S & Q & ")")
        end if
      end repeat
    end repeat
    repeat with y = 1 to the number of words in string(c2)
      CC = EMPTY & c2[y]
      if c2[y] < 10 then
        CC = "0" & CC
      end if
      repeat with x = 1 to 100
        S = member(x, CC).name
        if S <> EMPTY then
          _PUT("special_VerifyCast(" & Q & CC & Q & "," && Q & S & Q & ")")
        end if
      end repeat
    end repeat
    halt()
  end if
  special_VerifyCast("00", "zip-code")
  special_VerifyCast("00", "zip-mark")
  special_VerifyCast("01", "_prologue1")
  special_VerifyCast("01", "_prologue2")
  special_VerifyCast("01", "_scroll-1")
  special_VerifyCast("01", "_scroll-2")
  special_VerifyCast("01", "_P-Focus")
  special_VerifyCast("01", "1 - play prologue")
  special_VerifyCast("01", "2 - wait then advance")
  special_VerifyCast("01", "3 - wait then advance")
  special_VerifyCast("01", "4 - set DTS")
  special_VerifyCast("01", "5 - 1st shot ends")
  special_VerifyCast("01", "6 - hands up")
  special_VerifyCast("01", "7 - wait then end")
  special_VerifyCast("01", "8 - P-Focus")
  special_VerifyCast("02", "_4x4")
  special_VerifyCast("03", "_jumble")
  special_VerifyCast("10", "_code-grid")
  special_VerifyCast("15", "_phrase")
  special_VerifyCast("16", "_concat")
  special_VerifyCast("20", "_crossSlide")
  special_VerifyCast("21", "_fill-in")
  special_VerifyCast("30", "_patchwork")
  special_VerifyCast("31", "_stamp")
  special_VerifyCast("32", "_slider")
  special_VerifyCast("40", "_morph")
  special_VerifyCast("41", "_morph-text")
  special_VerifyCast("43", "_herbs")
  special_VerifyCast("44", "_tracer")
  special_VerifyCast("45", "_market")
  special_VerifyCast("50", "_coins")
  special_VerifyCast("51", "_inventory")
  special_VerifyCast("52", "_halves")
  special_VerifyCast("60", "_sevens")
  special_VerifyCast("65", "_auction")
  special_VerifyCast("72", "_pre-Finale")
  special_VerifyCast("75", "_passwords")
  special_VerifyCast("75", "_DEL-stub")
  special_VerifyCast("76", "_hex-words")
  special_VerifyCast("76", "_HEX-stub")
  special_VerifyCast("77", "_unnecessary")
  special_VerifyCast("77", "_REM-stub")
  special_VerifyCast("78", "_connects")
  special_VerifyCast("80", "_pre-HP")
  special_VerifyCast("80", "_end-HP")
  special_VerifyCast("81", "_HP")
  special_VerifyCast("82", "_seven-cups")
  special_VerifyCast("89", "_wager")
  special_VerifyCast("90", "_tarot-1")
  special_VerifyCast("91", "_tarot-2")
  special_VerifyCast("92", "_tarot-3")
  special_VerifyCast("93", "_tarot-4")
  special_VerifyCast("94", "_tarot-5")
  special_VerifyCast("97", "_map-puzzles")
  special_VerifyCast("98", "_map")
  special_VerifyCast("99", "_game-menu")
  special_VerifyCast("100", "_screen")
  special_VerifyCast("100", "_tokens")
  special_VerifyCast("100", "_tokens-help")
  special_VerifyCast("100", "_T-Focus")
  special_VerifyCast("100", "1 - tokens-load")
  special_VerifyCast("100", "2 - tokens-loop")
  special_VerifyCast("100", "3 - help-load")
  special_VerifyCast("100", "4 - help-loop")
  special_VerifyCast("100", "5 - T-Focus")
  special_VerifyCast("101", "_drown")
  special_VerifyCast("101", "_list")
  special_VerifyCast("101", "_roll")
  special_VerifyCast("101", "_splash")
  special_VerifyCast("101", "_C-Focus")
  special_VerifyCast("101", "1 - COMP - init")
  special_VerifyCast("101", "2 - COMP - loop")
  special_VerifyCast("101", "3 - SPLASH - init")
  special_VerifyCast("101", "4 - SPLASH - loop")
  special_VerifyCast("101", "5 - DROWN - init")
  special_VerifyCast("101", "6 - DROWN - loop")
  special_VerifyCast("101", "7 - C-Focus")
  special_VerifyCast("101", "compendium")
  special_VerifyCast("101", "miscellaneous")
  special_VerifyCast("102", "_arrow-F")
  special_VerifyCast("102", "_arrow-R")
  special_VerifyCast("102", "_help")
  special_VerifyCast("102", "_menu")
  special_VerifyCast("102", "_money")
  special_VerifyCast("102", "_scroll")
  special_VerifyCast("102", "1 - load")
  special_VerifyCast("102", "2 - loop")
  special_VerifyCast("103", "01-Initialization")
  special_VerifyCast("103", "02-Misc")
  special_VerifyCast("103", "03-Launch")
  special_VerifyCast("103", "04-Read/Write")
  special_VerifyCast("103", "05-Requests")
  special_VerifyCast("103", "06-Update-Stats")
  special_VerifyCast("103", "07-Data")
  special_VerifyCast("103", "08-StartUp")
  special_VerifyCast("103", "09-Special")
  special_VerifyCast("103", "10-Menu")
  special_VerifyCast("103", "11-Arrows")
  special_VerifyCast("103", "12-Help")
  special_VerifyCast("103", "20-Tokens")
  special_VerifyCast("103", "21-Compendium")
  special_VerifyCast("103", "22-Prologue")
  special_VerifyCast("103", "23-Puzzles")
  special_VerifyCast("103", "24-Finale")
  special_VerifyCast("104", "_finale-01")
  special_VerifyCast("104", "_finale-02")
  special_VerifyCast("104", "_finale-09")
  special_VerifyCast("104", "_finale-13")
  special_VerifyCast("104", "_finale-17")
  special_VerifyCast("104", "_finale-18")
  special_VerifyCast("104", "_finale-19")
  special_VerifyCast("104", "1 - f - load")
  special_VerifyCast("104", "2 - f - loop")
end

on special_VerifyCast c, M
  if M.char[1] = "_" then
    member(M, c).preload = 1
    if cGameDirectory = cWork then
      member(M, c).linked = 1
    end if
    if cGameDirectory = cLink then
      member(M, c).linked = 0
    end if
  end if
  if word 2 of string(member M of castLib c) = "-1" then
    _PUT("FALSE" && c && M)
    return 0
  end if
  return 1
end
