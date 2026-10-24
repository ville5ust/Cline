# KARHURYHMÄ — moottorin suunnittelu ja matematiikka

Tämä dokumentti kuvaa, mitä 3D-moottori oikeasti tekee. Kaikki renderöinti on
ohjelmistopohjaista Luaa TIC-80:n 240×136 -näytölle (4 bittia/pikseli, 16 väriä).

## 1. Maailma

* Kartta on 32×32 ruudukko, solu = 1 maailmayksikkö.
* Solu sisältää: seinämateriaalin (0 = lattia, 1–4 seinä, 5 = liukuovi),
  lattiatekstuurin (1 = betoni, 2 = parketti, 99 = poistumisalue) ja ovitilan
  (aukko 0…1).
* Korkeus: yksi kerros, kamera 0.5 yksikön korkeudella (klassinen raycast-rajoitus).

## 2. Seinät: DDA-ruudukkotraversaali

Jokaiselle näyttösarakkeelle (120 kpl, 2 px leveä) lasketaan säde:

```
camX = 2*col/120 - 1
ray  = dir + plane * camX
```

Säde etenee ruudukossa Amanatides–Woo -tyyppisellä DDA:lla: askellaan aina siihen
suuntaan, jonka seuraava ruuturaja on lähempänä.

```
ddx = |1/ray.x|  (∞ jos ray.x = 0)
stepX = sign(ray.x)
sdx = (mapX + 1 - px) * ddx   tai   (px - mapX) * ddx
```

Törmäyksen jälkeen kohtisuora etäisyys (perspektiivi vaatii tämän, jotta seinät
eivät kaareudu kalansilmäisesti):

```
perp = (side==0) ? (mapX - px + (1-stepX)/2) / ray.x
                 : (mapY - py + (1-stepY)/2) / ray.y
```

Seinän korkeus ruudulla `h = 136 / perp`, pystykeskipiste horisontissa (68 px,
liikkeen bob ±1.5 px). Tekstuurin pystykoordinaatti etenee `texPos += 32/h`
per pikseli.

**Liukuovet**: kun säde osuu oviruutuun, lasketaan osumakohta puoli ruutua
syvemmältä. Jos tekstuurikoordinaatti `wallX > aukko`, ovi on tiellä ja piirretään
siirtyneenä (`wallX - aukko`); muuten säde jatkaa matkaa — syntyy aidosti liukuva ovi.

## 3. Lattia ja katto: perspektiivikorjattu projektio

Vaakasuoralle pinnalle:

```
rowDist = 68 / |y - horisontti|
```

Rivin vasen/oikea sädevektori interpoloidaan ja näytettä kohti edetään
`step = rowDist * (ray1 - ray0) / 120`. Jokainen näyte kirjoitetaan 2×2 pikselin
blokkina (`poke4`), joten lattian hinta on ~2000 näytettä/ruutu.

## 4. Valaistus 16 värillä

Välimuisti `LAPA[c] = {tumma, perus, vaalea}` antaa jokaiselle palettivärille
kolme kirkkausporrasta. Valaistustaso:

```
L = 3.3 * exp(-d * 0.10)        (Beer–Lambert-tyylinen vaimeneminen)
    * (side==1 ? 0.66 : 1)      (Y-suuntaiset seinät tummempia → kulmat erottuvat)
    + muzzleFlash * exp(-d*0.2) (suuliekki valaisee lähietäisyyden)
```

Järjestysditherointi pehmentää portaituksen: 4×4 Bayer-matriisin kynnysarvoa
verrataan L:n murto-osaan ja valitaan kirkkaampi porras kynnyksen ylittyessä.
Tulos: 16 värillä saadaan liukuvia valaistusgradientteja ilman lisävärejä.

## 5. Spritet ja z-puskuri

Seinäsarakkeet tallentavat kohtisuoran etäisyyden `zbuf[1..120]`. Spriteille
tehdään kameramuunnos käänteisdeterminantilla:

```
invDet = 1 / (planeX*dirY - dirX*planeY)
tx = invDet * (dirY*relX - dirX*relY)
tz = invDet * (-planeY*relX + planeX*relY)
```

Näyttösarake `sx = 60*(1 + tx/tz)`, korkeus `h = 136/tz * spriteKorkeus`.
Jokainen sarake piirretään vain jos `zbuf[col] > tz` — sprite menee oikein seinän
taakse. Hahmoille piirretään lisäksi tumma jalkavarjo maadoittamaan ne.

## 6. Tekoäly

