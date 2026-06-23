# -*- coding: utf-8 -*-
"""Generate premium themed background art for marketplace COLLECTION cards via
Vertex Imagen, downscaled to static/collections/<slug>.jpg.

The art sits behind a heavily-tinted gradient on the card, so prompts aim for
clean themed objects on a simple background (it reads as a subtle texture).

Run from repo root:  python tools/gen_collection_art.py [slug1 slug2 ...]
With no args it generates every slug in PROMPTS.
"""
import base64
import io
import os
import sys
import time

import requests
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import ai_gen  # noqa: E402

LOC = "us-central1"
MODEL = "imagen-4.0-generate-001"
ASPECT = "4:3"
OUT_W = 860
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "static", "collections")
os.makedirs(OUT, exist_ok=True)

_COMMON = (" Premium glossy 3D render, wide horizontal composition. The themed object "
           "is large, bright and crisply lit on the RIGHT side. The LEFT ~40% is a "
           "smooth, slightly darker area of the SAME theme colour with a faint matching "
           "pattern, kept clean and simple. Fill the ENTIRE frame edge to edge with the "
           "rich saturated theme colour — NO white, NO pale or blown-out areas, NO grey "
           "studio, NO plain white corners. VERY IMPORTANT: absolutely NO text, NO "
           "letters, NO words, NO labels, NO captions, NO numbers, NO writing of any "
           "kind, NO logos other than the described object, NO watermark, NO floating "
           "card or banner shape — anywhere in the image.")

PROMPTS = {
    # English subject collections
    "english-a1": ("A small fresh green sprout growing beside a few colourful "
                   "wooden toy blocks and a friendly little book, cheerful "
                   "beginner learning theme, green tones." + _COMMON),
    "english-a2": ("An open textbook, a ceramic coffee mug and a yellow pencil on "
                   "a tidy study desk, everyday learning theme, blue tones." + _COMMON),
    "english-grammar": ("An open workbook with a wooden ruler, a pencil and a "
                        "fountain pen arranged neatly, structured study theme, "
                        "purple tones." + _COMMON),
    "english-vocabulary": ("An open dictionary book with a magnifying glass and a "
                           "small stack of flashcards, vocabulary theme, warm orange "
                           "tones." + _COMMON),
    "english-b1": ("A neat stack of study books with a pair of headphones resting "
                   "on top, focused learning theme, blue tones." + _COMMON),
    "english-b2": ("A few advanced hardcover books with a fountain pen and reading "
                   "glasses, refined study theme, deep indigo tones." + _COMMON),
    "english-phrasal-verbs": ("Several glossy interlocking metal chain links next "
                              "to small blank puzzle pieces, connection theme, "
                              "purple tones." + _COMMON),
    "english-ielts": ("A graduation cap resting on a neat stack of exam papers "
                      "with a pencil and a rolled certificate, exam-prep theme, "
                      "sky-blue tones." + _COMMON),
    "english-toefl": ("A passport, a small airplane model and a torch/statue "
                      "silhouette evoking American English travel, with an exam "
                      "booklet, red and white tones." + _COMMON),
    # Mathematics subject collections
    "math-algebra": ("Glossy 3D mathematical symbols — a plus sign, an equals "
                     "sign and x/y variables — beside a smooth parabola curve "
                     "graph, algebra theme, purple and violet tones." + _COMMON),
    "math-geometry": ("Glossy 3D geometric solids — a cube, a cone, a sphere and "
                      "a pyramid — with a ruler and a protractor, geometry theme, "
                      "blue tones." + _COMMON),
    "math-calculus": ("A glossy 3D integral symbol and a smooth curve with the "
                      "area under it shaded, plus a limit notation, higher "
                      "mathematics / calculus theme, red and crimson tones." + _COMMON),
    "math-statistics": ("A 3D bar chart, a pie chart and a bell-curve distribution "
                        "graph together, statistics and data theme, orange and "
                        "amber tones." + _COMMON),
    "math-exam-prep": ("A clipboard with a checklist and green check marks, a "
                       "pencil and an eraser, math exam preparation theme, warm "
                       "tones." + _COMMON),
    # Programming subject collections
    "programming-python": ("The Python programming language logo — two intertwined "
                           "blue and yellow snakes — as a glossy 3D emblem, with "
                           "faint code snippets behind it, green tones." + _COMMON),
    "programming-javascript": ("The JavaScript logo — a glossy 3D yellow rounded "
                               "square badge — with floating code brackets, amber "
                               "and gold tones." + _COMMON),
    "programming-html-css": ("The HTML5 orange shield emblem next to the CSS3 blue "
                             "shield emblem, glossy 3D, web-development theme, orange "
                             "tones." + _COMMON),
    "programming-sql": ("A stack of glossy 3D database cylinders with a small glowing "
                        "data tag, database and query theme, cyan and teal "
                        "tones." + _COMMON),
    "programming-algorithms": ("A glossy 3D flowchart with diamond decision nodes "
                               "and a couple of gears, algorithm theme, purple "
                               "tones." + _COMMON),
    "programming-data-structures": ("A glossy 3D graph of connected spheres forming "
                                    "a tree, plus a small linked-list of cubes, data "
                                    "structures theme, green tones." + _COMMON),
    # Natural Sciences subject collections
    "geography": ("A glossy 3D globe with a compass and a folded map, geography "
                  "theme, emerald green tones." + _COMMON),
    "anatomy": ("A glossy 3D anatomical human heart with a small skeleton/bone "
                "accent, human anatomy theme, teal-green tones." + _COMMON),
    "science-biology": ("A glowing DNA double helix with a microscope and a green "
                        "leaf cell, biology theme, green tones." + _COMMON),
    "science-chemistry": ("Glass beakers and a conical flask with colourful liquid "
                          "and floating molecules, chemistry theme, teal tones." + _COMMON),
    "science-physics": ("A glowing 3D atom model with a magnet and a pendulum, "
                        "physics theme, blue tones." + _COMMON),
    "science-general": ("A glossy 3D atom, a beaker and a small telescope together, "
                        "general science theme, green tones." + _COMMON),
    # Business subject collections
    "business-marketing": ("A glossy 3D megaphone with a target/bullseye and a "
                           "rising arrow, marketing theme, amber and orange tones." + _COMMON),
    "business-finance": ("Stacks of gold coins, a dollar sign and a rising line "
                         "chart, finance theme, gold and amber tones." + _COMMON),
    "business-accounting": ("A 3D calculator with a balance scale and a small "
                            "ledger book, accounting theme, warm orange tones." + _COMMON),
    "business-entrepreneurship": ("A glowing lightbulb launching like a rocket with "
                                  "a briefcase, entrepreneurship theme, orange "
                                  "tones." + _COMMON),
    # History subject collections
    "history-ancient": ("Ancient Greek marble columns with an amphora vase and a "
                        "laurel wreath, ancient world theme, warm gold and sepia "
                        "tones." + _COMMON),
    "history-medieval": ("A medieval castle tower with a knight's helmet and a "
                         "crossed sword and shield, middle ages theme, brown and "
                         "stone tones." + _COMMON),
    "history-modern": ("An antique sailing ship with an old world map, a compass "
                       "and a quill, early-modern era theme, sepia tones." + _COMMON),
    "history-20th-century": ("A vintage radio, an old globe and a folded newspaper, "
                             "20th-century theme, warm sepia tones." + _COMMON),
}


