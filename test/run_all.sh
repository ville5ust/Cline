#!/bin/bash
# Karhuryhma - automatisoitu testiputki
# Ajaa skenaariot oikeassa TIC-80:ssa (headless) ja tarkistaa tulokset.
set -e
cd "$(dirname "$0")/.."

TIC=./tools/tic80
export LD_LIBRARY_PATH="$PWD/tools/lib/usr/lib/x86_64-linux-gnu"

if [ ! -x "$TIC" ]; then
  echo "VIRHE: tools/tic80 puuttuu. Lataa TIC-80 CLI (ks. README)."
  exit 1
fi

mkdir -p test/fs test/shots
FAIL=0

run_scenario() {
  local scen="$1" name="$2" expect="${3:-OK}"
  echo "=== $name ($scen) ==="
  ./build.sh --test "$scen" "test/cart_${name}.lua" > /dev/null
  if ! tools/luac -p "test/cart_${name}.lua"; then
    echo "  SYNTAKSIVIRHE"; FAIL=1; return
  fi
  python3 tools/mkcart.py "test/cart_${name}.lua" "test/fs/${name}.tic" > /dev/null
  SDL_VIDEODRIVER=offscreen timeout 40 stdbuf -oL "$TIC" --cli --soft \
    --fs="$PWD/test/fs" --cmd "load ${name}.tic & run & exit" \
    > "test/out_${name}.log" 2>&1 || true
  if grep -q 'RUNTIME-ERROR\|SCENARIO-ERROR' "test/out_${name}.log"; then
    echo "  AJOVIRHE:"; grep -o 'RUNTIME-ERROR.*\|SCENARIO-ERROR.*' "test/out_${name}.log" | head -3
    FAIL=1
  elif grep -q 'AUTOEXIT OK' "test/out_${name}.log"; then
    echo "  OK ($(grep -o 'AUTOEXIT OK n=[0-9]* phase=[0-9]*' "test/out_${name}.log"))"
    if [ -n "$expect" ] && [ "$expect" != "OK" ]; then
      grep -q "$expect" "test/out_${name}.log" && echo "  tarkistus '$expect' OK" \
        || { echo "  tarkistus '$expect' PUUTTUU"; FAIL=1; }
    fi
  else
    echo "  EI LOPETTANUT AJOJA:"; tail -3 "test/out_${name}.log"; FAIL=1
  fi
}

run_scenario test/scen_smoke.lua smoke
run_scenario test/scen_full.lua full "DEBRIEF! done=true"
run_scenario test/scen_sys.lua sys "PMEM load=true"
run_scenario test/scen_shots.lua shots
run_scenario test/scen_diag.lua diag

echo "=== kuvakaappaukset ==="
python3 tools/decode_scr.py test/out_shots.log test/shots | tail -2

if [ $FAIL -eq 0 ]; then echo "KAIKKI TESTIT LAPI"; else echo "TESTEJA EPAONNISTUI"; exit 1; fi
