[org 0x0100]            ; .COM file format

start:
    ; Set video mode 13h (320x200, 256 colors)
    mov ax, 0x0013
    int 0x10

    ; Load the palette into the VGA DAC
    call load_palette

    ; Load and display the pixel data (40x40 image at position 140x100)
    call display_image

    ; Wait for a key press before exiting
    mov ah, 0x00
    int 0x16

    ; Exit to DOS
    mov ax, 0x4C00
    int 0x21

;=============================
; Function: load_palette
; Loads the palette data into VGA DAC registers
;=============================
load_palette:
    mov dx, 0x03C8          ; Set starting color index (0)
    xor al, al               ; Start at color 0
    out dx, al
    inc dx                   ; Move to DAC data register (0x03C9)

    ; Load all 256 colors (each color has 3 components: R, G, B)
    mov cx, 256 * 3          ; 256 colors * 3 components (RGB)
    mov si, palette_data     ; SI points to the palette data

load_palette_loop:
    lodsb                    ; Load the next palette value into AL
    out dx, al               ; Send the value to the DAC
    loop load_palette_loop    ; Repeat for all 256 colors
    ret

;=============================
; Function: display_image
; Displays the 40x40 image at position (140, 100) in video memory
;=============================
display_image:
    mov ax, 0xA000           ; Set ES to video memory segment
    mov es, ax
    mov si, pixel_data       ; SI points to the pixel data

    ; Set the position to (140, 100) in video memory
    mov di, 140 + 100 * 320  ; DI = x + y * 320 (offset in video memory)
    
    mov cx, 40               ; 40 rows to display
display_row:
    push cx
    mov cx, 40               ; 40 pixels per row
display_pixel:
    lodsb                    ; Load a byte (pixel color index) from pixel_data
    stosb                    ; Store the byte in video memory (A000h:DI)
    loop display_pixel       ; Repeat for all 40 pixels in the row

    ; Move to the next row (skip the rest of the screen line)
    add di, 320 - 40         ; Move to the next row by skipping 320-40 pixels
    pop cx
    loop display_row         ; Repeat for all 40 rows
    ret

;=============================
; Data Section
;=============================
%include 'ship_data.asm'     ; Include the pixel data and palette generated by Python