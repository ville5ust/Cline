# BARE-KNUCKLE — The 33 Mechanics
*Full mechanic bible for a brutal/gory bare-knuckle boxing manager on TIC-80.*

---

## INTRO

### The premise

You are not a boxer. You are the man behind the man. In the wet alleys of a
fog-bound industrial city you run a bare-knuckle stable: sign desperate kids,
patch their faces, take their corner on fight night, spend their purses, and
answer to anyone with money or a grudge. Nobody wears gloves. There is no
sanctioning body worth the name, no ambulance on retainer, and no bell that
saves anyone. Fights resolve tick-by-tick in front of you — you see every cut
open, every knuckle fold, every fighter who does not walk out of the ring.

The game runs on a single TIC-80 cartridge: 64 KB of Lua, 16 colors, 8,192
words of `pmem` as the entire persistent world, and a coroutine-driven fight
sim at 15 Hz. Everything in this document is designed to survive those limits
(see the companion `ARCHITECTURE_AUDIT.md` for the resource plan).

### Good-path vs bad-path fun philosophy

BARE-KNUCKLE has two deliberately opposed ways to be enjoyed, and **both must
pay**:

- **The good path — the honest cornerman.** Build a clean house: pay for real
  doctors, rest injured hands, refuse the dive money, keep the ledger clean,
  and carry a fighter to a genuine title with his face mostly intact. The
  reward is the *slow* fun: a roster you're proud of, a door that fills because
  the crowd trusts you, a GOLDEN GLOVE ending earned without a single envelope.
- **The bad path — the butcher.** Take the shylock's money, dope the laudanum,
  feed the crowd's blood appetite, sell the fix, and promote yourself on a
  conveyor of broken boys. The reward is the *fast* fun: bigger purses sooner,
  bigger cards, bigger notoriety — and a machine that visibly consumes
  everyone you sign, ending in KINGPIN (you won), MARTYR (you died of it), or
  PAUPER (it ate you).

Every mechanic below carries a **FUN AUDIT** line stating whether it pays on
the good path, the bad path, or both. A mechanic that only pays on one path is
a bug in design, not a feature: the bad path must be *tempting*, the good path
must be *dignified*, and both must be genuinely fun to play. The TIC-80 save
file (mechanic 33) is the philosophical anchor — the game remembers what kind
of person you were, and it tells you.

### TIC-80 context

- **Fight sim:** one Lua coroutine per fight, resumed from `TIC()` at a fixed
  15 Hz accumulator; the renderer draws every frame. Gore reads through shape,
  motion, and particles (2–3 blood particle tiers + decals), not palette.
- **Persistence:** 8,192 `pmem` words. The save is word-addressed, magic-
  tagged, and version-migrated; careers, wounds, debts, scars, and one cursed
  byte all live there.
- **Portraits:** sprites are scarce (256 slots/bank), so fighter faces are
  procedurally composited from parts — which is exactly what makes the
  PERMANENT SCAR GALLERY (6) cheap to implement and permanent to see.
- **Tone:** retro pixel fiction — no photoreal gore, just honest 16-color
  brutality: a red particle burst, a face that never heals clean, a newspaper
  that calls you the BUTCHER OF MARKET ROW in a 4×6 font.

---

# A. FIGHT-NIGHT CORNER (Mechanics 1–4)

## 1. SPLITS-BASED CORNER ORDERS

**Description.** At the end of every round you sit in the corner and issue
orders from a fixed menu of six: *JAB-AND-GO, HOOK-AND-HOPE, BODY-BREAK,
GUARD-DOWN, COVER-UP* and **BRAWL**. Every order costs the fighter stamina
to execute — even COVER-UP — because a corner order is adrenaline spent on
demand, not free advice. BRAWL is the order that breaks bodies: it doubles
the damage the fighter deals and doubles the damage he takes, for as long
as the round lasts. That split — one doubling, both directions — is the
whole art of the corner: you are never choosing whether to spend stamina,
only who pays for it, and every order is a bet about which fighter's face
the next round belongs to.

**TIC-80 primitive note.** Orders are a 3-bit enum per round stored in the
fight struct; stamina costs come from a 6-entry data table. The order menu
renders in the existing bottom HUD strip with `spr` icons and a `rect`
stamina bar; selection is pure D-pad + A, zero new UI code beyond a cursor.

**FUN AUDIT:** BOTH — good path: ordering COVER-UP to save a hurt kid for a
comeback round is quiet heroism; bad path: mashing BRAWL to force a bloody
highlight-reel finish while the crowd meter spikes — and your fighter's face
goes with it.

## 2. THE CUT-MAN'S TOWEL DILEMMA

**Description.** Once per fight, and only once, the cut-man can throw the
towel-wipe intervention: a full cleanup pass that resets the visible cut
state and buys the fighter back some of his vision and accuracy. The
referee **clocks it** — a mid-round towel is technically a delay, and he
logs it: first offense draws a warning and a **HEAT flag** on your
promotion record. A HEAT flag doesn't end anything immediately, but it
raises the referee's callousness on every future stoppage call and marks
you for the Bugle's fight reports. The dilemma is that the towel is worth
the most exactly when the referee is watching the closest — a fighter
going blind from a brow cut in round 3.

