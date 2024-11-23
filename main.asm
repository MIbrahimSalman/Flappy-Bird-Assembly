%define PILLAR_WIDTH 32
%define PILLAR_HEIGHT 128
%define PILLAR_COUNT 3
%define STARTING_ROW 320-22
%define PILLAR_STEP 10
%define PILLAR_GAP 320/3
%define VERTICAL_PILLAR_GAP 60

%define BIRD_HEIGHT 24
%define BIRD_WIDTH 32

; %define BIRD_HEIGHT 40
; %define BIRD_WIDTH 40

section .text
[org 0x0100]

jmp start
%include "file.asm"

transparent_pallette db 0xFF

bg_filename db 'bgg2.bmp', 0
bg_handle dw 0

bird_filename db 'bird3.bmp', 0
bird_handle dw 0

pillar_filename db 'pillar1.bmp', 0
pillar_handle dw 0

down_pillar_filename db 'pillar2.bmp', 0
down_pillar_handle dw 0

bird_row: dw 100
bird_column: dw 100

pillar_columns: dw -1, -1, STARTING_ROW
pillar_heights: dw 50, 70, 64

spacePressed: db 0
collsionFlag: db 0

escMsg: db "Press Y to exit or N to continue!$"
YPressed: db 0
NPressed: db 0

score: dw 0
scoreAdded: db 0
transparentColor: db 0

gameOverMessage db 'Game Over! Press any key to exit.$'

PILLAR_OUTLINE_COLOR: db 0x48

delay:
    push cx
    mov cx, 10
    .l1:
        push cx
        mov cx, 0xFFFF
        .l2:
            loop .l2
        pop cx
        loop .l1
    pop cx
    ret

drawBG:
    pusha

    ; Read the BMP header
    setCursor [bg_handle], 0, 54

    ; Read Pallete
    readfile [bg_handle], 256*4, buffer

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
        cmp byte [si+0], 0
        jne .noMatch
        cmp byte [si+1], 0
        jne .noMatch
        cmp byte [si+2], 135
        jne .noMatch
            mov [transparentColor], bl
        .noMatch:
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

        readfile [bg_handle], 320, buffer
        mov si, buffer
        mov cx, 320
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            jz .dontPrint
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            loop .readLine

        pop cx
        sub di, 320+320
        loop .readScreen
    
    popa
    ret

checkBirdInPillar:
    push bp
    mov bp, sp
    pusha

    mov word [bp+4], 0

    mov ax, [bird_column]
    cmp ax, [pillar_columns+0]
    jl .skipPillar0
    sub ax, PILLAR_WIDTH
    cmp ax, [pillar_columns+0]
    jg .skipPillar0
        mov word [bp+4], -1
    .skipPillar0:

    mov ax, [bird_column]
    cmp ax, [pillar_columns+2]
    jl .skipPillar1
    sub ax, PILLAR_WIDTH
    cmp ax, [pillar_columns+2]
    jg .skipPillar1
        mov word [bp+4], -1
    .skipPillar1:

        
    mov ax, [bird_column]
    cmp ax, [pillar_columns+4]
    jl .skipPillar2
    sub ax, PILLAR_WIDTH
    cmp ax, [pillar_columns+4]
    jg .skipPillar2
        mov word [bp+4], -1
    .skipPillar2:
        
    popa
    mov sp, bp
    pop bp
    ret

