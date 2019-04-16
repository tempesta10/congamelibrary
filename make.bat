@echo off


dir /b *.asm > ml.rsp               : create a response file for ML.EXE
\masm32\bin\ml.exe /c /coff @ml.rsp
if errorlevel 0 goto okml
:::: del ml.rsp
echo ASSEMBLY ERROR BUILDING LIBRARY MODULES
pause
goto theend

:okml
\masm32\bin\link -lib *.obj /out:congame.lib
if exist congame.lib goto theend

echo LINK ERROR BUILDING LIBRARY
echo The ConGame Library was not built
goto theend

:theend
if exist congame.lib del *.obj

dir \masm32\congamelib\congame.lib
dir \masm32\congamelib\congame.inc
pause