-- AUTOQUIT-kirjekuori (vain testikartoissa)
local __TIC=TIC
local CHR10=string.char(10)
local __n=0
function TIC()
 local ok,err=pcall(__TIC)
 if not ok then
  trace('RUNTIME-ERROR: '..tostring(err))
  trace('AUTOEXIT-ERR n='..__n)
  exit()
 end
 __n=__n+1
 local ok2,err2=pcall(__SCN,__n)
 if not ok2 then
  trace('SCENARIO-ERROR: '..tostring(err2))
  trace('AUTOEXIT-ERR n='..__n)
  exit()
 end
 if __n%120==0 then
  trace('PROG n='..__n..' phase='..tostring(G and G.phase))
 end
 if __n>=__MAX then
  trace('AUTOEXIT OK n='..__n..' phase='..tostring(G and G.phase))
  exit()
 end
end
function SCR(label)
 trace('SCR:'..tostring(label))
 for y=0,135 do
  local row=''
  for x=0,239 do
   row=row..string.format('%x',peek4(y*240+x))
  end
  trace('SCR:'..row..CHR10)
 end
 trace('SCREND:'..tostring(label)..CHR10)
end
BOOT()