drawBird:
    push bp
    mov bp, sp
    pusha

    sub sp, 2
    call checkBirdInPillar
    pop ax
    cmp ax, 0
    je .notInPillar
        cmp byte [scoreAdded], 0
        jne .afterPillarCheck
        inc word [score]
        mov byte [scoreAdded], 1
        ; popa
        ; mov sp, bp
        ; pop bp
        ; ret
        jmp .afterPillarCheck
    .notInPillar:
        mov byte [scoreAdded], 0
    .afterPillarCheck:

    setCursor [bird_handle], 0, 54+256*4
    mov ax, 0xA000
    mov es, ax
    mov ax, [bird_row]
    mov bx, 320
    mul bx
    add ax, [bird_column]
    mov di, ax
    mov cx, BIRD_HEIGHT
    mov byte [collsionFlag], 0
    .readScreen:
        push cx

        readfile [bird_handle], BIRD_WIDTH, buffer
        mov si, buffer
        mov cx, BIRD_WIDTH
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            jz .dontPrint
            push ax
            mov al, [es:di]
            cmp al, [PILLAR_OUTLINE_COLOR]
            jne .noCollision
                mov byte [collsionFlag], 1
            .noCollision:
            pop ax
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            loop .readLine

        pop cx
        sub di, 320+BIRD_WIDTH
        loop .readScreen
        
    popa
    mov sp, bp
    pop bp
    ret

; BP+4 => Pillar Row
; BP+6 => Pillar Column
; BP+8 => Pillar Height
drawUpPillar:
    push bp
    mov bp, sp
    pusha

    mov ax, PILLAR_HEIGHT
    sub ax, [BP+8]
    mov bx, PILLAR_WIDTH
    mul bx
    add ax, 54+256*4
    adc ax, 0

    setCursor [pillar_handle], dx, ax
    mov ax, 0xA000
    mov es, ax
    mov ax, [BP+4]
    mov bx, 320
    mul bx
    add ax, [BP+6]
    mov di, ax
    mov cx, [BP+8]
    .readScreen:
        push cx

        readfile [pillar_handle], PILLAR_WIDTH, buffer
        mov si, buffer
        mov cx, PILLAR_WIDTH
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            jz .dontPrint
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            loop .readLine

        pop cx
        sub di, 320+PILLAR_WIDTH
        loop .readScreen

    popa
    mov sp, bp
    pop bp
    ret 6


; BP+4 => Pillar Column
; BP+6 => Pillar Height
drawDownPillar:
    push bp
    mov bp, sp
    pusha

    setCursor [down_pillar_handle], 0, 54+256*4
    mov ax, 0xA000
    mov es, ax
    mov ax, [BP+6]
    mov bx, 320
    mul bx
    add ax, [BP+4]
    mov di, ax
    mov cx, [BP+6]
    .readScreen:
        push cx

        readfile [down_pillar_handle], PILLAR_WIDTH, buffer
        mov si, buffer
        mov cx, PILLAR_WIDTH
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            jz .dontPrint
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            loop .readLine

        pop cx
        sub di, 320+PILLAR_WIDTH
        loop .readScreen

    popa
    mov sp, bp
    pop bp
    ret 4

; BP+4 => Pillar Column
; BP+6 => Pillar Height
drawBackgroundInDownPillarPlace:
    push bp
    mov bp, sp
    pusha

    setCursor [down_pillar_handle], 0, 54+256*4

    mov ax, 0xA000
    mov es, ax
    mov ax, [BP+6]
    mov bx, 320
    mul bx
    mov dx, 54+256*4 + 199*320
    sub dx, ax
    add dx, [BP+4]
    add ax, [BP+4]
    mov di, ax
    mov si, dx

    setCursor [bg_handle], 0, si
    mov cx, [BP+6]
    .readScreen:
        push cx

        readfile [down_pillar_handle], PILLAR_WIDTH, buffer
        readfile [bg_handle], 320, buffer+PILLAR_WIDTH
        mov si, buffer
        mov bx, buffer+PILLAR_WIDTH
        mov cx, PILLAR_WIDTH
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            je .dontPrint
            mov al, [bx]
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            inc bx
            loop .readLine

        pop cx
        sub di, 320+PILLAR_WIDTH
        loop .readScreen

    popa
    mov sp, bp
    pop bp
    ret 4

