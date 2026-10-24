# BARE-KNUCKLE — Balance & Fun Audit Plan (GDA Methodology)

Target: brutal/gory TIC-80 bare-knuckle boxing manager. Constraints: 128x128 px, ~64KB cart, Lua data table tuning, sessions measured in 10-minute "nights." Audit owner: balance economist. Version 1.0.

---

## 1. CORE ECONOMY — Purse / Medical / Gambling / Crime

### 1.1 Design intent
Money is the drama engine. Every fight must resolve into one of three emotional outcomes: **get paid** (glory), **pay the man** (medical debt), or **chase the dragon** (gambling/crime spiral). The economy is intentionally cruel: a washed-up career should be survivable but never comfortable.

### 1.2 Canonical numbers (30-fight career arc)

Assume a career starting at age 24, reputation 0, ending at reputation 100 (champion) or ruin.

| Parameter | Start | Mid (F15) | End (F30) | Notes |
|---|---|---|---|---|
| Purse per win | 120 | 900 | 4,200 | ~35% rep-gated growth + fight-tier multiplier |
| Purse per loss | 40 | 250 | 900 | "Blood money" — paid even for losing |
| Win rate expected | 55% | 60% | 50% | Opponent quality scales faster than fighter |
| Baseline weekly burn (food, rent) | 90 | 140 | 180 | Inflation-lite; never lets you coast |
| Medical cost per KO taken | 150 | 600 | 1,500 | Scales with damage, not just outcome |
| Medical cost per injury (fracture/gore) | 80 | 300 | 700 | Per injury, stacks |
| Doctor clean bill (post-fight mandatory) | 60 | 120 | 250 | Fixed per fight, non-avoidable |
| Cutman upgrade tier | 100 | 250 | 500 | One-time buys, 4 tiers |
| Training one cycle | 70 | 150 | 250 | Stamina/str/power tradeoff |

**Example money flow, Fights 1–30 (expected-value sim, 55% win rate, no gambling):**

- F1–F10: avg purse +170/fight, avg outflow 190/fight → **net −20/fight. You are losing money winning.** This is intentional: the player must take a side job (crime minigame) or gamble small.
- F11–F20: avg purse +620, outflow 340 → **net +280/fight.** First breakeven crossover at **Fight 8 (median) / Fight 11 (mean)**. Breakeven = cumulative earnings curve crosses cumulative burn+medical curve.
- F21–F30: avg purse +2,600, outflow 900 → **net +1,700/fight.** Late career should feel rich for ~3 fights, then the title shot demands: trainer fee 3,000 + corner fee 800 + "clean gloves" optional bribe 1,200.

**Savings curve targets:**
- Median bankroll at Fight 10: **+150 (poor but alive)**
- Median at Fight 20: **+1,800**
- Median at Fight 30 (champion path): **+9,500**
- Median at Fight 30 (downfall path): **−2,300 (debt to the bookies)**

### 1.3 Gambling economy
- **Pari-mutuel betting on own fight**: bet your own win at odds 1.4–1.9 (odds drift with reputation). Betting on yourself to LOSE pays 3.5–5.0x but costs reputation ×1.5 and can trigger the "tanked fight" scandal event.
- **Underground fights** (no purse, betting only): stake up to 100% of bankroll, expected house edge 8%. Very high variance. Wired to gore: bloodier fight = bigger house handle = bigger invite next week.
- **Rule of thumb to tune to**: gambling should be +EV (in player favor, ~+12% EV) for bankrolls under 400 (the desperate), and −EV (−8%) above 2,000 (the house protects itself from winners). This creates the classic trap: gambling helps you escape ruin, then drags you back.

### 1.4 Crime economy (side jobs)
| Job | Pay | Risk of event | Cooldown |
|---|---|---|---|
| Enforce for bookie | 200–350 | 25% injury, 15% arrest | 2 fights |
| Fix a fight | 500–1,500 | 30% rep loss ×2, 10% career end | 4 fights |
| Smuggle | 800 | 40% arrest (bail = 2× pay) | 3 fights |
| Throw a fight (as the fixer) | 1,000–2,500 | rep −30, ban risk 12% | 5 fights |

Crime money should be **fast, dirty, and sticky** — 40% of crime income is "burned" in events (bribes, bail, stolen back). Net crime EV ≈ +180/job at mid-career vs. +280 from a won fight. Crime is a floor, never a ladder.