**TIC-80 primitive note.** One bit (available/used) plus one flag byte
(HEAT level 0–3) in career save; the referee-clocking is an event-bus
emission (`TOWEL_CLOCKED`) that both the newspaper renderer and referee AI
subscribe to. Cost: near-zero; the drama is free.

**FUN AUDIT:** BOTH — good path: holding the towel all fight and never
needing it is its own small triumph; bad path: spending it in round 3 to
sell a BRAWL round to the touts, eating the HEAT flag with your eyes open.

## 3. ROUND-BY-ROUND BLOOD METER

**Description.** Each fighter carries a 4-bit **blood meter** that climbs
with every cut, spray, and reopened wound, shown as a chunky red bar under
his portrait. At **8/8** the fight is at doctor-stoppage risk: at the round
bell there is a visible chance the doctor waves it off, and that chance
hardens with every tick past 8. The meter drains slightly between rounds
(clotting), but reopened cuts add to the *existing* value, so a face worked
on for six rounds doesn't reset — it compounds. The meter is public
information: the crowd can see it, the cornermen can see it, and your
ordering decisions (mechanic 1) should be able to see it too.

**TIC-80 primitive note.** One nibble per fighter packed into the existing
fighter state word; the bar is a `rect` fill at 2 pixels per point. The 8/8
threshold raises a `DOCTOR_LOOK` event the sim resolves at the bell.

**FUN AUDIT:** BOTH — good path: watching your man's meter creep to 7/8 and
refusing the coward's towel is a test of nerve; bad path: deliberately
cruising an opponent's meter to 8/8 so the doctor does your knockout for
you.

## 4. TALE OF THE TAPE RECON

**Description.** Before any fight you can pay a fixer for **recon** on the
opponent: stats, tendencies, a recent injury whisper, who he owes money to.
Recon is **70% reliable** — the other 30% is not merely missing
information, it is *plausible lies*: confident, specific, wrong. A report
that says "glass right hand, stale since March" may be exactly true, or may
be exactly what the other camp wants you to believe. Because the lies are
plausible, you cannot smell them; you can only cross-reference against the
wound-map rumor mill and your own scouting ledger. Buying recon on the same
opponent twice reduces the chance of a second contradiction but never
zeroes it.

**TIC-80 primitive note.** A per-opponent memo table with a 70/30 roll at
purchase time, seeded from the fight seed for determinism and replay; lies
are sampled from the real stat table with sign-flips, so they cost no extra
data and always *could* be true.

**FUN AUDIT:** BOTH — good path: paid recon confirming the wound map and
letting you order BODY-BREAK against a cracked rib; bad path: trusting a
bought lie about a soft chin, ordering HOOK-AND-HOPE, and walking your boy
into the truth.

---

# B. INJURY & GORE (Mechanics 5–9)

## 5. ANATOMY WOUND MAP

**Description.** Every fighter has a 9-cell body diagram — head, brow, eyes,
nose/mid-face, jaw, ribs, solar plexus, and both hands (glove-free; they
take punishment like everything else). Wounds are **localized and
persistent**: a cracked orbital in the brow cell stays in the brow cell,
degrades that cell's future damage resistance, and heals on a **real-heal
calendar** measured in calendar weeks, not fight count. You cannot fight
through a red-cell wound without consequences elsewhere (mechanics 3 and 12
exist specifically to tempt you into trying). The wound map is the game's
anatomy: where you get hit determines what you lose, what heals, and what
never does.

**TIC-80 primitive note.** 9 cells × (severity nibble + heal-weeks byte +
scar-flag bit) pack into about 2 words per fighter; the diagram renders as a
3×3 grid of `rect` cells colored by status — no sprites needed.

**FUN AUDIT:** BOTH — good path: resting a healed-in-weeks rib tear and
losing one card as the responsible thing to do; bad path: reading the map
as a menu of what is still sellable on a body you intend to cash out.

## 6. PERMANENT SCAR GALLERY

**Description.** Every wound that heals past a severity threshold leaves a
**permanent scar overlay** composited onto the fighter's portrait — a pale
line over the brow, a flattened nose, a long remembered stitch. The gallery
is a career made visible: open the roster and you can read who took what,
from whom, and roughly when. Scarred veterans **earn more** — the crowd
pays to see a face with history, and the gate bonus scales with total scar
count. The good path reads the gallery as a résumé; the bad path reads it
as an inventory.

**TIC-80 primitive note.** Portraits are already procedural composites of
part-sprites (per the architecture audit), so scars are 2–3 small overlay
sprites per face region keyed by wound cell — a handful of sprite slots,
permanent because they are written into the fighter's portrait config in
`pmem`.

**FUN AUDIT:** BOTH — good path: a roster wall of modestly scarred
professionals you kept whole enough to grow old; bad path: a stable that
looks like a war photograph and earns like one.

## 7. THE TORN-GLOVE RULE

**Description.** No gloves means bare-knuckle hands break. A fracture in
either hand cell puts the fighter out on a real-heal calendar stretch of
**3 to 9 months**, chosen by severity and that hand's wound history.
During recovery you face the **rest-hands decision**: full rest (the hand
heals cleanly) versus light duty (he keeps his timing training legs and
mind, but every spar risks re-fracturing the same hand and doubling the
remaining calendar). The torn-glove rule exists because bare knuckle
punishes the *weapon*, not just the target — your most valuable fighter is
also the most expensive thing to repair.

