global theDirectorVersion, cSwords1, cSwords2, cWands1, cWands2, cCups1, cCups2, cPentacles1, cPentacles2, cMansion1, cMansion2, cPrologue, cPreFinale, cPreHP, cEndHP, cHighPriestess, cSevenCups, cMoonMorph, cMoonsMap, cMoonsPuzzles, cGameMenus, cMenuSN, cTokens, cFinale, cActiveSN, cOpenGameNum, cHelpTokens, currGame, currPuzzle, currMenuDisplay, r1, r2, r3, R4, _Save_Type, menuStat, menu_Key, menu_HiliteCountDown, menu_Adjust, menu_Visible, cForwardSN, cReverseSN, F_Arrow_Active, R_Arrow_Active, fName, pStat, pFrame, pMenu, pClickToContinue, theDataStatus, saveMenuPreClick, playMode, pmZero, pmPlay, pmHelp, pmClick, pmSave, pmActivate, menuClick_Count, menuClick_Array

on menu_Init N
  case N of
    cHelpTokens:
      menu_Adjust = 9
    91, 92, 93, 94, 95, 96, 99, 666:
      menu_Adjust = 9
    97, 98:
      menu_Adjust = 18
    90:
      menu_Adjust = 27
    otherwise:
      menu_Adjust = 0
  end case
  menu_Visible = 1
  if sprite(cActiveSN).height = 600 then
    menu_Visible = 0
  end if
  misc_VisStaticSprite(cMenuSN, menu_Visible)
  sprite(cMenuSN).locH = 400
  sprite(cMenuSN).locV = 590
  menu_Set_Items()
  menu_ClickToContinue(0)
  menu_SavingGame(0)
  sprite(cMenuSN).setVariable("gMenuFrame", "666")
end

