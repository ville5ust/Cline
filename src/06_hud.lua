--------------------------- 06 HUD
function hudAction(m)
 -- ristikko (leviaa rekylissa)
 local sp=2+math.floor((m.rec or 0)*2)
 local cx,cy=120,68
 line(cx-sp-4,cy,cx-sp,cy,15) line(cx+sp,cy,cx+sp+4,cy,15)
 line(cx,cy-sp-4,cx,cy-sp,15) line(cx,cy+sp,cx,cy+sp+4,15)
 -- terveys
 local hp=m.hp
 local hc=14
 if hp<40 then hc=6 end
 if hp<20 then hc=4 end
 rectb(4,4,52,8,1)
 rect(5,5,math.max(0,math.floor(hp/2)),6,hc)
 print(m.name,4,14,15,false,1,true)
 -- lippaat
 print('KP-90 '..m.ammo..'-30',168,4,15,false,1,true)
 if m.reload>0 then print('LATAA..',168,12,14,false,1,true) end
 -- gokoodit
 local gx=4
 for i=1,3 do
  local lab=string.char(64+i) -- A B C
  local col=2
  if G.go[i] then col=14 else col=15 end
  print('G'..lab,gx,126,col,false,1,true)
  gx=gx+18
 end
 -- jasenet
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
 -- viesti
 if G.msg and G.msg.t>0 then
  local tw=#G.msg.txt*4
  local x=math.max(2,math.floor((240-tw)/2))
  print(G.msg.txt,x,120,15,false,1,true)
 end
 -- tavoitteindeksi
 local ot=objText()
 local oy=100
 for i,t in ipairs(ot) do
  print(t,4,oy,11,false,1,true) oy=oy+7
 end
 if G.objReady then
  print('POISTUMINEN: X',4,oy,14,false,1,true)
 end
 -- korostus: vihollinen tahden alla!
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
-- kartta (M-nappi pohjassa / suunnittelussa kaytetaan samaa)
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
 -- poistuminen
 for _,e in ipairs(G.map.exits) do
  rect(ox+e[1]*scale,oy+e[2]*scale,scale,scale,14)
 end
 -- kohteet
 for _,h in ipairs(G.hostages) do
  print('H',ox+h.x*scale,oy+h.y*scale-6,15,false,1,true)
 end
 for _,b in ipairs(G.bombs) do
  print('P',ox+b.x*scale,oy+b.y*scale-6,6,false,1,true)
 end
 -- viholliset (nakyvissa olevalle: nahty/gokoodi ei paleta)
 for _,e in ipairs(G.enemies) do
  if e.alive and e.seen then
   rect(ox+math.floor(e.x)*scale,oy+math.floor(e.y)*scale,scale,scale,4)
  end
 end
 -- jasenet + pelaaja
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
 -- suunnitelman reitit
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
