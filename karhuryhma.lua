SW,SH=240,136
FOV=0.7853982
MW,MH=32,32
HALF=60
SPEED=3.2/60
TURN=2.8/60
BRICK,CONCR,METAL,WOOD,DOORC=1,2,3,4,5
S_TITLE,S_MENU,S_BRIEF,S_PLAN,S_ACTION,S_DEBRIEF,S_EDITOR=0,1,2,3,4,5,6
PAL={
 {0x0a,0x0a,0x10},{0x22,0x22,0x2f},{0x55,0x55,0x6b},{0x9a,0x9a,0xb0},
 {0x3a,0x1f,0x16},{0x7a,0x3a,0x26},{0xbf,0x6a,0x42},{0x14,0x24,0x3d},
 {0x2f,0x5c,0x92},{0x6f,0xa3,0xd6},{0x2e,0x23,0x17},{0x6e,0x4d,0x2b},
 {0xb0,0x88,0x58},{0x12,0x3a,0x24},{0x3f,0xb9,0x6a},{0xf0,0xe9,0xcf}
}
LAPA={
 [0]={0,0,1},[1]={0,1,2},[2]={1,2,3},[3]={2,3,3},
 [4]={0,4,5},[5]={4,5,6},[6]={5,6,6},[7]={0,7,8},
 [8]={7,8,9},[9]={8,9,9},[10]={0,10,11},[11]={10,11,12},
 [12]={11,12,12},[13]={0,13,14},[14]={13,14,14},[15]={2,15,15}
}
BAY={
 [0]=0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5
}
function mkran(seed)
 local a=seed&0xffffffff
 return function()
 a=a+0x6D2B79F5
 local t=a
 t=(t+0x165667B1)&0xffffffff
 t=(t~(t>>15))*(t|1)&0xffffffff
 t=t~(t+(t>>7))
 t=t~(t>>16)
 t=(t&0xffffffff)
 return (t&0x7fffffff)/2147483648
 end
end
TS=32
function newtex() local t={} for i=1,TS*TS do t[i]=0 end return t end
local function tp(t,x,y,c) t[(y&31)*TS+(x&31)+1]=c end
function genBrick(rnd,base)
 local t=newtex() local d,m,l=base[1],base[2],base[3]
 for y=0,31 do for x=0,31 do
 local row=math.floor(y/8)
 local ox=(row%2)*8
 local bx=(x+ox)%16 local by=y%8
 local c=m
 if bx<1 or bx>14 or by<1 or by>6 then c=d end
 if rnd()<0.18 then c=(c==m and d or m) end
 if by>5 and bx>2 and bx<13 and rnd()<0.25 then c=l end
 if y>=28 then c=l end
 if y>=30 then c=m end
 tp(t,x,y,c)
 end end
 return t
end
function genConcr(rnd,base)
 local t=newtex() local d,m,l=base[1],base[2],base[3]
 for y=0,31 do for x=0,31 do
 local c=m
 if rnd()<0.3 then c=d elseif rnd()<0.2 then c=l end
 if y==0 or y==31 or x==0 or x==31 then c=d end
 if y>=28 then c=l end
 if y>=30 then c=m end
 if y<=1 then c=d end
 if (y%16==4) and rnd()<0.5 then c=l end
 tp(t,x,y,c)
 end end
 return t
end
function genMetal(rnd,base)
 local t=newtex() local d,m,l=base[1],base[2],base[3]
 for y=0,31 do for x=0,31 do
 local c=m
 if x%8==0 or x%8==7 then c=d end
 if y%8==0 or y%8==7 then c=d end
 if (x%8==3 or x%8==4) and (y%8==3 or y%8==4) then c=l end
 if (x%8==3) and rnd()<0.4 then c=d end
 tp(t,x,y,c)
 end end
 return t
end
function genWood(rnd,base)
 local t=newtex() local d,m,l=base[1],base[2],base[3]
 for y=0,31 do for x=0,31 do
 local plank=math.floor(y/8)
 local c=m
 if y%8==0 then c=d end
 local w=math.sin((x+plank*17)*0.5)*2+ (rnd()*3-1.5)
 if w>2 then c=l elseif w<-2 then c=d end
 if (x+plank*11)%16==0 then c=d end
 tp(t,x,y,c)
 end end
 return t
end
function genDoor(rnd,base)
 local t=newtex() local d,m,l=7,8,9
 for y=0,31 do for x=0,31 do
 local c=8
 if x<2 or x>29 or y<2 or y>29 then c=7 end
 if y==2 or y==29 then c=9 end
 if y>=13 and y<=18 and (math.floor((x+y)/2)%4)==0 then c=6 else
 if y>=13 and y<=18 then c=10 end end
 if y>=24 and y<=25 and x>=24 and x<=27 then c=15 end
 if y>=5 and y<=8 and x>=8 and x<=23 then c=9 end
 if y==6 and (x%2==0) then c=8 end
 tp(t,x,y,c)
 end end
 return t
end
function genFloor(rnd,base)
 local t=newtex() local d,m,l=base[1],base[2],base[3]
 for y=0,31 do for x=0,31 do
 local c=m
 if x%8==0 or y%8==0 then c=d end
 if rnd()<0.25 then c=d elseif rnd()<0.1 then c=l end
 tp(t,x,y,c)
 end end
 return t
end
function genParquet(rnd,base)
 local t=newtex() local d,m,l=base[1],base[2],base[3]
 for y=0,31 do for x=0,31 do
 local c=m
 local row=math.floor(y/4)
 local ox=(row%2)*8
 local px=(x+ox)%16
 if px==0 then c=d end
 local w=math.sin((x+row*13)*0.9)*1.5+rnd()*2-1
 if w>1.8 then c=l elseif w<-1.8 then c=d end
 tp(t,x,y,c)
 end end
 return t
end
function genCeil(rnd,base)
 local t=newtex() local d,m,l=base[1],base[2],base[3]
 for y=0,31 do for x=0,31 do
 local c=d
 if (x%16>=6 and x%16<=9) and (y%16>=6 and y%16<=9) then c=m end
 if (x%16>=7 and x%16<=8) and (y%16>=7 and y%16<=8) then c=l end
 tp(t,x,y,c)
 end end
 return t
end
function genExit(rnd)
 local t=newtex()
 for y=0,31 do for x=0,31 do
 local c=13
 if rnd()<0.2 then c=14 end
 if x==1 or x==30 or y==1 or y==30 then c=14 end
 local dx,dy=x-16,y-16
 if (math.abs(math.abs(dx)-math.abs(dy))<3) and dx*dx+dy*dy<196 then c=15 end
 tp(t,x,y,c)
 end end
 return t
end
TEX={}
function genTextures()
 local r=mkran(0xBEEF)
 TEX.wall={} TEX.floor={} TEX.ceil={}
 TEX.wall[BRICK]=genBrick(r,{4,5,6})
 TEX.wall[CONCR]=genConcr(r,{1,2,3})
 TEX.wall[METAL]=genMetal(r,{7,8,9})
 TEX.wall[WOOD]=genWood(r,{10,11,12})
 TEX.wall[DOORC]=genDoor(r)
 TEX.floor[1]=genFloor(r,{1,2,3})
 TEX.floor[2]=genParquet(r,{10,11,12})
 TEX.floor[3]=genFloor(r,{7,8,9})
 TEX.ceil=genCeil(r,{0,1,2})
 TEX.exit=genExit(r)
end
local function ch2c(ch,skin,jd,jm,jl,acc)
 if ch=='.' then return -1 end
 if ch=='J' then return jd end
 if ch=='j' then return jm end
 if ch=='K' then return jl end
 if ch=='s' then return skin end
 if ch=='g' then return 0 end
 if ch=='b' then return jd end
 if ch=='a' then return acc end
 if ch=='E' then return 0 end
 return -1
end
local function mkspr(art,skin,jd,jm,jl,acc)
 local h=#art local w=#art[1]
 local s={w=w,h=h,px={},jd=jd,jm=jm,jl=jl,skin=skin,acc=acc}
 for y=1,h do for x=1,w do
 s.px[y]={}
 s.px[y][x]=ch2c(art[y]:sub(x,x),skin,jd,jm,jl,acc)
 end end
 return s
end
local function legs(v)
 if v==0 then return {'.a..a.','..aa..','..b.b.','..b.b.'} end
 if v==1 then return {'..a.a.','.a...a','.b...b','.b...b'} end
 return {'.a..a.','.a..a.','..bb..','..bb..'} end
local function mkbody(leg,gun)
 return {
 '.JjjjjJ.'..(gun and '.g' or '..'),
 'JjjjjjjJ'..(gun and 'gg' or '..'),
 'JjsssjjJ'..(gun and 'gg' or '..'),
 '.JEsEJ..'..(gun and '..' or '..'),
 '.JjjjJ..'..(gun and '..' or '..'),
 '.jjjj...'..(gun and 'gg' or '..'),
 '.jjjj...'..(gun and 'g.' or '..'),
 table.unpack(legs(leg))
 }
end
local function mkdead()
 local a={
 '........',
 '........',
 '........',
 '........',
 '........',
 '........',
 '..sss...',
 '.JjjJgg.',
 'Jjjjjjjgg',
 }
 return a
end
local function mkhostage()
 return {
 '.ssss...',
 '.sEsE...',
 '.jssj...',
 '.jjjj...',
 '..jj..g.',
 '..jj....',
 '..bb....',
 '..bb....'
 }
end
local function mkbomb()
 return {
 '.....a..',
 '.aaaaaa.',
 'aJJJJJJj',
 'aJjjjjJj',
 'aJjEEjJj',
 'aJjjjjJj',
 '.aaaaaa.',
 '........'
 }
end
local function mkflash()
 return {
 '..aa..',
 '.aEEa.',
 '.aEEa.',
 '..aa..',
 '......',
 '..gg..'
 }
end
SPR={}
function genSprites()
 SPR.ew0=mkspr(mkbody(0,false),15,4,5,6,6)
 SPR.ew1=mkspr(mkbody(1,false),15,4,5,6,6)
 SPR.eaim=mkspr(mkbody(2,true),15,4,5,6,6)
 SPR.edead=mkspr(mkdead(),15,4,5,6,6)
 SPR.tw0=mkspr(mkbody(0,false),15,7,8,9,15)
 SPR.tw1=mkspr(mkbody(1,false),15,7,8,9,15)
 SPR.taim=mkspr(mkbody(2,true),15,7,8,9,15)
 SPR.host=mkspr(mkhostage(),15,10,11,12,14)
 SPR.bomb=mkspr(mkbomb(),15,1,2,3,6)
 SPR.flash=mkspr(mkflash(),15,1,2,3,9)
end
function idx(x,y) return y*MW+x+1 end
function cellAt(x,y)
 if x<0 or y<0 or x>=MW or y>=MH then return BRICK end
 return G.map.cells[idx(x,y)]
end
function isWall(x,y)
 local c=cellAt(x,y)
 return c>=1 and c<=4
end
function doorAt(x,y)
 return G.map.doors[idx(x,y)]
end
function passable(x,y)
 if x<0 or y<0 or x>=MW or y>=MH then return false end
 local c=G.map.cells[idx(x,y)]
 if c==0 then return true end
 if c==DOORC then
 local d=G.map.doors[idx(x,y)]
 return d and d.o>0.65
 end
 return false