on menu_Set_Items
  if menu_Visible = 1 then
    menu_Frame(1)
    menu_Key = pMenu[currPuzzle]
    repeat with x = 1 to 8
      if menu_Key.char[x] = "-" then
        sprite(cMenuSN).setFlashProperty("m" & x, #visible, 0)
        next repeat
      end if
      sprite(cMenuSN).setFlashProperty("m" & x, #visible, 1)
    end repeat
    menu_Frame(1)
  end if
end

on menu_MouseOver posX, posY
  if menu_Visible = 1 then
    N = 0
    repeat with x = 1 to 8
      if (posX >= r1[x]) and (posX <= r3[x]) then
        N = x
      end if
    end repeat
    if pClickToContinue = 1 then
      if (N > 4) and (N < 8) then
        N = 0
      end if
    end if
    menu_Display(N)
  end if
end

on menu_Poll_KeyCommand PK, K, saveCurrent
  if (PK = "100") or (PK = "010") or (PK = "001") then
    K = menu_KeyCommand(K, saveCurrent)
  end if
  return K
end

on menu_Display N
  if menu_Visible = 1 then
    currMenuDisplay = N
    if N = 0 then
      menu_Frame(1)
    else
      if menu_Key.char[N] = "-" then
        currMenuDisplay = 0
        menu_Frame(1)
      else
        menu_Frame(currMenuDisplay + 1)
      end if
    end if
  end if
end

on menu_ExitDisplay
  if menu_Visible = 1 then
    if playMode <> pmHelp then
      menu_Frame(1)
      currMenuDisplay = 0
    end if
    if playMode = pmClick then
      menu_SetFlashProperty_ClickToContinue()
    end if
  end if
end

on menu_KeyCommand K, saveCurrent
  if menu_Visible = 1 then
    CK = 0
    case K of
      84, 116:
        CK = 1
      77, 109:
        CK = 2
      80, 112:
        CK = 3
      83, 115:
        CK = 4
      72, 104:
        CK = 5
      82, 114:
        CK = 6
      85, 117, 90, 122:
        CK = 7
      81, 113:
        CK = 8
      126:
        if theDataStatus = 1 then
          if pClickToContinue = 0 then
            K = 0
            misc_SetFlash("gFlashCommand", 9)
          else
          end if
        end if
    end case
    if CK > 0 then
      if menu_Key.char[CK] <> "-" then
        menu_Display(CK)
        menu_Action(1, saveCurrent)
      end if
      return 0
    end if
  else
    return 0
  end if
  return K
end

on menu_Action fromKey, saveCurrent
  if menu_Visible = 1 then
    if currMenuDisplay > 0 then
      if menu_Key.char[currMenuDisplay] <> "-" then
        PK = pollSpecialKeys()
        case currMenuDisplay of
          1:
            if theDirectorVersion = 10 then
              if (PK = "111") and (currGame > 0) then
                openFoolFileCliff(currGame)
                exit
              end if
            end if
            menu_Click_Snd()
            initLaunch(cTokens, saveCurrent)
          2:
            menu_Click_Snd()
            initLaunch(cGameMenus, saveCurrent)
          3:
            menu_Click_Snd()
            if pStat[cMoonsMap] < 100 then
              initLaunch(cMoonsMap, saveCurrent)
            else
              initLaunch(cMoonsPuzzles, saveCurrent)
            end if
          4:
            menu_Click_Snd()
            if theDirectorVersion = 10 then
              if PK = "111" then
                if saveAsFoolFileCliff(currGame) = 0 then
                  exit
                end if
              end if
            end if
            _Set_Save_Mode(2, 1)
          5:
            if theDirectorVersion = 10 then
              if (PK = "111") and (currGame > 0) then
                _movie.go(4)
                getRevertFoolFile(currGame)
                exit
              end if
            end if
            menu_Click_Snd()
            help_Show()
          6:
            misc_SetFlash("gFlashCommand", 6)
            if fromKey = 1 then
              menu_Display(6)
              menu_HiliteCountDown = 10
            end if
          7:
            misc_SetFlash("gFlashCommand", 7)
            if fromKey = 1 then
              menu_Display(7)
              menu_HiliteCountDown = 10
            end if
          8:
            menu_Click_Snd()
            trigger_Quit_Game("menu")
          9:
        end case
      end if
    end if
  end if
end

on menu_Frame N
  misc_UpdateStaticSprite(cMenuSN, menu_Adjust + N, 1)
  if N = 1 then
    if F_Arrow_Active = 1 then
      misc_UpdateStaticSprite(cForwardSN, 1, 1)
    end if
    if R_Arrow_Active = 1 then
      misc_UpdateStaticSprite(cReverseSN, 1, 1)
    end if
  end if
end

on menu_pmPlay_Poll_ClickToContinue
  S = misc_GetFlash("gClickToContinue", 0)
  b = misc_StringToBoolean(S)
  if b <> pClickToContinue then
    if b = 1 then
      saveMenuPreClick = misc_GetFlash("gClickString", 0)
    end if
    menu_ClickToContinue(b)
  end if
end

on menu_pmClick_Poll_SpecialKeys PK, K, saveCurrent
  K = menu_Poll_KeyCommand(PK, K, saveCurrent)
  if K = 0 then
    exit
  end if
  Q = launch_SpecialKeys(K)
  if (launch_GameKey(K) = 0) and (Q = 0) then
    menu_ClickToContinue(0)
  end if
end

on menu_SetFlashProperty_ClickToContinue
  sprite(cMenuSN).setFlashProperty("clickText", #visible, pClickToContinue)
  if pClickToContinue = 0 then
    sprite(cMenuSN).setFlashProperty("clickBG", #visible, 0)
    sprite(cMenuSN).setFlashProperty("clickBG-Full", #visible, 0)
  else
    if menu_Key <> "--------" then
      sprite(cMenuSN).setFlashProperty("clickBG", #visible, 1)
      sprite(cMenuSN).setFlashProperty("clickBG-Full", #visible, 0)
    else
      sprite(cMenuSN).setFlashProperty("clickBG", #visible, 0)
      sprite(cMenuSN).setFlashProperty("clickBG-Full", #visible, 1)
    end if
  end if
end

on menu_ClickToContinue b
  pClickToContinue = b
  if cActiveSN = 1 then
    sprite(cActiveSN).setVariable("gClickToContinue", string(pClickToContinue))
  end if
  menu_Display(0)
  menu_SetFlashProperty_ClickToContinue()
  if pClickToContinue = 0 then
    if saveMenuPreClick.length = 8 then
      pMenu[currPuzzle] = saveMenuPreClick
      menu_Set_Items()
    end if
    saveMenuPreClick = EMPTY
    playMode = pmPlay
  else
    if menu_Key = "--------" then
      sprite(cMenuSN).setFlashProperty("clickText", #posX, 300)
    else
      if saveMenuPreClick = EMPTY then
        saveMenuPreClick = pMenu[currPuzzle]
      end if
      pMenu[currPuzzle] = "1234---8"
      menu_Set_Items()
      sprite(cMenuSN).setFlashProperty("clickText", #posX, 448)
    end if
    playMode = pmClick
  end if
end

on menu_SavingGame b
  sprite(cMenuSN).setFlashProperty("saveText", #visible, b)
  sprite(cMenuSN).setFlashProperty("saveBG", #visible, b)
  menu_Display(0)
end

on menu_Click_Snd
  menuClick_Count = menuClick_Count + 1
  if menuClick_Count > 9 then
    menuClick_Count = 1
  end if
  misc_SndFlash(menuClick_Array[menuClick_Count], 100)
end

on menu_No_Go_Snd
  misc_SndFlash(10, 30)
end
