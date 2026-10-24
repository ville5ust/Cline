# BARE-KNUCKLE — BRUTALITY & GORE SYSTEMS

> **Game:** BARE-KNUCKLE — brutal bare-knuckle boxing manager
> **Platform:** TIC-80 · 240×136 · 16 colors · Lua
> **Doc status:** Design spec · v1.0
> **Related docs:** `DESIGN_CORE.md`, `MANAGER_META.md`, `CONTENT_POLICY.md`

---

## 1) DAMAGE MODEL

The damage model is the mechanical spine of the gore systems. Every visual effect, cutman decision, and career consequence traces back to a number stored per fighter per region. **No gore is displayed without an underlying damage value that caused it.**

### 1.1 Regions & Damage Pools

The fighter's body is tracked as **four regions**, each with an independent **Damage Pool ranging 0–20**. Pools only rise during a fight; they reset between fights only via medical clearance (see §3).

| Region | Region Mult | Flavor |
|---|---|---|
| **HEAD** | ×1.5 | Knockout zone. Where fights end. |
| **EYES** | ×1.2 | Vision. Dodge, distance judgment. |
| **RIBS** | ×1.0 | Engine. Power and stamina. |
| **HANDS** | ×0.8 | Weapons. The bare-knuckle tax. |

### 1.2 Region States

Each pool maps to a state with cumulative effects:

| State | Pool Range |
|---|---|
| HEALTHY | 0–3 |
| BRUISED | 4–7 |
| CUT | 8–11 |
| FRACTURED | 12–16 |
| DOWN | 17–20 |

### 1.3 Damage Accrual

On every scoring hit:

```
damage = (punch_power × region_mult) − toughness, minimum 1
```

- `region_mult`: head 1.5 · eyes 1.2 · ribs 1.0 · hands 0.8.
- `toughness` is the fighter's stat (chin/skull). It applies to every region; the region mult already does the anatomical differentiation.
- **Fatigue rule:** after round 4, all damage accrual is multiplied **×1.25**. Late-round accumulation is where fights turn ugly — by design.

### 1.4 Per-Region Effect Table

| State | HEAD | EYES | RIBS | HANDS |
|---|---|---|---|---|
| **BRUISED (4–7)** | −5 stamina regen | −5 punch accuracy | −5 punch power | −10 dodge |
| **CUT (8–11)** | Bleed tick: −1 stamina/round · flash-KD threshold +1 (easier to drop) | Vision blur; each blur event costs **1 cutman charge** to clear | **Hurt-hand flag:** −25% power for 2 rounds | Hurt-hand flag: −25% power for 2 rounds |
| **FRACTURED (12–16)** | **+25% KO vulnerability** on all head shots | Dodge fails vs jab 20% of the time | **−20 punch power** | **Self-injury:** 10% chance per landed punch the striking hand takes +2 self-damage |
| **DOWN (17–20)** | KD on **any clean head hit ≥6 power** | — | **Forced clinch** — fighter cannot throw from distance | Hand **locked for 3 rounds** (cannot punch with it) |

**Referee stoppage:** if **any two regions** reach DOWN, or head is DOWN at the **end of a round**, the referee stops the fight with **60% probability** (checked once per round end).

### 1.5 Management Decisions — The Manager's Hand in the Blood

The player is a manager, not the fighter. All gore flow runs through two per-round levers:

- **3 cutman charges per round.** Spending a charge clears one CUT-tier condition (stops a bleed tick, restores blurred vision, resets a hurt-hand flag). Charges do **not** heal FRACTURED or DOWN — only a fight-ending decision or medical clearance can.
- **1 tactic call per round.** Per-round instruction to the corner (e.g., "protect the head," "body work," "clinch and reset").

**Fielding a FRACTURED fighter** (sending them out for another round while any region is FRACTURED): **−15 fan glory** when it happens. The crowd sees it. The commentators mention it. Your reputation pays.

**Throwing in the towel (TOWEL, key Y):** **−10 fan glory** and the crowd **boos** (audio + crowd sprite reaction). Glory is the meta-currency of notoriety — but note §4: towel temptation must win more often than it loses.

---
## 2) GORE PRESENTATION LADDER

Gore presentation is a strict 6-stage ladder (0–5). Each stage is triggered by mechanical state, not drama instinct. Stages are **additive**: stage 3 looks include stage 1 and 2 marks.

### 2.0 Constraints (apply to ALL stages)

- **Exactly 3 reserved gore colors:** `#5A1A1A` (deep blood), `#C4342D` (fresh blood), `#E8DCC0` (skin/cut contrast). No other palette slot may be repurposed for gore.
- **2–4 px effects only.** Particles ≤4px, splatter arcs ≤5px per blob, stains composited from small pixels.
- **Abstract, not literal.** Pulp-comic abstraction: red marks, streaks, stains. No anatomical rendering, no wounds-as-shapes, no facial distortion.
- Never exceed the palette: gore color is the *only* thing that may tint — never re-map skin sprites.

