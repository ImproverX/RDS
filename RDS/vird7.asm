	.ORG	0080h
A_080:	JMP	READ
A_083:	JMP	WRITE
READ:	SPHL
	XCHG
READ10:	MVI	A,10H	; 0001 0000 -- режим "стек", банк 3
	OUT	10H
	POP	D
	LDA	3CH
	OUT	10H
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	DCR	C
	JNZ	READ10
	LDA	15	; РДС
	OUT	10H
	LXI	SP,SBUF	; <= 0FEH
	RET
;
WRITE:	SPHL
	XCHG
WRIT10:	LDA	3CH
	OUT	10H
	DCX	H
	MOV	D,M
	DCX	H
	MOV	E,M
	MVI	A,10H	; 0001 0000 -- режим "стек", банк 3
	OUT	10H
	PUSH	D
	DCR	C
	JNZ	WRIT10
	LXI	SP,SBUF	; <= 0FEH
	LDA	15	; РДС
	OUT	10H
	RET
	.ORG 00FEh
SBUF:	.DW 0		; << стек, адрес возврата из vird7
	.org 027Fh	; выравнивание размера
	.db 0
	.END
