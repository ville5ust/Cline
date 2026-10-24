#!/usr/bin/env python3
"""strip.py - poistaa kommentit ja tyhjat rivit (stdin->stdout).
Sailyttaa merkkijonot: poistaa vain rivit, jotka alkavat '--',
seka loppukommentit muodossa ' -- ...' kun rivilla ei ole auki olevaa
merkkijonoa ennen kommenttia. Kutistaa myos sisennyksen yhteen valilyöntiin
(Lua ei valita sisennyksesta)."""
import sys, re
out = []
for ln in sys.stdin:
    s = ln.rstrip('\n')
    if re.match(r'^\s*--', s):
        continue
    if s.strip() == '':
        continue
    m = re.search(r'\s--\s', s)
    if m:
        head = s[:m.start()]
        if head.count('"') % 2 == 0 and head.count("'") % 2 == 0:
            s = head.rstrip()
    # kutista sisennys: johtavat valilyonnit -> yksi
    if s.startswith(' '):
        s = ' ' + s.lstrip(' ')
    out.append(s)
sys.stdout.write('\n'.join(out) + '\n')