def generate(prompt, retries=5):
    proj = ai_gen._vertex_project()
    url = (f"https://{LOC}-aiplatform.googleapis.com/v1/projects/{proj}"
           f"/locations/{LOC}/publishers/google/models/{MODEL}:predict")
    body = {"instances": [{"prompt": prompt}],
            "parameters": {"sampleCount": 1, "aspectRatio": ASPECT}}
    for attempt in range(retries):
        tok = ai_gen._vertex_token()
        r = requests.post(url, headers={"Authorization": f"Bearer {tok}"},
                          json=body, timeout=120)
        if r.status_code == 429:
            wait = 25 * (attempt + 1)
            print(f"    quota hit, waiting {wait}s ...")
            time.sleep(wait)
            continue
        if r.status_code != 200:
            raise RuntimeError(f"HTTP {r.status_code}: {r.text[:200]}")
        preds = r.json().get("predictions", [])
        if not preds or not preds[0].get("bytesBase64Encoded"):
            raise RuntimeError("no image in response")
        return base64.b64decode(preds[0]["bytesBase64Encoded"])
    raise RuntimeError("exhausted retries (quota)")


def main():
    slugs = sys.argv[1:] or list(PROMPTS)
    for slug in slugs:
        prompt = PROMPTS.get(slug)
        if not prompt:
            print(f"  {slug}: no prompt, skip"); continue
        try:
            raw = generate(prompt)
            img = Image.open(io.BytesIO(raw)).convert("RGB")
            h = round(img.height * OUT_W / img.width)
            img = img.resize((OUT_W, h), Image.LANCZOS)
            path = os.path.join(OUT, f"{slug}.jpg")
            img.save(path, "JPEG", quality=85, optimize=True, progressive=True)
            print(f"  {slug}: saved ({os.path.getsize(path)//1024} KB)")
        except Exception as e:
            print(f"  {slug}: FAILED — {e}")
        time.sleep(7)


if __name__ == "__main__":
    main()