; BP+4 => Pillar Row
; BP+6 => Pillar Column
; BP+8 => Pillar Height
drawBackgroundInUpPillarPlace:
    push bp
    mov bp, sp
    pusha

    mov ax, PILLAR_HEIGHT
    sub ax, [BP+8]
    mov bx, PILLAR_WIDTH
    mul bx
    add ax, 54+256*4
    adc ax, 0

    setCursor [pillar_handle], dx, ax

    mov ax, 0xA000
    mov es, ax
    mov ax, [BP+4]
    mov bx, 320
    mul bx
    mov dx, 54+256*4 + 199*320
    sub dx, ax
    add dx, [BP+6]
    add ax, [BP+6]
    mov di, ax
    mov si, dx

    setCursor [bg_handle], 0, si
    mov cx, [BP+8]
    .readScreen:
        push cx

        readfile [pillar_handle], PILLAR_WIDTH, buffer
        readfile [bg_handle], 320, buffer+PILLAR_WIDTH
        mov si, buffer
        mov bx, buffer+PILLAR_WIDTH
        mov cx, PILLAR_WIDTH
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            je .dontPrint
            mov al, [bx]
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            inc bx
            loop .readLine

        pop cx
        sub di, 320+PILLAR_WIDTH
        loop .readScreen

    popa
    mov sp, bp
    pop bp
    ret 6

drawBackgroundInBirdPlace:
    pusha

    mov ax, 0xA000
    mov es, ax
    mov ax, [bird_row]
    mov bx, 320
    mul bx
    mov dx, 54+256*4 + 199*320
    sub dx, ax
    add dx, [bird_column]
    add ax, [bird_column]
    mov di, ax
    mov si, dx

    setCursor [bird_handle], 0, 54+256*4
    setCursor [bg_handle], 0, si
    mov cx, BIRD_HEIGHT
    .readScreen:
        push cx

        readfile [bird_handle], BIRD_WIDTH, buffer
        readfile [bg_handle], 320, buffer+BIRD_WIDTH
        mov si, buffer
        mov bx, buffer+BIRD_WIDTH
        mov cx, BIRD_WIDTH
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            je .dontPrint
            mov al, [bx]
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            inc bx
            loop .readLine

        pop cx
        sub di, 320+BIRD_WIDTH
        loop .readScreen

    popa
    ret

oldisr: dd 0

kbisr:
    pusha
    in al, 0x60

    cmp al, 0xB9
    je .SpaceUP

    cmp al, 0X01
    je .escPressed

    jmp .retWithoutChaining
    .continueNormal:
        popa
        jmp far [oldisr]
    .retWithoutChaining:
        mov al, 0x20
        out 0x20, al
        popa
        iret

    .SpaceUP:
        mov byte [spacePressed], 1
        jmp .retWithoutChaining

    .escPressed:
        mov byte[YPressed], 0
        mov byte[NPressed], 0
        call clrscrn
        call prompt_and_input_str
        jmp .retWithoutChaining

movePillars:
    pusha
    mov cx, PILLAR_COUNT
    mov bx, PILLAR_COUNT*2
    .movePillar:
        sub bx, 2

        cmp word [pillar_columns+bx], -1
        je .skipPillar

        push word [pillar_heights+bx]
        push word [pillar_columns+bx]
        push 184
        call drawBackgroundInUpPillarPlace

        mov ax, [pillar_heights+bx]
        add ax, VERTICAL_PILLAR_GAP
        sub ax, 184
        neg ax
        push word ax
        push word [pillar_columns+bx]
        call drawBackgroundInDownPillarPlace

        sub word [pillar_columns+bx], PILLAR_STEP
        cmp word [pillar_columns+bx], 0
        jge .dontReset
            mov word [pillar_columns+bx], STARTING_ROW-PILLAR_STEP
        .dontReset:

        push word [pillar_heights+bx]
        push word [pillar_columns+bx]
        push 184
        call drawUpPillar

        mov ax, [pillar_heights+bx]
        add ax, VERTICAL_PILLAR_GAP
        sub ax, 184
        neg ax
        push word ax
        push word [pillar_columns+bx]
        call drawDownPillar

        cmp word [pillar_columns+bx], STARTING_ROW-PILLAR_GAP-PILLAR_STEP
        jg .skipPillar
        cmp bx, 0
        je .skipPillar
        cmp word [pillar_columns+bx-2], -1
        jne .skipPillar
        mov word [pillar_columns+bx-2], STARTING_ROW-PILLAR_STEP
        .skipPillar:
        loop .movePillar
    popa
    ret

