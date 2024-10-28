section .text
[org 0x0100]

jmp start
%include "file.asm"

bmp_filename db 'bg2.bmp', 0
file_handle dw 0

start:
    xor ax, ax;
    int 0x16

    openfile bmp_filename
    mov [file_handle], ax;

    ; Read the BMP header
    readfile [file_handle], 54, buffer

    ; Set video mode to 13h (320x200, 256 colors)
    mov ax, 0x13
    int 0x10

    ; Read Pallete
    readfile [file_handle], 256*4, buffer

    ; Load The Palette
    mov cx, 256;
    mov bx, 0;
    mov si, buffer
    .palleteLoop:
        push cx
        mov ax, 0x1010
        mov dh, [si+2]
        shr dh, 2
        mov ch, [si+1]
        shr ch, 2
        mov cl, [si+0]
        shr cl, 2
        int 0x10;
        pop cx
        add si, 4;
        inc bx;
        loop .palleteLoop

    
    mov ax, 0xA000
    mov es, ax
    mov cx, 200
    mov di, 64000-320
    .readScreen:
        push cx

        readfile [file_handle], 320, buffer
        mov si, buffer
        mov cx, 320
        rep movsb

        pop cx
        sub di, 320*2
        loop .readScreen

    closefile bmp_filename

    xor ax, ax;
    int 0x16

    ; Exit the program
    mov ax, 0x4C00
    int 0x21

buffer: times 64000 db 0