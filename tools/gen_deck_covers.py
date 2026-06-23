# -*- coding: utf-8 -*-
"""Generate ready-made deck cover images (Vertex Imagen) bundled into the
mobile app at mobile/assets/covers/cover_NN.jpg. Decorative & versatile so any
deck looks good; the deck's `cover` field stores the preset id (e.g. cover_07).

Run from repo root:  python tools/gen_deck_covers.py
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
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "mobile", "assets", "covers")
os.makedirs(OUT, exist_ok=True)

_C = (" Premium glossy 3D render, decorative deck cover, wide horizontal "
      "composition that fills the whole frame edge to edge with a rich, "
      "saturated colour gradient. Tasteful and clean. Absolutely NO text, NO "
      "letters, NO words, NO numbers, NO logos, NO watermark.")

PROMPTS = [
    "Smooth abstract flowing waves in indigo and violet" + _C,
    "Abstract soft gradient blobs in pink and orange, dreamy" + _C,
    "Geometric low-poly shapes in teal and blue" + _C,
    "Soft pastel gradient mesh, mint and sky blue" + _C,
    "Glossy abstract liquid swirl, purple and magenta" + _C,
    "Warm sunset gradient with subtle grain, amber and red" + _C,
    "Cool aurora gradient, green and cyan, soft glow" + _C,
    "Dark premium gradient with subtle gold particles" + _C,
    "A glossy 3D stack of colourful books on a blue gradient" + _C,
    "A glowing 3D lightbulb idea icon on a violet gradient" + _C,
    "A friendly 3D brain icon on a pink gradient" + _C,
    "A glossy 3D rocket launching on an indigo gradient" + _C,
    "A 3D target with a dart in the centre on an orange gradient" + _C,
    "A 3D graduation cap on a blue gradient" + _C,
    "A glowing 3D atom model on a teal gradient" + _C,
    "A glossy 3D globe on a green gradient" + _C,
    "3D code brackets </> on a dark purple gradient" + _C,
    "A 3D artist palette with brushes on a warm gradient" + _C,
    "A 3D music note on a magenta gradient" + _C,
    "A 3D trophy on a gold gradient" + _C,
    "A 3D compass on a deep blue gradient" + _C,
    "3D interlocking puzzle pieces on a colourful gradient" + _C,
    "A small 3D green plant sprout on a fresh green gradient" + _C,
    "A 3D flame / fire streak icon on a red-orange gradient" + _C,
]


def gen(prompt):
    proj = ai_gen._vertex_project()
    url = (f"https://{LOC}-aiplatform.googleapis.com/v1/projects/{proj}"
           f"/locations/{LOC}/publishers/google/models/{MODEL}:predict")
    body = {"instances": [{"prompt": prompt}],
            "parameters": {"sampleCount": 1, "aspectRatio": "16:9"}}
    for attempt in range(5):
        tok = ai_gen._vertex_token()
        r = requests.post(url, headers={"Authorization": f"Bearer {tok}"},
                          json=body, timeout=120)
        if r.status_code == 429:
            time.sleep(25 * (attempt + 1)); continue
        r.raise_for_status()
        return base64.b64decode(r.json()["predictions"][0]["bytesBase64Encoded"])
    raise RuntimeError("quota")


def main():
    for i, prompt in enumerate(PROMPTS, start=1):
        path = os.path.join(OUT, f"cover_{i:02d}.jpg")
        if os.path.exists(path):
            print(f"  cover_{i:02d}: exists"); continue
        try:
            raw = gen(prompt)
            img = Image.open(io.BytesIO(raw)).convert("RGB")
            w = 720
            img = img.resize((w, round(img.height * w / img.width)), Image.LANCZOS)
            img.save(path, "JPEG", quality=84, optimize=True, progressive=True)
            print(f"  cover_{i:02d}: {os.path.getsize(path)//1024} KB")
        except Exception as e:
            print(f"  cover_{i:02d}: FAILED {e}")
        time.sleep(6)
    print("[covers] done")


if __name__ == "__main__":
    main()
