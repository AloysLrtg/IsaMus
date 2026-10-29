#!/usr/bin/env python3
"""python3 -m pip install pymupdf Pillow
python3 scripts/convert_cards.py

PyMuPDF assure le rendu SVG ; Pillow redimensionne et optimise les PNG.
Aucune bibliothèque système Cairo nécessaire sur macOS.
"""
import argparse
import io
import re
from pathlib import Path

import pymupdf
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SUITS = {"coins": "oros", "cups": "copas", "swords": "espadas", "clubs": "bastos"}
RANKS = {1, 2, 3, 4, 5, 6, 7, 10, 11, 12}


def main():
    parser = argparse.ArgumentParser(description="Convertir les 40 cartes du Mus en PNG 400 × 600.")
    parser.add_argument("--source", type=Path, default=ROOT / "spanish-playing-cards-svg-main")
    parser.add_argument("--output", type=Path, default=ROOT / "assets/cards")
    args = parser.parse_args()
    cards = {}
    for svg in sorted(args.source.glob("*.svg")):
        match = re.fullmatch(r"card_(coins|cups|swords|clubs)_(\d+)", svg.stem)
        if match and int(match[2]) in RANKS:
            name = f"{SUITS[match[1]]}_{int(match[2])}.png"
            if name in cards:
                parser.error(f"Deux SVG correspondent à {name}")
            cards[name] = svg
    expected = {f"{suit}_{rank}.png" for suit in SUITS.values() for rank in RANKS}
    missing = expected - cards.keys()
    if missing:
        parser.error(f"Cartes manquantes dans {args.source} : {', '.join(sorted(missing))}")
    back = args.source / "card_back.svg"
    if back.exists():
        cards["card_back.png"] = back
    args.output.mkdir(parents=True, exist_ok=True)
    for name, svg in sorted(cards.items()):
        # Rendu à 2× puis réduction : contours nets, proportions conservées.
        with pymupdf.open(svg) as document:
            page = document[0]
            zoom = 1200 / page.rect.height
            # Les SVG ont des zones transparentes à l'intérieur des cartes :
            # un fond papier blanc empêche le tapis vert de transparaître.
            rendered = page.get_pixmap(matrix=pymupdf.Matrix(zoom, zoom), alpha=False).tobytes("png")
        with Image.open(io.BytesIO(rendered)) as source:
            fitted = ImageOps.contain(source.convert("RGB"), (400, 600), Image.Resampling.LANCZOS)
            canvas = Image.new("RGB", (400, 600), "white")
            canvas.paste(fitted, ((400 - fitted.width) // 2, (600 - fitted.height) // 2))
            destination = args.output / name
            canvas.save(destination, "PNG", optimize=True, compress_level=9)
        print(f"{svg.name} -> {destination}")
    print(f"{len(cards)} PNG optimisés, 400 × 600 px.")


if __name__ == "__main__":
    main()
