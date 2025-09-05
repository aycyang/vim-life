# Conway's Game of Life implemented in Vim

Disclaimer: This project is purely for personal entertainment and learning. I make no promises that this will be of value to anyone but me.

### How to use

Run:

```
vim -S life.vim examples/glider.txt
```

Once in Vim, you can run the simulation by pressing `\`, then `r`. Alternatively, run the following command:

```
:call GameOfLife()
```

To stop the simulation, you can press `Ctrl-c`.

### Notes

- This should be compatible with versions of Vim before 9, because I didn't use vim9script.

### Todo

- [ ] handle dynamic resize
