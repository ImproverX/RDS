	ORG	8800H	JMP	STARTBUF:	DS	6BUF2:	DS	6START:	LHLD	MADR	MVI	B,11	CALL	PAGE	SHLD	MADR	CALL	KEY	CPI	3	JZ	0E6FEH	CPI	'S'	JZ	SYS	CPI	'A'	JNZ	START	CALL	BEGIN	SHLD	MADR	JMP	STARTSYS:	LXI	H,HEX	MOV	A,M	CMA	MOV	M,A	JMP	STARTBEGIN:	MVI	C,13	CALL	PRINTC	CALL	PRINTHBEG10:	CALL	KEY	CPI	13	RZ	CPI	30H	JC	BEG10	CPI	'G'	JNC	BEG10	CPI	3AH	JC	BEG12	CPI	'A'	JC	BEG10	SUI	7BEG12:	SUI	30H	CALL	DOB	JMP	BEGINDOB:	MOV	D,A	MOV	A,L	RLC	RLC	RLC	RLC	MOV	E,A	ANI	0F0H	ORA	D	MOV	L,A	MOV	A,H	RLC	RLC	RLC	RLC	ANI	0F0H	MOV	D,A	MOV	A,E	ANI	15	ORA	D	MOV	H,A	RETHOCT:	LXI	H,BUF	MOV	A,D	ANI	80H	RLC	ORI	30H	MOV	M,A	INX	H	MOV	A,D	ANI	70H	RLC	RLC	RLC	RLC	ORI	30H	MOV	M,A	INX	H	MOV	A,D	ANI	0EH	RRC	ORI	30H	MOV	M,A	INX	H	PUSH	B	MOV	A,D	ANI	1	RLC	RLC	MOV	B,A	MOV	A,E	ANI	0C0H	RLC	RLC	ORA	B	ORI	30H	POP	B	MOV	M,A	MOV	A,E	INX	H	ANI	38H	RRC	RRC	RRC	ORI	30H	MOV	M,A	MOV	A,E	ANI	7	ORI	30H	INX	H	MOV	M,A	RETPAGE:	PUSH	B	CALL	HEXS	MOV	E,M	INX	H	MOV	D,M	INX	H	SHLD	TADR	PUSH	H	PUSH	D	MOV	E,M	INX	H	MOV	D,M	INX	H	PUSH	D	MOV	E,M	INX	H	MOV	D,M	XCHG	SHLD	OPER2	POP	H	SHLD	OPER1	POP	D	POP	H	PUSH	H	CALL	HOCT	XRA	A	STA	WOP	CALL	DIS	LDA	WOP	ANA	A	JZ	PAGE10	LHLD	TADR	LXI	D,-4	DAD	D	DCR	A	JNZ	PAGE05	INX	H	INX	HPAGE05:	CALL	HEXS	INX	H	INX	H	LDA	WOP	DCR	A	JZ	PAGE10	CALL	HEXSPAGE10:	POP	H	POP	B	LHLD	TADR	DCR	B	JNZ	PAGE	RETHEXS:	PUSH	H	PUSH	D	MVI	C,10	CALL	PRINTC	CALL	PRINTH	CALL	TABUL	CALL	TABUL	MOV	E,M	INX	H	MOV	D,M	XCHG	CALL	PRINTH	CALL	TABUL	CALL	TABUL	POP	D	POP	H	RETPRINTH:	LDA	HEX	ANA	A	JZ	PRNTH	PUSH	H	PUSH	D	XCHG	LXI	H,BUF2	PUSH	H	CALL	HOCT+3	POP	H	MVI	D,6PRNT10:	MOV	C,M	CALL	PRINTC	INX	H	DCR	D	JNZ	PRNT10	POP	D	POP	H	RETPRNTH:	MOV	A,H	CALL	HEXOUT	MOV	A,L	JMP	HEXOUTTABUL: 	MVI	C,32	JMP	PRINTCDIS:	MOV	A,D	ANA	A	JNZ	DIS20	MOV	A,E	CPI	7	JNC	DIS20	XCHG	DAD	H	DAD	H	LXI	D,TAB0	DAD	D	MVI	B,4DIS10:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	DIS10	RETDIS20:	MOV	A,D	ANI	70H	CPI	10H	JNZ	DIS30	LXI	H,MOVDIS21:	MVI	B,3DIS21@:	MOV	C,M	INX	H	CALL	PRINTC	DCR	B	JNZ	DIS21@	MOV	A,D	ANI	80H	JZ	DIS22	MVI	C,'B'	CALL	PRINTCDIS22:	CALL	TABUL	LHLD	OPER1	SHLD	OPERT	LXI	H,BUF+3	CALL	PROP	MVI	C,','	CALL	PRINTC	LHLD	OPER2	SHLD	OPERT	LXI	H,BUF+5	CALL	PROP	RETDIS30:	CPI	40H	JNZ	DIS32	LXI	H,BIC	JMP	DIS21DIS32:	CPI	50H	JNZ	DIS34	LXI	H,BIS	JMP	DIS21DIS34:	MOV	A,D	ANI	0F0H	CPI	60H	JNZ	DIS36	LXI	H,ADDDIS35:	CALL	PRINT	JMP	DIS22DIS36:	CPI	0E0H	JNZ	DIS40	LXI	H,SUB	JMP	DIS35DIS40:	LXI	H,CMP	ANI	70H	CPI	20H	JZ	DIS21	LXI	H,BIT	CPI	30H	JZ	DIS21	MOV	A,D	ANI	7FH	CPI	10	JC	DIS44	CPI	12	JNC	DIS44	CALL	VID3	JMP	DIS41VID3:	PUSH	H	LXI	H,BUF+3	MOV	A,M	ANI	7	POP	H	RETDIS41:	PUSH	D	MOV	L,A	MVI	H,0	PUSH	H	POP	D	DAD	H	DAD	D	LXI	D,TAB2	DAD	D	POP	DDIS41@:	MVI	B,3DIS40@:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	DIS40@	MOV	A,D	ANI	80H	JZ	DIS42	MVI	C,'B'	CALL	PRINTCDIS42:	LHLD	OPER1	CALL	TABUL	SHLD	OPERT	LXI	H,BUF+5	CALL	PROP	RETDIS44:	CPI	12	JC	DIS46	CPI	13	JNC	DIS46	CALL	VID3	ANI	3	PUSH	D	MVI	H,0	MOV	L,A	PUSH	H	POP	D	DAD	H	DAD	D	LXI	D,TAB3	DAD	D	POP	D	JMP	DIS41@DIS46:	CPI	13	JC	DIS50	CPI	14	JNC	DIS50	CALL	VID3	ANI	3	PUSH	B	MOV	B,A	MOV	A,D	ANI	80H	MOV	A,B	POP	B	JZ	DIS48	ORI	4DIS48:	MOV	L,A	MVI	H,0	PUSH	D	DAD	H	DAD	H	LXI	D,TAB4	DAD	D	POP	D	PUSH	PSW	MVI	B,4DIS48@:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	DIS48@	POP	PSW	ANA	A	JNZ	DIS42DIS49:	MOV	A,E	ANI	3FH	ADD	A	MOV	E,A	MVI	D,0	LHLD	TADR	MOV	A,L	SUB	E	MOV	L,A	MOV	A,H	SBB	D	MOV	H,A	CALL	TABUL	JMP	PRINTHDIS50:	MOV	A,D	ANA	A	JNZ	DIS52	MOV	A,E	ANI	0C0H	CPI	0C0H	JC	DIS51	LXI	H,SWAB	CALL	PRINT	JMP	DIS42DIS51:	CPI	80H	JNC	DIS52	CPI	40H	JC	DIS52	LXI	H,JMP	CALL	PRINT	JMP	DIS42DIS52:	LXI	H,BUF+1	MOV	A,M	ANI	7	JNZ	DIS60	INX	H	MOV	A,M	ANI	7	CPI	4	JNC	DIS60	MOV	A,D	ANA	A	JZ	DIS60	MOV	A,D	ANI	7	MOV	B,A	MOV	A,D	ANI	80H	MOV	A,B	JZ	DIS54@	ORI	8DIS54@:	MOV	L,A	MVI	H,0	DAD	H	DAD	H	PUSH	D	LXI	D,TAB5	DAD	D	POP	D	MVI	B,4DIS56:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	DIS56	CALL	TABUL	MOV	A,E	ANI	80H	PUSH	PSW	MOV	A,E	ADD	A	MOV	E,A	MVI	D,0	LHLD	TADR	POP	PSW	JZ	DIS58	MVI	D,-1DIS58:	DAD	D	JMP	PRINTHDIS60:	MOV	A,D	CPI	88H	JNZ	DIS62	LXI	H,EMTDIS61:	CALL	PRINT	CALL	TABUL	MOV	L,E	MVI	H,0	JMP	PRINTHDIS62:	CPI	89H	LXI	H,TRAP	JZ	DIS61	MOV	A,D	CPI	70H	JC	DIS66	CPI	7AH	JNC	DIS66	LXI	H,BUF+2	MOV	A,M	ANI	7	PUSH	D	MOV	L,A	MVI	H,0	DAD	H	DAD	H	LXI	D,TAB6	DAD	D	POP	D	MVI	B,4DIS62@:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	DIS62@DIS64:	CALL	TABUL	LXI	H,BUF+3	CALL	PRREG	MVI	C,','	CALL	PRINTC	JMP	DIS42DIS66:	CPI	8	JC	DIS68	CPI	10	JNC	DIS68	LXI	H,JSR	CALL	PRINT	JMP	DIS64DIS68:	CPI	7EH	JC	DIS70	CPI	80H	JNC	DIS70	LXI	H,SOB	CALL	PRINT	LXI	H,BUF+3	CALL	PRREG	MVI	C,','	CALL	PRINTC	JMP	DIS49DIS70:	MOV	A,D	ANA	A	JNZ	DIS99	MOV	A,E	CPI	80H	JC	DIS99	CPI	88H	JNC	DIS72	LXI	H,RTS	CALL	PRINT	LXI	H,BUF+5	JMP	PRREGDIS72:	CPI	0A0H	JZ	DIS76	ANI	0F0H	CPI	0C0H	JNC	DIS99	CPI	0A0H	JC	DIS99	LXI	H,CLF	CPI	0B0H	JC	DIS74	LXI	H,SEFDIS74:	CALL	PRINT	MOV	A,E	RRC	MOV	E,A	JNC	DIS740	MVI	C,'C'	CALL	PRINTCDIS740:	MOV	A,E	RRC	MOV	E,A	JNC	DIS742	MVI	C,'V'	CALL	PRINTCDIS742:	MOV	A,E	RRC	MOV	E,A	JNC	DIS744	MVI	C,'Z'	CALL	PRINTCDIS744:	MOV	A,E	RRC	RNC	MVI	C,'N'	JMP	PRINTCDIS76:	LXI	H,NOP	JMP	PRINTPROP:	MOV	A,M	CPI	'7'	JZ	MEM	DCX	H	MOV	A,MPROP10:	ANI	7	JZ	REG0	DCR	A	JZ	REG1	DCR	A	JZ	REG2	DCR	A	JZ	REG3	DCR	A	JZ	REG4	DCR	A	JZ	REG5	DCR	A	JZ	REG6	MVI	C,'@'	CALL	PRINTCREG6:	PUSH	H	LHLD	TADR	MOV	A,M	INX	H	MOV	H,M	MOV	L,A	CALL	PRINTH	POP	H	MVI	C,'('	CALL	PRINTC	INX	H	CALL	PRREG	MVI	C,')'	CALL	PRINTC	LHLD	TADR	INX	H	INX	H	SHLD	TADR	LXI	H,WOP	INR	M	RETMEM:	DCX	H	MOV	A,M	ANI	7	CPI	2	JC	PROP10	JZ	MEM2	CPI	3	JZ	MEM3	CPI	6	JC	PROP10	JNZ	MEM7MEM6:	LHLD	TADR	MOV	E,M	INX	H	MOV	D,M	INX	H	SHLD	TADR	PUSH	H	LXI	H,WOP	INR	M	POP	H	DAD	D	JMP	PRINTHMEM7:	MVI	C,'@'	CALL	PRINTC	JMP	MEM6MEM2:	MVI	C,'#'	CALL	PRINTC	LHLD	TADR	MOV	E,M	INX	H	MOV	D,M	INX	H	SHLD	TADR	LXI	H,WOP	INR	M	XCHG	JMP	PRINTHMEM3:	MVI	C,'@'	CALL	PRINTC	JMP	MEM2REG0:	INX	H	JMP	PRREGREG1:	MVI	C,'@'	CALL	PRINTC	INX	H	JMP	PRREGREG2:	MVI	C,'('	CALL	PRINTC	INX	H	CALL	PRREG	LXI	H,SK0	JMP	PRINTREG3:	MVI	C,'@'	CALL	PRINTC	JMP	REG2REG4:	PUSH	H	LXI	H,SK1	CALL	PRINT	POP	H	INX	H	CALL	PRREG	MVI	C,')'	JMP	PRINTCREG5:	MVI	C,'@'	CALL	PRINTC	JMP	REG4PRREG:	MOV	A,M	ANI	7	MOV	L,A	MVI	H,0	DAD	H	PUSH	D	LXI	D,TAB1	DAD	D	POP	D	MOV	C,M	CALL	PRINTC	INX	H	MOV	C,M	JMP	PRINTCDIS99:	LXI	H,??	JMP	PRINTPRINT:	MOV	A,M	ANA	A	RZ	INX	H	PUSH	B	MOV	C,A	CALL	PRINTC	POP	B	JMP	PRINTKEY:	PUSH	H	PUSH	D	PUSH	BKEY02:	MVI	C,6	MVI	E,-1	CALL	5	ANA	A	JZ	KEY02	POP	B	POP	D	POP	H	RETHEXOUT:	MOV	B,A	RRC	RRC	RRC	RRC	CALL	$+4	MOV	A,B	ANI	15	CPI	10	JC	$+5	ADI	7	ADI	30H	MOV	C,A	JMP	PRINTCPRINTC:	PUSH	H	PUSH	D	PUSH	B	PUSH	PSW	MOV	E,C	MVI	C,2	CALL	5	POP	PSW	POP	B	POP	D	POP	H	RETMADR:	DW	200HTADR:	DW	0OPER1:	DW	0OPER2:	DW	0OPERT:	DW	0HEX:	DB	0WOP:	DB	0MOV:	DB	'MOV'BIC:	DB	'BIC'BIS:	DB	'BIS'ADD:	DB	'ADD',0SUB:	DB	'SUB',0CMP:	DB	'CMP'BIT:	DB	'BIT'SWAB:	DB	'SWAB',0EMT:	DB	'EMT',0TRAP:	DB	'TRAP',0JMP:	DB	'JMP',0JSR:	DB	'JSR',0SOB:	DB	'SOB ',0RTS:	DB	'RTS ',0NOP:	DB	'NOP',0CLF:	DB	'CLF ',0SEF:	DB	'SEF ',0??:	DB	'????',0SK0:	DB	')+',0SK1:	DB	'-(',0TAB6:	DB 'MUL DIV ASH ASHCXOR 'TAB5:	DB '    '	DB 'BR  BNE BEQ BGE BLT BGT '	DB 'BLE BPL BMI BHI BLOSBVC '	DB 'BVS BCC BCS 'TAB4:	DB 'MARKMFPIMTPISXT '	DB 'MTPSMFPDMTPDMFPS'TAB3:	DB 'RORROLASRASL'TAB2:	DB 'CLRCOMINCDECNEGADCSBCTST'TAB1:	DB 'R0R1R2R3R4R5SPPC'TAB0:	DB 'HALTWAITRTI BPT IOT '	DB 'RESTRTT '