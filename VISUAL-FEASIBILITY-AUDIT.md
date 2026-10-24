# BARE-KNUCKLE — Visual Feasibility Audit (TIC-80)

Target: TIC-80 0.90+, 240×136 px, 16 colors, 8×8 sprites.
Hard budget: **4 sprite banks × 8192 B** (0–3) and **2 tile banks × 8192 B** (4–5).
Sprite math: 8×8 @ 4bpp = **32 B/sprite → exactly 256 sprites per bank, 1024 sprites total.**
Each sprite bank also carries **256 B of flags** (8 flag bits/sprite) — use flags for decal/overlay/anchor marking, not for extra art.
Text costs **0 sprite bytes** (use `print()`/`font()`); every UI drawn with `rect()`, `rectb()`, `circ()`, `pix()` is free. Only pixel art consumes the budget.

Verdict up front: **FEASIBLE with comfortable headroom** (≈358/1024 sprites, ≈11.5 KB/32 KB sprite banks, ≈52/512 tiles) — *provided* injuries are palette-swapped overlays, not per-fighter redrawn art. The one genuine overflow trap is "unique injury art per fighter"; see §2 risks.

---

## 1) PALETTE STRATEGY — "CARNAGE-16"

Custom palette replaces SWEETIE-16. It is organized as **ramps**, because gore readability depends on separating the blood ramp from the skin ramp and reserving one color for bruise.

| Id | Hex | Role |
|----|---------|------|
| 0 | `#0e0b10` | Near-black outline / UI background / clot shadow |
| 1 | `#f5f0e6` | **Bone white** — protruding fractures AND bright UI text (dual-purpose) |
| 2 | `#d5263a` | **Arterial red** — fresh blood, HP/danger bars, KO flash |
| 3 | `#7a1420` | Dried blood — canvas decals, older cuts |
| 4 | `#3d0a12` | Clot black-red — pooled blood, deep gorges |
| 5 | `#f0c8a0` | Skin highlight |
| 6 | `#cf8f62` | Skin base |
| 7 | `#96593a` | Skin shadow |
| 8 | `#5a3524` | Deep skin / leather trunks / wood desk |
| 9 | `#d9a530` | Gold — championship belt, money, warnings |
| 10| `#3fae52` | Green — healthy vitals, wins, cash-positive |
| 11| `#3f6db8` | Blue — UI selection, corner towels, cold UI |
| 12| `#b8a08c` | Ring canvas / bandage wrap / bone-adjacent neutral |
| 13| `#6a6472` | Crowd mid-grey (spotlit rows) |
| 14| `#403c48` | Crowd dark (background rows) |
| 15| `#7a4a8f` | **Bruise purple** — contusions, swelling rings, corner man shadows |

**Gore-readability rationale (why these 16):**
- **Blood ramp = 3 tones (2/3/4).** Fresh → dried → clot gives temporal storytelling on the canvas: a decal can be "aged" for free by re-drawing with color 3/4 remaps. Bright `#d5263a` is the most saturated hue on screen, so it wins the eye against the desaturated canvas (12) and crowd (13/14).
- **Skin ramp = 4 tones (5/6/7/8).** Cuts read as *holes in the ramp*: any skin pixel replaced by 2/3 instantly reads as a wound at 8×8 scale. A 2-tone skin ramp would not.
- **Bruise purple (15) is reserved exclusively for injuries.** It is adjacent in hue to skin shadow but hue-shifted, so a bruise overlay reads at a glance and *never* appears in UI, ring, or crowd — one color = one semantic ("this fighter is hurt").
- **Bone white (1) doubles as UI text.** Fractures are 1–2 white pixels at a joint anchor; the shared color means bone pops identically on skin and on canvas.
- **No pure red in the crowd or ring furniture.** Ropes are blue (11) so that red pixels anywhere on the fight screen are *always* blood. This is the single most important readability rule of the game.
- Keep index 0 as the darkest color — KO flashes remap "everything → 2" and need 0 to stay dark for contrast.

---

## 2) SPRITE BUDGET — audited per screen/state

Notation: `2x2` = one 16×16 image = **4 sprites / 128 B**. All banks hold 256 sprites / 8192 B.

### Bank 0 — Portraits & injury overlays (target ≤ 200/256)

