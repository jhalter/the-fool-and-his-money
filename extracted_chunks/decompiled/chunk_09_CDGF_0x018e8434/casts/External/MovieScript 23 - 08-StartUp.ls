global CR, QU, theDirectorVersion, theGameStartTime, theInitPhase, cFileIO, cTestIO, cGameDirectory, cWork, cLink, cXtraDirectory, cSavedGamesDirectory, cSaveDirectoryCliff, cOpenGameNum, prefTotal, prefChunk, prefNumber, zipCode, uniqueKey, uniquePass, uniqueName, uniqueAttempt, fName, theDataChunk, theDataName, theDataTrue, theDataTotal, theDataStatus, _StartUp_Switched, _Window_Switched, _Start_Comments, _PassKey_Pass, _PassKey_Name

on special_Frame_1
  _global.clearGlobals()
  clearASObjects()
  _Start_Comments = 0
  theInitPhase = 1
  _movie.idleHandlerPeriod = 15
  the cpuHogTicks = 20
  _movie.exitLock = 1
  theGameStartTime = 0
  _StartUp_Switched = 0
  _Window_Switched = 0
  noInterface()
  CR = numToChar(13)
  QU = numToChar(34)
  init_Window_Title(EMPTY)
  cFileIO = new(xtra("fileio"))
  cTestIO = new(xtra("fileio"))
  if string(_player.productVersion).char[1..2] <> "11" then
    theDirectorVersion = 10
    cTestIO.openfile("D:\TFaHM_work\data.txt", 1)
    chunk = cTestIO.readFile()
    cTestIO.closeFile()
    member("miscellaneous").text = chunk
  else
    theDirectorVersion = 11
    _movie.scriptExecutionStyle = 10
  end if
  theDataStatus = 0
  cGameDirectory = _movie.path
  cWork = "D:\TFaHM_work\"
  cLink = cWork & "zzz-COPY-Game-HERE\"
  cSaveDirectoryCliff = cWork & "ZZZAVED-GAMEZZZ\"
  if the platform contains "Windows" then
    cXtraDirectory = cGameDirectory & "Xtras\"
    cSavedGamesDirectory = cGameDirectory & "Saved Games\"
  else
    cXtraDirectory = cGameDirectory & "Xtras:"
    cSavedGamesDirectory = cGameDirectory & "Saved Games:"
  end if
  _Put_Start(cGameDirectory)
  _Put_Start(cXtraDirectory)
  _Put_Start(cSavedGamesDirectory)
  _Put_Start(cSaveDirectoryCliff)
  repeat with x = 3 to 8
    misc_VisStaticSprite(x, 1)
  end repeat
  _Put_Start("special_Prefs()")
  special_Prefs()
  _Put_Start("special_CheckCastMembers()")
  special_CheckCastMembers()
  theInitPhase = 2
end

on special_Frame_2
  _PassKey_Pass = EMPTY
  _PassKey_Name = EMPTY
  if theInitPhase < 3 then
    if prefChunk[prefTotal] <> "---" then
      _Put_Start(prefChunk[prefTotal])
      theInitPhase = 3
    else
      cTestIO.openfile(cGameDirectory & "PassKey.txt", 1)
      chunk = cTestIO.readFile()
      cTestIO.closeFile()
      if chunk.length = 1000 then
        chunk = chunk.char[4..chunk.length]
        chunk = decodeZip(chunk)
        pos = offset("|", chunk)
        chunk = chunk.char[pos + 1..chunk.length]
        pos = offset("|", chunk)
        _PassKey_Pass = chunk.char[1..pos - 1]
        chunk = chunk.char[pos + 1..chunk.length]
        pos = offset("|", chunk)
        _PassKey_Name = chunk.char[1..pos - 1]
        theInitPhase = 3
        _PUT(_PassKey_Pass.char[1..3] & "-" & _PassKey_Pass.char[4..6] & "-" & _PassKey_Pass.char[7..9])
        _PUT(_PassKey_Name)
      else
        theDataChunk = member("miscellaneous").text
        special_ReadDataChunk()
        theInitPhase = 3
      end if
    end if
  end if
  _movie.go(theInitPhase)
end

