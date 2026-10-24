#!/usr/bin/env python3
"""Karhuryhma - tehtavakarttageneraattori (tools/genmaps.py)
Generoi kasisuunnitellut kartat ja varmistaa koneellisesti:
 rivileveys, merkit, ovien naapuruudet, kytkeytyvyys, entiteetit lattiassa.
Tuloste: src/03b_missions.lua"""
W=30
FLOORS='.,'
WALLS='=MW#'

def blank(ch='='):
    return [[ch]*W for _ in range(W)]

def carve(g,x,y,w,h,ch):
    for yy in range(y,y+h):
        for xx in range(x,x+w):
            assert 1<=xx<=W and 1<=yy<=W,f"alue ulos: {xx},{yy}"
            g[yy-1][xx-1]=ch

def walls(g,x,y,w,h,mat):
    for yy in range(y-1,y+h+1):
        for xx in range(x-1,x+w+1):
            inside=x<=xx<=x+w-1 and y<=yy<=y+h-1
            edge=xx==x-1 or xx==x+w or yy==y-1 or yy==y+h
            if not inside and edge and 1<=xx<=W and 1<=yy<=W:
                if g[yy-1][xx-1] in WALLS:
                    g[yy-1][xx-1]=mat

def check_ents(num,g,enemies,hostages,bombs,exits,sp1,sp2):
    for lbl,pts in (("vihollinen",enemies),("panttivanki",hostages),
                    ("pommi",bombs),("poistuminen",exits)):
        for p in pts:
            assert g[p[1]-1][p[0]-1] in FLOORS,f"M{num}: {lbl} ({p[0]},{p[1]}) ei lattiassa"
    for lbl,p in (("sp1",sp1),("sp2",sp2)):
        assert g[p[1]-1][p[0]-1] in FLOORS,f"M{num}: {lbl} ei lattiassa"
    req=[sp1,sp2]+list(exits)+list(enemies)+list(hostages)+list(bombs)
    seen=set();stack=[tuple(sp1)]
    while stack:
        x,y=stack.pop()
        if (x,y) in seen:continue
        seen.add((x,y))
        for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
            nx,ny=x+dx,y+dy
            if 1<=nx<=W and 1<=ny<=W and (nx,ny) not in seen and g[ny-1][nx-1] in FLOORS+'D':
                stack.append((nx,ny))
    for p in req:
        assert (p[0],p[1]) in seen,f"M{num}: ({p[0]},{p[1]}) eristyksissa"

def emit(num,g,doors,enemies,hostages,bombs,exits,sp1,sp2,
         name,loc,obj,brief,comment):
    for x,y in doors:
        n=0
        for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
            if 1<=x+dx<=W and 1<=y+dy<=W and g[y+dy-1][x+dx-1] in FLOORS+'D':n+=1
        assert n>=2,f"M{num}: ovi ({x},{y}) naapureita {n}"
    L=[f"-- {comment}",f"MIS[{num}]={{",f'name="{name}",loc="{loc}",obj="{obj}",',
       f'brief="{brief}",','m={']
    for row in g:L.append(' "'+''.join(row)+'",')
    L.append('},')
    pk=lambda lst:'{'+','.join(f'{{{a},{b}}}' for a,b in lst)+'}'
    L.append(f'doors={pk(doors)},enemies={pk(enemies)},hostages={pk(hostages)},')
    L.append(f'bombs={pk(bombs)},exits={pk(exits)},')
    L.append(f'sp1={{{sp1[0]},{sp1[1]}}},sp2={{{sp2[0]},{sp2[1]}}}}}')
    return '\n'.join(L)

out=['--------------------------- 03b TEHTAVAT (generoitu: tools/genmaps.py)',
     '-- varmistettu: kytkeytyvyys, ovet, entiteetit',
     'MIS={}']

# ===== M1: OP.KAAMOS - pankki =====
g=blank('#')
for a in [(3,25,10,4,'.',None),(3,16,10,8,'.',None),(6,9,2,7,'.',None),
        (3,2,8,7,',','W'),(14,2,7,6,',','W'),(11,4,3,2,'.',None),
        (16,8,2,7,'.',None),(15,13,13,14,'.',None),(13,19,2,2,'.',None),
        (21,4,3,2,'.',None),(24,2,5,7,'.','M'),(24,9,2,4,'.',None),
        (13,25,2,3,'.',None)]:
    carve(g,*a[:5])
