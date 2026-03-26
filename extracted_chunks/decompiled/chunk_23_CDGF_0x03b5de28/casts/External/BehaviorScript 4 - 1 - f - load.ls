on prepareFrame
  fin_PrepInit()
end

on exitFrame
  fin_ExitInit()
end

on idle
  calcMouseChunk()
  _movie.idleHandlerPeriod = 15
  sleep = 1
end
