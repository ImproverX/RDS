;LZO28 fast unpacker for 8080, Ivan Gorodetsky 
;v2 2026-11-23 111-143 bytes
;
; lxi h,SrcAdr
; lxi d,DestAdr
; call LZO28_Decompress
;

;option -r
;#define BACKWARD
;option -s
;#define SHORT_LEN
;option -w
;#define SHORT_WIN

#ifdef BACKWARD
#define NEXT_HL dcx h
#define NEXT_DE dcx d
#define OFF_2B 0000h
#define OFF_HI_1B 00h
#else
#define NEXT_HL inx h
#define NEXT_DE inx d
#define OFF_2B 0FFFFh
#define OFF_HI_1B 0FFh
#endif

LZO28_Decompress:
#ifdef BACKWARD
        xra     a
#else
        mvi     a, OFF_HI_1B
#endif
        sta     LZO28_CopyLink+2
#ifndef SHORT_WIN
        sta     LZO28_CopyLink+3
#endif
LZO28_MainLoop:
        mov     c, m
        NEXT_HL
        mvi     a, 00000111b
        ana     c
        jz      LZO28_Link
        dcr     a
        jnz     LZO28_LitCopy
LZO28_LitLong:
        ora     m
        NEXT_HL
        jnz     LZO28_LitCopy
        stc
LZO28_LitCopy:
        rar
        mov     b, a
        jnc     LZO28_LDIR1
        mov     a, m
        stax    d
        NEXT_HL
        NEXT_DE
        xra     a
        ora     b
        jz      LZO28_Link
LZO28_LDIR1:
        mov     a, m
        stax    d
        NEXT_HL
        NEXT_DE
        mov     a, m
        stax    d
        NEXT_HL
        NEXT_DE
        dcr     b
        jnz     LZO28_LDIR1
LZO28_Link:
        mvi     a, 01111000b
        ana     c
#ifdef SHORT_LEN
        rz
#endif
        rrc
        rrc
        rrc
#ifndef SHORT_LEN
        jnz     LZO28_ReadOff
        ora     m
        NEXT_HL
        rz
LZO28_ReadOff:
#endif
        mov     b, a
        xra     a
        ora     c
        jm      LZO28_CopyLink
        mov     a, m
        NEXT_HL
#ifndef SHORT_WIN
        ora     a
#ifdef BACKWARD
        jm      LZO28_FarOff
#else
        jp      LZO28_FarOff
#endif
#endif
LZO28_ShortOff:
#ifdef SHORT_WIN
        sta     LZO28_CopyLink+2
#else
        push    h
        mvi     h, OFF_HI_1B
        mov     l, a
        shld    LZO28_CopyLink+2
        jmp     LZO28_CopyLink+4
#endif
LZO28_CopyLink:
        push    h
        lxi     h, OFF_2B
#ifdef BACKWARD
        inx     h
#endif
        dad     d
        xra     a
        ora     b
        rar
        mov     b, a
        jnc     LZO28_LDIR2
        ora     a
        jz      LZO28_copy1
        mov     a, m
        stax    d
        NEXT_HL
        NEXT_DE
LZO28_LDIR2:
        mov     a, m
        stax    d
        NEXT_HL
        NEXT_DE
        mov     a, m
        stax    d
        NEXT_HL
        NEXT_DE
        dcr     b
        jnz     LZO28_LDIR2
        pop     h
        jmp     LZO28_MainLoop
LZO28_copy1:
        mov     a, m
        stax    d
        NEXT_HL
        NEXT_DE
        pop     h
        jmp     LZO28_MainLoop
#ifndef SHORT_WIN
LZO28_FarOff:
#ifdef BACKWARD
        ani     7Fh
#else
        ori     80h
#endif
        mov     c, m
        NEXT_HL
        push    h
        mov     l, c
        mov     h, a
        shld    LZO28_CopyLink+2
        jmp     LZO28_CopyLink+4
#endif
