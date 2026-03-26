global cSwords1, cSwords2, cWands1, cWands2, cCups1, cCups2, cPentacles1, cPentacles2, cMansion1, cMansion2, cPrologue, cPreFinale, cPreHP, cEndHP, cHighPriestess, cSevenCups, cMoonMorph, cMoonsMap, cMoonsPuzzles, cGameMenus, cTokens, cFinale, cPuzzleTotal, cActiveSN, cForwardSN, cReverseSN, cTarot1, cTarot2, cTarot3, cTarot4, cTarot5, currPuzzle, nextPuzzle, currRollOver, menuStat, menu_Key, pFrame, pStat, F_Arrow_Active, R_Arrow_Active, _Read_Only_Mansion, pz_Available, pz_Total, pz_LastLaunch, csGrid, csJumble, csClickCode, csPhrase, csConcat, csLetterSlide, csPatchPirate, csPatchStamp, csMorphText, csHerb, csTracer, csInventory, csSeven, csAuction, csWager, csTarot, csWagerTarot, csPentacle, csPreFinale, csMorph, csCoins, csHalves, csFillin, csPatchSlider, csMansion, csDEL, csHEX, csREM, csCON

on arrow_F_Init
  F_Arrow_Active = 0
  if sprite(cActiveSN).height = 320 then
    F_Arrow_Active = 1
  end if
  misc_VisStaticSprite(cForwardSN, F_Arrow_Active)
  sprite(cForwardSN).locH = 788
  sprite(cForwardSN).locV = 450
  arrow_F_Show(0)
end

on arrow_R_Init
  R_Arrow_Active = 0
  if sprite(cActiveSN).height = 320 then
    R_Arrow_Active = 1
  end if
  misc_VisStaticSprite(cReverseSN, R_Arrow_Active)
  sprite(cReverseSN).locH = 12
  sprite(cReverseSN).locV = 450
  arrow_R_Show(0)
end

on arrow_F_Show f
  if (F_Arrow_Active = 1) and (menu_Key <> "--------") then
    if f = 0 then
      if currRollOver = cForwardSN then
        f = 2
      else
        f = 1
      end if
    end if
    misc_UpdateStaticSprite(cForwardSN, f, 1)
  end if
end

on arrow_R_Show f
  if (R_Arrow_Active = 1) and (menu_Key <> "--------") then
    if f = 0 then
      if currRollOver = cReverseSN then
        f = 2
      else
        f = 1
      end if
    end if
    misc_UpdateStaticSprite(cReverseSN, f, 1)
  end if
end

on pz_Grab N
  pz_Total = pz_Total + 1
  pz_Available[pz_Total] = N
end

on launch_One N
  pz_Grab(N)
end

on launch_Range n1, n2
  repeat with x = n1 to n2
    pz_Grab(x)
  end repeat
end

on calcSolvedMansionStats N
  pStat[N] = 100
  menuStat[N] = 3
end

on launch_Delivery
  repeat with x = cMansion1 to cMansion2
    N = x - 72
    if pStat[cGameMenus] <= 20 then
      if (pStat[x] >= 1) and (pStat[x] <= 100) then
        pz_Grab(csMansion[N])
      end if
      next repeat
    end if
    calcSolvedMansionStats(100 + N)
    pz_Grab(csDEL[N])
  end repeat
end

on launch_Hex
  if pStat[cGameMenus] >= 30 then
    repeat with x = cMansion1 to cMansion2
      N = x - 72
      if pStat[cGameMenus] <= 60 then
        if (pStat[x] >= 101) and (pStat[x] <= 200) then
          pz_Grab(csMansion[N])
        end if
        next repeat
      end if
      calcSolvedMansionStats(107 + N)
      pz_Grab(csHEX[N])
    end repeat
  end if
end

on launch_Remainder
  if pStat[cGameMenus] >= 70 then
    repeat with x = cMansion1 to cMansion2
      N = x - 72
      if pStat[cGameMenus] <= 90 then
        if (pStat[x] >= 201) and (pStat[x] <= 300) then
          pz_Grab(csMansion[N])
        end if
        next repeat
      end if
      calcSolvedMansionStats(114 + N)
      pz_Grab(csREM[N])
    end repeat
  end if
