func s:FillGrid(w, h, value)
  let result = []
  let r = 0
  while r < a:h
    let c = 0
    call add(result, [])
    while c < a:w
      call add(result[r], a:value)
      let c += 1
    endwhile
    let r += 1
  endwhile
  return result
endfunc

func s:WinWidth()
  return winwidth(0) - &numberwidth
endfunc

func s:ReadBuf()
  let w = s:WinWidth()
  let h = winheight(0)
  let lifeCoords = s:FillGrid(w, h, 0)
  let lines = getline(1, line("$"))
  let r = 0
  for line in lines
    let c = 0
    for char in line
      if char ==# "#"
        let lifeCoords[r][c] = 1
      endif
      let c += 1
    endfor
    let r += 1
  endfor
  return lifeCoords
endfunc

func s:DebugGrid(grid, getter)
  let r = 0
  while r < len(a:grid)
    let c = 0
    let row = []
    while c < len(a:grid[r])
      call add(row, a:getter(a:grid, r, c))
      let c += 1
    endwhile
    echo join(row, "")
    let r += 1
  endwhile
  echo ""
endfunc

" Return a deep copy of src grid while applying fn element-wise.
func s:GridMap(src, fn)
  let dst = []
  let r = 0
  while r < len(a:src)
    call add(dst, [])
    let c = 0
    while c < len(a:src[r])
      call add(dst[r], a:fn(a:src[r][c]))
      let c += 1
    endwhile
    let r += 1
  endwhile
  return dst
endfunc

" Use with partial application to create grid views at various origins.
func s:GridGetWithOffset(roffs, coffs, src, r, c)
  let row = (a:r + a:roffs + len(a:src)) % len(a:src)
  let col = (a:c + a:coffs + len(a:src[row])) % len(a:src[row])
  return a:src[row][col]
endfunc

" Add src into dst element-wise, using getter on src.
" Assumes src and dst have the same dimensions.
func s:GridAdd(dst, src, getter)
  let r = 0
  while r < len(a:dst)
    let c = 0
    while c < len(a:dst[r])
      let a:dst[r][c] += a:getter(a:src, r, c)
      let c += 1
    endwhile
    let r += 1
  endwhile
endfunc

" Given src1 and src2, produce element in returned new grid.
" Assumes src1 and src2 have the same dimensions.
func s:GridMap2(src1, src2, fn)
  let dst = []
  let r = 0
  while r < len(a:src1)
    call add(dst, [])
    let c = 0
    while c < len(a:src1[r])
      call add(dst[r], a:fn(a:src1[r][c], a:src2[r][c]))
      let c += 1
    endwhile
    let r += 1
  endwhile
  return dst
endfunc

func s:ApplyConwayRules(isLive, neighborCount)
  if a:isLive && a:neighborCount < 2
    return 0
  elseif a:isLive && (a:neighborCount == 2 || a:neighborCount == 3)
    return 1
  elseif a:isLive && a:neighborCount > 3
    return 0
  elseif !a:isLive && a:neighborCount == 3
    return 1
  endif
endfunc

func s:RenderGrid(grid)
  let lnum = 1
  for row in a:grid
    call setline(lnum, join(row, ""))
    let lnum += 1
  endfor
endfunc

func GameOfLifeStep()
  " Read buffer into 2D list
  let grid = s:ReadBuf()
  " Calculate neighbor counts
  let hconv = deepcopy(grid)
  let vconv = s:GridMap(grid, {x -> -x})
  call s:GridAdd(hconv, grid, function("s:GridGetWithOffset", [0, 1]))
  call s:GridAdd(hconv, grid, function("s:GridGetWithOffset", [0, -1]))
  call s:GridAdd(vconv, hconv, function("s:GridGetWithOffset", [0, 0]))
  call s:GridAdd(vconv, hconv, function("s:GridGetWithOffset", [1, 0]))
  call s:GridAdd(vconv, hconv, function("s:GridGetWithOffset", [-1, 0]))
  " Determine live cells in next iteration
  let next = s:GridMap2(grid, vconv, function("s:ApplyConwayRules"))
  " Render to buffer
  let render = s:GridMap(next, { cell -> cell ? "#" : " " })
  call s:RenderGrid(render)
endfunc

func GameOfLife()
  while 1
    call GameOfLifeStep()
    redraw
  endwhile
endfunc

nnoremap \s :call GameOfLifeStep()<cr>
nnoremap \r :call GameOfLife()<cr>
