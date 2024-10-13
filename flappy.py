from PIL import Image

# Load and convert the image
img = Image.open("bird.png")
img = img.resize((320, 200))  # Resize to 320x200
img = img.convert("P", palette=Image.ADAPTIVE, colors=256)  # Convert to 256-color palette

# Save as raw pixel data
with open("bird.raw", "wb") as f:
    f.write(img.tobytes())