### 1.5 Ruin risk
- **Debt spiral rule**: if bankroll < −500, bookies take a weekly 15% vig on all income. Below −1,500, you get the "kneecaps" event: forced underground fight with 25% stat damage.
- **Ruin probability targets** (1000-run sim, no gambling, no crime):
  - Gentle: **< 8%** of careers hit ruin by Fight 30
  - Standard: **18–25%**
  - Meat Grinder: **35–45%**
  - With gambling enabled, add +10–15 points to each — gambling must be the player's own choice to burn.
---

## 2. DIFFICULTY CURVE — Three Ramps as Tunable Parameters

All three ramps use the same parameter table; only values change. This is the spreadsheet contract (see §6).

| # | Parameter | Gentle | Standard | Meat Grinder |
|---|---|---|---|---|
| D1 | Starting bankroll | 500 | 250 | 80 |
| D2 | Win rate adjustment (opponent quality vs. rep) | −15% | 0 | +12% |
| D3 | Medical cost multiplier | ×0.6 | ×1.0 | ×1.7 |
| D4 | Burn rate per fight | 80 | 120 | 160 |
| D5 | Injury severity roll (dmg→fracture chance) | 0.08 | 0.15 | 0.28 |
| D6 | Recovery fights after KO | 1 | 2 | 3–4 |
| D7 | Career length (fights before forced retirement roll) | 40 | 32 | 26 |
| D8 | Stat decay per fight (age 28+) | 0.3 | 0.7 | 1.2 |
| D9 | Gambling house edge | −14% (player-favored) | +8% | +15% |
| D10 | Crime event severity | ×0.5 | ×1.0 | ×1.4 |
| D11 | Comeback event frequency (lucky break) | 1 per 5 fights | 1 per 8 fights | 1 per 12 fights |
| D12 | Title shot requirements | rep 70 | rep 85 | rep 95 + 2 rival wins |

**Curve shape (all ramps):** difficulty follows a sawtooth, not a ramp. Difficulty index = `0.5×(fight# /30)^1.4 + opponent_scout_roll`. Every 5th fight is a "showcase" (−20% difficulty, big purse) to produce a guaranteed dopamine spike; every 7th–9th fight is a "meat fight" (+25% difficulty, low purse, high injury) to produce the low point. This alternation is the dramatic engine more than absolute numbers.

**Ramp feel targets:**
- Gentle: player should reach Fight 30 with ≥60% of careers alive and ≥1 title shot taken.
- Standard: 40–50% alive, 25% take the title shot, ~15% retire "washed."
- Meat Grinder: 20–30% alive; the ones who survive should feel like legends. High attrition is the point — a Meat Grinder champion must be a badge.

---

## 3. FUN CURVE AUDIT — Dramatic Arc per 10 Minutes

### 3.1 The 10-minute night loop
One TIC-80 "fight night" (sim + decisions + aftermath) = ~2–3 minutes. Target: **3–4 decision-dense nights per 10 minutes**, and within every 10-minute window the player must experience at least one event from each column of the drama table:

| Slot | High beat (glory) | Low beat (downfall) | Swerve (surprise) |
|---|---|---|---|
| ~min 0–3 | Win purse / knockout call | Medical bill lands | Odds shift against you |
| ~min 3–6 | Crowd chant / rep milestone | Injury forces skip | Scandal / fix rumor |
| ~min 6–10 | Gambling hit ×2.5 | Debt spiral trigger | Rival event, fight offer at bad terms |

### 3.2 How 30+ mechanics interlock (interaction map)
1. **Fight sim** → damage → 2. **Injury table** → 3. **Medical costs & recovery** → 4. **Bankroll pressure** → 5. **Gambling/crime temptation** → 6. **Rep change** → 7. **Fight offers & odds** → loops back to 1. Plus parallel loops: **stat decay** (age loop) and **rival escalation** (narrative loop).
- The key interlock to audit: **damage is the currency of both glory and cost.** A bloodier win pays more (purse bonus +15% for "Fight of the Night") but costs more medically. Player must consciously choose gore. If players can get both without a tradeoff, the loop is broken.
- Second key interlock: **gambling availability rises exactly when the player is desperate** (betting window opens at bankroll < 200 or after a loss). The fun curve requires the "dragon" to whisper at the low beats, not randomly.

### 3.3 Good fun vs. bad fun loop (must both exist, must be distinguishable)
- **Good fun**: earned glory — the showcase win, the comeback after 2 losses, the ×2.5 self-bet cashed. Feel: "I did this."
- **Bad fun (productive)**: downfall with agency — losing everything because you bet it on yourself, the kneecaps event after your third fix. Feel: "I did this to myself and it's a great story."
- **Bad fun (unproductive — must be audited out)**: RNG ruin with no decision behind it (a random injury cascade at full health, an event with no telegraph). Rule: **every low beat must be traceable to a player choice made ≤2 fights earlier.** If a playtest traces a downfall to no decision, that's a bug, not grit.

