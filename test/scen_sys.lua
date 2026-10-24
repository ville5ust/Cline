-- skenaario: tehtava 3 (pomminpurku) + ryhman AI + editori
__MAX=700
local stage=0
function T(s) trace(s..string.char(10)) end
function __SCN(n)
 G.inj={} G.injP={}
 if stage==0 then
  -- 1) ryhman AI-testi: reittipiste + gokoodi
  loadMission(MIS[1])
  initPlanState()
  G.plan[1].wps={{4,20,go=1},{4,10,go=0}}
  G.phase=S_PLAN
  stage=1
 else
  if G.phase==S_PLAN and n==3 then G.injP[50]=true end
  if stage==1 and G.phase==S_ACTION then
   stage=2
   T('TOIMINTA: ryhma odottaa gokoodia A')
  end
 end
 if stage==2 then
  if n==40 then
   local m2=G.members[2]
   T('SUSI2 x='..math.floor(m2.x*10)..' y='..math.floor(m2.y*10))
   G.injP[28]=true
  end
  if n==140 then
   local m2=G.members[2]
   T('SUSI2 100f x='..math.floor(m2.x*10)..' y='..math.floor(m2.y*10))
   stage=3
   -- 2) pomminpurku M3
   loadMission(MIS[3])
   initPlanState()
   G.phase=S_PLAN
  end
 end
 if stage==3 then
  if G.phase==S_PLAN and n==150 then G.injP[50]=true end
  if G.phase==S_ACTION then
   stage=4
   T('M3 TOIMINTA')
  end
 end
 if stage==4 then
  if n==200 then
   local m=G.members[G.player]
   local b=G.bombs[1]
   m.x=b.x+0.6 m.y=b.y
   T('pommi1 edessa, obj='..G.md.obj)
  end
  if n>=201 and n<=330 then G.inj[5]=true end -- pida E pohjassa
  if n==340 then
   T('pommi1 def='..tostring(G.bombs[1].def))
   -- teleporttaa pommi 2 viereen
   local m=G.members[G.player]
   local b=G.bombs[2]
   m.x=b.x+0.6 m.y=b.y
   stage=5
  end
 end
 if stage==5 then
  if n>=350 and n<=480 then G.inj[5]=true end
  if n==490 then
   T('pommi2 def='..tostring(G.bombs[2].def))
   T('objReady='..tostring(G.objReady))
   -- 3) editori: tallenna/lataa
   for i=1,MW*MH do ED.cells[i]=CONCR end
   for y=10,16 do for x=10,16 do ED.cells[idx(x,y)]=0 end end
   ED.objs={{t=5,x=11,y=11},{t=6,x=15,y=15},{t=1,x=14,y=12},{t=4,x=12,y=14}}
   ED.obj='kill'
   pmSaveEditor(ED)
   for i=1,MW*MH do ED.cells[i]=CONCR end
   ED.objs={}
   local ok=pmLoadEditor(ED)
   local cells_ok=ED.cells[idx(12,12)]==0 and ED.cells[idx(2,2)]==CONCR
   T('PMEM load='..tostring(ok)..' cells='..tostring(cells_ok)..' objs='..#ED.objs)
   local md=edCellsToMap()
   local err=edValidate(md)
   T('EDITOR validointi: '..tostring(err))
   stage=6
  end
 end
end
