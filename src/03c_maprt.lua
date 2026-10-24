--------------------------- 03c KARTTA AJONAIKAINEN
CH2W={['#']=BRICK,['=']=CONCR,['M']=METAL,['W']=WOOD,['D']=DOORC}
CH2F={['.']=1,[',']=2}
function buildMap(md)
 local m={cells={},floors={},doors={},exits={},md=md}
 for i=1,MW*MH do m.cells[i]=CONCR m.floors[i]=1 end
 -- sisalto 30x30 keskelle
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
  m.floors[idx(e[1],e[2])]=99 -- poistumistekstuuri
  m.exits[#m.exits+1]={e[1],e[2]}
 end
 return m
end
-- oven avaus/sulkeminen + animaatio
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
-- proseduraalinen harjoituskartta: huoneet + kaytavat + ovet
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

--------------------------- pmem-tallennus (editori)
PM_MAGIC=0x4B41523A -- "KAR:"
PM_BASE=1           -- kartta: 128 sanaa x 8 solua (4 bittia/solu)
PM_OBJN=129         -- objektien maara
PM_OBJ=130          -- max 40 objektia: (tyyppi<<12)|(y<<6)|x
-- tyypit: 1 vihollinen 2 panttivanki 3 pommi 4 poistuminen 5 ryhma1 6 ryhma2
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
