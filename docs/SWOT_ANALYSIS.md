# BARE-KNUCKLE — SWOT-ANALYYSI (auditoitu)

**Perustuu:** 5 sub-agentin auditointiin (MECHANICS_33, VISUAL-FEASIBILITY,
GORE_SYSTEMS, ARCHITECTURE_AUDIT, balance plan) + MASTER_PLAN. Jokainen SWOT-
kohta on sidottu auditointilähteeseen ja — missä relevanttia — myöhempään
toimenpiteeseen (→ toiminta).

---

## S — STRENGTHS (vahvuudet)

| # | Vahvuus | Auditointitodiste |
|---|---------|-------------------|
| S1 | **Laaja resurssipuskuri** — suunnitelma mahtuu patruunaan helposti: ≈358/1024 spritetä (36 %), koodi ~55/64 KB, save ~240–400 sanaa/8192 (FREE) | ARCHITECTURE_AUDIT §1, VISUAL-AUDIT §2 |
| S2 | **Pro-yhteensopivuus läpinäkyvästi** — word-addressed save skaalautuu 32 KB → 256 KB pmem ilman redesignia; TIC-80 Pro antaa 8 bank/section (~512 KB koodia) | ARCHITECTURE_AUDIT §1 |
| S3 | **Interlock-spine — mekaniikat ruokkivat toisiaan** — kulmauskäskyt → haavat → kartelli → uhkailuillat → maine → palkkiot → lainat → ratsiat → legacy → NG+; ei eristettyjä featureita | MECHANICS_33 system table + interlock spine |
| S4 | **"Damage is the currency of glory AND cost"** — gore ei ole silmäkarkkia vaan taloudellinen päätös; verisimmät voitot maksavat +15% FOTN-palkkion mutta kasvattavat lääkärilaskut | GORE_SYSTEMS §4, balance plan §3 |
| S5 | **Vahinko on luettavissa ja pelaajan omaa valintaa** — 6-stage gore ladder, jokainen vaurio näkyy spritessä ≤2 s; complicity-testi ≥70 % | GORE_SYSTEMS §1–2, §6 |
| S6 | **Deterministinen sim + replay yhdestä RNG-siemenestä** — 1 sana per tallennettu ottelu = täysi replay; 2 000 headless-sim/portti ennen human playtestia | ARCHITECTURE_AUDIT §4, balance plan §5 |
| S7 | **Vahva identiteetti ja tone** — 1980s sports-pulp, "pizza-parlor CRT"-testi, Bruiser Bugle -sanomalehtisysteemi kirjoittaa legendan tai syytteet pelaajasta | GORE_SYSTEMS §5, MECHANICS_33 #31 |

## W — WEAKNESSES (heikkoudet)

| # | Heikkous | Auditointitodiste | → Toiminta |
|---|----------|-------------------|------------|
| W1 | **Deliberate squeeze on rankin riski** — F1–10 nettoaa −20/ottelu myös voittaessa; jos pelaaja ei oivalla pelin "pakottavan" gambling/crime-kiertoon, tunne on epäreilu, ei tiukka | balance plan §1 | Mercy-valve-event ahtauman loppuun; tutorial-hint F3 |
| W2 | **Per-fighter-injury-taide ei mahdu** — 32 fighteria × 4 vakavuutta × 4 spritetä = 512 spritetä = puoli peliä; VISUAL-AUDITOR hylkäsi suoraan | VISUAL-AUDIT §2 | Overlayt + pal()-swaps; bespoke-art vain ≤4 tähtifighterille (jo päätetty MASTER_PLAN §3) |
| W3 | **16 värin gore-luettavuus** — veri kankaalla vs. punainen UI-riski; jos paletti vuotaa, gore muuttuu kohinaksi | VISUAL-AUDIT §1, §5 checklist | Punainen KIELLETTY crowd/ring/UI:ssa; ΔL ≥ 25 % veri vs. canvas -check jokaisessa asset-droppissa |
| W4 | **Spreadsheet-fatigue-riski** — managerisim + 33 mekaniikkaa + ledger-taulut voi tuntua Exceliltä | balance plan §4 risk #3 | Decision density ≥2.0/min -portti; jokainen ruutu vastaa 3 napin sääntöön |
| W5 | **Code-ceiling M6:lla** — legacy-meta (7 mekaniikkaa) on kallein systeemi ja gate vaatii ≤57 KB; data-driven tablen on kannettava paino | ARCHITECTURE_AUDIT §6 | Flat-table arkkitehtuuri (10 arkkityyppiä × modifiierit) jo suunniteltu; auditoinni kussakin gateissa |
| W6 | **Alkuvaiheen "who am I" -sekavuus** — 33 mekaniikkaa on paljon näytettäväksi; hook on vain F1–3 | balance plan §3 arc | Ensimmäinen 10 min pitää sisältää ≥1 glory beat + ≥1 downfall beat + ≥1 swerve |

## O — OPPORTUNITIES (mahdollisuudet)