### 2.1 The Six Stages

| Stage | Name | Visual | Trigger |
|---|---|---|---|
| **0** | **CLEAN** | Fighter sprite unmodified. | Pool < 4 in all regions. |
| **1** | **FLUSH** | 2×2 red-tint pixels on the head/cheek area; bruise tint (muted palette blend, no gore colors yet). | Any region reaches BRUISED (pool ≥ 4). |
| **2** | **MARKED** | 1–2 px red streaks on the face/head; **canvas drip pixels** — blood drips land on the ring canvas (1 px spots that persist for the round). | Any region reaches CUT (pool ≥ 8). |
| **3** | **SPLATTER** | 3–5 px arc sprays on hit; 3–6 canvas splatter pixels per heavy hit; **seeded 8-frame particle burst** — max 12 particles, 12-frame life, deterministic from hit seed (replayable, cheap). | Any region reaches CUT **and** a hit lands ≥ 8 power, OR any region hits FRACTURED. |
| **4** | **CARNAGE ZONE** | Persistent 8×8 stain blobs accumulate on the canvas where the fight has churned; 1 px **blood trail** follows a bleeding fighter; between rounds the **cornerman sprite mops** the canvas (5-second between-round vignette). | Two regions CUT+, or any FRACTURED for 2+ rounds, or canvas drip count ≥ 12. |
| **5** | **THE TOLL** | **Fight-ending presentation:** 6-color desaturation vignette over the scene, slow-mo on the finishing sequence, single staggered fade to the result screen. | Fight ends by KO/stoppage with head FRACTURED or DOWN, or total pool ≥ 45. |

### 2.2 Stage Rules

- **Stage 5 is reserved for the final blow.** It is never used mid-fight; slow-mo and desaturation only run on the fight-ending hit so it stays a punctuation mark, not wallpaper.
- **Stages decay visually but not mechanically.** A cutman charge removes bleed mechanics but visible marks fade only between rounds (story memory).
- **Stage 4 mopping is mechanical, not cosmetic:** stain blobs block nothing but they feed the crowd-glory pulse (see §3) — the crowd reacts to a painted canvas.
- **Determinism:** all particle seeds derive from fight RNG state, so replays and AI-vs-AI sims render identically.

---
## 3) CONSEQUENCE SYSTEM

Gore without consequence is decoration. BARE-KNUCKLE makes damage a **career-long ledger**.

### 3.1 Damage Persistence

- Damage pools **persist between fights** until **medical clearance** is obtained (post-fight clinic visit, costs money + time on the calendar).
- Fighting on damaged regions imports the current pools into the next bout — a FRACTURED hand you fielded on Friday is still FRACTURED next Tuesday.
- **Fighters hide damage.** Unless the player reviews the medical report (a deliberate action), the game only shows a vague "nursing injuries" tag — forcing managers to choose between inspection cost and ignorance.

### 3.2 Permanent Injuries

Repeating damage converts to permanents:

| Condition | Consequence |
|---|---|
| Head FRACTURED **3× career** | Permanent −1 toughness; glass-chin rumor affects contract offers. |
| Hands FRACTURED **3× career** | Permanent −2 punch power. |
| Ribs FRACTURED **3× career** | Permanent −5 stamina regen. |
| Eyes FRACTURED **2× career** | Permanent −10 dodge. |
| Any region DOWN **2× in one fight** | Forced 60-day medical hold, regardless of clearance money. |

### 3.3 Career-Ending & Death Risk

- **Career-ending damage:** a pool hitting 20 (DOWN) in the same region **three fights in a row**, or head DOWN in consecutive fights, ends the fighter's career with a full in-fiction retirement arc (press conference scene, stat freeze, pension ledger).
- **Rare death risk:** death is possible but **rare and always traceable**. It can only trigger when the player **fielded a fighter with head FRACTURED or worse AND ignored an explicit doctor's warning prompt** in that same fight. Probability is low (see §6 telemetry target) and it is *never* random flavor — every death is a consequence of a logged player decision.
- **Death presentation:** black screen, one line of text, ledger penalty. See §5 Rule 6.

### 3.4 Retirement Pipeline

`FIGHT → DAMAGE LEDGER → MEDICAL REVIEW → (clearance | hold | retirement arc) → HALL-OF-FAME / PENSION RECORD`

Retired fighters remain in the game world as trainers, cutmen, or rumor sources — the roster's history is the save file's texture.

### 3.5 Gore Feeds the Meta-Game: Glory vs. Downfall

