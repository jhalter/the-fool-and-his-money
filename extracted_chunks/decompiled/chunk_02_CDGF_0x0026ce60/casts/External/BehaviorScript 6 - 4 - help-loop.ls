on prepareFrame
  tokenHelp_PrepPlay()
end

on exitFrame
  tokenHelp_ExitPlay()
end

on idle
  _movie.idleHandlerPeriod = 15
  sleep = 1
end
