        include 'C:\KPO\FASM\INCLUDE\MACRO\PROC16.inc'
        org 100h
Width = 320
Height = 200

Start:
        mov     ah, $0F
        int     10h
        mov     [bOldMode], al
        mov     [bOldPage], bh

        mov     ax, $0013
        int     10h

        push    $A000
        pop     es

        mov     cx, 320 * 200
        xor     di, di

        ;all canvas
        mov     al, $01
        mov     cx, 320 * 200
        rep     stosb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;white left-up to rightdown diagonal

        mov     si, 0
.LLoop:
        cmp     si, 30
        je      .lEnd

        mov     bx, si
        mov     cx, Height - 1
        sub     cx, bx
        stdcall DrawLine, bx, 0, Width - 1, cx, $0f

        inc     si
        jmp     .LLoop
.lEnd:


        mov     si, 0
.LLoop2:
        cmp     si, 30
        je      .lEnd2

        mov     bx, si
        mov     cx, Width - 1
        sub     cx, bx
        stdcall DrawLine, 0, bx, cx ,Height - 1, $0f

        inc     si
        jmp     .LLoop2
.lEnd2:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;red left-up to rightdown diagonal
        mov     si, 0
.LRLoop:
        cmp     si, 15
        je      .lREnd

        mov     bx, si
        mov     cx, Height - 1
        sub     cx, bx
        stdcall DrawLine, bx, 0, Width - 1, cx, $27

        inc     si
        jmp     .LRLoop
.lREnd:


        mov     si, 0
.LRLoop2:
        cmp     si, 15
        je      .lREnd2

        mov     bx, si
        mov     cx, Width - 1
        sub     cx, bx
        stdcall DrawLine, 0, bx, cx ,Height - 1, $27

        inc     si
        jmp     .LRLoop2
.lREnd2:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;white left-down to right-up diagonal

        mov     si, 0
.RLoop:
        cmp     si, 30
        je      .rEnd

        mov     bx, si
        mov     cx, Height - 1
        sub     cx, bx
        mov     dx, Width - 1
        sub     dx, bx
        stdcall DrawLine, 0, cx, dx, 0, $0f

        inc     si
        jmp     .RLoop
.rEnd:


        mov     si, 0
.RLoop2:
        cmp     si, 30
        je      .rEnd2

        mov     bx, si
        mov     cx, Width - 1
        sub     cx, bx
        stdcall DrawLine, bx, Height - 1, Width - 1, bx, $0f

        inc     si
        jmp     .RLoop2
.rEnd2:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;red left-down to right-up diagonal
        mov     si, 0
.RRLoop:
        cmp     si, 15
        je      .rREnd

         mov     bx, si
        mov     cx, Height - 1
        sub     cx, bx
        mov     dx, Width - 1
        sub     dx, bx
        stdcall DrawLine, 0, cx, dx, 0, $27

        inc     si
        jmp     .RRLoop
.rREnd:


        mov     si, 0
.RRLoop2:
        cmp     si, 15
        je      .rREnd2

         mov     bx, si
        mov     cx, Width - 1
        sub     cx, bx
        stdcall DrawLine, bx, Height - 1, Width - 1, bx, $27

        inc     si
        jmp     .RRLoop2
.rREnd2:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        ;vertical white line
        mov     bx, 0
.Loop:
        cmp     bx, 200
        je      .end
        mov     ax, Width
        mul     bx
        mov     di, ax
        add     di, 130

        mov     al, $0f
        mov     cx, 60
        rep     stosb

        inc     bx
        jmp     .Loop
 .end:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;horizontal white line
        mov    di, Width * 70
        mov    cx, 60 * Width
        rep     stosb

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;vertical red line
        mov     bx, 0
