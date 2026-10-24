-- title:  BARE-KNUCKLE
-- author: ville5ust + cline
-- desc:   brutal bare-knuckle boxing manager (audited M1-M4 slice)
-- script: lua

-- BARE-KNUCKLE (c) pulp fiction. 33-mechanic plan: docs/MASTER_PLAN.md
-- M1 walking skeleton + M2 roster + M3 economy + M4 fight sim.

-- ================= CONFIG =================
MAGIC=1196247874 -- "BKMG"
VERSION=1
ROUNDS_MAX=8
CROWD_MAX=100
-- sweetie-16 palette roles
C_BG=0 C_DK=15 C_TXT=12 C_DIM=14 C_BLOOD=2 C_DRIED=1 C_BRUISE=1
C_SKIN=4 C_SKIN2=3 C_BONE=12 C_OK=6 C_WARN=3 C_GOLD=4

-- ================= STATE =================
G=nil -- game root
F=nil -- active fight
SHK=0 FLASH=0
PARTS={}
TITLE_T=0

-- ================= HELPERS =================
function clamp(v,a,b) if v<a then return a end if v>b then return b end return v end
function rrange(a,b) return a+math.random(b-a+1) end
function wpick(t,n)
 local wsum=0
 for i=1,#t do wsum=wsum+t[i][2] end
 local r=math.random(wsum)
 for i=1,#t do r=r-t[i][2] if r<=0 then return t[i][1] end end
 return t[#t][1]
end

-- wound states: 0-3 HEALTHY 4-7 BRUISED 8-11 CUT 12-16 FRACTURED 17-20 DOWN
function wstate(p)
 if p>=17 then return "DOWN" end
 if p>=12 then return "FRACT" end
 if p>=8 then return "CUT" end
 if p>=4 then return "BRUISE" end
 return "OK"
end
WSTATE_COL={"OK","BRUISE","CUT","FRACT","DOWN"}
function wstateidx(p)
 if p>=17 then return 5 elseif p>=12 then return 4 elseif p>=8 then return 3
 elseif p>=4 then return 2 end
 return 1
end

-- ================= NAMES =================
FIRST={"Mickey","Rocco","Eddie","Sal","Bunny","Lou","Vinny","Paddy","Gus","Tiny","Dutch","Moe","Iggy","Bones","Knuckles"}
NICK={"Iron","Butcher","Glass","Mad","Kid","Lucky","Bloody","Stone","Candy","Southpaw"}
SUR={"Malone","Doyle","Kowalski","Bianchi","O'Rourke","Petrov","Vasquez","Gruber","Cahill","Marsh","Kowalczyk","Dujardin"}
function genname()
 local n=FIRST[math.random(#FIRST)]
 if math.random(3)>1 then n=n.." '"..NICK[math.random(#NICK)].."'" end
 n=n.." "..SUR[math.random(#SUR)]
 if #n>14 then n=string.sub(n,1,14) end
 return n
end

-- name packing: 14 chars -> 4 pmem words (4 chars each)
function packname(s,w0)
 for w=0,3 do
  local v=0
  for k=0,3 do
   local c=string.byte(s,w*4+k+1) or 32
   if c>127 then c=63 end
   v=v+c*(256^k)
  end
  pmem(w0+w,v)
 end
end
function unpackname(w0)
 local s=""
 for w=0,3 do
  local v=pmem(w0+w)
  for k=0,3 do
   local c=(v//(256^k))%256
   if c~=32 then s=s..string.char(c) end
  end
 end
 return string.sub(s,1,14)
end

-- ================= FIGHTERS =================
function newfighter(q)
 local f={}
 f.name=genname()
 f.pow=clamp(2+rrange(1,q),1,9)
 f.tgh=clamp(2+rrange(1,q),1,9)
 f.sta=clamp(3+rrange(0,q),1,9)
 f.spd=clamp(2+rrange(1,q),1,9)
 f.age=18+math.random(8)
 f.career=0
 f.wound={0,0,0,0} -- head ribs hands eyes (damage pools 0-20)
 f.scar=0 -- bit0 head bit1 ribs bit2 hands bit3 eyes bit4 dead bit5 retired
 return f
end

function dead(f) return (f.scar//16)%2==1 end
function retired(f) return (f.scar//32)%2==1 end
function scarbit(f,i) return (f.scar//(2^i))%2==1 end

-- heals 1 pool point per region per call (calendar step), scars stay
function healstep(f)
 for i=1,4 do
  if f.wound[i]>0 and not scarbit(f,i-1) then f.wound[i]=f.wound[i]-1 end
 end
end

-- ================= SAVE / LOAD =================
-- words: 0 magic 1 ver 2 money 3 fight 4 heat 5 debt 6 tone 7 ngp 8 curse
-- fighters: base 9 + (i-1)*7 : name(3) stats(1) wound(1) scar(1) career(1)
function savegame()
 pmem(0,MAGIC) pmem(1,VERSION)
 pmem(2,G.money+1000000) pmem(3,G.fight) pmem(4,G.heat)
 pmem(5,G.debt+1000) pmem(6,G.tone) pmem(7,G.ngp) pmem(8,G.curse)
 for i=1,4 do
  local f=G.fighters[i]
  local b=9+(i-1)*7
  packname(f.name,b)
  pmem(b+4,f.pow+f.tgh*16+f.sta*256+f.spd*4096+f.age*65536)
  local w=0
  for k=1,4 do w=w+f.wound[k]*(32^(k-1)) end
  pmem(b+5,w)
  pmem(b+6,f.scar) pmem(b+7,f.career)
 end
end

function loadgame()
 if pmem(0)~=MAGIC or pmem(1)~=VERSION then return false end
 G={}
 G.money=pmem(2)-1000000 G.fight=pmem(3) G.heat=pmem(4)
 G.debt=pmem(5)-1000 G.tone=pmem(6) G.ngp=pmem(7) G.curse=pmem(8)
 G.fighters={}
 for i=1,4 do
  local b=9+(i-1)*7
  local f={}
  f.name=unpackname(b)
  local s=pmem(b+4)
  f.pow=s%16 f.tgh=(s//16)%16 f.sta=(s//256)%16 f.spd=(s//4096)%16 f.age=(s//65536)%64
  f.wound={}
  local w=pmem(b+5)
  for k=1,4 do f.wound[k]=(w//(32^(k-1)))%32 end
  f.scar=pmem(b+6) f.career=pmem(b+7)
  G.fighters[i]=f
 end
 G.sel=1
 return true
end

function newgame()
 G={}
 G.money=250 G.fight=1 G.heat=0 G.debt=0 G.tone=0
 G.ngp=pmem(7) or 0 G.curse=pmem(8) or 0 -- NG+ survives new game
 G.sel=1
 G.fighters={}
 for i=1,4 do G.fighters[i]=newfighter(2+G.ngp) end
end
-- ================= UI HELPERS =================
function topbar(t)
 rect(0,0,240,11,C_DK)
 print("BARE-KNUCKLE",2,2,C_GOLD)
 print(t,64,2,C_TXT)
 print("$"..G.money,196,2,G.money<0 and C_BLOOD or C_OK)
 print("F"..G.fight,168,2,C_DIM)
end

function ticker(y)
 rect(0,y,240,15,C_DK)
 print(G.bugle or "THE BRUISER BUGLE: hopes, hangovers, hook shots",4,y+3,C_DIM)
end

function uiBar(x,y,w,lab,val,mx,col)
 print(lab,x,y+1,C_DIM)
 local bw=w-30
 rect(x+26,y,bw*val//mx,5,col)
 rectb(x+26,y,bw,5,C_DK)
end

-- procedural pulp face, 16x16 at x,y (gore overlay per damage pool)
function drawFace(x,y,f)
 local head=f.wound[1]
 circ(x+8,y+9,7,C_SKIN)
 rect(x+2,y+2,12,3,C_DK) -- hair
 pix(x+5,y+8,C_DK) pix(x+11,y+8,C_DK) -- eyes
 rect(x+6,y+13,5,1,C_DK) -- mouth
 if head>=4 then pix(x+4,y+7,C_BRUISE) pix(x+12,y+10,C_BRUISE) end
 if head>=8 then rect(x+4,y+6,1,4,C_BLOOD) end
 if head>=12 then pix(x+9,y+11,C_BONE) end
 if head>=17 then rect(x+3,y+6,4,5,C_BLOOD) end
 if scarbit(f,0) then rect(x+10,y+5,1,7,C_DRIED) end
 if scarbit(f,3) then pix(x+11,y+8,C_BONE) end
 if dead(f) then rect(x,y,16,16,C_DK) print("RIP",x+2,y+6,C_BLOOD) end
end

-- ================= BUGLE =================
function setbugle(s) G.bugle="BUGLE: "..s end

function bugletone()
 if G.debt>1500 then return "BUTCHER OF MARKET ROW" end
 if G.heat>=3 then return "SUSPECT IN VICE SQUADE FILE" end
 if G.fight>=15 then return "PROMISING MANAGER" end
 return "NEW FACE ON CHALK LANE"
end

-- ================= TITLE =================
function titleUD()
 TITLE_T=TITLE_T+1
 if btnp(4) or btnp(6) then
  if not loadgame() then newgame() end
  setState("ROSTER")
 end
 cls(C_BG)
 print("BARE-",86,TITLE_T//120%2==0 and 24 or 26,4,false,2)
 print("KNUCKLE",86,48,2,false,2)
 print("NO GLOVES. NO RULES. NO AMBULANCE.",40,80,C_DIM)
 if math.random()<0.1 then pix(40+math.random(160),80+math.random(10),2) end
 print("Z: START / CONTINUE",72,100,C_TXT)
 if pmem(0)==MAGIC then print("(save found: fight "..pmem(3)..")",72,110,C_DIM) end
 print("1987 CHALK LANE ATHLETIC",60,126,15)
end

-- ================= ROSTER =================
function rosterUD()
 if btnp(0) then G.sel=(G.sel+3)%4+1 end
 if btnp(1) then G.sel=(G.sel%4)+1 end
 if btnp(4) then setState("MARKET") end
 cls(C_BG)
 topbar("ROSTER & CORNER")
 local y=16
 print("PICK YOUR CORNER  (Z: market  UP/DN: select)",4,y,C_DIM)
 y=y+10
 for i=1,4 do
  local f=G.fighters[i]
  if i==G.sel then rect(2,y-2,118,18,8) end
  drawFace(4,y,f)
  local col=C_TXT
  if dead(f) then col=C_BLOOD elseif retired(f) then col=C_DIM end
  print(f.name,22,y,C_TXT,false,false)
  print("P"..f.pow.." T"..f.tgh.." S"..f.sta.." D"..f.spd.." age"..f.age,22,y+8,C_DIM)
  -- wound chips
  for k=1,4 do
   local wx=104+((k-1)%2)*6
   local wy=y+((k-1)//2)*6
   if f.wound[k]>=17 then rect(wx,wy,5,5,C_BLOOD)
   elseif f.wound[k]>=12 then rect(wx,wy,5,5,C_BONE)
   elseif f.wound[k]>=8 then rect(wx,wy,5,5,C_BLOOD)
   elseif f.wound[k]>=4 then rect(wx,wy,5,5,C_BRUISE) end
  end
  y=y+20
 end
 y=y+4
 local f=G.fighters[G.sel]
 if scarbit(f,0) or scarbit(f,1) or scarbit(f,2) or scarbit(f,3) then
  print("SCAR GALLERY: permanent marks on this one",4,y,C_DRIED)
  y=y+8
 end
 print("WOUND MAP:",4,y,C_DIM)
 local lab={"HEAD","RIBS","HAND","EYES"}
 for k=1,4 do
  local st=WSTATE_COL[wstateidx(f.wound[k])]
  print(lab[k].." "..f.wound[k].." "..st,4+((k-1)%2)*60,y+((k-1)//2)*8,
   f.wound[k]>=12 and C_BLOOD or C_DIM)
 end
 ticker(121)
end
-- ================= MARKET =================
MK={cur=1,msg=""}
MKITEMS={"TAKE THE FIGHT","BET ON SELF (30%)","SHYLOCK LOAN +500","PAY DEBT","REST HANDS (-2 wk)","TAPE RECON ($80)"}

function mkmsg(s) MK.msg=s end

function opponent()
 -- data-driven: archetype scaled to career arc (balance plan F1->F30)
 local q=clamp(2+(G.fight//3),2,9)
 local o=newfighter(q)
 if G.fight>=15 then o.pow=clamp(o.pow+1,1,9) end
 if G.fight>=24 then o.tgh=clamp(o.tgh+1,1,9) end
 o.isopp=true
 return o
end

function purse(f)
 local p
 if f<=5 then p=120+30*f
 elseif f<=15 then p=270+63*(f-5)
 else p=900+220*(f-15) end
 return math.floor(p)
end

function marketUD()
 local f=G.fighters[G.sel]
 if btnp(0) then MK.cur=(MK.cur+#MKITEMS-2)%#MKITEMS+1 end
 if btnp(1) then MK.cur=(MK.cur%#MKITEMS)+1 end
 if btnp(4) then doMarket(f) end
 cls(C_BG)
 topbar("MARKET ROW")
 local y=14
 print("FIGHT #"..G.fight.."   purse $"..purse(G.fight),4,y,C_GOLD)
 y=y+9
 if MK.opp then
  print("OPPONENT: "..MK.opp.name.."  P"..MK.opp.pow.." T"..MK.opp.tgh,4,y,C_TXT)
  y=y+8
  if MK.recon then
   print("RECON:"..mkReconText(),4,y,MK.reconok and C_OK or C_BLOOD)
   y=y+8
  end
 else
  print("no card yet. take a fight to see the paper.",4,y,C_DIM)
  y=y+8
 end
 y=y+4
 for i=1,#MKITEMS do
  local col=C_TXT
  if i==MK.cur then rect(2,y-2,110,9,8) col=C_GOLD end
  print(MKITEMS[i],4,y,col)
  y=y+10
 end
 y=y+2
 print("heat:"..G.heat.." debt:$"..G.debt.." tone:"..bugletone(),4,y,C_DIM)
 y=y+8
 print(MK.msg,4,y,C_BLOOD)
 y=y+8
 print("bet:"..(MK.bet or 0).."  ownd money curve: F1-10 nets -20",4,y,C_DIM)
 ticker(121)
end

function mkReconText()
 local o=MK.opp
 if MK.reconok then
  return "true: P"..o.pow.." T"..o.tgh.." S"..o.sta
 else
  -- plausible lie: describes own fighter (mechanic #4)
  local f=G.fighters[G.sel]
  return "lie: P"..f.pow.." T"..f.tgh.." (glass-jaw tip)"
 end
end

function doMarket(f)
 local i=MK.cur
 if i==1 then -- take the fight
  if dead(f) then mkmsg("he's dead. pick a live one.") return end
  if retired(f) then mkmsg("retired men don't fight.") return end
  if f.wound[3]>=12 then mkmsg("fractured hand: he can't close a fist!") return end
  if not MK.opp then MK.opp=opponent() mkmsg("card posted. odds favor nobody.") return end
  setupFight(f,MK.opp)
  setState("FIGHT")
 elseif i==2 then
  if MK.opp==nil then mkmsg("no card, no book.") return end
  local b=math.max(0,math.floor(G.money*0.3))
  if b<10 then mkmsg("bankroll too thin to bet.") return end
  MK.bet=b mkmsg("booked: $"..b.." on your man.") -- EV shifts per balance plan
 elseif i==3 then
  G.money=G.money+500 G.debt=G.debt+500
  mkmsg("chalk-lane shylock smiles. vig 10% per card.")
  if G.debt>1500 then G.heat=G.heat+1 mkmsg("kneecaps party is brewing...") end
 elseif i==4 then
  if G.debt<=0 then mkmsg("you owe nothing. rare.") return end
  local pay=math.min(G.debt,math.max(0,G.money))
  if pay<=0 then mkmsg("no cash. no mercy.") return end
  G.money=G.money-pay G.debt=G.debt-pay
  mkmsg("paid $"..pay.." debt now $"..G.debt)
 elseif i==5 then
  f.wound[3]=math.max(0,f.wound[3]-2)
  healstep(f) healstep(f)
  mkmsg("rested: hands recover, calendar moves")
  aftercard()
 elseif i==6 then
  if MK.opp==nil then mkmsg("buy recon AFTER card posted.") return end
  if G.money<80 then mkmsg("recon costs $80.") return end
  G.money=G.money-80
  MK.recon=true
  MK.reconok=math.random(100)<=70 -- mechanic #4: 70% reliable
  mkmsg("tipster whispers...")
 end
end

function aftercard()
 -- calendar: heal all, interest, aging
 for i=1,4 do
  if not dead(G.fighters[i]) then
   healstep(G.fighters[i])
   G.fighters[i].age=G.fighters[i].age+0
  end
 end
 G.debt=math.floor(G.debt*1.1)
end
-- ================= FIGHT =================
ORDERS={"HOLD","SWING","COUNTER","BRAWL","CLINCH","COVER"}
ORDER_COST={1,2,2,3,1,0}

function setupFight(me,opp)
 F={}
 F.me=me F.opp=opp
 F.msta={H=0,R=0,N=0,E=0} -- round-local damage pools (fight-local)
 F.osta={H=0,R=0,N=0,E=0}
 F.men={stam=100,blood=0,dealt=0,downs=0,towel=false}
 F.ost={stam=100,blood=0,dealt=0,downs=0}
 F.round=1 F.cur=1 F.phase="MENU" F.tick=0
 F.feed={} F.events={} F.evi=0
 F.crowd=30 F.toweldeclined=0
 F.res=nil F.seed=math.random(1,2^30)
 math.randomseed(F.seed+G.fight*13)
 setbugle("tonight: "..me.name.." vs "..opp.name.." @ chalk lane hall")
 feed("BELL. round 1. no gloves, no mercy.",12)
end

function feed(t,c) table.insert(F.feed,{t=t,c=c or 12}) if #F.feed>7 then table.remove(F.feed,1) end end

function gorestage(wnd,blood) -- wound pool table + blood meter -> stage 0-4
 local s=0
 if blood>=3 then s=2 elseif blood>=1 then s=1 end
 local frac=0
 for k=1,4 do if wnd[k]>=12 then frac=frac+1 end end
 if frac>=2 then return 4 elseif frac>=1 then s=3 end
 if blood>=6 and s<3 then s=3 end
 return s
end

function resolveRound(oi,oo)
 -- builds deterministic event list for the round
 local ev={}
 local cost=ORDER_COST[oi]
 F.men.stam=F.men.stam-cost*2
 local oc=ORDER_COST[oo]
 F.ost.stam=F.ost.stam-oc*2
 local ex=5+math.random(3)
 for x=1,ex do
  local mine=(math.random(F.me.spd+3)<F.opp.spd+3) -- speed race w/ noise
  local atk,def,ao,ae,de
  if mine then atk,def,ao,ae,de=F.me,F.opp,oi,F.men,F.ost else
   atk,def,ao=F.opp,F.me,oo ae,de=F.ost,F.men end
  local reg=1
  if ao==5 then reg=2 elseif ao==2 or ao==3 then reg=1
  elseif ao==4 then reg=math.random(4) end
  local acc=55+atk.spd*2-def.tgh*2
  if reg==3 then acc=acc-8 end -- body shots: less clean
  if def.wound[4]>=12 then acc=acc+15 end -- eyes: dodge fails vs jab (GORE §1)
  acc=clamp(acc,20,90)
  if ao==6 or (ao==5 and math.random(2)==1) then
   ae.stam=ae.stam+6
   if ao==6 then table.insert(ev,{t="COVER",who=mine}) end
  elseif math.random(100)<=acc then
   local mult=1.5
   if reg==2 then mult=1.0 elseif reg==3 then mult=0.8 elseif reg==4 then mult=1.2 end
   local dmg=atk.pow*mult-def.tgh*0.5+math.random(3)
   if ao==2 then dmg=dmg*1.4 end
   if ao==4 then dmg=dmg*2 end -- BRAWL doubles both ways
   if ao==3 then dmg=dmg*0.7 end
   dmg=math.max(1,math.floor(dmg))
   if ao==4 then def.wound[reg]=def.wound[reg]+dmg -- brawl hits hard both ways
   else def.wound[reg]=def.wound[reg]+dmg end
   def.wound[reg]=clamp(def.wound[reg],0,20)
   if mine then F.men.dealt=F.men.dealt+dmg else F.ost.dealt=F.ost.dealt+dmg end
   table.insert(ev,{t="HIT",who=mine,reg=reg,dmg=dmg})
   -- torn-glove rule (mech #7): bare knuckle hurts the thrower too
   if reg~=3 and math.random(100)<=6 and atk.wound[3]<20 then
    atk.wound[3]=atk.wound[3]+1
    table.insert(ev,{t="HAND",who=mine})
   end
   -- blood meter (mech #3)
   if (reg==1 and def.wound[1]>=8) or math.random(100)<=10 then
    def.blood=clamp(def.blood+1,0,8)
    table.insert(ev,{t="BLOOD",who=mine})
   end
   -- knockdown (GORE §1 DOWN head: any clean head hit >=6)
   if reg==1 and def.wound[1]>=17 and dmg>=6 then
    table.insert(ev,{t="DOWN",who=mine})
   end
   if atk.wound[3]>=12 and math.random(100)<=10 then
    atk.wound[3]=clamp(atk.wound[3]+2,0,20)
    table.insert(ev,{t="SELF",who=mine})
   end
  else
   table.insert(ev,{t="MISS",who=mine})
  end
 end
 table.insert(ev,{t="ROUNDEND",r=F.round})
 return ev
end

function orderAI()
 local o=F.opp
 local agg=2+o.pow//2
 return wpick({{1,4},{2,agg},{3,2},{4,o.pow>=6 and 3 or 1},{5,2},{6,1}},2)
end
-- ================= FIGHT UPDATE =================
REGNAME={"HEAD","RIBS","HAND","EYES"}

function fightUD()
 F.tick=F.tick+1
 if F.phase=="MENU" then
  if btnp(0) then F.cur=(F.cur+5)%6+1 end
  if btnp(1) then F.cur=(F.cur%6)+1 end
  if btnp(5) and not F.men.towel then -- THE TOWEL (mech #2)
   F.men.towel=true
   G.heat=G.heat+1
   feed("YOU THREW THE TOWEL. ref clocked it. HEAT+1",2)
   endFight("TOWEL")
   return
  end
  if btnp(4) then
   if F.men.stam<10 then feed("he's gassed - order still goes in.",3) end
   local oo=orderAI()
   F.events=resolveRound(F.cur,oo)
   F.evi=0 F.phase="ANIM"
  end
 elseif F.phase=="ANIM" then
  if F.tick%8==0 then
   F.evi=F.evi+1
   if F.evi>#F.events then endRound()
   else applyEvent(F.events[F.evi]) end
  end
 elseif F.phase=="DOWN" then
  -- last-chance towel while our man is on the canvas (mech #2 + mercy valve)
  if btnp(5) and not F.men.towel and F.downWho==false then
   F.men.towel=true G.heat=G.heat+1
   feed("TOWEL IN! he's saved. ref clocked it. HEAT+1",4)
   endFight("TOWEL")
   return
  end
  if F.tick%14==0 then knockTick() end
 elseif F.phase=="END" then
  if btnp(4) then
   results()
  end
 end
end

function vicOf(mine) if mine then return F.opp else return F.me end end

function applyEvent(e)
 if e.t=="HIT" then
  local v=vicOf(e.who)
  F.crowd=clamp(F.crowd+e.dmg,0,CROWD_MAX)
  if e.dmg>=6 then SHK=6 end
  if e.dmg>=9 then FLASH=2 end
  spawnBlood(120+math.random(30)-15,60+math.random(16),1+e.dmg//3)
  if e.who then
   feed("crack! "..REGNAME[e.reg].." "..e.dmg.." ("..wstate(v.wound[e.reg])..")",
    e.dmg>=8 and 2 or 12)
  else
   feed("he takes "..REGNAME[e.reg].." "..e.dmg.." ("..wstate(v.wound[e.reg])..")",
    e.dmg>=8 and 2 or 14)
  end
 elseif e.t=="BLOOD" then
  local v=vicOf(e.who)
  spawnBlood(120+math.random(30)-15,55+math.random(20),4)
  if e.who then feed("his face opens up! blood "..v.blood.."/8",2)
  else feed("OUR MAN IS BLEEDING "..v.blood.."/8",2) end
 elseif e.t=="DOWN" then
  local v=vicOf(e.who)
  F.crowd=clamp(F.crowd+20,0,CROWD_MAX)
  SHK=10 FLASH=3
  spawnBlood(120+math.random(30)-15,60,12)
  F.downWho=e.who F.count=0 F.phase="DOWN"
  if e.who then feed("DOWN!! "..v.name.." hits the canvas!",2)
  else feed("OUR MAN IS DOWN!! towel? (X)",2) end
 elseif e.t=="HAND" or e.t=="SELF" then
  local v=vicOf(e.who)
  feed("bare knuckles fold - "..v.name.."'s hand swells",3)
 elseif e.t=="MISS" then
  F.crowd=clamp(F.crowd-1,0,CROWD_MAX)
 elseif e.t=="COVER" then
  feed("he covers up and breathes.",14)
 end
end

function knockTick()
 local mineDown=F.downWho -- true: OPPONENT is down (we landed it)
 local v2=mineDown and F.opp or F.me -- the fighter on the canvas
 F.count=F.count+1
 if F.count>=10 then
  if not mineDown then F.toweldeclined=F.toweldeclined+1 end
  koEnd(mineDown)
  return
 end
 local up=math.random(100)<(55-F.count*4-v2.wound[1])
 if up and F.count>=3 then
  if mineDown then F.ost.stam=math.max(30,F.ost.stam-F.count*6)
  else F.men.stam=math.max(30,F.men.stam-F.count*6) end
  feed(v2.name.." is UP at "..F.count.."!",4)
  F.phase="ANIM"
 elseif not mineDown and F.count>=3 then
  F.toweldeclined=F.toweldeclined+1
 end
end

function koEnd(mineDown)
 -- mineDown==true <=> vastustaja putosi (minä osasin) -> VOITIN (minä olin voittaja)
 if not mineDown and F.toweldeclined>=1 and F.me.wound[1]>=17 and math.random(100)<=3 then
  F.me.scar=F.me.scar+16
  G.tone=G.tone+1
  endFight("DEATH")
  return
 end
 endFight("KO", mineDown)
end

function endRound()
 -- bleed & doctor stoppage (mech #3: 8/8 = doctor risk)
 for i=1,4 do
  if F.me.wound[1]>=8 then F.men.stam=F.men.stam-1 end
  if F.opp.wound[1]>=8 then F.ost.stam=F.ost.stam-1 end
 end
 F.men.stam=clamp(F.men.stam+8-F.me.wound[1]//2,10,100)
 F.ost.stam=clamp(F.ost.stam+8-F.opp.wound[1]//2,10,100)
 if F.men.blood>=8 and math.random(100)<=60 then endFight("DOC") return end
 if F.ost.blood>=8 and math.random(100)<=60 then endFight("DOC") return end
 F.round=F.round+1
 if F.round>ROUNDS_MAX then
  if F.men.dealt>=F.ost.dealt then endFight("DEC",true) else endFight("DEC",false) end
  return
 end
 F.crowd=clamp(F.crowd-5,10,CROWD_MAX)
 feed("--- bell. round "..F.round.." ---",14)
 F.phase="MENU"
end
-- ================= END FIGHT / RESULTS =================
function endFight(kind,winMine)
 F.res={kind=kind,win=winMine}
 -- scars: FRACTURED+ damage becomes permanent (GORE §3)
 for i=1,4 do
  local b=(F.me.scar//(2^(i-1)))%2
  if F.me.wound[i]>=12 and b==0 then F.me.scar=F.me.scar+2^(i-1) end
 end
 local med=150+F.me.wound[1]*10+F.me.wound[2]*6+F.me.wound[3]*8+F.me.wound[4]*5
 F.res.med=med
 F.res.purse=0
 if kind=="DEATH" then
  F.res.purse=math.floor(purse(G.fight)*0.5)
  G.money=G.money+F.res.purse
  med=math.floor(med*1.5)
 elseif winMine then
  F.res.purse=purse(G.fight)
  F.res.purse=F.res.purse+F.crowd//2 -- Fight-of-the-Night bonus (crowd pays)
  G.money=G.money+F.res.purse
 else
  F.res.purse=math.floor(purse(G.fight)*0.3) -- blood money
  G.money=G.money+F.res.purse
 end
 G.money=G.money-med
 F.res.med=med
 -- bet settle (mech #11 ledger)
 if MK.bet and MK.bet>0 then
  if winMine then F.res.bet=math.floor(MK.bet*1.8) G.money=G.money+F.res.bet
  else F.res.bet=-MK.bet end
  MK.bet=0
 end
 if kind=="DEATH" then setbugle("OBITUARY: "..F.me.name.." died in the ring. ledger bleeds.")
 elseif kind=="TOWEL" then setbugle("corner quit. ref clocked the towel.")
 elseif winMine then setbugle(F.me.name.." wins by "..kind.."! crowd roars.")
 else setbugle(F.me.name.." loses by "..kind..". chalk lane shrugs.") end
 G.fight=G.fight+1
 G.me_stamps=1
 savegame()
 F.phase="END"
end

function results()
 MK.opp=nil MK.recon=nil
 aftercard()
 -- save-file curse (mech #33): the past collects
 if G.curse>0 and math.random(100)<=12 then
  G.money=G.money-100
  setbugle("a ghost from fight "..G.curse.." collects. -$100")
 end
 if G.debt>1500 and G.money<0 then G.heat=G.heat+1 end
 -- endings (mech #32)
 if G.money<=-1500 and G.debt>=1500 then setState("GAMEOVER") return end
 if G.fight>30 then setState("GAMEOVER") return end
 setState("RESULTS")
 savegame()
end

function resultsUD()
 if btnp(4) then setState("MARKET") end
 cls(C_BG)
 topbar("FIGHT NIGHT LEDGER")
 local r=F.res
 local y=16
 local col=r.win and C_OK or C_BLOOD
 if r.kind=="DEATH" then col=C_DRIED end
 print("RESULT: "..r.kind..(r.win and " - YOUR MAN WINS" or ""),4,y,col)
 y=y+10
 drawFace(4,y,F.me)
 print(F.me.name,24,y,C_TXT)
 print("purse $"..r.purse.."  medical -$"..r.med,24,y+8,C_DIM)
 y=y+22
 if r.bet then print("bet settled: "..(r.bet>0 and "+$"..r.bet or "-$"..(-r.bet)),4,y,4) y=y+8 end
 print("money $"..G.money.."  debt $"..G.debt.."  heat "..G.heat,4,y,C_DIM)
 y=y+10
 print("WOUNDS CARRIED:",4,y,C_BLOOD)
 local lab={"HEAD","RIBS","HAND","EYES"}
 for k=1,4 do
  print(lab[k].." "..F.me.wound[k].." "..wstate(F.me.wound[k]),4+((k-1)%2)*60,y+((k-1)//2)*8,
   F.me.wound[k]>=12 and C_BLOOD or C_DIM)
 end
 y=y+20
 if scarbit(F.me,0) or scarbit(F.me,1) or scarbit(F.me,2) or scarbit(F.me,3) then
  print("SCAR GALLERY grows. these never heal.",4,y,C_DRIED)
  y=y+8
 end
 if dead(F.me) then
  print("HE NEVER WALKED OUT.",4,y,C_BLOOD) y=y+8
  print("black screen. one line. the ledger pays.",4,y,C_DIM) y=y+8
 end
 print("Z: back to market row",4,110,C_TXT)
 ticker(121)
end

-- ================= GAMEOVER (mech #32) =================
function endingGrade()
 if G.fight>30 and G.money>3000 and G.heat==0 and G.debt==0 then return "GOLDEN GLOVE",4 end
 if G.fight>30 and G.heat>=4 then return "KINGPIN",2 end
 if G.money<=-1500 then return "PAUPER",2 end
 return "MARTYR",14
end

function gameoverUD()
 if btnp(4) then
  local g,_=endingGrade()
  if g=="GOLDEN GLOVE" then G.ngp=G.ngp+1 end
  if g=="KINGPIN" then G.ngp=G.ngp+1 end
  pmem(7,G.ngp) -- NG+ survives the wipe
  pmem(8,G.curse) -- so does the curse (mech #33)
  pmem(0,0) -- wipe save
  F=nil MK.opp=nil MK.bet=0 MK.recon=nil
  setState("TITLE")
  return
 end
 cls(0)
 local g,col=endingGrade()
 print("THE FOUR DEATHS",80,20,col,false,1)
 print(g,104,40,col,false,2)
 local line="your ledger is closed. fight "..(G.fight-1).."."
 if g=="PAUPER" then line="nothing left. not even the shirt." end
 if g=="GOLDEN GLOVE" then line="clean hands. full pockets. city sings." end
 if g=="KINGPIN" then line="feared, rich, and utterly empty." end
 if g=="MARTYR" then line="the city loved you more than your ledger did." end
 print(line,40,70,12)
 print("NG+ bonus level: "..G.ngp.." (next run starts stronger)",40,86,14)
 print("Z: back to the alley",72,110,12)
end
-- ================= FIGHT DRAW =================
function spawnBlood(x,y,n)
 for i=1,n do
  if #PARTS<64 then
   table.insert(PARTS,{x=x,y=y,vx=math.random(-20,20)/10,vy=math.random(-15,25)/10,life=12+math.random(10),c=math.random(2)==1 and 2 or 1})
  end
 end
end

function drawFighterBox(x,y,f,ent,mine)
 local st=gorestage(f.wound,ent.blood)
 rectb(x,y,50,70,15)
 drawFace(x+17,y+4,f)
 print(string.sub(f.name,1,8),x+2,y+22,12)
 uiBar(x+2,y+30,46,"ST",ent.stam,100,st>=3 and 2 or 6)
 print("BLD",x+2,y+38,14)
 for b=1,8 do
  rect(x+22+((b-1)%4)*6,y+38+((b-1)//4)*4,5,3,b<=ent.blood and 2 or 15)
 end
 print("GORE:"..st,x+2,y+48,st>=3 and 2 or 14)
 print("dmg out:"..ent.dealt,x+2,y+56,14)
 if F.phase=="DOWN" and ((mine and F.downWho==false) or (not mine and F.downWho==true)) then
  print("DOWN!",x+8,y+62,2)
 end
end

function fightDraw()
 cls(C_BG)
 topbar("FIGHT NIGHT  R"..F.round)
 -- ring scene center
 rect(110,18,120,66,7)
 rect(114,22,112,58,0)
 drawFighterBox(116,24,F.me,F.men,true)
 drawFighterBox(178,24,F.opp,F.ost,false)
 -- canvas stains persist during fight
 if F.men.blood>=3 then rect(150,50,10,6,1) end
 if F.men.blood>=6 then rect(144,56,22,8,1) end
 -- crowd meter
 print("CROWD",116,86,14)
 rect(148,86,90*F.crowd//CROWD_MAX,5,4)
 rectb(148,86,90,5,15)
 -- orders panel
 if F.phase=="MENU" then
  for i=1,6 do
   local col=12
   if i==F.cur then rect(2,17+(i-1)*9,52,9,8) col=4 end
   print(ORDERS[i],4,18+(i-1)*9,col)
   print("s-"..ORDER_COST[i],40,18+(i-1)*9,14)
  end
  print("Z: call it  X: TOWEL",2,74,2)
 else
  print("..."..F.phase,4,22,14)
 end
 -- feed
 local fy=100
 for i=1,#F.feed do
  print(string.sub(F.feed[i].t,1,38),2,fy,F.feed[i].c)
  fy=fy+8
 end
 -- count display
 if F.phase=="DOWN" then
  rect(96,40,40,24,0)
  print(".."..F.count.."..",98,46,2,false,2)
 end
 if F.phase=="END" then print("Z: LEDGER",190,90,4) end
 ticker(121)
end

-- ================= STATE MACHINE =================
ST=""
function setState(s)
 ST=s
 if s=="MARKET" then MK.cur=1 end
 if s=="MARKET" or s=="ROSTER" then savegame() end
 if s=="TITLE" then MK={cur=1,msg=""} end
end

STATES={}
STATES.TITLE=titleUD
STATES.ROSTER=rosterUD
STATES.MARKET=marketUD
STATES.FIGHT=function() fightUD() fightDraw() end
STATES.RESULTS=resultsUD
STATES.GAMEOVER=gameoverUD

-- ================= PARTICLES =================
function updp()
 for i=#PARTS,1,-1 do
  local p=PARTS[i]
  p.x=p.x+p.vx p.y=p.y+p.vy p.vy=p.vy+0.15 p.life=p.life-1
  if p.life<=0 or p.y>119 then table.remove(PARTS,i) end
 end
 if SHK>0 then SHK=SHK-1 end
 if FLASH>0 then FLASH=FLASH-1 end
end

function drwp()
 for i=1,#PARTS do pix(PARTS[i].x//1,PARTS[i].y//1,PARTS[i].c) end
end

-- ================= MAIN =================
function TIC()
 updp()
 -- determinism: fight sim reseeded from stored seed + tick (replayable)
 if F and F.seed then
  math.randomseed(F.seed+F.tick*7+G.fight*13)
 end
 if ST=="" then setState("TITLE") end
 if ST=="FIGHT" then
  fightUD()
  fightDraw()
 else
  STATES[ST]()
 end
 drwp()
 if FLASH>0 then rect(0,0,240,136,2) end
 if SHK>0 then
  rect(0,0,240,3,0) rect(0,133,240,3,0)
  rect(0,0,3,136,0) rect(237,0,3,136,0)
 end
end