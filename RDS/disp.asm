	.ORG	0C000H
#include "font.inc"
;
	.ORG	0CA00H
	JMP	START
	JMP	KEY
	JMP	INBYT
	JMP	PRINTC
	JMP	OUTBYT
	JMP	LST
	JMP	TSKEY
	JMP	HEXOUT
	JMP	PRINT
	JMP	INKEY
	.DW	XX	; +1Eh
DISKI:	.EQU	0AE33H
VIRADR:	.EQU	0FB00h	; == адрес начала virt
VIRSRC:	.EQU	0D380H	; == адрес хранения virt
VTAB:	.EQU	VIRADR+39H
SYMBUF:	.EQU	VTAB+17	; ссылка на DRTAB в virt
VVECT:	.DW VTAB,VTAB+3,VTAB+6,VTAB+9	; DRAW,SCROLL,CLS,CURS
;FONT:	.EQU	0C000H
XX:	.DB	0	; XX+00h (CA28h)
CURX:	.DB	0	; +01h
YY:	.DB	-1	; +02h
SETCOL:	.DB	80H	; +03h
COLOR:	.DB 0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1	; +04h
FONTP:	.DW	TFONT	; +14h
	.DW	TABK	; +16h
BORD:	.DB	10H	; +18h
SCROLL:	.DB	-1	; +19h
KEYS:	.DB	-1	; +1Ah
RUSLT:	.DB	-1	; +1Bh	; больше не используется, оставлено для совместимости
MODKEY:	.DB	1,1	; +1Ch	; РУС, СС
PORT1:	.DB	6	; +1Eh	; A6h=РУС, 06h=ЛАТ, 46h=СС+ЛАТ, E6h=СС+РУС
KEYCNT:	.DB	0	; +1Fh
KEYINC:	.DB	0	; +20h
KEYPNT:	.DB	0	; +21h
KEYBUF:	.DS	8	; +22h <=
CONSTR:	.DB	4BH	; +2Ah
CONSTW:	.DB	32H	; +2Bh
ONBEEP:	.DB	0	; +2Ch
TIMER:	.DB	12	; +2Dh
POVTK:	.DB	0	; +2Eh
POVTK2:	.DB	0	; +2Fh
CNTCUR:	.DB	0	; +30h
CURFR:	.DB	0	; +31h
ESCCNT:	.DB	0	; +32h
ESCP:	.DB	0	; +33h
MASC:	.DB	0	; +34h
MIGCN:	.DB	8	; +35h
START:	DI
	MVI	A,81H
	OUT	4
	LXI	H,VIRADR+03H	; 0FB03h
	SHLD	1
	LXI	H,VIRADR	; 0FB00h
	SHLD	6
	SHLD	9
	LXI	H,VIRSRC	; 0D400h
	LXI	D,VIRADR	; 0FB00h
ST10:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	XRA	A	;MOV	A,D
	ORA	D	;ANA	A
	JNZ	ST10	; копирование virt (D400-D8FF)->(FB00-FFFF)
	LHLD	SYMBUF	; DRTAB в virt
	LXI	D,DRTAB
	MVI	B,32	;<= было 48
	CALL	COPY	; копирование 32 байт из adr(HL) в adr(DE)
;ST11:	MOV	A,M	; заменить на call copy ????
;	STAX	D
;	INX	H
;	INX	D
;	DCR	B
;	JNZ	ST11	; цикл
	LXI	H,PRNT12
	SHLD	VTAB+13
	LHLD	VTAB+1
	INX	H
	INX	H
	INX	H
	SHLD	PRNT11+1
	MVI	A,0DAH	; = JC
	STA	PRNT13
	LXI	H,DYSPLY
	SHLD	VTAB-2
	LXI	H,VTAB-6
	SHLD	39H
	MVI	A,80H
	STA	SETCOL	; установка палитры 80h раз
	MVI	A,0C3H	; = JMP
	STA	38H
	STA	0
	STA	5
	STA	8
	LHLD	VTAB+15	; ссылка на ZAGA в virt
	PUSH	H
	XCHG
	LHLD	DISKI	; ссылка на ссылку на ZAGA в b7h
	PUSH	H
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A	; HL = ссылка на ZAGA в b7h
;	PUSH	H
;	PUSH	D
	MVI	C,4	; счётчик дисков
