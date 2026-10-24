-- skenaario: pelimekaniikkatesti (tehtava 2: panttivanki)
-- valvoo: vihollisen havaitseminen, taistelu, panttivangin varmistus,
-- poistuminen ja debrief
__MAX=600
local stage=0
local log={}
function T(s) log[#log+1]=s trace(s) end
function __SCN(n)
 G.inj={} G.injP={}
 -- 1) mene suoraan toimintaan
 if stage==0 then
  G.menuSel=1
  G.briefFrom=2
  local md=MIS[2]
  loadMission(md)
  initPlanState()
  G.phase=S_PLAN
  stage=1
  T('LADATTU M2: vihollisia='..#G.enemies..' vanki='..#G.hostages)
 elseif stage==1 then
  if n==5 then
   G.injP[50]=true
  end
  if G.phase==S_ACTION then
   stage=2
   T('TOIMINTA ALKOI')
  end
 elseif stage==2 then
  -- 2) telektele vihollisen viereen ja anna sen havaita pelaaja
  if n==20 then
   local m=G.members[G.player]
   local e=G.enemies[1]
   e.x=m.x+2.0 e.y=m.y
   e.ang=math.pi
   stage=3
  end
 elseif stage==3 then
  -- odota: vihollisen pitaisi havaita ja viheltaa
  if n==80 then
   T('vih1 state='..G.enemies[1].state..' hp='..G.members[G.player].hp)
   stage=4
  end
 elseif stage==4 then
  -- 3) pelaaja ampuu vihollisen: suorita memberFire suoraan suunnaten
  if n==82 then
   local m=G.members[G.player]
   local e=G.enemies[1]
   m.x=e.x-1.5 m.y=e.y
   m.ang=0
   for i=1,6 do memberFire(m) end
   T('vih1 alive='..tostring(e.alive)..' hp='..e.hp..' kills='..G.stats.kills)
   stage=5
  end
 elseif stage==5 then
  -- 4) mene vangin luo ja paina E
  if n==90 then
   local m=G.members[G.player]
   local h=G.hostages[1]
   m.x=h.x+0.6 m.y=h.y
   G.injP[5]=true -- E-nappain
  end
  if n==95 then
   T('vanki sec='..tostring(G.hostages[1].sec))
   stage=6
  end
 elseif stage==6 then
  -- 5) kohteet: tavoitteet valmiit?
  if n==100 then
   T('objReady='..tostring(G.objReady))
  end
  -- 6) telektele poistumisalueelle
  if n==105 then
   local m=G.members[G.player]
   local ex=G.map.exits[1]
   m.x=ex[1]+0.5 m.y=ex[2]+0.5
   stage=7
  end
 elseif stage==7 then
  if G.phase==S_DEBRIEF then
   stage=8
   T('DEBRIEF! done='..tostring(G.done)..' failed='..tostring(G.failed))
   T('tavoitteet: kills='..G.stats.kills..' shots='..G.stats.shots)
   SCR('DEBRIEF')
   __MAX=n+30
  end
 end
end
