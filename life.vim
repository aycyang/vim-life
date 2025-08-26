" switch to active window for buffer if visible instead of opening new window
" see :help sb
set switchbuf+=useopen

" create temporary buffers for intermediate buffers for dynamic programming
vsplit hconv
split vconv

" switch back to the main buffer
sbuffer 1

autocmd TextChanged <buffer> :call UpdateHConv()

function UpdateHConv()
  " mark a
  normal ma
  " copy buffer to register t
  normal gg"tyG
  " switch to buffer hconv
  sbuffer hconv
  " replace buffer contents with contents of register t
  normal ggdG"tpkdd
  " update buffer hconv
  while line(".") < line("$") - 1
    call ConvLine()
    normal j
  endwhile
  call ConvLine()
  normal gg
  " switch to buffer 1
  sbuffer 1
  " return to mark a
  normal `a
endfunction

function ConvLine()
  normal yyPPj
  let @" = 0
  normal Pjxkk
  " the cursor is now on the original line, but there are now two copies of
  " the the line below it. one copy is left-shifted by one and the other copy
  " is right-shifted by one (zero-padded).
  call ZipBelow()
  normal jddk
  call ZipBelow()
  normal jddk
endfunction

function ZipBelow()
  " go to beginning of line
  normal 0
  while col(".") < col("$") - 1
    call AddBelow()
    normal l
  endwhile
  call AddBelow()
endfunction

function AddBelow()
  let col1 = col(".")
  normal j
  let col2 = col(".")
  if col1 != col2
    normal k
    return
  endif
  normal "aylk"byl
  let @c = @a + @b
  normal x"cP
endfunction
