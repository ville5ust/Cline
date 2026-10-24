#!/usr/bin/env python3
"""Lightweight Lua block/paren balance checker + undefined-call lint.
Audits TIC-80 cart source without a Lua interpreter (sandbox has none).
Usage: python3 tools/check_lua.py cart/bareknuckle.lua
"""
import re, sys

BLOCK_OPEN = {"function", "if", "do", "while", "for", "repeat"}
BLOCK_CLOSE = {"end", "until"}
TIC_API = {
    "TIC","BDR","BOOT","SCANLINE","MENU","POSTINIT",
    "btn","btnp","cls","circ","circb","clip","elli","ellib","fget","fset","font",
    "key","keyp","line","map","mget","mset","mouse","music","peek","peek1","peek2","peek4",
    "pix","pmem","poke","poke1","poke2","poke4","print","rect","rectb","reset","rot","sfx",
    "spr","sprf","sync","time","trace","tri","trib","tstamp","vbank","exit","drawlabel",
    "str","memcpy","memset","load","save","ls","cd","mkdir","rm","print'","pmem",
}
STD = {"math","string","table","os","io","coroutine","pairs","ipairs","tonumber","tostring",
       "type","print","select","unpack","rawget","rawset","setmetatable","getmetatable","pcall",
       "error","assert","next","require","string","table","insert","remove","concat","floor",
       "random","randomseed","max","min","abs","sub","byte","char","rep","format","find","gmatch"}

def strip_code(src):
    out=[]; i=0; n=len(src)
    while i<n:
        c=src[i]
        if src.startswith("--[[",i):
            j=src.find("]]",i+4); i=(j+2) if j>=0 else n; continue
        if src.startswith("--",i):
            j=src.find("\n",i); i=(j+1) if j>=0 else n; continue
        if c in "\"'":
            q=c; i+=1
            while i<n:
                if src[i]=="\\": i+=2; continue
                if src[i]=="\n": break
                if src[i]==q: i+=1; break
                i+=1
            out.append(" STR "); continue
        if c=="[[":
            j=src.find("]]",i+2); i=(j+2) if j>=0 else n; out.append(" STR "); continue
        out.append(c); i+=1
    return "".join(out)

def tokens(code):
    return re.findall(
        r"[A-Za-z_][A-Za-z0-9_]*|\.\.\.|\.\.|==|<=|>=|~=|//|"
        r"[()\[\]{}+\-*/%^#,<>=:;.]", code)

def audit(path):
    src=open(path,encoding="utf-8").read()
    code=strip_code(src)
    tk=tokens(code)
    depth=0; expect_do=0; rep=0
    pd=pb=pc=0  # paren, bracket, brace depth
    errs=[]
    defined=set(); calls=[]
    assigned=set()
    for idx,t in enumerate(tk):
        prev=tk[idx-1] if idx else ""
        nxt=tk[idx+1] if idx+1<len(tk) else ""
        if t=="function": depth+=1
        elif t=="if": depth+=1
        elif t=="while" or t=="for": depth+=1; expect_do+=1
        elif t=="do":
            if expect_do>0: expect_do-=1
            else: depth+=1
        elif t=="repeat": depth+=1
        elif t=="end" or t=="until":
            depth-=1
            if depth<0: errs.append(f"line? extra '{t}'")
        elif t=="(": pd+=1
        elif t==")": pd-=1
        elif t=="[": pb+=1
        elif t=="]": pb-=1
        elif t=="{": pc+=1
        elif t=="}": pc-=1
        if pd<0 or pb<0 or pc<0: errs.append(f"negative bracket depth at token {idx} ({t})")
        # collect defs/calls
        if t=="function" and re.match(r"[A-Za-z_]",nxt or ""):
            defined.add(nxt)
        if re.match(r"[A-Za-z_]",t) and nxt=="(" and t not in BLOCK_OPEN and t not in {"if","while","for","return","and","or","not"}:
            calls.append(t)
        if prev=="local" or prev=="=":
            assigned.add(t)
    line="" 
    if depth!=0: errs.append(f"BLOCK IMBALANCE: net depth {depth}")
    if pd: errs.append(f"PAREN imbalance: {pd}")
    if pb: errs.append(f"BRACKET imbalance: {pb}")
    if pc: errs.append(f"BRACE imbalance: {pc}")
    api=set()
    for c in set(calls):
        if c not in defined and c not in TIC_API and c not in STD and c not in assigned:
            api.add(c)
    print(f"== AUDIT {path} ==")
    print(f"tokens: {len(tk)}, defined funcs: {len(defined)}, calls sampled: {len(set(calls))}")
    if api: print("POSSIBLY UNDEFINED CALLS:", sorted(api))
    else: print("undefined-call lint: clean")
    for e in errs: print("ERROR:", e)
    if not errs and not api:
        print("VERDICT: PASS (structural)")
    return 0 if not errs else 1

if __name__=="__main__":
    sys.exit(audit(sys.argv[1]))