on special_Frame_3
  case theInitPhase of
    3:
      uniqueKey = EMPTY
      uniquePass = EMPTY
      uniqueName = EMPTY
      uniqueAttempt = 0
      if prefChunk[prefTotal] = "---" then
        sprite(9).setVariable("fromDirectorPuzzlePhase", string(10))
        set the keyDownScript to "keyPassWord"
        theInitPhase = 4
      else
        uniqueName = prefChunk[prefTotal]
        theInitPhase = 10
      end if
    4:
      if uniqueKey <> EMPTY then
        sprite(9).setVariable("fromDirectorKey", string(uniqueKey))
        uniqueKey = EMPTY
      end if
      uniquePass = sprite(9).getVariable("fromDirectorPass", 1)
      if uniquePass.length = 9 then
        theInitPhase = 5
      end if
    5:
      if _PassKey_Pass = EMPTY then
        uniqueName = special_FindPassWordName(uniquePass)
      else
        if uniquePass = _PassKey_Pass then
          uniqueName = _PassKey_Name
          cTestIO.openfile(cGameDirectory & "PassKey.txt", 0)
          delete cTestIO
        end if
      end if
      if uniqueName = EMPTY then
        theInitPhase = 6
      else
        theInitPhase = 10
      end if
    6:
      uniqueAttempt = uniqueAttempt + 1
      if uniqueAttempt = 7 then
        finally_Quit()
        return 
      end if
      if uniqueAttempt <= 3 then
        sprite(9).setVariable("messageNum", string(1))
      else
        sprite(9).setVariable("messageNum", string(2))
      end if
      _player.flushInputEvents()
      sprite(9).setVariable("fromDirectorPuzzlePhase", string(30))
      sprite(9).setVariable("fromDirectorPass", EMPTY)
      uniquePass = EMPTY
      uniqueName = EMPTY
      theInitPhase = 4
    10:
      specialStartTime()
      sprite(9).setVariable("fromDirectorPuzzlePhase", string(40))
      sprite(9).setVariable("fromDirectorName", string(uniqueName))
      if prefChunk[prefTotal] = "---" then
        prefChunk[prefTotal] = uniqueName
      end if
      theInitPhase = 11
    11:
      N = sprite(9).getVariable("fromFlashPuzzlePhase")
      N = integer(N)
      if N = 100 then
        theInitPhase = 12
      end if
    12:
      set the keyDownScript to EMPTY
      init_StartGame()
      if uniqueName = decodeZip("^DR$_GMlsLT~ydL") then
        theDataStatus = 1
        _PUT(decodeZip("]W<.r~H5dcd"))
      end if
      theInitPhase = 13
    13:
      if specialFinishTime() = 1 then
        if theDataStatus = 1 then
          setPrefList()
          init_LaunchGame()
          theInitPhase = 14
          return 
        end if
        setPrefList()
        _Launch_Tokens(0, 1)
        theInitPhase = 14
        return 
      end if
  end case
  _movie.go(3)
end

on special_Frame_4
  _movie.go(4)
end

on specialStartTime
  if theGameStartTime = 0 then
    theGameStartTime = _system.ticks()
  end if
end

on specialFinishTime
  T = _system.ticks() - theGameStartTime
  if T > 240 then
    return 1
  end if
  return 0
end

on special_Prefs
  prefChunk = list()
  prefNumber = list()
  prefTotal = 14
  repeat with x = 1 to 12
    prefNumber[x] = misc_PadNumber(x, 0, 0) & ".txt"
    prefChunk[x] = prefNumber[x]
  end repeat
  prefChunk[prefTotal - 1] = "00"
  prefChunk[prefTotal] = "---"
  S = member("zip-code").text
  zipCode = list()
  repeat with x = 1 to 94
    zipCode[x] = charToNum(S.char[x]) - 32
  end repeat
  getPrefList()
  if _key.shiftDown = 1 then
    prefChunk[prefTotal] = "---"
  end if
  if prefChunk[prefTotal] = "---" then
    sprite(8).setVariable("fromDirectorPuzzlePhase", string(40))
    sprite(8).setVariable("fromDirectorName", prefChunk[prefTotal])
    specialStartTime()
  end if
end