ST1A:	PUSH	B
	MVI	B,8
	CALL	COPY	; копирование 8 байт из adr(HL) в adr(DE)
	LXI	B,8
	DAD	B
	XCHG
	DAD	B	; пропускаем 8 байт
	XCHG
	POP	B
	DCR	C
	JNZ	ST1A	; цикл копирования параметров ???
;	POP	H
;	LXI	B,93
;	DAD	B
;	XCHG
;	POP	H
;	DAD	B	; HL = DIRB b7h, DE = DIRB virt
;	LXI	B,327
;	CALL	BCOPY	; копирование DIRB,CSVA,CSVB,ALVA,ALVB,ALVC из b7h в virt
	LXI	B,10H
	POP	H	; HL = DISKI b7h
	POP	D	; DE = ZAGA virt
	MVI	A,4	; количество дисков
ST12:	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	XCHG
	DAD	B
	XCHG
	DCR	A
	JNZ	ST12	; цикл: меняем таблицу описателей дисков в b7h на virt
	XRA	A
	STA	3
	MVI	A,2	;+++
	STA	4	; номер текущего диска = 2 (C:) (было 0)
	LDA	BORD
	ORI	10H
	STA	BORD
	MVI	A,20H	; 0010 0000b -- банк 3 как ОЗУ A000-DFFFh
	STA	15
	MVI	A,23H	; 0010 0011b -- банк 0 как ОЗУ A000-DFFFh
	STA	3BH
	STA	3CH
	XRA	A
	STA	3EH
	RET
;
;BCOPY:	MOV	A,M
;	STAX	D
;	INX	H
;	INX	D
;	DCX	B
;	MOV	A,B
;	ORA	C
;	JNZ	BCOPY
;	RET
;
COPY:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	COPY
	RET
;
VIRT:	PUSH	H
	PUSH	D
	PUSH	B
	DI
	DCR	A
	RLC
	MOV	E,A
	MVI	D,0
	LXI	H,VVECT
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	SHLD	VIRT15+1
	LXI	H,0
	DAD	SP
	SHLD	VIRT20+1
	POP	B
	POP	D
	POP	H
	LXI	SP,0FF98H
VIRT15:	CALL	0		;<<<<
VIRT20:	LXI	SP,0		;<<<<
	POP	B
	POP	D
	POP	H
	EI
	RET
;
LST:	PUSH	PSW
LST10:	IN	5
	RRC
	JC	LST10
	MOV	A,C
	OUT	7
	MVI	A,8
	OUT	4
	MVI	A,9
	OUT	4
	POP	PSW
	RET
;
PRINT:	MOV	A,M
	ANA	A
	RZ
	PUSH	B
	MOV	C,A
	CALL	PRINTC
	POP	B
	INX	H
	JMP	PRINT
;
HEXOUT:	MOV	B,A
	RRC
	RRC
	RRC
	RRC
	CALL	HEX10
	MOV	A,B
HEX10:	ANI	15
	CPI	10
	JC	$+5
	ADI	7
	ADI	30H
	MOV	C,A
	JMP	PRINTC
;
INBYT:	PUSH	D
	DI
	PUSH	B
	MVI	C,0
	MOV	D,A
	IN	1
	ANI	10H	; МГ
	MOV	E,A
INB10:	IN	1
	ANI	10H	; МГ
	CMP	E
	JZ	INB10
	RLC
	RLC
	RLC
	RLC
	MOV	A,C
	RAL
	MOV	C,A
	CALL	WAITI
	IN	1
	ANI	10H	; МГ
	MOV	E,A
	MOV	A,D
	ANA	A
	JP	INB20
	MOV	A,C
	CPI	0E6H
	JNZ	INB30
	XRA	A
	STA	MASC
	JMP	INB40
;
INB30:	CPI	19H
	JNZ	INB10
	MVI	A,-1
	STA	MASC
INB40:	MVI	D,9
INB20:	DCR	D
	JNZ	INB10
	LDA	MASC
	XRA	C
	POP	B
	POP	D
	RET
