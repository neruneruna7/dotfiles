---
name: "pdf"
description: "Use when tasks involve reading, creating, or reviewing PDF fileswhere rendering and layout matter; prefer visual checks by rendering pages(Poppler) and use Python tools such as `reportlab`, `pdfplumber`, and `pypdf`for generation and extraction."
---

# PDF Skill

## Policy
- Python execution must be done via `uv` only.
- Never modify machine-global Python environments (`--system`, user-site,
global pip).
- Prefer ephemeral execution with `uv run --with ...`.
- Keep caches and temporary artifacts under workspace-local `tmp/` so they are
disposable.
- Avoid commands that affect the whole machine (for example, automatic
`brew` / `apt` installs).

## When to use
- Read or review PDF content where layout and visuals matter.
- Create PDFs programmatically with reliable formatting.
- Validate final rendering before delivery.

## Workflow
1. Prepare disposable local directories before any `uv` command.
    - `mkdir -p tmp/.cache/uv tmp/.cache/python tmp/pdfs`
2. Prefer visual review: render PDF pages to PNGs and inspect them.
    - Use `pdftoppm` if available.
    - If unavailable, tell the user what is missing and ask for local
installation or manual review.
3. Run Python tasks with one-shot dependencies via `uv run --with ...`.
4. Use `reportlab` to generate PDFs when creating new documents.
5. Use `pdfplumber` (or `pypdf`) for text extraction and quick checks; do not
rely on it for layout fidelity.
6. After each meaningful update, re-render pages and verify alignment,
spacing, and legibility.

## Temp and output conventions
- Use `tmp/pdfs/` for intermediate files; delete when done.
- Write final artifacts under `output/pdf/` when working in this repo.
- Keep filenames stable and descriptive.

## Dependency execution (no global install)
Use this environment prefix for every `uv` Python command:

`UV_CACHE_DIR=tmp/.cache/uv UV_PYTHON_CACHE_DIR=tmp/.cache/python`

Example (one-shot import check):
```bash
UV_CACHE_DIR=tmp/.cache/uv UV_PYTHON_CACHE_DIR=tmp/.cache/python \
uv run --with reportlab --with pdfplumber --with pypdf \
python -c "import reportlab, pdfplumber, pypdf; print('ok')"

Example (run script):

UV_CACHE_DIR=tmp/.cache/uv UV_PYTHON_CACHE_DIR=tmp/.cache/python \
uv run --with reportlab --with pdfplumber --with pypdf python scripts/
pdf_task.py

Forbidden:

- uv pip install ... --system
- python3 -m pip install ... (global/user context)
- Any global package mutation outside the workspace

## Environment

Required for uv commands in this skill:

- UV_CACHE_DIR=tmp/.cache/uv
- UV_PYTHON_CACHE_DIR=tmp/.cache/python

Rules:

- Always create cache directories before first use.
- Always pass both environment variables with uv commands.

## Rendering command

pdftoppm -png $INPUT_PDF $OUTPUT_PREFIX

## Quality expectations

- Maintain polished visual design: consistent typography, spacing, margins,
  and section hierarchy.
- Avoid rendering issues: clipped text, overlapping elements, broken tables,
  black squares, or unreadable glyphs.
- Charts, tables, and images must be sharp, aligned, and clearly labeled.
- Use ASCII hyphens only. Avoid U+2011 (non-breaking hyphen) and other Unicode
  dashes.
- Citations and references must be human-readable; never leave tool tokens or
  placeholder strings.

## Final checks

- Do not deliver until the latest PNG inspection shows zero visual or
  formatting defects.
- Confirm headers/footers, page numbering, and section transitions look
  polished.
- Keep intermediate files organized or remove them after final approval.
