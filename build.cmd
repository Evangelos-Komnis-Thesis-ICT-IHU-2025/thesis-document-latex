@echo off
setlocal

REM ----- Settings -----
set "MAIN=thesis.tex"
if not "%~1"=="" set "MAIN=%~1"
for %%F in ("%MAIN%") do set "BASE=%%~nF"
set "OUTDIR=out"
set "PDFLATEX_FLAGS=-interaction=nonstopmode -file-line-error -output-directory=%OUTDIR%"

REM ----- Tooling (MiKTeX default path fallback) -----
if not defined MIKTEX_BIN set "MIKTEX_BIN=%LOCALAPPDATA%\Programs\MiKTeX\miktex\bin\x64"
set "PDFLATEX=pdflatex"
set "BIBER=biber"
if exist "%MIKTEX_BIN%\pdflatex.exe" set "PDFLATEX=%MIKTEX_BIN%\pdflatex.exe"
if exist "%MIKTEX_BIN%\biber.exe" set "BIBER=%MIKTEX_BIN%\biber.exe"

REM ----- Prep -----
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

REM ----- Clean aux  -----
if /I "%~2"=="--clean" (
  for /r %%F in (*.aux *.out *.toc *.lof *.lot *.bcf *.run.xml *.bbl *.blg *.fdb_latexmk *.fls) do del /q "%%F" 2>nul
  del /q "%OUTDIR%\%BASE%.*" 2>nul
  goto :eof
)

REM Root-level biblatex aux files can shadow the fresh files produced in %OUTDIR%.
call :CleanRootArtifacts

REM ----- Manual build: pdflatex -> biber -> pdflatex -> pdflatex -----
call :RunPdfLaTeX "%MAIN%" || exit /b 1

if /I "%BIBER%"=="biber" (
  where biber >nul 2>&1
  if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] biber not found (MiKTeX Console -> install biber) & exit /b 1
  )
) else (
  if not exist "%BIBER%" (
    echo [ERROR] biber not found (MiKTeX Console -> install biber) & exit /b 1
  )
)

call :RunBiber "%BASE%" || exit /b 1
call :SyncRootArtifacts "%BASE%" || exit /b 1

call :RunPdfLaTeX "%MAIN%" || exit /b 1
call :RunPdfLaTeX "%MAIN%" || exit /b 1

call :SyncRootArtifacts "%BASE%" || exit /b 1

REM ----- Copy final PDF to root -----
copy /y "%OUTDIR%\%BASE%.pdf" "%BASE%.pdf" >nul

echo Build OK: "%OUTDIR%\%BASE%.pdf"
exit /b 0

REM ----- Helpers -----
:CleanRootArtifacts
for %%E in (aux bbl bcf blg run.xml toc lof lot out) do (
  if exist "%BASE%.%%E" del /q "%BASE%.%%E" 2>nul
)
exit /b 0

:SyncRootArtifacts
for %%E in (bbl toc lof lot out) do (
  if exist "%OUTDIR%\%~1.%%E" copy /y "%OUTDIR%\%~1.%%E" "%~1.%%E" >nul
)
exit /b 0

:RunPdfLaTeX
%PDFLATEX% %PDFLATEX_FLAGS% "%~1"
set "LATEX_EXIT=%ERRORLEVEL%"
if %LATEX_EXIT% EQU 0 exit /b 0

REM MiKTeX may return a nonzero exit code for update warnings. Continue if no fatal errors.
set "LOG=%OUTDIR%\%BASE%.log"
if not exist "%LOG%" exit /b %LATEX_EXIT%
findstr /I /R /C:"LaTeX Error" /C:"Package .* Error" /C:"Emergency stop" /C:"Fatal error" /C:"No pages of output" /C:"Runaway argument" /C:"File ended while scanning use of" /C:"Undefined control sequence" "%LOG%" >nul
if %ERRORLEVEL% EQU 0 exit /b 1
echo [WARN] pdflatex exited with code %LATEX_EXIT% but no fatal errors found. Continuing.
exit /b 0

:RunBiber
%BIBER% --output-directory "%OUTDIR%" "%~1"
set "BIBER_EXIT=%ERRORLEVEL%"
if %BIBER_EXIT% EQU 0 exit /b 0
if exist "%OUTDIR%\%~1.bbl" (
  echo [WARN] biber exited with code %BIBER_EXIT% but "%OUTDIR%\%~1.bbl" exists. Continuing.
  exit /b 0
)
exit /b %BIBER_EXIT%
