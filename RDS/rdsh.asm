;(перед компилированием преобразовать в CP866)
	.ORG	100H
;#DEFINE NoPACK
STDISP:	.EQU	0CA00H
SELDSK:	.EQU	0FB1BH
SETTRK:	.EQU	0FB1EH
SETSEC:	.EQU	0FB21H
SETDMA:	.EQU	0FB24H
WRITE:	.EQU	0FB2AH
READ:	.EQU	0FB27H
;OS:	.EQU	400H
TDSK:	.EQU	OS+38h		; ПП проверки наличия КД11
DISKS:	.EQU	0AE46H		; количество дисковых устройств -1
STRA:	.EQU	OS+60h		; ссылка на надпись в загрузчике
DMARK:	.EQU	STRA+62h
PACK:	.EQU	OS+100h
LCOM:	.EQU	0B80h		; размер файла ccph.obj
#ifdef NoPACK
RDS:	.EQU	PACK+LCOM	; << начало блока + размер файла ccph.obj
COM:	.EQU	PACK
#else
RDS:	.EQU	PACK		;
COM:	.EQU	0A000H-LCOM	; туда будут распакованы данные
#endif
	LXI	SP,80H
;;	JMP	START
START:	DI
	MVI	A,20H		; 0010 0000 -- банк 3 как ОЗУ A000-DFFFh
	OUT	10H
	LXI	H,RDS		; откуда
#ifdef NoPACK
	LXI	D,0A000H	; куда
BEGIN:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	MOV	A,D
	CPI	0D8H
	JC	BEGIN		; цикл до адреса D800h
	XRA	A		; очистка памяти (КД) далее
FIL0:	STAX	D
	INR	E
	JNZ	FIL0		; цикл 1
	INR	D
	MOV	A,D
	CPI	0E0H
	JC	FIL0		; цикл до адреса E000h
#else
	LXI	D,COM		; куда
	CALL	unlzsa1		; распаковка
#endif
	CALL	STDISP		; (0CA00H)
	LXI	H,0E4F2h	; ='РД'
	SHLD	11
	LXI	H,30F3H		; ='С' 3.0
	SHLD	13
	LXI	SP,0
	EI
	LXI	D,STR0
	MVI	C,9
	CALL	5
	IN	1
	ANI	40H
	JNZ	EXIT	; >>> переход, если не нажата УС
	LXI	D,STR2	; "Форматирование..."
	MVI	C,9
	CALL	5
	LXI	H,80H
FORM10:	MVI	M,0E5H
	INR	L
	JNZ	FORM10
	LXI	B,80H
	CALL	SETDMA
	MVI	C,2
	CALL	SELDSK
	LXI	D,0EB08h ; начальное значение, D=235 (трек), E=8 (сектор)
FORM11:	PUSH	D
	MOV	C,D
	CALL	SETTRK
	POP	D
FORM12:	PUSH	D
	MOV	C,E
	CALL	SETSEC
	CALL	WRITE
	POP	D
	DCR	E
	JNZ	FORM12	; цикл по секторам 8..1
	MVI	E,8
	DCR	D
	MOV	A,D
	CPI	180
	JC	FORM11	; < 180
	INR	A	;CPI	0FFh
	JZ	FORMOK	; >>>
	CPI	197
	JNC	FORM11	; >= 196
	MVI	D,179	;SUI	10h
			;MOV	D,A
	JMP	FORM11	; цикл с пропуском треков 180-195
;
FORMOK:	LXI	D,STR1	; "КД отформатирован"
	MVI	C,9
	CALL	5
	LXI	H,FILE0+1
	MVI	M,'O'
	INX	H
	MVI	M,'S'
	INX	H
	MVI	M,' '	; переименовываем в OS.COM
