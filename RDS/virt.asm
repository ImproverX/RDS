	.ORG	0FB00H
;#DEFINE NoPACK
	JMP	BDOS	; +00
STEK1:	.EQU	0E000H
STEK2:	.EQU	0DFA0H
STEK3:	.EQU	0DF40H
ABIOS:	.EQU	0AE00H
BWBOOT:	.EQU	ABIOS+03H
NBDOS:	.EQU	0A006H
	JMP	WBOOT	; +03
	CALL	BIOS	; +06
	CALL	BIOS	; +09
	CALL	BIOS	; +0C
	CALL	BIOS	; +0F
	CALL	BIOS	; +12
	CALL	BIOS	; +15
	CALL	BIOS	; +18	HOME
	CALL	BIOS	; +1B	SELDSK
	CALL	BIOS	; +1E	SETTRK
	CALL	BIOS	; +21	SETSEC
	CALL	BIOS	; +24	SETDMA
	CALL	BIOS	; +27	READ
	CALL	BIOS	; +2A	WRITE
	CALL	BIOS	; +2D
	CALL	BIOS	; +30
	JMP	DYSPLY	; +33	VTAB-6	<<< прерывание по RST7
DYSINT:	JMP	0	; +36	VTAB-3
	JMP	DRAW	; +39	VTAB
	JMP	SCROLL	; +3C	VTAB+3
	JMP	CLS	; +3F	VTAB+6
	JMP	CURS	; +42	VTAB+9
DREXIT:	JMP	0	; +45	VTAB+12
	.DW	ZAGA	; +48	VTAB+15
	.DW	DRTAB	; +4A	VTAB+17
;
BIOS:	DI
	POP	H
	MOV	A,L
	SUI	3
;	MOV	L,A
;	MVI	H,0AEH	; =BIOS
;	SHLD	BIOS02+1
	STA	BIOS02+1; вместо трёх строк выше
	LDA	3BH
	STA	BSP10+1
	LDA	15
	STA	3BH
	OUT	10H
	LXI	H,0
	DAD	SP
	SHLD	BIOS10+1
	LXI	SP,STEK1
	EI
BIOS02:	CALL	ABIOS	;<<<< изменяется
	DI
BIOS10:	LXI	SP,0
	MOV	B,A
BSP10:	MVI	A,0	;	LDA	BSP10
	STA	3BH
	OUT	10H
	MOV	A,B
	EI
	RET
;BSP10:	.DB	0
;
WBOOT:	DI
	LXI	SP,0
	LDA	15
	STA	3BH
	OUT	10H
	EI
	CALL	BWBOOT
	DI
	LDA	3CH
	STA	3BH
	OUT	10H
	EI
	PCHL
;
BDOS:	DI
	LDA	15
	STA	3BH
	OUT	10H
	LXI	H,0
	DAD	SP
	SHLD	BDOS10+1
	LXI	SP,STEK2
	EI
	CALL	NBDOS
	DI
BDOS10:	LXI	SP,0
	MOV	C,A
	LDA	3CH
	OUT	10H
	STA	3BH
	MOV	A,C
	EI
	RET
;
SCROLL:	XRA	A
	OUT	10H
	MOV	D,A
	MOV	A,E
	MOV	E,B
SCR08:	MOV	B,E
SCR10:	MOV	M,D
	DCR	L
	MOV	M,D
	DCR	L
	DCR	B
	JNZ	SCR10
	MOV	L,C
	INR	H
	CMP	H
	JNZ	SCR08
	LDA	15
	OUT	10H
	RET
;
CLS:	XRA	A
	OUT	10H
	LXI	H,0
	DAD	SP
	SHLD	CLS20+1
	LXI	SP,STEK1
	LXI	H,-1024
	LXI	D,0
	LXI	B,1
CLS10:	PUSH	D
	PUSH	D
	PUSH	D
	PUSH	D
	PUSH	D
	PUSH	D
	PUSH	D
	PUSH	D
	DAD	B
	JNC	CLS10
CLS20:	LXI	SP,0
	LDA	15
	OUT	10H
	RET
;
DYSPLY:	PUSH	H
	PUSH	PSW
	LXI	H,0
	DAD	SP
	LDA	15
	OUT	10H
	LXI	SP,STEK3
	CALL	DYSINT
	SPHL
	LDA	3BH
	OUT	10H
	POP	PSW
	POP	H
	EI
	RET
