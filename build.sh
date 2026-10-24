#!/bin/bash
# Karhuryhma - koontiskripti
# Rakentaa src/*.lua -> karhuryhma.lua (max 64kt TIC-80-koodipankki)
# Suodattaa kommentit pois (lahdekoodi pysyy luettavana)
set -e
cd "$(dirname "$0")"
OUT=karhuryhma.lua
FILES="src/00_boot.lua src/01_tex.lua src/02_spr.lua src/03_map.lua src/03b_missions.lua src/03c_maprt.lua src/04_game.lua src/05_render.lua src/06_hud.lua src/07_plan.lua src/08_action.lua src/09_editor.lua src/10_menu.lua src/11_main.lua"

if [ "$1" == "--test" ]; then
  SCEN="$2"; OUT="${3:-test/cart_test.lua}"
  for f in $FILES; do python3 tools/strip.py < "$f"; done > "$OUT"
  python3 tools/strip.py < "$SCEN" >> "$OUT"
  python3 tools/strip.py < test/autoquit.lua >> "$OUT"
else
  for f in $FILES; do python3 tools/strip.py < "$f"; done > "$OUT"
fi
SZ=$(wc -c < "$OUT")
echo "KOOTTI: $OUT ($SZ tavua / 65536 max)"
if [ "$SZ" -gt 65500 ]; then echo "VAROITUS: koodipankki ylitayteen!"; exit 1; fi
