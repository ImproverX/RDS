;(перед компилированием преобразовать в KOI-8R)
	.ORG	0EF80H
	.DB	0h,0F0h,0h,0F0h,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah
	.DB	1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah
	.DB	1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah
	.DB	1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah
	.DB	1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah
	.DB	1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah
	.DB	1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah
	.DB	1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah,1Ah
	.ORG	0F000H
Y0004:	.EQU	00004H
X0005:	.EQU	00005H
Y0080:	.EQU	00080H
X0100:	.EQU	00100H
DF200:	JMP	BEGIN
	JMP	AF558
STRBF:	.DB	07FH
LNBUF:	.DB	000H
COMSTR:	.DB "              "
	.DB "COPYRIGHT (C) 1979, DIGITAL RES"
	.DB "EARCH  "
	.DB "Переработано Вьюновым В.А. в 19"
	.DB "96 году. "
	.DB "Copyright (c) 1996 by Vewnov Vi"
	.DB "taly."
BUFDEC:	.DW	0
BFDEC2:	.DW	0
;
PRINTA:	MOV     E,A
	MVI	C,002H
	JMP	X0005
;
SPACE:	MVI     A,020H
;	JMP     PRINT2
PRINT2:	PUSH    B
	CALL    PRINTA
	POP	B
	RET
;
CRLF:	MVI     A,00DH
	PUSH    B
	CALL    PRINTA
	MVI	A,00AH
	CALL    PRINTA
	POP	B
	RET
;
PRINT:	PUSH    B
	CALL    CRLF
	POP	H
PRINTH:	MOV	A,M
	ORA	A
	RZ
	INX	H
	PUSH	H
	CALL    PRINTA
	POP	H
	JMP	PRINTH
;
SELDSK:	MOV	E,A
	MVI	C,00EH
	JMP	X0005
;
BDOS:	CALL	X0005
	STA	DF9EE
	INR	A
	RET
;
OPENF:	MVI	C,00FH
	JMP	BDOS
;
OPEN2:	XRA	A
	STA	DF9ED
	LXI	D,CBUF
	JMP	OPENF
;
CLOSE:	MVI	C,010H
	JMP	BDOS
;
FSEAR:	MVI	C,011H
	JMP	BDOS
;
NSEAR:	MVI	C,012H
	JMP	BDOS
;
SEAR2:	LXI	D,CBUF
	JMP	FSEAR
;
ERASE:	MVI	C,013H
	JMP	X0005
;
BDOS2:	CALL	X0005
	ORA	A
	RET
;
SREAD:	MVI	C,014H
	JMP	BDOS2
;
READF:	LXI	D,CBUF
	JMP	SREAD
;
SWRIT:	MVI	C,015H
	JMP	BDOS2
;
MAKEF:	MVI	C,016H
	JMP	BDOS
;
RENAM:	MVI	C,017H
	JMP	X0005
;
GETUS:	MVI	E,0FFH
SETUS:	MVI	C,020H
	JMP	X0005
;
AF31A:	CALL	GETUS
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LXI	H,TDISK
	ORA	M
	STA	Y0004
	RET
;
AF329:	LDA	TDISK
	STA	Y0004
	RET
