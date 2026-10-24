--------------------------- 04 PELI
G={phase=S_TITLE,inj={},injP={},frame=0,mem={},msg=nil,plan=nil}
G.stats={shots=0,hits=0,kills=0,t=0}
TEAMNAMES={{"SUSI 1","SUSI 2"},{"KARHU 1","KARHU 2"}}
GOKEYS={28,29,30} -- 1,2,3

-- syottokerros: rightoi testausta varten
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

-- seinasade (DDA): palauttaa {dist, side, cx, cy, wallx}
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
   -- puolivalinen ovi: tarkista osuuko lapinaan
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

-- ampuminen: hitscan + sirpaleet
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

-- tavoitteenanto
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
-- liike tormaystarkistuksella (ympyra r=0.25)
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
 -- kaanna pehmeasti
 local da=na-e.ang
 while da>3.14159265 do da=da-6.2831853 end
 while da<-3.14159265 do da=da+6.2831853 end
 e.ang=e.ang+da*0.25
 return false
end
-- jasen-AI: seuraa suunnitelmaa, ampuu nahtavia
function memberAI(m,plan)
 -- taistelu ensin
 local tgt=nil local bd=12
 for _,e in ipairs(G.enemies) do
  if e.alive then
   local dd=math.sqrt((e.x-m.x)^2+(e.y-m.y)^2)
   if dd<bd and los(m.x,m.y,e.x,e.y) then bd=dd tgt=e end
  end
 end
 if tgt then
  -- tahtaa ja ammu
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
 -- suunnitelman seuranta
 local wps=plan.wps
 if #wps==0 then return end
 local wp=wps[m.ai.pi or 1]
 if wp==nil then return end
 -- odota gokoodia
 if wp.go and wp.go>0 and not G.go[wp.go] then return end
 -- kulje seuraavaan reittisolmuun
 if not m.ai.path then
  m.ai.path=findPath(math.floor(m.x),math.floor(m.y),wp[1],wp[2])
  if not m.ai.path then m.ai.pi=math.min(m.ai.pi+1,#wps) return end
  m.ai.ni=1
 end
 local node=m.ai.path[m.ai.ni]
 if node==nil then
  -- saavutettiin waypoint
  if m.ai.pi<#wps then m.ai.pi=m.ai.pi+1 end
  m.ai.path=nil
  return
 end
 local tx,ty=node[1]+0.5,node[2]+0.5
 if stepToward(m,tx,ty,0.045) then
  -- avaa ovi tarvittaessa
  local cx,cy=node[1],node[2]
  if cellAt(cx,cy)==DOORC then
   local d=doorAt(cx,cy)
   if d.o<0.9 then d.op=true end
  end
  m.ai.ni=m.ai.ni+1
 end
end
-- vihollis-AI
function enemyAI(e)
 if not e.alive then return end
 if e.stun>0 then e.stun=e.stun-1/60 return end
 -- havaitse jasenet
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
    -- kadotti kohteen: siirry viimeksi nahtyyn
    e.state=1 e.lx=tgt.x e.ly=tgt.y e.path=nil
   end
  end
 end
 if e.state==2 and tgt then
  -- taistele
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
  -- sivuttaisliike vaeltaa
  e.strafe=e.strafe-1/60
  if e.strafe<=0 then e.strafe=1+math.random()*1.5
   e.sdx=math.random()-0.5 e.sdy=math.random()-0.5 end
  moveEnt(e,e.sdx*0.008,e.sdy*0.008)
 elseif e.state==1 then
  -- tutki melua
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
  -- parturoi idisti hitaasti
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


