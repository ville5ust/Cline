-- KARHURYHMA - taktinen FPS TIC-80:lle
-- (c) 2026 - suomalainen tasku-Rainbow :)
-- title: KARHURYHMA
-- desc: Tactical squad game w/ raycast 3D, planning & editor

------------------------------- 00 ALKU / KONFIG
SW,SH=240,136      -- nayton koko
FOV=0.7853982      -- 45 astetta? -> kentan puoli-avo
MW,MH=32,32        -- karttaruudukko
HALF=60            -- 120 sadea (2px pikselit)
SPEED=3.2/60       -- liikenopeus per frame (~3.2 ruutua/s)
TURN=2.8/60
-- seinatyypit
BRICK,CONCR,METAL,WOOD,DOORC=1,2,3,4,5
-- tilat
S_TITLE,S_MENU,S_BRIEF,S_PLAN,S_ACTION,S_DEBRIEF,S_EDITOR=0,1,2,3,4,5,6

PAL={
 {0x0a,0x0a,0x10},{0x22,0x22,0x2f},{0x55,0x55,0x6b},{0x9a,0x9a,0xb0},
 {0x3a,0x1f,0x16},{0x7a,0x3a,0x26},{0xbf,0x6a,0x42},{0x14,0x24,0x3d},
 {0x2f,0x5c,0x92},{0x6f,0xa3,0xd6},{0x2e,0x23,0x17},{0x6e,0x4d,0x2b},
 {0xb0,0x88,0x58},{0x12,0x3a,0x24},{0x3f,0xb9,0x6a},{0xf0,0xe9,0xcf}
}
-- tummentava LUT: LAPA[c]={tumma,itse,vaalea} (c=0..15)
LAPA={
 [0]={0,0,1},[1]={0,1,2},[2]={1,2,3},[3]={2,3,3},
 [4]={0,4,5},[5]={4,5,6},[6]={5,6,6},[7]={0,7,8},
 [8]={7,8,9},[9]={8,9,9},[10]={0,10,11},[11]={10,11,12},
 [12]={11,12,12},[13]={0,13,14},[14]={13,14,14},[15]={2,15,15}
}
-- Bayer 4x4 jarjestysditherointi (0..15) /16
BAY={
 [0]=0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5
}

----------------- RNG (mulberry32)
function mkran(seed)
 local a=seed&0xffffffff
 return function()
  a=a+0x6D2B79F5
  local t=a
  t=(t+0x165667B1)&0xffffffff
  t=(t~(t>>15))*(t|1)&0xffffffff
  t=t~(t+(t>>7))
  t=t~(t>>16)
  t=(t&0xffffffff)
  return (t&0x7fffffff)/2147483648
 end
end
