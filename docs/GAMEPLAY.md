# KARHURYHMÄ — peliopas

## Perusidea

KARHURYHMÄ on taktinen rynnäkköpeli. Tehtävä ei ole räiskintä vaan **suunniteltu
operaatio**: kaksi kahden hengen ryhmää (SUSI ja KARHU), blueprint-kartta, reittipisteet
ja go-koodit. Kuolema on pysyvä — mutta suunnitelma säilyy ja uusi yritys alkaa samalla
suunnitelmalla.

## Pelin kulku

1. **Otsikko** → TEHTÄVÄT / HARJOITUS / EDITORI / OHJEET
2. **Briefing** — kohde, tavoite, tiedustelutiedot
3. **Suunnittelu** — blueprint, reitit ja go-koodit
4. **Toiminta** — 3D-rynnäkkö
5. **Debrief** — tilastot, R = uusi yritys samalla suunnitelmalla

## Suunnittelu

* **Hiiri** = lisää reittipiste valittuna olevalle ryhmälle (vain lattialle)
* **Oikea klikkaus** = poista viimeisin piste
* **Q** = vaihda ryhmä (SUSI = keltainen, KARHU = sininen)
* **1 / 2 / 3** = aseta go-koodi A/B/C kursorin alla olevalle (tai viimeiselle) pisteelle
* **SHIFT + klikkaus** = siirrä ryhmän alkupaikka
* **ENTER** = hyökkäys

Ryhmä etenee pisteeltä seuraavalle ja **pysähtyy pisteelle, jolla on go-koodi**, kunnes
laukaiset sen toiminnan aikana. Klassinen taktiikka: SUSI sisään ovesta (A), KARHU
vastakkaisesta ovesta (B), molemmat yhtä aikaa (C = "kaikki").

## Toiminta

| Näppäin | Toiminto |
|---|---|
| Nuolet / WASD | liike |
| Z / hiiri vasen | tulita (recoil kasvaa, älä pidä pohjassa pitkään) |
| E | avaa/sulje ovi, vapauta panttivanki, pura pommi (pidä pohjassa n. 2 s) |
| F | valokranaatti (sokaisee viholliset 4,5 s) |
| R | lataa |
| TAB | vaihda jäsentä (ohjaat aina yhtä, muut jatkavat suunnitelmaa) |
| 1/2/3 | laukaise go-koodi |
| M (pohjassa) | taktinen kartta |
| ESC | tauko |

**Vinkit**
* Kuuntele: laukaukset houkuttelevat vihollisia. Ammu vasta kun näet kohteen.
* Valokranaatti on tehokkain juuri ennen ovesta menemistä.
* Jos jäsen kuolee, ohjaus siirtyy automaattisesti seuraavalle elossa olevalle.
* Tavoitteiden valmistuttua HUD ohjaa poistumisalueelle (vihreä X lattialla).

## Tehtävät

| # | Tehtävä | Kohde | Tavoite |
|---|---|---|---|
| 1 | OP.KAAMOS | Helsingin pankkikeskus | Neutraloi kaikki |
| 2 | OP.REVONTULI | Suurlähetystö | Vapauta panttivanki |
| 3 | OP.JÄÄKARHU | Lentotukikohta sektori 7 | Pura 2 pommia |
| 4 | OP.SUSITÄHD | Sataman varastoalue | Vapauta + tyhjenä |
| 5 | OP.UKKONEN | Yksityisklinikka | Pura pommit + tyhjenä |
| — | OP.TOISTO | Proseduraalinen | Satunnainen tavoite |

## Editori

* **Siveltimet:** 1 tiili, 2 betoni, 3 metalli, 4 puu, 5 lattia (vaihtaa
  betoni/parketti), 6 ovi
* **Työkalut:** E vihollinen, H panttivanki, B pommi, X poistuminen, I spawn 1,
  J spawn 2
* **Hiiri:** vasen = maalaa/asetta, oikea = kumita
* **Komennot:** G = generoi proseduraalinen kenttä, N = tyhjennä, O = vaihda tavoite,
  S = tallenna pmem-muistiin, L = lataa, T = testaa (siirtyy suunnitteluun)
* Ennen testiä editori validoi: ovatko spawnit ja poistuminen lattialla, ovatko kaikki
  kohteet saavutettavissa, ja onko tavoitteen vaatimia kohteita olemassa.

## Tunnetut rajoitukset

* Ei kaltevia pintoja tai kerroksia (raycast-moottori).
* Viholliset eivät käytä ovia taktisesti hyväkseen kuten oikea Rainbow Six -AI.
* Panttivanki ei seuraa pelaajaa; vapautus riittää tavoitteeseen.
* Editorin tallennus on TIC-80:n pmem-muistissa (säilyy koneella, ei kortissa).
