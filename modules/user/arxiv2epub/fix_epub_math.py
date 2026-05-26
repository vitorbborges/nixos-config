#!/usr/bin/env python3
"""
Scale display-math SVGs 2x so they render at a readable size in crengine.

CodeCogs generates equations at ~12pt body-text height. At 96 dpi that makes
display equations only ~40-50 px tall — too close to body text. 2x scaling
brings them to ~80-100 px, which reads like a proper display equation.

Inline equations are left at their natural size; CSS pins them to 1em height.
"""
import io
import re
import sys
import zipfile
from pathlib import Path

DISPLAY_SCALE = 2.0


def _scale_svg(svg_bytes: bytes, scale: float) -> bytes:
    text = svg_bytes.decode("utf-8", errors="replace")

    def scale_attr(m: re.Match) -> str:
        raw = m.group(2)
        unit = next((u for u in ("pt", "px", "mm", "cm", "in") if raw.endswith(u)), "")
        num  = raw[: len(raw) - len(unit)] if unit else raw
        try:
            return m.group(1) + f"{float(num) * scale:.5f}{unit}" + m.group(3)
        except ValueError:
            return m.group(0)

    text = re.sub(r'(<svg\b[^>]*\bwidth=["\'])([^"\']+)(["\'])',  scale_attr, text, count=1)
    text = re.sub(r'(<svg\b[^>]*\bheight=["\'])([^"\']+)(["\'])', scale_attr, text, count=1)
    return text.encode("utf-8")


def _resolve(src: str, xhtml_name: str) -> str:
    prefix = xhtml_name.rsplit("/", 1)[0] if "/" in xhtml_name else ""
    base   = prefix.split("/") if prefix else []
    for part in src.split("/"):
        if part == "..":
            if base: base.pop()
        elif part and part != ".":
            base.append(part)
    return "/".join(base)


def process_epub(path: str) -> None:
    epub = Path(path)

    with zipfile.ZipFile(epub) as zf:
        names = zf.namelist()
        files = {n: zf.read(n) for n in names}

    display_svgs: set[str] = set()
    for name, content in files.items():
        if not name.endswith(".xhtml"):
            continue
        html = content.decode("utf-8", errors="replace")
        for m in re.finditer(
            r'<span class="math display"[^>]*>.*?<img\b[^>]*\bsrc=["\']([^"\']+)["\']',
            html,
        ):
            display_svgs.add(_resolve(m.group(1), name))

    modified = dict(files)
    scaled = 0
    for n in names:
        if n in display_svgs and n.endswith(".svg"):
            modified[n] = _scale_svg(files[n], DISPLAY_SCALE)
            scaled += 1

    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr(
            zipfile.ZipInfo("mimetype"),
            modified.get("mimetype", b"application/epub+zip"),
            zipfile.ZIP_STORED,
        )
        for n in names:
            if n != "mimetype":
                zf.writestr(n, modified[n])

    epub.write_bytes(buf.getvalue())
    print(f"fix_epub_math: scaled {scaled} display SVGs ×{DISPLAY_SCALE}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(f"Usage: {sys.argv[0]} <epub-file>")
    process_epub(sys.argv[1])
