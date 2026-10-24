--------------------------- 02 SPRITET
-- merkkigrafiikka -> pikselitaulukko, s = sakeita {w,h,px}
-- merkit: .=lapsonna J=puseri tumna j=puseri K=puseri vaalea
--         s=iho g=ase b=saapas a=aksentti/ryhma E=silma/varuste
local function ch2c(ch,skin,jd,jm,jl,acc)
 if ch=='.' then return -1 end
 if ch=='J' then return jd end
 if ch=='j' then return jm end
 if ch=='K' then return jl end
 if ch=='s' then return skin end
 if ch=='g' then return 0 end
 if ch=='b' then return jd end
 if ch=='a' then return acc end
 if ch=='E' then return 0 end
 return -1
end
local function mkspr(art,skin,jd,jm,jl,acc)
 local h=#art local w=#art[1]
 local s={w=w,h=h,px={},jd=jd,jm=jm,jl=jl,skin=skin,acc=acc}
 for y=1,h do
  s.px[y]={}
  for x=1,w do
   s.px[y][x]=ch2c(art[y]:sub(x,x),skin,jd,jm,jl,acc)
  end
 end
 return s
end
-- jalat -2 framerosta: frame0 suoraan, frame1 askel
local function legs(v)
 if v==0 then return {'.a..a.','..aa..','..b.b.','..b.b.'} end
 if v==1 then return {'..a.a.','.a...a','.b...b','.b...b'} end
 return {'.a..a.','.a..a.','..bb..','..bb..'} end
local function mkbody(leg,gun)
 return {
 '.JaaaaJ.'..(gun and '.g' or '..'),
 'JjjjjjjJ'..(gun and 'gg' or '..'),
 'JjsssjjJ'..(gun and 'gg' or '..'),
 '.JEsEJ..'..(gun and '..' or '..'),
 '.JjjjJ..'..(gun and '..' or '..'),
 '.jjjj...'..(gun and 'gg' or '..'),
 '.jjjj...'..(gun and 'g.' or '..'),
 table.unpack(legs(leg))
 }
end
local function mkdead()
 local a={
 '........',
 '........',
 '........',
 '........',
 '........',
 '........',
 '..sss...',
 '.JjjJgg.',
 'Jjjjjjjgg',
 }
 return a
end
local function mkhostage()
 return {
 '.ssss...',
 '.sEsE...',
 '.jssj...',
 '.jjjj...',
 '..jj..g.',
 '..jj....',
 '..bb....',
 '..bb....'
 }
end
local function mkbomb()
 return {
 '.....a..',
 '.aaaaaa.',
 'aJJJJJJj',
 'aJjjjjJj',
 'aJjEEjJj',
 'aJjjjjJj',
 '.aaaaaa.',
 '........'
 }
end
local function mkflash()
 return {
 '..aa..',
 '.aEEa.',
 '.aEEa.',
 '..aa..',
 '......',
 '..gg..'
 }
end
SPR={}
function genSprites()
 -- vihollinen: tiilipuseri (4/5/6), iho 15, aksentti 6
 SPR.ew0=mkspr(mkbody(0,false),15,0,1,2,6)
 SPR.ew1=mkspr(mkbody(1,false),15,0,1,2,6)
 SPR.eaim=mkspr(mkbody(2,true),15,0,1,2,6)
 SPR.edead=mkspr(mkdead(),15,0,1,2,6)
 SPR.tw0=mkspr(mkbody(0,false),15,7,8,9,15)
 SPR.tw1=mkspr(mkbody(1,false),15,7,8,9,15)
 SPR.taim=mkspr(mkbody(2,true),15,7,8,9,15)
 SPR.host=mkspr(mkhostage(),15,10,11,12,14)
 SPR.bomb=mkspr(mkbomb(),15,1,2,3,6)
 SPR.flash=mkspr(mkflash(),15,1,2,3,9)
end
