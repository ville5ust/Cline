# BARE-KNUCKLE — MASTER PLAN (auditoitu) v1.0

**TIC-80 Pro — Bare-Knuckle Boxing Manager. Brutal & gory retro pixel fiction.**

> Tämä on koko projektin juurisuunnitelma: visio, 33 mekaniikkaa, ja viiden
> riippumattoman GDA-sub-agentin auditoinnin synteesi. Suomi-yhteenveto ylhäällä,
> yksityiskohtainen englanninkielinen spesifi alla.

---

## 1. TIIVIS YHTEENVETO (FI)

**Peli:** TIC-80:lle toteutettava bare-knuckle nyrkkeilyn manageripeli. Pelaaja ei
ole nyrkkeilijä — hän on kulissien takana oleva manageri sumuisessa
teollisuuskaupungissa: hän kirjaa hurjapäitä, korjaa kasvot, pitää kulmauksen
otteluyönä, käyttää palkkion rahat ja vastaa kenelle tahansa, jolla on rahaa
tai kaunaa. Ei käsineitä, ei sanktiointielintä, ei ambulanssia.

**Tunnusluku:** 33 äärimmäisen hauskaa, toisiinsa kytkeytyvää mekaniikkaa
(katso [docs/MECHANICS_33.md](docs/MECHANICS_33.md)), jotka jakautuvat
*good-path*- (kunnia, kurinalaisuus) ja *bad-path*- (raha, veri, rappio)
mekaniikoihin. Väki on brutaali ja gore-retrohengoitteinen — tarkasti
auditoiduissa pixel-rajoissa.

**Auditointivarmaus:** Viisi riippumatonta sub-agenttia (mekaniikkasuunnittelu,
visuaalinen auditointi, gore-järjestelmäauditointi, koodiarkkitehtuuriauditointi,
tasapaino/viihtyisyysauditointi) tuottivat kunkin oman auditointidokumentin.
Päätulos: **projekti on toteutettavissa** — resurssikäyttö ~36 % spritepankeista,
koodi ~55 KB / 64 KB, tallennus ~240–400 sanaa / 8 192 (FREE) tai 256 KB (Pro).

**Jatkoselkä (interlock spine):** kulmauskäskyt (1) synnyttävät haavoja (5–9) →
haavat pakottavat romuhakuisuuteen (16) → hakuisuus herättää kartellin (20) →
kartelli laukaisee uhkailuillat (21) → uhkailuillat romahduttavat
kaupunginosan maineen (24) → maine romahduttaa palkkiot (14) → köyhyys pakottaa
lainoihin (12, 17) → velka laukaisee ratsiat (26) → ainoastaan Hall of Bruises (27)
ja Bruiser Bugle (31) muistavat miksi — ja NG+ (32, 33) pakottaa elämään sen kanssa.

---

## 2. VISION (EN)

You are not a boxer. You are the man behind the man. A single TIC-80 cartridge:
64 KB of Lua, 16 colors, a coroutine fight sim at 15 Hz, and a persistent world
that remembers every scar — and one byte that remembers your worst act forever.

The fun thesis: **damage is the currency of both glory and cost.** Bloodier wins
pay more but cost more. The player authors every low beat and every high beat;
"every low beat must trace to a player decision ≤2 fights back, else it's a bug,
not grit."

---

## 3. SUB-AGENT AUDIT ROSTER & VERDICTS