moveGround:
    push bp
    mov bp, sp
    pusha
    mov ax, 0xA000
    mov es, ax

    mov cx, 200-185
    mov di, 320*185

    next_row:
        mov al, byte[es:di]
        mov si, di
        mov dx, 320-1

        shift_row:
            mov bl, byte[es:si+1]
            mov byte[es:si], bl
            inc si
            dec dx
            jnz shift_row
        
        mov [es:si], al

        add di, 320
        loop next_row

    popa
    mov sp, bp
    pop bp

    ret

clrscrn:
    pusha
    mov ax, 0xA000
    mov es, ax

    mov di, 0          
    mov al, 0xFF       
    mov cx, 64000
        
    .clearLoop:
        stosb              
        loop .clearLoop   

    popa
    ret

prompt_and_input_str:
    push bp
    mov bp, sp
    pusha

    ; Center cursor
    mov dl, 0
    mov dh, 0

    mov bh, 0h
    mov ah, 02h
    int 0x10

    ; PROMPT
    mov ah, 09h
    lea dx, escMsg
    int 0x21

    ; INPUT
    .waitForInput:
        in al, 0x60             
        cmp al, 0x15           
        je .YPressed
        cmp al, 0x31            
        je .NPressed
        jmp .waitForInput

    .NPressed:
        call drawBG
        mov byte[NPressed], 1
        jmp .exit

    .YPressed:
        mov byte[YPressed], 1
        jmp .exit

    .exit:
        popa
        mov sp, bp
        pop bp
        ret

start:

    xor ax, ax;
    int 0x16

    ; Set video mode to 13h (320x200, 256 colors)
    mov ax, 0x13
    int 0x10

    mov ax, 0;
    mov es, ax;
    ; SAVE PREVIOUS KBISR
    mov ax, [es:9*4]
    mov [oldisr], ax
    mov ax, [es:9*4+2];
    mov [oldisr+2], ax

    ; HOOK
    mov [es:9*4+2], cs
    mov word [es:9*4], kbisr

    openfile bird_filename
    mov [bird_handle], ax;
    openfile bg_filename
    mov [bg_handle], ax
    openfile pillar_filename
    mov [pillar_handle], ax
    openfile down_pillar_filename
    mov [down_pillar_handle], ax

    call drawBG

    .infLoop:
        cmp byte[YPressed], 1
        je .gameOver
        call moveGround
        call drawBackgroundInBirdPlace
        cmp byte [spacePressed], 0
        je .dontMoveUp
            mov byte [spacePressed], 0
            cmp word [bird_row], 65
            jl .dontMoveUp
            sub word [bird_row], 25
        .dontMoveUp:
        add word [bird_row], 5
        call drawBird
        cmp byte[collsionFlag], 1
        je .gameOver
        cmp word [bird_row], 184
        jge .stopLoop
        call movePillars
        call delay
        jmp .infLoop

    .gameOver:
        mov ah, 0x09
        lea dx, gameOverMessage
        int 0x21 

    .stopLoop:
    closefile bird_handle
    closefile bg_handle
    closefile pillar_handle
    closefile down_pillar_handle

    ;UNHOOK
    mov ax, 0;
    mov es, ax;
    mov ax, [oldisr]
    mov [es:9*4], ax
    mov ax, [oldisr+2];
    mov [es:9*4+2], ax

    xor ax, ax;
    int 0x16

    ; Exit the program
    mov ax, 0x4C00
    int 0x21

buffer: times 2000 db 0