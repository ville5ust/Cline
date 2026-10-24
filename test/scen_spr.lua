-- debug: sprite projisointi
__MAX=200
local st=0
function __SCN(n)
 G.inj={} G.injP={}
 if n==1 then
  loadMission(MIS[1]) initPlanState() G.phase=S_PLAN G.nogun=true
 elseif n==3 then G.injP[50]=true
 elseif G.phase==S_ACTION then
  if st==0 then
   local m=G.members[G.player]
   m.x=8.5 m.y=20.5 m.ang=0
   local e=G.enemies[1]
   e.x=10.5 e.y=20.5 e.state=2
   G.dbg=true G.dbg2=true
   st=1
  end
  if n==10 then G.dbg=false G.dbg2=true end
  if n==30 then SCR('SPRTEST') end
 end
end