**TIC-80 primitive note.** Hand cells flagged `fracture` carry a heal-weeks
value of 12–36; a single rest/light-duty toggle bit gates which training
actions the sim permits. Zero new systems — it reuses mechanic 5 entirely.

**FUN AUDIT:** BOTH — good path: eating the 9 months and getting your
franchise fighter back whole; bad path: gambling light duty on a short
title run and rolling the re-fracture you knew was in there.

## 8. THE BONE-CRACK REPLAY

**Description.** When a fight ends on a knockdown, a cut stoppage, or a
visible break, the sim rolls the last moments back into a slow-motion,
freeze-framed **replay**: the finishing exchange re-ticked with a damage
overlay showing exactly which wound-map cell took the blow, at what force,
with what blood-meter consequence. Sound drops to a single heartbeat SFX
and a bone-crack variant where applicable; the crowd noise returns only
when you press on to the card. The replay is the game's thesis statement in
gore: it teaches anatomy (mechanic 5), it sells drama, and it makes every
ending feel *authored* even when the sim produced it.

**TIC-80 primitive note.** The fight sim is deterministic and seed-stored,
so the replay is a coroutine rewind of the last ~120 ticks at 3× tick
scale — no recorded data needed. Screen shake rides a `BDR` line offset;
the palette flash is a temporary color-entry remap. Fits inside the
existing fight bank.

**FUN AUDIT:** BOTH — good path: the replay of a clean, legal, beautiful
one-punch finish you built a whole camp around; bad path: the replay of a
BRAWL-order mauling that ended a career, which you will watch anyway, and
the Bugle will describe.

## 9. THE CANVAS FEEDS

**Description.** Blood, sweat, and worse **stay on the canvas** between
fights: the ring accumulates persistent decals fight after fight, and a
crowd walking into a stained house reads it instantly. Scrubbing the canvas
costs money per cleaning, and skip enough of them and an
unsanitary-canvas flag rolls — fighters who bleed onto it through open face
wounds risk an **infection** condition that turns a healing wound into a
slow one that never quite closes. Grossly, the dirty canvas also *helps*:
the crowd meter gains a small ongoing bonus while the gore is fresh, so the
filth is a revenue decision like any other.

**TIC-80 primitive note.** The canvas is a dedicated low-res buffer (map RAM
or a sprite-bank page used as scratch): each fight writes decal splats at
three blood tones, cleaning fades the buffer toward the base color. One
infection roll per fight, driven by a `canvas_dirt` byte.

**FUN AUDIT:** BOTH — good path: paying the scrubbing bill every week as
the cost of decency; bad path: pocketing the cleaning money, taking the
crowd bonus, and rolling infections you will treat with mechanic 13's
cheapest sawbones.

---

# C. MONEY & VICE (Mechanics 10–14)

## 10. THE CHALK-LANE SHYLOCK

**Description.** When the ledger runs dry you can borrow from the Chalk
Lane shylock: instant cash, weekly **vig**, and a **debt level** from 0 to
5 that is the most honest number in the game. Debt 1–2 buys you time and
draws collectors to the gym door; **debt level 3 is the trigger the Bugle
has been waiting for** — the pre-written obituary mechanic (31) activates,
and the paper quietly starts writing about your promotion in the past
tense. Debt 4–5 brings mechanic 21's threat nights to your doorstep with
your name on the ledger instead of a fighter's. Loans are never free, and
the shylock never forgets a face — not even across save files; see
mechanic 33.

**TIC-80 primitive note.** Debt is one byte (0–5) plus a vig word debited
weekly by the calendar system; the obituary activation is a flag the Bugle
generator reads. Total cost: about 3 words of save space.

**FUN AUDIT:** BOTH — good path: one ugly loan at debt 2, repaid in full,
never spoken of again; bad path: riding debt 4 through three cards,
spending purses that were never yours, and meeting the collectors the
night your franchise fighter has a title defense.

## 11. THE LEDGER OF BLOOD MONEY

**Description.** Every fight generates a purse, and the ledger splits it:
**clean money** (gate share, contracted purse) and **unmarked notes** (bet
collections, side payments, money whose origin is a rumor). You may bet
your own stable's fights at the tout windows, hedge against your own man,
or take a quiet side-payment to guarantee a certain result — the ledger
records all of it with a `dirty` weight. Dirty money is faster and bigger;
the season-end counting-house visit (the accountant) converts dirty weight
into attention — mechanic 26's heat grows with the ratio, and mechanic
31's Bugle picks a tone from it. Clean money is slower, smaller, and never
mentioned in the obituary draft.

**TIC-80 primitive note.** Two purse words (clean/dirty) per career plus a
dirty-ratio nibble; the accountant audit is a single season-tick event
that adds to the heat byte mechanic 26 already uses.

**FUN AUDIT:** BOTH — good path: a stubbornly clean ledger that grows one
gate at a time; bad path: betting against your own journeyman to bankroll
your champion, and watching the ledger's dirty ratio become a character in
the newspaper's coverage.

## 12. THE LAUDANUM SCHEDULE

