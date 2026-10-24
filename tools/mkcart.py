#!/usr/bin/env python3
"""mkcart.py - rakentaa karhuryhma.tic -kortin.
Chunk-formaatti: [type:5|bank:3][size LE16][00] + data.
- CODE (5): pelin Lua-koodi
- PALETTE (12): 2 x 48 tavua (vbank 0/1)
- WAVEFORM (10): 16 aaltoa x 16 tavua (4-bittiset naytteet)
- SAMPLES (9): 64 efektiä x 66 tavua
Ks. TIC-80 src/cart.c"""
import struct, sys

# ---- paletti (sama kuin src/00_boot.lua PAL)
PAL = [
 (0x0a,0x0a,0x10),(0x22,0x22,0x2f),(0x55,0x55,0x6b),(0x9a,0x9a,0xb0),
 (0x3a,0x1f,0x16),(0x7a,0x3a,0x26),(0xbf,0x6a,0x42),(0x14,0x24,0x3d),
 (0x2f,0x5c,0x92),(0x6f,0xa3,0xd6),(0x2e,0x23,0x17),(0x6e,0x4d,0x2b),
 (0xb0,0x88,0x58),(0x12,0x3a,0x24),(0x3f,0xb9,0x6a),(0xf0,0xe9,0xcf)]

def chunk(t, bank, data):
    return struct.pack('<BHx', (bank<<5)|t, len(data)) + data

# ---- aallot: 32 naytetta, 4 bittia (0..15, 8 = nolla)
def pack_wave(samples):  # samples: 32 arvoa 0..15
    out = bytearray()
    for i in range(0, 32, 2):
        out.append((samples[i] & 0xF) | ((samples[i+1] & 0xF) << 4))
    return bytes(out)

import math
def wave_square():
    return [15 if (i < 16) else 0 for i in range(32)]
def wave_saw():
    return [max(0, 15 - int(i*15/31)) for i in range(32)]
def wave_tri():
    return [int(abs(2*i-31)*15/31) for i in range(32)]
def wave_noise(seed=7):
    x = seed
    out=[]
    for i in range(32):
        x = (x*109 + 89) % 251
        out.append(x & 0xF)
    return out
def wave_pulse():
    return [15 if (i % 8 < 3) else 0 for i in range(32)]
def wave_slide():
    return [int(8 + 7*math.sin(i/32*2*math.pi)) for i in range(32)]

WAVES = [wave_square(), wave_noise(3), wave_saw(), wave_tri(),
         wave_noise(11), wave_pulse(), wave_noise(23), wave_slide(),
         wave_square(), wave_noise(41), wave_saw(), wave_slide(),
         wave_noise(59), wave_tri(), wave_pulse(), wave_noise(77)]

# ---- efektit: tic_sample 66 tavua
# data[30]: (vol:4|wave:4 | chord:4|pitch:4) x 30
# header: [okt:3|p16:1|spd:3signed|rev:1] [note:4|L:1|R:1|tmp:2]
# loops: 4 x (start:4|size:4)
def effect(wave, vol0, vol1, note, octave, speed=0, pitch=0, chord=0):
    d = bytearray(66)
    for t in range(30):
        vol = int(vol0 + (vol1 - vol0) * t / 29)
        vol = max(0, min(15, vol))
        p = int(pitch * t / 29)
        d[t*2]   = (vol & 0xF) | ((wave & 0xF) << 4)
        d[t*2+1] = (chord & 0xF) | ((p & 0xF) << 4)
    # header
    d[60] = (octave & 0x7) | (0 << 3) | ((speed & 0x7) << 4) | (0 << 7)
    d[61] = (note & 0xF) | (1 << 4) | (1 << 5)  # stereo L+R
    return bytes(d)

SAMPLES = [
    # 0: laukaus - kohinaa + volyymiramppaus alas
    effect(1, 15, 2, 6, 3),
    # 1: osuma - kova napakka
    effect(2, 14, 4, 10, 2),
    # 2: ovi - nouseva saha
    effect(2, 6, 10, 4, 1, 0, 2),
    # 3: gokoodi - kaksi piippausta (aalto 6 pulssi)
    effect(5, 12, 12, 12, 3),
    # 4: valokranaattu - iso kohina
    effect(4, 15, 0, 2, 2),
    # 5: lataus - napakat klikit
    effect(3, 8, 8, 9, 3, 0, 4),
    # 6: viesti - pehmee tri
    effect(3, 9, 9, 14, 4),
    # 7: vinkuva osuma pelaajaan
    effect(1, 13, 6, 5, 4),
]
def build_samples():
    out = bytearray()
    for i in range(64):
        if i < len(SAMPLES):
            out += SAMPLES[i]
        else:
            out += b'\x00' * 66
    return bytes(out)

def build_palette():
    p = bytes(b for c in PAL for b in c)
    return p + p  # vbank 0 ja 1

def make_cart(code_file, out_file):
    code = open(code_file, 'rb').read()
    data = b''
    data += chunk(12, 0, build_palette())   # PALETTE
    data += chunk(10, 0, b''.join(pack_wave(w) for w in WAVES))  # WAVEFORM
    data += chunk(9, 0, build_samples())     # SAMPLES
    # koodi: max 64k per pankki
    assert len(code) <= 65536, f"koodi liian suuri: {len(code)}"
    data += chunk(5, 0, code)               # CODE
    open(out_file, 'wb').write(data)
    print(f"KORTTI: {out_file} ({len(data)} tavua, koodi {len(code)})")

if __name__ == '__main__':
    make_cart(sys.argv[1] if len(sys.argv)>1 else 'karhuryhma.lua',
              sys.argv[2] if len(sys.argv)>2 else 'karhuryhma.tic')
