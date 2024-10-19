def create_wide_palette():
    palette = []
    step = 256 // 6  # Number of steps for each primary color component

    # Primary colors and their mixtures
    for r in range(0, 256, step):
        for g in range(0, 256, step):
            for b in range(0, 256, step):
                if len(palette) < 256:
                    palette.extend((r, g, b))

    # If there are fewer than 256 colors, fill the remaining with gradients of gray
    while len(palette) < 256 * 3:
        gray = len(palette) // 3
        palette.extend((gray, gray, gray))

    return palette[:768]  # Ensure it's exactly 256 colors (256 * 3 values)

# Create the palette
palette = create_wide_palette()

# Print the palette as a list
print("Palette:", palette)

# If you want to save the palette as a list to a file
with open('palette.txt', 'w') as file:
    file.write(str(palette))

print("Palette saved as palette.txt")