**Description.** The gym keeps a bottle — laudanum, ether rags, the cheap
miracle of the era. A **dose** before fight night lets a fighter compete
through yellow-and-red wound-map flags by suppressing the penalties, at
the cost of an **addiction ticker** (0–9) that climbs with every dose and
never fully drains. Addicted fighters drain stamina faster in every round,
train worse between fights, and carry a small overdose risk on the card
itself — the sim resolves it as a collapse during the walk-in or
mid-round, in front of everyone. The schedule is a moral dial you own: the
good path is a locked medicine box; the bad path is a stable that fights
through anything and pays for it on the bell.

**TIC-80 primitive note.** One ticker byte per fighter; dose effects are a
multiplier table on existing penalty lookups. The overdose roll reuses the
event-bus collapse pathway already built for knockdowns — no new
presentation code.

**FUN AUDIT:** BOTH — good path: holding the bottle back through a title
run while a hurt fighter loses anyway, honorably; bad path: dosing the
whole roster every card and discovering your best fighter's ticker crossed
7 at the worst possible moment.

## 13. THE SAWBONES RETAINER

**Description.** Healing is a purchase. The gym hires from a roster of
**sawbones at three quality tiers**: the per-stitch street cutter (fast,
cheap, leaves residues), the proper physician on monthly retainer (slow,
costly, clean heals), and the one expensive ex-naval surgeon who can even
treat infections from mechanic 9. Quality determines how the wound map
*resolves*: a tier-1 stitch on a brow cut may close the week but leave a
nerve-damage residue that permanently lowers that cell's resistance — a
mangled heal that shows up months later when a lighter blow reopens it
worse than before. You can switch doctors between fights, but a botched
heal is a botched heal.

**TIC-80 primitive note.** Doctor tier is one byte in career save; heal
resolution is a table lookup (tier × cell severity → heal-weeks + residue
chance). Residues reuse the wound-map cell structure — no new anatomy
data.

**FUN AUDIT:** BOTH — good path: the retainer bill paid every month
without complaint, and fighters whose brows healed like new; bad path:
running the whole roster through the street cutter to keep the vig paid,
and harvesting residues you will never be able to fix.

## 14. THE DOOR, THE BAR & THE TOKENS

**Description.** Fight-night revenue is a three-layer economy: **the door**
(gate receipts scaled by crowd size and district reputation), **the bar**
(beer and pie take that scales with how long the card runs and how long
the crowd stays), and **the tokens** (the touts and program sellers who
add a small margin but carry gossip). A blood-hungry crowd that stays late
drinks more; a clean technical card empties the house early. This mechanic
is the monetary bridge between the crowd systems (22–25) and the ledger
(11): every cheer you earn has a shilling attached, which is exactly why
the temptation to feed the meter is never merely aesthetic.

**TIC-80 primitive note.** Three derived words computed from existing
crowd/reputation state at fight end; a per-fight `card_length` tick drives
bar take. Zero new storage — pure arithmetic on data that already exists.

**FUN AUDIT:** BOTH — good path: modest, honest gates that grow as the
district learns your name for the right reasons; bad path: stacking cards
long and bloody on purpose because the bar's cut of a slaughterhouse night
pays the vig.

---

# D. ROSTER & HUMAN COST (Mechanics 15–19)

## 15. THE SPAR-RING LADDER

**Description.** The cheapest training in the game is also the most honest:
put your own fighters in the gym **spar-ring** and both men gain real stat
growth — the ladder ranks your roster by form and the sim runs short spars
between them. The catch is that sparring rolls **real wounds** on the
anatomy map (mechanic 5) at reduced severity, and a badly matched spar can
put a hand cell on the 3–9 month calendar (mechanic 7) six weeks before a
booked card. A risk slider (soft rounds / honest rounds / war) sets the
stat-gain-to-wound-die ratio, and 'war' is never labeled a mistake by the
UI — it just is what it is.

**TIC-80 primitive note.** Spars run the existing fight coroutine at
reduced tick counts with `spar` flags suppressing gore presentation but
not wound rolls. The risk slider is one byte; the ladder is a sort over
existing fighter records.

**FUN AUDIT:** BOTH — good path: honest rounds between your top two men,
and both improve for a title eliminator; bad path: running 'wars' every
week on two kids you signed for pocket change because wounds on cheap flesh
are an acceptable line item.

## 16. THE SECOND'S EYE

**Description.** Each fighter has a **second** — a cornerman with his own
loyalty meter, shaped by what he has witnessed. Seconds who watch too many
gore events, towel-drama embarrassments, or deaths walk out, and a fighter
left without his second fights with degraded corner orders (mechanic 1's
costs rise, because advice without trust does not land). Loyal, veteran
seconds **discount** corner-order stamina costs and add a small
clotting bonus to the blood meter between rounds. The second is the human
cost ledger's quiet line: the men around your fighters bleed too, just
slower.

**TIC-80 primitive note.** One loyalty byte per fighter-second pair;
discounts are a small multiplier table on existing order costs. Seconds
are data-only — a name, a face variant, a loyalty byte — so they cost
almost nothing in sprite RAM.

**FUN AUDIT:** BOTH — good path: a ten-year second who has seen everything
and still shows up; bad path: cycling through third-choice cornermen all
season because your corner stool has a body count.