| # | Mahdollisuus | Perusta |
|---|--------------|---------|
| O1 | **TIC-80 Pro -julkaisu** — 256 KB pmem mahdollistaa laajemman Hall of Bruises -arkiston, useamman NG+-kerroksen ja isomman Bugle-arkiston ilman kompaktointia | ARCHITECTURE_AUDIT §1 |
| O2 | **Replay/kertomus-sisältö** — replay-from-seed + Bruiser Bugle + Hall of Bruises = valmis "highlight reel" -virta streamaukseen ja jakaminen | ARCHITECTURE_AUDIT §4, MECHANICS_33 #27, #31 |
| O3 | **NG+ = replayability kertaa 4** — neljä ending-modifiaattoria (GOLDEN GLOVE/KINGPIN/MARTYR/PAUPER) + save-file-kirous tekee jokaisesta uudelleenpeluusta erilaisen | MECHANICS_33 #32–33 |
| O4 | **Retro-gore-markkinaraottuma** — brutaali mutta tone-lockattu pixel fiction on harvinainen yhdistelmä; peli muistuttaa pulp-arcadea, ei realistista väkivaltaa | GORE_SYSTEMS §5 tone lock |
| O5 | **Data-driven modulaarisuus** — fighter/moves/injury/league-taulut mahdollistavat modit ja community-rosterit ilman koodimuutoksia | ARCHITECTURE_AUDIT §2 |
| O6 | **2 000-sim-portti = halpa tasapainotus** — headless-simulat paljastavat ekonomian ja ruin-rate-bugit ennen kuin yksi ihminen pelaa | balance plan §5 |

## T — THREATS (uhat)

| # | Uhka | Auditointitodiste | → Torjunta |
|---|------|-------------------|------------|
| T1 | **Gore-wallpaper** — jos Stage 3 -reaktio ei laske F15:ssä vs. F3:ssa, gore on liian usein eikä enää jännitä | balance plan §4 risk #1, GORE_SYSTEMS §6 check 4 | Gore eskaloituu FORMAATISSA (6 stagea), ei frekvenssissä; CARNAGE_BIAS=1.0 |
| T2 | **Satunnainen kuolema = kohtuuton rage-quit** — "random" death, jota ei voi jäljittää päätökseen, epäonnistaa auditoinnin | GORE_SYSTEMS §6 check 7 | Kuolema ≤5 % urista, 100 % päätösjäljitys (declined towel ×2); muuten bugi |
| T3 | **Gambling-dominated optimal play** — jos vedonlyönti on aina paras valinta, manageri-osio kuolee | balance plan §4 risk #6 | EV kääntyy negatiiviseksi >2 000 bankroll; self-bet cap 50 % |
| T4 | **TIC-80 scope collapse** — 33 mekaniikkaa + 6 milestonea on iso putki 64 KB:iin ja retro-konsolille | balance plan §4 risk #8 | ≤5 tasapainosolua per iteraatio; "jos fix ei mahdu BALANCE-sheettiin, se on design-muutos" |
| T5 | **Tallennuskorruptio** — 32 KB pmem, bit-packing, versiomigraatiot; yksi virhe tuhoaa koko uran | ARCHITECTURE_AUDIT risk register | Magic + version + end-marker; chained migrate(v); tallennus vain state-exiteissä |
| T6 | **Sisällöntuotannon tone-kriippi** — yksi liian realistinen asset riittää, ja pelin identiteetti murtuu | GORE_SYSTEMS §5, §6 check 8 | Pizza-parlor-testi jokaisessa asset-droppissa; real-person blocklist; AI-vs-AI cap Stage 2 |
| T7 | **RNG-frustration** — pelaaja syyttää noppaa, kun syy oli hänen oma | balance plan §4 risk #2 | Ruin-autopsia: ≥75 % player-caused; comeback arc 30–55 % urista |

---

## SWOT-MATRIX: strategiset aiheet

| | **Mahdollisuudet (O)** | **Uhat (T)** |
|---|------------------------|--------------|
| **Vahvuudet (S)** | **SO — hyökkäys:** Pro-pmem (S2+O1) + replay/taru-sisältö (S6+O2) + NG+ (S3+O3) → pitkäikäinen julkaisu, jonka runit ovat kertomuksia | **ST — puolustus:** determinismi + decision-tracing (S6) tappaa T2; luettava gore (S5) + tone lock (S7) tappaa T1 & T6 |
| **Heikkoudet (W)** | **WO — kehitys:** data-driven (O5) kiertää W5 code-ceilingin; 2 000-sim (O6) korjaa W1 squeezeen ennen julkaisua | **WT — kriisinhallinta:** palettidiscipline (W3) ja sprite-overlayt (W2) ovat M5-portin kovia gateja; scope collapse (T4) torjutaan tasaamalla VAIN BALANCE-sheetin kautta |

---

## Päätelmä

**Sisäinen asema: vahva** (S-paino > W-paino — suurimmat heikkoudet W2/W3 on jo
ratkaistu suunnitelmassa tehdyllä päätöksellä). **Ulkoinen asema: hallittu** —
jokainen uhka T1–T7 on sidottu mitattavaan auditointiporttiin, ei mielipiteeseen.

Kriittisin polku: **W1 (squeeze-tunne) ja T1 (gore-wallpaper)** — molemmat
vaativat playtest-telemetriaa, eivät design-oletusta. Siksi 2 000-sim-portti
on projektin tärkein yksittäinen työkalu ennen ensimmäistäkään ihmispelaajaa.