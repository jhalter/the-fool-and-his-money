on prepareFrame
  puzz_PrepPlay()
end

on exitFrame
  puzz_ExitPlay()
end

on idle
  calcMouseChunk()
  _movie.idleHandlerPeriod = 15
  sleep = 1
end
