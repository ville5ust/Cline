--------------------------- 05 RENDER 3D
-- 120 sade-rivipari (2px pikselit), 136 rivia; poke4 nopeus
local VRAM=0 -- vbank0 nayttomuisti
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
 -- ---------- LATTIA + KATTIO (horisontaalinen castaus)
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
 -- ---------- SEINAT (DDA sarake kerrallaan)
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
  -- perp etaisyys
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
   -- wallx suunnasta
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
 -- ---------- SPRITET
 local ents=collectSprites(m)
 local invDet=1/(plX*dirY-dirX*plY)
 for i=1,#ents do
  local s=ents[i]
  drawSprite3D(s,invDet,dirX,dirY,plX,plY,px,py,hor,mz)
 end
 -- ---------- PARTIKKELIT JA VALOJALKI
 drawFX3D(invDet,dirX,dirY,plX,plY,px,py,hor)
end
function moving(m) return G.moveFlags and (G.moveFlags.f or G.moveFlags.s) end

-- spritet ettaisiin lajiteltuna
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
 local ws=hs*s.spr.w/s.spr.h/2
 local feetY=hor+68/tz
 local y1=feetY
 local y0=feetY-hs
 if y1<0 or y0>136 then return end
 local x0=sx-ws/2 local x1=sx+ws/2
 -- varjo jalkojen alle
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
-- aseen paallepiirto
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

