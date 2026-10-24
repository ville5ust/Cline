--------------------------- 07 SUUNNITTELU
PLAN_SCALE=3.2
function initPlanState()
 G.planSel=0 -- 0 = SUSI, 1 = KARHU
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
 -- tausta-ruudukko
 for y=0,MH do line(ox,oy+y*scale,ox+MW*scale,oy+y*scale,1) end
 for x=0,MW do line(ox+x*scale,oy,ox+x*scale,oy+MH*scale,1) end
 drawMinimap(nil,ox,oy,scale,true)
 -- otsikot
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
 -- piirra molempien ryhmien reitit
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
 -- hiirikursori
 if onMap then
  rectb(ox+cx*scale,oy+cy*scale,scale+1,scale+1,15)
 end
 -- syotto
 if kdp(17) then G.planSel=1-G.planSel end -- Q
 local plan=G.plan[G.planSel+1]
 if onMap then
  local s=plan.start
  local nearStart=math.abs(cx-s[1])<=0 and math.abs(cy-s[2])<=0
  local clickL=G.injM1 or l
  -- oikea klikkaus: poista viimeisin
  if r or G.injM2 then
   if #plan.wps>0 then
    table.remove(plan.wps)
   end
  end
  -- klikkaus: alkupaikka tai reittipiste
  if l or clickL then
   if cx==s[1] and cy==s[2] then
    -- ei mitaan (alkupaikka jasenissa)
   elseif passable(cx,cy) then
    plan.wps[#plan.wps+1]={cx,cy,go=0}
   end
  end
  -- gokoodin asettaminen hiiriren nyttamalle pisteelle
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
  -- alkupaikan siirto: SHIFT+klikkaus
  if (kd(64) or G.injShift) and (l or clickL) then
   if passable(cx,cy) then
    plan.start={cx,cy}
   end
  end
 end
 -- ENTER / Z: aloita
 if kdp(50) or btnp(4) then
  -- nollaa jasenet alkupaikkoihin
  local md2=G.md
  loadMission(md2,G.plan)
  G.phase=S_ACTION
  msg('TOIMINTA ALKAA - GOKOODIT: 1 2 3',3)
 end
end
