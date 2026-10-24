-- lähikuvat: seinä 2 ruudun päässä, vihollinen 3 ruudun
__MAX=200
local st=0
function __SCN(n)
 G.inj={} G.injP={}
 if n==1 then
  loadMission(MIS[1]) initPlanState() G.phase=S_PLAN
  G.nogun=true
 elseif n==3 then G.injP[50]=true
 elseif G.phase==S_ACTION then
  if st==0 then
   local m=G.members[G.player]
   m.x=8.5 m.y=19.5 m.ang=-1.5708
   st=1
  end
  if n==20 then SCR('D1_WALL2') end
  if n==22 then
   local m=G.members[G.player]
   m.x=8.5 m.y=22.5 m.ang=-1.5708
   G.enemies[1].x=8.5 G.enemies[1].y=19.5 G.enemies[1].state=2
  end
  if n==40 then SCR('D2_ENEMY3') end
  if n==42 then
   local m=G.members[G.player]
   m.x=6.5 m.y=27.5 m.ang=-0.5
  end
  if n==60 then SCR('D3_CORRIDOR') end
 end
end
