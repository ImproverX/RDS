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

copy /b bdos.obj+b7h.obj+font.bin+disp.obj+virt.obj+vird7.obj pack1.bin
lzsa -f1 -r pack1.bin pack1.pak
copy /b rdsh.obj+loaderkd.obj+ccph.obj+pack1.pak rds3042.rom