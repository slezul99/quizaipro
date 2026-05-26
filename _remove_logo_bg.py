"""Remove white background from logo PNG to make it transparent."""
from PIL import Image
import os

src = r"c:\Scripts\quizpro\static\logo-banner.png"
dst = r"c:\Scripts\quizpro\static\logo-banner.png"

img = Image.open(src).convert("RGBA")
data = img.getdata()

new_data = []
for r, g, b, a in data:
    # If pixel is near-white, make fully transparent.
    # Threshold 235+ catches white and very light gray (anti-aliased edges).
    if r >= 235 and g >= 235 and b >= 235:
        new_data.append((255, 255, 255, 0))
    elif r >= 220 and g >= 220 and b >= 220:
        # Soft edge — partial transparency to keep anti-aliasing smooth
        # Map [220..234] -> alpha [200..0]
        avg = (r + g + b) / 3
        alpha = int(max(0, min(255, (235 - avg) * 14)))
        new_data.append((r, g, b, alpha))
    else:
        new_data.append((r, g, b, a))

img.putdata(new_data)
img.save(dst, "PNG", optimize=True)
print(f"Done. Saved {dst}, size={os.path.getsize(dst)} bytes")