## 17. THE PALLET DORM

**Description.** The roster lives in the gym's **pallet dorm**, and living
is a weekly line item: food spend sets whether fighters train on full
stomachs or hollow legs, and housing spend sets whether the injured sleep
in a bunk or on the floor beside the ring where they were hurt. Underfed
fighters slowly lose chin and stamina growth; floor-sleeping injured
fighters heal on a stretched calendar. The dorm is the dark mirror of the
ledger — every shilling you divert to the vig or the laudanum comes
visibly out of the bodies you are responsible for, and the Bugle hears
about it if a fighter collapses of hunger in public.

**TIC-80 primitive note.** Two weekly budget bytes; effects are simple
modifiers on existing heal-week and stat-growth rates. One Bugle hook on a
starvation event, reusing the event bus.

**FUN AUDIT:** BOTH — good path: a well-fed dorm that heals on schedule
and trains like it; bad path: starving the prospects to cover the shylock
while your champion eats first, and pretending not to notice.

## 18. THE PAUPER'S PLOT

**Description.** Fighters die in this game — in the ring, on the card, of
an infection, of an overdose — and when one does, you handle the burial.
Three **coffin tiers**: the pauper's plot (free, a mass grave, roster
morale craters and the Bugle's tone hardens), the plain box (a week's
gate), and the stone with a name (expensive, but the dorm sleeps easier
and the gym wall gains a memorial plaque). The **gym wall memorial**
persists: every fighter you have lost is a small engraved name on a
rendered wall panel, and prospects visiting it carry marginally worse
morale if the plaques outnumber the trophies. How you bury your dead is a
permanent public statement.

**TIC-80 primitive note.** The memorial is a small `pmem` list of names
drawn via `print` onto a static wall scene; coffin tier is one nibble per
dead fighter. Cheap, permanent, and it reads across NG+ (mechanic 32).

**FUN AUDIT:** BOTH — good path: paying for the stone with the name, and
the whole dorm standing at the fence; bad path: the pauper's plot ledger
filling while the crowd meter stays fat, and knowing exactly what the
obituary will say about you.

## 19. THE FARMHAND PIPELINE

**Description.** Talent enters through the **farmhand market**: ploughboys,
dock kids, and discharged soldiers signed cheap on short contracts with
untested chins. Farmhands are glass — their wound maps fill fast and their
real-heal calendars are brutal — but they are also the only way to build a
stable without money, and occasionally one is a diamond with a chin like a
hymn. The dark lever: contracts are **sellable** — you can flip a
developed farmhand up the ladder to a richer promotion for notes that are,
in ledger terms, unmarked. The pipeline is the game's heart-shaped trap:
everyone you sign is a person, and every one of them is also an asset.

**TIC-80 primitive note.** Farmhands are ordinary fighter records with a
`tier` byte and a short contract word; a sale is a ledger credit (mechanic
11) plus a roster delete. Nothing new to store — new *weights* on existing
data.

**FUN AUDIT:** BOTH — good path: raising a farmhand from the pallet dorm
to a title with his original nose; bad path: the assembly line — sign,
spar, bleed, sell — and the day a buyer's camp asks why the kid can't see
out of the left eye.

---

# E. CRIME & PRESSURE (Mechanics 20, 21, 26, 33)

## 20. THE FIRST ENVELOPE

**Description.** Sooner or later a quiet man sits in your office with an
**envelope**: a purse-sized payment to make sure your fighter does not win
— or, sometimes, that he does. Accepting the dive is the entry into the
E-group machine: the cartel's leash attaches (mechanics 21 and 26 now have
your name in their books), the money is unmarked (mechanic 11), and the
crowd, if the fix is sloppy, boos in a way the crowd meter records
(mechanic 22). Refusing is the fork: the envelope goes back across the
desk, the man nods politely, and your **threat clock** starts ticking —
nothing happens tonight, and that is the entire threat. The first envelope
is the single most consequential ten seconds in the game.

**TIC-80 primitive note.** One flag byte (pending/accepted/refused) plus
the threat-clock word used by 21; the offer is a scripted calendar event
with a two-button prompt. Trivial storage, enormous consequence — the
TIC-80 way.

**FUN AUDIT:** BOTH — good path: pushing the envelope back across the desk
and eating whatever comes; bad path: taking it, fixing the fight cleanly
enough that only you know, and feeling the leash click shut anyway.

## 21. THREAT NIGHTS

**Description.** When you owe the wrong people, certain fight nights become
**threat nights**: the cartel attends, drawn as a block of flat, dark
silhouettes in the crowd who never cheer. On threat nights the booked
result has an audience that matters more than the meter — fail an owed dive
and the punishment is physical (your fighter 'slips' in training, your gym
door grows a nail-studded message); succeed and the leash shortens (bigger
fixes requested, worse odds demanded). Threat nights are telegraphed in
the schedule with a small mark the player learns to dread, because the
dread is the mechanic: you fight the card knowing exactly who is sitting
in row three.

**TIC-80 primitive note.** Threat nights are a flag on the fight record;
the silhouettes are 2–3 sprite variants drawn over crowd rows (cheap,
because the crowd is already procedural). Punishment events ride the
existing wound-map and gym-state pathways.

