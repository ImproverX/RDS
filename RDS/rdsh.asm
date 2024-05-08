;(перед компилированием преобразовать в KOI-8R)
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
DISKS:	.EQU	0AE46H		; количество дисковых устройств -1
STRA:	.EQU	0BF66H+1	; ссылка на надпись загрузчика
DMARK:	.EQU	STRA+62h
STR0:	.EQU	0BEA4h		; ссылка на первую надпись РДС
LCOM:	.EQU	0B80h		; размер файла ccph.obj
LLDR:	.EQU	0080h		; размер файла loaderkd.obj
#ifdef NoPACK
LDR:	.EQU	OS
COM:	.EQU	OS+LLDR
RDS:	.EQU	COM+LCOM	; << начало блока + размер ccph.obj и loaderkd.obj
#else
RDS:	.EQU	OS		; начало архива
COM:	.EQU	0A000H-LCOM
LDR:	.EQU	COM-LLDR	; туда будут распакованы данные
#endif
TDSK:	.EQU	LDR+5Eh		; ПП проверки наличия КД11 (loaderkd)
STAUB:	.EQU	LDR+2Eh		; запуск системы из лоадера
L_BUFT:	.EQU	0D7F3h		; "AUTOEXEC..." для БУФ (в virt)
M_E000:	.EQU	0E000H		; БУФ для запуска AUTOEXEC.BAT (31 байт)
;
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
	LXI	D,LDR		; куда
	CALL	unlzsa1		; распаковка
#endif
	CALL	STDISP		; (0CA00H)
;	LXI	H,0E4F2h	; ='РД'		>> перенесено в лоадер
;	SHLD	11
;	LXI	H,30F3H		; ='С' 3.0
;	SHLD	13
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
	LXI	D,0202h	; D=02 -- диск C:, E=02 -- форматирование
	LXI	B,0080H	; вызов функции "Тест квазидиска"
	CALL	5	; форматирование КД
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
	CALL	SETTRK	; для КД старший байт (B) не важен
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
	MVI	A,1	; сколько секторов (по 128 байт)
	STA	WSECT
	LXI	H,LDR	; откуда
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
	CALL	SETTRK	; для КД старший байт (B) не важен
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
;	CPI	3
	JZ	SKP2
	MVI  A, 20h	; =" "
	STA	DMARK	; затираем букву "D"
SKP2:	LXI  H, L_BUFT	; ссылка на данные для БУФ (AUTOEXEC.BAT)
	LXI  D, M_E000	; куда копировать (БУФ)
	PUSH D		; сохр.в стек
BUFLP:	MOV  A, M
	STAX D
	INX  H
	INX  D
	ANA  A		; признаки по А
	JNZ     BUFLP	; цикл, пока А не обнулится
	CALL	INIHDD	;<<<
	MVI	E,10	; <ПС>
	MVI	C,2
	CALL	5
	LXI	D,STRA	; надпись РДС в прямоугольнике
	JMP	STAUB	; >>>>>>>>>>>>>>>>> запуск системы (через loaderkd)
;	JMP	0
;
INIHDD:	LXI	D,STRHDD	;"Инициализация HDD...$"
	MVI	C,9
	CALL	5
	LXI	B,80H
	CALL	SETDMA
	MVI	A,2
	STA	3FH
	LXI	B,04F1h	; B=4 (счётчик), C=0F0h+1 (НЖМД, +сектор 1 CP/M) или C=0
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
	STA	04h	; номер диска 0 (A:) для SETHDD
	LXI	D,STRHDE	; "Ошибка"
	MVI	C,9
	CALL	5
	LXI	D,0
	LXI	B,0F80H	; SETHDD -- Установка номера 0 дискеты HDD
	CALL	5
	MVI	A,2
	STA	04h	; восстанавливаем номер диска
	RET
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
	jmp BLOCKCOPY2
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
;
STR2:	.DB 10,"Форматирование диска C:.$"
STRHDD:	.DB 10,"Инициализация HDD...$"
STRHDE:	.DB " не найден.$"
DMA:	.DW	0
WSECT:	.DB	0
FILE0:	.DB 0,"RDS     COM"	; или OS.COM после форматирования КД
FILE1:	.DB 0,"COMMAND SYS"
FILE2:	.DB 0,"RDS     SYS"
;
OS:	.END
