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
ASPECT = "1:1"
OUT_W = 720
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "static", "collections")
os.makedirs(OUT, exist_ok=True)

_COMMON = (" Clean modern 3D render, premium quality, soft studio lighting, "
           "centred tidy composition, themed objects on a simple uncluttered "
           "background, calm and subtle (it will sit behind a coloured overlay). "
           "No text, no words, no letters, no logos, no watermark.")

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
