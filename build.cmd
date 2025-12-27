@echo off
setlocal

REM ----- Settings -----
set "MAIN=thesis.tex"
if not "%~1"=="" set "MAIN=%~1"
for %%F in ("%MAIN%") do set "BASE=%%~nF"
set "OUTDIR=out"
set "PDFLATEX_FLAGS=-interaction=nonstopmode -file-line-error -output-directory=%OUTDIR%"

REM ----- Prep -----
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

REM ----- Clean aux  -----
if /I "%~2"=="--clean" (
  del /q "%OUTDIR%\%BASE%.*" 2>nul
  goto :eof
)

REM ----- Manual build: pdflatex → biber → pdflatex → pdflatex -----
pdflatex %PDFLATEX_FLAGS% "%MAIN%" || exit /b 1

where biber >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
  echo [ERROR] biber not found (MiKTeX Console -> install biber) & exit /b 1
)

biber --output-directory "%OUTDIR%" "%BASE%" || exit /b 1

pdflatex %PDFLATEX_FLAGS% "%MAIN%" || exit /b 1
pdflatex %PDFLATEX_FLAGS% "%MAIN%" || exit /b 1

REM ----- Copy final PDF to root -----
copy /y "%OUTDIR%\%BASE%.pdf" "%BASE%.pdf" >nul

echo Build OK: "%OUTDIR%\%BASE%.pdf"
exit /b 0
