--------------------------- 03 KARTTA
function idx(x,y) return y*MW+x+1 end
function cellAt(x,y)
 if x<0 or y<0 or x>=MW or y>=MH then return BRICK end
 return G.map.cells[idx(x,y)]
end
function isWall(x,y) -- taynainen seina?
 local c=cellAt(x,y)
 return c>=1 and c<=4
end
function doorAt(x,y) -- oven-data tai nil
 return G.map.doors[idx(x,y)]
end
-- voiko liikkua soluun (ove huomioiden)
function passable(x,y)
 if x<0 or y<0 or x>=MW or y>=MH then return false end
 local c=G.map.cells[idx(x,y)]
 if c==0 then return true end
 if c==DOORC then
  local d=G.map.doors[idx(x,y)]
  return d and d.o>0.65
 end
 return false
end
-- NAKOYHTEYS: DDA viiva, seina tai kiinni-ove katkaisee
function los(x0,y0,x1,y1)
 local dx,dy=x1-x0,y1-y0
 local dist=math.sqrt(dx*dx+dy*dy)
 if dist<0.001 then return true end
 local sx,sy=dx/dist,dy/dist
 local cx,cy=math.floor(x0),math.floor(y0)
 local tx,ty=math.floor(x1),math.floor(y1)
 local steps=math.floor(dist*3)+1
 local t=0
 while steps>0 do
  local nx,ny=x0+sx*t*dist,y0+sy*t*dist
  local ccx,ccy=math.floor(nx+sx*0.01),math.floor(ny+sy*0.01)
  if ccx==tx and ccy==ty then return true end
  local c=cellAt(ccx,ccy)
  if c>=1 and c<=4 then return false end
  if c==DOORC then
   local d=G.map.doors[idx(ccx,ccy)]
   if d.o<0.5 then return false end
  end
  t=t+1/3
  steps=steps-1
 end
 return true
end
-- A*-reitinhaku (32x32, ovet lapasyna)
function findPath(x0,y0,x1,y1)
 if x0==x1 and y0==y1 then return {{x1,y1}} end
 local W=MW
 local open={} local came={} local gs={}
 local hcost=function(x,y) return math.abs(x-x1)+math.abs(y-y1) end
 local s0=idx(x0,y0) local s1=idx(x1,y1)
 gs[s0]=0
 open[#open+1]={s0,hcost(x0,y0)}
 local inopen={} inopen[s0]=true
 local found=false
 local iter=0
 while #open>0 do
  iter=iter+1 if iter>2000 then return nil end
  -- etsi paras
  local bi=1 local bv=open[1][2]
  for i=2,#open do if open[i][2]<bv then bv=open[i][2] bi=i end end
  local cur=open[bi][1]
  open[bi]=open[#open] open[#open]=nil inopen[cur]=false
  local cx,cy=(cur-1)%W,math.floor((cur-1)/W)
  if cur==s1 then found=true break end
  for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
   local nx,ny=cx+d[1],cy+d[2]
   if passable(nx,ny) or (nx==x1 and ny==y1) then
    local ni=idx(nx,ny)
    local ng=(gs[cur] or 0)+1
    if gs[ni]==nil or ng<gs[ni] then
     gs[ni]=ng came[ni]=cur
     local f=ng+math.abs(nx-x1)+math.abs(ny-y1)
     if not inopen[ni] then
      open[#open+1]={ni,f} inopen[ni]=true
     end
    end
   end
  end
 end
 if not found then return nil end
 -- rekonstruoi
 local path={} local cur=s1
 while cur and cur~=s0 do
  path[#path+1]={(cur-1)%W,math.floor((cur-1)/W)}
  cur=came[cur]
 end
 local rev={}
 for i=#path,1,-1 do rev[#rev+1]=path[i] end
 return rev
end
