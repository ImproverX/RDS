;	Структура элемента таблицы.
; Длина 7 б. 2б-код,3-ключ,2б-смещение.
	ORG	100H
	JMP	START
HSTAB:	EQU	0C000H
MBUF:	EQU	800H
OPENF:	MVI	C,15
	JMP	5
CLOSEF:	MVI	C,16
	JMP	5
ERAF:	MVI	C,19
	JMP	5
SREAD:	MVI	C,20
	JMP	5
SWRITE:	MVI	C,21
	JMP	5
MAKEF:	MVI	C,22
	JMP	5
RENF:	MVI	C,23
	JMP	5
SETDMA:	MVI	C,26
	JMP	5
STR0:	DB 10,7,'Отсутствует входной файл !$'
STR1:	DB 10,7,'Нет места в каталоге диска !$'
STR2:	DB 10,7,'Немогу записать выходной файл,диск полон !$'
STR3:	DB 10,'Упаковка завершена !$'
KADR:	DW	0
START:	LXI	SP,0
	LDA	5DH
	CPI	20H
	LXI	D,STR0
	JZ	EXITMS
	CALL	CLEAR
	LXI	D,5CH
	CALL	OPENF
	INR	A
	LXI	D,STR0
	JZ	EXITMS
	LXI	D,MBUF
BEGIN:	PUSH	D
	CALL	SETDMA
	LXI	D,5CH
	CALL	SREAD
	POP	D
	LXI	H,128
	DAD	D
	XCHG
	ANA	A
	JZ	BEGIN
	SHLD	KADR
	LXI	H,65H
	MVI	M,'M'
	INX	H
	MVI	M,'L'
	INX	H
	MVI	M,'Z'
	CALL	CLEAR
	LXI	D,5CH
	CALL	ERAF
	LXI	D,5CH
	CALL	MAKEF
	LXI	D,STR1
	INR	A
	JZ	EXITMS
	LXI	D,80H
	CALL	SETDMA
	XRA	A
	STA	FLPNT
	LXI	H,CURSTR
	LXI	B,700H
	CALL	FILL
	LXI	H,MBUF
	SHLD	BYTPNT
	LXI	H,0
	SHLD	SMECH
	SHLD	NSMECH
	CALL	INITB
	MVI	A,1
	STA	LENSTR
	CALL	GTNXCH
	LDA	CURBYT
	STA	CURSTR+3
	DI
PAK:	LXI	H,CURSTR
	LXI	D,NEWSTR
	MVI	B,7
	CALL	COPY
	LXI	H,LENSTR
	MOV	A,M
	CPI	18
	JZ	PAK10
	INR	M
	IN	1
	ADD	A
	JP	PAKEOF
	CALL	GTNXCH
	JC	PAKEOF
	LXI	H,NEWSTR
	CALL	EXIST
	JNZ	PAK10
	LXI	D,CURSTR+2
	MVI	B,2
	CALL	COPY
	XRA	A
	STAX	D
	INX	D
	INX	H
	INX	H
	INX	H
	MVI	B,2
	CALL	COPY
	DCX	H
	XCHG
	LHLD	NSMECH
	XCHG
	MOV	M,D
	DCX	H
	MOV	M,E
	XCHG
	INX	H
	SHLD	NSMECH
	JMP	PAK
PAK10:	CALL	WRCODE
	CALL	INS
	LXI	H,CURSTR
	LXI	B,700H
	CALL	FILL
	LDA	CURBYT
	STA	CURSTR+3
	XRA	A
	STA	LENSTR
	LHLD	NSMECH
	INX	H
	SHLD	NSMECH
	SHLD	SMECH
	JMP	PAK
WRCODE:	LDA	CURSTR+2
	ANA	A
	JZ	WRCD20
	CALL	WRCD22
	LHLD	CURSTR+5
	XCHG
	LHLD	NSMECH
	DCX	H
	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	LXI	D,514
	CALL	HDCMP
	JNC	WRCD30
	LXI	D,65
	CALL	HDCMP
	JNC	WRCD10
	LDA	LENSTR
	CPI	4
	JNC	WRCD10
	SUI	2
	DCR	L
	RRC
	RRC
	ORA	L
	ADI	30H
	JMP	WRBYTE
WRCD10:	DCX	H
	DCX	H
	DCX	H
	LDA	LENSTR
	SUI	3
	MOV	E,A
	MOV	A,H
	RRC
	RRC
	RRC
	RRC
	ORA	E
	ADI	0B0H
	CALL	WRBYTE
	MOV	A,L
	JMP	WRBYTE
WRCD20:	LXI	H,LENNPK
	INR	M
	MOV	A,M
	DCR	A
	LXI	H,NPKBUF
	CALL	HLA
	LDA	CURSTR+3
	MOV	M,A
	LDA	LENNPK
	CPI	48
	RC
WRCD22:	LDA	LENNPK
	ANA	A
	RZ
WRCD23:	MOV	B,A
	DCR	A
	CALL	WRBYTE
	LXI	H,NPKBUF
