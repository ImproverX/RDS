;(перед компилированием преобразовать в KOI-8R)
;
; BDOS и BIOS, компилируются одновременно, т.к. в них много
; перекрёстных ссылок и в памяти они расположены друг за другом
;
#DEFINE VERSION "3.08"
#DEFINE DMODIFIC "17.02.2023"
;
#include "bdos.inc"
#include "b7h.inc"
;
	.org 0BEA4h	;0BE98h
PNAME:	.DB 12,27,'/',27,'b',"(c) "
	.DB "Резидентная Дисковая Система."
	.DB "              Версия "
	.DB VERSION,' ',10,"(c) "
	.DB "Вьюнов В.А."
	.DB "   Copyright (c) 1994-1997 "
	.DB "by Vitaly Vewnov.",10
	.DB " Марта 24 числа 1997г. от Р.Х."
	.DB 10,27,'a'
	.DB "Модификация "
	.DB DMODIFIC,"г., Improver",10,'$'
;
	.org 0BF66h
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
	.DB "     РДС V"
	.DB VERSION
	.DB "     "
	.DB 08Ah, 00Ah
	.DB 08Ah
	.DB "    Вектор 06Ц+    "
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
;	.org 0BFFFh	; выравнивание размера
;	.db 0
	.END
