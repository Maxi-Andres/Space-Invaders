# Space Invaders in x8086 Assembly

A **Space Invaders** clone written from scratch in **8086 Assembly** for DOS and built with Turbo Assembler (TASM). The whole game runs in text mode (80x25), and the enemies, the ship and the final boss are drawn with ASCII block characters (`█ ▄ ▀`). Sound comes from the PC speaker.

```
     ▄█▄█▄          ▄█▄█▄          ▄█▄█▄
     █▄█▄█          █▄█▄█          █▄█▄█
      ▀ ▀            ▀ ▀            ▀ ▀

   ▄█▄█▄          ▄█▄█▄          ▄█▄█▄
 █▄█▄█▄█▄█      █▄█▄█▄█▄█      █▄█▄█▄█▄█
 ▄█ ▀ ▀ █▄      ▄█ ▀ ▀ █▄      ▄█ ▀ ▀ █▄

                     ¡

                    ▄█▄
```

---

## How to play

### Windows

You don't need to install anything. The repo already includes DOSBox 0.74 and TASM in `tools/`.

1. Clone the repo, or download it as a ZIP from GitHub and extract it.
2. Double-click **`run.bat`**.
3. DOSBox opens, builds everything and starts the game. The build pauses between steps, so press any key to continue.

### Linux / macOS

Install DOSBox with your package manager (`apt install dosbox`, `brew install dosbox`, etc.), then run this from the repo folder:

```
dosbox -conf dosbox.conf
```

---

## Controls

|   Key   | Action                                         |
| :-----: | ---------------------------------------------- |
|   `A`   | Move left                                      |
|   `D`   | Move right                                     |
|   `W`   | Shoot                                          |
|  `Esc`  | Quit                                           |
| `Space` | Keep playing / retry (on end-of-level screens) |

---

## Gameplay

- **18 enemies in 3 rows** sweep from side to side and drop one row each time they reach an edge. If one touches you or reaches the bottom, you lose.
- **Points by row:**

  | Enemy                  | Points |
  | ---------------------- | ------ |
  | Top row (green)        | 30     |
  | Middle row (cyan)      | 20     |
  | Bottom row (red)       | 10     |
  | Mystery ship (magenta) | ?      |

- **Mystery ship:** every now and then it flies across the top of the screen and leaves. You don't need to kill it to clear the level, but it gives bonus points.
- **4 levels**, each at a different speed. Score and high score are tracked.
- **Final boss:** after level 4 a big boss (26x7 characters) shows up and shoots at random. It takes 28 hits to kill. You get 3 lives in this part.

---

## How it works

The game uses two **custom interrupts** that are installed before it starts. They are memory-resident programs (TSRs) built as `.COM` files:

| File           | Interrupt | What it does                                                                                                                                         |
| -------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `intSound.asm` | `int 80h` | Plays a tone on the PC speaker by programming the timer (PIT, port `42h`) and port `61h`. Takes the tone in `CX` and the duration in `BX`.            |
| `intRand.asm`  | `int 84h` | Returns a "random" number from 0 to 9 in `AL`, taken from the clock's hundredths of a second (`int 21h`, function `2Ch`). The boss uses it to decide when to shoot. |

The game itself (`Game14h.asm`) uses:

- **BIOS `int 10h`** in video mode `02h` (80x25 text) to move the cursor and draw in color.
- **BIOS `int 16h`** to read the keyboard without blocking the game. It also flushes repeated keys from the buffer, so the ship stops moving when you release the key.
- **DOS `int 21h`** to print text and exit the program.
- **BIOS `int 15h`** (function `86h`) for the delays that set each level's speed.
- **VGA vertical retrace sync** (port `3DAh`), so the screen is redrawn without flicker.

### Building

`game.bat` runs inside DOSBox and does everything in order:

1. `intRand`: assembles it with `tasm /zi /m`, links it as a `.COM` with `tlink /t`, and runs it to install `int 84h`.
2. `intSound`: same thing, for `int 80h`.
3. `Game14h`: assembles it, links it as an `.EXE` with debug info (`tlink /v`), and runs it.

Inside DOSBox, `TASM`, `TLINK` and `TD` (Turbo Debugger) are on the `PATH`. To rebuild after changing the code, type `game`. If the keyboard doesn't work right, type `keyb sp` for a Spanish layout, or `keyb us` for US.