- **Glory** rises from spectacle: sustained damage stages, knockdowns, a painted canvas (Stage 4), finishing a favored opponent.
- **Downfall** rises from cruelty: fielding FRACTURED fighters (−15), towel refusals that end in stoppages, repeat head trauma.
- The meta-hook is the **margin**: glory pays the bills and grows the stable; downfall costs morality reputation, crowd trust, and eventually medical quality (low-reputation gyms attract cheap cutmen — fewer effective charges).
- A manager can run a clean gym (low glory, slow growth) or a blood gym (high glory, brittle fighters). The design goal: **both viable, both costly.**

---
## 4) GOOD vs BAD FUN AUDIT

Every gore feature is scored on two axes: **thrill** (does it excite?) and **tastelessness/tedium risk** (does it sicken without meaning, or bore through repetition?). Features that score thrill but risk bad fun get **tuning advice** below, not deletion.

| Feature | Thrill | Tastelessness Risk | Tedium Risk | Verdict / Tuning |
|---|---|---|---|---|
| Damage pools (§1) | High | Low — it's numbers | Medium — 4 pools × UI can overwhelm | Compact region glyph UI; hide pools behind one medical screen |
| Bleed ticks (CUT) | High | Low | **High** — passive drain can stall fights | Cap any passive bleed at ≤30s of fight time without a decision point (see §6) |
| Flash-KD +1 (head CUT) | High | Low | Low | Keep. Clean cause→effect |
| Hurt-hand −25% (2 rds) | Medium | Low | Medium | Announce once with icon, then stay silent |
| Self-injury 10% hand rolls | Medium | Medium (watchdog feel) | Medium | Telegraph with 1-frame wince before the roll; add "wrap hands" tactic option as counterplay |
| FRACTURED KO vulnerability | High | Medium | Low | Couple to Stage 3 visuals so the player *sees* why |
| Cutman charges (3/round) | High | Low | Low | The core fun loop — protect it from automation |
| Fielding FRACTURED (−15 glory) | High | **High** — can read as cruelty tourism | Low | Always pair with doctor's warning prompt; make glory loss visible immediately |
| TOWEL decision | **Very high** | Medium | Low | See towel temptation target in §6; never punish towel so hard it's never used |
| Stage 2 MARKED streaks | Medium | Low | Low | Keep — the workhorse look |
| Stage 3 SPLATTER particles | High | **High** if frequent | Medium — novelty decays fast | **Ship hidden `CARNAGE_BIAS` 1.0** (see below); seeded bursts keep cost low |
| Stage 4 CARNAGE ZONE stains | High | Medium | Low | Mopping vignette keeps it "ring history," not gore wallpaper |
| Stage 5 THE TOLL slow-mo | Very high | High if overused | High if overused | **Once per fight maximum.** Never trigger mid-fight |
| Death risk | High (rare) | **Very high** | Low | Trace-to-decision gate (§3.3) + ≤5% telemetry cap (§6) |

### 4.1 CARNAGE_BIAS

- A **hidden float, range 0.8–1.2**, shipped at **1.0** by default.
- Scales Stage 3+ visual trigger thresholds (not damage math): lower = more gore displays, higher = fewer.
- **It is a live-tuning knob, not a content feature.** It never appears in UI, patch notes read as "visual polish tuning," and it exists so gore frequency can be adjusted post-launch without touching mechanics.
- Playtest rule: if thrill scores hold but tastelessness rises, raise `CARNAGE_BIAS` before touching mechanics.

### 4.2 Prime Directive

> **Raise gore legibility before gore frequency.** When gore feels weak in playtests, the fix is almost always making the *existing* effects clearer (bigger context: hit-flash pairing, sound layer, damage-number pop) — not adding more blood. Legibility is free thrills; frequency is a fast path to numbness.

---
## 5) CONTENT INTEGRITY GUARDRAILS

Seven hard rules. These are **release blockers**, not suggestions. A build violating any rule does not ship.

### Rule 1 — Abstract Pixel Fiction Only
All gore is pulp-comic abstraction: particles ≤4 px, streaks, stains, tints. No anatomical detail, no wound shapes, no dismemberment sprites, no realistic injury rendering. Fighters are pulp sprites — exaggerated, comic-book, clearly fictional.

### Rule 2 — No Real People
Fighters are generated via a **combinatorial name generator** (syllable pools + nickname tables + region/culture flavor lists). A **real-person blocklist** runs at generation and at save-load: if a generated name matches a known real boxer/public figure (normalized comparison), it is discarded and regenerated. Never ship, mention, or homage a real fighter, alive or dead.

### Rule 3 — Violence Stays in the Ring
The gore palette colors (`#5A1A1A`, `#C4342D`, `#E8DCC0` in gore contexts) are **dropped on roster screens** — gyms, contracts, menus, hall of fame. Damage appears there only as clean text/icons. Blood belongs to the canvas and nowhere else.