end
function los(x0,y0,x1,y1)
 local dx,dy=x1-x0,y1-y0
 local dist=math.sqrt(dx*dx+dy*dy)
 if dist<0.001 then return true end
 local sx,sy=dx/dist,dy/dist
 local cx,cy=math.floor(x0),math.floor(y0)
 local tx,ty=math.floor(x1),math.floor(y1)
 local steps=math.floor(dist*3)+1
 local t=0
 while steps>0 do
 local nx,ny=x0+sx*t*dist,y0+sy*t*dist
 local ccx,ccy=math.floor(nx+sx*0.01),math.floor(ny+sy*0.01)
 if ccx==tx and ccy==ty then return true end
 local c=cellAt(ccx,ccy)
 if c>=1 and c<=4 then return false end
 if c==DOORC then
 local d=G.map.doors[idx(ccx,ccy)]
 if d.o<0.5 then return false end
 end
 t=t+1/3
 steps=steps-1
 end
 return true
end
function findPath(x0,y0,x1,y1)
 if x0==x1 and y0==y1 then return {{x1,y1}} end
 local W=MW
 local open={} local came={} local gs={}
 local hcost=function(x,y) return math.abs(x-x1)+math.abs(y-y1) end
 local s0=idx(x0,y0) local s1=idx(x1,y1)
 gs[s0]=0
 open[#open+1]={s0,hcost(x0,y0)}
 local inopen={} inopen[s0]=true
 local found=false
 local iter=0
 while #open>0 do
 iter=iter+1 if iter>2000 then return nil end
 local bi=1 local bv=open[1][2]
 for i=2,#open do if open[i][2]<bv then bv=open[i][2] bi=i end end
 local cur=open[bi][1]
 open[bi]=open[#open] open[#open]=nil inopen[cur]=false
 local cx,cy=(cur-1)%W,math.floor((cur-1)/W)
 if cur==s1 then found=true break end
 for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
 local nx,ny=cx+d[1],cy+d[2]
 if passable(nx,ny) or (nx==x1 and ny==y1) then
 local ni=idx(nx,ny)
 local ng=(gs[cur] or 0)+1
 if gs[ni]==nil or ng<gs[ni] then
 gs[ni]=ng came[ni]=cur
 local f=ng+math.abs(nx-x1)+math.abs(ny-y1)
 if not inopen[ni] then
 open[#open+1]={ni,f} inopen[ni]=true
 end
 end
 end
 end
 end
 if not found then return nil end
 local path={} local cur=s1
 while cur and cur~=s0 do
 path[#path+1]={(cur-1)%W,math.floor((cur-1)/W)}
 cur=came[cur]
 end
 local rev={}
 for i=#path,1,-1 do rev[#rev+1]=path[i] end
 return rev
end
MIS={}
MIS[1]={
name="OP.KAAMOS",loc="HELSINGIN PANKKIKESKUS",obj="kill",
brief="Ryostajaryhma pankissa. Henkiloisto holveissa. Tyhjenna talo jotta poliisi paasee sisaa.",
m={
 "#WWWWWWWWWW#WWWWWWWWW#MMMMMMM#",
 "#W,,,,,,,,W#W,,,,,,,W#M.....M#",
 "#W,,,,,,,,W#W,,,,,,,W#M.....M#",
 "#W,,,,,,,,...,,,,,,,.D......M#",
 "#W,,,,,,,,...,,,,,,,........M#",
 "#W,,,,,,,,W#W,,,,,,,W#M.....M#",
 "#W,,,,,,,,W#W,,,,,,,W#M.....M#",
 "#W,,,D,,,,W#WWW..WWWW#M.....M#",
 "#WWWW..WWWW####..#####M..MMMM#",
 "#####..########..######..#####",
 "#####..########..######..#####",
 "#####..########..######D.#####",
 "#####..#######.............###",
 "#####..#######.............###",
 "#####..#######.D...........###",
 "##..........##.............###",
 "##..........##.............###",
 "##..........##.............###",
 "##..........D..............###",
 "##.........................###",
 "##..........##.............###",
 "##..........##.............###",
 "##..........##.............###",
 "#######D######.............###",
 "##..........D..............###",
 "##.........................###",
 "##............################",
 "##..........##################",
 "##############################",
 "##############################",
},
doors={{8,24},{6,8},{22,4},{16,15},{13,19},{24,12},{13,25}},enemies={{5,5},{17,4},{27,5},{20,17},{25,22},{9,19},{6,12}},hostages={},
bombs={},exits={{3,26},{4,26}},
sp1={4,27},sp2={11,27}}
MIS[2]={
name="OP.REVONTULI",loc="SUURLAHETYSTO",obj="rescue",
brief="Militantit valtasivat suurlahetyston. Virkailija panttivankeina ylakerrassa. Etene varovasti: vangin henki ensimmaisena.",
m={
 "==========WWWWWWWW============",
 "=WWWWWWWWWW,,,,,,WWWWWWWWWW===",
 "=W,,,,,,,,W,,,,,,WW,,,,,,,W===",
 "=W,,,,,,,,W,,,,,,WW,,,,,,,W===",
 "=W,,,,,,,,W,,,,,,WW,,,,,,,W===",
 "=W,,,,,,,,W,,,,,,WW,,,,,,,W===",
 "=W,,,,,,,,W,,,,,,WW,,,,,,,W===",
 "=W,,,,,,,,W,,,,,,WW,,,,,,,W===",
 "=W,,,,,,,,WWW..WWWW,,,,,,,W===",
 "=W,,,,,,,,W==..===W,,,,,,,W===",
 "=WWWD.WWWWW==..===WWWWD.WWW===",
 "====..=======D.=======..======",
 "====....................======",
 "====....................======",
 "======.................=======",
 "======.................=======",
 "=MMMMM.................MMMMM==",
 "=M.........................M==",
 "=M.........................M==",
 "=M...D.................D...M==",
 "=M.........................M==",
 "=M.........................M==",
 "=M.........................M==",
 "=MMMMMM=======D=======MMMMMM==",
 "============......============",
 "============......============",
 "============......============",
 "============......============",
 "==============================",
 "==============================",
},
doors={{15,24},{5,11},{23,11},{14,12},{6,20},{24,20}},enemies={{9,6},{23,6},{16,17},{20,21},{4,20},{26,20},{15,11}},hostages={{15,4}},
bombs={},exits={{13,26},{18,26}},
sp1={14,27},sp2={17,27}}
MIS[3]={
name="OP.JAAKARHU",loc="LENNOTUKIKOHTA SEKTORI 7",obj="defuse",
brief="Kaapatut koneet vanhalla tukikohdalla. Kaksi rajaydyslaitetta: asevarasto ja huoltoluola. Purka ne ennen nousua.",
m={
 "WWWWWWWWWWWWMMMMMMMMMMMMMMMMMM",
 "W,,,,,,,,,,WMMMMMMMMMMMMMMMMMM",
 "W,,,,,,,,,,WMMMMMMMMMMMM,,,,MM",
 "W,,,,,,,,,,WMMMMMMMMMMMM,,,,MM",
 "W,,,,,,,,,,WMMMMMMMMMMMM,,,,MM",
 "W,,,,,,,,,,WMMMMMMMMMMMM,,,,MM",
 "W,,,,,,,,,,WMMMMMMMMMMMM,,,,MM",
 "WWWWD.WWWWWWMMMMMMMMMMM.,,,,MM",
 "WWWW..MMMMMMMMMMMMMMMMMD,,,,MM",
 "W,,.....................MMMMMM",
 "W,,....................MMMMMMM",
 "W,D....................M....MM",
 "W,,....................M....MM",
 "WWW.........................MM",
 "MMM....................D....MM",
 "MMM.........................MM",
 "MMM....................M....MM",
 "MMM....................M....MM",
 "MMM....................M....MM",
 "MMM....................MMMMMMM",
 "MMM....................MMMMMMM",
 "MMM....................MMMMMMM",
 "MMM....................MMMMMMM",
 "MMMMDMMMMMMMMMMMMMMMMMMMMMMMMM",
 "M......MMMMMMMMMMMMMMMMMMMMMMM",
 "M......MMMMMMMMMMMMMMMMMMMMMMM",
 "M......MMMMMMMMMMMMMMMMMMMMMMM",
 "M......MMMMMMMMMMMMMMMMMMMMMMM",
 "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM",
 "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM",
},
doors={{5,24},{24,9},{3,12},{5,8},{24,15}},enemies={{8,4},{27,6},{10,15},{18,20},{26,16},{16,12}},hostages={},
bombs={{27,15},{2,11}},exits={{2,26}},
sp1={3,27},sp2={6,27}}
MIS[4]={
name="OP.SUSITAHD",loc="SATAMAN VARASTOALUE",obj="killrescue",
brief="Asekauppiaat varastolabyrintissa hyllyjen taakse. Vapauta virkailija toimistosta ja tyhjenna alue.",
m={
 "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..WWWWWW..WWWWWW..WWWWWW..WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..........................WWW",
 "WWWWWWW..WWWWWW..WWWWWW....WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..WWWWWW..WWWWWW..WWWWWW..WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W....WWWWW...WWWWW...WWWWW.WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..........................WWW",
 "W..........................WWW",
 "WWWD.WWWWWWWWWWWWWWWWWDWWWWWWW",
 "WWW..WWWWWWWWWWWWWW,,,,,,,,WWW",
 "W.......WWWWWWWWWWW,,,,,,,,WWW",
 "W.......WWWWWWWWWWW,,,,,,,,WWW",
 "W.......WWWWWWWWWWW,,,,,,,,WWW",
 "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
 "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
},
doors={{4,24},{23,24}},enemies={{5,7},{16,3},{24,8},{12,17},{20,16},{26,20},{12,12},{6,21}},hostages={{25,27}},
bombs={},exits={{2,26}},
sp1={3,27},sp2={7,27}}
MIS[5]={
name="OP.UKKONEN",loc="YKSITYISKLINIKKA",obj="defusekill",
brief="Kiristysryhma klinikalla, uhkaa rajayttaa laboratorion. Purka laitteet ja tyhjenna rakennus.",
m={
 "=WWWWWWWWWWWWWWWWWWWWWWWWWWWW=",
 "=W,,,,,,W,,,,,,W,,,,,,W,,,,,W=",
 "=W,,,,,,W,,,,,,W,,,,,,W,,,,,W=",
 "=W,,,,,,W,,,,,,W,,,,,,W,,,,,W=",
 "=W,,,,,,W,,,,,,W,,,,,,W,,,,,W=",
 "=W,,,,,,W,,,,,,W,,,,,,W,,,,,W=",
 "=WWWDWWWWWWDWWWWWWDWWWWWDWWWW=",
 "==.......................=====",
 "==.......................=====",
 "==..=MMMMMMMMMMMM=====..======",
 "==..=M..........M=====..WWWWW=",
 "==..=M..........M=====..W,,,W=",
 "==..=M..........M=====..W,,,W=",
 "==..=M..........M=====..W,,,W=",
 "==..=M..........M=====...,,,W=",
 "==..=M..........M=====..D,,,W=",
 "==..=M..........M=====...,,,W=",
 "==..=MMMMMMMMDMMM=====..W,,,W=",
 "==..=======........===..W,,,W=",
 "==......................WWWWW=",
 "==......................======",
 "==..=======........===..======",
 "==..=======........===..======",
 "===========........===========",
 "==============D===============",
 "===========........===========",
 "===========........===========",
 "===========........===========",
 "==============================",
 "==============================",
},
doors={{15,25},{5,7},{12,7},{19,7},{25,7},{14,18},{25,16}},enemies={{5,4},{13,3},{20,4},{27,4},{10,14},{24,20},{16,21}},hostages={},
bombs={{14,14},{27,13}},exits={{12,26},{19,26}},
sp1={13,27},sp2={18,27}}
MIS_N=1
CH2W={['#']=BRICK,['=']=CONCR,['M']=METAL,['W']=WOOD,['D']=DOORC}
CH2F={['.']=1,[',']=2}
function buildMap(md)
 local m={cells={},floors={},doors={},exits={},md=md}
 for i=1,MW*MH do m.cells[i]=CONCR m.floors[i]=1 end
 for y=1,30 do
 local row=md.m[y]
 for x=1,30 do
 local ch=row:sub(x,x)
 local ii=idx(x,y)
 m.cells[ii]=CH2W[ch] or 0
 if m.cells[ii]==DOORC then m.doors[ii]={o=0,op=false} end
 if CH2F[ch] then m.floors[ii]=CH2F[ch] end
 end
 end
 for _,e in ipairs(md.exits) do
 m.floors[idx(e[1],e[2])]=99
 m.exits[#m.exits+1]={e[1],e[2]}
 end
 return m
end
function toggleDoor(cx,cy)
 local d=doorAt(cx,cy)
 if d then d.op=not d.op end
end
function updateDoors()
 for _,d in pairs(G.map.doors) do
 if d.op and d.o<1 then d.o=math.min(1,d.o+0.06)
 elseif not d.op and d.o>0 then d.o=math.max(0,d.o-0.06) end
 end
end
function genProcMap(seed,obj)
 local try=0
 while try<20 do
 try=try+1
 local rnd=mkran(seed*7919+try*104729)
 local wallch='='
 if rnd()<0.5 then wallch='#' end
 local g={}
 for y=1,30 do g[y]=string.rep(wallch,30) end
 local function setc(x,y,c) g[y]=g[y]:sub(1,x-1)..c..g[y]:sub(x+1) end
 local function getc(x,y) return g[y]:sub(x,x) end
 local rooms={}
 local function overlap(x,y,w,h)
 for _,r in ipairs(rooms) do
 if x<r.x+r.w+2 and r.x<x+w+2 and y<r.y+r.h+2 and r.y<y+h+2 then return true end
 end
 end
 for i=1,60 do
 if #rooms>=8 then break end
 local w=3+math.floor(rnd()*5) local h=3+math.floor(rnd()*5)
 local x=2+math.floor(rnd()*(27-w)) local y=2+math.floor(rnd()*(27-h))
 if not overlap(x,y,w,h) then rooms[#rooms+1]={x=x,y=y,w=w,h=h} end
 end
 for _,r in ipairs(rooms) do
 local f='.' if rnd()<0.5 then f=',' end
 for yy=r.y,r.y+r.h-1 do for xx=r.x,r.x+r.w-1 do setc(xx,yy,f) end end
 end
 table.sort(rooms,function(a,b) return a.x<b.x end)
 local pathcells={}
 for i=2,#rooms do
 local a,b=rooms[i-1],rooms[i]
 local ax,ay=a.x+math.floor(a.w/2),a.y+math.floor(a.h/2)
 local bx,by=b.x+math.floor(b.w/2),b.y+math.floor(b.h/2)
 local x,y=ax,ay
 while x~=bx do
 if getc(x,y)~='.' and getc(x,y)~=',' then
 pathcells[#pathcells+1]={x,y} setc(x,y,'.') end
 x=x+(bx>x and 1 or -1)
 end
 while y~=by do
 if getc(x,y)~='.' and getc(x,y)~=',' then
 pathcells[#pathcells+1]={x,y} setc(x,y,'.') end
 y=y+(by>y and 1 or -1)
 end
 end
 for _,pc in ipairs(pathcells) do
 local x,y=pc[1],pc[2]
 local function fl(cx,cy) local c=getc(cx,cy) return (c=='.'or c==',')and 1 or 0 end
 local l=fl(x-1,y) local r2=fl(x+1,y) local u=fl(x,y-1) local dw=fl(x,y+1)
 if ((l+r2==2)or(u+dw==2))and(l+r2+u+dw)==2 and rnd()<0.5 then
 setc(x,y,'D')
 end
 end
 local first,last=rooms[1],rooms[#rooms]
 local sp1={first.x+1,first.y+1}
 local sp2={first.x+first.w-2,first.y+1}
 local exits={{last.x+1,last.y+1},{last.x+2,last.y+1}}
 local enemies={}
 for i=2,#rooms do
 if i<#rooms then
 local r=rooms[i]
 enemies[#enemies+1]={r.x+math.floor(r.w/2),r.y+math.floor(r.h/2)}
 end
 end
 local mid=rooms[math.max(2,math.floor(#rooms/2))]
 local hostages={} local bombs={}
 if obj=='rescue' or obj=='killrescue' then
 hostages={{last.x+math.floor(last.w/2),last.y+math.floor(last.h/2)}}
 end
 if obj=='defuse' or obj=='defusekill' then
 bombs={{last.x+1,last.y+1},{mid.x+1,mid.y+1}}
 end
 local function isf(x,y) local c=getc(x,y) return c=='.' or c==',' end
 local ok=isf(sp1[1],sp1[2]) and isf(sp2[1],sp2[2])
 for _,e in ipairs(exits) do ok=ok and isf(e[1],e[2]) end
 for _,e in ipairs(enemies) do ok=ok and isf(e[1],e[2]) end
 for _,h in ipairs(hostages) do ok=ok and isf(h[1],h[2]) end
 for _,b in ipairs(bombs) do ok=ok and isf(b[1],b[2]) end
 if ok then
 return {name='OP.TOISTO',loc='PROSEDURAALINEN KOHDE',obj=obj,
 brief='Satunnaisgeneroitu harjoituskohde. Aihe vaihtelee.',
 m=g,enemies=enemies,hostages=hostages,bombs=bombs,
 exits=exits,sp1=sp1,sp2=sp2}
 end
 end
 return nil
end
PM_MAGIC=0x4B41523A
PM_BASE=1
PM_OBJN=129
PM_OBJ=130
function pmSaveEditor(ed)
 pmem(0,PM_MAGIC)
 for w=0,127 do
 local v=0
 for b=0,7 do
 local i=w*8+b
 local c=ed.cells[i+1] or 0
 v=v|((c&15)<<(b*4))
 end
 pmem(PM_BASE+w,v)
 end
 pmem(PM_OBJN,#ed.objs)
 for i,o in ipairs(ed.objs) do
 if i<=40 then pmem(PM_OBJ+i-1,(o.t<<12)|(o.y<<6)|o.x) end
 end
end
function pmLoadEditor(ed)
 if pmem(0)~=PM_MAGIC then return false end
 for w=0,127 do
 local v=pmem(PM_BASE+w)
 for b=0,7 do
 ed.cells[w*8+b+1]=(v>>(b*4))&15
 end
 end
 ed.objs={}
 local n=pmem(PM_OBJN)
 for i=0,math.min(n,40)-1 do
 local v=pmem(PM_OBJ+i)
 ed.objs[#ed.objs+1]={t=v>>12,y=(v>>6)&63,x=v&63}
 end
 return true
end
G={phase=S_TITLE,inj={},injP={},frame=0,mem={},msg=nil,plan=nil}
G.stats={shots=0,hits=0,kills=0,t=0}
TEAMNAMES={{"SUSI 1","SUSI 2"},{"KARHU 1","KARHU 2"}}
GOKEYS={28,29,30}
function kd(c) return key(c) or G.inj[c]==true end
function kdp(c)
 if keyp(c) then return true end
 if G.injP[c]==true then G.injP[c]=false return true end
 return false
end
function bd(b) return btn(b) end
function clearInj() G.inj={} G.injP={} end
function newMember(team,i,x,y)
 return {x=x+0.5,y=y+0.5,ang=0,hp=100,alive=true,
 team=team,name=TEAMNAMES[team+1][i],id=team*2+i,
 ammo=30,mag=3,flash=2,reload=0,
 ai={path=nil,pi=1,wait=false,shootT=0},rec=0}
end
function newEnemy(x,y)
 return {x=x+0.5,y=y+0.5,ang=math.random()*6.28,hp=50,alive=true,
 state=0,aimT=0,fireT=0,stun=0,path=nil,pi=1,
 seen=false,lx=0,ly=0,seeT=0,strafe=0}
end
function loadMission(md,plan)
 G.md=md
 G.map=buildMap(md)
 G.enemies={} G.hostages={} G.bombs={}
 G.tracers={} G.sparks={} G.parts={}
 for _,e in ipairs(md.enemies or {}) do G.enemies[#G.enemies+1]=newEnemy(e[1],e[2]) end
 for _,h in ipairs(md.hostages or {}) do
 G.hostages[#G.hostages+1]={x=h[1]+0.5,y=h[2]+0.5,ang=0,sec=false} end
 for _,b in ipairs(md.bombs or {}) do
 G.bombs[#G.bombs+1]={x=b[1]+0.5,y=b[2]+0.5,def=false,prog=0,blink=0} end
 G.plan=plan or {
 {start={md.sp1[1],md.sp1[2]},wps={}},
 {start={md.sp2[1],md.sp2[2]},wps={}}}
 G.members={}
 for t=0,1 do
 for i=1,2 do
 local s=G.plan[t+1].start
 G.members[#G.members+1]=newMember(t,i,s[1],s[2])
 end
 end
 G.player=1
 G.go={false,false,false}
 G.objReady=false G.done=false G.failed=false
 G.stats={shots=0,hits=0,kills=0,t=0}
 G.t=0 G.frame=0
 G.mz=0 G.moveFlags={} G.flash=nil
 G.extractReady=false
end
function msg(txt,ttl) G.msg={txt=txt,t=ttl or 3} end
function castRay(px,py,dx,dy,maxd)
 local mapX,mapY=math.floor(px),math.floor(py)
 local ddx=(dx==0)and 1e9 or math.abs(1/dx)
 local ddy=(dy==0)and 1e9 or math.abs(1/dy)
 local stepX,stepY,sdx,sdy
 if dx<0 then stepX=-1 sdx=(px-mapX)*ddx else stepX=1 sdx=(mapX+1-px)*ddx end
 if dy<0 then stepY=-1 sdy=(py-mapY)*ddy else stepY=1 sdy=(mapY+1-py)*ddy end
 local side=0
 local d=0
 for i=1,64 do
 if sdx<sdy then d=sdx mapX=mapX+stepX side=0
 else d=sdy mapY=mapY+stepY side=1 end
 if d>(maxd or 64) then return {dist=(maxd or 64),side=side,cx=mapX,cy=mapY,wallx=0} end
 local c=cellAt(mapX,mapY)
 if c>=1 and c<=4 then
 local wallx
 if side==0 then wallx=py+d*dy else wallx=px+d*dx end
 wallx=wallx-math.floor(wallx)
 return {dist=d,side=side,cx=mapX,cy=mapY,wallx=wallx}
 elseif c==DOORC then
 local dd=d+0.5
 local hx,hz
 if side==0 then
 hx=py+dd*dy hz=px+dd*dx
 if math.floor(hz)==mapX then
 local wallx=hx-math.floor(hx)
 local door=G.map.doors[idx(mapX,mapY)]
 if wallx>door.o then
 return {dist=dd,side=side,cx=mapX,cy=mapY,wallx=wallx-door.o,door=door}
 end
 end
 else
 hx=px+dd*dx hz=py+dd*dy
 if math.floor(hz)==mapY then
 local wallx=hx-math.floor(hx)
 local door=G.map.doors[idx(mapX,mapY)]
 if wallx>door.o then
 return {dist=dd,side=side,cx=mapX,cy=mapY,wallx=wallx-door.o,door=door}
 end
 end
 end
 end
 end
 return {dist=maxd or 64,side=0,cx=mapX,cy=mapY,wallx=0}
end
function shootRay(sh,x,y,ang,spread,dmg)
 local a=ang+(math.random()-0.5)*spread
 local dx,dy=math.cos(a),math.sin(a)
 local hit=castRay(x,y,dx,dy,32)
 local bestD=hit.dist local target=nil
 local list
 if sh.isEnemy then list=G.members else list=G.enemies end
 for _,e in ipairs(list) do
 if e~=sh and e.alive then
 local rx,ry=e.x-x,e.y-y
 local t=rx*dx+ry*dy
 if t>0.3 and t<bestD then
 local lat=math.abs(rx*dy-ry*dx)
 if lat<0.32 then bestD=t target=e end
 end
 end
 end
 local ex,ey=x+dx*bestD,y+dy*bestD
 G.tracers[#G.tracers+1]={x0=x+dx*0.3,y0=y+dy*0.3,x1=ex,y1=ey,t=0.08,c=15}
 if target then
 target.hp=target.hp-dmg
 G.stats.hits=G.stats.hits+1 SND(1,72,8,3,1)
 for i=1,4 do
 G.parts[#G.parts+1]={x=ex,y=ey,vx=(math.random()-0.5)*0.04,
 vy=(math.random()-0.5)*0.04,t=0.5,c=4}
 end
 if target.hp<=0 then
 target.alive=false
 if not sh.isEnemy then G.stats.kills=G.stats.kills+1 end
 end
 return true
 else
 G.sparks[#G.sparks+1]={x=ex-dx*0.05,y=ey-dy*0.05,t=0.15,c=15}
 return false
 end
end
function memberFire(m)
 if m.reload>0 or m.ammo<=0 then return end
 m.ammo=m.ammo-1
 G.stats.shots=G.stats.shots+1
 local spr=0.02+(m.rec*0.012)
 m.rec=math.min(6,m.rec+1.2)
 sfxShot()
 shootRay(m,m.x,m.y,m.ang,spr,14+math.random(0,5))
 for _,e in ipairs(G.enemies) do
 if e.alive and e.state==0 then
 local dd=math.sqrt((e.x-m.x)^2+(e.y-m.y)^2)
 if dd<9 then e.state=1 e.lx=m.x e.ly=m.y e.path=nil end
 end
 end
end
function enemyFire(e)
 local acc=0.055
 if e.stun>0 then acc=0.4 end
 local dd=1
 acc=acc+dd*0.004
 local a=e.ang+(math.random()-0.5)*acc
 local dx,dy=math.cos(a),math.sin(a)
 local hit=castRay(e.x,e.y,dx,dy,32)
 local bestD=hit.dist local target=nil
 for _,mm in ipairs(G.members) do
 if mm.alive then
 local rx,ry=mm.x-e.x,mm.y-e.y
 local t=rx*dx+ry*dy
 if t>0.3 and t<bestD then
 local lat=math.abs(rx*dy-ry*dx)
 if lat<0.3 then bestD=t target=mm end
 end
 end
 end
 G.tracers[#G.tracers+1]={x0=e.x+dx*0.3,y0=e.y+dy*0.3,
 x1=e.x+dx*bestD,y1=e.y+dy*bestD,t=0.08,c=6}
 if target then
 target.hp=target.hp-(8+math.random(0,7))
 for i=1,4 do
 G.parts[#G.parts+1]={x=target.x,y=target.y,vx=(math.random()-0.5)*0.04,
 vy=(math.random()-0.5)*0.04,t=0.5,c=4}
 end
 if target.hp<=0 then
 target.alive=false
 msg(target.name..' KUOLI!',2) SND(7,50,8,6,2)
 autoSwitch()
 end
 else
 G.sparks[#G.sparks+1]={x=e.x+dx*bestD,y=e.y+dy*bestD,t=0.15,c=15}
 end
 sfxShot()
end
function autoSwitch()
 local p=G.player
 for i=1,4 do
 local n=((p-1+i)%4)+1
 if G.members[n].alive then G.player=n msg(G.members[n].name..' OTTI KOMENNON',2) return end
 end
end
function objText()
 local o=G.md.obj local t={}
 if o=='kill'or o=='killrescue'or o=='defusekill' then
 local n=0 for _,e in ipairs(G.enemies) do if e.alive then n=n+1 end end
 t[#t+1]='VASTUSTAJIA: '..n
 end
 if o=='rescue'or o=='killrescue' then
 local n=0 for _,h in ipairs(G.hostages) do if not h.sec then n=n+1 end end
 t[#t+1]='VAPAUTETTAVA: '..n
 end
 if o=='defuse'or o=='defusekill' then
 local n=0 for _,b in ipairs(G.bombs) do if not b.def then n=n+1 end end
 t[#t+1]='PURKAMATTA: '..n
 end
 return t
end
function checkObjectives()
 if G.objReady then return end
 local o=G.md.obj local ok=true
 if o=='kill'or o=='killrescue'or o=='defusekill' then
 for _,e in ipairs(G.enemies) do if e.alive then ok=false end end
 end
 if o=='rescue'or o=='killrescue' then
 for _,h in ipairs(G.hostages) do if not h.sec then ok=false end end
 end
 if o=='defuse'or o=='defusekill' then
 for _,b in ipairs(G.bombs) do if not b.def then ok=false end end
 end
 if ok then
 G.objReady=true
 msg('TAVOITTEET VALMIIT! SIIRRY POISTUMISALUEELLE',4)
 end
end
function moveEnt(e,dx,dy)
 local r=0.25
 local nx,ny=e.x+dx,e.y+dy
 local function free(x,y)
 local c0=cellAt(math.floor(x-r),math.floor(y-r))
 local c1=cellAt(math.floor(x+r),math.floor(y-r))
 local c2=cellAt(math.floor(x-r),math.floor(y+r))
 local c3=cellAt(math.floor(x+r),math.floor(y+r))
 for _,c in ipairs({c0,c1,c2,c3}) do
 if c>=1 and c<=4 then return false end
 if c==DOORC then
 local d=G.map.doors[idx(math.floor(x),math.floor(y))]
 if d.o<0.65 then return false end
 end
 end
 return true
 end
 if free(nx,e.y) then e.x=nx end
 if free(e.x,ny) then e.y=ny end
end
function stepToward(e,tx,ty,speed)
 local dx,dy=tx-e.x,ty-e.y
 local d=math.sqrt(dx*dx+dy*dy)
 if d<0.05 then return true end
 moveEnt(e,dx/d*speed,dy/d*speed)
 local na=math.atan2(dy,dx)
 local da=na-e.ang
 while da>3.14159265 do da=da-6.2831853 end
 while da<-3.14159265 do da=da+6.2831853 end
 e.ang=e.ang+da*0.25
 return false
end
function memberAI(m,plan)
 local tgt=nil local bd=12
 for _,e in ipairs(G.enemies) do
 if e.alive then
 local dd=math.sqrt((e.x-m.x)^2+(e.y-m.y)^2)
 if dd<bd and los(m.x,m.y,e.x,e.y) then bd=dd tgt=e end
 end
 end
 if tgt then
 local na=math.atan2(tgt.y-m.y,tgt.x-m.x)
 local da=na-m.ang
 while da>3.14159265 do da=da-6.2831853 end
 while da<-3.14159265 do da=da+6.2831853 end
 m.ang=m.ang+da*0.2
 m.ai.shootT=m.ai.shootT-1/60
 if math.abs(da)<0.2 and m.ai.shootT<=0 and m.ammo>0 then
 memberFire(m)
 m.ai.shootT=0.12+math.random()*0.2
 end
 return
 end
 m.ai.shootT=0
 local wps=plan.wps
 if #wps==0 then return end
 local wp=wps[m.ai.pi or 1]
 if wp==nil then return end
 if wp.go and wp.go>0 and not G.go[wp.go] then return end
 if not m.ai.path then
 m.ai.path=findPath(math.floor(m.x),math.floor(m.y),wp[1],wp[2])
 if not m.ai.path then m.ai.pi=math.min(m.ai.pi+1,#wps) return end
 m.ai.ni=1
 end
 local node=m.ai.path[m.ai.ni]
 if node==nil then
 if m.ai.pi<#wps then m.ai.pi=m.ai.pi+1 end
 m.ai.path=nil
 return
 end
 local tx,ty=node[1]+0.5,node[2]+0.5
 if stepToward(m,tx,ty,0.045) then
 local cx,cy=node[1],node[2]
 if cellAt(cx,cy)==DOORC then
 local d=doorAt(cx,cy)
 if d.o<0.9 then d.op=true end
 end
 m.ai.ni=m.ai.ni+1
 end
end
function enemyAI(e)
 if not e.alive then return end
 if e.stun>0 then e.stun=e.stun-1/60 return end
 local tgt=nil local bd=11
 for _,m in ipairs(G.members) do
 if m.alive then
 local dd=math.sqrt((m.x-e.x)^2+(m.y-e.y)^2)
 if dd<bd then bd=dd tgt=m end
 end
 end
 if tgt then
 local seen=los(e.x,e.y,tgt.x,tgt.y)
 local inFov=true
 if e.state==0 then
 local a=math.atan2(tgt.y-e.y,tgt.x-e.x)
 local da=a-e.ang
 while da>3.14159265 do da=da-6.2831853 end
 while da<-3.14159265 do da=da+6.2831853 end
 if math.abs(da)>0.9 then inFov=false end
 end
 if seen and inFov then
 e.seen=true e.lx=tgt.x e.ly=tgt.y
 if e.state<2 then
 e.seeT=e.seeT+1/60
 if e.seeT>0.45 then e.state=2 e.seeT=0 end
 end
 else
 e.seeT=0
 if e.state==2 and not seen then
 e.state=1 e.lx=tgt.x e.ly=tgt.y e.path=nil
 end
 end
 end
 if e.state==2 and tgt then
 local na=math.atan2(tgt.y-e.y,tgt.x-e.x)
 local da=na-e.ang
 while da>3.14159265 do da=da-6.2831853 end
 while da<-3.14159265 do da=da+6.2831853 end
 e.ang=e.ang+da*0.15
 e.fireT=e.fireT-1/60
 if math.abs(da)<0.25 and e.fireT<=0 and los(e.x,e.y,tgt.x,tgt.y) then
 enemyFire(e)
 e.fireT=0.4+math.random()*0.5
 end
 e.strafe=e.strafe-1/60
 if e.strafe<=0 then e.strafe=1+math.random()*1.5
 e.sdx=math.random()-0.5 e.sdy=math.random()-0.5 end
 moveEnt(e,e.sdx*0.008,e.sdy*0.008)
 elseif e.state==1 then
 if not e.path then
 e.path=findPath(math.floor(e.x),math.floor(e.y),math.floor(e.lx),math.floor(e.ly))
 e.ni=1
 end
 if e.path then
 local node=e.path[e.ni]
 if node==nil then e.state=0 e.path=nil
 else
 local tx,ty=node[1]+0.5,node[2]+0.5
 if stepToward(e,tx,ty,0.02) then
 if cellAt(node[1],node[2])==DOORC then
 local d=doorAt(node[1],node[2]) if d.o<0.9 then d.op=true end
 end
 e.ni=e.ni+1
 end
 end
 else e.state=0 end
 else
 if math.random()<0.004 then e.ang=e.ang+(math.random()-0.5)*1.6 end
 end
end
function anyAlive()
 for _,m in ipairs(G.members) do if m.alive then return true end end
 return false
end
function atExit(m)
 local cx,cy=math.floor(m.x),math.floor(m.y)
 for _,e in ipairs(G.map.exits) do
 if e[1]==cx and e[2]==cy then return true end
 end
 return false
end
local VRAM=0
function P4(x,y,c) poke4(y*240+x,c) end
function render3D(m)
 local px,py,pa=m.x,m.y,m.ang
 local bob=math.sin(G.frame*0.35)*(moving(m)and 1.5 or 0.3)
 local hor=68+bob
 local dirX,dirY=math.cos(pa),math.sin(pa)
 local plX,plY=-dirY*0.72,dirX*0.72
 local mz=0
 if G.mz>0 then mz=G.mz*1.4 end
 cls(0)
 local rdx0,rdy0=dirX-plX,dirY-plY
 local rdx1,rdy1=dirX+plX,dirY+plY
 local CTEX=TEX.ceil
 for y=2,134,2 do
 local p=y-hor
 local isFloor=p>0
 if p==0 then p=0.001 end
 local rowDist=68/math.abs(p)
 if rowDist<15 then
 local stepX=rowDist*(rdx1-rdx0)/120
 local stepY=rowDist*(rdy1-rdy0)/120
 local fx=px+rowDist*rdx0
 local fy=py+rowDist*rdy0
 local l=3.5*math.exp(-rowDist*0.105)+mz*math.exp(-rowDist*0.2)
 if not isFloor then l=l*0.62 end
 if l>2.98 then l=2.98 elseif l<0 then l=0 end
 local li=math.floor(l) local fr=l-li
 local base=y*240
 for x=0,119 do
 local cxi=math.floor(fx) local cyi=math.floor(fy)
 local tex
 if isFloor then
 local f=G.map.floors[idx(cxi,cyi)] or 1
 if f==99 then tex=TEX.exit else tex=TEX.floor[f] end
 else tex=CTEX end
 local tx=fx-cxi local ty=fy-cyi
 local t2=(math.floor(ty*32)*32+math.floor(tx*32))
 local c=tex[(t2&1023)+1]
 if c==nil then
 trace('NILC t2='..t2..' t2b='..(t2&1023)..' f='..tostring(f)..' cxi='..cxi..' cyi='..cyi..' tx='..tx..' ty='..ty)
 c=0
 end
 local th=BAY[((y&3)<<2)|((x*2)&3)]/16
 local lvl=li+(fr>th and 1 or 0)
 if lvl>2 then lvl=2 elseif lvl<0 then lvl=0 end
 local map_=LAPA[c]
 poke4(base+x*2,map_[lvl+1])
 poke4(base+x*2+1,map_[lvl+1])
 poke4(base+240+x*2,map_[lvl+1])
 poke4(base+240+x*2+1,map_[lvl+1])
 fx=fx+stepX fy=fy+stepY
 end
 end
 end
 local zbuf=G.zbuf
 for col=0,119 do
 local camX=2*col/120-1
 local rdx=dirX+plX*camX
 local rdy=dirY+plY*camX
 local mapX,mapY=math.floor(px),math.floor(py)
 local ddx=(rdx==0)and 1e9 or math.abs(1/rdx)
 local ddy=(rdy==0)and 1e9 or math.abs(1/rdy)
 local stepX,stepY,sdx,sdy
 if rdx<0 then stepX=-1 sdx=(px-mapX)*ddx else stepX=1 sdx=(mapX+1-px)*ddx end
 if rdy<0 then stepY=-1 sdy=(py-mapY)*ddy else stepY=1 sdy=(mapY+1-py)*ddy end
 local side=0 local cell=0 local hitd=0 local wallx=0 local door=nil
 for i=1,64 do
 if sdx<sdy then hitd=sdx mapX=mapX+stepX side=0
 else hitd=sdy mapY=mapY+stepY side=1 end
 local c=G.map.cells[idx(mapX,mapY)]
 if c>=1 and c<=4 then cell=c break end
 if c==DOORC then
 local d=G.map.doors[idx(mapX,mapY)]
 local dd=hitd+ddx*0.5+ddy*0.5
 local hz1,hz2
 if side==0 then
 hz1=px+dd*rdx hz2=py+dd*rdy
 if math.floor(hz1)==mapX then
 local wx=hz2-math.floor(hz2)
 if wx>d.o then cell=DOORC wallx=wx-d.o door=d hitd=dd break end
 end
 else
 hz1=px+dd*rdx hz2=py+dd*rdy
 if math.floor(hz2)==mapY then
 local wx=hz1-math.floor(hz1)
 if wx>d.o then cell=DOORC wallx=wx-d.o door=d hitd=dd break end
 end
 end
 end
 end
 local perp
 if side==0 then
 perp=(mapX-px+(1-stepX)/2)/rdx
 else
 perp=(mapY-py+(1-stepY)/2)/rdy
 end
 if perp<0.01 then perp=0.01 end
 zbuf[col+1]=perp
 local hgt=136/perp
 local y0=hor-hgt/2 local y1=hor+hgt/2
 if y0<0 then y0=0 end
 if y1>136 then y1=136 end
 local tex
 if cell==DOORC then tex=TEX.wall[DOORC]
 else tex=TEX.wall[cell] or TEX.wall[CONCR] end
 local twx=wallx
 if cell>=1 and cell<=4 then
 if side==0 then twx=py+perp*rdy else twx=px+perp*rdx end
 twx=twx-math.floor(twx)
 if side==0 and rdx>0 then twx=1-twx end
 if side==1 and rdy<0 then twx=1-twx end
 end
 local txi=math.floor(twx*32)&31
 local l=3.3*math.exp(-perp*0.1)+mz*math.exp(-perp*0.2)
 if side==1 then l=l*0.66 end
 if l>2.98 then l=2.98 elseif l<0 then l=0 end
 local li=math.floor(l) local fr=l-li
 local txstep=32/hgt
 local texPos=(y0-(hor-hgt/2))*txstep
 local x0=col*2
 for y=math.floor(y0),math.floor(y1)-1 do
 local tyi=math.floor(texPos)&31
 texPos=texPos+txstep
 local c=tex[tyi*32+txi+1]
 local th=BAY[((y&3)<<2)|((x0)&3)]/16
 local lvl=li+(fr>th and 1 or 0)
 if lvl>2 then lvl=2 elseif lvl<0 then lvl=0 end
 local map_=LAPA[c]
 local cc=map_[lvl+1]
 local ad=y*240+x0
 poke4(ad,cc) poke4(ad+1,cc)
 end
 end
 local ents=collectSprites(m)
 local invDet=1/(plX*dirY-dirX*plY)
 for i=1,#ents do
 local s=ents[i]
 drawSprite3D(s,invDet,dirX,dirY,plX,plY,px,py,hor,mz)
 end
 drawFX3D(invDet,dirX,dirY,plX,plY,px,py,hor)
end
function moving(m) return G.moveFlags and (G.moveFlags.f or G.moveFlags.s) end
function collectSprites(m)
 local list={}
 for _,e in ipairs(G.enemies) do
 if not e.alive then
 list[#list+1]={x=e.x,y=e.y,spr=SPR.edead,h=0.22,dim=true}
 elseif e.alive then
 local spr
 if e.stun>0 then spr=SPR.ew1
 elseif e.state==2 then spr=SPR.eaim
 elseif math.floor(G.frame/14)%2==0 then spr=SPR.ew0
 else spr=SPR.ew1 end
 list[#list+1]={x=e.x,y=e.y,spr=spr,h=0.72}
 end
 end
 for _,h in ipairs(G.hostages) do
 list[#list+1]={x=h.x,y=h.y,spr=SPR.host,h=0.45}
 end
 for _,b in ipairs(G.bombs) do
 list[#list+1]={x=b.x,y=b.y,spr=SPR.bomb,h=0.4,
 dim=b.def}
 end
 for _,mm in ipairs(G.members) do
 if mm.alive and mm~=m then
 local spr
 if math.floor(G.frame/14)%2==0 then spr=SPR.tw0 else spr=SPR.tw1 end
 list[#list+1]={x=mm.x,y=mm.y,spr=spr,h=0.72,team=mm.team+1}
 end
 end
 if G.flash then
 list[#list+1]={x=G.flash.x,y=G.flash.y,spr=SPR.flash,h=0.25,bright=true}
 end
 table.sort(list,function(a,b)
 local da=(a.x-m.x)^2+(a.y-m.y)^2
 local db=(b.x-m.x)^2+(b.y-m.y)^2
 return da>db end)
 return list
end
function drawSprite3D(s,invDet,dirX,dirY,plX,plY,px,py,hor,mz)
 local zbuf=G.zbuf
 local relX,relY=s.x-px,s.y-py
 local tz=invDet*(-plY*relX+plX*relY)
 if tz<0.12 or tz>26 then return end
 local tx=invDet*(dirY*relX-dirX*relY)
 local sx=60*(1+tx/tz)
 local hs=(136/tz)*s.h
 local ws=hs*s.spr.w/s.spr.h
 local feetY=hor+68/tz
 local y1=feetY
 local y0=feetY-hs
 if y1<0 or y0>136 then return end
 local x0=sx-ws/2 local x1=sx+ws/2
 if s.shadow~=false then
 for col=math.floor(x0+ws*0.2),math.floor(x1-ws*0.2) do
 if col>=0 and col<120 and zbuf[col+1]>tz then
 local sy=math.floor(feetY)
 for dy=0,1 do
 local yy=sy+dy
 if yy>=0 and yy<136 then
 poke4(yy*240+col*2,0) poke4(yy*240+col*2+1,0)
 end
 end
 end
 end
 end
 local l=3.3*math.exp(-tz*0.1)+mz*math.exp(-tz*0.2)
 if s.dim then l=l*0.5 end
 if s.bright then l=l+1.2 end
 if l>2.98 then l=2.98 elseif l<0 then l=0 end
 local li=math.floor(l) local fr=l-li
 local spr=s.spr
 for col=math.floor(x0),math.floor(x1) do
 if col>=0 and col<120 and zbuf[col+1]>tz then
 local u=math.floor((col-x0)/ws*spr.w)
 if u>=0 and u<spr.w then
 for yy=math.floor(y0),math.floor(y1) do
 if yy>=0 and yy<136 then
 local v=math.floor((yy-y0)/hs*spr.h)+1
 local c=spr.px[v] and spr.px[v][u+1] or -1
 if c and c>=0 then
 local th=BAY[((yy&3)<<2)|((col*2)&3)]/16
 local lvl=li+(fr>th and 1 or 0)
 if lvl>2 then lvl=2 elseif lvl<0 then lvl=0 end
 local map_=LAPA[c]
 local cc=map_[lvl+1]
 poke4(yy*240+col*2,cc)
 poke4(yy*240+col*2+1,cc)
 end
 end
 end
 end
 end
 end
end
function projPt(x,y,z,invDet,dirX,dirY,plX,plY,px,py,hor)
 local relX,relY=x-px,y-py
 local tz=invDet*(-plY*relX+plX*relY)
 if tz<0.12 then return nil end
 local tx=invDet*(dirY*relX-dirX*relY)
 local sx=120*(1+tx/tz)
 local sy=hor+(136/tz)*(0.5-z)
 return sx,sy,tz
end
function drawFX3D(invDet,dirX,dirY,plX,plY,px,py,hor)
 for _,p in ipairs(G.parts) do
 local sx,sy,tz=projPt(p.x,p.y,0.3,invDet,dirX,dirY,plX,plY,px,py,hor)
 if sx then
 local col=math.floor(sx/2)
 if col>=0 and col<120 and G.zbuf[col+1]>tz then
 pix(sx,sy,p.c) pix(sx+1,sy,p.c)
 end
 end
 end
 for _,s in ipairs(G.sparks) do
 local sx,sy,tz=projPt(s.x,s.y,0.5,invDet,dirX,dirY,plX,plY,px,py,hor)
 if sx then
 local col=math.floor(sx/2)
 if col>=0 and col<120 and G.zbuf[col+1]>tz then
 pix(sx,sy,s.c) pix(sx+1,sy+1,s.c) pix(sx,sy+1,s.c)
 end
 end
 end
 for _,tr in ipairs(G.tracers) do
 local x0,y0=projPt(tr.x0,tr.y0,0.45,invDet,dirX,dirY,plX,plY,px,py,hor)
 local x1,y1=projPt(tr.x1,tr.y1,0.45,invDet,dirX,dirY,plX,plY,px,py,hor)
 if x0 and x1 then line(x0,y0,x1,y1,tr.c) end
 end
 for _,h in ipairs(G.hostages) do
 if h.sec then
 local sx,sy,tz=projPt(h.x,h.y,0.1,invDet,dirX,dirY,plX,plY,px,py,hor)
 if sx then
 local col=math.floor(sx/2)
 if col>=0 and col<120 and G.zbuf[col+1]>tz then
 pix(sx,sy,14) pix(sx+1,sy,13)
 end
 end
 end
 end
end
function drawWeapon(m)
 local rec=m.rec or 0
 local ox=math.floor(rec*2)
 local oy=math.floor(rec*3)
 rect(150+ox,90+oy,80,50,0)
 rect(158+ox,92+oy,42,12,11)
 rect(158+ox,92+oy,42,2,12)
 rect(158+ox,104+oy,42,3,10)
 rect(184+ox,94+oy,38,6,8)
 rect(184+ox,94+oy,38,1,9)
 rect(198+ox,100+oy,10,7,1)
 rect(162+ox,104+oy,10,20,1)
 rect(178+ox,104+oy,9,16,8)
 rect(170+ox,102+oy,18,9,12)
 rect(170+ox,102+oy,18,2,15)
 if m.reload>0 then
 local p=1-m.reload/1.2
 rectb(184+ox,84+oy,24,4,15)
 rect(184+ox,84+oy,math.floor(24*p),4,14)
 end
 if m.flash>0 then circ(232,124,3,14) end
end
function hudAction(m)
 local sp=2+math.floor((m.rec or 0)*2)
 local cx,cy=120,68
 line(cx-sp-4,cy,cx-sp,cy,15) line(cx+sp,cy,cx+sp+4,cy,15)
 line(cx,cy-sp-4,cx,cy-sp,15) line(cx,cy+sp,cx,cy+sp+4,15)
 local hp=m.hp
 local hc=14
 if hp<40 then hc=6 end
 if hp<20 then hc=4 end
 rectb(4,4,52,8,1)
 rect(5,5,math.max(0,math.floor(hp/2)),6,hc)
 print(m.name,4,14,15,false,1,true)
 print('KP-90 '..m.ammo..'-30',168,4,15,false,1,true)
 if m.reload>0 then print('LATAA..',168,12,14,false,1,true) end
 local gx=4
 for i=1,3 do
 local lab=string.char(64+i)
 local col=2
 if G.go[i] then col=14 else col=15 end
 print('G'..lab,gx,126,col,false,1,true)
 gx=gx+18
 end
 local yy=24
 for i,mm in ipairs(G.members) do
 local col=8
 if mm==m then col=15 end
 if not mm.alive then col=4 end
 local hpp=math.max(0,math.floor(mm.hp/20))
 local bar=string.rep('|',hpp)..string.rep('.',5-hpp)
 print((mm==m and '>' or ' ')..mm.name..' '..bar,4,yy,col,false,1,true)
 yy=yy+8
 end
 if G.msg and G.msg.t>0 then
 local tw=#G.msg.txt*4
 local x=math.max(2,math.floor((240-tw)/2))
 print(G.msg.txt,x,120,15,false,1,true)
 end
 local ot=objText()
 local oy=100
 for i,t in ipairs(ot) do
 print(t,4,oy,11,false,1,true) oy=oy+7
 end
 if G.objReady then
 print('POISTUMINEN: X',4,oy,14,false,1,true)
 end
 local tgt=nil local bd=14
 for _,e in ipairs(G.enemies) do
 if e.alive then
 local dd=math.sqrt((e.x-m.x)^2+(e.y-m.y)^2)
 if dd<bd and los(m.x,m.y,e.x,e.y) then bd=dd tgt=e end
 end
 end
 if tgt then
 print('KOHDE',212,40,4,false,1,true)
 end
end
function drawMinimap(m,ox,oy,scale,blueprint)
 local mw=MW*scale local mh=MH*scale
 if blueprint then
 rect(ox-2,oy-2,mw+4,mh+4,0)
 rect(ox-1,oy-1,mw+2,mh+2,7)
 else
 rect(ox-1,oy-1,mw+2,mh+2,1)
 end
 for y=0,MH-1 do
 for x=0,MW-1 do
 local c=G.map.cells[idx(x,y)]
 local col
 if c==0 then
 if blueprint then col=0 else
 local f=G.map.floors[idx(x,y)]
 col=(f==99)and 13 or 1
 end
 elseif c==DOORC then
 local d=G.map.doors[idx(x,y)]
 col=d.o>0.5 and 3 or 14
 else
 col=blueprint and 9 or 2
 if c==METAL then col=blueprint and 9 or 8 end
 if c==BRICK then col=blueprint and 9 or 5 end
 if c==WOOD then col=blueprint and 9 or 11 end
 end
 rect(ox+x*scale,oy+y*scale,scale,scale,col)
 end
 end
 for _,e in ipairs(G.map.exits) do
 rect(ox+e[1]*scale,oy+e[2]*scale,scale,scale,14)
 end
 for _,h in ipairs(G.hostages) do
 print('H',ox+h.x*scale,oy+h.y*scale-6,15,false,1,true)
 end
 for _,b in ipairs(G.bombs) do
 print('P',ox+b.x*scale,oy+b.y*scale-6,6,false,1,true)
 end
 for _,e in ipairs(G.enemies) do
 if e.alive and e.seen then
 rect(ox+math.floor(e.x)*scale,oy+math.floor(e.y)*scale,scale,scale,4)
 end
 end
 for i,mm in ipairs(G.members) do
 if mm.alive then
 local col=15
 if i==G.player then col=14 end
 circ(ox+mm.x*scale,oy+mm.y*scale,scale,15)
 if i==G.player then pix(ox+mm.x*scale,oy+mm.y*scale,14) end
 end
 end
end
function drawBigMap(m)
 cls(0)
 print('TAKTINEN KARTTA  (M: palaa)',4,4,15,false,1,true)
 local scale=3.6
 drawMinimap(m,18,20,scale,false)
 for t=0,1 do
 local plan=G.plan[t+1]
 local col=t==0 and 14 or 3
 local s=plan.start
 circ(18+s[1]*scale+1,20+s[2]*scale+1,2,col)
 local px,py=18+s[1]*scale+1,20+s[2]*scale+1
 for _,w in ipairs(plan.wps) do
 local wx,wy=18+w[1]*scale+1,20+w[2]*scale+1
 line(px,py,wx,wy,col)
 pix(wx,wy,col) pix(wx+1,wy,col) pix(wx,wy+1,col)
 if w.go and w.go>0 then
 print(string.char(64+w.go),wx+3,wy-3,15,false,1,true)
 end
 px,py=wx,wy
 end
 end
end
PLAN_SCALE=3.2
function initPlanState()
 G.planSel=0
 G.planMsg='Hiiri=piste Q=ryhma 1-3=koodi OIK=poista ENTER=aloita'
end
function planPhase()
 local md=G.md
 local scale=PLAN_SCALE
 local ox,oy=6,24
 local mx,my,l,_m,r=mouse()
 mx=mx or 0 my=my or 0
 local cx,cy=math.floor((mx-ox)/scale),math.floor((my-oy)/scale)
 local onMap=cx>=0 and cy>=0 and cx<MW and cy<MH
 cls(0)
 for y=0,MH do line(ox,oy+y*scale,ox+MW*scale,oy+y*scale,1) end
 for x=0,MW do line(ox+x*scale,oy,ox+x*scale,oy+MH*scale,1) end
 drawMinimap(nil,ox,oy,scale,true)
 print('SUUNNITTELU: '..md.name,4,4,15,false,1,true)
 print(md.loc,4,12,11,false,1,true)
 print('VIH:'..#G.enemies..'?',206,4,4,false,1,true)
 local teamName=G.planSel==0 and 'RYHMA SUSI' or 'RYHMA KARHU'
 print('RYHMA:',118,26,11,false,1,true)
 print(teamName,118,34,G.planSel==0 and 14 or 9,false,1,true)
 print('(Q vaihtaa)',118,42,2,false,1,true)
 print('OHJE:',118,56,11,false,1,true)
 print('klik = reittipiste',118,64,15,false,1,true)
 print('oik klik = poista',118,72,15,false,1,true)
 print('1-3 = gokoodi',118,80,15,false,1,true)
 print('shift+klik = alku',118,88,15,false,1,true)
 print('ENTER = hyokkays',118,96,14,false,1,true)
 print('TAUKO = ESC',118,110,2,false,1,true)
 print(G.planMsg,4,129,11,false,1,true)
 for t=0,1 do
 local plan=G.plan[t+1]
 local col=(t==G.planSel) and (t==0 and 14 or 3) or 2
 local s=plan.start
 local sx,sy=ox+s[1]*scale+1,oy+s[2]*scale+1
 circ(sx,sy,3,col)
 print(t==0 and 'S' or 'K',sx+4,sy-5,col,false,1,true)
 local px,py=sx,sy
 for wi,w in ipairs(plan.wps) do
 local wx,wy=ox+w[1]*scale+1,oy+w[2]*scale+1
 line(px,py,wx,wy,col)
 circb(wx,wy,2,col)
 pix(wx,wy,col)
 print(tostring(wi),wx+3,wy-3,11,false,1,true)
 if w.go and w.go>0 then
 print(string.char(64+w.go),wx-4,wy+3,15,false,1,true)
 end
 px,py=wx,wy
 end
 end
 if onMap then
 rectb(ox+cx*scale,oy+cy*scale,scale+1,scale+1,15)
 end
 if kdp(17) then G.planSel=1-G.planSel end
 local plan=G.plan[G.planSel+1]
 if onMap then
 local s=plan.start
 local nearStart=math.abs(cx-s[1])<=0 and math.abs(cy-s[2])<=0
 local clickL=G.injM1 or l
 if r or G.injM2 then
 if #plan.wps>0 then
 table.remove(plan.wps)
 end
 end
 if l or clickL then
 if cx==s[1] and cy==s[2] then
 elseif passable(cx,cy) then
 plan.wps[#plan.wps+1]={cx,cy,go=0}
 end
 end
 for i=1,3 do
 if kdp(GOKEYS[i]) then
 local hit=false
 for _,w in ipairs(plan.wps) do
 if w[1]==cx and w[2]==cy then w.go=i hit=true end
 end
 if not hit and #plan.wps>0 then
 plan.wps[#plan.wps].go=i
 end
 end
 end
 if (kd(64) or G.injShift) and (l or clickL) then
 if passable(cx,cy) then
 plan.start={cx,cy}
 end
 end
 end
 if kdp(50) or btnp(4) then
 local md2=G.md
 loadMission(md2,G.plan)
 G.phase=S_ACTION
 msg('TOIMINTA ALKAA - GOKOODIT: 1 2 3',3)
 end
end
function initAction()
 G.zbuf={}
 for i=1,120 do G.zbuf[i]=1e9 end
 G.mz=0 G.moveFlags={}
end
function actionPhase()
 local m=G.members[G.player]
 local dt=1/60
 G.frame=G.frame+1
 G.t=G.t+dt
 local f,s=false,false
 local spd=0.05
 local mvx,mvy=0,0
 if bd(0) or kd(23) then f=true mvx=mvx+1 end
 if bd(1) or kd(19) then f=true mvx=mvx-1 end
 if kd(1) then s=true mvy=mvy-1 end
 if kd(4) then s=true mvy=mvy+1 end
 if bd(2) then m.ang=m.ang-0.062 end
 if bd(3) then m.ang=m.ang+0.062 end
 local mx=mouse()
 if type(mx)=='number' then
 local off=mx-120
 if math.abs(off)>6 then m.ang=m.ang+off*0.0006 end
 end
 if m.reload>0 then
 m.reload=m.reload-dt
 if m.reload<=0 then
 if m.mag>0 then m.mag=m.mag-1 m.ammo=30 end
 m.reload=0
 end
 end
 local dx=math.cos(m.ang) local dy=math.sin(m.ang)
 local nx=(mvx*dx+mvy*-dy)*spd
 local ny=(mvx*dy+mvy*dx)*spd
 if f or s then moveEnt(m,nx,ny) end
 G.moveFlags={f=f,s=s}
 if (bd(4) or mouseBtn()) and m.reload<=0 then
 if G.frame%8==0 or m.rec<0.5 then memberFire(m) end
 if m.ammo<=0 and m.mag>0 then m.reload=1.2 msg('LIPAS VAIHTO',1) SND(5,60,8,4,2) end
 end
 m.rec=math.max(0,m.rec-0.15)
 if G.mz>0 then G.mz=G.mz-0.15 end
 if G.stats.shots>G.stats.hits+G.stats.kills then end
 if m.hp<100 and G.frame%180==0 then m.hp=math.min(100,m.hp+1) end
 if kdp(18) and m.reload<=0 and m.ammo<30 and m.mag>0 then
 m.reload=1.2 msg('LADATAAN..',1)
 end
 if kdp(6) and m.flash>0 and not G.flash then
 m.flash=m.flash-1
 G.flash={x=m.x+dx*0.6,y=m.y+dy*0.6,vx=dx*0.09,vy=dy*0.09,t=0.9}
 msg('VALOKRANAATTO HEITETTY',1.5) SND(5,60,8,4,2)
 end
 if kdp(49) then autoSwitch() end
 for i=1,3 do
 if kdp(GOKEYS[i]) and not G.go[i] then
 G.go[i]=true
 msg('GOKOODI '..string.char(64+i)..' LAUKAISTI',2.5) SND(3,74,9,8,3)
 end
 end
 local didAct=false
 local cx,cy=math.floor(m.x+dx*0.8),math.floor(m.y+dy*0.8)
 if cellAt(cx,cy)==DOORC and kdp(5) then
 toggleDoor(cx,cy) SND(2,50,8,6,2) didAct=true
 end
 for _,h in ipairs(G.hostages) do
 if not h.sec then
 local dd=math.sqrt((h.x-m.x)^2+(h.y-m.y)^2)
 if dd<1.1 then
 if kdp(5) then h.sec=true msg('PANTTIVANKI VARMA!',2) didAct=true end
 end
 end
 end
 for _,b in ipairs(G.bombs) do
 if not b.def then
 local dd=math.sqrt((b.x-m.x)^2+(b.y-m.y)^2)
 if dd<1.1 then
 if kd(5) then
 b.prog=b.prog+dt
 if b.prog>=2 then b.def=true msg('POMMI PURKETTU!',2) end
 else b.prog=math.max(0,b.prog-dt) end
 end
 end
 end
 updateDoors()
 for i,mm in ipairs(G.members) do
 if mm.alive and i~=G.player then
 memberAI(mm,G.plan[mm.team+1])
 end
 end
 for _,e in ipairs(G.enemies) do enemyAI(e) end
 if G.flash then
 local fl=G.flash
 fl.x=fl.x+fl.vx fl.y=fl.y+fl.vy
 fl.vx=fl.vx*0.97 fl.vy=fl.vy*0.97
 if not passable(math.floor(fl.x),math.floor(fl.y)) then
 fl.vx=-fl.vx*0.4 fl.vy=-fl.vy*0.4
 end
 fl.t=fl.t-dt
 if fl.t<=0 then
 for _,e in ipairs(G.enemies) do
 if e.alive then
 local dd=math.sqrt((e.x-fl.x)^2+(e.y-fl.y)^2)
 if dd<6 and los(fl.x,fl.y,e.x,e.y) then
 e.stun=4.5 e.state=1 e.lx=fl.x e.ly=fl.y e.path=nil
 end
 end
 end
 G.mz=1.2
 msg('BANG!',1) SND(4,38,12,16,0)
 G.flash=nil
 end
 end
 for i=#G.parts,1,-1 do
 local p=G.parts[i]
 p.x=p.x+p.vx p.y=p.y+p.vy p.t=p.t-dt
 if p.t<=0 then table.remove(G.parts,i) end
 end
 for i=#G.sparks,1,-1 do
 local s=G.sparks[i] s.t=s.t-dt
 if s.t<=0 then table.remove(G.sparks,i) end
 end
 for i=#G.tracers,1,-1 do
 local t=G.tracers[i] t.t=t.t-dt
 if t.t<=0 then table.remove(G.tracers,i) end
 end
 if G.msg then G.msg.t=G.msg.t-dt if G.msg.t<=0 then G.msg=nil end end
 checkObjectives()
 if not anyAlive() then
 G.failed=true G.phase=S_DEBRIEF return
 end
 if G.objReady then
 for i,mm in ipairs(G.members) do
 if mm.alive and atExit(mm) then
 G.done=true G.phase=S_DEBRIEF return
 end
 end
 end
 render3D(m)
 if not G.nogun then drawWeapon(m) end
 hudAction(m)
 for _,b in ipairs(G.bombs) do
 if b.prog>0 and b.prog<2 then
 print('PURKAA '..string.rep('.',math.floor((G.frame/12)%4)),90,90,14,false,1,true)
 end
 end
 if kd(13) then drawBigMap(m) end
end
function mouseBtn()
 local _,_,l=mouse()
 return l
end
ED={cells={},objs={},brush=CONCR,tool=0,obj='kill'}
function edInit()
 if not ED.init then
 for i=1,MW*MH do ED.cells[i]=CONCR end
 for y=14,19 do for x=14,19 do ED.cells[idx(x,y)]=0 end end
 ED.init=true
 end
end
function edClear()
 for i=1,MW*MH do ED.cells[i]=CONCR end
 ED.objs={}
 msg('KARTTA TYHJENNETTY',2)
end
function edCellsToMap()
 local rows={}
 for y=1,30 do
 local s=''
 for x=1,30 do
 local c=ED.cells[idx(x,y)]
 if c==0 then
 local fl=(ED.floors and ED.floors[idx(x,y)]) or 1
 s=s..(fl==2 and ',' or '.')
 elseif c==BRICK then s=s..'#'
 elseif c==CONCR then s=s..'='
 elseif c==METAL then s=s..'M'
 elseif c==WOOD then s=s..'W'
 elseif c==DOORC then s=s..'D'
 else s=s..'=' end
 end
 rows[y]=s
 end
 local enemies={} local hostages={} local bombs={} local exits={}
 local sp1 local sp2
 for _,o in ipairs(ED.objs) do
 if o.t==1 then enemies[#enemies+1]={o.x,o.y}
 elseif o.t==2 then hostages[#hostages+1]={o.x,o.y}
 elseif o.t==3 then bombs[#bombs+1]={o.x,o.y}
 elseif o.t==4 then exits[#exits+1]={o.x,o.y}
 elseif o.t==5 then sp1={o.x,o.y}
 elseif o.t==6 then sp2={o.x,o.y} end
 end
 return {name='OP.EDIT',loc='OMA KENTTA',obj=ED.obj,
 brief='Itse tehty kentta. Tarkista spawnit ja poistuminen!',
 m=rows,enemies=enemies,hostages=hostages,bombs=bombs,exits=exits,
 sp1=sp1 or {2,2},sp2=sp2 or sp1 or {2,2}}
end
function edValidate(md)
 local seen={}
 local stack={{md.sp1[1],md.sp1[2]}}
 while #stack>0 do
 local p=table.remove(stack)
 local x,y=p[1],p[2]
 local k=x..','..y
 if not seen[k] and x>=1 and y>=1 and x<=30 and y<=30 then
 local c=md.m[y]:sub(x,x)
 if c=='.'or c==',' or c=='D' then
 seen[k]=true
 stack[#stack+1]={x+1,y} stack[#stack+1]={x-1,y}
 stack[#stack+1]={x,y+1} stack[#stack+1]={x,y-1}
 end
 end
 end
 local function okf(p) return seen[p[1]..','..p[2]] end
 if not okf(md.sp1) then return 'SPAWN 1 ei lattialla!' end
 if not okf(md.sp2) then return 'SPAWN 2 ei lattialla!' end
 if #md.exits==0 then return 'Aseta POISTUMINEN (X)!' end
 for _,e in ipairs(md.exits) do if not okf(e) then return 'Poistuminen eristyksissa!' end end
 for _,e in ipairs(md.enemies) do if not okf(e) then return 'Vihollinen eristyksissa!' end end
 for _,h in ipairs(md.hostages) do if not okf(h) then return 'Panttivanki eristyksissa!' end end
 for _,b in ipairs(md.bombs) do if not okf(b) then return 'Pommi eristyksissa!' end end
 if md.obj=='kill' and #md.enemies==0 then return 'Aseta vihollisia (E)!' end
 if (md.obj=='rescue' or md.obj=='killrescue') and #md.hostages==0 then
 return 'Aseta panttivanki (H)!' end
 if (md.obj=='defuse' or md.obj=='defusekill') and #md.bombs==0 then
 return 'Aseta pommi (B)!' end
 return nil
end
function editorPhase()
 local scale=3.4 local ox,oy=6,6
 local mx,my,l,_mm,r=mouse()
 mx=mx or 0 my=my or 0
 local cx,cy=math.floor((mx-ox)/scale),math.floor((my-oy)/scale)
 local onMap=cx>=1 and cy>=1 and cx<=30 and cy<=30
 cls(0)
 for y=0,31 do line(ox,oy+y*scale,ox+32*scale,oy+y*scale,1) end
 for x=0,31 do line(ox+x*scale,oy,ox+x*scale,oy+32*scale,1) end
 for y=1,30 do
 for x=1,30 do
 local c=ED.cells[idx(x,y)]
 local col
 if c==0 then
 local f=(ED.floors and ED.floors[idx(x,y)]) or 1
 col=f==2 and 10 or 1
 elseif c==DOORC then col=14
 elseif c==BRICK then col=5
 elseif c==METAL then col=9
 elseif c==WOOD then col=11
 else col=2 end
 rect(ox+x*scale,oy+y*scale,scale,scale,col)
 end
 end
 local LAB={['1']='E',['2']='H',['3']='P',['4']='X',['5']='1',['6']='2'}
 local OCOL={[1]=4,[2]=15,[3]=6,[4]=14,[5]=14,[6]=9}
 for _,o in ipairs(ED.objs) do
 rectb(ox+o.x*scale,oy+o.y*scale,scale+1,scale+1,15)
 print(LAB[tostring(o.t)],ox+o.x*scale+1,oy+o.y*scale-5,OCOL[o.t],false,1,true)
 end
 if onMap then rectb(ox+cx*scale,oy+cy*scale,scale+1,scale+1,15) end
 local sx=118
 print('EDITORI',sx,8,15,false,1,true)
 local by=18
 local help={
 '1 tiili 2 betoni 3 metal',
 '4 puu 5 lattia 6 ovi',
 'E vihol H vanki B pommi',
 'X poist I sp1 J sp2',
 'G generoi N tyhjaa',
 'S tallenna L lataa',
 'T testaa O tavoite',
 'hiiri v=maali o=poista',
 }
 for i,h in ipairs(help) do
 print(h,sx,by,i<=5 and 14 or (i<=9 and 15 or 11),false,1,true)
 by=by+8
 end
 print('TAVOITE:',sx,by+4,11,false,1,true)
 print(ED.obj,sx,by+12,14,false,1,true)
 if kdp(28) then ED.brush=BRICK ED.tool=0 end
 if kdp(29) then ED.brush=CONCR ED.tool=0 end
 if kdp(30) then ED.brush=METAL ED.tool=0 end
 if kdp(31) then ED.brush=WOOD ED.tool=0 end
 if kdp(32) then ED.brush=0 ED.tool=0 end
 if kdp(33) then ED.brush=DOORC ED.tool=0 end
 if kdp(5) then ED.tool=1 end
 if kdp(8) then ED.tool=2 end
 if kdp(2) then ED.tool=3 end
 if kdp(24) then ED.tool=4 end
 if kdp(9) then ED.tool=5 end
 if kdp(10) then ED.tool=6 end
 if onMap then
 if ED.tool>0 then
 if l or G.injM1 then
 local t=ED.tool
 if t==5 or t==6 then
 for i=#ED.objs,1,-1 do
 if ED.objs[i].t==t then table.remove(ED.objs,i) end
 end
 end
 for i=#ED.objs,1,-1 do
 if ED.objs[i].x==cx and ED.objs[i].y==cy and ED.objs[i].t==t then
 table.remove(ED.objs,i)
 end
 end
 ED.objs[#ED.objs+1]={t=t,x=cx,y=cy}
 end
 else
 if l or G.injM1 then
 if ED.brush==0 then
 if ED.cells[idx(cx,cy)]==0 then
 ED.floors=ED.floors or {}
 ED.floors[idx(cx,cy)]=(ED.floors[idx(cx,cy)]==2) and 1 or 2
 end
 else
 ED.cells[idx(cx,cy)]=ED.brush
 end
 end
 if r or G.injM2 then
 ED.cells[idx(cx,cy)]=0
 for i=#ED.objs,1,-1 do
 if ED.objs[i].x==cx and ED.objs[i].y==cy then table.remove(ED.objs,i) end
 end
 end
 end
 end
 if kdp(7) then
 local objs={'kill','rescue','defuse','killrescue','defusekill'}
 local md=genProcMap(math.random(99999),objs[math.random(#objs)])
 if md then
 for y=1,30 do for x=1,30 do
 local ch=md.m[y]:sub(x,x)
 ED.cells[idx(x,y)]=CH2W[ch] or 0
 ED.floors=ED.floors or {}
 ED.floors[idx(x,y)]=CH2F[ch] or 1
 end end
 ED.objs={}
 for _,e in ipairs(md.enemies) do ED.objs[#ED.objs+1]={t=1,x=e[1],y=e[2]} end
 for _,h in ipairs(md.hostages) do ED.objs[#ED.objs+1]={t=2,x=h[1],y=h[2]} end
 for _,b in ipairs(md.bombs) do ED.objs[#ED.objs+1]={t=3,x=b[1],y=b[2]} end
 for _,e in ipairs(md.exits) do ED.objs[#ED.objs+1]={t=4,x=e[1],y=e[2]} end
 ED.objs[#ED.objs+1]={t=5,x=md.sp1[1],y=md.sp1[2]}
 ED.objs[#ED.objs+1]={t=6,x=md.sp2[1],y=md.sp2[2]}
 ED.obj=md.obj
 msg('KENTTA GENEROITU',2)
 end
 end
 if kdp(14) then edClear() end
 if kdp(19) then pmSaveEditor(ED) msg('TALLENNETTU PMEM:IN',2) end
 if kdp(12) then
 if pmLoadEditor(ED) then msg('KARTTA LADATTU',2)
 else msg('EI TALLENNETTUA KARTTAA',2) end
 end
 if kdp(15) then
 local objs={'kill','rescue','defuse','killrescue','defusekill'}
 local n=1
 for i,o in ipairs(objs) do if o==ED.obj then n=i end end
 ED.obj=objs[(n%#objs)+1]
 end
 if kdp(20) then
 local md=edCellsToMap()
 local err=edValidate(md)
 if err then msg(err,3)
 else
 G.edmd=md
 loadMission(md)
 initPlanState()
 G.phase=S_PLAN
 G.fromEditor=true
 end
 end
end
function titlePhase()
 cls(0)
 local t=G.frame
 for i=0,20 do
 local y=(t*0.2+i*7)%136
 line(0,y,239,y,1)
 end
 print('KARHURYHMA',33,30,15,false,3)
 print('KARHURYHMA',34,31,2,false,3)
 print('TAKTINEN ERIKOISYKSIKO',42,62,11,false,1,true)
 print('v1.0  TIC-80',170,126,2,false,1,true)
 local items={'TEHTAVAT','HARJOITUS (SATUNNAINEN)','EDITORI','OHJEET'}
 local sel=G.menuSel or 1
 for i,it in ipairs(items) do
 local col=i==sel and 14 or 11
 print((i==sel and '> ' or '  ')..it,72,78+i*12,col)
 end
 if btnp(2) or kdp(60) then G.menuSel=((sel-2)%#items)+1 end
 if btnp(3) or kdp(61) then G.menuSel=(sel%#items)+1 end
 if btnp(4) or kdp(50) then
 if sel==1 then G.phase=S_MENU G.msel=1
 elseif sel==2 then
 local objs={'kill','rescue','defuse','killrescue','defusekill'}
 local md=genProcMap(math.random(99999),objs[math.random(#objs)])
 if md then
 G.procMd=md
 G.phase=S_BRIEF G.briefFrom='proc'
 end
 elseif sel==3 then G.phase=S_EDITOR edInit()
 else G.phase=S_BRIEF G.briefFrom='help' end
 end
end
function menuPhase()
 cls(0)
 print('TEHTAVAT',4,4,15,false,1,true)
 local sel=G.msel or 1
 for i=1,6 do
 local md
 if i==6 then md={name='OP.TOISTO',loc='SATUNNAINEN HARJOITUS'}
 else md=MIS[i] end
 local col=i==sel and 14 or 11
 print((i==sel and '> ' or '  ')..md.name..' - '..md.loc,8,18+i*12,col,false,1,true)
 end
 print('nuolet: valitse  Z/ENTER: tiedote',4,124,11,false,1,true)
 print('ESC: takaisin',4,130,2,false,1,true)
 if btnp(2) or kdp(60) then G.msel=((sel-2)%6)+1 end
 if btnp(3) or kdp(61) then G.msel=(sel%6)+1 end
 if btnp(4) or kdp(50) then
 if sel==6 then
 local objs={'kill','rescue','defuse','killrescue','defusekill'}
 local md=genProcMap(math.random(99999),objs[math.random(#objs)])
 if md then G.procMd=md G.phase=S_BRIEF G.briefFrom='proc' end
 else
 G.phase=S_BRIEF G.briefFrom=sel
 end
 end
 if kdp(66) then G.phase=S_TITLE end
end
function briefPhase()
 cls(0)
 local md
 if G.briefFrom=='proc' then md=G.procMd
 elseif G.briefFrom=='help' then
 print('OHJEET',4,4,15,false,2)
 local lines={
 'LIIKE: nuolet/WASD  KAANTO: <- ->',
 'TULITA: Z/hiiri  TOIMINTA: E',
 'VALOKRANAATTI: F  LATAUS: R',
 'JASEN VAIHTO: TAB  GOKOODIT: 1 2 3',
 'KARTTA: M (pohjassa)  TAUKO: ESC',
 'SUUNNITTELU:',
 ' hiiri = reittipiste',
 ' Q = ryhma  1-3 = gokoodi',
 ' oikea klik = poista piste',
 ' SHIFT+klik = alkupaikka',
 ' ENTER = aloita toiminta',
 }
 for i,l in ipairs(lines) do print(l,8,26+i*10,15,false,1,true) end
 if kdp(50) or btnp(4) or kdp(66) then G.phase=S_TITLE end
 return
 end
 md=G.procMd or MIS[G.briefFrom]
 G.pendingMd=md
 print(md.name,4,4,15,false,2)
 print(md.loc,4,24,11,false,1,true)
 print('TIETOA:',4,40,14,false,1,true)
 local words={}
 for w in md.brief:gmatch('%S+') do words[#words+1]=w end
 local line='' local y=52
 for _,w in ipairs(words) do
 if #line+#w+1>44 then
 print(line,4,y,15,false,1,true) y=y+9 line=w
 else
 if line=='' then line=w else line=line..' '..w end
 end
 end
 if line~='' then print(line,4,y,15,false,1,true) y=y+9 end
 local objnames={kill='NEUTRALOI VIHOLLISET',rescue='VAPAUTA PANTTIVANKI',
 defuse='PURKA POMMIT',killrescue='TYHJENNA+VAPAUTA',
 defusekill='PURKA+TYHJENNA'}
 print('TAVOITE: '..(objnames[md.obj] or md.obj),4,y+6,14,false,1,true)
 print('RYHMA: SUSI & KARHU (2+2)',4,y+16,11,false,1,true)
 print('Z/ENTER: SUUNNITTELU  ESC: TAKAISIN',4,126,11,false,1,true)
 if kdp(50) or btnp(4) then
 local plan=G.plans and G.plans[md] or nil
 loadMission(md,plan)
 initPlanState()
 G.phase=S_PLAN
 end
 if kdp(66) then G.phase=S_MENU end
end
function debriefPhase()
 cls(0)
 if G.done then
 print('TEHTAVA ONNISTUI!',40,20,14,false,2)
 else
 print('TEHTAVA EPAONNISTUI',40,20,4,false,2)
 end
 local st=G.stats
 local mins=math.floor(G.t/60) local secs=math.floor(G.t%60)
 print('AIKA:      '..string.format('%02d:%02d',mins,secs),40,50,15,false,1,true)
 print('LAUKAUKSIA: '..st.shots,40,60,15,false,1,true)
 print('OSUMIA:    '..st.hits,40,70,15,false,1,true)
 print('NEUTRALOITU: '..st.kills,40,80,15,false,1,true)
 local alive=0
 for _,m in ipairs(G.members) do if m.alive then alive=alive+1 end end
 print('RYHMASTA ELOSSA: '..alive..'/4',40,90,15,false,1,true)
 print('R: YRITA UUDELLEEN (SUUNNITTELU)',40,108,11,false,1,true)
 print('ENTER: VALIKKOON',40,118,11,false,1,true)
 if kdp(18) then
 loadMission(G.md,G.plan)
 initPlanState()
 G.phase=S_PLAN
 end
 if kdp(50) then
 G.phase=G.fromEditor and S_EDITOR or S_MENU
 G.fromEditor=false
 end
end
function setPalette()
 for i,c in ipairs(PAL) do
 poke(0x3FC0+(i-1)*3,c[1],c[2],c[3])
 end
end
function BOOT()
 setPalette()
 genTextures()
 genSprites()
 G.phase=S_TITLE
 G.menuSel=1
 G.msel=1
 G.frame=0
 G.zbuf={}
 for i=1,120 do G.zbuf[i]=1e9 end
 edInit()
end
function SND(id,note,vol,dur,ch)
 pcall(sfx,id,note or 55,dur or 4,ch or 0,vol or 10,-1)
end
function sfxShot() SND(0,55,10,4,0) end
function TIC()
 G.frame=G.frame+1
 local ph=G.phase
 if ph==S_TITLE then titlePhase()
 elseif ph==S_MENU then menuPhase()
 elseif ph==S_BRIEF then briefPhase()
 elseif ph==S_PLAN then planPhase()
 elseif ph==S_ACTION then actionPhase()
 elseif ph==S_DEBRIEF then debriefPhase()
 elseif ph==S_EDITOR then editorPhase()
 end
end
function MENU()
 if G.phase==S_ACTION or G.phase==S_PLAN then
 cls(0)
 print('TAUKO',100,50,15,false,2)
 print('ESC: jatka tehtavaa',70,80,11,false,1,true)
 print('(tehtava jatkuu mista jait)',64,92,2,false,1,true)
 end
end
