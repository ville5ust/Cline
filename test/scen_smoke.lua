-- skenaario: savutesti - kay startupista toimintaan ja ammu
__MAX=420
local stage=0
function __SCN(n)
 G.inj={} G.injP={}
 if stage==0 then
  if n>=20 then
   G.injP[50]=true -- ENTER: valitse TEHTAVAT
   if n>=21 then stage=1 end
  end
 elseif stage==1 then
  if n>=40 then G.injP[50]=true end -- ENTER: tiedote M1
  if G.phase==2 then stage=2 end
 elseif stage==2 then
  if n==60 then G.injP[50]=true end
  if n>62 and G.phase==3 then stage=3 end
 elseif stage==3 then
  if n==90 then SCR('PLAN') end
  if n>=110 then G.injP[50]=true end
  if G.phase==4 then stage=4 end
 elseif stage==4 then
  if n==140 then SCR('ACTION1') end
  G.inj[23]=true -- W eteen
  if n>=250 then
   G.inj={}
   if n==280 then SCR('ACTION2') end
  end
  if n>=380 then
   G.inj[13]=true -- M: kartta
   if n==400 then SCR('MAP') end
  end
 end
end
