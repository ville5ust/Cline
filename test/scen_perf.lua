-- diagnostiikka: mouse-tila ja suorituskyky
__MAX=400
local t0
function __SCN(n)
 G.inj={} G.injP={}
 if n==1 then
  local a,b,c,d,e,f,g=mouse()
  local T=function(x) trace(x) end
  T('MOUSE x=..'..tostring(a)..' '..tostring(b)..' '..tostring(c)..' '..tostring(d)..' '..tostring(e))
  trace('MOUSE '..tostring(a)..' '..tostring(b)..' '..tostring(c)..' '..tostring(d)..' '..tostring(e))
  -- suoraan toimintaan M1
  loadMission(MIS[1])
  initPlanState()
  G.phase=S_PLAN
  t0=time()
 end

 if G.phase==S_PLAN and n==3 then G.injP[50]=true end
 if G.phase==S_ACTION and not t1 then t1=time() end
 if n==__MAX then
  local dt=(time()-t0)/1000
  trace('Aikaa '..dt..' s, ruutuja '..__MAX..', fps='..(math.floor(__MAX/dt)))
  trace('hp='..G.members[G.player].hp..' viholliset='..#G.enemies)
 end
end