### Rule 4 — Escalation Is Player-Triggered
- **Stage 3+ gore presentation requires a player-chosen damage target** (the manager's tactic/cutman targeting decision escalates the presentation).
- **AI-vs-AI simulated fights cap at Stage 2.** Background fights never splatter.
- Before any fight where Stage 3+ is possible, the **TOWEL (Y) prompt is shown for 2 rounds first** — the player must have seen the off-ramp before escalation can occur.
- The player is always complicit *by informed choice*, never by ambush.

### Rule 5 — Every Gore Display Has a Mechanical Receipt
No visual effect exists without a backing stat change the player can verify: a splatter means a damage roll landed; a stain means pool ≥ 8 happened there; a vignette means a threshold crossed. Any effect that can't show its receipt gets cut. (This is also the debugging tool: if you can't point to the number, the pixels are lying.)

### Rule 6 — No Glorified Death
If a fighter dies: **black screen, one line of text** (name, date, "the sport lost one of its own"), and a **ledger penalty** — financial and moral, recorded permanently in the save. No slow-mo, no tribute montage, no glory gain, no dramatic music. Death is a cost, never a climax.

### Rule 7 — 1980s Sports-Pulp Tone Lock
All gore-adjacent copy (commentary lines, newspaper headlines, cutman dialogue, result screens) stays in gritty 1980s sports-pulp register — sweat, smoke, odds, hometown pride. **The pizza-parlor CRT test:** if a line reads as if scribbled on a napkin at a 1983 pizza-parlor boxing night under a CRT glow, it passes; if it reads as edgy-for-edginess, shock-writing, or modern grimdark, it's rewritten.

---
## 6) AUDIT CHECKLIST

Eight playtest checks. **All eight must pass** before any gore-tuned build ships. Log results per build in `QA_LOG.md`.

| # | Check | Method | Pass Criteria |
|---|---|---|---|
| 1 | **Complicity test** — does the player feel they *chose* the gore? | Survey after fights that reached Stage 3+: "Did your decisions cause what you saw?" | **≥70%** of players answer yes |
| 2 | **Towel temptation** — is TOWEL (Y) a real, tempting option? | Instrument sessions; count fights where towel was available, considered (hover/consider window), or thrown | Towel considered or used in **≥50% of sessions**; not >80% (else it's the only right answer) |
| 3 | **Legibility** — can a player read what happened and why? | Timed test: after each Stage 3+ event, player states which region was hit and what state it caused | Correct read within **≤2 s** of the effect, ≥80% accuracy |
| 4 | **Shock decay** — does gore still land by fight #15? | Compare player heart-rate/self-report arousal at first Stage 3+ in fight #3 vs fight #15 in the same career | Decay ≤50% from fight #3 to fight #15; if worse, raise `CARNAGE_BIAS` and re-test |
| 5 | **No passive bleed wallowing** — fights never stall in unmanaged bleed | Instrument fight timelines for stretches of bleed-tick drain with no player decision point | No stretch of **>30 s** of passive bleed without an available decision (cutman charge, tactic, towel) |
| 6 | **Consequence recall** — do players remember that damage matters? | Post-session interview: "What happened to your fighter last time?" | ≥1 consequence story (permanent injury, hold, retirement, glory hit) recalled per session on average |
| 7 | **Death telemetry** — is death rare and always earned? | Full-save audit: every death traced through its decision chain (fielded FRACTURED + ignored doctor warning) | **≤5% of careers** contain a death; **100%** of deaths traced to a logged player decision, zero unattributed deaths |
| 8 | **Tone re-screen** — does all gore-adjacent copy still pass Rule 7? | Full copy re-read against the pizza-parlor CRT test each patch | 100% of gore copy passes tone test; violations rewritten before merge |

---

## Appendix A — Quick Reference

- **Pools:** head / ribs / hands / eyes, 0–20 each. States: HEALTHY 0–3 · BRUISED 4–7 · CUT 8–11 · FRACTURED 12–16 · DOWN 17–20.
- **Formula:** `dmg = power × region_mult − toughness` (head 1.5 / eyes 1.2 / ribs 1.0 / hands 0.8); ×1.25 after round 4.
- **Per-round manager levers:** 3 cutman charges, 1 tactic call.
- **Glory:** field FRACTURED −15 · towel −10 (crowd boos).
- **Gore colors (3 only):** `#5A1A1A`, `#C4342D`, `#E8DCC0`.
- **Ladder:** 0 CLEAN · 1 FLUSH · 2 MARKED · 3 SPLATTER · 4 CARNAGE ZONE · 5 THE TOLL.
- **Tuning knob:** `CARNAGE_BIAS` 0.8–1.2, ships at 1.0.
- **Prime directive:** legibility before frequency.

*End of document.*