on special_ReadDataChunk
  len = theDataChunk.length
  N = theDataChunk.char[1..13]
  N = decodeZip(N)
  totalLong = integer(N)
  N = theDataChunk.char[14..26]
  N = decodeZip(N)
  totalName = integer(N)
  theDataChunk = theDataChunk.char[27..theDataChunk.length]
  chunkLong = theDataChunk.char[1..totalLong]
  chunkName = theDataChunk.char[totalLong + 1..theDataChunk.length]
  chunkLong = decodeZip(chunkLong)
  pos = offset("|", chunkLong)
  N = chunkLong.char[1..pos - 1]
  theDataTotal = integer(N)
  chunkLong = chunkLong.char[pos + 1..chunkLong.length]
  arrayLong = list()
  repeat with x = 1 to theDataTotal
    pos = offset("|", chunkLong)
    N = chunkLong.char[1..pos - 1]
    arrayLong[x] = integer(N)
    chunkLong = chunkLong.char[pos + 1..chunkLong.length]
  end repeat
  theDataName = list()
  theDataTrue = list()
  repeat with x = 1 to theDataTotal
    theDataName[x] = chunkName.char[1..arrayLong[x]]
    chunkName = chunkName.char[arrayLong[x] + 1..chunkName.length]
    theDataTrue[x] = chunkName.char[1..10]
    chunkName = chunkName.char[11..chunkName.length]
  end repeat
  if theDirectorVersion = 10 then
    S = theDataTrue[random(theDataTotal)]
    S = decodeZip(S)
    Q = special_FindPassWordName(S)
    S = theDataTrue[theDataTotal]
    S = decodeZip(S)
    Q = special_FindPassWordName(S)
  end if
end

on special_FindPassWordName S
  ZM = member("zip-mark").text
  find = list()
  repeat with x = 1 to ZM.length
    find[x] = encodeZipNum(S, x)
  end repeat
  found = 0
  repeat with y = 1 to theDataTotal
    repeat with x = 1 to ZM.length
      if find[x] = theDataTrue[y] then
        S1 = decodeZip(theDataName[y])
        s2 = decodeZip(theDataTrue[y])
        s3 = S1.char[1..4]
        N = integer(s3)
        found = 1
      end if
      if found = 1 then
        exit repeat
      end if
    end repeat
    if found = 1 then
      exit repeat
    end if
  end repeat
  if found = 0 then
    return EMPTY
  else
    S1 = S1.char[5..S1.length]
    return S1
  end if
end

on getFileKeyWord
  return "Wise men make proverbs, but fools repeat them."
end

on encodeZip S
  ZM = member("zip-mark").text
  ct = random(ZM.length)
  SS = ZM.char[ct]
  repeat with x = 1 to S.length
    N = charToNum(S.char[x])
    if (N >= 32) and (N <= 126) then
      ct = ct + 1
      if ct > 94 then
        ct = 1
      end if
      N = charToNum(S.char[x]) + zipCode[ct]
      if N > 126 then
        N = N - 94
      end if
      SS = SS & numToChar(N)
      next repeat
    end if
    SS = SS & S.char[x]
  end repeat
  return SS
end

on decodeZip S
  ZM = member("zip-mark").text
  ct = 0
  repeat with x = 1 to ZM.length
    if S.char[1] = ZM.char[x] then
      ct = x
    end if
  end repeat
  SS = EMPTY
  repeat with x = 2 to S.length
    N = charToNum(S.char[x])
    if (N >= 32) and (N <= 126) then
      ct = ct + 1
      if ct > 94 then
        ct = 1
      end if
      N = charToNum(S.char[x]) - zipCode[ct]
      if N < 32 then
        N = N + 94
      end if
      SS = SS & numToChar(N)
      next repeat
    end if
    SS = SS & S.char[x]
  end repeat
  return SS
end

on encodeZipNum S, ct
  ZM = member("zip-mark").text
  SS = ZM.char[ct]
  repeat with x = 1 to S.length
    N = charToNum(S.char[x])
    if (N >= 32) and (N <= 126) then
      ct = ct + 1
      if ct > 94 then
        ct = 1
      end if
      N = charToNum(S.char[x]) + zipCode[ct]
      if N > 126 then
        N = N - 94
      end if
      SS = SS & numToChar(N)
      next repeat
    end if
    SS = SS & S.char[x]
  end repeat
  return SS
end

on zipTest chunk
  S1 = getFileKeyWord()
  s2 = decodeZip(chunk.char[1..S1.length + 1])
  if S1 <> s2 then
    return 0
  end if
  return 1
end

on keyPassWord
  global uniqueKey
  if poll_Quit_Keys() = 0 then
    uniqueKey = _key.keyPressed()
  else
    finally_Quit()
  end if
end

on _Put_Start S
  if _Start_Comments = 1 then
    _PUT(S)
  end if
end