;
AF330:	CPI	061H
	RC		; >> A < 61h  ( a )
	CPI	07BH
	RNC		; >> A >= 7Bh ( { )
	ANI	05FH	; 61h->41h ... 7Ah->5Ah (A...Z)
	RET
;
GTSTR:	CALL	AF31A
	LXI	B,880H	; Статус BAT-файла
	CALL	X0005
	ANA	A
	JNZ	BATF	; >> обработка BAT-файла
	MVI	C,10
	LXI	D,STRBF
	CALL	X0005	; ввод с клавиатуры в буфер
GTST10:	CALL	AF329	; TDISK
AF3A7:	LXI	H,LNBUF
	MOV	B,M
AF3AB:	INX	H
	MOV	A,B
	ORA	A
	JZ	AF3BA	; >>
	MOV	A,M
	CALL	AF330	; преобразование a..z в A..Z
	MOV	M,A
	DCR	B
	JMP	AF3AB
AF3BA:	MOV	M,A
	LXI	H,COMSTR
	SHLD	BUFDEC
	RET
;
BATF:	LXI	H,LNBUF
	MVI	M,0
	MVI	E,0
	INX	H
BATF10:	CALL	BATF20
	JC	BATF14
	JZ	BATF12
	MOV	A,E
	CPI	127
	JC	BATF10
BATF12:	MOV	A,E
	STA	LNBUF
	MVI	M,0
	LXI	H,COMSTR
	CALL	PRINTH
	JMP	GTST10
BATF14:	MVI	A,19H
	CALL	PRINTA
	JMP	0
BATF20:	PUSH	H
	PUSH	D
	LXI	B,680H
	CALL	X0005
	CPI	1AH
	STC
	JZ	BATF2A
	CPI	13
	JZ	BATF2A
	CPI	'%'
	JNZ	BATF29
	LXI	B,680H
	CALL	X0005
	SUI	30H
	CMC
	JNC	BATF29
	CPI	3AH
	JNC	BATF29
	POP	D
	POP	H
	PUSH	H
	PUSH	D
	STA	DBUF
	SHLD	DBUF+1
	LXI	D,DBUF
	LXI	B,780H
	CALL	X0005
	INR	A
	STC
	JZ	BATF2A
	POP	B
	POP	D
	MOV	A,L
	SUB	E
	ADD	C
	MOV	E,A
	JMP	BATF20
BATF29:	POP	D
	POP	H
	MOV	M,A
	INX	H
	INR	E
	ORI	1
	RET
BATF2A:	POP	D
	POP	H
	RET
CONST:	MVI	C,00BH
	CALL	X0005
	ORA	A
	RZ
	MVI	C,001H
	CALL	X0005
	ORA	A
	RET
;
GETDSK:	MVI	C,019H
	JMP	X0005
;
SYSDMA:	LXI	D,00080H
SETDMA:	MVI	C,01AH
	JMP	X0005
;
ERROR:	CALL    CRLF
	LHLD	BFDEC2
AF40F:	MOV	A,M
	CPI	020H
	JZ	AF422
	ORA	A
	JZ	AF422
	PUSH	H
	CALL    PRINTA
	POP	H
	INX	H
	JMP	AF40F
AF422:	MVI	A,03FH
	CALL    PRINTA
	RET
;
BADCOM:	CALL	ERROR
	CALL    CRLF
	JMP	MAIN
;
AF430:	LDAX	D
	ORA	A
	RZ
	CPI	020H
	JC	BADCOM
	RZ
	CPI	03DH
	RZ
	CPI	05FH
	RZ
	CPI	02EH
	RZ
	CPI	03AH
	RZ
	CPI	03BH
	RZ
	CPI	03CH
	RZ
	CPI	03EH
	RZ
	RET
;
AF459:	ADD	L
	MOV	L,A
	RNC
	INR	H
	RET
;
DECOD:	XRA	A
AF460:	LXI	H,CBUF
	CALL	AF459
DECO10:	PUSH	H
	PUSH	H
	XRA	A
	STA	UDISK
	LHLD	BUFDEC
	XCHG
	CALL	OBRS13
	XCHG
	SHLD	BFDEC2
	XCHG
	POP	H
	LDAX	D
	ORA	A
	JZ	AF489
	SBI	040H
	MOV	B,A
	INX	D
	LDAX	D
	CPI	03AH
	JZ	AF490
	DCX	D
AF489:	LDA	TDISK
	MOV	M,A
	JMP	AF496
;
AF490:	MOV	A,B
	STA	UDISK
	MOV	M,B
	INX	D
AF496:	MVI	B,008H
AF498:	CALL	AF430
	JZ	AF4B9
	INX	H
	CPI	02AH
	JNZ	AF4A9
	MVI	M,03FH
	JMP	AF4AB
;
AF4A9:	MOV	M,A
	INX	D
AF4AB:	DCR	B
	JNZ	AF498
AF4AF:	CALL	AF430
	JZ	AF4C0
	INX	D
	JMP	AF4AF
;
AF4B9:	INX	H
	MVI	M,020H
	DCR	B
	JNZ	AF4B9
AF4C0:	MVI	B,003H
	CPI	02EH
	JNZ	AF4E9
	INX	D
AF4C8:	CALL	AF430
	JZ	AF4E9
	INX	H
	CPI	02AH
	JNZ	AF4D9
	MVI	M,03FH
	JMP	AF4DB
;
AF4D9:	MOV	M,A
	INX	D
AF4DB:	DCR	B
	JNZ	AF4C8
AF4DF:	CALL	AF430
	JZ	AF4F0
	INX	D
	JMP	AF4DF
;
AF4E9:	INX	H
	MVI	M,020H
	DCR	B
	JNZ	AF4E9
AF4F0:	MVI	B,003H
AF4F2:	INX	H
	MVI	M,000H
	DCR	B
	JNZ	AF4F2
	XCHG
	SHLD	BUFDEC
	POP	H
	LXI	B,0000BH
AF501:	INX	H
	MOV	A,M
	CPI	03FH
	JNZ	AF509
	INR	B
AF509:	DCR	C
	JNZ	AF501
	MOV	A,B
	ORA	A
	RET
;
TF510:	.DB "DIR ERA TYPESAVEREN USERTEST"
	.DB "RESTHDD "
;
BUILD:	LXI	H,TF510
	MVI	C,0
AF533:	MOV	A,C
	CPI	9
	RNC
	LXI	D,CBUF+1
	MVI	B,004H
AF53C:	LDAX	D
	CMP	M
	JNZ	AF54F
	INX	D
	INX	H
	DCR	B
	JNZ	AF53C
	LDAX	D
	CPI	020H
	JNZ	AF554
	MOV	A,C
	STC
	RET
;
AF54F:	INX	H
	DCR	B
	JNZ	AF54F
AF554:	INR	C
	JMP	AF533
;
AF558:	XRA	A
	STA	LNBUF
BEGIN:	LXI	SP,00000H
	PUSH	B
	MOV	A,C
	RAR
	RAR
	RAR
	RAR
	ANI	00FH
	MOV	E,A
	CALL	SETUS
	POP	B
	MOV	A,C
	ANI	00FH
	STA	TDISK
	CALL	SELDSK
	LDA	LNBUF
	ORA	A
	JNZ	AF598
MAIN:	LXI	SP,00000H
	CALL	CRLF
	LXI	B,480H
	CALL	X0005
	CALL	GETUS
	ANA	A
	JZ	MAIN10
	CPI	10
	JC	MAIN02
	SUI	10
	PUSH	PSW
	MVI	A,31H
	CALL	PRINTA
	POP	PSW
MAIN02:	ADI	30H
	CALL	PRINTA
	MVI	A,27H
	CALL	PRINTA
MAIN10:	CALL	GETDSK
	ADI	041H
	CALL    PRINTA
	MVI	A,03EH
	CALL    PRINTA
	CALL	GTSTR	; >>
AF598:	LXI	D,00080H
	CALL	SETDMA
	CALL	GETDSK
	STA	TDISK
	CALL	DECOD
	CNZ	BADCOM
	LDA	UDISK
	ORA	A
	JNZ	EXEC
	CALL	BUILD
	JNC	EXEC
	PUSH	PSW
	LHLD	BUFDEC
	PUSH	H
	CALL	PEREN
	POP	H
	SHLD	BUFDEC
	POP	PSW
	LXI	H,TF5C1
	MOV	E,A
	MVI	D,000H
	DAD	D
	DAD	D
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	PCHL
;
; >> NO EXECUTION PATH TO HERE <<
TF5C1:	.DW	DIR
	.DW	ERA
	.DW	TYPE
	.DW	SAVE
	.DW	REN
	.DW	USER
	.DW	TEST
	.DW	REST
	.DW	HDD
	.DW	EXEC
;
REST:	MVI	C,13
	CALL	X0005
	CALL	AF329
	CALL	SELDSK
	JMP	MAIN
;
HDD:	CALL	DECOD	; ПП переключения дискет НЖМД
	LXI	H,CBUF+1
	LDA	UDISK	; номер диска в командной строке
	DCR	A
	JP	HDD10	; >> A>FFh
	MOV	A,M
	CPI	20H
	JNZ	HDD01	; >> не пустая командная строка
	MVI	C,0	; вывод конфигурации
	CALL	HDD20
	MVI	C,1
	CALL	HDD20
	JMP	MAIN
;
HDD01:	DCX	H
	MOV	A,M
	INX	H
HDD10:	CPI	2
	JNC	BADCOM
	PUSH	PSW
	XCHG
	CALL	HDD30
	XCHG
	POP	PSW
	STA	4
	LXI	B,0F80H
	CALL	X0005
	ANA	A
	LDA	TDISK
	STA	4
	JNZ	BADCOM
	JMP	MAIN
;
HDD30:	LXI	H,0
	MVI	B,4
HDD32:	LDAX	D
	CPI	20H
	RZ
	INX	D
	ANI	7FH
	CPI	60H
	JC	HDD31
	SUI	20H
HDD31:	SUI	30H
	JC	BADCOM
	CPI	10
	JC	HDD33
	SUI	7
	CPI	10H
	JNC	BADCOM
HDD33:	DAD	H
	DAD	H
	DAD	H
	DAD	H
	ORA	L
	MOV	L,A
	DCR	B
	JNZ	HDD32
	RET
;
HDD20:	CALL	CRLF
	MVI	A,41H
	ADD	C
	CALL	PRINT2
	MVI	A,':'
	CALL	PRINT2
	CALL	SPACE
	MOV	E,C
	LXI	B,0E80H
	CALL	X0005
	MOV	A,H
	CALL	HEXOUT
	MOV	A,L
HEXOUT:	PUSH	PSW
	RRC
	RRC
	RRC
	RRC
	CALL	$+4
	POP	PSW
	ORI	0F0h	; преобразование HEX по методу ivagor
	DAA		;
	CPI	060h	;
	SBI	01Fh	;
	PUSH	H
	CALL	PRINTA
	POP	H
	RET
;
AF5D9:	LXI	B,TF5DF
	JMP     PRINT
;
TF5DF:	.DB "READ ERROR",0
;
AF5EA:	LXI	B,TF5F0
	JMP     PRINT
;
TF5F0:	.DB "NO FILE",0
;
AF5F8:	CALL	DECOD
	LDA	UDISK
	ORA	A
	JNZ	BADCOM
	LXI	H,CBUF+1
	LXI	B,0000BH
AF608:	MOV	A,M
	CPI	020H
	JZ	AF633
	INX	H
	SUI	030H
	CPI	00AH
	JNC	BADCOM
	MOV	D,A
	MOV	A,B
	ANI	0E0H
	JNZ	BADCOM
	MOV	A,B
	RLC
	RLC
	RLC
	ADD	B
	JC	BADCOM
	ADD	B
	JC	BADCOM
	ADD	D
	JC	BADCOM
	MOV	B,A
	DCR	C
	JNZ	AF608
	RET
;
AF633:	MOV	A,M
	CPI	020H
	JNZ	BADCOM
	INX	H
	DCR	C
	JNZ	AF633
	MOV	A,B
	RET
;
AF640:	MVI	B,003H
AF642:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	AF642
	RET
;
AF64B:	LXI	H,00080H
	ADD	C
	CALL	AF459
	MOV	A,M
	RET
;
AF654:	XRA	A
	STA	CBUF
F655:	LDA	UDISK
	ORA	A
	RZ
	DCR	A
	LXI	H,TDISK
	CMP	M
	RZ
	JMP	SELDSK
;
AF666:	LDA	UDISK
	ORA	A
	RZ
	DCR	A
	LXI	H,TDISK
	CMP	M
	RZ
	LDA	TDISK
	JMP	SELDSK
;
TEST:	CALL	DECOD
;	LXI	H,CBUF+1
	LDA	UDISK	; номер диска в командной строке
	DCR	A
	JP	TST01	; >> A<>FFh
	MVI	A,2
TST01:	MOV	D,A	; D= номер диска
	CPI	2
	JC	BADCOM	; >> переход, если A<2 (C:--)
	CPI     4
	JNC	BADCOM	; >> переход, если A>=4 (E:++)
	MVI	E,02h	; E= Х-тест, 1-восстановить КС, 2-форматирование
	LDA	CBUF+1	; первый символ параметров
	CPI	'F'
	JZ	TST02	; >> форматирование
	DCR	E
	CPI	'R'
	JZ	TST02	; >> восстановление
	DCR	E
	CPI	20h
	JNZ	BADCOM	; >> неправильный вызов
TST02:	LXI	B,80H
	CALL	X0005
	MVI	C,13	; сброс дисков
	CALL	X0005
	CALL	AF329
	CALL	SELDSK
	JMP	KONEC
;
DIR:	CALL	DECOD
	CALL	AF654
	LXI	H,CBUF+1
	MOV	A,M
	CPI	020H
	JNZ	AF68F
	MVI	B,00BH
AF688:	MVI	M,03FH
	INX	H
	DCR	B
	JNZ	AF688
AF68F:	MVI	E,000H
	PUSH	D
	CALL	SEAR2
	CZ	AF5EA
AF698:	JZ	AF71B
	LDA	DF9EE
	RRC
	RRC
	RRC
	ANI	060H
	MOV	C,A
	POP	D
	MOV	A,E
	INR	E
	PUSH	D
	ANI	003H
	PUSH	PSW
	JNZ	AF6CC
	CALL    CRLF
	PUSH	B
	CALL	GETDSK
	POP	B
	ADI	041H
	CALL    PRINT2
	MVI	A,03AH
	CALL    PRINT2
	JMP	AF6D4
;
AF6CC:	CALL    SPACE
	MVI	A,08Ah	; = '┼'
	CALL    PRINT2
	CALL	SPACE
AF6D4:	MVI	B,1
AF6D9:	MOV	A,B
	CALL	AF64B
	ANI	07FH
	CALL    PRINT2
	INR	B
	MOV	A,B
	CPI	00CH
	JNC	AF70E
	CPI	009H
	JNZ	AF6D9
	MVI	A,'.'
	CALL	PRINT2
	JMP	AF6D9
AF70E:	POP	PSW
	CALL	SPACE
	MVI	A,9
	CALL	AF64B
	RLC
	MVI	A,'R'
	JC	$+5
	MVI	A,20H
	CALL	PRINT2
	MVI	A,10
	CALL	AF64B
	RLC
	MVI	A,'S'
	JC	$+5
	MVI	A,20H
	CALL	PRINT2
	CALL	SPACE
	CALL	CONST
	JNZ	AF71B
	CALL	NSEAR
	JMP	AF698
AF71B:	POP	D
	LXI	B,0D80H
	CALL	X0005
	LXI	B,180H
	CALL	X0005
	MOV	A,E
	SUB	L
	MOV	E,A
	MOV	A,D
	SBB	H
	MOV	D,A
	PUSH	H
	PUSH	D
	LXI	B,STRDR0
	CALL	PRINT
	POP	H
	CALL	DES
	LXI	H,STRDR1
	CALL	PRINTH
	POP	H
	CALL	DES
	LXI	H,STRDR2
	CALL	PRINTH
	JMP	AF986
;
DES:	LXI	B,-1000
	CALL	DES10
	LXI	B,-100
	CALL	DES10
	LXI	B,-10
	CALL	DES10
	MOV	A,L
DES02:	ADI	30H
	PUSH	H
	CALL	PRINT2
	POP	H
	RET
DES10:	MVI	E,0
DES12:	PUSH	H
	DAD	B
	JNC	DES14
	INR	E
	XTHL
	POP	H
	JMP	DES12
DES14:	POP	H
	MOV	A,E
	JMP	DES02
;
STRDR0:.DB 27,62H,9,9,"Занято - ",0
STRDR1:.DB "КБ, свободно - ",0
STRDR2:.DB "КБ.",9,9,9,27,61H,0
;
ERA:	CALL	DECOD
	CPI	00BH
	JNZ	AF742
	LXI	B,TF752
	CALL    PRINT
	CALL	GTSTR
	LXI	H,LNBUF
	DCR	M
	JNZ	MAIN
	INX	H
	MOV	A,M
	CPI	059H
	JNZ	MAIN
	INX	H
	SHLD	BUFDEC
AF742:	CALL	AF654
	LXI	D,CBUF
	CALL	ERASE
	INR	A
	CZ	AF5EA
	JMP	AF986
;
; >> NO EXECUTION PATH TO HERE <<
TF752:	.DB "ALL (Y/N)?",0
;
TYPE:	CALL	DECOD
	JNZ	BADCOM
	CALL	AF654
	CALL	OPEN2
	JZ	AF7A7
	CALL    CRLF
	LXI	H,TF9F1
	MVI	M,0FFH
AF774:	LXI	H,TF9F1
	MOV	A,M
	CPI	080H
	JC	AF787
	PUSH	H
	CALL	READF
	POP	H
	JNZ	AF7A0
	XRA	A
	MOV	M,A
AF787:	INR	M
	LXI	H,00080H
	CALL	AF459
	MOV	A,M
	CPI	01AH
	JZ	AF986
	CALL    PRINTA
	CALL	CONST
	JNZ	AF986
	JMP	AF774
;
AF7A0:	DCR	A
	JZ	AF986
	CALL	AF5D9
AF7A7:	CALL	AF666
	JMP	BADCOM
;
SAVE:	CALL	AF5F8
	PUSH	PSW
	CALL	DECOD
	JNZ	BADCOM
	CALL	AF654
	LXI	D,CBUF
	PUSH	D
	CALL	ERASE
	POP	D
	CALL	MAKEF
	JZ	AF7FB
	XRA	A
	STA	DF9ED
	POP	PSW
	MOV	L,A
	MVI	H,000H
	DAD	H
	LXI	D,00100H
AF7D4:	MOV	A,H
	ORA	L
	JZ	AF7F1
	DCX	H
	PUSH	H
	LXI	H,00080H
	DAD	D
	PUSH	H
	CALL	SETDMA
	LXI	D,CBUF
	CALL	SWRIT
	POP	D
	POP	H
	JNZ	AF7FB
	JMP	AF7D4
;
AF7F1:	LXI	D,CBUF
	CALL	CLOSE
	INR	A
	JNZ	AF801
AF7FB:	LXI	B,TF807
	CALL    PRINT
AF801:	CALL	SYSDMA
	JMP	AF986
;
; >> NO EXECUTION PATH TO HERE <<
TF807:	.DB "NO SPACE",0
;
REN:	CALL	DECOD
	JNZ	BADCOM
	LDA	UDISK
	PUSH	PSW
	CALL	AF654
	CALL	SEAR2
	JNZ	AF879	; >>> файл1 найден, переход
	LXI	H,CBUF
	LXI	D,DF9DD
	MVI	B,010H
	CALL	AF642
	LHLD	BUFDEC
	XCHG
	CALL	OBRS13
	CPI	03DH
	JZ	AF83F
	CPI	05FH
	JNZ	AF873
AF83F:	XCHG
	INX	H
	SHLD	BUFDEC
	CALL	DECOD
	JNZ	AF873
	POP	PSW
	MOV	B,A
	LXI	H,UDISK
	MOV	A,M
	ORA	A
	JZ	AF859
	CMP	B
	MOV	M,B
	JNZ	AF873
AF859:	MOV	M,B
	XRA	A
	STA	CBUF
	CALL	SEAR2
	JZ	AF86D
	LXI	D,CBUF
	CALL	RENAM
	JMP	AF986
;
AF86D:	CALL	AF5EA
	JMP	AF986
;
AF873:	CALL	AF666
	JMP	BADCOM
;
AF879:	LXI	B,TF882
	CALL    PRINT	; "FILE EXISTS"
	JMP	AF986
;
; >> NO EXECUTION PATH TO HERE <<
TF882:	.DB "FILE EXISTS",0
;
USER:	CALL	AF5F8
	CPI	010H
	JNC	BADCOM
	MOV	E,A
	LDA	CBUF+1
	CPI	020H
	JZ	BADCOM
	CALL	SETUS
	JMP	KONEC
;
EXEC:	LDA	CBUF+1
	CPI	020H
	JNZ	AF8C4	; >> переход, если не пустая командная строка
	LDA	UDISK
	ORA	A
	JZ	EXEC10	; >> переход, если КС не начинается с диска
	DCR	A
	STA	TDISK
;	CALL	AF329	; <- убрал, иначе подвисает на ошибке в случае неверного диска
	CALL	SELDSK	; выбор диска
EXEC10:	CALL	PEREN
	JMP	KONEC
;
AF8C4:	LXI	D,EXT
	LDAX	D
	CPI	020H
	JNZ	EXEC12
	PUSH	D
	CALL	AF654
	POP	D
	LXI	H,ECOM
	CALL	AF640
	CALL	OPEN2
	JNZ	COM
	LXI	D,EXT
	LXI	H,EBAT
	CALL	AF640
	CALL	OPEN2
	JZ	AF96B
BAT:	CALL	AF666
	CALL	OBRSTR
	LXI	D,CBUF
	LDA	UDISK
	STAX	D
	LXI	B,580H
	CALL	X0005
	JMP	MAIN
EXEC12:	LXI	H,ECOM
	CALL	EXEC11
	JNZ	EXEC14
	CALL	AF654
	CALL	OPEN2
	JNZ	COM
	JMP	AF96B
EXEC14:	LXI	H,EBAT
	LXI	D,EXT
	CALL	EXEC11
	JNZ	BADCOM
	CALL	AF654
	CALL	OPEN2
	JNZ	BAT
	JMP	AF96B
EXEC11:	MVI	B,3
EXE11C:	LDAX	D
	CMP	M
	RNZ
	INX	H
	INX	D
	DCR	B
	JNZ	EXE11C
	RET
COM:	LXI	H,CBUF+1
	LXI	D,4CH
	LDA	UDISK
	STAX	D
	INX	D
	MVI	B,11
	CALL	AF642
	LXI	H,100H
AF8E1:	PUSH	H
	XCHG
	CALL	SETDMA
	LXI	D,CBUF
	CALL	SREAD
	JNZ	AF901
	POP	H
	LXI	D,00080H
	DAD	D
	LXI	D,DF200
	MOV	A,L
	SUB	E
	MOV	A,H
	SBB	D
	JNC	AF971
	JMP	AF8E1
AF901:	POP	H
	DCR	A
	JNZ	AF971
	CALL	AF666
	CALL	DECOD
	LXI	H,UDISK
	PUSH	H
	MOV	A,M
	STA	CBUF
	MVI	A,010H
	CALL	AF460
	POP	H
	MOV	A,M
	STA	DF9DD
	XRA	A
	STA	DF9ED
	LXI	D,0005CH
	LXI	H,CBUF
	MVI	B,021H
	CALL	AF642
	CALL	OBRSTR
	JMP	AF94F
OBRSTR:	LXI	H,COMSTR
AF930:	MOV	A,M
	ORA	A
	JZ	AF93E
	CPI	020H
	JZ	AF93E
	INX	H
	JMP	AF930
AF93E:	MVI	B,000H
	LXI	D,00081H
AF943:	MOV	A,M
	STAX	D
	ORA	A
	JZ	OBRS10
	CPI	'>'
	JZ	OBRS10
	CPI	'<'
	JZ	OBRS10
	INR	B
	INX	H
	INX	D
	JMP	AF943
OBRS10:	XRA	A
	STAX	D
	MOV	A,B
	STA	80H
PEREN:	LHLD	BUFDEC
	XCHG
OBRS12:	CALL	OBRS13
	RZ
	INX	D
	CPI	'<'
	JZ	OBRSIN
	CPI	'>'
	JNZ	OBRS12
	LDAX	D
	CPI	3EH
	JZ	ERROR
	XCHG
	SHLD	BUFDEC
	LDA	TDISK
	STA	OTDISK
	LXI	H,DBUF
	CALL	DECO10
	JNZ	ERROR
	XRA	A
	STA	DBUF
	CALL	F655
	LXI	D,DBUF
	LXI	B,380H
	CALL	BDOS
	PUSH	PSW
	LDA	OTDISK
	STA	TDISK
	CALL	SELDSK
	POP	PSW
	JZ	ERROR
	JMP	PEREN
OBRSIN:	XCHG
	SHLD	BUFDEC
	LDA	TDISK
	STA	OTDISK
	LXI	H,DBUF
	CALL	DECO10
	JNZ	ERROR
	XRA	A
	STA	DBUF
	CALL	F655
	LXI	D,DBUF
	LXI	B,280H
	CALL	BDOS
	PUSH	PSW
	LDA	OTDISK
	STA	TDISK
	CALL	SELDSK
	POP	PSW
	JZ	ERROR
	JMP	PEREN
OBRS13:	LDAX	D
	ANA	A
	RZ
	CPI	20H
	JZ	OBRS14
	CPI	9
	RNZ
OBRS14:	INX	D
	JMP	OBRS13
AF94F:	CALL    CRLF
	CALL	SYSDMA
	CALL	AF31A
	LXI	H,0
	PUSH	H
	JMP	X0100
AF96B:	CALL	AF666
	JMP	BADCOM
;
AF971:	LXI	B,TF97A
	CALL    PRINT
	JMP	AF986
;
; >> NO EXECUTION PATH TO HERE <<
TF97A:	.DB	"BAD LOAD",0
ECOM:	.DB	"COM"
EBAT:	.DB	"BAT"
;
AF986:	CALL	AF666
KONEC:	CALL	DECOD
	LDA	CBUF+1
	SUI	020H
	LXI	H,UDISK
	ORA	M
	JNZ	BADCOM
	JMP	MAIN
;
; >> NO EXECUTION PATH TO HERE <<
DBUF:	.DW	0,0,0,0,0,0,0,0
OTDISK:	.DB	0
CBUF:	.DB	0
	.DW	0,0,0,0
EXT:	.DB	0,0,0,0,0,0,0
DF9DD:	.DW	0,0,0,0,0,0,0,0
DF9ED:	.DB	0
DF9EE:	.DB	0
TDISK:	.DB	0
UDISK:	.DB	0
TF9F1:	.DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TFA00:	.DW 0,0,0
;
	.org 0FAFFh	; выравнивание размера
	.DB 0
	.END