* **Näköyhteys**: DDA-viiva kahden pisteen välillä; seinä tai suljettu ovi katkaisee.
* **Vihollinen**: tila 0 = partio (satunnainen kääntyminen), 1 = tutki (A* viimeksi
  kuultuun/nähtyyn pisteeseen), 2 = taistelu (tähtää, ampuma-aika, sivuttaisliike).
  Reaktioaika 0.45 s näköyhteyden synnyttyä; laukaukset kuuluvat 9 ruudun säteellä.
* **Omat**: seuraavat suunnitelman reittipisteitä A*:lla, avaavat ovet automaattisesti,
  pysähtyvät tulittamaan näkyvää kohdetta ja jatkavat sitten matkaa.
* **Reitinhaku**: A* 32×32-ruudukossa, ovet läpäistäviä (aukko > 0.65).

## 7. Osumat ja taistelu

Hitscan: säde + satunnaispoikkeama (kasvaa recoilista), DDA tuottaa seinäetäisyyden,
sen jälkeen projisoidaan jokainen vihollinen säteelle:

```
t   = rel · dir            (etäisyys säteen suunnassa)
lat = |rel × dir|          (sivuttaispoikkeama)
osuma jos 0.3 < t < seinäetäisyys ja lat < 0.32
```

## 8. Proseduraalinen generointi

1. Arvotaan 5–8 päällekkäisyydetöntä suorakaidehuonetta (3–7 ruutua).
2. Huoneet yhdistetään L-muotoisilla käytävillä järjestyksessä.
3. Käytäväsoluista, joilla on täsmälleen kaksi vastakkaista lattianaapuria,
   muodostetaan ovia 50 % todennäköisyydellä.
4. Spawnit ensimmäiseen huoneeseen, poistuminen viimeiseen, viholliset välihuoneisiin,
   panttivanki/pommit tavoitteen mukaan.
5. Kytkeytyvyys varmistetaan flood-fillillä; epäonnistuessa uusi siemen (max 20 yritystä).

Käsityönä suunnitellut kentät validoidaan Python-generaattorilla
(`tools/genmaps.py`): rivien pituudet, ovien naapuruudet ja kaikkien kohteiden
saavutettavuus tarkistetaan ennen kuin data upotetaan Lua-taulukkoon.

## 9. Arkkitehtuuri (tiedostot)

| Tiedosto | Sisalto |
|---|---|
| `src/00_boot.lua` | vakiot, paletti, kirkkaus-LUT, Bayer, RNG |
| `src/01_tex.lua` | tekstuurien generointi (tiili, betoni, metalli, puu, ovi, lattiat, katto) |
| `src/02_spr.lua` | sprite-generaattori merkkigrafiikasta (viholliset, omat, vanki, pommi) |
| `src/03_map.lua` | kartan perusoperaatiot, LOS, A* |
| `src/03b_missions.lua` | 5 validoitua tehtavakarttaa (generoitu) |
| `src/03c_maprt.lua` | kartan rakennus, ovet, proseduraaligeneraattori, pmem |
| `src/04_game.lua` | pelitila, taistelu, AI, tavoitteet |
| `src/05_render.lua` | raycast-renderoija, spritet, efektit, ase |
| `src/06_hud.lua` | HUD, minimap, taktinen kartta |
| `src/07_plan.lua` | suunnitteluruutu |
| `src/08_action.lua` | toimintavaiheen syotto ja paivitys |
| `src/09_editor.lua` | kenttaeditori |
| `src/10_menu.lua` | otsikko, tehtavalista, briefing, debrief |
| `src/11_main.lua` | BOOT/TIC/MENU, aani |

Rakennus: `build.sh` poistaa kommentit ja kutistaa sisennyksen (lahdekoodi pysyy
luettavana), `tools/mkcart.py` kirjoittaa .tic-chunkit (CODE, PALETTE, WAVEFORM,
SAMPLES) TIC-80:n binaarimuotoon.

## 10. Testiputki

* `test/autoquit.lua` kaari pelin TIC()-kutsun: ajaa skenaarion joka ruudulla ja
  kutsuu `exit()` lopussa -> testit ajetaan oikeassa TIC-80:ssa, ei mockissa.
* `SCR(label)` lukee nayttomuistin (`peek4`) ja tulostaa sen hexina lokiin;
  `tools/decode_scr.py` muuntaa sen PNG:ksi -> visuaalinen regressiotestaus.
* Skenaariot: `scen_smoke`, `scen_full` (mekaniikat), `scen_sys` (AI/pommit/pmem/
editori), `scen_shots` (kaikki ruudut), `scen_diag` (lahikuvat).
