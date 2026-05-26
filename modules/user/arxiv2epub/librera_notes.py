#!/usr/bin/env python3
"""
librera-notes — sync Librera Reader highlights into per-paper markdown notes.

Usage:
  librera-notes <query>       # query = epub filename fragment, arxiv ID, or paper number
  librera-notes --list        # list all books that have highlights

Environment:
  NOTES_DIR     where note .md files live  (default: ~/EDF/bibliography/notes)
  LIBRERA_DIR   where app-Bookmarks.json lives after Syncthing sync
                (default: ~/EDF/bibliography/.librera)

Workflow:
  1. In Syncthing Android: share Librera's data folder (Books/Librera/)
  2. On desktop: receive it at ~/EDF/bibliography/.librera/
  3. Run: librera-notes 2402.10957   (arxiv ID, or any fragment of the epub filename)

The script finds app-Bookmarks.json, extracts highlights for the matching book,
and writes/updates NOTES_DIR/<query-derived-name>.md.  Everything above the
sentinel comment is preserved as your manual notes; highlights are regenerated
below it each run.
"""
import json
import os
import sys
from pathlib import Path
from datetime import datetime, timezone

NOTES_DIR  = Path(os.environ.get("NOTES_DIR",  Path.home() / "EDF/bibliography/notes"))
LIBRERA_DIR = Path(os.environ.get("LIBRERA_DIR", Path.home() / "EDF/bibliography/.librera"))

SENTINEL = "<!-- librera-notes: auto-generated highlights — edit above this line only -->"

NOTE_TEMPLATE = """\
---
paper: {title}
status: queued
---

## Summary


## Key Points


## Questions / Ideas

"""


def die(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def find_bookmarks_json() -> Path | None:
    for p in LIBRERA_DIR.rglob("app-Bookmarks.json"):
        return p
    return None


def load_bookmarks(path: Path) -> list[dict]:
    with open(path) as f:
        data = json.load(f)
    result = []
    for v in data.values():
        if isinstance(v, dict) and "text" in v and "path" in v:
            result.append(v)
    return result


def match_bookmarks(bookmarks: list[dict], query: str) -> tuple[str | None, list[dict]]:
    """Return (matched_path, matching_bookmarks) for the best matching book."""
    q = query.lower()
    # Group by epub path
    by_path: dict[str, list[dict]] = {}
    for b in bookmarks:
        p = b.get("path", "")
        by_path.setdefault(p, []).append(b)

    matches = {p: bms for p, bms in by_path.items() if q in p.lower()}
    if not matches:
        return None, []
    if len(matches) == 1:
        path, bms = next(iter(matches.items()))
        return path, bms

    # Multiple matches: prefer exact basename match
    for p, bms in matches.items():
        if q in Path(p).name.lower():
            return p, bms

    # Fall back to first
    path, bms = next(iter(matches.items()))
    return path, bms


def format_highlights(bookmarks: list[dict]) -> str:
    sorted_bm = sorted(bookmarks, key=lambda b: float(b.get("p", 0)))
    if not sorted_bm:
        return "_No highlights yet._"
    lines = []
    for b in sorted_bm:
        pct = round(float(b.get("p", 0)) * 100, 1)
        text = b.get("text", "").strip().replace("\n", " ")
        ts   = b.get("t", 0)
        date = datetime.fromtimestamp(ts / 1000, tz=timezone.utc).strftime("%Y-%m-%d") if ts else ""
        date_str = f" _{date}_" if date else ""
        lines.append(f"- **{pct}%**{date_str} — {text}")
    return "\n".join(lines)


def derive_note_filename(epub_path: str, query: str) -> str:
    """Best-effort note filename from the epub path."""
    name = Path(epub_path).stem if epub_path else query
    # Strip common suffixes like _2402.10957 that are already part of the name
    return name


def update_or_create_note(note_path: Path, epub_path: str, highlights_md: str) -> None:
    if note_path.exists():
        content = note_path.read_text()
        if SENTINEL in content:
            manual = content[: content.index(SENTINEL)]
        else:
            manual = content.rstrip() + "\n\n"
    else:
        title = Path(epub_path).stem if epub_path else note_path.stem
        manual = NOTE_TEMPLATE.format(title=title)

    new_content = manual.rstrip() + "\n\n" + SENTINEL + "\n\n" + highlights_md + "\n"
    note_path.write_text(new_content)


def cmd_list(bookmarks: list[dict]) -> None:
    by_path: dict[str, list[dict]] = {}
    for b in bookmarks:
        by_path.setdefault(b.get("path", "?"), []).append(b)
    for p, bms in sorted(by_path.items(), key=lambda x: -len(x[1])):
        print(f"  {len(bms):3d}  {Path(p).name}")


def main() -> None:
    args = sys.argv[1:]
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        return

    bm_file = find_bookmarks_json()
    if bm_file is None:
        die(
            f"app-Bookmarks.json not found under {LIBRERA_DIR}\n"
            "  Share Librera's data folder via Syncthing and receive it there."
        )

    bookmarks = load_bookmarks(bm_file)

    if args[0] == "--list":
        cmd_list(bookmarks)
        return

    query = args[0]
    epub_path, matched = match_bookmarks(bookmarks, query)

    if not matched:
        print(f"No highlights found matching '{query}'.")
        print("Books with highlights:")
        cmd_list(bookmarks)
        sys.exit(1)

    print(f"Matched: {Path(epub_path).name}  ({len(matched)} highlight(s))")

    # Derive note filename: use the epub stem, but allow override via second arg
    note_stem = args[1] if len(args) > 1 else derive_note_filename(epub_path, query)
    note_path = NOTES_DIR / f"{note_stem}.md"

    highlights_md = format_highlights(matched)
    NOTES_DIR.mkdir(parents=True, exist_ok=True)
    update_or_create_note(note_path, epub_path, highlights_md)

    action = "Updated" if note_path.exists() else "Created"
    print(f"{action}: {note_path}")


if __name__ == "__main__":
    main()