EXIT:	MVI	E,2	;
	MVI	C,14	; Выбор диска 2 (КД)
	CALL	5
	LXI	B,0D80H	; Проверка текущего диска на статус Read only,если он установлен то "сброс".
	CALL	5
	MVI	A,3	; исправление КС секторов под RDS.SYS
	STA	3FH
	LXI	D,0C308h ; начальное значение, D=195 (трек), E=8 (сектор)
REP11:	PUSH	D
	MOV	C,D
	CALL	SETTRK
	POP	D
REP12:	PUSH	D
	MOV	C,E
	CALL	SETSEC
	CALL	READ	; чтение с исправлением КС
	POP	D
	DCR	E
	JNZ	REP12	; цикл по секторам 8..1
	MVI	E,8
	DCR	D
	MVI	A,179
	CMP	D
	JC	REP11	; цикл по трекам, >= 180
	XRA	A
	STA	3FH
	MVI	A,2	; сколько секторов (по 128 байт)
	STA	WSECT
	LXI	H,OS	; откуда
	SHLD	DMA
	LXI	H,FILE0
	CALL	SAVE	; сохр.файла OS.COM / RDS.COM
	MVI	A,23	; сколько секторов (по 128 байт)
	STA	WSECT

	LXI	H,COM	; откуда

	SHLD	DMA
	LXI	H,FILE1
	CALL	SAVE	; сохр.файла COMMAND.SYS
	LXI	H,80H	; откуда
	SHLD	DMA
SRDS:	MVI	A,0	; сколько секторов (по 128 байт)
	STA	WSECT
	LXI	H,FILE2
	CALL	SAVE	; создание файла RDS.SYS
; исправление записи файла
	LXI	B,80H
	CALL	SETDMA
;	MVI	C,2	; КД
;	CALL	SELDSK
	MVI	C,0	; трек 0
	CALL	SETTRK
	CALL	FIND	; поиск записи (с исправлением)
	JNZ	SKP1	; найдено -- пропускаем трек 1
	MVI	C,1	; трек 1
	CALL	SETTRK
	CALL	FIND	; поиск записи (с исправлением)
	JZ	SRDS	; не нашли????
SKP1:	CALL	WRITE	; сохраняем каталог
;
	CALL	TDSK	; тест наличия КД11
	STA	DISKS	; сохраняем количество устройств
	CPI	3
	JZ	SKP2
	MVI  A, 20h	; =" "
	STA	DMARK	; затираем букву "D"
SKP2:	CALL	INIHDD	;<<<
	MVI	C,13	; сброс дисков
	CALL	5
	MVI	E,10	; <ПС>
	MVI	C,2
	CALL	5
	LXI	D,STRA	; надпись РДС в прямоугольнике
	MVI	C,9
	CALL	5
	JMP	0	; >>>>>>>>>>>>>>>>> запуск системы
;
INIHDD:	LXI	D,STRHDD	;"Инициализация HDD...$"
	MVI	C,9
	CALL	5
	LXI	B,80H
	CALL	SETDMA
	MVI	A,2
	STA	3FH
	LXI	B,04F1h	; B=4 (счётчик), C=0F0h+1 (НЖМД, сектор 1 CP/M) или C=0
INIH10:	PUSH	B
	CALL	SELDSK
	MVI	C,0	; или 2
	CALL	SETSEC
	LXI	B,0	; или 00FFh
	CALL	SETTRK
	CALL	READ
	ANA	A
	POP	B
	JZ	INIH12	; >>> всё ок!
	DCR	B
	JNZ	INIH10	; цикл, 4 попытки
	XRA	A
	STA	3FH
	LXI	D,STRHDE	; "Ошибка"
	MVI	C,9
	CALL	5
	LXI	D,0
	LXI	B,0F80H	; SETHDD -- Установка номера 0 дискеты HDD
	JMP	5
