# BARE-KNUCKLE — SPRITE SHEETS (M5)

**TIC-80 cart: `cart/bareknuckle.lua`** · gore ladder: `docs/GORE_SYSTEMS.md` §2.

Procedural draw current (M1–M4) is replaced by sprite data in M5. Sprites are
8×8 / larger pixel-grid definitions, drawn with `spr(id,x,y,colorkey,scale,...)`
into the four editor sprite banks (budget ≤200 slots/bank per architecture audit).

## §1 Face states (ring canvas, 24×18 body + face)

### Body (8×8, 2 frames: standing / leaning)
```
......... 
..####...
..####...
..##.##...
..#####..
..####...
.#####...
..###.....
```

### Face state S0–S5 (one sprite per, all in "injuries" bank)

```
S0 CLEAN        S1 FLUSH       S2 MARKED       S3 SPLATTER      S4 CARNAGE      S5 TOLL
......X         .....o         .....o         ....o.          ....o.          .oooo.
.....oXX        .....oo        ..o..oo        ...o..o         ...o..o         .o..o.
....ooXX        ....oo         ...oo..        ..o.oo.         ..o.oo.         ..oo.
.....oX.        ....o.         ...o.o         ...oo..         ...oo..         .o..o.
....o..X        ....o.         ..o.o          ..oo.          ..oo.          .oo.
.....XX.        ...o.          .o.o           oo.            oo.            o.
...o..X..       ..o.           ..o            ..o             ..o             ..o
.O......o       .O......o       o..........      o........        o..........      O........
```

Color ramps: skin `4/3`, fresh blood `2`, dried `1`, bruise `1`, bone `12`.
**Rule:** no red outside crowd/ring/UI — every red pixel in the sheet is blood.

## §2 Gore decals (canvas, bank 2)

### D0 pool (fresh knockdown)
```
.......
.......
...o...
...o...
..o o..
...o...
...o...
.......
```
### D2 stain / D3 splatter (2 variants)
```
...o...
..ooo..
.oo.oo.
..oo.o.
.oo...
..o...
...o..
```
Palette-animates via `pal()` remap of dried→fresh at age buckets (2→1→3).

## §3 Ring & props

- Backdrop: 32×9 canvas rope tile bank 4
- Corner stool + towel: bank 1 (towel = white `12` cloth)
- Crowd tiles: 16×5 bank 2

## §4 UI icons (bank 3)

- Bell, towel, money clip, syringe, tape, skull — 8×8 each, colorkeyed to palette.

## §5 Audit gates (from MASTER_PLAN + VISUAL-FEASIBILITY-AUDIT)

- ≤200 sprites/bank, gore overlay layers: shared overlays + `pal()` swaps (≤4 star fighters bespoke art)
- ΔL ≥ 25 % luminance between blood and canvas — enforced by visual checklist §5
- overlay anchor collision test, tile-bleed test, flash-safety, ramp integrity per asset drop
