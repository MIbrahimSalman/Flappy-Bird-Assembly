from PIL import Image

# Load the images
bgimage = Image.open("background.png")
imagenames = [
    "bird", #0
]
images = []
for name in imagenames:
    images.append(Image.open(name+'.png'))

# Resize accordingly
bgimage = bgimage.resize((320,200))
images[0] = images[0].resize((40,40)) # bird


## DO NOT CHANGE BELOW ##
# Ensure the image is in the correct mode (8-bit pixels, 256 colors)
bgimage = bgimage.convert('P', colors=256)
for i in range(len(images)):
    images[i] = images[i].convert('RGB', colors=256)
    
# Get the palette data
palette = bgimage.getpalette()

for i in range (len(images)):
    p_img = Image.new('P', (40, 40))
    p_img.putpalette(palette)

    conv = images[i].quantize(palette=p_img, dither=0)
    images[i] = conv.convert('P')


# Get the pixel data
bgpixels = list(bgimage.getdata())
pixels = []
for i in range(len(images)):
    pixels.append(list(images[i].getdata()))

images[0].save(imagenames[0]+'.bmp')


# Get image dimensions
bgwidth, bgheight = bgimage.size
heights = []
widths = []
for i in range(len(images)):
    heights.append(images[i].size[0])
    widths.append(images[i].size[1])



# Convert pixel data to a format suitable for assembly
bg_pixel_data = []
for y in range(bgheight):
    for x in range(bgwidth):
        bg_pixel_data.append(bgpixels[y * bgwidth + x])

pixel_datas = [[]]
for i in range(len(images)):
    for y in range(heights[i]):
        for x in range(widths[i]):
            pixel_datas[i].append(pixels[i][y*widths[i]+x])
    

#filepath = r'C:\Users\user\Downloads\FlappyBirdCOAL'

for x in range(heights[0]):
    for y in range(widths[0]):
        if pixel_datas[0][x*widths[0]+y] == 0x00:
            pixel_datas[0][x*widths[0]+y] = 0xF5

# Write the pixel data and palette to a file
with open('background_img.asm', 'w') as file:
    file.write('pixel_data_background: db ')
    for i in range(len(bg_pixel_data)):
        file.write(f'0x{bg_pixel_data[i]:02X}')
        if i != len(bg_pixel_data) - 1:
            file.write(', ')

for i in range(len(imagenames)):
    with open(imagenames[i]+'.asm', 'w') as file:
        file.write(f'pixel_data_{imagenames[i]}: db ')
        for y in range(len(pixel_datas[i])):
            file.write(f'0x{pixel_datas[i][y]:02X}')
            if y != len(pixel_datas[i]) - 1:
                file.write(', ')

with open('pallete_data.asm', 'w') as file:
    file.write('\n\npalette_data_background: db ')
    for i in range(0, len(palette), 3):
        file.write(f'0x{palette[i]//4:02X}, 0x{palette[i+1]//4:02X}, 0x{palette[i+2]//4:02X}')
        if i != len(palette) - 3:
            file.write(', ')

print("Pixel data and palette have been written to *.asms")