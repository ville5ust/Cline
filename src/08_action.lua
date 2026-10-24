--------------------------- 08 TOIMINTA
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
 -- ---------- SYOTTO
 local f,s=false,false
 local spd=0.05
 local mvx,mvy=0,0
 if bd(0) or kd(23) then f=true mvx=mvx+1 end      -- ylos / W
 if bd(1) or kd(19) then f=true mvx=mvx-1 end      -- alas / S
 if kd(1) then s=true mvy=mvy-1 end                -- A: vasen sivuaskel
 if kd(4) then s=true mvy=mvy+1 end                -- D: oikea
 if bd(2) then m.ang=m.ang-0.062 end               -- vasen kaanto
 if bd(3) then m.ang=m.ang+0.062 end               -- oikea
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
 -- tulitus
 if (bd(4) or mouseBtn()) and m.reload<=0 then
  if G.frame%8==0 or m.rec<0.5 then memberFire(m) end
  if m.ammo<=0 and m.mag>0 then m.reload=1.2 msg('LIPAS VAIHTO',1) SND(5,60,8,4,2) end
 end
 m.rec=math.max(0,m.rec-0.15)
 if G.mz>0 then G.mz=G.mz-0.15 end
 if G.stats.shots>G.stats.hits+G.stats.kills then end
 if m.hp<100 and G.frame%180==0 then m.hp=math.min(100,m.hp+1) end
 -- lataus R
 if kdp(18) and m.reload<=0 and m.ammo<30 and m.mag>0 then
  m.reload=1.2 msg('LADATAAN..',1)
 end
 -- valokranaatu F
 if kdp(6) and m.flash>0 and not G.flash then
  m.flash=m.flash-1
  G.flash={x=m.x+dx*0.6,y=m.y+dy*0.6,vx=dx*0.09,vy=dy*0.09,t=0.9}
  msg('VALOKRANAATTO HEITETTY',1.5) SND(5,60,8,4,2)
 end
 -- vuorotabloi jasenta
 if kdp(49) then autoSwitch() end
 -- gokoodit
 for i=1,3 do
  if kdp(GOKEYS[i]) and not G.go[i] then
   G.go[i]=true
   msg('GOKOODI '..string.char(64+i)..' LAUKAISTI',2.5) SND(3,74,9,8,3)
  end
 end
 -- vuorovaikutus E
 local didAct=false
 local cx,cy=math.floor(m.x+dx*0.8),math.floor(m.y+dy*0.8)
 if cellAt(cx,cy)==DOORC and kdp(5) then
  toggleDoor(cx,cy) SND(2,50,8,6,2) didAct=true
 end
 -- panttivangit
 for _,h in ipairs(G.hostages) do
  if not h.sec then
   local dd=math.sqrt((h.x-m.x)^2+(h.y-m.y)^2)
   if dd<1.1 then
    if kdp(5) then h.sec=true msg('PANTTIVANKI VARMA!',2) didAct=true end
   end
  end
 end
 -- pommit
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
 -- ---------- PAIVITYKSET
 updateDoors()
 for i,mm in ipairs(G.members) do
  if mm.alive and i~=G.player then
   memberAI(mm,G.plan[mm.team+1])
  end
 end
 for _,e in ipairs(G.enemies) do enemyAI(e) end
 -- valokranaattu
 if G.flash then
  local fl=G.flash
  fl.x=fl.x+fl.vx fl.y=fl.y+fl.vy
  fl.vx=fl.vx*0.97 fl.vy=fl.vy*0.97
  if not passable(math.floor(fl.x),math.floor(fl.y)) then
   fl.vx=-fl.vx*0.4 fl.vy=-fl.vy*0.4
  end
  fl.t=fl.t-dt
  if fl.t<=0 then
   -- pam! sokaise nakoiset
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
 -- partikkelit
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
 -- ---------- VOITTO/TAPPIO
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
 -- ---------- RENDER + HUD
 render3D(m)
 if not G.nogun then drawWeapon(m) end
 hudAction(m)
 -- defuse-progress
 for _,b in ipairs(G.bombs) do
  if b.prog>0 and b.prog<2 then
   print('PURKAA '..string.rep('.',math.floor((G.frame/12)%4)),90,90,14,false,1,true)
  end
 end
 -- kartta M pohjassa
 if kd(13) then drawBigMap(m) end
end
function mouseBtn()
 local _,_,l=mouse()
 return l
end
