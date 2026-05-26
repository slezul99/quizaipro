"""Remove white background from logo PNGs to make them transparent."""
from PIL import Image
import os

def strip_white(src, dst):
    img = Image.open(src).convert("RGBA")
    data = img.getdata()
    new_data = []
    for r, g, b, a in data:
        if r >= 235 and g >= 235 and b >= 235:
            new_data.append((255, 255, 255, 0))
        elif r >= 220 and g >= 220 and b >= 220:
            avg = (r + g + b) / 3
            alpha = int(max(0, min(255, (235 - avg) * 14)))
            new_data.append((r, g, b, alpha))
        else:
            new_data.append((r, g, b, a))
    img.putdata(new_data)
    img.save(dst, "PNG", optimize=True)
    print(f"Saved {dst}, size={os.path.getsize(dst)} bytes")

if __name__ == "__main__":
    base = r"c:\Scripts\quizpro\static"
    strip_white(os.path.join(base, "logo-org.png"), os.path.join(base, "logo-org.png"))
    print("Done")
