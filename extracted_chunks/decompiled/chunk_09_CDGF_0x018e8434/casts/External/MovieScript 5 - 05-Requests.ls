global cMenuSN, cRevGameNum, cNewGameNum, cPreFinale, cTokens, cPreHP, cEndHP, cHighPriestess, cSevenCups, cGameMenus, cFinale, cHelpTokens, cMoonsMap, cMoonsPuzzles, pStat, pHelp, pMenu, pMiscellaneous, pInfo, pFrame, pTransition, pPage, fName, fData, currGame, currPuzzle, lastPuzzle, theRequest, requestBlock, menuName, menuStat, token1, token2, token3, csWager, csTarot, csWagerTarot, tokens_LastPuzzle, tokens_CurrentGame, tokens_NeedToSave, status_First_Launch

on initRequest S
  requestBlock = requestBlock & S
end

on extractRequest b
  if requestBlock <> EMPTY then
    n1 = 1
    n2 = 1
    repeat while requestBlock.char[n2..n2] <> "|"
      n2 = n2 + 1
    end repeat
    S = requestBlock.char[n1..n2 - 1]
    requestBlock = requestBlock.char[n2 + 1..requestBlock.length]
    if b = 0 then
      return S
    else
      return integer(S)
    end if
  end if
end

on _Launch_From_Map b
  menu_Click_Snd()
  N = extractRequest(1)
  repeat with x = 1 to 5
    if N = csWager[x] then
      csWagerTarot[x] = csWager[x]
    end if
  end repeat
  initLaunch(N, 1)
  if b = 1 then
    pTransition = 9
  end if
end

on doSpecialRequests
  theRequest = extractRequest(1)
  case theRequest of
    0:
      misc_SetFlash("gFlashCommand", 0)
    1:
      _Launch_From_Map(1)
    2:
      _Launch_From_Map(0)
    3:
      Q = extractRequest(1)
      updateGameStats(currGame)
    4:
      initLaunch(cMoonsMap, 1)
      pTransition = 9
    5:
      initLaunch(cMoonsPuzzles, 1)
      pTransition = 9
    6:
      initLaunch(cSevenCups, 1)
      pTransition = 9
    7:
      pPage[cPreFinale] = 2
      initLaunch(cPreFinale, 1)
      pTransition = 9
    8:
      menu_Click_Snd()
      initLaunch(extractRequest(1), 1)
      pTransition = 9
    9:
      menu_Click_Snd()
      initLaunch(extractRequest(1), 1)
    10:
      initLaunch(extractRequest(1), 1)
    13:
      misc_CalcPage(extractRequest(1))
    14:
      pHelp[currPuzzle] = extractRequest(0)
    17:
      saveCurrentPuzzle()
      updateGameStats(currGame)
      misc_SetFlash("pInfo", pInfo)
    18:
      menu_Click_Snd()
      menu_Frame(2)
      initLaunch(cPreHP, 1)
    19:
      S = extractRequest(0)
      if S.length = 8 then
        if S <> pMenu[currPuzzle] then
          pMenu[currPuzzle] = S
          menu_Set_Items()
        end if
      end if
    20:
      N = misc_GetFlash("gStat", 1)
      _Set_Game_Menu_Status(N)
      _PUT("Menu" && pStat[cGameMenus])
      menu_Click_Snd()
      _movie.puppetTransition(9, 1, 20, 0)
      comp_Main_Launch()
    21:
      comp_Next_Column(extractRequest(1))
    22:
      if pStat[cGameMenus] < 94 then
        comp_Splash_Launch()
      else
        comp_Drown_Launch()
      end if
    23:
      comp_Drown_Launch()
    24:
      _movie.puppetTransition(9, 1, 20, 0)
      initLaunch(cGameMenus, 0)
    25:
      _movie.puppetTransition(9, 1, 20, 0)
      initLaunch(cGameMenus, 0)
    30:
      initLaunch(cFinale, 1)
    31:
      fin_Play()
    88:
      initLaunch(cGameMenus, 1)
      pTransition = 9
    89:
      _Set_Game_Menu_Status(69)
      initLaunch(cHighPriestess, 1)
    90:
      initLaunch(cEndHP, 1)
    91:
      pStat[3] = 190
      initLaunch(3, 1)
    95:
      menu_Click_Snd()
      N = extractRequest(1)
      csWagerTarot[N] = csTarot[N]
      initLaunch(csWagerTarot[N], 1)
    96:
      menu_Click_Snd()
      _Update_Solved_Tarot()
      N = extractRequest(1)
      csWagerTarot[N] = csWager[N]
      initLaunch(csWagerTarot[N], 1)
    97:
    98:
      menu_Click_Snd()
      initLaunch(cMoonsPuzzles, 1)
    99:
      initLaunch(cGameMenus, 1)
    cTokens:
      case extractRequest(1) of
        1:
          n1 = extractRequest(1)
          n2 = extractRequest(1)
          if status_First_Launch = 0 then
            if n2 = 0 then
              launchGame(n1, 1)
            else
              initLaunch(lastPuzzle, 0)
            end if
          else
            status_First_Launch = 0
            launchGame(n1, 1)
          end if
        2:
        3:
          n1 = extractRequest(1)
          n2 = extractRequest(1)
          currGame = n1
          token_Save(0, "YES")
          putLastGamePref(n2)
        4:
          n1 = extractRequest(1)
          n2 = extractRequest(1)
          if token3[cRevGameNum] = 1 then
            token2[cRevGameNum] = "Your fortune awaits."
          end if
          copyTokens(n1, cRevGameNum)
          putLastGamePref(n2)
        5:
          getRevertFoolFile(extractRequest(1))
        6:
          eraseFoolFile(extractRequest(1))
        7:
          eraseAllFoolFiles()
        8:
          token_Save(1, "Save/Quit")
        9:
          update_Double_Secret()
        10:
          initLaunch(lastPuzzle, 0)
        11:
          token_Save(0, "Save")
        12:
        13:
        14:
        15:
          gotoNetPage("http://www.thefoolandhismoney.com/07-Hints/index.htm", "_new")
        16:
          tokens_LastPuzzle = currPuzzle
          tokens_CurrentGame = extractRequest(1)
          tokens_NeedToSave = extractRequest(1)
          initLaunch(cHelpTokens, 0)
        17:
          pStat[cHelpTokens] = 0
          token_RestoreSaved()
          initLaunch(cTokens, 0)
      end case
    otherwise:
      repeat with x = 1 to 17
        _PUT("NO" && theRequest)
      end repeat
  end case
end
