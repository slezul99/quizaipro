# -*- coding: utf-8 -*-
"""Generate premium themed background art for the marketplace subject cards via
Vertex Imagen, then downscale to web JPEGs in static/subjects/<slug>.jpg.

Run from repo root:
    python tools/gen_subject_art.py            # all subjects
    python tools/gen_subject_art.py general physics chemistry   # a subset

Reuses the Vertex service-account auth from ai_gen.py. Re-run to regenerate.
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
MODEL = "imagen-4.0-generate-001"   # latest / highest quality
ASPECT = "1:1"
OUT_W = 1536          # was 1024 — sharper on retina / large cards
JPEG_Q = 92           # was 87
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "static", "subjects")
os.makedirs(OUT, exist_ok=True)

_COMMON = (" Cinematic 3D illustration, premium quality, ultra detailed, sharp "
           "focus, soft studio lighting, depth of field. Square composition: the "
           "themed objects fill the UPPER two-thirds of the frame; the BOTTOM "
           "third is calmer and darker, mostly empty (for a text overlay). No "
           "text, no words, no letters, no logos, no watermark.")

PROMPTS = {
    # ── universal fallback (any deck with no recognised subject) ──
    "general": ("A glowing translucent 3D brain made of soft light and floating "
                "knowledge particles, an open book radiating gentle light, a "
                "lightbulb, small orbiting stars, on a deep aurora background of "
                "indigo, violet and magenta, premium cinematic render, dreamy and "
                "inspiring." + _COMMON),
    # ── existing (regenerated at higher quality) ──
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
    "science": ("Clean modern 3D render on a SOFT BRIGHT mint-green background "
                "filled with subtle blurred molecule shapes and gentle bokeh. On "
                "the left a detailed dark microscope; in the centre a glowing "
                "cyan-teal DNA double helix; on the right a tidy 3D atom model with "
                "glossy orange and blue spheres orbiting on thin rings; in front two "
                "glass conical flasks with glowing amber-yellow and teal liquid. "
                "Soft even studio lighting, light and airy, fresh pastel green "
                "tones, premium quality, NOT dark, NOT neon." + _COMMON),
    "business": ("A rising 3D bar chart with a golden upward arrow, neat stacks of "
                 "gold coins, a small pie chart, financial growth theme, on a warm "
                 "orange and gold background, premium business aesthetic." + _COMMON),
    "history": ("An ancient Greek temple with marble columns, an antique brass "
                "globe, an old open book with aged yellow pages, warm sepia and "
                "brown colour grade, golden-hour classical lighting." + _COMMON),
    # ── new subjects ──
    "physics": ("A glowing 3D atom with orbiting electrons, a swinging pendulum, a "
                "horseshoe magnet with field lines, energy waves and a lightning "
                "bolt, floating translucent physics symbols, on a deep blue and "
                "indigo background with electric cyan glow, premium sci render." + _COMMON),
    "chemistry": ("Three glass conical flasks and a round beaker with glowing "
                  "purple, teal and amber liquids and rising bubbles, a translucent "
                  "3D molecular structure of connected spheres, small periodic-table "
                  "style tiles, on a clean teal-green laboratory background." + _COMMON),
    "biology": ("A vivid cyan-green DNA double helix, fresh green leaves and a "
                "sprouting plant, a translucent cell with organelles, a dark "
                "microscope, on a soft fresh green background, light and airy, "
                "premium botanical science render." + _COMMON),
    "geography": ("A glossy 3D planet Earth globe with soft clouds, a folded world "
                  "map, a brass compass, small green mountains and a location pin, "
                  "on a calm teal and ocean-blue background, premium render." + _COMMON),
    "language": ("Colourful glossy 3D chat speech bubbles in pink, yellow and blue "
                 "with three-dot typing icons, a cluster of small waving national "
                 "flags (France, Japan, Brazil, Germany, Italy) on thin gold poles, "
                 "a small glossy globe and a translation arrows icon, warm coral and "
                 "orange gradient background, friendly premium 3D render. IMPORTANT: "
                 "absolutely NO letters, NO alphabet, NO words, NO text anywhere." + _COMMON),
    "literature": ("A tall stack of classic hardcover books, an open book with a "
                   "white feather quill resting in a glass inkwell, soft floating "
                   "paper pages, warm amber and burgundy colour grade, cosy "
                   "library lighting." + _COMMON),
    "art": ("A wooden painter's palette with glossy blobs of vivid paint, a cluster "
            "of paint brushes, an easel with a blank canvas, a splash of colourful "
            "paint, on a soft pastel lilac background, premium creative render." + _COMMON),
    "music": ("Glossy 3D musical notes floating in the air, a pair of premium "
              "headphones, a grand-piano keyboard and an acoustic guitar silhouette, "
              "glowing sound waves, on a purple and pink gradient background." + _COMMON),
    "medicine": ("A modern stethoscope, a glossy red medical cross, a caduceus "
                 "symbol, a translucent DNA helix and a couple of capsule pills, on "
                 "a clean white and soft-blue background, premium medical render." + _COMMON),
    "astronomy": ("A ringed planet and two smaller planets, a sleek telescope, a "
                  "bright glowing star and a swirl of a distant galaxy, sparkling "
                  "stardust, on a deep space background of navy, violet and magenta "
                  "nebula, premium cosmic render." + _COMMON),
}

# math is an alias of mathematics (same art).
ALIASES = {"math": "mathematics"}


def generate(prompt, retries=6):
    proj = ai_gen._vertex_project()
    url = (f"https://{LOC}-aiplatform.googleapis.com/v1/projects/{proj}"
           f"/locations/{LOC}/publishers/google/models/{MODEL}:predict")
    body = {"instances": [{"prompt": prompt}],
            "parameters": {"sampleCount": 1, "aspectRatio": ASPECT}}
    for attempt in range(retries):
        tok = ai_gen._vertex_token()
        r = requests.post(url, headers={"Authorization": f"Bearer {tok}",
                                        "Content-Type": "application/json"},
                          json=body, timeout=120)
        if r.status_code == 429:                       # per-minute quota
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


def save(slug, raw):
    img = Image.open(io.BytesIO(raw)).convert("RGB")
    w = OUT_W
    h = round(img.height * w / img.width)
    img = img.resize((w, h), Image.LANCZOS)
    path = os.path.join(OUT, f"{slug}.jpg")
    img.save(path, "JPEG", quality=JPEG_Q, optimize=True, progressive=True)
    print(f"  {slug}: saved ({os.path.getsize(path)//1024} KB, {w}x{h})")


def main():
    want = [s.lower() for s in sys.argv[1:]] or list(PROMPTS.keys())
    for slug in want:
        if slug not in PROMPTS:
            print(f"  {slug}: no prompt, skipping"); continue
        try:
            raw = generate(PROMPTS[slug])
            save(slug, raw)
        except Exception as e:
            print(f"  {slug}: FAILED — {e}")
        time.sleep(6)
    # keep math == mathematics in sync
    import shutil
    src = os.path.join(OUT, "mathematics.jpg")
    if ("mathematics" in want or "math" in want) and os.path.exists(src):
        shutil.copyfile(src, os.path.join(OUT, "math.jpg"))
        print("  math: mirrored from mathematics.jpg")


if __name__ == "__main__":
    main()