### 3.4 Arc shape over 30 fights (target emotional profile)
F1–3 hook (winnable, cheap, first blood) → F4–8 squeeze (money gets tight, first big medical bill) → F9–12 first spiral or first showcase (branch point) → F13–18 grind with rival story → F19–24 peak variance (title contention, max stakes) → F25–30 resolution (champion / washed / ruined — three authored endings). **Nothing new is introduced after Fight 24** except escalations of known mechanics.

---

## 4. RISK AUDITS — 8 Design Risks

| # | Risk | Why it kills the game | Detection heuristic | Fix |
|---|---|---|---|---|
| R1 | **Gore becomes wallpaper** | Repeated gore moments stop landing; players skim the violence | In playtests, count gore reactions: if mention rate of gore drops <1 per 10 min after Fight 10, or 0 screenshots/quotes of gore | Gore budget: escalate format, don't frequency. Tier gore (bruise → cut → fracture → career-end) with rarer, more dramatic presentations; cap frequency at 1 major gore beat per night |
| R2 | **RNG frustration / phantom agency** | Player attributes unavoidable losses to "rigged" dice | Post-session interview: any "the game cheated" statement = fail; log fights where outcome was decided before player decisions (backtestable) | Telegraph risk: pre-fight scout screen shows opponent tendencies; make injury rolls visible ("doctor says 30% fracture risk — fight anyway?") |
| R3 | **Spreadsheet fatigue** | Too many numbers per decision; the manager becomes accounting | Decision time per night > 25 s median, or players ignore 2+ of the 5 core stats entirely | Hard cap: 5 visible stats + 2 contextual. All derived values (odds, risk %) shown as icons/words, not numbers. Auto-preset tactics ("safe/bloodthirsty") |
| R4 | **Money never matters late** | Late-game wealth trivializes medical/gambling tension | Median bankroll at F25 > 5× mid-career medical cost | Late-game money sinks: title fees, rival blackmail, injury costs ×3 at heavyweight tier; purse scales but so do stakes |
| R5 | **Death spiral that isn't the player's fault** | Ruin feels random, not earned | Ruin autopsy: % of ruined careers where no gambling/crime/ignore-injury decision preceded ruin — must be <25% | Add "mercy valve": at ruin threshold, offer one authored last-chance event (underground fight, fix offer) before career end |
| R6 | **Gambling dominates optimal play** | The math says always bet; drama becomes slot machine | Sim: if optimal strategy includes betting >60% of fights, or players bet >80% of bankroll repeatedly | Keep the ±EV inversion (§1.3); cap self-bet at 50% bankroll; add cooldown after wins |
| R7 | **Difficulty ramp invisible** | Players can't tell Gentle from Meat Grinder; tuning feels arbitrary | A/B playtest: session length and ruin rate statistically indistinguishable across ramps | Make difficulty legible via fiction: Meat Grinder = bloodier crowd, harsher doctor prices shown on-screen; log ramp-specific metrics per session |
| R8 | **TIC-80 scope collapse** | 30 mechanics × economy × gore sprites blows the 64KB cart / 128px readability | Cart size > 55KB or any mechanic lacking a distinct on-screen pixel identity | Prototype-first rule: each mechanic must earn its cart bytes via the playtest protocol; mechanics failing decision-density audits get cut before polish |

---

## 5. PLAYTEST & AUDIT PROTOCOL — 12-Point Checklist

Each point has a measurable pass/fail. Run on 8+ sessions × 3 difficulty ramps.