| Asset | Count | Sprites | Bytes |
|---|---|---|---|
| Roster portraits, 16×16 (`2x2`), 16 fighters | 16 | 64 | 2048 |
| Generic facial-injury overlays, 4 severities × `2x2` | 16 | 16 | 512 |
| Joint/anchor fracture overlays (bone-white), 6 anchors × 1 sprite | 6 | 6 | 192 |
| Swelling/bruise overlay set (`1x1` + `2x2` variants) | 4 | 5 | 160 |
| Title-screen hero pose `3x4` | 1 | 12 | 384 |
| Headshot stance variants (cut eyebrow / taped jaw), `1x1` | 8 | 8 | 256 |
| Head coaches/corner men `2x3` | 2 | 12 | 384 |
| **Bank 0 total** | | **123** | **3936 B (48%)** |

### Bank 1 — Fight-night boxers (target ≤ 180/256)

| Asset | Count | Sprites | Bytes |
|---|---|---|---|
| Boxer frames: idle, bob, jab, cross, hook, uppercut, hit-react, block — `3x3` (24×24) each | 8 | 72 | 2304 |
| Second fighter: **palette-swapped clone of the same 8 frames** | 0 | **0** | 0 |
| Knockdown / on-canvas / getting-up sequence, `4x2` each | 3 | 24 | 768 |
| Referee, `2x3` | 1 | 6 | 192 |
| Corner men at stool, `2x3` | 2 | 12 | 384 |
| Cut-man working frames | 2 | 12 | 384 |
| Blood spurt burst frames (drawn at muzzle anchors) | 3 | 3 | 96 |
| Hit-flash copy: **palette remap, no duplicate sprite** | — | **0** | 0 |
| **Bank 1 total** | | **129** | **4128 B (50%)** |

### Bank 2 — Ring, crowd, gore decals (target ≤ 120/256)

| Asset | Count | Sprites | Bytes |
|---|---|---|---|
| Canvas blood decals, 8×8 (splash, smear, drag, spray, pool, footprint) | 24 | 24 | 768 |
| Large pool decals `2x2` | 3 | 12 | 384 |
| Crowd tile variants, animated 2 frames | 4 | 8 | 256 |
| Camera-flash glint, spotlight glow | 2 | 2 | 64 |
| Ring furniture not done as tiles (turnbuckle pad, stool, bucket, towel) | 6 | 6 | 192 |
| Sweat/spit particles (2×2 and 1×1) | 4 | 4 | 128 |
| **Bank 2 total** | | **56** | **1792 B (22%)** |

### Bank 3 — Manager UI icons (target ≤ 64/256)

| Asset | Count | Sprites | Bytes |
|---|---|---|---|
| 16×16 icons: gloves, belt, contract, med kit, scale, money bag, ticket, newspaper | 8 | 32 | 1024 |
| 8×8 stat glyphs (fist, chin, heart, footwork), 2 frames for pulse | 8 | 8 | 256 |
| Injury-tab icons (cut, bruise, break, fatigue) | 4 | 4 | 128 |
| Cursor/hand pointer, arrows, checkbox/cross | 6 | 6 | 192 |
| **Bank 3 total** | | **50** | **1600 B (20%)** |

### Tile banks 4–5 — environments (target ≤ 70/512)

| Asset | Tiles | Bytes |
|---|---|---|
| Ring canvas (4 clean + 2 blood-soaked variants) | 6 | 192 |
| Ropes / ropes-crossing / posts | 8 | 256 |
| Apron, ring skirt, floor around ring | 10 | 320 |
| Crowd seating rows, tunnel, arena wall | 16 | 512 |
| Desk/office furniture for manager screens (map-drawn) | 12 | 384 |
| **Total** | **52** | **1664 B (10% of 2 banks)** |

### Grand total
**358 sprites ≈ 11.5 KB / 32 KB sprite banks (36%) · 52 tiles ≈ 10% of tile banks. Feasible with ~2.9× headroom.**

