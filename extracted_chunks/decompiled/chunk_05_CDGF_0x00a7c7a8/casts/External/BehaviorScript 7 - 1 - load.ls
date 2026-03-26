on prepareFrame
  puzz_PrepInit()
end

on exitFrame
  puzz_ExitInit()
end

on idle
  calcMouseChunk()
  _movie.idleHandlerPeriod = 15
  sleep = 1
end
