	ORG	100H	LXI	SP,100H	JMP	STARTPRINTC:	EQU	0F809HPRINT:	EQU	0F818HHEXOUT:	EQU	0F815HKEY:	EQU	0F803HMADR:	DW	5200HSTART:	LHLD	MADR	MVI	B,11	CALL	PAGE	SHLD	MADR	CALL	KEY	CPI	3	JZ	0	CPI	'A'	JNZ	START	CALL	BEGIN	SHLD	MADR	JMP	STARTPAGE:	PUSH	B	MVI	C,10	CALL	PRINTC	CALL	PRINTH	CALL	TABUL	XRA	A	STA	IND	STA	SMPAGE00:	MOV	A,M	CPI	40H	JC	PAGE10	CPI	80H	JNC	PAGE10	INX	H	PUSH	H	PUSH	PSW	LXI	H,LD	CALL	PRINT	CALL	TABUL	POP	PSW	CALL	REGPAGE99:	POP	H	POP	B	LDA	SM	ANA	A	JZ	$+4	INX	H	DCR	B	JNZ	PAGE	RETREG:	PUSH	PSW	RRC	RRC	RRC	CALL	REG04	CALL	ZAPAT	POP	PSWREG04:	ANI	7	CPI	6	JZ	REG10	MVI	D,0	MOV	E,A	LXI	H,TAB0	DAD	D	MOV	C,M	CALL	PRINTC	RETZAPAT:	MVI	C,','	JMP	PRINTCREG10:	LDA	IND	LXI	H,RHL	ANA	A	JZ	REG11	STA	SM	LHLD	DOBRREG11:	MVI	C,'('	CALL	PRINTC	CALL	PRINT	LDA	IND	ANA	A	JZ	REG12	LDA	SMECH	MVI	C,'+'	ORA	A	JP	$+5	MVI	C,'-'	CALL	PRINTC	CALL	HEXOUTREG12:	MVI	C,')'	JMP	PRINTCPAGE10:	CPI	40H	JNC	PAGE20	ANI	7	CPI	6	JNZ	PAGE20	PUSH	H	LXI	H,LD	CALL	PRINT	CALL	TABUL	XTHL	MOV	A,M	XTHL	RRC	RRC	RRC	CALL	REG04	CALL	ZAPAT	XTHL	INX	H	MOV	A,M	INX	H	MOV	E,M	XTHL	MOV	D,A	LDA	IND	ANA	A	MOV	A,D	JZ	$+4	MOV	A,E	CALL	HEXOUT	JMP	PAGE99PAGE20:	MOV	A,M	CPI	40H	JNC	PAGE30	ANI	15	CPI	9	JZ	PAGE22	CPI	3	JZ	PAGE24	CPI	11	JZ	PAGE26	DCR	A	JNZ	PAGE30	MOV	A,M	INX	H	MOV	E,M	INX	H	MOV	D,M	INX	H	PUSH	H	PUSH	D	PUSH	PSW	LXI	H,LD	CALL	PRINT	CALL	TABUL	POP	PSW	RRC	RRC	RRC	RRC	CALL	REG1	CALL	ZAPAT	POP	H	CALL	PRINTH	JMP	PAGE99PAGE22:	MOV	A,M	INX	H	PUSH	H	PUSH	PSW	LXI	H,ADD	CALL	PRINT	CALL	TABUL	LXI	H,RHL	LDA	IND	ANA	A	JZ	PAG22E	LHLD	DOBRPAG22E:	CALL	PRINT	CALL	ZAPATPAGE23:	POP	PSW	RRC	RRC	RRC	RRC	CALL	REG1	JMP	PAGE99PAGE24:	MOV	A,M	INX	H	PUSH	H	PUSH	PSW	LXI	H,INC	CALL	PRINTPAGE25:	CALL	TABUL	JMP	PAGE23PAGE26:	MOV	A,M	INX	H	PUSH	H	PUSH	PSW	LXI	H,DEC	CALL	PRINT	JMP	PAGE25REG1:	ANI	3	CPI	2	CZ	REG100	RLC	MOV	E,A	MVI	D,0	LXI	H,TAB1	DAD	D	MOV	C,M	CALL	PRINTC	INX	H	MOV	C,M	JMP	PRINTCREG100:	MOV	E,A	LDA	IND	ANA	A	MOV	A,E	RZ	POP	H	LHLD	DOBR	JMP	PRINTPAGE30:	MOV	A,M	CPI	40H	JNC	PAGE40	ANI	7	CPI	5	JNZ	PAGE32	PUSH	H	LXI	H,DEC	CALL	PRINT	CALL	TABUL	JMP	PAGE34PAGE32:	CPI	4	JNZ	PAGE40	PUSH	H	LXI	H,INC	CALL	PRINT	CALL	TABULPAGE34:	XTHL	MOV	A,M	INX	H	XTHL	RRC	RRC	RRC	CALL	REG04	JMP	PAGE99PAGE40:	LXI	D,TAB3	MVI	C,0	MVI	B,13PAGE42:	LDAX	D	CMP	M	JZ	PAGE44	INX	D	INR	C	DCR	B	JNZ	PAGE42	JMP	PAGE50PAGE44:	INX	H	PUSH	H	LXI	H,TAB4	MOV	A,C	RLC	ADD	C	MOV	E,A	MVI	D,0	DAD	D	MVI	B,3PAGE46:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	PAGE46	JMP	PAGE99PAGE50:	MOV	A,M	CPI	80H	JC	PAGE60	CPI	0C0H	JNC	PAGE60	INX	H	PUSH	H	PUSH	PSW	RRC	RRC	RRC	ANI	7	MOV	C,A	RLC	ADD	C	MOV	E,A	MVI	D,0	LXI	H,TAB5	DAD	D	MVI	B,3PAGE52:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	PAGE52	CALL	TABUL0	POP	PSW	CALL	REG04	JMP	PAGE99PAGE60:	MOV	A,M	CPI	0C0H	JC	PAGE80	ANI	0F7H	MOV	C,A	ANI	7	CPI	6	JNZ	PAGE62	MOV	A,C	ANI	30H	RRC	RRC	RRC	RRC	MOV	E,A	MOV	A,M	ANI	8	MOV	D,A	INX	H	MOV	B,M	INX	H	PUSH	H	LXI	H,TAB5	PUSH	B	LXI	B,3	MOV	A,D	ANA	A	JZ	$+4	DAD	B	MOV	A,E	RLC	MOV	D,A	RLC	ADD	D	MOV	E,A	MVI	D,0	DAD	D	MVI	B,3PAGE61:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	PAGE61	CALL	TABUL0	POP	B	MOV	A,B	CALL	HEXOUT	JMP	PAGE99PAGE62:	MOV	A,M	ANI	8	RRC	MOV	D,A	MOV	A,C	ANI	30H	RRC	RRC	RRC	RRC	MOV	E,A	MOV	A,C	ANI	7	CPI	2	JZ	PAGE64	CPI	4	JZ	PAGE66	ANA	A	JNZ	PAGE70	MOV	A,E	ORA	D	RLC	MOV	E,A	MVI	D,0	INX	H	PUSH	H	LXI	H,RET	CALL	PRINT	CALL	TABUL	LXI	H,TAB6	DAD	D	MOV	C,M	CALL	PRINTC	INX	H	MOV	C,M	CALL	PRINTC	JMP	PAGE99PAGE64:	PUSH	H	LXI	H,JP	XTHLPAGE65:	MOV	A,E	ORA	D	INX	H	MOV	E,M	INX	H	MOV	D,M	INX	H	POP	B	PUSH	H	PUSH	D	RLC	MOV	E,A	MVI	D,0	PUSH	B	POP	H	CALL	PRINT	CALL	TABUL	LXI	H,TAB6	DAD	D	MOV	C,M	CALL	PRINTC	INX	H	MOV	C,M	CALL	PRINTC	CALL	ZAPAT	POP	H	CALL	PRINTH	JMP	PAGE99PAGE66:	PUSH	H	LXI	H,CALL	XTHL	JMP	PAGE65PAGE70:	CPI	7	JZ	PAGE74	MOV	A,M	ANI	15	CPI	5	JZ	PAGE72	CPI	1	JNZ	PAGE76	PUSH	H	LXI	H,POP	XTHLPAGE71:	MOV	D,M	INX	H	XTHL	CALL	PRINT	CALL	TABUL	MOV	A,D	RRC	RRC	RRC	RRC	CALL	REG2	JMP	PAGE99PAGE72:	PUSH	H	LXI	H,PUSH	XTHL	JMP	PAGE71REG2:	ANI	3	CPI	2	CZ	REG100	RLC	MOV	E,A	MVI	D,0	LXI	H,TAB7	DAD	D	MOV	C,M	CALL	PRINTC	INX	H	MOV	C,M	JMP	PRINTCPAGE74:	MOV	A,M	RRC	RRC	RRC	ANI	7	MOV	D,A	INX	H	PUSH	H	LXI	H,RST	CALL	PRINT	CALL	TABUL	MOV	A,D	RLC	RLC	ADD	A	CALL	HEXOUT	JMP	PAGE99PAGE76:	MOV	A,M	CPI	0D3H	JZ	PAG710	CPI	0DBH	JZ	PAG714	CPI	0E3H	JZ	PAG720	CPI	0EBH	JZ	PAG724	CPI	0F9H	JZ	PAG726	CPI	0E9H	JZ	PAG730	CPI	0C3H	JZ	PAG700	CPI	0CDH	JNZ	PAGE80PAG700:	INX	H	MOV	E,M	INX	H	MOV	D,M	INX	H	PUSH	H	CPI	0C3H	LXI	H,JP	JZ	PAG702	LXI	H,CALLPAG702:	CALL	PRINT	CALL	TABUL	XCHG	CALL	PRINTH	JMP	PAGE99PAG710:	INX	H	MOV	D,M	INX	H	PUSH	H	LXI	H,OUTPAG712:	CALL	PRINT	CALL	TABUL	MOV	A,D	CALL	HEXOUT	JMP	PAGE99PAG714:	INX	H	MOV	D,M	INX	H	PUSH	H	LXI	H,IN	JMP	PAG712PAG720:	INX	H	PUSH	H	LXI	D,SPSPAG721:	LXI	H,EX	CALL	PRINT	CALL	TABUL	XCHG	CALL	PRINTPAG722:	CALL	ZAPAT	LXI	H,RHL	LDA	IND	ANA	A	JZ	PAG723	LHLD	DOBRPAG723:	CALL	PRINT	JMP	PAGE99PAG724:	INX	H	PUSH	H	LXI	D,RDE	JMP	PAG721PAG726:	INX	H	PUSH	H	LXI	H,LD	CALL	PRINT	CALL	TABUL	LXI	H,RSP	CALL	PRINT	JMP	PAG722PAG730:	INX	H	PUSH	H	LXI	H,JP	CALL	PRINT	CALL	TABUL	LXI	H,RHL	LDA	IND	ANA	A	JZ	PAG732	LHLD	DOBRPAG732:	MVI	C,'('	CALL	PRINTC	CALL	PRINT	MVI	C,')'	CALL	PRINTC	JMP	PAGE99PAGE80:	MOV	A,M	CPI	0CBH	JZ	CB	CPI	0DDH	JZ	DD	CPI	0EDH	JZ	ED	CPI	0FDH	JZ	FD	ANI	7	CPI	2	JNZ	PAGE90	MOV	A,M	MVI	D,80HPAGE82:	CPI	2	JZ	PAG800	CPI	12H	JZ	PAG810	CPI	22H	JZ	PAG820	CPI	32H	JZ	PAG830	MVI	D,1	ANI	0F7H	JMP	PAGE82PAG800:	INX	H	PUSH	H	LXI	H,LD	CALL	PRINT	CALL	TABUL	MOV	A,D	RAL	CALL	PAG802	CALL	ZAPAT	MOV	A,D	RAR	CALL	PAG802	JMP	PAGE99PAG802:	JNC	PAG804	LXI	H,BC	JMP	PRINTPAG804:	MVI	C,'A'	JMP	PRINTCPAG810:	INX	H	PUSH	H	LXI	H,LD	CALL	PRINT	CALL	TABUL	MOV	A,D	RAL	CALL	PAG812	CALL	ZAPAT	MOV	A,D	RAR	CALL	PAG812	JMP	PAGE99PAG812:	JNC	PAG804	LXI	H,DE	JMP	PRINTPAG820:	INX	H	MOV	C,M	INX	H	MOV	B,M	INX	H	PUSH	H	PUSH	B	LXI	H,LD	CALL	PRINT	CALL	TABUL	POP	H	MOV	A,D	RAL	CALL	PAG822	CALL	ZAPAT	MOV	A,D	RAR	CALL	PAG822	JMP	PAGE99PAG822:	JC	PAG824	PUSH	H	LXI	H,RHL	LDA	IND	ANA	A	JZ	PAG823	LHLD	DOBRPAG823:	CALL	PRINT	POP	H	RETPAG824:	MVI	C,'('	CALL	PRINTC	CALL	PRINTH	MVI	C,')'	JMP	PRINTCPAG830:	INX	H	MOV	C,M	INX	H	MOV	B,M	INX	H	PUSH	H	PUSH	B	LXI	H,LD	CALL	PRINT	CALL	TABUL	POP	H	MOV	A,D	RAL	CALL	PAG832	CALL	ZAPAT	MOV	A,D	RAR	CALL	PAG832	JMP	PAGE99PAG832:	JC	PAG824	MVI	C,'A'	JMP	PRINTCPAGE90:	MOV	A,M	CPI	8	JNZ	PAGE92	INX	H	PUSH	H	LXI	H,EX	CALL	PRINT	LXI	H,AF	PUSH	H	CALL	PRINT	CALL	ZAPAT	POP	H	CALL	PRINT	MVI	C,27H	CALL	PRINTC	JMP	PAGE99PAGE92:	INX	H	MOV	E,M	INX	H	PUSH	H	CPI	10H	JNZ	PAGE94	LXI	H,DJNZPAGE91:	CALL	PRINT	CALL	TABULPAGE93:	POP	H	PUSH	H	MVI	D,0	MOV	A,E	ANA	A	JP	$+5	MVI	D,-1	DAD	D	CALL	PRINTH	JMP	PAGE99PAGE94:	CPI	18H	JNZ	PAGE96	LXI	H,JR	JMP	PAGE91PAGE96:	MOV	B,A	ANI	10H	PUSH	PSW	MOV	A,B	ANI	8	PUSH	PSW	LXI	H,JR	CALL	PRINT	CALL	TABUL	POP	PSW	MVI	C,'N'	JNZ	$+6	CALL	PRINTC	MVI	C,'Z'	POP	PSW	JZ	$+5	MVI	C,'C'	CALL	PRINTC	CALL	ZAPAT	JMP	PAGE93CB:	INX	H	MOV	A,M	CPI	30H	JC	CB10	CPI	38H	JC	CB30CB10:	CPI	40H	JNC	CB20	RRC	RRC	RRC	ANI	7	MOV	C,A	RLC	ADD	C	MOV	E,A	MVI	D,0	MOV	A,M	INX	H	PUSH	H	PUSH	PSW	LXI	H,TAB8	DAD	D	MVI	B,3CB12:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	CB12	CALL	TABUL0	POP	PSW	CALL	REG04	XRA	A	STA	SM	JMP	PAGE99CB20:	ANI	0C0H	RLC	RLC	DCR	A	MOV	D,M	INX	H	PUSH	H	MOV	C,A	RLC	ADD	C	MOV	C,A	MVI	B,0	LXI	H,TAB9	DAD	B	MVI	B,3CB22:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	CB22	CALL	TABUL0	MOV	A,D	RRC	RRC	RRC	ANI	7	ADI	30H	MOV	C,A	CALL	PRINTC	CALL	ZAPAT	MOV	A,D	CALL	REG04	XRA	A	STA	SM	JMP	PAGE99CB30:	PUSH	H	LXI	H,??	CALL	PRINT	POP	H	DCX	H	MOV	A,M	CALL	HEXOUT	MVI	C,10	CALL	PRINTC	INX	H	CALL	PRINTH	CALL	TABUL	JMP	ZAGLDD:	LXI	D,IXDD10:	INX	H	INX	H	MOV	A,M	STA	SMECH	DCX	H	XCHG	SHLD	DOBR	XCHG	MVI	A,1	STA	IND	MOV	A,M	CPI	0CBH	JNZ	PAGE00	INX	H	MOV	A,M	STA	SMECH	JMP	CBFD:	LXI	D,IY	JMP	DD10ED:	INX	H	MOV	A,M	CPI	40H	JC	CB30	CPI	0C0H	JNC	CB30	CPI	0A0H	JC	ED10	MOV	D,A	ANI	7	CPI	4	JNC	CB30	MOV	E,A	MOV	A,D	ANI	8	RRC	ORA	E	MOV	E,A	MOV	A,D	ANI	10H	RRC	ORA	E	RLC	RLC	MOV	E,A	MVI	D,0	INX	H	PUSH	H	LXI	H,TAB10	DAD	D	MVI	B,4ED02:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	ED02	JMP	PAGE99ED10:	PUSH	H	LXI	D,TAB11	MVI	B,6ED12:	LDAX	D	CMP	M	JZ	ED14	INX	D	DCR	B	JNZ	ED12	POP	H	JMP	ED20ED14:	POP	H	INX	H	PUSH	H	MVI	A,6	SUB	B	RLC	RLC	MOV	E,A	MVI	D,0	LXI	H,TAB12	DAD	D	MVI	B,4ED16:	MOV	C,M	CALL	PRINTC	INX	H	DCR	B	JNZ	ED16	JMP	PAGE99ED20:	MOV	B,M	MOV	A,B	ANI	7	CPI	2	JNZ	ED22	MOV	A,B	ANI	8	INX	H	PUSH	H	LXI	H,SBC	JZ	ED21	LXI	H,ADCED21:	CALL	PRINT	CALL	TABUL	LXI	H,RHL	CALL	PRINT	CALL	ZAPAT	MOV	A,B	RRC	RRC	RRC	RRC	CALL	REG1	JMP	PAGE99ED22:	CPI	3	JNZ	ED30	MOV	A,B	ANI	8	MVI	D,80H	JZ	ED23	MVI	D,1ED23:	MOV	A,B	RRC	RRC	RRC	RRC	ANI	3	RLC	PUSH	H	PUSH	D	MOV	E,A	MVI	D,0	LXI	H,TAB13	DAD	D	MOV	E,M	INX	H	MOV	D,M	XCHG	SHLD	DOBR	MVI	A,1	STA	IND	POP	D	POP	H	JMP	PAG820ED30:	ANA	A	JZ	ED31	CPI	1	JNZ	ED40	LXI	D,OUT	JMP	ED32ED31:	LXI	D,INED32:	INX	H	PUSH	H	XCHG	MOV	A,B	ANI	7	MVI	D,0	JZ	ED33	INR	DED33:	PUSH	D	CALL	PRINT	CALL	TABUL	MOV	A,B	RRC	RRC	RRC	ANI	7	MVI	D,0	MOV	E,A	LXI	H,TAB0	DAD	D	POP	D	MOV	E,M	DCR	D	JNZ	ED34	LXI	H,RC	CALL	PRINT	CALL	ZAPAT	MOV	C,E	CALL	PRINTC	JMP	PAGE99ED34:	MOV	C,E	CALL	PRINTC	CALL	ZAPAT	LXI	H,RC	CALL	PRINT	JMP	PAGE99ED40:	CPI	7	JNZ	ED50	MOV	A,B	CPI	60H	JNC	CB30	INX	H	PUSH	H	LXI	H,LD	CALL	PRINT	CALL	TABUL	MOV	A,B	ANI	8	MVI	E,'I'	JZ	ED41	MVI	E,'R'ED41:	MOV	A,B	ANI	0F0H	CPI	40H	JNZ	ED42	MOV	C,E	CALL	PRINTC	CALL	ZAPAT	MVI	C,'A'	CALL	PRINTC	JMP	PAGE99ED42:	MVI	C,'A'	CALL	PRINTC	CALL	ZAPAT	MOV	C,E	CALL	PRINTC	JMP	PAGE99ED50:	MOV	A,B	MVI	E,'0'	CPI	46H	JZ	ED52	INR	E	CPI	56H	JZ	ED52	INR	E	CPI	5EH	JNZ	CB30ED52:	INX	H	PUSH	H	LXI	H,IM	CALL	PRINT	CALL	TABUL	MOV	C,E	CALL	PRINTC	JMP	PAGE99ZAGL:	PUSH	H	LXI	H,??	CALL	PRINT	XTHL	MOV	A,M	INX	H	XTHL	CALL	HEXOUT	JMP	PAGE99BEGIN:	MVI	C,13	CALL	PRINTC	CALL	PRINTHBEG10:	CALL	KEY	CPI	13	RZ	CPI	30H	JC	BEG10	CPI	'G'	JNC	BEG10	CPI	3AH	JC	BEG12	CPI	'A'	JC	BEG10	SUI	7BEG12:	SUI	30H	CALL	DOB	JMP	BEGINDOB:	MOV	D,A	MOV	A,L	RLC	RLC	RLC	RLC	MOV	E,A	ANI	0F0H	ORA	D	MOV	L,A	MOV	A,H	RLC	RLC	RLC	RLC	ANI	0F0H	MOV	D,A	MOV	A,E	ANI	15	ORA	D	MOV	H,A	RETTABUL0:	MVI	C,20H	CALL	PRINTCTABUL:	MVI	C,20H	CALL	PRINTC	JMP	PRINTCPRINTH:	MOV	A,H	CALL	HEXOUT	MOV	A,L	JMP	HEXOUT??:	DB	'??=',0LD:	DB	'LD  ',0DEC:	DB	'DEC ',0INC:	DB	'INC ',0ADD:	DB	'ADD ',0RET:	DB	'RET ',0JP:	DB	'JP  ',0CALL:	DB	'CALL',0PUSH:	DB	'PUSH',0POP:	DB	'POP ',0RST:	DB	'RST ',0OUT:	DB	'OUT ',0IN:	DB	'IN  ',0DJNZ:	DB	'DJNZ',0JR:	DB	'JR  ',0ADC:	DB	'ADC ',0SBC:	DB	'SBC ',0IM:	DB	'IM  ',0RHL:	DB	'HL',0RSP:	DB	'SP',0SPS:	DB	'(SP)',0RDE:	DB	'DE',0RBC:	DB	'BC',0RC:	DB	'(C)',0DE:	DB	'(DE)',0BC:	DB	'(BC)',0AF:	DB	'AF',0IX:	DB	'IX',0IY:	DB	'IY',0SMECH:	DB	0SM:	DB	0IND:	DB	0DOBR:	DW	0EX:	DB	'EX  ',0TAB0:	DB 'BCDEHLMA'TAB1:	DB 'BCDEHLSP'TAB3:	DB 0,7,17H,27H,37H,15,1FH,2FH,3FH	DB 0F3H,0FBH,0C9H,0D9HTAB4:	DB 'NOPRLCRLADAASCFRRCRRACPLCCFDI EI RETEXX'TAB5:	DB 'ADDADCSUBSBCANDXOROR CP 'TAB6:	DB 'NZNCPOP Z C PEM 'TAB7:	DB 'BCDEHLAF'TAB8:	DB 'RLCRRCRL RR SLASRA   SRL'TAB9:	DB 'BITRESSET'TAB10:	DB 'LDI CPI INI OUTILDD CPD IND OUTDLDIRCPIR'	DB 'INIROTIRLDDRCPDRINDROTDR'TAB11:	DB 44H,45H,4DH,67H,6FH,70HTAB12:	DB 'NEG RETNRETIRRD RLD INF 'TAB13:	DW RBC,RDE,RHL,RSP