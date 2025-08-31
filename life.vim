func LifePlay()
  call LifeInitializeBackBuffer()
  autocmd QuitPre * bdelete! life_back_buffer
  call LifeUpdateBackBuffer()
endfunc

func LifePause()
endfunc

func LifeSwitchToBackBuffer()
  buffer life_back_buffer
endfunc

func LifeInitializeBackBuffer()
  let n = bufnr("%")
  let w = winwidth("%") - &numberwidth
  let h = winheight("%")
  edit life_back_buffer
  set bufhidden=hide
  normal! ggdG
  execute "normal! ".w."i0\<esc>yy".(h-1)."p"
  execute "buffer".n
endfunc

" Returns the character at (line, col).
" Returns empty string if (line, col) is out of bounds.
func LifeCharAt(line, col)
  " Example: suppose the file has 3 lines in it.
  " Then line("$") == 3 and the lines are 1-indexed.
  if a:line > line("$")
    return ""
  endif
  " Navigate to the specified line.
  call cursor(a:line, 0)
  " Example: suppose the current line has 3 characters on it.
  " Then col("$") == 4 and the columns are 1-indexed.
  " So valid columns would be 1, 2, or 3.
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
      call LifeSwitchToBackBuffer()
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

" Assumes we are currently on the back buffer.
" Updates the neighbor count at (line, col) by looking at adjacent live cells
" in buffer bufn.
func LifeUpdateNeighborCount(bufn, line, col)
  call cursor(a:line, a:col)
  normal! yl
  let char = LifeCharAt(a:bufn, a:line, a:col)
  if char ==# "#"
    normal! r1
  endif
endfunc
