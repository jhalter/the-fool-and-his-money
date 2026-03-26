on prepareFrame
  tokenHelp_PrepInit()
end

on exitFrame
  tokenHelp_ExitInit()
end

on idle
  _movie.idleHandlerPeriod = 15
  sleep = 1
end