;
INIH12:	DI		; занесение характеристик НЖМД в БСВВ
	XRA	A
	STA	3FH
	MVI	A,20H	; 0010 0000b -- банк 3 как ОЗУ A000-DFFFh
	OUT	10H
	LHLD	0A000H	; HL = CBIOS (0AE00h)
	LXI	D,41H
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG		; HL = HDDAT+1 (BIOS)
	SHLD	APAR2+1
	LHLD	84H	; -- количество дискет
	MOV	A,H
	CMA
	MOV	H,A
	MOV	A,L
	CMA
	MOV	L,A
;	INX	H
APAR2:	SHLD	0	; => HDDAT+1 (BIOS) = (FFFFh - (число дискет))
	MVI	A,23H	; 0010 0011b -- банк 0 как ОЗУ A000-DFFFh
	OUT	10H
	EI
	RET
;
DMA:	.DW	0
WSECT:	.DB	0
FILE0:	.DB 0,"RDS     COM"	; или OS.COM после форматирования КД
FILE1:	.DB 0,"COMMAND SYS"
FILE2:	.DB 0,"RDS     SYS"
;
SAVE:	LXI	D,5CH
	PUSH	D
	MVI	B,12
SAVE10:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	SAVE10
	XCHG
SAVE12:	MVI	M,0
	INR	L
	JNZ	SAVE12
	POP	D
	PUSH	D	;LXI	D,5CH
	MVI	C,19
	CALL	5	; удалить файл (если был)
	POP	D	;LXI	D,5CH
	MVI	C,22
	CALL	5	; создать файл
	LHLD	DMA
	LDA	WSECT
	ANA	A
	JZ	SAVE21	; пропускаем запись, если размер =0
	MOV	B,A
	XCHG
SAVE20:	PUSH	B
	PUSH	D
	MVI	C,1AH	; установить DMA
	CALL	5
	LXI	D,5CH
	MVI	C,21
	CALL	5	; писать в файл
	POP	D
	POP	B
	LXI	H,128
	DAD	D
	XCHG
	DCR	B
	JNZ	SAVE20
SAVE21:	LXI	D,5CH
	MVI	C,16
	JMP	5	; закрыть файл
;
FIND:	MVI	A,1
F_LOOP:	STA	WSECT
	MOV	C,A	; сектор 1
	CALL	SETSEC
	CALL	READ
	LHLD	DMA	; начало
	LXI	D,0020h	; шаг
FL_1:	MOV	A,M
	CPI	0E5h
	CNZ	L_NAME	; проверка найденой записи (с исправлением)
	RNZ		; >> нашли, что надо
	DAD	D
	XRA	A
	CMP	H	; адрес меньше 100h
	JZ	FL_1	; цикл по считанному
	LDA	WSECT
	INR	A
	CPI	9
	JNZ	F_LOOP	; цикл по секторам
	RET		; не нашли...
;
L_NAME:;PUSH	B
	PUSH	H
	PUSH	D
	LXI	D,FILE2
	XCHG
NLOOP:	INX	H
	INX	D
	LDAX	D	; читаем символ из буфера
	ANA	A	; =0?
	JZ	COMP	; имя закончилось, всё совпало
	CMP	M	; сравниваем с образцом
	JZ	NLOOP	; символ совпал, продолжаем в цикле
	XRA	A	; не совпало, уст.Z=0
NEND:	POP	D
	POP	H
;	POP	B
	RET
;
COMP:	XCHG
	INX	H
	INX	H
	INX	H
	MVI	M,07Fh	; число занятых кластеров
	MVI	A,180	; от 
	MVI	C,196	; до
WRN:	INX	H
	MOV	M,A
	INR	A
	CMP	C
	JNZ	WRN	; цикл по записи
	ANA	A	; установить Z<>0
	JMP	NEND
#ifndef NoPACK
;
;input: 	hl=compressed data start
;		de=uncompressed destination start
unlzsa1:
	mvi b,0
	jmp ReadToken
;
NoLiterals:
	xra m
	push d
	inx h
	mov e,m
	jm LongOffset
ShortOffset:
	mvi d,0FFh
	adi 3
	cpi 15+3
	jnc LongerMatch