for a in [(3,2,8,7,',','W'),(14,2,7,6,',','W'),(24,2,5,7,'.','M')]:
    walls(g,a[0],a[1],a[2],a[3],a[5])
for x,y in [(8,24),(6,8),(22,4),(16,15),(13,19),(24,12),(13,25)]:
    assert g[y-1][x-1] in WALLS+FLOORS,f"M1 ovi ({x},{y}) ei seinassa ({g[y-1][x-1]})"
    g[y-1][x-1]='D'
enemies=[(5,5),(17,4),(27,5),(20,17),(25,22),(9,19),(6,12)]
hostages=[];bombs=[];exits=[(3,26),(4,26)];sp1=(4,27);sp2=(11,27)
check_ents(1,g,enemies,hostages,bombs,exits,sp1,sp2)
out.append(emit(1,g,[(8,24),(6,8),(22,4),(16,15),(13,19),(24,12),(13,25)],
 enemies,hostages,bombs,exits,sp1,sp2,
 "OP.KAAMOS","HELSINGIN PANKKIKESKUS","kill",
 "Ryostajaryhma pankissa. Henkiloisto holveissa. Tyhjenna talo jotta poliisi paasee sisaa.",
 "M1 PANKKI: eteinen, aula, toimistot, holvikaytava, kassaholvi"))

# ===== M2: OP.REVONTULI - suurlahetysto =====
g=blank()
for a in [(13,25,6,4,'.',None),(7,13,17,11,'.',None),(3,3,8,8,',','W'),
        (20,3,7,8,',','W'),(12,2,6,7,',','W'),(5,11,2,4,'.',None),
        (23,11,2,4,'.',None),(14,9,2,4,'.',None),(3,18,4,6,'.','M'),
        (24,18,4,6,'.','M')]:
    carve(g,*a[:5])
for a in [(3,3,8,8,',','W'),(20,3,7,8,',','W'),(12,2,6,7,',','W'),
          (3,18,4,6,'.','M'),(24,18,4,6,'.','M')]:
    walls(g,a[0],a[1],a[2],a[3],a[5])
for x,y in [(15,24),(5,11),(23,11),(14,12),(6,20),(24,20)]:
    assert g[y-1][x-1] in WALLS+FLOORS,f"M2 ovi ({x},{y}) ei seinassa ({g[y-1][x-1]})"
    g[y-1][x-1]='D'
enemies=[(9,6),(23,6),(16,17),(20,21),(4,20),(26,20),(15,11)]
hostages=[(15,4)];bombs=[];exits=[(13,26),(18,26)];sp1=(14,27);sp2=(17,27)
check_ents(2,g,enemies,hostages,bombs,exits,sp1,sp2)
out.append(emit(2,g,[(15,24),(5,11),(23,11),(14,12),(6,20),(24,20)],
 enemies,hostages,bombs,exits,sp1,sp2,
 "OP.REVONTULI","SUURLAHETYSTO","rescue",
 "Militantit valtasivat suurlahetyston. Virkailija panttivankeina ylakerrassa. Etene varovasti: vangin henki ensimmaisena.",
 "M2 LAHETYSTO: juhla-aula, siipitoimistot, neuvotteluhuone"))

# ===== M3: OP.JAAKARHU - lentotukikohta =====
g=blank('M')
for a in [(2,25,6,4,'.',None),(4,10,20,14,'.',None),(25,3,4,7,',','M'),
        (24,8,1,3,'.',None),(2,10,2,4,',','W'),(5,8,2,2,'.',None),
        (2,2,10,6,',','W'),(25,12,4,8,'.','M'),(24,14,1,3,'.',None)]:
    carve(g,*a[:5])
for a in [(25,3,4,7,',','M'),(2,10,2,4,',','W'),(2,2,10,6,',','W'),
          (25,12,4,8,'.','M')]:
    walls(g,a[0],a[1],a[2],a[3],a[5])
for x,y in [(5,24),(24,9),(3,12),(5,8),(24,15)]:
    assert g[y-1][x-1] in WALLS+FLOORS,f"M3 ovi ({x},{y}) ei seinassa ({g[y-1][x-1]})"
    g[y-1][x-1]='D'
