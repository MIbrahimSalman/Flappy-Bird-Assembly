org 0x0100

; Data Segment to hold file-related information
filename db 'palette.bmp', 0  ; Filename of the BMP file
buffer_size equ 1024  ; Buffer size to store the 256-color palette (256 * 4 bytes for each entry)
palette_buffer times buffer_size db 0  ; Allocate buffer space for the palette

; Set the video mode (320x200, 256 colors)
start:
    mov ax, 0x13
    int 0x10

    ; Load the color palette from the BMP file
    call load_palette_from_bmp

    ; Keep the program running to observe the palette
    mov ah, 0x00
    int 0x16  ; Wait for key press

    ; Exit to DOS
    mov ax, 0x4C00
    int 0x21

;=============================
; Function: load_palette_from_bmp
; Loads the palette from the BMP file
;=============================
load_palette_from_bmp:
    ; Open the BMP file
    mov ah, 0x3D  ; DOS service to open a file
    mov al, 0x00  ; Open for reading
    lea dx, [filename]
    int 0x21      ; Call DOS interrupt
    jc error      ; If carry is set, there was an error
    mov bx, ax    ; BX = file handle

    ; Seek to the palette start (54 bytes from the beginning)
    mov ax, 0x4200  ; DOS service to set file pointer (absolute)
    xor cx, cx      ; CX:DX = offset to move to (54 bytes for header)
    mov dx, 54
    int 0x21        ; Call DOS interrupt

    ; Read 1024 bytes (256 entries * 4 bytes per entry) into palette_buffer
    mov ah, 0x3F   ; DOS service to read from file
    lea dx, [palette_buffer]
    mov cx, buffer_size  ; Read 1024 bytes
    int 0x21        ; Call DOS interrupt

    ; Close the file
    mov ah, 0x3E   ; DOS service to close file
    int 0x21

    ; Load the palette data into the VGA DAC registers
    mov dx, 0x03C8  ; Set DAC to starting color index (0)
    xor al, al      ; Start with color index 0
    out dx, al
    inc dx          ; Move to DAC data register (0x03C9)

    ; Load all 256 colors (each color has 3 components: R, G, B)
    mov si, palette_buffer  ; SI points to the buffer
    mov cx, 256  ; 256 colors to load
load_palette_loop:
    ; Read the BGR values from the buffer and write to the DAC
    lodsb   ; Load blue component
    out dx, al  ; Send it to DAC
    lodsb   ; Load green component
    out dx, al  ; Send it to DAC
    lodsb   ; Load red component
    out dx, al  ; Send it to DAC
    lodsb   ; Skip the reserved byte (Alpha, unused in VGA mode)

    loop load_palette_loop  ; Repeat for all 256 colors
    ret

error:
    ; Handle file open error
    mov ah, 0x09
    lea dx, [error_msg]
    int 0x21
    ret

error_msg db 'Error opening BMP file.', 0x0D, 0x0A, '$'
