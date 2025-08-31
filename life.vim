func LifePlay()
  set bufhidden=hide
  autocmd ExitPre * bdelete! life_neighbor_count
  autocmd ExitPre * bdelete! life_back_buffer
  while 1
    call LifeInitializeNeighborCount()
    call LifeInitializeBackBuffer()
    call LifeUpdateNeighborCount()
    call LifeUpdateBackBuffer()
    call LifeUpdateMainBuffer()
    redraw
  endwhile
endfunc

func LifeUpdateMainBuffer()
  " Copy back buffer to main buffer.
  let n = bufnr("%")
  call LifeSwitchToBackBuffer()
  normal! ggyG
  execute "buffer" n
  normal! gg"_dGpkdd
endfunc

func LifePause()
endfunc

func LifeSwitchToBackBuffer()
  buffer life_back_buffer
endfunc

func LifeSwitchToNeighborCount()
  buffer life_neighbor_count
endfunc

func LifeInitializeBackBuffer()
  " Save previous buffer number.
  let n = bufnr("%")
  let w = winwidth("%") - &numberwidth
  let h = winheight("%")
  edit life_back_buffer
  set bufhidden=hide
  normal! ggdG
  " Fill with spaces.
  execute "normal! ".w."i \<esc>yy".(h-1)."p"
  " Switch back to previous buffer.
  execute "buffer".n
endfunc

func LifeInitializeNeighborCount()
  let n = bufnr("%")
  let w = winwidth("%") - &numberwidth
  let h = winheight("%")
  edit life_neighbor_count
  set bufhidden=hide
  normal! ggdG
  " Fill with zeros.
  execute "normal! ".w."i0\<esc>yy".(h-1)."p"
  execute "buffer".n
endfunc

" Returns the character at (line, col).
" Returns empty string if (line, col) is out of bounds.
func LifeCharAt(line, col)
  " Example: suppose the file has 3 lines in it.
  " Then line("$") == 3 and the lines are 1-indexed.
  " Valid lines would be 1, 2, or 3.
  if a:line > line("$") || a:line <= 0
    return ""
  endif
  " Navigate to the specified line.
  call cursor(a:line, 0)
  " Example: suppose the current line has 3 characters on it.
  " Then col("$") == 4 and the columns are 1-indexed.
  " Valid columns would be 1, 2, or 3.
  if a:col >= col("$") || a:col <= 0
    return ""
  endif
  " Navigate to the specified column.
  call cursor(a:line, a:col)
  " Yank the character under the cursor.
  normal! yl
  " Return the yanked character.
  return @"
endfunc

func LifeOneIndexedModulo(i, n)
  return (a:i - 1) % (a:n) + 1
endfunc

" Assumes we are currently on the main buffer.
func LifeUpdateNeighborCount()
  " Save the buffer number of the main buffer.
  let bufn = bufnr("%")
  " Iterate over every character of the neighbor count buffer.
  call LifeSwitchToNeighborCount()
  let line = 1
  let numLines = line("$")
  while line <= numLines
    call cursor(line, 1)
    let col = 1
    let numCols = col("$") - 1
    while col <= numCols
      " Switch to main buffer.
      execute "buffer".bufn
      let neighborCount = 0
      for [dx, dy] in [
        \ [-1, -1], [-1, 0], [-1, 1],
        \ [ 0, -1],          [ 0, 1],
        \ [ 1, -1], [ 1, 0], [ 1, 1]]
        if LifeCharAt(
          \ LifeOneIndexedModulo(line + dy, numLines),
          \ LifeOneIndexedModulo(col + dx, numCols)) ==# "#"
          let neighborCount += 1
        endif
      endfor
      call LifeSwitchToNeighborCount()
      " Replace char under cursor with neighbor count.
      call cursor(line, col)
      let @" = neighborCount
      normal! Plx
      let col += 1
    endwhile
    let line += 1
  endwhile
  execute "buffer".bufn
endfunc

" Assumes we are currently on the main buffer.
func LifeUpdateBackBuffer()
  " Save the buffer number of the main buffer.
  let bufn = bufnr("%")
  " Iterate over every character of the back buffer.
  call LifeSwitchToBackBuffer()
  let line = 1
  let numLines = line("$")
  while line <= numLines
    call cursor(line, 1)
    let col = 1
    let numCols = col("$") - 1
    while col <= numCols
      " Switch to main buffer.
      execute "buffer".bufn
      let cell = LifeCharAt(line, col)
      " Switch to neighbor count buffer.
      call LifeSwitchToNeighborCount()
      call cursor(line, col)
      normal! yl
      let neighborCount = @"
      " Switch to back buffer.
      call LifeSwitchToBackBuffer()
      let isLive = 0
      if cell ==# "#" && neighborCount < 2
        let isLive = 0
      elseif cell ==# "#" && (neighborCount == 2 || neighborCount == 3)
        let isLive = 1
      elseif cell ==# "#" && neighborCount > 3
        let isLive = 0
      elseif cell !=# "#" && neighborCount == 3
        let isLive = 1
      endif
      if isLive
        " Replace char under cursor.
        call cursor(line, col)
        let @" = "#"
        normal! Plx
      endif
      let col += 1
    endwhile
    let line += 1
  endwhile
  execute "buffer".bufn
endfunc