enemies=[(8,4),(27,6),(10,15),(18,20),(26,16),(16,12)]
hostages=[];bombs=[(27,15),(2,11)];exits=[(2,26)];sp1=(3,27);sp2=(6,27)
check_ents(3,g,enemies,hostages,bombs,exits,sp1,sp2)
out.append(emit(3,g,[(5,24),(24,9),(3,12),(5,8),(24,15)],
 enemies,hostages,bombs,exits,sp1,sp2,
 "OP.JAAKARHU","LENNOTUKIKOHTA SEKTORI 7","defuse",
 "Kaapatut koneet vanhalla tukikohdalla. Kaksi rajaydyslaitetta: asevarasto ja huoltoluola. Purka ne ennen nousua.",
 "M3 HANGAARI: iso avoin halli, komentoluola, asevarasto, huolto"))

# ===== M4: OP.SUSITAHD - varastoalue =====
g=blank('W')
for a in [(2,2,26,22,'.',None),(2,26,7,3,'.',None),(4,24,2,2,'.',None),
        (20,25,8,4,',','W')]:
    carve(g,*a[:5])
walls(g,20,25,8,4,'W')
for sx,sy,sw,sh in [(4,5,6,1),(12,5,6,1),(20,5,6,1),
          (2,9,6,1),(10,9,6,1),(18,9,6,1),
          (4,13,6,1),(12,13,6,1),(20,13,6,1),
          (6,17,5,1),(14,17,5,1),(22,17,5,1)]:
    carve(g,sx,sy,sw,sh,'W')
for x,y in [(4,24),(23,24)]:
    assert g[y-1][x-1] in WALLS+FLOORS,f"M4 ovi ({x},{y}) ei seinassa ({g[y-1][x-1]})"
    g[y-1][x-1]='D'
enemies=[(5,7),(16,3),(24,8),(12,17),(20,16),(26,20),(12,12),(6,21)]
hostages=[(25,27)];bombs=[];exits=[(2,26)];sp1=(3,27);sp2=(7,27)
check_ents(4,g,enemies,hostages,bombs,exits,sp1,sp2)
out.append(emit(4,g,[(4,24),(23,24)],
 enemies,hostages,bombs,exits,sp1,sp2,
 "OP.SUSITAHD","SATAMAN VARASTOALUE","killrescue",
 "Asekauppiaat varastolabyrintissa hyllyjen taakse. Vapauta virkailija toimistosta ja tyhjenna alue.",
 "M4 VARASTO: hyllylabyrintti, lastauslaituri, eteinen, toimisto"))

# ===== M5: OP.UKKONEN - klinikka =====
g=blank()
for a in [(12,26,8,3,'.',None),(12,19,8,6,'.',None),(3,10,2,14,'.',None),
        (23,10,2,14,'.',None),(3,8,23,2,'.',None),(3,2,6,5,',','W'),
        (10,2,6,5,',','W'),(17,2,6,5,',','W'),(24,2,5,5,',','W'),
        (5,20,7,2,'.',None),(20,20,3,2,'.',None),(7,11,10,7,'.','M'),
        (26,12,3,8,',','W'),(25,15,1,3,'.',None)]:
    carve(g,*a[:5])
for a in [(3,2,6,5,',','W'),(10,2,6,5,',','W'),(17,2,6,5,',','W'),
          (24,2,5,5,',','W'),(7,11,10,7,'.','M'),(26,12,3,8,',','W')]:
    walls(g,a[0],a[1],a[2],a[3],a[5])
for x,y in [(15,25),(5,7),(12,7),(19,7),(25,7),(14,18),(25,16)]:
    assert g[y-1][x-1] in WALLS+FLOORS,f"M5 ovi ({x},{y}) ei seinassa ({g[y-1][x-1]})"
    g[y-1][x-1]='D'
enemies=[(5,4),(13,3),(20,4),(27,4),(10,14),(24,20),(16,21)]
hostages=[];bombs=[(14,14),(27,13)];exits=[(12,26),(19,26)];sp1=(13,27);sp2=(18,27)
check_ents(5,g,enemies,hostages,bombs,exits,sp1,sp2)
out.append(emit(5,g,[(15,25),(5,7),(12,7),(19,7),(25,7),(14,18),(25,16)],
 enemies,hostages,bombs,exits,sp1,sp2,
 "OP.UKKONEN","YKSITYISKLINIKKA","defusekill",
 "Kiristysryhma klinikalla, uhkaa rajayttaa laboratorion. Purka laitteet ja tyhjenna rakennus.",
 "M5 KLINIKKA: potilassiivet, kaytarengas, operointisali, varasto"))

out.append('MIS_N=1')
src='\n'.join(out)+'\n'
open('/workspace/src/03b_missions.lua','w').write(src)
print("OK",len(src),"tavua")
