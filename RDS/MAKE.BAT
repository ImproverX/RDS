@echo off
set TASMTABS=D:\Work\~TASM
set TASMOPTS=-85 -b

tasm b7h.asm
if ERRORLEVEL 1 pause
tasm bdos.asm
if ERRORLEVEL 1 pause
tasm ccph.asm
if ERRORLEVEL 1 pause
tasm disp.asm
if ERRORLEVEL 1 pause
tasm loaderkd.asm
if ERRORLEVEL 1 pause
tasm rdsh.asm
if ERRORLEVEL 1 pause
tasm vird7.asm
if ERRORLEVEL 1 pause
tasm virt.asm
if ERRORLEVEL 1 pause

copy /b ccph.obj+bdos.obj+b7h.obj+vird7.obj+font.bin+disp.obj+virt.obj pack1.bin
lzsa -f1 -r pack1.bin pack1.pak
copy /b rdsh.obj+loaderkd.obj+pack1.pak rds307.rom
