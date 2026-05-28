"""Regenerate favicon from logo-org.png with proper sizes."""
from PIL import Image
import os

BASE = r"c:\Scripts\quizpro\static"
src = os.path.join(BASE, "logo-org.png")
img = Image.open(src).convert("RGBA")
print(f"Source: {img.size} {img.mode}")

# Remove white background
data = list(img.getdata())
new_data = []
for r, g, b, a in data:
    if r >= 230 and g >= 230 and b >= 230:
        new_data.append((255, 255, 255, 0))
    elif r >= 210 and g >= 210 and b >= 210:
        avg = (r + g + b) / 3
        alpha = int(max(0, min(255, (230 - avg) * 12)))
        new_data.append((r, g, b, alpha))
    else:
        new_data.append((r, g, b, a))
img.putdata(new_data)

# Make square with padding
size = max(img.size)
square = Image.new("RGBA", (size, size), (0, 0, 0, 0))
offset = ((size - img.width) // 2, (size - img.height) // 2)
square.paste(img, offset)

# Create ICO with multiple sizes (proper multi-size ICO)
ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128)]
ico_imgs = [square.resize(s, Image.LANCZOS) for s in ico_sizes]
ico_path = os.path.join(BASE, "favicon.ico")
ico_imgs[0].save(ico_path, format="ICO", sizes=ico_sizes, append_images=ico_imgs[1:])
print(f"favicon.ico: {os.path.getsize(ico_path)} bytes")

# 192x192 PNG for Yandex/Google
png192 = square.resize((192, 192), Image.LANCZOS)
p192 = os.path.join(BASE, "favicon-192.png")
png192.save(p192, "PNG")
print(f"favicon-192.png: {os.path.getsize(p192)} bytes")

# 512x512 PNG for PWA
png512 = square.resize((512, 512), Image.LANCZOS)
p512 = os.path.join(BASE, "favicon-512.png")
png512.save(p512, "PNG")
print(f"favicon-512.png: {os.path.getsize(p512)} bytes")

print("Done!")
