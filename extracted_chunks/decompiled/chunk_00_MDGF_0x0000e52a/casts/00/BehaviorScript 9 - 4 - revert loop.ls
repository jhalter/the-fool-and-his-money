global fName, cOpenGameNum

on exitFrame
  if fName[cOpenGameNum] <> EMPTY then
    xferFoolFileCliff()
  end if
  _movie.go(_movie.frame)
end