;
CURS:	XRA	A
	OUT	10H
	MOV	A,D
	ANA	C
	XRA	M
	MOV	M,A
	INR	H
	MOV	A,D
	ANA	B
	XRA	M
	MOV	M,A
	MVI	A,1FH
	ADD	H
	MOV	H,A
	MOV	A,D
	ANA	C
	XRA	M
	MOV	M,A
	INR	H
	MOV	A,D
	ANA	B
	XRA	M
	MOV	M,A
	LDA	15
	OUT	10H
	RET
;
DRAW:	OUT	10H
	JMP	0
DR0:
DR010:	POP	PSW
	DCX	SP
INV0:	NOP
	MOV	C,A
	XRA	M
	ANI	0E0H
	XRA	M
	MOV	M,A
	XCHG
	MOV	A,C
	RLC
	RLC
	RLC
	XRA	M
	ANI	0E0H
	XRA	M
	MOV	M,A
	XCHG
	DCR	L
	DCR	E
	DCR	B
	JNZ	DR010
DRW10:	MVI	A,20H	; 0010 0000b -- банк 3 как ОЗУ A000-DFFFh
	OUT	10H
	JMP	DREXIT
DR1:
DR110:	POP	PSW
	DCX	SP
INV2:	NOP
	MOV	C,A
	RRC
	XRA	M
	ANI	70H
	XRA	M
	MOV	M,A
	XCHG
	MOV	A,C
	RLC
	RLC
	XRA	M
	ANI	70H
	XRA	M
	MOV	M,A
	XCHG
	DCR	E
	DCR	L
	DCR	B
	JNZ	DR110
	JMP	DRW10
DR2:
DR210:	POP	PSW
	DCX	SP
INV4:	NOP
	MOV	C,A
	RRC
	RRC
	XRA	M
	ANI	38H
	XRA	M
	MOV	M,A
	XCHG
	MOV	A,C
	RLC
	XRA	M
	ANI	38H
	XRA	M
	MOV	M,A
	XCHG
	DCR	E
	DCR	L
	DCR	B
	JNZ	DR210
	JMP	DRW10
DR3:
DR310:	POP	PSW
	DCX	SP
INV6:	NOP
	MOV	C,A
	RRC
	RRC
	RRC
	XRA	M
	ANI	1CH
	XRA	M
	MOV	M,A
	XCHG
	MOV	A,C
	XRA	M
	ANI	1CH
	XRA	M
	MOV	M,A
	XCHG
	DCR	E
	DCR	L
	DCR	B
	JNZ	DR310
	JMP	DRW10
DR4:
DR410:	POP	PSW
	DCX	SP
INV8:	NOP
	RRC
	MOV	C,A
	RRC
	RRC
	RRC
	XRA	M
	ANI	0EH
	XRA	M
	MOV	M,A
	XCHG
	MOV	A,C
	XRA	M
	ANI	0EH
	XRA	M
	MOV	M,A
	XCHG
	DCR	E
	DCR	L
	DCR	B
	JNZ	DR410
	JMP	DRW10
DR5:
DR510:	POP	PSW
	DCX	SP
INVA:	NOP
	MOV	C,A
	RLC
	RLC
	RLC
	XRA	M
	ANI	7
	XRA	M
	MOV	M,A
	XCHG
	MOV	A,C
	RRC
	RRC
	XRA	M
	ANI	7
	XRA	M
	MOV	M,A
	XCHG
	DCR	E
	DCR	L
	DCR	B
	JNZ	DR510
	JMP	DRW10
DR6:
DR610:	POP	PSW
	DCX	SP
INVC:	NOP
	RLC
	RLC
	MOV	C,A
	XRA	M
	ANI	3
	XRA	M
	MOV	M,A
	INR	H
	MOV	A,C
	XRA	M
	ANI	80H
	XRA	M
	MOV	M,A
	DCR	H
	XCHG
	MOV	A,C
	RLC
	RLC
	RLC
	MOV	C,A
	XRA	M
	ANI	3
	XRA	M
	MOV	M,A
	INR	H
	MOV	A,C
	XRA	M
	ANI	80H
	XRA	M
	MOV	M,A
	DCR	H
	XCHG
	DCR	E
	DCR	L
	DCR	B
	JNZ	DR610
	JMP	DRW10
