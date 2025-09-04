func Set(list, x, y, value)
  let a:list[a:y * winwidth(0) + a:x] = a:value
endfunc

func Get(list, x, y)
  return a:list[a:y * winwidth(0) + a:x]
endfunc

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

func FillList(size, value)
  let result = []
  let i = 0
  while i < a:size
    call add(result, a:value)
    let i += 1
  endwhile
  return result
endfunc

func ReadBuf()
  let w = winwidth(0)
  let h = winheight(0)
  let lifeCoords = FillGrid(w, h, 0)
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

func DebugGrid(grid, getter)
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
endfunc

" Return a deep copy of src grid while applying fn element-wise.
func MapGrid(src, fn)
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

func GridGetWithOffset(roffs, coffs, src, r, c)
  let r = (a:r + a:roffs + len(a:src)) % len(a:src)
  let c = (a:c + a:coffs + len(a:src[r])) % len(a:src[r])
  return a:src[r][c]
endfunc

set switchbuf=useopen
sbuffer glider.txt
let grid = ReadBuf()
let neighborCounts = MapGrid(grid, {cell -> -cell})
"call DebugGrid(grid, {grid, r, c -> grid[r][c]})
call DebugGrid(grid, function("GridGetWithOffset", [0, 3]))
sbuffer life.vim