| # | Sub-agent | Deliverable | Verdict |
|---|-----------|-------------|---------|
| 1 | **MECHANICS-DESIGNER** | 33 interlocking mechanics, 7 systems, good/bad-path tags → [docs/MECHANICS_33.md](docs/MECHANICS_33.md) (854 lines) | PASS — full interlock spine validated |
| 2 | **VISUAL-AUDITOR** | Palette, sprite budget, gore rendering, UI layout → [VISUAL-FEASIBILITY-AUDIT.md](VISUAL-FEASIBILITY-AUDIT.md) (190 lines) | FEASIBLE — ≈358/1024 sprites (36%), one overflow risk auto-rejected |
| 3 | **GORE-SYSTEMS-AUDITOR** | Damage model, 6-stage gore ladder, consequences, guardrails → [docs/GORE_SYSTEMS.md](docs/GORE_SYSTEMS.md) (233 lines) | PASS — brutal but accountable ("brutal in the ring, accountable in the ledger") |
| 4 | **CODE-ARCHITECT-AUDITOR** | Limits, 13 tabs, coroutine sim, save plan, milestones → [docs/ARCHITECTURE_AUDIT.md](docs/ARCHITECTURE_AUDIT.md) (317 lines) | PASS — design to FREE limits, Pro headroom is transparent |
| 5 | **BALANCE-FUN-AUDITOR** | Economy numbers, difficulty sawtooth, risk audits, playtest protocol → [bare_knuckle_balance_audit_plan.md](bare_knuckle_balance_audit_plan.md) (197 lines) | PASS — with 2,000-sim gate before any human playtest |

### Cross-audit conflict resolution (the audit of the audits)

| Conflict | Resolution |
|----------|------------|
| Visual auditor wants shared injury overlays; mechanics wants per-fighter scar gallery | Only ≤4 star fighters get bespoke scar art; roster uses overlay sprites + `pal()` swaps |
| Architecture wants 15 Hz sim; visual wants 60 FPS juice | Sim ticks every 4th frame; juice (shake/flash/particles) renders every frame from sim state |
| Balance wants frequent gore; playtest risk #1 is gore-wallpaper | Gore escalates in **format** (6 stages), not frequency; `CARNAGE_BIAS` ships at 1.0 |
| Mechanics wants death events; fun audit caps random deaths | Death ≤5% of careers, 100% traced to logged player decisions (declined towel ×2) |
| Save memory vs 33-mechanic persistence | Bit-packed words, ~240–400 words typical, versioned migration chain; Pro's 256 KB pmem absorbs growth |

---

## 4. THE 33 MECHANICS — SYSTEM MAP

| System | Mechanics | Path |
|--------|-----------|------|
| A. Fight-Night Corner | 1 Corner Orders, 2 Towel Dilemma, 3 Blood Meter, 4 Tape Recon | good-path core loop |
| B. Injury & Gore | 5 Wound Map, 6 Scar Gallery, 7 Torn-Glove Rule, 8 Bone-Crack Replay, 9 Canvas Feeds | bad-path consequence engine |
| C. Money & Vice | 10 Chalk-Lane Shylock, 11 Blood-Money Ledger, 12 Laudanum Schedule, 13 Sawbones Retainer, 14 Door/Bar/Tokens | bad-path economy |
| D. Roster & Human Cost | 15 Spar-Ring Ladder, 16 Second's Eye, 17 Pallet Dorm, 18 Pauper's Plot, 19 Farmhand Pipeline | good/bad mix |
| E. Crime & Pressure | 20 First Envelope, 21 Threat Nights, 26 Blue Hour Raids, 33 Save-File Curse | bad-path spiral |
| F. Crowd & Culture | 22 Blood Appetite, 23 Chant Register, 24 Rain Card, 25 Heckler's Gallery | good-path feedback |
| G. Legacy & Succession | 27 Hall of Bruises, 28 Promoter's Handshake, 29 Heir System, 30 Age Curves, 31 Bruiser Bugle, 32 Four Deaths Endings | both paths, endgame |

Full detail per mechanic (description, TIC-80 primitive, FUN AUDIT) →
[docs/MECHANICS_33.md](docs/MECHANICS_33.md).

---

## 5. HARD CONSTRAINTS (audited numbers)

