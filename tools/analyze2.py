import sys
sys.path.insert(0,'/workspace/tools')
from analyze_png import read_png, near_pal
w,h,rows=read_png(sys.argv[1])
for y in range(0,136,2):
    s=''
    for x in range(0,240,8):
        s+=str(near_pal(rows[y][x*3:x*3+3]))
    print(f'{y:3d} '+s)