end

on launch_Connection
  if pStat[cGameMenus] >= 95 then
    repeat with x = cMansion1 to cMansion2
      N = x - 72
      if pStat[x] >= 301 then
        pz_Grab(csMansion[N])
      end if
    end repeat
  end if
end

on launch_InitList
  pz_Total = 0
  launch_Range(cSwords1, cSwords2)
  launch_Delivery()
  launch_Range(cWands1, cWands2)
  launch_Hex()
  launch_Range(cCups1, cCups2)
  launch_Remainder()
  launch_Range(cPentacles1, cPentacles2)
  launch_Connection()
  if pStat[cGameMenus] = 70 then
    launch_One(cHighPriestess)
  end if
  if pStat[cGameMenus] >= 95 then
    launch_One(cSevenCups)
  end if
  if pStat[cMoonsMap] < 100 then
    launch_One(cMoonsMap)
  else
    launch_One(cMoonsPuzzles)
  end if
  launch_One(cPreFinale)
  launch_One(cGameMenus)
end

on _Test_Genre_Mension test
  repeat with x = 1 to 4
    adj = x * 100
    m1 = adj + cMansion1
    m2 = adj + cMansion2
    if (test >= m1) and (test <= m2) then
      N = test - adj
      return N
    end if
  end repeat
  return 0
end

on activity_NextKey incre, launchType
  if currPuzzle = 87 then
    exit
  end if
  CP = currPuzzle
  repeat with x = 1 to 5
    if CP = csTarot[x] then
      CP = csWager[x]
    end if
  end repeat
  calc = 0
  repeat with x = 1 to pz_Total
    if pz_Available[x] = CP then
      calc = x
      exit repeat
    end if
  end repeat
  if calc = 0 then
    exit
  end if
  start_test = pz_Available[calc]
  repeat while 666 = 666
    if incre = -1 then
      calc = calc - 1
      if calc < 1 then
        calc = pz_Total
      end if
    end if
    if incre = 1 then
      calc = calc + 1
      if calc > pz_Total then
        calc = 1
      end if
    end if
    test = pz_Available[calc]
    if test = CP then
      exit repeat
    end if
    case launchType of
      "000":
        repeat with x = 1 to 5
          if test = csWager[x] then
            if menuStat[test] > 0 then
              if pStat[cMoonsMap] = 100 then
                csWagerTarot[x] = csWager[x]
              end if
              return csWagerTarot[x]
            end if
          end if
        end repeat
        if menuStat[test] > 0 then
          return test
        end if
      "100":
        if pStat[cMoonsMap] < 100 then
          repeat with x = 1 to 5
            if test = csWager[x] then
              if (pStat[test] > 0) and (pStat[test] < 100) then
                return csWagerTarot[x]
              end if
            end if
          end repeat
        end if
        if (pStat[cMoonsMap] = 100) and (pStat[cMoonsPuzzles] < 700) then
          case test of
            2:
              if (pStat[test] >= 300) and (pStat[test] <= 600) then
                return test
              end if
            3:
              if (pStat[test] = 300) or (pStat[test] = 400) then
                return test
              end if
            4:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            5:
              if (pStat[test] >= 200) and (pStat[test] <= 320) then
                return test
              end if
            6:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            7:
              if pStat[test] = 200 then
                return test
              end if
            8:
              if pStat[test] = 200 then
                return test
              end if
            9:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            11:
              if pStat[test] = 300 then
                return test
              end if
            12:
              if pStat[test] = 300 then
                return test
              end if
            13:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            14:
              if pStat[test] = 300 then
                return test
              end if
            15:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            16:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            17:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            18:
              if (pStat[test] >= 200) and (pStat[test] <= 320) then
                return test
              end if
            19:
              if (pStat[test] >= 300) and (pStat[test] <= 600) then
                return test
              end if
            21:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            22:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            23:
              if pStat[test] = 200 then
                return test
              end if
            24:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            26:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            27:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            28:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            29:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            30:
              if pStat[test] = 300 then
                return test
              end if
            31:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            32:
              if pStat[test] = 300 then
                return test
              end if
            34:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            35:
              if (pStat[test] >= 200) and (pStat[test] <= 320) then
                return test
              end if
            36:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            38:
              if (pStat[test] >= 300) and (pStat[test] <= 600) then
                return test
              end if
            39:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            40:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            42:
              if pStat[test] = 200 then
                return test
              end if
            44:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            45:
              if pStat[test] = 300 then
                return test
              end if
            46:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            48:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            49:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            50:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            51:
              if pStat[test] = 300 then
                return test
              end if
            52:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            54:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            55:
              if (pStat[test] >= 200) and (pStat[test] <= 320) then
                return test
              end if
            56:
              if pStat[test] = 300 then
                return test
              end if
            57:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            58:
              if pStat[test] = 200 then
                return test
              end if
            59:
              if pStat[test] = 300 then
                return test
              end if
            60:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            61:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            63:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            64:
              if pStat[test] = 300 then
                return test
              end if
            65:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            66:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            68:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            69:
              if (pStat[test] = 200) or (pStat[test] = 300) then
                return test
              end if
            70:
              if pStat[test] = 300 then
                return test
              end if
            71:
              if (pStat[test] >= 200) and (pStat[test] <= 320) then
                return test
              end if
          end case
        end if
        case test of
          cPreFinale:
            if menuStat[test] >= 4 then
              return test
            end if
          cMoonsMap:
            if pStat[cMoonsMap] < 100 then
              return test
            end if
          cMoonsPuzzles:
            if pStat[cMoonsPuzzles] < 700 then
              return test
            end if
          cSevenCups:
            if pStat[cGameMenus] >= 95 then
              if pStat[cSevenCups] < 700 then
                return test
              end if
            end if
          cGameMenus:
            if (pStat[test] = 20) or (pStat[test] = 60) or (pStat[test] = 80) or (pStat[test] = 90) then
              return test
            end if
            if (pStat[cMoonsPuzzles] > 0) and (pStat[cSevenCups] < 100) then
              return test
            end if
          otherwise:
            if (menuStat[test] > 0) and (menuStat[test] < 3) then
              return test
            end if
        end case
      "010":
        if (pFrame[CP] = pFrame[test]) and (menuStat[test] > 0) then
          return test
        end if
      "999":
        case test of
          cHighPriestess, cSevenCups, cMoonsMap, cMoonsPuzzles, cGameMenus:
          otherwise:
            if menuStat[test] > 0 then
              repeat with x = 1 to 5
                if test = csWager[x] then
                  csWagerTarot[x] = csWager[x]
                  return test
                end if
              end repeat
              return test
            end if
        end case
    end case
  end repeat
  menu_No_Go_Snd()
  return 0