;
WAITI:	LDA	CONSTR
WAIT:	DCR	A
	JNZ	WAIT
	RET
;
WAITO:	LDA	CONSTW
	JMP	WAIT
;
OUTBYT:	PUSH	D
	DI
	PUSH	B
	PUSH	PSW
	MOV	D,A
	MVI	C,8
OUTB10:	MOV	A,D
	RLC
	MOV	D,A
	MVI	A,1
	XRA	D
	ANI	1
	OUT	0
	CALL	WAITO
	XRA	A
	XRA	D
	ANI	1
	OUT	0
	CALL	WAITO
	DCR	C
	JNZ	OUTB10
	POP	PSW
	POP	B
	POP	D
	RET
;
PRINTC:	PUSH	H
	PUSH	D
	PUSH	B
	PUSH	PSW
	LDA	3EH
	ANA	A
	JNZ	PRN99T
	LDA	CNTCUR
	ANI	1
	CNZ	CURS
PRNT01:	LXI	H,ESCCNT
	MOV	A,M
	ANA	A
	JZ	PRN01T
	CPI	80H
	JZ	ESCFPR
	CPI	60H
	JZ	ESC210
	CPI	40H
	JZ	ESCCLR	; изменить палитру
	CPI	28H
	JZ	PRC162
	CPI	20H
	JZ	PRNC09
;	JMP	ESC00
ESC00:	CPI	1	; АР2-последовательности (1Bh + ...)
	JNZ	ESC84
	MOV	A,C
	CPI	80H
	JNC	ESC80
	CPI	'a'
	JZ	ESC02	; отключить вывод символов в негативе
	CPI	'b'
	JZ	ESC04	; вывод символов в негативе
	CPI	'6'
	JZ	ESC04	; вывод символов в негативе
	CPI	'7'
	JZ	ESC02	; отключить вывод символов в негативе
	CPI	'Y'
	JZ	ESC06	; перемещение курсора
	CPI	'T'
	JZ	ESC06	; перемещение курсора
	CPI	'E'
	JZ	ESC21	; сброс экрана
	CPI	'J'
	JZ	ESC20	; стирание экрана
	CPI	'H'
	JZ	ESC200	; курсор в лев.верх угол без стирания
	CPI	'K'
	JZ	PRNC16
	CPI	'^'
	JZ	ESC202
	CPI	5CH
	JZ	ESC22	; КОИ-7
	CPI	5BH
	JZ	ESC24	; КОИ-8
	CPI	2FH
	JZ	ESC24	; КОИ-8
	CPI	'P'
	JZ	ESC08	; установка цвета
	CPI	7
	JZ	ESCBP	; звук нажатия клавиш
ESC99:	XRA	A
	STA	ESCCNT
	JMP	PRNT99
;
PRN01T:	MOV	A,C
	CPI	20H
	JNC	PRNT10
	CPI	1BH
	JNZ	PRNTSL
	INR	M
	JMP	PRNT99
;
ESCFPR:	MVI	M,0
	JMP	PRNT10
;
ESCBP:	LXI	H,ONBEEP	; звук нажатия клавиш
	MOV	A,M
	XRI	1
	MOV	M,A
	JMP	ESC99
;
ESC06:	INR	M	; перемещение курсора
	JMP	PRNT99
;
ESC08:	MVI	M,40H	; установка цвета
	JMP	PRNT99
;
ESC80:	INR	M
	MOV	A,C
ESC82:	SUI	60H
	MOV	C,A
ESC84:	MOV	A,C
	CPI	80H
	JNC	ESC82
	MOV	A,M
	CPI	3
	JNC	ESC14
	INR	M
	MOV	A,C
	SUI	20H
	JM	ESC10
	CPI	25
	JM	$+5
ESC10:	MVI	A,24
	RLC
	MOV	C,A
	RLC
	RLC
	ADD	C
	MOV	C,A
	LDA	SCROLL
	SUB	C
	STA	YY
	JMP	PRNT99
;
ESC14:	MVI	M,0
	MOV	A,C
	SUI	20H
	JM	ESC16
	CPI	80
	JM	$+5
