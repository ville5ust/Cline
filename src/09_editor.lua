--------------------------- 09 EDITORI
ED={cells={},objs={},brush=CONCR,tool=0,obj='kill'}
-- tool: 0 seinamaali 1 vihollinen 2 panttivanki 3 pommi 4 poistuminen 5 sp1 6 sp2
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
 -- sivupalkki
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
 -- sivelykset
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