**FUN AUDIT:** BOTH — good path: refusing dives forever and carding
through threat night after threat night, watching the silhouettes and
holding your nerve; bad path: becoming reliable, and discovering that
reliable men get asked for bigger things.

## 26. THE BLUE HOUR

**Description.** The constabulary takes an interest in your trade on its
own schedule: **raids** hit the gym or a fight card, confiscating the
ledger, arresting whoever is nearest, and closing the gym for a **closure
timer** (1–4 weeks of no training, no healing, no income). Raid frequency
scales with heat — HEAT flags from towel abuses (2), the accountant's
audit of your dirty money (11), and cartel visibility (21) — and decays
slowly if you keep your head down. The long game: a **payable sergeant**
who, for a monthly envelope, tips you one event in advance and quietly
zeroes small heat. Buying the sergeant is the bad path wearing a police
uniform; the good path is eating raids and rebuilding. The blue hour
always comes — you only choose whether it arrives announced.

**TIC-80 primitive note.** Heat byte + sergeant flag + closure-timer byte;
raid events are calendar ticks that freeze training and heal progression
(the wound map's real-heal calendar conveniently keeps counting, which is
the cruel part). Fits in under five words of save.

**FUN AUDIT:** BOTH — good path: surviving raids with a clean ledger and
losing nothing that matters; bad path: the sergeant's monthly envelope,
the quiet weeks, and the day his protection fails exactly when the
obituary mechanic is listening.

## 33. THE SAVE-FILE CURSE

**Description.** Somewhere in the 8,192 words of `pmem` there is one
persistent byte that remembers **your worst act** — the dive you took, the
fighter you dosed, the funeral you did not pay for: whichever single deed
the game weighed as heaviest in your previous run. In **any future save**,
at a calendared moment, one event calls it back: a stranger arrives who
saw it, a Bugle reprint surfaces, a new prospect's uncle was the man you
buried cheap. It is not punishment-by-random; it is memory — the one
mechanic in the game that crosses the boundary between your runs and
refuses to reset. You live with it the way the city does.

**TIC-80 primitive note.** One reserved `pmem` word outside the normal
save layout (magic-tagged like the save header, so migrations never touch
it): a category nibble + severity nibble + NG+-generation counter. The
callback event is a fixed table lookup on the category. Costs three words
of your 8,192. Worth it.

**FUN AUDIT:** BOTH — good path: a byte that holds a zero because you
gave it nothing to remember (and the game lets you feel the difference);
bad path: starting fresh with a new roster and having the past walk
through the door on week nine anyway.

---

# F. CROWD & CULTURE (Mechanics 22–25)

## 22. THE BLOOD APPETITE

**Description.** The crowd carries a live **meter** that fills on gore
(sprays, knockdowns, reopened cuts) and drains during long tactical
rounds — a pretty jab-and-move win can literally *bore* a house that came
to see blood. The meter gates future attendance and the door take
(mechanic 14): a house habitually denied its appetite thins, while a fed
one grows and brings friends. It also feeds district reputation, which is
the same number the crime group watches. The appetite is never labeled
evil — it is just weather, and you are the man who decides what to farm
in it.

**TIC-80 primitive note.** One byte per district, updated by event-bus gore
events that already exist for the particle system; the bar renders beside
the crowd sprites. The feedback loop costs essentially nothing.

**FUN AUDIT:** BOTH — good path: gradually teaching your district's crowd
to appreciate technical craft instead of slaughter — the meter's slow
migration upward on honest violence; bad path: ordering BRAWL rounds to
feed the meter, and the meter learning you.

## 23. THE CHANT REGISTER

**Description.** Fans adopt **chants** for fighters they love — a chant is
a short procedurally assembled tag that persists per fighter and grows
with his crowd history. A fighter with a strong chant enters the ring
with a mental-stat bonus and draws extra door take, and chants are earned
by *moments*: first blood survived, a comeback round, a finish inside the
distance. Chants decay if a fighter fades — or dies mid-chant, which is
its own quiet tragedy the Bugle will note. The register is the culture
layer of the crowd: affection, recorded and audible.

**TIC-80 primitive note.** Chants are a small string table per fighter (a
byte index into a phoneme/word bank assembled at generation); the mental
bonus is a flat modifier. Two words of save per fighter at most.

**FUN AUDIT:** BOTH — good path: hearing a chant you helped build ring out
on a title night; bad path: a chant echoing over a ten-count, and next
week's paper printing it in the obituary.

## 24. THE RAIN CARD

**Description.** Outdoor fight nights roll **weather**, and rain changes
everything: the canvas turns to mud, knockdowns come from slips as often
as punches, cuts gurgle spectacularly and the blood appetite eats it up —
but mud injuries are worse (sprains, reopened wounds on the anatomy map)
and the sawbones bills follow. A rain card is a gamble you can decline:
postponing costs a small fee and crowd goodwill, while running it can be
the most memorable gate of the season or a hospital run. Old-timers in
the crowd love a mud fight; accountants do not.

**TIC-80 primitive note.** Weather is one nibble on the fight record; mud
modifies existing friction/fracture tables and adds a decal tint to the
canvas buffer (mechanic 9). Rain itself is a `BDR`-offset line effect —
three lines of code, maximum atmosphere.

