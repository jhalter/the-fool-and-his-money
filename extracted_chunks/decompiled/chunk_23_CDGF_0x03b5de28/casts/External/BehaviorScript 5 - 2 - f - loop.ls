on prepareFrame
  fin_PrepPlay()
end

on exitFrame
  fin_ExitPlay()
end

on idle
  calcMouseChunk()
  _movie.idleHandlerPeriod = 15
  sleep = 1
end
