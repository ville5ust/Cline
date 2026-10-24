#!/usr/bin/env python3
"""analyze_png.py - analysoi kuvakaappauksen riveja (keskisarake)."""
import sys, zlib, struct

def read_png(fn):
    d = open(fn,'rb').read()
    pos = 8
    w=h=None; idat=b''
    while pos < len(d):
        ln = struct.unpack('>I', d[pos:pos+4])[0]
        typ = d[pos+4:pos+8]
        data = d[pos+8:pos+8+ln]
        if typ==b'IHDR':
            w,h,bd,ct = struct.unpack('>IIBB', data[:10])
        elif typ==b'IDAT':
            idat += data
        pos += 12+ln
    raw = zlib.decompress(idat)
    stride = w*3
    rows=[]
    prev=bytearray(stride)
    p=0
    for y in range(h):
        f = raw[p]; p+=1
        line = bytearray(raw[p:p+stride]); p+=stride
        # unfilter (vain tyyppi 0 tai 2)
        if f==2:
            for i in range(stride):
                line[i]=(line[i]+prev[i])&0xff
        rows.append(bytes(line))
        prev=line
    return w,h,rows

PAL = [
 (0x0b,0x0b,0x12),(0x25,0x25,0x38),(0x4a,0x4a,0x63),(0x8f,0x8f,0xa8),
 (0x33,0x20,0x1a),(0x6b,0x3a,0x29),(0xa8,0x61,0x3f),(0x17,0x26,0x3f),
 (0x2a,0x4d,0x7d),(0x5a,0x8f,0xbf),(0x2e,0x23,0x17),(0x64,0x49,0x2b),
 (0xa0,0x7d,0x52),(0x11,0x3b,0x2b),(0x35,0xa4,0x5c),(0xec,0xe5,0xc8)]

def near_pal(rgb):
    best=0; bd=1e9
    for i,p in enumerate(PAL):
        d=sum((a-b)**2 for a,b in zip(rgb,p))
        if d<bd: bd=d; best=i
    return best

if __name__=='__main__':
    fn=sys.argv[1]
    w,h,rows=read_png(fn)
    print(f'{fn}: {w}x{h}')
    # keskisarakkeen varit riveittain (x=120 ja x=60)
    for x in (60,120,180):
        seq=[]
        for y in range(0,h,4):
            rgb=rows[y][x*3:x*3+3]
            seq.append(str(near_pal(rgb)))
        print(f'x={x}: '+''.join(seq))
