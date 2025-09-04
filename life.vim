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

func DebugCoords(coords)
  for line in a:coords
    echo join(line)
  endfor
endfunc

set switchbuf=useopen
sbuffer glider.txt
call DebugCoords(ReadBuf())
sbuffer life.vim

