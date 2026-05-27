"""Create favicon.ico and favicon-192.png from logo-org.png (icon only)."""
from PIL import Image
import os

base = r"c:\Scripts\quizpro\static"

# Use the icon-only logo (logo-org.png)
src = os.path.join(base, "logo-org.png")
img = Image.open(src).convert("RGBA")

# Crop to square (center crop to get just the icon part)
w, h = img.size
print(f"Original size: {w}x{h}")

# logo-org.png is the full banner (icon + text), crop left square portion
# The icon takes roughly the left 45% of the image
icon_w = int(h * 1.05)  # slightly wider than height to get full icon
icon_img = img.crop((0, 0, min(icon_w, w), h))

# Remove white background
data = list(icon_img.getdata())
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
icon_img.putdata(new_data)

# Resize to square with padding
size = max(icon_img.size)
square = Image.new("RGBA", (size, size), (0, 0, 0, 0))
offset = ((size - icon_img.width) // 2, (size - icon_img.height) // 2)
square.paste(icon_img, offset)

# Save favicon.ico (multiple sizes)
ico_sizes = [(16,16), (32,32), (48,48), (64,64)]
ico_images = [square.resize(s, Image.LANCZOS) for s in ico_sizes]
ico_path = os.path.join(base, "favicon.ico")
ico_images[0].save(ico_path, format="ICO", sizes=ico_sizes,
                   append_images=ico_images[1:])
print(f"Saved favicon.ico: {os.path.getsize(ico_path)} bytes")

# Save 192x192 PNG for Google / PWA
png192 = square.resize((192, 192), Image.LANCZOS)
png192_path = os.path.join(base, "favicon-192.png")
png192.save(png192_path, "PNG")
print(f"Saved favicon-192.png: {os.path.getsize(png192_path)} bytes")

# Save 512x512 PNG for PWA
png512 = square.resize((512, 512), Image.LANCZOS)
png512_path = os.path.join(base, "favicon-512.png")
png512.save(png512_path, "PNG")
print(f"Saved favicon-512.png: {os.path.getsize(png512_path)} bytes")

print("Done!")
