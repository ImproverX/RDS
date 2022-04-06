; BDOS и BIOS, компилируются одновременно, т.к. в них много
; перекрёстных ссылок и в памяти они расположены друг за другом
;
#include "bdos.inc"
#include "b7h.inc"
;
	.org 0BEE0h
L_0160:	.DB 00Ch		; надпись при загрузке ОС
	.DB 01Bh, 02Fh
	.DB 01Bh, 062h
	.DB 099h, 09Dh, 09Dh, 09Dh
	.DB 09Dh, 09Dh, 09Dh, 09Dh
	.DB 09Dh, 09Dh, 09Dh, 09Dh
	.DB 09Dh, 09Dh, 09Dh, 09Dh
	.DB 09Dh, 09Dh, 09Dh, 09Dh
	.DB 08Bh, 00Ah
	.DB 08Ah
	.DB "     "
	.DB 0F2h  ; Р
	.DB 0E4h  ; Д
	.DB 0F3h  ; С
	.DB " V3.07     "
	.DB 08Ah, 00Ah
	.DB 08Ah
	.DB "    "
	.DB 0F7h  ; В
	.DB 0C5h  ; е
	.DB 0CBh  ; к
	.DB 0D4h  ; т
	.DB 0CFh  ; о
	.DB 0D2h  ; р
	.DB " 06"
	.DB 0E3h  ; ц
	.DB "+    "
	.DB 08Ah, 00Ah
	.DB 08Ah
	.DB "  CP/M BDOS V2.2+  "
	.DB 08Ah, 00Ah
	.DB 08Ah
	.DB "  ABC"
DMARK:	.DB "D-disk drive  "	; метка буквы диска D
	.DB 08Ah, 00Ah
	.DB 098h, 09Dh, 09Dh, 09Dh
	.DB 09Dh, 09Dh, 09Dh, 09Dh
	.DB 09Dh, 09Dh, 09Dh, 09Dh
	.DB 09Dh, 09Dh, 09Dh, 09Dh
	.DB 09Dh, 09Dh, 09Dh, 09Dh
	.DB 08Ch, 00Ah
	.DB 01Bh, 061h
	.DB " 62,5Kb free.", 00Ah,'$'
;
	.org 0BF7Fh	; выравнивание размера
	.db 0
	.END