### ⚠️ Overflow risks (flagged)
1. **Per-fighter unique injury art — the killer.** 32 fighters × 4 severities × `2x2` = **512 sprites (half the entire game budget) for one screen.** Mandatory mitigation: shared generic overlays anchored onto shared portraits + `pal()` color remaps. Only "star" fighters (≤4) may get bespoke injury art (≤32 sprites).
2. **24×24 fighters are seductive.** One extra animation frame per boxer = 9 sprites / 288 B. Cap at 8 frames; add "juice" with flash/particles, not frames.
3. **Crowd portraits.** Distinct crowd-member sprites (even 8 variants × 2 frames) silently eat bank 2; the budget keeps crowds as **tiles + palette noise**, not sprites.
4. **Flags are 8 bits/sprite only** — decal layering, flip states, anchor IDs must fit in 8 flags or live in code data tables.
5. If bank 2 decal pressure grows: the canvas is 240×80 px of repeatable content — draw decals **procedurally with `pix()`/`circ()`** (0 sprites). This is the designated escape hatch (§3.6).

---

## 3) GORE RENDERING TECHNIQUES (8×8 sprites, 16 colors)

1. **Palette-swap injury states (0 bytes per state).** Draw the same portrait sprite, then remap skin colors before `spr()`: `pal(5,15)` / `pal(6,15)` / `pal(7,15)` shifts the whole skin ramp toward bruise purple; `pal(6,2)` pales a "winded" fighter. Severity 1–4 = progressive remap tables + overlay sprites. Cost: one `pal()` sequence per draw, **0 sprite bytes**.
2. **Facial injury overlay layering.** Portraits are 16×16; injuries are separate `2x2`/`1x1` sprites drawn *after* the portrait at 6 defined anchor points (left brow, right brow, nose, left cheek, lip, jaw). A fighter's injury record is just `(anchor_id, severity, age)` tuples — render = `spr(overlay[severity], px+ax, py+ay, 0)`. Aging a wound = redraw the severity-1 overlay with `pal(2,3)` (fresh → dried).
3. **Canvas blood decal accumulation.** Maintain a decal array (cap **64 entries**: `{x, y, tile, age, flipx, flipy}`); each knockdown / hard shot pushes a decal. Draw order per frame: canvas tiles → decals → pool `2x2` decals → boxers → spurts. Age buckets 0–2 remap decal color 2→3→4 (fresh→dried→clot).
4. **Hit-flash & spurts (juice, ~0 bytes).** On landed power shots: draw the victim's sprite once with *every* color remapped to arterial red (`pal(0,2)…pal(15,2)`) for exactly 2 frames; spawn 6–10 `pix()` particles with gravity (cap 32 live particles; particles are `pix()`, not sprites). Blood-spurt sprite frames (3 in bank 1) only for "big cut" events.
5. **Knockdown carnage sequence.** Scripted 4-phase state: (a) hit-flash + shake, (b) `4x2` fall frame, (c) canvas decal spray + pool `2x2`, (d) referee count over the downed `4x2` frame with a 2-frame alternate `pal(7,4)` (pale, drained look). Screen shake = camera offset `±3 px` decaying over 12 frames. **CRT-style flicker only during KO cam**: alternate frames dim scanlines via 2 `line()` calls — hard cap 2 flash frames, no full-screen strobing (accessibility + readability).
6. **Persistent blood soak — procedural escape hatch.** When decals approach the 64 cap: paint blood directly with `circ()`/`pix()` at placement time, or keep 24 decal sprites but **randomize flip/mirror/rotation at placement** (8 orientations × 24 decals = 192 visual states from 768 B).
7. **Broken-bone reveal.** Fractures = 2 bone-white (color 1) pixels protruding at a joint anchor + one 1×1 bruise-purple halo, shown on the injury tab and in KO slow-mo. One sprite each, 6 anchors, 192 B total.
8. **Corner cut-man repair.** Between rounds, the cut-man sprite overlaps the fighter for 6 frames while one severity-1 overlay anchor is removed per round — communicates "the corner fixed the cut" with zero new art.

---

## 4) UI LAYOUT AUDIT — 240×136 manager screens

Base layout (manager desk / roster / fighter detail share the chrome):

