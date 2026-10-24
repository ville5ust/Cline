--------------------------- 10 VALIKOT
function titlePhase()
 cls(0)
 -- animoitu tausta: kohinaa + liikkuvat viivat
 local t=G.frame
 for i=0,20 do
  local y=(t*0.2+i*7)%136
  line(0,y,239,y,1)
 end
 -- logo
 print('KARHURYHMA',33,30,15,false,3)
 print('KARHURYHMA',34,31,2,false,3)
 print('TAKTINEN ERIKOISYKSIKO',42,62,11,false,1,true)
 print('v1.0  TIC-80',170,126,2,false,1,true)
 local items={'TEHTAVAT','HARJOITUS (SATUNNAINEN)','EDITORI','OHJEET'}
 local sel=G.menuSel or 1
 for i,it in ipairs(items) do
  local col=i==sel and 14 or 11
  print((i==sel and '> ' or '  ')..it,72,78+i*12,col)
 end
 if btnp(2) or kdp(60) then G.menuSel=((sel-2)%#items)+1 end
 if btnp(3) or kdp(61) then G.menuSel=(sel%#items)+1 end
 if btnp(4) or kdp(50) then
  if sel==1 then G.phase=S_MENU G.msel=1
  elseif sel==2 then
   local objs={'kill','rescue','defuse','killrescue','defusekill'}
   local md=genProcMap(math.random(99999),objs[math.random(#objs)])
   if md then
    G.procMd=md
    G.phase=S_BRIEF G.briefFrom='proc'
   end
  elseif sel==3 then G.phase=S_EDITOR edInit()
  else G.phase=S_BRIEF G.briefFrom='help' end
 end
end
function menuPhase()
 cls(0)
 print('TEHTAVAT',4,4,15,false,1,true)
 local sel=G.msel or 1
 for i=1,6 do
  local md
  if i==6 then md={name='OP.TOISTO',loc='SATUNNAINEN HARJOITUS'}
  else md=MIS[i] end
  local col=i==sel and 14 or 11
  print((i==sel and '> ' or '  ')..md.name..' - '..md.loc,8,18+i*12,col,false,1,true)
 end
 print('nuolet: valitse  Z/ENTER: tiedote',4,124,11,false,1,true)
 print('ESC: takaisin',4,130,2,false,1,true)
 if btnp(2) or kdp(60) then G.msel=((sel-2)%6)+1 end
 if btnp(3) or kdp(61) then G.msel=(sel%6)+1 end
 if btnp(4) or kdp(50) then
  if sel==6 then
   local objs={'kill','rescue','defuse','killrescue','defusekill'}
   local md=genProcMap(math.random(99999),objs[math.random(#objs)])
   if md then G.procMd=md G.phase=S_BRIEF G.briefFrom='proc' end
  else
   G.phase=S_BRIEF G.briefFrom=sel
  end
 end
 if kdp(66) then G.phase=S_TITLE end
end
function briefPhase()
 cls(0)
 local md
 if G.briefFrom=='proc' then md=G.procMd
 elseif G.briefFrom=='help' then
  print('OHJEET',4,4,15,false,2)
  local lines={
   'LIIKE: nuolet/WASD  KAANTO: <- ->',
   'TULITA: Z/hiiri  TOIMINTA: E',
   'VALOKRANAATTI: F  LATAUS: R',
   'JASEN VAIHTO: TAB  GOKOODIT: 1 2 3',
   'KARTTA: M (pohjassa)  TAUKO: ESC',
   'SUUNNITTELU:',
   ' hiiri = reittipiste',
   ' Q = ryhma  1-3 = gokoodi',
   ' oikea klik = poista piste',
   ' SHIFT+klik = alkupaikka',
   ' ENTER = aloita toiminta',
  }
  for i,l in ipairs(lines) do print(l,8,26+i*10,15,false,1,true) end
  if kdp(50) or btnp(4) or kdp(66) then G.phase=S_TITLE end
  return
 end
 md=G.procMd or MIS[G.briefFrom]
 G.pendingMd=md
 print(md.name,4,4,15,false,2)
 print(md.loc,4,24,11,false,1,true)
 print('TIETOA:',4,40,14,false,1,true)
 -- rivita brief
 local words={}
 for w in md.brief:gmatch('%S+') do words[#words+1]=w end
 local line='' local y=52
 for _,w in ipairs(words) do
  if #line+#w+1>44 then
   print(line,4,y,15,false,1,true) y=y+9 line=w
  else
   if line=='' then line=w else line=line..' '..w end
  end
 end
 if line~='' then print(line,4,y,15,false,1,true) y=y+9 end
 local objnames={kill='NEUTRALOI VIHOLLISET',rescue='VAPAUTA PANTTIVANKI',
  defuse='PURKA POMMIT',killrescue='TYHJENNA+VAPAUTA',
  defusekill='PURKA+TYHJENNA'}
 print('TAVOITE: '..(objnames[md.obj] or md.obj),4,y+6,14,false,1,true)
 print('RYHMA: SUSI & KARHU (2+2)',4,y+16,11,false,1,true)
 print('Z/ENTER: SUUNNITTELU  ESC: TAKAISIN',4,126,11,false,1,true)
 if kdp(50) or btnp(4) then
  local plan=G.plans and G.plans[md] or nil
  loadMission(md,plan)
  initPlanState()
  G.phase=S_PLAN
 end
 if kdp(66) then G.phase=S_MENU end
end
function debriefPhase()
 cls(0)
 if G.done then
  print('TEHTAVA ONNISTUI!',40,20,14,false,2)
 else
  print('TEHTAVA EPAONNISTUI',40,20,4,false,2)
 end
 local st=G.stats
 local mins=math.floor(G.t/60) local secs=math.floor(G.t%60)
 print('AIKA:      '..string.format('%02d:%02d',mins,secs),40,50,15,false,1,true)
 print('LAUKAUKSIA: '..st.shots,40,60,15,false,1,true)
 print('OSUMIA:    '..st.hits,40,70,15,false,1,true)
 print('NEUTRALOITU: '..st.kills,40,80,15,false,1,true)
 local alive=0
 for _,m in ipairs(G.members) do if m.alive then alive=alive+1 end end
 print('RYHMASTA ELOSSA: '..alive..'/4',40,90,15,false,1,true)
 print('R: YRITA UUDELLEEN (SUUNNITTELU)',40,108,11,false,1,true)
 print('ENTER: VALIKKOON',40,118,11,false,1,true)
 if kdp(18) then
  loadMission(G.md,G.plan)
  initPlanState()
  G.phase=S_PLAN
 end
 if kdp(50) then
  G.phase=G.fromEditor and S_EDITOR or S_MENU
  G.fromEditor=false
 end
end
