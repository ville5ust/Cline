--------------------------- 01 TEKSTUURIT
-- 32x32, arvo = paletti-indeksi (0-15), generoidaan koodissa
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
  if bx<1 or bx>14 or by<1 or by>6 then c=d end -- laastisauma
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
  if y>=28 then c=l end -- jalkalista
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
  if (x%8==3 or x%8==4) and (y%8==3 or y%8==4) then c=l end -- niitit
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
  if (x+plank*11)%16==0 then c=d end -- laudoittelu
  tp(t,x,y,c)
 end end
 return t
end
function genDoor(rnd,base) -- metalliovi + varoitusraidat
 local t=newtex() local d,m,l=7,8,9
 for y=0,31 do for x=0,31 do
  local c=8
  if x<2 or x>29 or y<2 or y>29 then c=7 end
  if y==2 or y==29 then c=9 end
  -- varoitusraidat
  if y>=13 and y<=18 and (math.floor((x+y)/2)%4)==0 then c=6 else
   if y>=13 and y<=18 then c=10 end end
  if y>=24 and y<=25 and x>=24 and x<=27 then c=15 end -- kahva
  if y>=5 and y<=8 and x>=8 and x<=23 then c=9 end -- ikkuna
  if y==6 and (x%2==0) then c=8 end
  tp(t,x,y,c)
 end end
 return t
end
function genFloor(rnd,base) -- betonilattia + tiilisaumat
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
function genExit(rnd) -- poistumisalueen lattia
 local t=newtex()
 for y=0,31 do for x=0,31 do
  local c=13
  if rnd()<0.2 then c=14 end
  -- iso X ja reunat
  if x==1 or x==30 or y==1 or y==30 then c=14 end
  local dx,dy=x-16,y-16
  if (math.abs(math.abs(dx)-math.abs(dy))<3) and dx*dx+dy*dy<196 then c=15 end
  tp(t,x,y,c)
 end end
 return t
end

TEX={} -- [1..] seinat, lattiat, katot
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