WRCD24:	MOV	A,M
	CALL	WRBYTE
	INX	H
	DCR	B
	JNZ	WRCD24
	XRA	A
	STA	LENNPK
	RET
WRCD30:	LXI	D,MBUF
	DAD	D
	LDA	LENSTR
	JMP	WRCD23
WRBYTE:	PUSH	H
	PUSH	D
	PUSH	B
	MOV	C,A
	LXI	H,80H
	LDA	FLPNT
	CALL	HLA
	MOV	M,C
	LXI	H,FLPNT
	INR	M
	CM	WRBT10
	POP	B
	POP	D
	POP	H
	RET
WRBT10:	MVI	M,0
	LXI	D,5CH
	CALL	SWRITE
	ANA	A
	RZ
	LXI	D,STR2
	JMP	EXITMS
PAKEOF:	LXI	SP,0
	CALL	WRCODE
	MVI	A,-1
	CALL	WRBYTE
	LXI	D,5CH
	CALL	SWRITE
	ANA	A
	LXI	D,STR2
	JNZ	EXITMS
	LXI	D,5CH
	CALL	CLOSEF
	LXI	D,STR3
	JMP	EXITMS
INITB:	LXI	H,0
	SHLD	HSPNT
	SHLD	LNHSTB
	LXI	H,100H
	SHLD	NUMCOD
	SHLD	FRSNUM
	RET
SEEKEL:	XCHG
	LHLD	HSPNT
	DAD	D
	LXI	D,1026
	CALL	HDCMP
	JC	SEEK10
	LXI	D,-1026
	DAD	D
SEEK10:	PUSH	H
	DAD	H
	PUSH	H
	DAD	H
	POP	D
	DAD	D
	POP	D
	DAD	D
	LXI	D,HSTAB
	DAD	D
	RET
INS:	LHLD	LNHSTB
	PUSH	H
	CALL	SEEKEL
	XCHG
	LHLD	NUMCOD
	PUSH	H
	XCHG
	MOV	M,D
	INX	H
	MOV	M,E
	INX	H
	LXI	D,NEWSTR+2
	XCHG
	MVI	B,3
	CALL	COPY
	LHLD	SMECH
	XCHG
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	POP	H
	INX	H
	SHLD	NUMCOD
	POP	H
	LXI	D,1026
	CALL	HDCMP
	JNZ	INS12
	LHLD	HSPNT
	INX	H
	SHLD	HSPNT
	LHLD	FRSNUM
	INX	H
	SHLD	FRSNUM
	RET
INS12:	INX	H
	SHLD	LNHSTB
	RET
GTNXCH:	LHLD	KADR
	XCHG
	LHLD	BYTPNT
	CALL	HDCMP
	STC
	RZ
	MOV	A,M
	INX	H
	SHLD	BYTPNT
	STA	CURBYT
	STA	NEWSTR+4
	ANA	A
	RET
EXIST:	PUSH	H
	INX	H
	INX	H
	MOV	D,M
	INX	H
	MOV	E,M
	INX	D
	LXI	H,100H
	CALL	HDCMP
	JC	$+6
	LXI	D,100H
	LHLD	FRSNUM
	MOV	A,E
	SUB	L
	MOV	E,A
	MOV	A,D
	SBB	H
	MOV	D,A
	LHLD	LNHSTB
	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	PUSH	H
	XCHG
	CALL	SEEKEL
	POP	B
	POP	D
EXIS10:	MOV	A,B
	ORA	C
	JZ	EXIS12
	CALL	STRCMP
	RZ
	PUSH	B
	LXI	B,7
	DAD	B
	POP	B
	DCX	B
	JMP	EXIS10
EXIS12:	ORI	1
	RET
STRCMP:	PUSH	H
	PUSH	D
	PUSH	B
	INX	H
	INX	H
	INX	D
	INX	D
	MVI	B,3
STRC10:	LDAX	D
	CMP	M
	JNZ	STRC12
	INX	H
	INX	D
	DCR	B
	JNZ	STRC10
STRC12:	POP	B
	POP	D
	POP	H
	RET
COPY:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	COPY
	RET
HLA:	ADD	L
	MOV	L,A
	RNC
	INR	H
	RET
HDCMP:	MOV	A,H
	SUB	D
	RNZ
	MOV	A,L
	SUB	E
	RET
EXITMS:	MVI	C,9
	LXI	SP,0
	CALL	5
	JMP	0
CLEAR:	LXI	H,68H
	LXI	B,1800H
FILL:	MOV	M,C
	INX	H
	DCR	B
	JNZ	FILL
	RET
CURSTR:	DS	7
CURBYT:	DB	0
NEWSTR:	DS	7
BYTPNT:	DW	0
SMECH:	DW	0
LENSTR:	DB	0
FLPNT:	DB	0
HSPNT:	DW	0
LNHSTB:	DW	0
NSMECH:	DW	0
LENNPK:	DB	0
FRSNUM:	DW	0
NUMCOD:	DW	0
NPKBUF:	DS	48
