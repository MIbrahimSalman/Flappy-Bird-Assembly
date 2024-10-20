filename = "background.png"
height = 320
width = 200

## DO NOT CHANGE BELOW ##
from PIL import Image

# Get name
filenamewithoutext = filename.split('.')[0]

# Load the image
image = Image.open(filename)

# Resize accordingly
image = image.resize((height, width))

# Get the palette data
palette = [ 0, 0, 0, 0, 0, 95, 0, 0, 135, 0, 0, 175, 0, 0, 215, 0, 0, 255, 0, 95, 0, 0, 95, 95, 0, 95, 135, 0, 95, 175, 0, 95, 215, 0, 95, 255, 0, 135, 0, 0, 135, 95, 0, 135, 135, 0, 135, 175, 0, 135, 215, 0, 135, 255, 0, 175, 0, 0, 175, 95, 0, 175, 135, 0, 175, 175, 0, 175, 215, 0, 175, 255, 0, 215, 0, 0, 215, 95, 0, 215, 135, 0, 215, 175, 0, 215, 215, 0, 215, 255, 0, 255, 0, 0, 255, 95, 0, 255, 135, 0, 255, 175, 0, 255, 215, 0, 255, 255, 95, 0, 0, 95, 0, 95, 95, 0, 135, 95, 0, 175, 95, 0, 215, 95, 0, 255, 95, 95, 0, 95, 95, 95, 95, 95, 135, 95, 95, 175, 95, 95, 215, 95, 95, 255, 95, 135, 0, 95, 135, 95, 95, 135, 135, 95, 135, 175, 95, 135, 215, 95, 135, 255, 95, 175, 0, 95, 175, 95, 95, 175, 135, 95, 175, 175, 95, 175, 215, 95, 175, 255, 95, 215, 0, 95, 215, 95, 95, 215, 135, 95, 215, 175, 95, 215, 215, 95, 215, 255, 95, 255, 0, 95, 255, 95, 95, 255, 135, 95, 255, 175, 95, 255, 215, 95, 255, 255, 135, 0, 0, 135, 0, 95, 135, 0, 135, 135, 0, 175, 135, 0, 215, 135, 0, 255, 135, 95, 0, 135, 95, 95, 135, 95, 135, 135, 95, 175, 135, 95, 215, 135, 95, 255, 135, 135, 0, 135, 135, 95, 135, 135, 135, 135, 135, 175, 135, 135, 215, 135, 135, 255, 135, 175, 0, 135, 175, 95, 135, 175, 135, 135, 175, 175, 135, 175, 215, 135, 175, 255, 135, 215, 0, 135, 215, 95, 135, 215, 135, 135, 215, 175, 135, 215, 215, 135, 215, 255, 135, 255, 0, 135, 255, 95, 135, 255, 135, 135, 255, 175, 135, 255, 215, 135, 255, 255, 175, 0, 0, 175, 0, 95, 175, 0, 135, 175, 0, 175, 175, 0, 215, 175, 0, 255, 175, 95, 0, 175, 95, 95, 175, 95, 135, 175, 95, 175, 175, 95, 215, 175, 95, 255, 175, 135, 0, 175, 135, 95, 175, 135, 135, 175, 135, 175, 175, 135, 215, 175, 135, 255, 175, 175, 0, 175, 175, 95, 175, 175, 135, 175, 175, 175, 175, 175, 215, 175, 175, 255, 175, 215, 0, 175, 215, 95, 175, 215, 135, 175, 215, 175, 175, 215, 215, 175, 215, 255, 175, 255, 0, 175, 255, 95, 175, 255, 135, 175, 255, 175, 175, 255, 215, 175, 255, 255, 215, 0, 0, 215, 0, 95, 215, 0, 135, 215, 0, 175, 215, 0, 215, 215, 0, 255, 215, 95, 0, 215, 95, 95, 215, 95, 135, 215, 95, 175, 215, 95, 215, 215, 95, 255, 215, 135, 0, 215, 135, 95, 215, 135, 135, 215, 135, 175, 215, 135, 215, 215, 135, 255, 215, 175, 0, 215, 175, 95, 215, 175, 135, 215, 175, 175, 215, 175, 215, 215, 175, 255, 215, 215, 0, 215, 215, 95, 215, 215, 135, 215, 215, 175, 215, 215, 215, 215, 215, 255, 215, 255, 0, 215, 255, 95, 215, 255, 135, 215, 255, 175, 215, 255, 215, 215, 255, 255, 255, 0, 0, 255, 0, 95, 255, 0, 135, 255, 0, 175, 255, 0, 215, 255, 0, 255, 255, 95, 0, 255, 95, 95, 255, 95, 135, 255, 95, 175, 255, 95, 215, 255, 95, 255, 255, 135, 0, 255, 135, 95, 255, 135, 135, 255, 135, 175, 255, 135, 215, 255, 135, 255, 255, 175, 0, 255, 175, 95, 255, 175, 135, 255, 175, 175, 255, 175, 215, 255, 175, 255, 255, 215, 0, 255, 215, 95, 255, 215, 135, 255, 215, 175, 255, 215, 215, 255, 215, 255, 255, 255, 0, 255, 255, 95, 255, 255, 135, 255, 255, 175, 255, 255, 215, 255, 255, 255]

p_img = Image.new('P', (height, width))
p_img.putpalette(palette)

# image = image.quantize(palette=p_img, dither=Image.Dither.FLOYDSTEINBERG)
image = image.quantize(palette=p_img, dither=0)

image.save(filenamewithoutext+'.bmp')

print(f"Pixel data and palette have been written to {filenamewithoutext+'.bmp'}")