end

on launch_SpecialKeys K
  if menu_Key = "--------" then
    return 0
  end if
  keys = list(46, 62, 39, 34, 93, 125, 44, 60, 59, 58, 91, 123, 45, 61, 666, 999)
  N = 0
  repeat with x = 1 to 16
    if keys[x] = K then
      N = x
    end if
  end repeat
  return N
end

on launch_CalcKey K
  N = launch_SpecialKeys(K)
  if N = 0 then
    return 0
  end if
  Q = 0
  case N of
    1, 2:
      Q = activity_NextKey(1, "000")
    3, 4:
      Q = activity_NextKey(1, "100")
    5, 6:
      Q = activity_NextKey(1, "010")
    7, 8:
      Q = activity_NextKey(-1, "000")
    9, 10:
      Q = activity_NextKey(-1, "100")
    11, 12:
      Q = activity_NextKey(-1, "010")
    13:
      Q = activity_Prev()
    14:
      Q = activity_Next()
    15:
      Q = activity_NextKey(-1, "999")
    16:
      Q = activity_NextKey(1, "999")
  end case
  if Q = currPuzzle then
    return 0
  end if
  return Q
end

on launch_GameKey K
  if (currPuzzle = cPreHP) or (currPuzzle = cEndHP) then
    exit
  end if
  Q = launch_CalcKey(K)
  if Q > 0 then
    if nextPuzzle = 0 then
      menu_Click_Snd()
    end if
    initLaunch(Q, 1)
    return 1
  end if
  return 0
end