| # | Check | Measure | Pass | Fail |
|---|---|---|---|---|
| P1 | Hook lands | Time to first memorable moment | ≤ 3 min | > 5 min |
| P2 | Decision density | Player decisions per minute (any deliberate choice) | ≥ 2.0/min during nights | < 1.0/min |
| P3 | Session length (organic) | Median voluntary session | 10–25 min | < 7 min or forced exits early |
| P4 | Comeback frequency | % of careers with ≥1 "down-then-up" arc (≥3-loss dip followed by title contention) | 30–55% | <15% (hopeless) or >70% (no stakes) |
| P5 | Gore-moment highlight rate | Verbal/physical reaction to gore per 10 min | ≥ 0.8/10 min in F1–10; ≥0.5 sustained | <0.3 after F10 (wallpaper — see R1) |
| P6 | Agency on downfalls | % of ruin/spiral events traceable to a player decision ≤2 fights back | ≥ 75% | < 50% (R5 fail) |
| P7 | Gambling behavior | % of players who gamble ≥3 times; % who bust via gambling | 40–70% try it; bust-via-gambling 10–25% | >40% bust (predatory feel) or <20% try (invisible) |
| P8 | Economy breakeven | Median fight at which income > burn | F8–F12 (Standard) | <F5 (trivial) or >F16 (oppressive) |
| P9 | Ramp separation | Ruin rate delta between ramps | ≥2× difference Gentle vs. Meat Grinder | <1.3× (R7 fail) |
| P10 | Readability | Time to parse fight-night screen; % correct predictions of fight outcome from scout info | <4 s parse; prediction accuracy 55–75% | >8 s, or accuracy <45% (noise) |
| P11 | Spreadsheet fatigue check | % of nights where player skips tactic/finance choice | <20% skipped | >40% skipped (R3 fail) |
| P12 | Ending resonance | Post-playtest: player can narrate their career in one sentence, and wants "one more career" | Yes / yes | No, or "why did I lose?" with no cause |

**Protocol cadence:** audit at prototype milestones F1–3 (loop core), F1–10 (economy), full 30-fight sim dump (2,000 automated career sims per ramp before human playtests — the sim dump validates §1–§2 numbers; humans validate §3 feelings).

---

## 6. BALANCE SPREADSHEET SPEC — One Lua Table

Single source of truth: one sheet (`BALANCE`) that exports directly to a TIC-80 Lua data table. All numeric, no formulas in exported cells (compute in Lua).

### Columns (A–L):
| Col | Field | Type | Example |
|---|---|---|---|
| A | `id` | string key | `purse_win` |
| B | `gentle` | number | 120 |
| C | `standard` | number | 150 |
| D | `meat` | number | 180 |
| E | `curve_exp` | number (exponent on fight#) | 1.4 |
| F | `ramp_start_fight` | int | 1 |
| G | `ramp_end_fight` | int | 30 |
| H | `value_at_start` | number | 120 |
| I | `value_at_end` | number | 4200 |
| J | `variance_pct` | number (±%) | 25 |
| K | `difficulty_index_ref` | int (0–12, links to D-params) | 1 |
| L | `notes` | string (not exported) | "scales w/ rep × tier mult" |

### Rows (grouped):
- **BLOCK E — ECONOMY** (rows 1–12): `purse_win`, `purse_loss`, `purse_potn_bonus`, `burn_weekly`, `med_ko`, `med_injury`, `med_checkup`, `cutman_tier[1..4]`, `training_cost`, `trainer_fee_title`, `crime_ev`, `debt_vig_pct`
- **BLOCK G — GAMBLING** (rows 13–18): `odds_self_win_min/max`, `odds_self_lose_min/max`, `house_edge_low_bank`, `house_edge_high_bank`, `bankroll_threshold_low`, `bankroll_threshold_high`, `selfbet_cap_pct`
- **BLOCK D — DIFFICULTY PARAMS D1–D12** (rows 19–30): exactly the parameters in §2, one row each, columns B–D per ramp
- **BLOCK F — FUN & ARC** (rows 31–36): `showcase_every_n`, `showcase_diff_mod`, `meatfight_every_n`, `meatfight_diff_mod`, `comeback_every_n`, `gore_beat_cap_per_night`

### Export target (Lua, fits cart):
```lua
BAL = {
  eco = {purse_win={g=120,s=150,m=180,e=1.4,v=25,a=120,b=4200},
         med_ko={g=90,s=150,m=255,e=1.1,v=30,a=150,b=1500}},
  gamb = {house_edge_low={g=-14,s=8,m=15}, selfbet_cap=0.5},
  diff = {D1={500,250,80}, D2={-15,0,12}, D3={0.6,1.0,1.7}},
  fun = {showcase_every=5, meatfight_every=8, comeback_every={5,8,12}}
}
```
Compact form ≈ 1.5KB — safe for the 64KB cart. **Tuning rule:** one playtest cycle changes values only in this sheet; if a fix can't be expressed in this sheet, it's a design change, not a balance change.

### One-sheet tuning workflow
1. Run 2,000 sim careers per ramp → check §1.5 ruin targets, §2 feel targets, P8/P9.
2. Adjust ≤5 cells per iteration (log them — no shotgun tuning).
3. Human playtest 8 sessions → P1–P12 checklist.
4. Iterate; freeze economy before polishing gore presentation (R1 fixes are art-first, not numeric).