ESC16:	MVI	A,79
	STA	CURX
	JMP	PRNT99
;
ESC20:	XRA	A	; стирание экрана
	STA	ESCCNT
	JMP	PRNC0C
;
ESC200:	XRA	A	; курсор в лев.верх угол без стирания
	STA	ESCCNT
	JMP	PRNC0B
;
ESC202:	MVI	M,60H
	JMP	PRNT99
;
ESC210:	MOV	A,C
	CPI	'C'
	JZ	ESC04	; вывод символов в негативе
	CPI	'A'
	JZ	ESC04	; вывод символов в негативе
	CPI	'@'
	JZ	ESC02	; отключить вывод символов в негативе
	JMP	ESC99
;
ESC21:	XRA	A	; сброс экрана
	CALL	SETINV
	LXI	H,TFONT
	SHLD	FONTP
	JMP	ESC20
;
ESC22:	LXI	H,TFONT+16	; КОИ-7
	SHLD	FONTP
	JMP	ESC99
;
ESC24:	LXI	H,TFONT	; КОИ-8
	SHLD	FONTP
	JMP	ESC99
;
PRNC0F:	LXI	H,TFONT
	SHLD	FONTP
	JMP	PRNT99
;
PRNC0E:	LXI	H,TFONT+32
	SHLD	FONTP
	JMP	PRNT99
;
ESCCLR:	LXI	H,ESCP	; изменение палитры 
	MOV	A,M
	ANA	A
	JNZ	ESCCL0
	INR	M
	LXI	H,COLOR
	LXI	D,7
	MOV	M,C
	INX	H
	MOV	M,C
	DAD	D
	MOV	M,C
	INX	H
	MOV	M,C
	JMP	PRNT99
;
ESCCL0:	MVI	M,0
	LXI	H,COLOR+2
	MVI	D,2
ESCCL1:	MVI	E,6
ESCCL2:	MOV	M,C
	INX	H
	DCR	E
	JNZ	ESCCL2
	INX	H
	INX	H
	DCR	D
	JNZ	ESCCL1
	MVI	A,80H
	STA	SETCOL
	JMP	ESC99
;
GETXX:	LDA	CURX
	MOV	D,A
	ADD	A
	ADD	D
	ADI	8
	STA	XX
	RET
;
ESC02:	XRA	A	; = NOP	; отключить вывод символов в негативе
	CALL	SETINV
	JMP	ESC99
;
ESC04:	MVI	A,2FH	; = CMA	; вывод символов в негативе
	CALL	SETINV
	JMP	ESC99
;
SETINV:	LXI	H,INVTAB
	MVI	B,8
SETI10:	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	STAX	D
	DCR	B
	JNZ	SETI10
	RET
;
PRNT10:	MOV	A,C
	RLC
	RLC
	RLC
	LXI	H,0
	MOV	B,H
	DAD	SP
	SHLD	PRNT12+1
	ANI	7
	ADD	A
	LHLD	FONTP
	MOV	E,A
	MOV	D,B
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M
	MOV	A,C
	ANI	1FH
	ADD	A
	MOV	C,A
	ADD	A
	ADD	A
	MOV	L,A
	MOV	H,B
	DAD	B
	DAD	D
	LDA	CURX
	MOV	D,A
	ADD	A
	ADD	D
	ADI	8
	MOV	C,A
	RRC
	RRC
	RRC
	ANI	1FH
	ADI	0C0H
	MOV	D,A
	LDA	YY
	MOV	E,A
	MOV	A,C
	ANI	7
	MOV	C,A
	;B=0
	DI
	SPHL
	LXI	H,DRTAB
	DAD	B
	DAD	B
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
PRNT11:	SHLD	0
	MVI	B,10
	LXI	H,-2000H
	DAD	D
	MVI	A,10H
	DCX	SP
	XCHG
	JMP	VTAB
;
PRNT12:	LXI	SP,0
	EI
PRNC18:	LXI	H,CURX
	INR	M
	MOV	A,M
	CPI	80
PRNT13:	JC	PRNT99
	MVI	M,0
	JMP	PRNC0A