**FUN AUDIT:** BOTH — good path: a legendary mud card your chant-leading
veteran wins on heart, injuries and all; bad path: the rain card that
broke two hands and an ankle, and the three heal-calendars it started.

## 25. THE HECKLER'S GALLERY

**Description.** Every house has **hecklers** — named regulars who needle
a specific fighter mid-fight, applying a small but real mental-stat drain
on every exchange they needle him through. You can pay to ban a heckler
(a fee, and a small crowd-meter grumble), let him run (a minor gate
bonus, and the mental risk), or — the ugly option — pay him off *behind
the stalls* to turn his wit on the opponent, which works, and which is
exactly the kind of thing the save-file curse (33) is thinking about.
Hecklers give fight nights voices and personalities, and they make the
mental stat something you manage from outside the ropes.

**TIC-80 primitive note.** Hecklers are 3–4 named records (name string
index + target + state byte); the drain is a modifier on the existing
mental check. Their dialogue is `print`-drawn ticker text at the arena's
bottom edge, scrolling on a timer.

**FUN AUDIT:** BOTH — good path: a loyal house whose favorite heckler has
needled your man for years and made him deaf to it; bad path: the
backstage payoff, the sabotage that worked, and the word for it that the
city uses later.

---

# G. LEGACY & SUCCESSION (Mechanics 27–32)

## 27. THE HALL OF BRUISES

**Description.** The gym keeps a **Hall of Bruises**: a persistent hall of
fame recording every fighter who held a belt, died famous, or simply
lasted long enough to matter — scarred portrait, chant, career ledger
line, and epitaph. It is written to `pmem` *outside* the run's save
scope, so it survives NG+ and even a fresh career: you start a new stable
in a city that already remembers the last one. Retired champions give
your new prospects a small training aura; the dead give the dorm their
gravity. The hall is where all the other systems' outputs get archived
into one place you can stand in and look at.

**TIC-80 primitive note.** A fixed-size `pmem` ring buffer of hall entries
(portrait config words + name + epitaph string indices), capped so that
migration is trivial; rendered as a scrollable wall in the gym scene. The
cap is the cruel part: the hall has room for maybe twenty faces, and old
ones fall off.

**FUN AUDIT:** BOTH — good path: a hall of professionals who retired whole
and live on as training auras for the next generation; bad path: a hall
of martyrs your new farmhands train beneath, plaques outnumbering belts.

## 28. THE PROMOTER'S HANDSHAKE

**Description.** When your reputation earns it, a bigger **promoter**
offers the handshake: promotion to a new league tier and district —
bigger purses, harder opposition, better doctors *available*, and
proportionally more attention from every E-group eye. The handshake is
the career's lever and its bridge into legacy: title defenses at the top
tier are what write you into the Bugle's history and the Hall of
Bruises, and the top tier is also where the cartel's asks get bigger and
the constabulary's raids more calendared. Refusing promotion is legal
and costs you relevance; taking it costs you anonymity. There is no
tier at which nothing is watching.

**TIC-80 primitive note.** League tier is one byte scaling existing
purse, heat, and AI difficulty tables; the offer is a calendar event
with a threshold check on district reputation. All multipliers, no new
data.

**FUN AUDIT:** BOTH — good path: the handshake earned clean and a
top-tier run where the money is real and nobody owns your corner; bad
path: taking the handshake at debt 4, discovering the top tier's vig,
and learning that bigger stages have better-lit gallows.

## 29. THE HEIR SYSTEM

**Description.** As a career matures you may designate an **heir** — a
chosen successor who inherits a portion of your dead or retired
fighters' stats, training knowledge, and ledger wisdom when your run
hands off. The heir must be picked while you live: a **heir death in the
ring loses the legacy bonus permanently** — inheritance is a one-time
pass through a generation, and the ring is exactly where one-time passes
end. Heirs make long-horizon decisions meaningful: the farmhand you
raised carefully in mechanic 19 is not just a fighter, he is the vessel
your career's competence will pour into. Choose the boy. Keep the boy
breathing.

**TIC-80 primitive note.** Heir flag + source-fighter indices packed into
a few words; the inheritance is a stat-transfer function run once at
generation handoff. NG+ reads it at cart start (mechanic 32).

**FUN AUDIT:** BOTH — good path: grooming a worthy heir for twenty
in-game years and watching him carry your school forward; bad path:
designating the heir and then letting the boy chase one payday too many
— and the bonus, and the boy, gone in one round.

## 30. AGE CURVES & THE LAST FIGHT

**Description.** Fighters age on real-heal calendar time and their stat
**curves bend**: peak years are **years 3–7** of a career, after which
chin and recovery decay while scar count and guile creep up. Late-career
fighters can take **THE GRAND FAREWELL** — a farewell card with
elevated injury risk, announced in advance, that pays like a title
fight and can end in the ring as easily as in glory. Age is the game's
honest clock: every decision about rest, laudanum, and rest-hands (7)
is ultimately a decision about how many years you are spending of whose
life.

**TIC-80 primitive note.** Age is a byte plus per-stat curve coefficients
in a shared table; the Grand Farewell is a flagged card type adding an
injury-risk multiplier and a Bugle feature. Reuses everything —
calendar, wound map, gore events.