CopyMatch:
	mov c,a
CopyMatch_UseC:
	inx h
	xthl
	xchg
	dad d
	mov a,m
	inx h
	stax d
	inx d
	dcx b
	mov a,m
	inx h
	stax d
	inx d
	dcx b
	dcx b
	inr c
BLOCKCOPY1:
	mov a,m
	stax d
	inx h
	inx d
	dcr c
	jnz BLOCKCOPY1
	xra a
	ora b
	jz $+7
	dcr b
	jmp BLOCKCOPY1
	pop h
ReadToken:
	mov a,m
	ani 70h
	jz NoLiterals 
	cpi 70h
	jz MoreLiterals
	rrc
	rrc
	rrc
	rrc
	mov c,a
	mov b,m
	inx h
	mov a,m		; <<<
	stax d
	inx h
	inx d
	dcr c
	jnz $-5		; >>>
	push d
	mov e,m
	mvi a,8Fh
	ana b
	mvi b,0
	jp ShortOffset
LongOffset:
	inx h
	mov d,m
	adi -128+3
	cpi 15+3
	jc CopyMatch
LongerMatch:
	inx h
	add m
	jnc CopyMatch
	mov b,a
	inx h
	mov c,m
	jnz CopyMatch_UseC
	inx h
	mov b,m
	mov a,b
	ora c
	jnz CopyMatch_UseC
	pop d
	ret
;
MoreLiterals:		
	xra m
	push psw
	mvi a,7
	inx h
	add m
	jc ManyLiterals
CopyLiterals:
	mov c,a
CopyLiterals_UseC:
	inx h
	dcx b
	inr c
BLOCKCOPY2:
	mov a,m
	stax d
	inx h
	inx d
	dcr c
	jnz BLOCKCOPY2
	xra a
	ora b
	jz $+7
	dcr b
	jmp BLOCKCOPY1
	pop psw
	push d
	mov e,m
	jp ShortOffset
	jmp LongOffset
ManyLiterals:
	mov b,a
	inx h
	mov c,m
	jnz CopyLiterals_UseC
	inx h
	mov b,m
	jmp CopyLiterals_UseC
#endif
STR0:	.DB 12,27,'/',27,'b'
;	.DB "(c) Резидентная Дисковая Систем"
	.DB "(c) Є┼┌╔─┼╬╘╬┴╤ ф╔╙╦╧╫┴╤ є╔╙╘┼═"
;	.DB "а.              Версия 3.07 "
	.DB "┴.              ў┼╥╙╔╤ 3.07 "
	.DB 10
;	.DB "(c) Вьюнов В.А.   Copyright (c)"
	.DB "(c) ў╪└╬╧╫ ў.с.   Copyright (c)"
	.DB " 1994-1997 by Vitaly Vewnov."
	.DB 10
;	.DB " Марта 24 числа 1997г. от Р.Х."
	.DB " э┴╥╘┴ 24 ▐╔╙╠┴ 1997╟. ╧╘ Є.ш."
	.DB 10,27,'a'
;	.DB "Модификация 31.03.2022г., Impro"
	.DB "э╧─╔╞╔╦┴├╔╤ 31.03.2022╟., Impro"
	.DB "ver",10,'$'
STR1:;	.DB 10,"Квази-диск отформатирован.$"
	.DB 10,"ы╫┴┌╔-─╔╙╦ ╧╘╞╧╥═┴╘╔╥╧╫┴╬.$"
STR2:;	.DB 10,"Форматирование диска C:.$"
	.DB 10,"ц╧╥═┴╘╔╥╧╫┴╬╔┼ ─╔╙╦┴ C:.$"
STRHDD:;.DB 10,"Инициализация HDD...$"
	.DB 10,"щ╬╔├╔┴╠╔┌┴├╔╤ HDD...$"
STRHDE:;.DB 10,"Ошибка !$"
	.DB 10,"я█╔┬╦┴ !$"
OS:	.END
