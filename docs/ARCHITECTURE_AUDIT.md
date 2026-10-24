# BARE-KNUCKLE — Technical Architecture Audit & Plan (TIC-80)

Brutal/gory bare-knuckle boxing **manager** game for TIC-80 (Lua). You run a stable of
fighters: sign them, train them, bet on them, watch fights resolve tick-by-tick with
gore events, and ride their careers into legacy.

Target runtime: **TIC-80 1.x (FREE)** as the baseline; **TIC-80 PRO** treated as an
optional stretch target that unlocks headroom (noted inline).

---

## 1) RESOURCE AUDIT — what TIC-80 actually gives us

### 1.1 Hard limits (FREE baseline)

| Resource | Limit | Notes for BARE-KNUCKLE |
|---|---|---|
| Code bank | **64 KB** uncompressed, split across up to **16 code tabs** (one shared Lua namespace) | Manager logic + fight sim + UI. Budget ~55 KB, keep ~9 KB slack for iterations. LZ4-compressed at cart save time, but the *source* limit is what bites. |
| Lua runtime | Lua **5.4**, incremental GC, coroutines supported | Coroutines are legal and cheap — use them for the fight sim instead of hand-rolled state machines. |
| Total RAM | **80 KB** (see breakdown below) | Runtime working set, not persistent. |
| VRAM | 16 KB (240×136 px, 16 colors) | Fixed; UI drawn via `spr`/`rect`/`print`, no framebuffer abuse needed. |
| Sprite RAM | 8 KB per bank = **256 8×8 entries** per bank (4bpp, 32 B each); tiles & sprites **share** the same 256 slots per bank | ~512 total slots across 2 banks in FREE. Fighter portraits must be **procedurally composited** (small parts: head, torso, arms, blood overlays) or they won't fit. Reserve ~64 slots for UI/chrome. |
| Map RAM | 32 KB (2 bytes/cell: tile + flags) | Not a map game — leave map RAM alone (or reuse as scratch buffer if ever needed). |
| Sound | ~16 KB + registers; 64 SFX per bank | ~32 SFX budget: punches (4 hits × 3 materials), bone crack, crowd swell, bell, heartbeat-at-low-stamina. |
| Persistent memory | **32 KB** via `pmem(index, val)` — index is a **32-bit word**, so **8,192 words** usable | This is the entire save file. See §4. |
| Input | **6 buttons** (U/D/L/R + A/B); mouse supported | Menu-driven game, 6 buttons is plenty; mouse optional for market screens. |
| Cartridge | 1 `.tic` file | Everything ships in one cart. |
| Main loop | `TIC()` at **60 FPS**; `SCN`/`BDR` line callbacks available | Sim decoupled from render via a fixed-tick accumulator (§3). |

### 1.2 What TIC-80 PRO unlocks (stretch target)

| Feature | FREE → PRO | Why it matters here |
|---|---|---|
| Persistent memory | 32 KB → **256 KB** | Roster of 40+ fighters with full stat history, season archives, fight logs. The single biggest win for a *manager* game. |
| Banks | 1 per section → **8 banks each** (code/sprites/map/sound) | ~512 KB code potential; separate sprite banks for portrait packs per league tier. Bank switch costs a reload — swap banks only at state transitions, never mid-frame. |
| Commercial license | non-commercial → commercial | Relevant only if we sell it. |

**Decision:** design to FREE limits; make the save format word-addressed so it
transparently scales into 256 KB Pro PMEM (§4).

### 1.3 Budget reality check

- 16 colors: gore must read through **shape + motion + particle** (blood as 2–3
  colored particle tiers + decals), not palette richness.
- 64 KB code: a full manager with fight sim in Lua is **tight but doable**
  (~40–55 KB). The discipline that saves us is *data-driven* fighters (tables, not
  code per fighter) and *shared* UI rendering.
- 8,192 pmem words: a compressed save fits comfortably at ~30–60 fighters; season
---

## 2) ARCHITECTURE — single cartridge, module layout

### 2.1 Code tabs (all share one global namespace; prefix-gated)