;
PRNC0A:	XRA	A
	STA	CURX
	LXI	H,YY
	MOV	A,M
	SUI	10
	MOV	M,A
	MOV	C,A
	SUI	6
	LXI	H,SCROLL
	CMP	M
	JNZ	PRNT99
	MOV	A,M
	SUI	10
	MOV	M,A
	OUT	3
	MVI	B,8
	MVI	E,0E0H
	MVI	H,0A0H
	MVI	A,2
	CALL	VIRT
;	JMP	PRNT99
;
PRNT99:	LDA	ESCCNT
	CPI	28H
	JZ	PRC160
	CPI	20H
	JNZ	PRN99T
	LDA	CURX
	ANI	7
	JNZ	PRNT01
	XRA	A
	STA	ESCCNT
PRN99T:	POP	PSW
	POP	B
	POP	D
	POP	H
	EI
	RET
;
PRNC01:	MVI	A,80H
	STA	ESCCNT
	JMP	PRNT99
;
PRNC09:	MVI	A,20H
	MOV	C,A
	STA	ESCCNT
	JMP	PRNT10
;
PRNTSL:	CPI	8
	JZ	PRNC08
	CPI	9
	JZ	PRNC09
	CPI	1
	JZ	PRNC01
	CPI	18H
	JZ	PRNC18
	CPI	10
	JZ	PRNC0A
	CPI	13
	JZ	PRNC0D
	CPI	7
	JZ	PRNC07
	CPI	19H
	JZ	PRNC19
	CPI	1AH
	JZ	PRNC1A
	CPI	12
	JZ	PRNC0C
	CPI	1FH
	JZ	PRNC0C
	CPI	14
	JZ	PRNC0E
	CPI	15
	JZ	PRNC0F
	CPI	11
	JZ	PRNC0B
	CPI	16H
	JZ	PRNC16
	JMP	PRNT10
;
PRNC16:	MVI	A,28H
	STA	ESCCNT
	LDA	CURX
	STA	SCURX+1	;>>>
	MVI	A,0C3H	; = JMP
	STA	PRNT13
	MVI	C,20H
	JMP	PRNT10
;
;SCURX:	.DB	0
;
PRC160:	LDA	CURX
	ANI	7
	JNZ	PRNT01
	MVI	A,0DAH	; = JC
	STA	PRNT13
	LDA	YY
	MOV	C,A
	LDA	CURX
	MOV	D,A
	ADD	A
	ADD	D
	ADI	8
	RRC
	RRC
	RRC
	ANI	1FH
	ADI	0A0H
	MOV	H,A
	MOV	L,C
	MVI	E,0C0H
	MVI	B,5
	MVI	A,2
	CALL	VIRT
	MVI	A,20H
	ADD	H
	MOV	H,A
	MVI	E,0E0H
	MVI	A,2
	CALL	VIRT
SCURX:	MVI	A,0	;LDA	SCURX
	STA	CURX
	XRA	A
	STA	ESCCNT
	JMP	PRNT99
;
PRC162:	MVI	C,20H
	JMP	PRNT10
;
PRNC08:	LXI	H,CURX
	DCR	M
	JP	PRNT99
	MVI	M,79
PRNC19:	LXI	H,YY
	LDA	SCROLL
	CMP	M
	JZ	PRC190
	MOV	A,M
	ADI	10
	MOV	M,A
	JMP	PRNT99
;
PRC190:	ADI	16
	MOV	M,A
	JMP	PRNT99
;
PRNC0D:	XRA	A
	STA	CURX
	JMP	PRNT99
;
PRNC1A:	LXI	H,YY
	MOV	A,M
	SUI	10
	MOV	M,A
	LDA	SCROLL
	ADI	6
	CMP	M
	JZ	PRC1A0
	JMP	PRNT99
;
PRC1A0:	SUI	6
	MOV	M,A
	JMP	PRNT99
;
PRNC07:	LXI	H,1002H
PRNC70:	HLT
	DCR	H
	MVI	A,36H
	OUT	8
	MOV	A,L
	OUT	11
	MOV	A,H
	OUT	11
	JNZ	PRNC70
	JMP	PRNT99