**FUN AUDIT:** BOTH — good path: the Grand Farewell won on guile in year
nine, retirement into the Hall of Bruises, a face like a map you can
read; bad path: a farewell card booked to pay the vig, and the ten-count
under the lights with the whole district chanting.

## 31. NEWSPAPER LEGACY: THE BRUISER BUGLE

**Description.** The city reads a **procedural weekly paper, THE BRUISER
BUGLE**, generated from the event bus: fight reports, chant quotes,
wound news, funeral notices, and a running editorial **tone** about you
that shifts with your ledger — from "the honest house on Basket Street"
toward, at the far end of the dirty ratio, **THE BUTCHER OF MARKET
ROW**. At **debt level 3** (mechanic 10) the Bugle pre-writes your
**obituary** — a full dead-promotion obituary held in reserve, updated
weekly, waiting for the week it becomes true. The paper is the game's
memory made public and legible: it tells you what the city has decided
you are, and it is always binding.

**TIC-80 primitive note.** Headlines assemble from a template grammar fed
by event-bus tags (the same events the particle system already emits);
tone is a byte riding the dirty ratio and heat. Text renders via
`print` in the existing newspaper scene. A full paper costs almost
nothing in code — the events are the content.

**FUN AUDIT:** BOTH — good path: fifty honest weeks of the Bugle calling
your house fair, and the obituary file staying empty; bad path: reading
your own pre-written obituary on screen because you wanted to see it,
and it getting one line more accurate every week.

## 32. ENDING GRADES: THE FOUR DEATHS

**Description.** Every run ends in one of four graded endings. **THE
GOLDEN GLOVE**: a title won clean — ledger mostly whole, hall worthy,
the city calling you something decent. **THE KINGPIN**: you reached the
top of the trade dirty and survived it — the richest man at the
funeral. **THE MARTYR**: the trade killed *you* — the obituary became
true about the right person. **THE PAUPER**: it ate you — debt, raids,
and a pauper's plot with your name mis-spelled. Endings are computed
from the run's totals (ledger ratio, heat, deaths, scar galleries,
Bugle tone) and each ending carries an **NG+ modifier** for the next
run: GOLDEN GLOVE heirs start with an heir-system bonus, KINGPIN starts
richer but with heat pre-seeded, MARTYR starts with the Hall heavier
and morale gloomy, PAUPER starts in debt. You never escape the
arithmetic; you only choose which sums you would rather be.

**TIC-80 primitive note.** Ending grade is a weighted sum over existing
bytes (no new data), written into `pmem` alongside the NG+ modifier word
read at cart start. The four ending screens are static scenes with
procedural text from the Bugle grammar.

**FUN AUDIT:** BOTH — good path: the GOLDEN GLOVE earned and the NG+
that gives your heir a real head start; bad path: the KINGPIN file you
keep reloading because being rich and dreadful is *fun* — and the
modifiers that make the next run pay for it from the first week.

---

## SYSTEM TABLE

| Group | Mechanics | Theme | Primary interlocks |
|---|---|---|---|
| **A. Fight-Night Corner** | 1–4 | Corner orders, the towel, the blood meter, opponent recon | Feeds B (wounds), F (crowd meter), C (bets) |
| **B. Injury & Gore** | 5–9 | Wound map, scars, torn gloves, replays, the canvas | Fed by A; feeds C (doctors, laudanum), D (human cost) |
| **C. Money & Vice** | 10–14 | Shylock, blood money, laudanum, sawbones, gate economy | Feeds E (debt→obituary, dirty→heat); drains B's healing |
| **D. Roster & Human Cost** | 15–19 | Spar-ring, seconds, the dorm, burials, farmhands | Feeds G (heirs, hall); fed by B and C |
| **E. Crime & Pressure** | 20, 21, 26, 33 | The envelope, threat nights, the blue hour, the save-file curse | Fed by C (debt, dirty ratio); pressures B and D |
| **F. Crowd & Culture** | 22–25 | Blood appetite, chants, rain cards, hecklers | Feeds C (door/bar take); feeds E (reputation = attention) |
| **G. Legacy & Succession** | 27, 28, 29, 30, 31, 32 | Hall of Bruises, promotion, heirs, age, the Bugle, the four deaths | Consumes every group's outputs; writes NG+ |

---

## THE INTERLOCK SPINE

Everything above hangs on one spine, and it is worth saying in one breath:
**corner orders generate wounds** — every BRAWL round and unprotected
exchange writes to the anatomy map — and wounds demand the **gypsy circuit**
of sawbones, laudanum, and rest decisions; paying for the circuit without
money means the **cartel** (the shylock first, then the envelope, then
threat nights), and the cartel's attention plus your dirty ledger schedule
**threat nights** and **raids** that raise your **district reputation** for
the wrong reasons, which inflates **purses** that tempt bigger **loans**, and
bigger loans invite the **raids** again — while the crowd's blood appetite,
the Bugle's tone, and the **Hall of Bruises** remember *why* every purse was
earned, and **NG+ makes you live with it**: the heir inherits what you
built, the cursed byte recalls your worst act, and the Bugle, which never
misses a week, is already setting type.

The whole game is that sentence, played one fight night at a time.

---

*33 mechanics. One cartridge. Two ways to be damned, and one way to be
proud. — end of document.*
