;(перед компилированием преобразовать в CP866)
;
;
; BDOS и BIOS, компилируются одновременно, т.к. в них много
; перекрёстных ссылок и в памяти они расположены друг за другом
;
#DEFINE VERSION "3.07"
#DEFINE DMODIFIC "6.05.2022"
;
#include "bdos.inc"
#include "b7h.inc"
;
	.org 0BE98h
PNAME:	.DB 12,27,'/',27,'b',"(c) "
;	.DB "Резидентная Дисковая Система."
	.DB "Є┼┌╔─┼╬╘╬┴╤ ф╔╙╦╧╫┴╤ є╔╙╘┼═┴."
;	.DB "              Версия X.XX "
	.DB "              ў┼╥╙╔╤ "
	.DB VERSION,' ',10,"(c) "
;	.DB "Вьюнов В.А."
	.DB "ў╪└╬╧╫ ў.с."
	.DB "   Copyright (c) 1994-1997 "
	.DB "by Vitaly Vewnov.",10
;	.DB " Марта 24 числа 1997г. от Р.Х."
	.DB " э┴╥╘┴ 24 ▐╔╙╠┴ 1997╟. ╧╘ Є.ш."
	.DB 10,27,'a'
;	.DB "Модификация " ... "г." ...
	.DB "э╧─╔╞╔╦┴├╔╤ "
	.DB DMODIFIC,"╟., Improver",10,'$'
;
	.org 0BF60h
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
	.DB " V"
	.DB VERSION
	.DB "     "
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
	.org 0BFFFh	; выравнивание размера
	.db 0
	.END
