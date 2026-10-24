--------------------------- 11 PAAOHJELMA
function setPalette()
 for i,c in ipairs(PAL) do
  poke(0x3FC0+(i-1)*3,c[1],c[2],c[3])
 end
end
function BOOT()
 setPalette()
 genTextures()
 genSprites()
 G.phase=S_TITLE
 G.menuSel=1
 G.msel=1
 G.frame=0
 G.zbuf={}
 for i=1,120 do G.zbuf[i]=1e9 end
 edInit()
end
function SND(id,note,vol,dur,ch)
 pcall(sfx,id,note or 55,dur or 4,ch or 0,vol or 10,-1)
end
function sfxShot() SND(0,55,10,4,0) end
function TIC()
 G.frame=G.frame+1
 local ph=G.phase
 if ph==S_TITLE then titlePhase()
 elseif ph==S_MENU then menuPhase()
 elseif ph==S_BRIEF then briefPhase()
 elseif ph==S_PLAN then planPhase()
 elseif ph==S_ACTION then actionPhase()
 elseif ph==S_DEBRIEF then debriefPhase()
 elseif ph==S_EDITOR then editorPhase()
 end
end
function MENU()
 if G.phase==S_ACTION or G.phase==S_PLAN then
  cls(0)
  print('TAUKO',100,50,15,false,2)
  print('ESC: jatka tehtavaa',70,80,11,false,1,true)
  print('(tehtava jatkuu mista jait)',64,92,2,false,1,true)
 end
end