;
PRNC0C:	MVI	A,3
	CALL	VIRT
	MVI	A,-1
	STA	YY
	STA	SCROLL
	OUT	3
	XRA	A
	STA	CURX
	JMP	PRNT99
;
PRNC0B:	LDA	SCROLL
	STA	YY
	XRA	A
	STA	CURX
	JMP	PRNT99
;
HBYTE:	RRC
	RRC
	RRC
	ANI	1FH
	ADI	0C0H
	MOV	H,A
	RET
;
PRNPAR:	PUSH	H
	PUSH	D
	LDA	XX
	ANI	7
	RLC
	MOV	E,A
	MVI	D,0
	LXI	H,TMASC
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	POP	D
	POP	H
	RET
;
TFONT:	.DW FONT,FONT+320,FONT+640,FONT+960,FONT+1280,FONT+1600		; КОИ-8
	.DW FONT+1920,FONT+2240
	.DW FONT,FONT+320,FONT+640,FONT+2240,FONT+1280,FONT+1600	; КОИ-7
	.DW FONT+1920,FONT+960
	.DW FONT,FONT+320,FONT+1920,FONT+2240,FONT+1280,FONT+1600
	.DW FONT+640,FONT+960
;
DYSPLY:	PUSH	H
	PUSH	D
	PUSH	B
	PUSH	PSW
	LXI	H,SETCOL
	XRA	A
	CMP	M
	JZ	DYSP01
	DCR	M
	LXI	H,COLOR+15
	MVI	B,15
DYSP10:	MOV	A,B
	OUT	2
	MOV	A,M
	OUT	12
	DCX	H
	OUT	12
	INR	C
	OUT	12
	DCR	C
	OUT	12
	INR	C
	OUT	12
	DCR	C
	OUT	12
	DCR	B
	OUT	12
	JP	DYSP10
DYSP01:	LXI	H,TIMER
	DCR	M
	JNZ	DYSP02
	MVI	M,10
	MVI	A,1
	STA	CURFR
DYSP02:	MVI	A,8AH
	OUT	0
	XRA	A
	OUT	3
	IN	2
	INR	A	; если нет нажатых кнопок, то A = FFh
	JZ	DYSP15	; нет нажатых кнопок
	LXI	B,000FEh; C - маска для клавиатуры, B - номер столбца
	MOV	A,C
DYSP14:	OUT	3
	IN	2
	CPI	-1
	JNZ	DYSP19	; >> найдена нажатая клавиша
	INR	B
	MOV	A,C
	RLC
	MOV	C,A
	JC	DYSP14	; цикл чтения матрицы клавиатуры
	XRA	A
DYSP15:	MOV	E,A	; E=00h -- нет нажатых клавиш или [код клавиши +1]
	IN	1	; !!! (1) !!!
	MOV	D,A	; результат в D
	LXI	H,MODKEY
	LXI	B,080A0h; B=80h (выделяем РУС), C=A0h (для PORT1)
	CALL	DYSP12	; >>
	INX	H	; MODKEY+1
	LXI	B,02040h; B=20h (выделяем СС), C=40h (для PORT1)
	CALL	DYSP12	; >>
	CALL	DYSP89	; индикатор РУС/ЛАТ и восст.режима ВВ55А
	DCR	E	; E = код клавиши
	JP	DYSP21	; >> S=0, если код < 80h (были нажатые клавиши)
	XRA	A
	STA	POVTK
	CMA
	STA	KEYS
DYSP99:	POP	PSW
	POP	B
	POP	D
	POP	H
	RET
;
DYSP12:	MOV	A,D
	ANA	B	; выделяем РУС/CC
	JNZ	DYSP13	; >> не РУС (или СС)
	ORA	M
	MVI	M,0
	RZ		; >> MODKEY было = 0 и нажата РУС (или СС)
	MOV	A,E
	ANA	A
	RNZ		; >> есть нажатые кнопки
	MVI	M,2
	RET
;
DYSP13:	DCR	M
	MVI	M,1
	RZ		; >> MODKEY было = 1
	RM		; >> MODKEY было = 0,81h..FFh
	LDA	PORT1	;    MODKEY было = 2..80h
	XRA	C	; инвертируем нужные биты
	STA	PORT1
	RET
