-- skenaario: kuvakaappaukset kaikista ruuduista
__MAX=900
local st=0
function __SCN(n)
 G.inj={} G.injP={}
 if n>=151 and n<=160 then G.inj[13]=true end
 if n==20 then SCR('01_TITLE')
 elseif n==22 then G.injP[50]=true -- TEHTAVAT
 elseif n==40 then SCR('02_MISSIONS')
 elseif n==42 then G.injP[50]=true -- M1 tiedote
 elseif n==60 then SCR('03_BRIEF')
 elseif n==62 then G.injP[50]=true -- suunnittelu
 elseif n==90 then
  -- lisaa reittipisteita suoraan
  G.plan[1].wps={{4,20,go=1},{8,16,go=0},{14,10,go=2}}
  G.plan[2].wps={{10,24,go=1},{16,20,go=0}}
  SCR('04_PLAN')
 elseif n==110 then G.injP[50]=true -- toiminta
 elseif n==150 then
  local m=G.members[G.player]
  m.x=8.5 m.y=20.5 m.ang=0
  local e=G.enemies[1] e.x=11.5 e.y=20.5 e.state=2
  SCR('05_ACTION')
 elseif n==152 then st2=true
 elseif n==160 then SCR('06_MAP')
 elseif n==162 then G.inj={}
 elseif n==200 then
  -- debrief-nakyma pakottamalla
  G.stats={shots=41,hits=13,kills=5,t=0}
  G.done=true G.phase=S_DEBRIEF
 elseif n==210 then SCR('07_DEBRIEF')
 elseif n==220 then
  G.phase=S_EDITOR edInit()
 elseif n==240 then
  -- piirra editoriin kamaa
  for y=8,20 do for x=8,20 do ED.cells[idx(x,y)]=0 end end
  for y=10,12 do for x=10,18 do ED.cells[idx(x,y)]=CONCR end end
  ED.objs={{t=5,x=9,y=9},{t=6,x=19,y=19},{t=1,x=16,y=15},{t=2,x=12,y=9},{t=4,x=9,y=18}}
  SCR('08_EDITOR')
 elseif n==260 then
  -- proseduraalinen harjoitus
  local md=genProcMap(12345,'rescue')
  if md then G.procMd=md G.phase=S_BRIEF G.briefFrom='proc' end
  T2('PROC '..(G.procMd and 'OK' or 'FAIL'))
 elseif n==280 then SCR('09_PROC_BRIEF')
 elseif n==282 then G.injP[50]=true
 elseif n==310 then SCR('10_PROC_PLAN')
 end
end
function T2(s) trace(s..string.char(10)) end