.Loop2:
        cmp     bx, 200
        je      .end2
        mov     ax, Width
        mul     bx
        mov     di, ax
        add     di, 140

        mov     al, $27
        mov     cx, 40
        rep     stosb

        inc     bx
        jmp     .Loop2
 .end2:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;horizontal red line
        mov    di, Width * 80
        mov    cx, 40 * Width
        rep     stosb

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     ax, $0C08
        int     21h
        test    al, al
        jnz     @F
        mov     ah, $08
        int     21h
@@:

        movzx   ax, [bOldMode]
        int     10h
        mov     ah, $05
        mov     al, [bOldPage]
        int     10h

        ret





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc    DrawLine uses ax bx cx dx di,\
        x0, y0, xk, yk: WORD, color: Byte
        sub     sp, 18
        ;bp-2 - x
        ;bp-4 - y
        ;bp-6 - dx
        ;bp-8 - dy
        ;bp-10 - t
        ;bp-12 - k
        ;bp-14 - sign(x2-x1)
        ;bp-16 - sign(y2-y1)
        ;bp-18 - ChangeFlag
        ;Initialize
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov     dx, [x0] ;current x
        mov     [bp - 2], dx
        mov     ax, [y0] ;current y
        mov     [bp - 4], ax

        ;dx
        mov     cx, [xk]
        sub     cx, dx
        cmp     cx, 0
        jl      @F
        mov     [bp - 6], cx
        je      .zero
        mov     [bp - 14], word 1
        jmp     .cont1
.zero:
        mov     [bp - 14], word 0
        jmp     .cont1
@@:
        neg     cx
        mov     [bp - 6], cx
        mov     [bp - 14], word -1
.cont1:


        ;dy
        mov     cx, ax
        sub     cx, [yk]
        cmp     cx, 0
        jl      @F
        mov     [bp - 8], cx
        je      .zero2
        mov     [bp - 16], word 1
        jmp     .cont2
.zero2:
        mov     [bp - 16], word 0
        jmp     .cont2
@@:
        neg     cx
        mov     [bp - 8], cx
        mov     [bp - 16], word -1

.cont2:

        mov     cx, [bp-8]
        mov     ax, [bp-6]
        cmp     cx, ax
        jna     .else
        xchg    cx, ax
        mov     [bp-8], cx
        mov     [bp-6], ax
        mov     [bp-18], word 1
        jmp     .end
.else:
        mov     [bp-18], word 0
.end:
        ;t
        mov     cx, [bp-8]
        add     cx, cx
        sub     cx, [bp - 6]
        mov     [bp - 10], cx
        ;k
        mov     cx, [bp - 8]
        add     cx, cx
        mov     [bp - 12], cx
        ;end of Inintialize
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



        mov     cx, [bp-4]
        mov     ax, Width
        mul     cx
        add     ax, [bp-2]
        mov     di, ax

        mov     ch, [color]
        mov     byte [es:di], ch

.Loop:
        mov     cx, [bp - 2]
        cmp     cx, [xk]
        je     .EndOfLoop

.While:
        cmp     [bp-10], word 0
        jl      .endWhile
        cmp     [bp-18], word 1
        jne     .else1
        mov     cx, [bp-14]
        add     [bp-2], cx
        add     di, cx
        jmp     .ifend
.else1:
        mov     cx, [bp-16]
        sub     [bp-4], cx
        mov     ax, Width
        imul    cx
        sub     di, ax
.ifend:
        mov     cx, [bp-6]
        add     cx, cx
        sub     [bp-10], cx

        jmp     .While
.endWhile:

        cmp     [bp-18], word 1
        jne     .else2
        mov     cx, [bp-16]
        sub     [bp-4], cx
        mov     ax, Width
        imul    cx
        sub     di, ax
        jmp     .ifend1
.else2:
        mov     cx, [bp-14]
        add     [bp-2], cx
        add     di, cx
.ifend1:

        mov     cx, [bp-8]
        add     cx, cx
        add     [bp-10], cx




        mov     ch, [color]
        mov     byte [es:di], ch
        jmp     .Loop
.EndOfLoop:

        add     sp, 18
        ret
endp



bOldMode        db      ?
bOldPage        db      ?