;
DYSP19:	MVI	C,0	; вычисление кода клавиши
DYSP20:	INR	C
	RAR
	JC	DYSP20
	MOV	A,B
	ADD	A
	ADD	A
	ADD	A	; столбец * 8
	ADD	C	; + строка
	JMP	DYSP15	; A= код клавиши +1
;
DYSP21:	LXI	H,DYSP30
	PUSH	H
	IN	1	; <- проверка УС и СС при нажатии клавиш
	ANI	60H	; выделяем УС и СС
	MOV	B,A
	MOV	A,E
	CPI	3FH
	MVI	A,20H
	RZ
	MOV	A,E
	CPI	16
	JNC	DYSP22
	CALL	PERKEY
	MVI	D,0
	DAD	D
	MOV	A,M
	RET
;
DYSP22:	CPI	20H
	JNC	DYSP24
	CPI	1CH
	MOV	A,B
	JNC	DYSP23
	ANI	20H
	MOV	A,E
	JZ	DYS220
DYS222:	ADI	10H
DYS220:	ADI	10H
	RET
;
DYSP23:	ANI	20H
	MOV	A,E
	JNZ	DYS220
	JMP	DYS222
;
DYSP24:	MOV	A,B
	ANI	40H
	JNZ	DYSP25
	MOV	A,E
	ANI	1FH
	RET
;
DYSP25:	MOV	A,B
	ANI	20H
	MOV	B,A
	LDA	PORT1
	ANI	40H	; СС
	ORA	B
	MOV	A,E
	JPO	DYSP26
	ADI	20H
DYSP26:	ADI	20H
	RET
;
DYSP30:	LXI	H,DYSP99
	PUSH	H
	MOV	B,A
	LDA	KEYS
	CPI	-1
	JZ	DYSP31
	CMP	B
	RNZ
	LXI	H,POVTK
	MOV	A,M
	CPI	32H
	JZ	DYSP32
DYSP33:	INR	M
	RET
;
DYSP32:	LXI	H,POVTK2
	MOV	A,M
	CPI	3
	JNZ	DYSP33
	MVI	M,0
DYSP31:	MOV	A,B
	STA	KEYS
	CPI	0B2H
	JC	DYSP34
	CPI	0B6H
	JNC	DYSP34
	SUI	0B2H
	ADD	A
	ADD	A
	MOV	D,A
	ADD	D
	ADD	D
	MOV	E,A
	MVI	D,0
	LXI	H,TABGR
	DAD	D
	MVI	B,12
	LXI	D,TABK+4
DYSP42:	MOV	A,M
	STAX	D
	INX	D
	INX	H
	DCR	B
	JNZ	DYSP42
	RET
;
BEEP:	MVI	D,32
	XRA	A
BEEP10:	MVI	E,16
BEEP12:	OUT	0
	DCR	E
	JNZ	BEEP12
	XRI	1
	DCR	D
	JNZ	BEEP10
	RET
;
DYSP34:	CPI	40H
	JC	DYSP35
	INR	A
	JM	DYSP35
	LDA	PORT1
	ANI	0A0H	; РУС
	XRA	B
	MOV	B,A
	IN	1	; <- проверка РУС при нажатии клавиш
	RLC		; РУС в признак С
	JC	DYSP35
	MOV	A,B
	XRI	0A0H
	MOV	B,A
DYSP35:	LXI	H,KEYCNT
	LDA	ONBEEP
	ANA	A
	CNZ	BEEP
	MOV	A,M
	CPI	8
	RNC
	INR	M
	LDA	KEYINC
	MOV	E,A
	MVI	D,0
	LXI	H,KEYBUF
	DAD	D
	INR	A
	ANI	7
	STA	KEYINC
	MOV	M,B
	RET
;
DYSP89:	MVI	A,88H
	OUT	0
	LDA	SCROLL
	OUT	3
	LDA	BORD
	OUT	2
	LDA	PORT1	; !!!
