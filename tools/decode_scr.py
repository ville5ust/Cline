#!/usr/bin/env python3
"""decode_scr.py - muuntaa testilokin SCR-rivit PNG-kuviksi.
Kaytto: python3 tools/decode_scr.py LOGFILE [hakemisto]"""
import sys, os, re

PAL = [
 (0x0b,0x0b,0x12),(0x25,0x25,0x38),(0x4a,0x4a,0x63),(0x8f,0x8f,0xa8),
 (0x33,0x20,0x1a),(0x6b,0x3a,0x29),(0xa8,0x61,0x3f),(0x17,0x26,0x3f),
 (0x2a,0x4d,0x7d),(0x5a,0x8f,0xbf),(0x2e,0x23,0x17),(0x64,0x49,0x2b),
 (0xa0,0x7d,0x52),(0x11,0x3b,0x2b),(0x35,0xa4,0x5c),(0xec,0xe5,0xc8)]

def decode(logfile, outdir):
    os.makedirs(outdir, exist_ok=True)
    data = open(logfile, encoding='utf-8', errors='replace').read()
    shots = []          # (label, rows)
    cur = None
    rows = []
    label = None
    for tok in data.split('SCR:')[1:]:
        # etsi rivin lopetus: kay lapi kunnes SCREND tai ei-hex
        # rivit paattyvat rivinvaihtoon (CHR10)
        # muoto: <hex240>\n  ... viimeisella rivilla SCREND:<label>\n
        if tok.startswith('SCREND') or 'SCREND' in tok[:20]:
            m = re.match(r'SCREND:(.*)', tok)
            if m and label is not None:
                shots.append((label, rows))
            label, rows = None, []
            cur = None
            continue
        # label-rivi tai kuvarivi
        m = re.match(r'([0-9a-f]{240})', tok)
        if m:
            rows.append(m.group(1))
        else:
            # uusi label: vanha kuva sulkeutuu
            if label is not None and rows:
                shots.append((label, rows))
            label = tok.strip().split('\n')[0].strip()
            rows = []
    if label is not None and rows:
        shots.append((label, rows))
    out = []
    for label, rows in shots:
        if len(rows) != 136:
            print(f'VAROITUS {label}: {len(rows)} rivia (ei 136)')
        img = bytearray()
        for row in rows[:136]:
            for h in row.ljust(240,'0')[:240]:
                img += bytes(PAL[int(h, 16)])
        png = write_png(240, 136, bytes(img))
        fn = os.path.join(outdir, f'{label or "shot"}.png')
        open(fn, 'wb').write(png)
        out.append(fn)
    return out

def write_png(w, h, rgb):
    import zlib, struct
    def chunk(t, d):
        c = struct.pack('>I', len(d)) + t + d
        return c + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    raw = b''
    stride = w * 3
    for y in range(h):
        raw += b'\x00' + rgb[y*stride:(y+1)*stride]
    return (b'\x89PNG\r\n\x1a\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 6))
            + chunk(b'IEND', b''))

if __name__ == '__main__':
    log = sys.argv[1]
    outdir = sys.argv[2] if len(sys.argv) > 2 else '/workspace/test/shots'
    files = decode(log, outdir)
    for f in files:
        print('KUVA:', f)
    if not files:
        print('EI KUVIA!')