DR7:
DR710:	POP	PSW
	DCX	SP
INVE:	NOP
	RLC
	MOV	C,A
	XRA	M
	ANI	1
	XRA	M
	MOV	M,A
	INR	H
	MOV	A,C
	XRA	M
	ANI	0C0H
	XRA	M
	MOV	M,A
	DCR	H
	XCHG
	MOV	A,C
	RLC
	RLC
	RLC
	MOV	C,A
	XRA	M
	ANI	1
	XRA	M
	MOV	M,A
	INR	H
	MOV	A,C
	XRA	M
	ANI	0C0H
	XRA	M
	MOV	M,A
	DCR	H
	XCHG
	DCR	E
	DCR	L
	DCR	B
	JNZ	DR710
	JMP	DRW10
;
DRTAB:	.DW DR0,DR1,DR2,DR3,DR4,DR5,DR6,DR7
INVTAB:	.DW INV0,INV2,INV4,INV6,INV8,INVA,INVC,INVE
;
ZAGA:	.DW 0,0,0,0,DIRB,PARA,CSVA,ALVA
ZAGB:	.DW 0,0,0,0,DIRB,PARB,CSVB,ALVB
ZAGC:	.DW 0,0,0,0,DIRB,PARC,0,ALVC
ZAGD:	.DW 0,0,0,0,DIRB,PARD,0,ALVD
; 00 адрес таблицы трансляции логических секторов в физические (передается функции SECTRAN в DE) или 0 если трансляция не нужна
; 01 просто ноль
; 02 просто ноль
; 03 просто ноль
; 04 адрес 128 байтного буфера для операций с директорием. Это поле у всех DPH в системе может совпадать.
; 05 адрес таблицы параметров диска. Допускается совместное использование одной и той же таблицы разными DPH.
; 06 адрес области используемой для контроля смены диска. Для каждого DPH в системе должна быть своя область.
; 07 адрес области для контроля за заполнением диска. Для каждого DPH в системе должна быть своя область.
;
PARA:	.DW 40
	.DB 4,15,0
	.DW 187H,127,0C0H,32,8
PARB:	.DW 40
	.DB 4,15,0
	.DW 187H,127,0C0H,32,8
PARC:	.DW 8
	.DB 3,7,0
	.DW 235,63,0C0H,0,0	; 219...
PARD:	.DW 8
	.DB 3,7,0
	.DW 235,63,0C0H,0,0
; Параметры диска:
; DW SPT - количество секторов (по 128 байт) на дорожку;
; DB BSH - количество бит, на которое необходимо сдвинуть размер логического сектора, чтобы получить размер кластера
; DB BLM - маска кластера - (размер_кластера/128)-1;
; DB ЕХМ - маска директорной записи: если ЕХМ=0, то максимальный размер, адресуемый одной директорной записью, равен 16К; если ЕХМ=1, то - 32К и т.д.
; DW DSM - объем памяти на диске в блоках минус 1 (не считая системных дорожек)
; DW DRM - количество входов в директорию -1
; DB AL0,1 - битовая шкала занятости BLS директорией. Начало шкалы - бит 7 AL0, конец - бит 0 AL1. Количество единиц, заполняющих AL0,1 (от начала шкалы) - (DRM+BLS/32)/(BLS/32).
	; // определяет, какие блоки зарезервированы
	; // под директорию. Каждый  бит AL0,AL1, 
	; // начиная со старшего бита AL0 и кончая 
	; // младшим битом AL1, значением 1 резервирует
	; // один блок данных для директории. Нужно
	; // резервировать необходимое число блоков
	; // для хранения входов в директорию: 32*DRM/BLS
; DW CKS - размер области CSV в DPH. Для сменных дисков - (DRM+1)/4, для не сменных - 0.
; DW OFF - количество зарезервированных дорожек на диске (с системой например). 
;
DIRB:	.DS	128	; <=
CSVA:	.DS	32	; <=
CSVB:	.DS	32	; <=
ALVA:	.DS	51	; <=
ALVB:	.DS	51	; <=
ALVC:	.DS	33	; <=
ALVD:	.DS	33	; <=
;
#ifndef NoPACK
	.org 01077Fh	; выравнивание размера
#else
	.org 0FF7Fh
#endif
	.db 0
	.END
