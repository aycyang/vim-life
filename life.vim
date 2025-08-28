" switch to active window for buffer if visible instead of opening new window
" see :help sb
set switchbuf+=useopen

" create temporary intermediate buffers
vsplit hconv
split vconv
vsplit vconv2

" switch back to the main buffer
sbuffer 1
autocmd TextChanged <buffer> :call UpdateHConv()

function UpdateMain()
  sbuffer 1
  let maxLine = line("$")
  let maxCol = col("$")
  let line = 1
  while line < maxLine
    let col = 1
    while col < maxCol
      " pick from vconv2 -> @b
      sbuffer vconv2
      call cursor(line, col)
      normal! "byl
      " pick from main buffer -> @a
      sbuffer 1
      call cursor(line, col)
      normal! "ayl
      " calculate result
      if @a == 1 && @b < 2
        let @c = 0
      elseif @a == 1 && (@b == 2 || @b == 3)
        let @c = 1
      elseif @a == 1 && @b > 3
        let @c = 0
      elseif @a == 0 && @b == 3
        let @c = 1
      else
        let @c = 0
      endif
      " store result in main buffer
      normal! x"cP
      let col += 1
    endwhile
    let line += 1
  endwhile
endfunction

" assumes line and col are uniform within buffers
function SubtractBuffer(buf1, buf2)
  execute "sbuffer " . a:buf2
  let maxLine = line("$")
  let maxCol = col("$")
  let line = 1
  while line < maxLine
    let col = 1
    while col < maxCol
      " pick from buf2 -> @b
      execute "sbuffer " . a:buf2
      call cursor(line, col)
      normal! "byl
      " pick from buf1 -> @a
      execute "sbuffer " . a:buf1
      call cursor(line, col)
      normal! "ayl
      " store result in buf1
      let @c = @a - @b
      normal! x"cP
      let col += 1
    endwhile
    let line += 1
  endwhile
endfunction

function UpdateVConv2()
  " clear vconv2
  sbuffer vconv2
  normal! ggdG
  " transpose vconv, paste result in vconv2
  sbuffer vconv
  normal! gg
  while col('.') < col('$') - 1
    call YankColumnBelowTransposed()
    sbuffer vconv2
    execute "normal! o\<esc>p"
    sbuffer vconv
    normal! l
  endwhile
  call YankColumnBelowTransposed()
  sbuffer vconv2
  execute "normal! o\<esc>p"
  " delete leading blank line
  normal! ggdd
  call SubtractBuffer("vconv2", 1)
endfunction

function UpdateVConv()
  " clear vconv
  sbuffer vconv
  normal! ggdG
  " transpose hconv, paste result in vconv
  sbuffer hconv
  normal! gg
  while col('.') < col('$') - 1
    call YankColumnBelowTransposed()
    sbuffer vconv
    execute "normal! o\<esc>p"
    sbuffer hconv
    normal! l
  endwhile
  call YankColumnBelowTransposed()
  sbuffer vconv
  execute "normal! o\<esc>p"
  " delete leading blank line
  normal! ggdd
  " perform horizontal convolution
  while line(".") < line("$") - 1
    call ConvLine()
    normal! j
  endwhile
  call ConvLine()
  normal! gg
endfunction

" TODO investigate using visual block mode instead of transposing: execute with double quote and
" escaped <C-v>
function YankColumnBelowTransposed()
  let @a = ""
  let origLine = line(".")
  let origCol = col(".")
  while line(".") < line("$") && col(".") == origCol
    normal yl
    let @a = @a . @"
    normal j
  endwhile
  normal yl
  let @a = @a . @"
  let @" = @a
  call cursor(origLine, origCol)
endfunction

function UpdateHConv()
  " mark a
  normal! ma
  " copy buffer to register t
  normal! gg"tyG
  " switch to buffer hconv
  sbuffer hconv
  " replace buffer contents with contents of register t
  normal! ggdG"tpkdd
  " update buffer hconv
  while line(".") < line("$") - 1
    call ConvLine()
    normal! j
  endwhile
  call ConvLine()
  normal! gg
  " next phases
  call UpdateVConv()
  call UpdateVConv2()
  call UpdateMain()
  " switch to buffer 1
  sbuffer 1
  " return to mark a
  normal! `a
endfunction

" TODO investigate why this doesn't work on the last line or column
function ConvLine()
  normal! yyPPj
  let @" = 0
  normal! Pjxkk
  " the cursor is now on the original line, but there are now two copies of
  " the line below it. one copy is left-shifted by one and the other copy is
  " right-shifted by one (zero-padded).
  call ZipBelow()
  normal! jddk
  call ZipBelow()
  normal! jddk
endfunction

" for each digit in the current line, add the digit immediately below it and
" store the result at the current position. if there is no digit below the
" current digit (e.g. if the line below is shorter than the current line),
" nothing happens.
function ZipBelow()
  " go to beginning of line
  normal! 0
  while col(".") < col("$") - 1
    call AddBelow()
    normal! l
  endwhile
  call AddBelow()
endfunction

" add the digit under the cursor and the digit immediately below it and store
" the result at the current cursor position.
function AddBelow()
  let col1 = col(".")
  normal! j
  let col2 = col(".")
  if col1 != col2
    normal! k
    return
  endif
  normal! "aylk"byl
  let @c = @a + @b
  normal! x"cP
endfunction
