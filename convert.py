from PIL import Image

palette = [
    (0, 0, 0), (128, 0, 0), (0, 128, 0), (128, 128, 0),
    (0, 0, 128), (128, 0, 128), (0, 128, 128), (192, 192, 192),
    (128, 128, 128), (255, 0, 0), (0, 255, 0), (255, 255, 0),
    (0, 0, 255), (255, 0, 255), (0, 255, 255), (255, 255, 255),
    (0, 0, 85), (85, 0, 0), (0, 85, 0), (85, 85, 0),
    (0, 0, 170), (170, 0, 0), (0, 170, 0), (170, 170, 0),
    (0, 85, 85), (85, 85, 85), (0, 170, 85), (85, 170, 0),
    (85, 0, 85), (170, 0, 85), (85, 85, 170), (170, 85, 0),
    (85, 0, 170), (170, 0, 170), (85, 170, 85), (170, 85, 85),
    (85, 170, 170), (170, 170, 85), (85, 85, 255), (255, 85, 85),
    (85, 255, 85), (255, 85, 170), (85, 170, 255), (255, 170, 85),
    (85, 255, 170), (170, 255, 85), (85, 255, 255), (255, 85, 255),
    (170, 85, 255), (255, 170, 255), (85, 85, 42), (42, 85, 85),
    (85, 42, 85), (170, 42, 85), (42, 170, 85), (85, 42, 170),
    (42, 85, 170), (170, 85, 42), (42, 170, 170), (170, 42, 170),
    (42, 42, 85), (42, 42, 170), (85, 42, 42), (170, 42, 42),
    (42, 170, 42), (170, 42, 42), (42, 85, 42), (42, 42, 42),
    (85, 170, 42), (42, 255, 42), (255, 42, 42), (255, 85, 42),
    (42, 85, 255), (85, 255, 42), (42, 255, 85), (170, 255, 42),
    (42, 255, 170), (255, 170, 42), (170, 255, 255), (85, 255, 255),
    (255, 255, 85), (255, 255, 170), (255, 42, 85), (85, 42, 255),
    (170, 42, 255), (42, 85, 42), (85, 255, 255), (255, 42, 255),
    (170, 42, 170), (42, 42, 255), (85, 85, 42), (255, 85, 255),
    (42, 42, 128), (128, 42, 42), (42, 128, 128), (128, 42, 85),
    (128, 128, 42), (42, 128, 42), (85, 42, 128), (128, 85, 42),
    (42, 128, 85), (85, 128, 128), (42, 85, 128), (128, 85, 85),
    (170, 128, 42), (128, 170, 85), (128, 42, 170), (42, 128, 170),
    (128, 170, 42), (170, 128, 85), (85, 128, 170), (170, 85, 128),
    (128, 85, 170), (85, 170, 128), (170, 42, 128), (42, 170, 128),
    (85, 42, 255), (255, 42, 128), (42, 255, 85), (128, 255, 42),
    (42, 255, 255), (255, 128, 85), (255, 128, 255), (85, 42, 128),
    (128, 255, 85), (85, 255, 128), (255, 42, 42), (85, 128, 85),
    (42, 85, 128), (255, 128, 170), (42, 42, 170), (170, 42, 42),
    (170, 42, 255), (85, 42, 170), (255, 85, 85), (170, 128, 170),
    (255, 128, 255), (85, 170, 85), (255, 42, 85), (42, 42, 255),
    (42, 170, 255), (85, 42, 85), (170, 42, 85), (85, 170, 42),
    (42, 85, 85), (85, 42, 42), (42, 42, 170), (85, 42, 128),
    (255, 42, 255), (170, 255, 42), (85, 128, 42), (255, 42, 170),
    (170, 128, 128), (255, 85, 128), (85, 42, 42), (85, 128, 42),
    (85, 170, 42), (85, 42, 42), (42, 85, 170), (255, 42, 255),
    (42, 42, 42), (128, 42, 128), (128, 128, 128), (255, 255, 255)
]

imagenames = [
    "bird",        # 0
    "background",  # 1
]

images = []
for name in imagenames:
    images.append(Image.open(name + '.png'))

# Resize images to target dimensions
images[0] = images[0].resize((40, 40))    # bird
images[1] = images[1].resize((320, 200))  # background

# Convert images to 'RGB' mode before quantizing
for i in range(len(images)):
    images[i] = images[i].convert('RGB')

# Quantize the bird and background images using the provided palette
# Bird
bird_img = Image.new('P', (40, 40))
bird_img.putpalette([val for color in palette for val in color])
images[0] = images[0].quantize(palette=bird_img, dither=0)

# Background
background_img = Image.new('P', (320, 200))
background_img.putpalette([val for color in palette for val in color])
images[1] = images[1].quantize(palette=background_img, dither=0)

# Extract pixel data from both images
pixel_datas = []
for i in range(len(images)):
    pixel_datas.append(list(images[i].getdata()))

# Replace transparent pixels in bird image with a specific color (e.g., 0xF5)
for i in range(len(pixel_datas[0])):
    if pixel_datas[0][i] == 0x00:  # Assuming 0x00 is the transparent color
        pixel_datas[0][i] = 0xF5

# Write pixel data to .asm files
for i, name in enumerate(imagenames):
    with open(name + '.asm', 'w') as file:
        file.write(f'pixel_data_{name}: db ')
        for y in range(len(pixel_datas[i])):
            file.write(f'0x{pixel_datas[i][y]:02X}')
            if y != len(pixel_datas[i]) - 1:
                file.write(', ')
        file.write('\n')

# Write palette data to palette.asm
with open('palette.asm', 'w') as file:
    file.write('\npalette_data: db ')
    for color in palette:
        r, g, b = [val // 4 for val in color]  # Scale down to 6-bit per channel
        file.write(f'0x{r:02X}, 0x{g:02X}, 0x{b:02X}')
        if color != palette[-1]:
            file.write(', ')
    file.write('\n')

print("Pixel data and palette have been written to *.asm files")