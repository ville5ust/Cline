# BARE-KNUCKLE — CART (M1–M4 playable slice)

**File:** [`cart/bareknuckle.lua`](cart/bareknuckle.lua) — 865 lines, single-file
TIC-80 text cartridge (Lua). Audit: `python3 tools/check_lua.py cart/bareknuckle.lua`
→ **PASS (structural), undefined-call lint: clean**.

## Run it

TIC-80 loads `.lua` files natively as carts:

```bash
tic80 cart/bareknuckle.lua          # run directly
# or inside the TIC-80 console:
load cart/bareknuckle.lua
save bareknuckle.tic                # produce the binary cartridge
```

No external assets: faces, ring, bars and gore are drawn procedurally with
`circ/rect/pix`, so the cart is 100 % self-contained and modifiable from the
TIC-80 editor.

## Controls

| Btn | Keyboard | Action |
|-----|----------|--------|
| D-pad | arrows | navigate roster / orders / market |
| Z (A) | z | confirm: start, take fight, call corner order, advance ledger |
| X (B) | x | **THROW THE TOWEL** (once per fight, HEAT +1) |

## Implemented states

`TITLE → ROSTER → MARKET → FIGHT → RESULTS → (MARKET | GAMEOVER → TITLE)`

## Mechanics shipped in this slice (traceable to the 33)

| # | Mechanic | In cart |
|---|----------|---------|
| 1 | Splits-based corner orders | 6 orders, stamina cost, BRAWL doubles damage both ways |
| 2 | Towel dilemma | 1 towel per fight (X), HEAT+1, available in MENU **and** during the 10-count |
| 3 | Round-by-round blood meter | 0–8 per fighter, drawn as 8 blocks, doctor stoppage roll at 8/8 |
| 4 | Tale-of-the-tape recon | $80, 70 % reliable, 30 % "plausible lie" quoting your own fighter |
| 5 | Anatomy wound map | head/ribs/hands/eyes pools 0–20, states OK→DOWN, penalties wired to sim |
| 6 | Permanent scar gallery | pools ≥12 at bell → permanent scar bits, portrait overlay, roster flag |
| 7 | Torn-glove rule | bare-knuckle hand wear 6 %/punch, 10 % self-injury at FRACTURED, fight gate at 12+ |
| 11 | Blood-money ledger | purse curve 120→900→4,200, medical bill, blood money on loss, bet settle 1.8× |
| 12 | Chalk-lane shylock | +$500 loan, 10 % vig per card, heat at debt >1500 |
| 14 | Gate/bar/tokens (purse curve) | Fight-of-the-Night crowd bonus (crowd ÷ 2 added to purse) |
| 22 | Blood appetite (crowd) | crowd meter climbs with damage/KDs, decays per round |
| 27 | Hall of Bruises (seed) | careers, scars, deaths persist in pmem |
| 30 | Age curves | age stored/persisted (decline curve stubbed for M6) |
| 31 | Bruiser Bugle | tone shifts: NEW FACE → PROMISING → SUSPECT → **BUTCHER OF MARKET ROW** |
| 32 | Four Deaths endings | GOLDEN GLOVE / KINGPIN / MARTYR / PAUPER, NG+ level persists over save wipe |
| 33 | Save-file curse | persistent byte: 12 % per fight a "ghost" collects $100 |

## Persistence (audited save plan)

pmem layout: words 0–8 header (magic `BKMG`, version, money+1e6, fight, heat,
debt+1e3, tone, ngp, curse); per fighter 7 words (name packed 4 chars/word,
stats bitfield, 4×5-bit wound pools, scar bits, career). **37 words total** —
~0.45 % of FREE 8,192-word pmem, leaving room for the full M6 legacy archive.
Saved on every roster/market exit and at the final bell; NG+ and curse bytes
survive the `pmem(0,0)` wipe.

## Determinism

Each fight stores `F.seed`; `TIC()` reseeds from `seed + tick*7 + fight*13`, so a
stored fight is replayable from one word (architecture audit §4). Particles
(64 max), shake (±3 px, border-masked) and 2-frame hit flash are presentation-
only and never feed sim state.

## Audited constraints honoured

- 240×136, 16-color SWEETIE palette; blood = colour 2, dried = 1, bone = 12
- ≤4 px gore effects, 64-particle pool, no sprite-bank usage (procedural draw)
- No string allocation in the hot render path except the short feed lines
- Gore escalation is **format**, not frequency: stage 0–4 derived from pools+blood
- Content integrity: pulp 1987 fiction, procedural names, violence stays in the ring

## Known gaps → next milestones

- M5: sprite-based portraits/ring art (currently procedural; `cart/sprites/SPRITE_SHEETS.md`
  is the M5 design doc: faces S0–S5, gore decals, ring props, UI icons) → **IN PROGRESS**;
  sprite budget ≤200/bank + visual-checklist gates from [VISUAL-FEASIBILITY-AUDIT.md](VISUAL-FEASIBILITY-AUDIT.md)
- M6: heir system (#29), Hall of Bruises archive UI (#27 full), Blue Hour raids (#26), chant register (#23), heckler gallery (#25), age-decline curve
- Sound: `sfx()` bell/crowd stings
- Balance pass: run 2,000 headless sims via the audit plan before human playtests