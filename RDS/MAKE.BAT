@echo off
set TASMTABS=D:\TASM
set TASMOPTS=-85 -b

tasm bdosbios.asm
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

copy /b loaderkd.obj+ccph.obj+bdosbios.obj+font.bin+disp.obj+vird7.obj+virt.obj pack1.bin
lzsa -f1 -r pack1.bin pack1.pak
copy /b rdsh.obj+pack1.pak rds308.rom
