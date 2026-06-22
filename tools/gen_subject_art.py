# -*- coding: utf-8 -*-
"""One-off: generate premium themed background art for the marketplace subject
cards via Vertex Imagen, then downscale to web-friendly JPEGs in
static/subjects/<slug>.jpg.

Run from repo root:  python tools/gen_subject_art.py
Reuses the Vertex service-account auth from ai_gen.py. Re-run to regenerate.
"""
import base64
import io
import os
import sys

import requests
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import ai_gen  # noqa: E402

LOC = "us-central1"
MODEL = "imagen-3.0-generate-001"
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "static", "subjects")
os.makedirs(OUT, exist_ok=True)

_COMMON = (" Cinematic 3D illustration, premium quality, highly detailed, soft "
           "studio lighting, depth of field. The themed objects are weighted to "
           "the RIGHT half of the frame; the LEFT half is calmer, darker, mostly "
           "empty negative space (for text overlay). No text, no words, no "
           "letters, no logos, no watermark.")

PROMPTS = {
    "english": ("London at dusk under a rich purple and violet twilight sky: Big "
                "Ben clock tower, a glossy red double-decker bus, a waving Union "
                "Jack British flag, a stack of vintage hardcover books in the "
                "foreground, warm glowing street lights, purple and magenta colour "
                "grade." + _COMMON),
    "mathematics": ("A sleek modern calculator, glossy 3D geometric shapes (cone, "
                    "sphere, cube), floating translucent mathematical formulas and "
                    "equations and a square-root symbol, on a vibrant orange and "
                    "amber background, warm orange colour grade." + _COMMON),
    "programming": ("A modern open laptop showing colourful glowing source code on "
                    "its screen, a blue ceramic coffee mug, a mechanical keyboard, "
                    "floating neon code brackets, deep indigo and purple ambient "
                    "lighting, premium tech aesthetic." + _COMMON),
    "science": ("A glowing DNA double helix, a laboratory microscope, translucent "
                "molecules and atoms, on a deep emerald green background, green and "
                "teal colour grade, clean scientific aesthetic." + _COMMON),
    "business": ("A rising 3D bar chart with a golden upward arrow, neat stacks of "
                 "gold coins, a small pie chart, financial growth theme, on a warm "
                 "orange and gold background, premium business aesthetic." + _COMMON),
    "history": ("An ancient Greek temple with marble columns, an antique brass "
                "globe, an old open book with aged yellow pages, warm sepia and "
                "brown colour grade, golden-hour classical lighting." + _COMMON),
}


def generate(prompt):
    tok = ai_gen._vertex_token()
    proj = ai_gen._vertex_project()
    url = (f"https://{LOC}-aiplatform.googleapis.com/v1/projects/{proj}"
           f"/locations/{LOC}/publishers/google/models/{MODEL}:predict")
    body = {"instances": [{"prompt": prompt}],
            "parameters": {"sampleCount": 1, "aspectRatio": "16:9"}}
    r = requests.post(url, headers={"Authorization": f"Bearer {tok}",
                                    "Content-Type": "application/json"},
                      json=body, timeout=120)
    if r.status_code != 200:
        raise RuntimeError(f"HTTP {r.status_code}: {r.text[:200]}")
    preds = r.json().get("predictions", [])
    if not preds or not preds[0].get("bytesBase64Encoded"):
        raise RuntimeError("no image in response")
    return base64.b64decode(preds[0]["bytesBase64Encoded"])


def main():
    for slug, prompt in PROMPTS.items():
        try:
            raw = generate(prompt)
            img = Image.open(io.BytesIO(raw)).convert("RGB")
            # downscale to a web-friendly width (cards render ~400px → 2x retina)
            w = 900
            h = round(img.height * w / img.width)
            img = img.resize((w, h), Image.LANCZOS)
            path = os.path.join(OUT, f"{slug}.jpg")
            img.save(path, "JPEG", quality=82, optimize=True, progressive=True)
            print(f"  {slug}: saved {path} ({os.path.getsize(path)//1024} KB, {w}x{h})")
        except Exception as e:
            print(f"  {slug}: FAILED — {e}")


if __name__ == "__main__":
    main()