- Screen 240×136, 16 colors ("CARNAGE-16" palette: 4-tone skin ramp, 3-tone blood ramp 2/3/4, reserved bruise purple 15, bone-white 1; **no red in crowd/ring/UI — every red pixel is blood by definition**)
- Sprites: 4 banks × 8192 B = 1024 sprites total; budget ≈358 (bank0: 123, bank1: 129, bank2: 56, bank3: 50); tiles 4–5: 52
- Code: 64 KB across ≤16 tabs; budget 55 KB (≤90% per milestone gate)
- RAM 80 KB; persistent 32 KB FREE → 256 KB TIC-80 **Pro** (biggest win for a manager game; design to FREE limits)
- Sim: coroutine per fight, 15 Hz fixed tick; gore: 3 reserved colors, ≤4 px effects, 64-particle blood pool
- Save: magic + version + end-marker, bit-packed ~240–400 words, every stored fight keeps its RNG seed (full replay from 1 word)

## 6. MILESTONES & AUDIT GATES

| Milestone | Scope | Audit gate (must pass) |
|-----------|-------|------------------------|
| M1 | Walking skeleton: state machine, save round-trip, 60 FPS | leak-free transitions, save v1→v1 restore |
| M2 | Roster & career core (mechanics 15–19) | wound-map persistence heals on calendar |
| M3 | Market & betting (10–14) | odds validated against 100 headless sims |
| M4 | Fight-night sim (1–4) | determinism gate, zero-alloc tick, replay-from-seed |
| M5 | Gore layer (5–9 + gore ladder) | sprite budget ≤200/bank, worst-case-frame perf gate |
| M6 | Legacy meta-game (27–33) | code ≤57 KB, save ≤800 words, v1→v2 migration verified |

Each gate = one of the 10-point architecture checklist + relevant playtest checks.

## 7. BALANCE NUMBERS (from BALANCE-FUN-AUDITOR)

- Purses 120 → 900 → 4,200 (F1→F15→F30); F1–10 nets **−20/fight even while winning** (deliberate squeeze)
- Breakeven median F8 / mean F11; late career +1,700/fight, title shot costs ~5,000
- Gambling: +12% EV under 400 bankroll, −8% above 2,000; self-bet (lose) 3.5–5×, capped at 50% bankroll
- Crime: EV ≈ +180/job vs +280 won fight (floor, never ladder); 40% burns in bail/bribe
- Ruin targets (1,000 sims): Gentle <8%, Standard 18–25%, Meat Grinder 35–45%; ramp delta ≥2×
- Sawtooth curve: showcase fight (−20% diff, big purse) every 5th; meat fight (+25%) every 7th–9th

## 8. PLAYTEST & AUDIT PROTOCOL

2,000 automated sims per ramp **before** human playtests. Key measurable pass criteria:
decision density ≥2.0/min · median session 10–25 min · comeback arc in 30–55% of careers ·
gore highlight ≥0.8 per 10 min early · breakeven F8–F12 · ramp ruin delta ≥2× ·
complicity test ≥70% · towel temptation ≥50% of sessions · death ≤5% of careers, 100% decision-traced ·
pizza-parlor tone re-screen per content patch.

Full 12-point protocol → [bare_knuckle_balance_audit_plan.md](bare_knuckle_balance_audit_plan.md) §5;
gore checks → [docs/GORE_SYSTEMS.md](docs/GORE_SYSTEMS.md) §6.

## 9. CONTENT INTEGRITY GUARDRAILS (non-negotiable)

Abstract pixel fiction only · no real people (combinatorial name generator + blocklist) ·
violence stays in the ring (gore colors dropped on roster screens) · escalation player-triggered ·
every gore display has a mechanical receipt · death is mourned, never celebrated ·
1980s sports-pulp tone lock ("would this look wrong on a CRT in a pizza parlor?").

## 10. FILE MAP

```
docs/MASTER_PLAN.md                  <- this document (root plan)
docs/MECHANICS_33.md                 <- Sub-agent 1: 33 mechanics bible
docs/GORE_SYSTEMS.md                 <- Sub-agent 3: brutality & gore systems
docs/ARCHITECTURE_AUDIT.md           <- Sub-agent 4: technical architecture audit
VISUAL-FEASIBILITY-AUDIT.md          <- Sub-agent 2: visual audit
bare_knuckle_balance_audit_plan.md   <- Sub-agent 5: balance & fun audit
```