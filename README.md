# README — Building the Thesis PDF (Windows)

This repo includes a simple **Windows CMD** script to compile your thesis with the sequence:
**`pdflatex` → `biber` → `pdflatex` → `pdflatex`**,  
writing all intermediate files to the `out/` folder.

---

## Prerequisites

- **MiKTeX** (or TeX Live for Windows)
- Installed tools: `pdflatex`, **`biber`**
  - MiKTeX Console → *Packages* → search **biber** → *Install*
- Recommended viewer that **doesn’t lock files**: **SumatraPDF**

---

## Suggested folder layout

```
project-root/
├─ thesis.tex              # main entry file
├─ references.bib
├─ build.cmd               # the script
├─ out/                    # created automatically
└─ chapters/...            # chapters (if you use \include)
```

---

## Usage

Open **Command Prompt** in the folder that contains `build.cmd`:

```bat
build                 REM builds thesis.tex
build myfile.tex      REM builds a different .tex as main
build myfile.tex --clean
```

> Note: The `--clean` flag is recognized as the **second** argument (e.g., `build thesis.tex --clean`).  
> It clears intermediates for *that specific file* inside `out/`.

After a successful build:
- The final PDF is at **`out/thesis.pdf`**
- It is also copied to the repo root as **`thesis.pdf`**

---

## What the script does

1. Creates the **`out/`** folder if it doesn’t exist.
2. Runs:
   - `pdflatex -interaction=nonstopmode -file-line-error -output-directory=out thesis.tex`
   - `biber --output-directory out thesis`
   - `pdflatex ...`
   - `pdflatex ...`
3. Copies **`out/thesis.pdf`** to the repo root as `thesis.pdf`.

---

## Configuration

Change defaults in `build.cmd`:
```bat
set "MAIN=thesis.tex"   # default main .tex
set "OUTDIR=out"        # output directory
```
(You can always pass a different main file as the first argument: `build mymain.tex`.)

---

## Tips

- Always open **`out/thesis.pdf`** (it’s the source of truth).
- Add `out/` to your **.gitignore**.
- Never redirect console output to the PDF (e.g., `build > thesis.pdf`)—it will corrupt it.