```
boot.tic-lua      -- B: TIC(), fixed-tick accumulator, state dispatch, rng seed mgmt
core.tic-lua      -- C: util (lerp, clamp, pack/unpack, table pool), EVENT BUS, RNG
data.tic-lua      -- D: DATA-DRIVEN TABLES: fighter archetypes, move tables, injury/
                     gore tables, league schedules, opponents, price/economy curves
state.tic-lua     -- S: STATE MACHINE: enter/exit hooks per state, transitions
ui.tic-lua        -- U: shared widgets (list, bar, panel, cursor), one draw pass
title.tic-lua     -- T1: TITLE, NEW/CONTINUE
roster.tic-lua    -- T2: ROSTER (list, detail, stats history)
train.tic-lua     -- T3: TRAINING (allocate weekly points, minigame-lite)
market.tic-lua    -- T4: MARKET (free agents, bets, odds from sim)
fight.tic-lua     -- T5: FIGHT_NIGHT — coroutine sim, arena render, gore layer
results.tic-lua   -- T6: RESULTS + press/event text, injuries, payouts
legacy.tic-lua    -- T7: LEGACY (career end, hall of fame, new dynasty)
save.tic-lua      -- V: serialize/deserialize to pmem, versioned migration
```

### 2.2 State machine

States: `TITLE → ROSTER → TRAINING → MARKET → FIGHT_NIGHT → RESULTS → LEGACY`
with `FIGHT_NIGHT ↔ MARKET` (betting) and `RESULTS → TRAINING` (recovery) edges.

```lua
-- state.tic-lua
ST = {}
function setState(id, ...)
  local st = ST[state] ; if st and st.exit then st.exit() end
  state = id ; ST[id].enter(...)
end
function TIC()          -- boot.tic-lua
  tickAcc = tickAcc + 1
  local st = ST[state]
  if st.update then st.update() end   -- input + logic (may resume coroutine)
  if st.draw then st.draw() end       -- pure render, no allocation
end
```

Rules: states own their enter/exit (enter builds UI cache, exit frees it).
`boot` owns the tick; nothing else touches `TIC` internals.

### 2.3 Event bus (core)

Decouples sim from UI/results — the fight coroutine **emits**, listeners
**render / log / save**.

```lua
-- core.tic-lua
local subs = {}
function on(ev, fn) (subs[ev] = subs[ev] or {})[#subs[ev]+1] = fn end
function emit(ev, a, b, c)          -- fire immediately; no allocations in hot path
  local l = subs[ev]
  if l then for i=1,#l do l[i](a,b,c) end end
end
-- events: PUNCH_LAND, PUNCH_MISS, BLOCK, CUT, KNOCKDOWN, BONE_BREAK,
-- TKO, KO, DECISION, CROWD(shift), BET_SETTLE, INJURY, PRESS_QUOTE
```

### 2.4 Data-driven tables (data)

Fighters, moves, injuries, and leagues are **arrays of flat tables**, never code:

```lua
-- D: archetypes (10 archetypes × modifiers = hundreds of fighters, zero extra code)
ARCH = {
  { name="IRONHEAD", hp=95, pow=8, chin=9, spd=4, stam=6, tech=2, mental=5, style="swarm" },
---

## 3) FIGHT-NIGHT SIM LOOP — tick pseudocode (15 Hz sim tick)

```lua
function simTick(fA, fB, crowd)
  -- 1. STAMINA: drain = base + lastActionCost; regen = (stamStat*0.4 + guard*0.6)
  for _,f in ipairs({fA,fB}) do
    f.stam = clamp(f.stam + regen(f) - f.lastDrain, 0, 100) ; f.lastDrain = 0
  end
  -- 2. AI DECISION (alternating priority each tick)
  --    inputs: stamina ratio, damage taken, aggression mood, crowd meter,
  --    style weights from MOVES table, odds pressure (the manager's bet!)
  --    output: {move=, intent="attack|guard|feint|clinic"}
  --    low stam → guard/clinic bias; wounded foe + hot crowd → swarm bias
  -- 3. RESOLUTION: acc roll vs defender spd/guard; crit on pow roll
  --    damage = pow * (1 + momentum) * stamPenalty(attacker)
  --    accumulate: hp, CUT_ACCUM (per face zone), STAGGER (≥ thresh → wobble anim)
  -- 4. GORE TRIGGER: if CUT_ACCUM[zone] > GORE[zone].thresh →
  --    emit("CUT", zone, sev) → blood particles (pool of 64), decal flag,
  --    crowd += sev, injured fighter: acc −=, hp drain per round (cuts worsen)
  --    BONE_BREAK: rare — chin roll < pow*0.25 → fight-ending table lookup
  -- 5. CROWD METER (0..100): += gore events & knockdowns; -= passive ticks;
  --    drives crowd sfx gain; "foul tactics" AI option to milk it (boos)
  -- 6. DOWN/COUNT: hp<=0 or BONE_BREAK → knockdown; 3 downs in a round = TKO
  -- 7. PARTICLE/DECAL TICK: fixed 64-slot particle pool, ring buffer
end
```

Rendering is a pure consumer: fighters = composited sprites (stance frame per tick
bucket), particles drawn from the pool, HUD (hp/stam bars, cut icons, crowd meter).
**No `print`/string concatenation per tick** — pre-rendered digit sprites for numbers
(§5.1).

---

## 4) SAVE / PERSISTENCE PLAN (pmem, 8,192 words)

### 4.1 What fits

pmem is word-addressed 32-bit values. Strategy: **pack structs into words** with
`band/bor/shl`; version the blob. Compact stat encoding: each stat 0–10 → 4 bits.

| Block | Words (approx) | Content |
|---|---|---|
| Header | 2 | magic `0x4B4E5543` ("KNUC"), version, seed epoch |
| Career | 4 | week#, money (32-bit cents), league tier, dynasty name hash |
| Fighter (each) | 6 | 8 stats × 4 bits (1 word) + flags/W/L (1) + name hash (1) + age/contract/mood (1) + injury bitmask (1) + cut-scar bitmask (1) |
| League tables | 16 | per tier: top-8 hashes + points, packed 2 words each |
| Roster of 24 | ~144 | 24 × 6 words |
| Season fight log (capped) | 64 | last 64 fights: seed + outcome packed, 1 word each (replayable via seed!) |
| Economy/odds state | 8 | market prices, bet slips |
| **Total typical** | **~240–400 words (≈1–1.6 KB)** | **~20× headroom in FREE; trivial in Pro** |

Because each stored fight keeps its RNG seed, full fight replays cost 1 word —
do **not** store fight narratives.

### 4.2 Versioned save

```lua
-- save.tic-lua
---

## 5) PERFORMANCE & MEMORY AUDIT CHECKLIST (10 concrete checks)

1. **String allocation per frame:** zero `..` concatenation or `string.format` inside
   `TIC` render paths — every `print` uses pre-built strings or digit sprites.
   Audit: grep render paths for `..` at each milestone.
2. **GC pressure / table churn:** the sim tick allocates nothing. AI decision tables,
   particles (fixed 64-slot pool), and exchange results are **reused tables**, never
   fresh ones. Audit: pool sizes constant across a 3-minute fight.
3. **Coroutine hygiene:** one coroutine alive per fight, explicitly finished at fight
   end; no coroutine leaked per round. Audit: coroutine count returns to 0 post-fight.
4. **RNG discipline:** `math.randomseed(seed)` exactly once per fight, from the saved
   seed; never reseed mid-fight (breaks replayability). TIC-80 does **not** seed for
   you. Audit: same seed → identical fight outcome, byte-identical save delta.
5. **Sprite bank overflow:** 256 slots per bank and tiles share the bank. Portrait
   parts + gore overlays + UI chrome ≤ 200 slots per bank, 56 reserved.
   Audit: script counts slot usage from the source-of-truth asset table.
6. **Code bank creep:** 64 KB total across tabs. Per-milestone gate: dump tab sizes,
   total ≤ 90% (57.6 KB). Trim by moving text tables to compressed packed strings,
   decompressed once at load.
7. **pmem bounds:** every `pmem` write index-clamped `< 8192` (FREE); end-marker word
   verified on load; save routine refuses to write if computed size exceeds limit.
   Audit: force-save with a 40-fighter roster.
8. **Update/render separation:** `draw` functions never mutate state; input handled
   only in `update`. Prevents double-processing if `TIC` timing ever changes.
9. **Sim/render decoupling:** fight logic at a fixed 15 Hz tick via accumulator;
   renderer consumes, never drives. Audit: 60 FPS holds on the worst-case frame
   (max particles + both fighters + crowd fx + HUD).
10. **Determinism for saves:** no frame-timing dependence inside sim (no `time()` in
    fight logic — UI animations only); sim iterates fighters as arrays, never
    hash-order pairs. Audit: replay from stored seed reproduces identical results.

---

## 6) DEVELOPMENT MILESTONES (each with an audit gate)

**M1 — Walking skeleton.** `boot` + state machine + one placeholder state; fixed-tick
accumulator; event bus stub; empty save/load round-trip.
*Gate A:* 60 FPS stable; state transitions leak nothing (table count before/after
enter/exit identical); save→load reproduces header magic; code ≤ 15 KB.

**M2 — Roster & career core.** Data-driven fighter tables; ROSTER + TRAINING states;
week advancement; save format v1 with migration stub.
*Gate B:* 24-fighter roster saves ≤ 512 words; loads cleanly; all stats mutate
through events (no direct writes from UI code).

**M3 — Market & betting.** MARKET state, opponent generation from archetypes, odds
curve, bet slips persisted.
*Gate C:* odds within ±10% of headless sim outcomes across 100 generated fights
(run fight coroutines without rendering); code ≤ 30 KB.

**M4 — Fight-night sim (the heart).** Full coroutine tick loop: stamina, AI, damage
accumulation, knockdowns/TKO/KO/decision; RESULTS state, payouts, bet settlement.
*Gate D:* deterministic replay from seed verified (checks #4/#10); 15 Hz tick holds
60 FPS with zero per-tick allocation (checks #1/#2); code ≤ 45 KB.

**M5 — Gore layer & presentation.** Cut zones, blood particle pools, decals, bone
breaks, crowd meter driving sfx; composited portraits from the sprite bank; arena
polish.
*Gate E:* sprite usage ≤ 200/bank (check #5); worst-case frame still 60 FPS
(check #9); all gore events routed through the event bus.

**M6 — Legacy meta-game & full loop.** LEGACY state, hall of fame, injuries carrying
into careers, cut scars persisting on portraits, season logs, title defenses,
save v2 migration from v1.
*Gate F:* full 10-minute session end-to-end with 3 fights; migration v1→v2 verified
on a real v1 save; final pass of all 10 checklist items; code ≤ 57 KB; save ≤ 800
words typical, hard-capped at 1,600.

---

## Appendix — risk register (top items)

| Risk | Mitigation |
|---|---|
| 64 KB code ceiling hit late | Data tables packed; text as compressed strings; UI widgets shared, never per-state copies |
| Gore reads as mush in 16 colors | Ship a "gore readability" test scene in M5; palette mapping lives in data, not hardcoded |
| Save corruption | magic + end-marker + version; refuse load on mismatch; `CONTINUE` fallback keeps a safe copy |
| AI decisions opaque to player | fight log strip in RESULTS fed by the event bus (press quotes generated from events) |
SLOT_BASE = 0
function save()
  pmem(SLOT_BASE,   0x4B4E5543)          -- magic
  pmem(SLOT_BASE+1, SAVE_VERSION)        -- v1 = 1
  local w = SLOT_BASE+2
  w = writeCareer(w) ; w = writeRoster(w) ; w = writeLeague(w) ; w = writeLog(w)
  pmem(w, 0)                             -- end marker
end
function load()
  if pmem(SLOT_BASE) ~= 0x4B4E5543 then return nil end
  local v = pmem(SLOT_BASE+1)
  while v < SAVE_VERSION do v = migrate(v) end  -- read old layout, write as v+1
  return readAll(v)
end
-- migrate(n): reads version-n layout, rewrites as n+1; chained until current.
```

Rules: save only at **state exits** and fight completion (never mid-tick);
every `SAVE_VERSION` bump ships with a `migrate` stub; keep old readers in
`save.tic-lua` until at least one shipped version is deprecated.
  { name="GHOST",    hp=70, pow=4, chin=4, spd=9, stam=8, tech=9, mental=7, style="boxer" },
}
MOVES = { jab={pow=2,stam=1,acc=85,cut=5}, hook={pow=5,stam=3,acc=60,cut=15},
          upper={pow=7,stam=5,acc=45,cut=20}, elbow={pow=4,stam=2,acc=55,cut=35,gore=2} }
GORE  = { -- cutLoc, severity, particle burst id, crowdShift, penalty
  { loc="brow", sev=3, fx="BLOOD_SPRAY", crowd=+2, accPenalty=-10 } }
```

### 2.5 Coroutine-based fight night (fight)

One Lua coroutine per fight; `TIC` resumes it. Sim logic ticks at **15 Hz**
(every 4th frame at 60 FPS) via the accumulator in `boot`; rendering runs every frame.

```lua
-- fight.tic-lua
function fightCoroutine(seed)
  math.randomseed(seed)  -- deterministic: seed stored in save for replay
  initFighters(fA, fB)
  for round=1, ROUNDS do
    bell(round) ; crowdSwell()
    for t=1, TICKS_PER_ROUND do            -- 15 Hz × 45 s compressed round
      stepStamina(fA) ; stepStamina(fB)     -- regen ≤ drain, modified by guard
      resolveExchange(aiDecision(fA,fB,crowd), fA, fB)  -- emits PUNCH_*/KD/GORE
      resolveExchange(aiDecision(fB,fA,crowd), fB, fA)
      tickParticles() ; stepCrowdMeter()
      if knockdownPending then resumeCount() ; coroutine.yield("kd") end
      if fightOver() then break end
      coroutine.yield()                      -- hand control back to TIC (1 sim tick)
    end
    coroutine.yield("round_end")
  end
  scorecards() ; coroutine.yield("done")
end
```

`TIC` resumes with `coroutine.resume(co)`; yields carry phase tags so the renderer
knows whether to draw the arena, the knockdown cam, or the card screen.
  histories are the thing that doesn't. Cap history (§4).