```
┌────────────────────────────────────────────────────────── y=0
│ TOP BAR y 0–11 (240×12): cash (green 10) │ date │ rep │ week │
├───────────────┬──────────────────────┬───────────────────┤ y=12
│ LEFT PANEL    │ CENTER FIELD         │ RIGHT PANEL       │
│ x 0–119       │ x 120–183            │ x 184–239         │
│ y 12–119      │ y 12–119             │ y 12–119          │
│               │                      │                   │
│ Portrait 16×16│ news/queue feed      │ 4 action buttons  │
│ at (8,18)     │ 6 lines × 10 px,     │ 52×14 each at     │
│ Vitals bars   │ colors: injury=2,    │ (188,18/36/54/72) │
│ (4 bars 40×4) │ money=10, event=9    │ selection = blue  │
│ at (8,40)     │ scroll log           │ border 11         │
│ Injury tab:   │ (max 12 entries)     │ 6 icon buttons    │
│ anchors ×     │                      │ 24×24 at y 92–116 │
│ severity dots │                      │                   │
├───────────────┴──────────────────────┴───────────────────┤ y=120
│ TICKER y 121–135 (240×15): last 2 log lines, marquee     │
└──────────────────────────────────────────────────────────┘
```

Pixel-region audit:

| Region | Rect | Purpose | Sprite cost |
|---|---|---|---|
| Top bar | (0,0)–(239,11) | persistent HUD: cash/date/rep/week | 0 (text+rects) |
| Left panel | (0,12)–(119,119) | portrait + 4 stat bars + injury tab | portrait = 4 sprites |
| Stat bars | (8,40)–(48,58) | fist/chin/heart/footwork, green→red lerp 10→2 | 0 |
| Injury tab | (8,64)–(116,116) | anchors × severity + purple bruises | overlays ≤ 8 sprites |
| Center feed | (120,12)–(183,119) | 6-line news feed, color-coded | 0 |
| Right panel | (184,12)–(239,119) | 4 action buttons + 6 icon buttons | icons ≤ 24 sprites |
| Ticker | (0,120)–(239,135) | scrolling log, event countdown | 0 |

Rules: **buttons ≥ 14 px tall** (pointer target); selection state = 1 px blue `rectb` + color-1 text; danger states use color-2 **text only, never background fills of 2** — red is blood, red text is danger, no confusion. Fighter detail replaces the left panel with a 32×32 "medical view": portrait `2x2` + fracture overlays + a body-chart drawn with `circb()`/`line()` (0 sprites). Fight night drops all panels: ring occupies (16,8)–(224,112), crowd is tiled above/below it for depth; HUD shrinks to the same top bar + a 60×6 HP/stamina bar per corner at (4,14) and (176,14).

---

## 5) VISUAL AUDIT CHECKLIST — run against every asset

1. **16-color compliance:** extract the sprite sheet's palette; reject any pixel outside the CARNAGE-16 table (a single off-palette pixel breaks `pal()` remaps downstream).
2. **Color-semantic violation scan:** scan the sheet for color 2 (arterial red) in crowd/ring/UI assets — red may appear ONLY in blood, HP/danger bars, and KO flash.
3. **Ramp integrity:** every skin region uses the 5/6/7/8 ramp in order (no skipped tones); every blood region uses 2/3/4. Wrong-ramp pixels fail at 8×8 as "dirty" smears.
4. **Byte-budget re-count:** per bank, `sprites_used × 32 ≤ 8192`; flag any bank > 75% (192 sprites) and force a consolidation pass (merge `1x1`s into `2x2` sheets).
5. **Overlay-anchor collision:** composite each injury overlay on each portrait at all 6 anchors; reject overlays that obscure both eyes or the mouth (face readability = fighter-state readability).
6. **Contrast check at native resolution:** downscale to 240×136 with no scaling cheats; verify blood decals are distinguishable from canvas shadow (color 12 vs 3 — ΔL ≥ 25%).
7. **Flash-safety:** KO sequence contains no full-screen strobe > 2 frames; hit-flash duration ≤ 2 frames at 60 fps.
8. **Palette-swap proof:** render each boxer frame through both fighter palettes and each portrait through 4 severity remaps — confirm no remap degenerates (e.g., entire sprite → one color).
9. **Tile bleed check:** canvas/rope/crowd tiles must tile seamlessly in all 4 directions, and decal sprites must not overhang the canvas walkable region by > 1 px.
10. **Budget drift report:** after each asset drop, re-run the §2 tables and report delta vs the 358-sprite plan; any asset pushing a bank past 200/256 sprites or adding a *new* per-fighter art dependency is auto-rejected to the backlog.

---

*Audit basis: TIC-80 0.90 memory model — 4 sprite banks × 8192 B (256 × 8×8 4bpp sprites + 256 B flags each), 2 tile banks × 8192 B, 16-color indexed palette, runtime-drawn UI costs zero sprite bytes.*