[org 0x0100]

jmp start

bmp_filename db 'background.bmp', 0
file_handle dw 0
buffer resb 64000  ; Allocate space for the file data

start:
    ; Open the file
    mov ah, 0x3D
    mov al, 0
    mov dx, bmp_filename
    int 0x21
    mov [file_handle], ax

    ; Read the BMP header
    mov ah, 0x3F
    mov bx, [file_handle]
    mov dx, buffer
    mov cx, 54  ; header size
    int 0x21

    ; Set video mode to 13h (320x200, 256 colors)
    mov ax, 0x13
    int 0x10

    ; Read BMP pixel data and display it
    mov bx, [file_handle]
    mov [buffer], bx
    mov di, 0
    mov cx, 64000

;read_loop:
    mov ax, 0xA000
    mov es, ax
    mov ax, 0
    mov ah, 0x3F
    mov si, buffer
    ;int 0x21
    
read_loop:
    mov al, [si]
    mov [es:di], al
    inc di
    inc si
    dec cx
    jnz read_loop

    ; Close the file
    mov ah, 0x3E
    mov bx, [file_handle]
    int 0x21

    ; Wait for a keypress
    xor ax, ax
    int 0x16

    ; Exit the program
    mov ax, 0x4C00
    int 0x21