PORT1O:	CPI	0	; <- значение меняется
DYSP8A:	JZ	MIG0	; >>> (адрес меняется)
	STA	PORT1O+1; ->
	RLC
	RLC		; Х001 10[РУС][СС]
	ANI	3	; 0000 00[РУС][СС]
	ADD	A	; *2
	LXI	H,MIGT
	MOV	C,A
	MVI	B,0
	DAD	B
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	SHLD	DYSP8A+1; -> меняем адрес ПП
	PCHL
;
MIG1:	LXI	H,MIGCN ; мигалка ЛАТ+СС
	DCR	M
	JNZ	MIG0	; >>
	MVI	M,16
MIG2:	MVI	A,8	; включение РУС
	OUT	1
	RET
;
MIG3:	LXI	H,MIGCN ; мигалка РУС+СС
	DCR	M
	JNZ	MIG2	; >>
	MVI	M,4
MIG0:	XRA	A	; выключение РУС
	OUT	1
	RET
;
MIGT:	.DW	MIG0,MIG1,MIG2,MIG3
;
PERKEY:	LXI	H,TABK
	PUSH	B
	MOV	A,B
	RRC
	MOV	C,A
	MVI	B,0
	DAD	B
	POP	B
	RET
;
TSKEY:	LDA	3EH
	ANA	A
	JNZ	TSK10
	LDA	CURFR
	ANA	A
	CNZ	CURS
TSK10:	LDA	KEYCNT
	ANA	A
	RZ
	MVI	A,-1
	RET
;
KEY:	CALL	TSKEY
	JZ	KEY
	CALL	INKEY
	RET
;
CURS:	PUSH	H
	PUSH	D
	PUSH	B
	PUSH	PSW
	LXI	H,CNTCUR
	INR	M
	XRA	A
	STA	CURFR
	LDA	YY
	SUI	9
	MOV	L,A
	CALL	GETXX
	LDA	XX
	CALL	HBYTE
	MOV	A,H
	SUI	20H
	MOV	H,A
	CALL	PRNPAR
	MVI	D,-1
	MVI	A,4
	CALL	VIRT
	POP	PSW
	POP	B
	POP	D
	POP	H
	EI
	RET
;
INKEY:	;DA	3EH
	;NA	A
	;VI	A,'Y'
	;NZ
	PUSH	H
	PUSH	B
	LXI	H,KEYCNT
	MOV	A,M
	ANA	A
	MVI	A,-1
	JZ	INKY99
	DCR	M
	LDA	KEYPNT
	LXI	H,KEYBUF
	MOV	C,A
	MVI	B,0
	DAD	B
	INR	A
	ANI	7
	STA	KEYPNT
	MOV	A,M
INKY99:	POP	B
	POP	H
	RET
;
TABK:	.DB 0B2H,0B3H,0B4H,0B5H,94H,91H,94H,83H
	.DB 90H,0A9H,84H,0AAH,92H,8FH,93H,95H
	.DB 0BAH,0BBH,0BCH,0DFH,0ACH,0ADH,80H,0AEH
	.DB 0AFH,81H,82H,0BDH,0B0H,0B1H,0ABH,0BEH
	.DB 9,10,13,5FH,8,19H,18H,1AH,11,12,27,16,17,18,19,20
	.DB 9,10,13,7FH,8,19H,18H,1AH,11,12,27,0,1,2,3,4
TABGR:	.DB 94H,91H,94H,83H,90H,0A9H,84H,0AAH,92H,8FH,93H,95H
	.DB 9DH,9AH,9DH,8AH,98H,8CH,89H,99H,9BH,8BH,9CH,9EH
	.DB 9DH,9FH,9DH,83H,0A4H,8EH,85H,0A5H,0A1H,88H,96H,0A8H
	.DB 94H,0A0H,94H,8AH,0A3H,8DH,86H,0A6H,0A2H,87H,97H,0A7H
TMASC:	.DB 0E0H,0,70H,0,38H,0,1CH,0
	.DB 0EH,0,7,0,3,080H,1,0C0H
DRTAB:	.DS	16
INVTAB:	.DS	15	;<-16
;
	.org 0D2FFh	; выравнивание размера
	.db 0
	.END
