	ORG	1D00H	LXI	SP,8000H	JMP	START	JMP	COPYGAMEND:	LXI	H,5400H	SHLD	1	JMP	0PRINTD:	EQU	138HPRNTC:	EQU	129HHXOUT:	EQU	135HSCR0:	EQU	189HSCR2:	EQU	18CHINIT:	EQU	120HCOLOR:	EQU	156HPLOT:	EQU	13EHLINE:	EQU	141HINKEY:	EQU	13BHSELJS:	EQU	10HPALETG:	DB 0,192,7,12,197,34,54,255	DB 0,192,7,12,197,34,54,255PALET0:	DB 0,192,7,12,197,34,54,255	DB -1,-1,-1,-1,-1,-1,-1,-1PALET1:	DB 0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1START:	MVI	A,1	STA	WLEVEL	MVI	A,50	STA	LIFE	LDA	98EH	STA	INV	LDA	SELJS	DCR	A	MVI	A,93H	JZ	$+5	MVI	A,81H	OUT	4	CALL	SETLEV	LXI	H,0	SHLD	SCORE	LXI	H,3030H	SHLD	SCORE0-3	SHLD	SCORE0-1	LXI	H,60HST10:	MOV	M,H	INR	L	JNZ	ST10	CALL	INIT	DI	LXI	H,DYSPLY	SHLD	39H	EI	MVI	A,15	CALL	SCR2	CALL	CLSBEGS00:	LXI	SP,8000H	LXI	H,CHE24	SHLD	1	CALL	PECHAT	CALL	LEVS	LXI	H,BABCHS	SHLD	ABABCH	LXI	H,MINS	SHLD	AMINA	XRA	A	STA	WBABCH	STA	WMINA	CALL	LEVEL	LXI	H,PALETG	SHLD	COLORS	LXI	H,SETPAL	MVI	M,16	XRA	A	CMP	M	JNZ	$-1	LDA	WMINA	MOV	C,A	LDA	WBABCH	ORA	C	JZ	GAMEND	XRA	A	STA	GOBOLD	MVI	A,6	STA	TIMER	JMP	BEGIN+3BEGIN:	CALL	CHANGE	XRA	A	STA	WALMAZ	IN	1	ANI	0E0H	JZ	AL20	LDA	KEYS	INR	A	JZ	NOGOB	LDA	CTLKEY	MVI	B,-1	MVI	C,1	CPI	0EFH	JZ	DWIG	MVI	B,1	MVI	C,2	CPI	0BFH	JZ	DWIG	MVI	B,-10H	MVI	C,3	CPI	0DFH	JZ	DWIG	MVI	B,10H	MVI	C,4	CPI	7FH	JZ	DWIG	JMP	NOGOBSETLEV:	IN	1	ANI	40H	RNZ	LXI	D,PALETG	CALL	SCR0	MVI	C,13	CALL	PRNTC	MVI	C,1FH	CALL	PRNTC	MVI	A,7	CALL	COLOR	LXI	H,STRSTL	CALL	PRINTDSTLV10:	LDA	WLEVEL	CALL	DES	CALL	HXOUT	MVI	C,8	CALL	PRNTC	MVI	C,8	CALL	PRNTCSTLV12:	CALL	INKEY	CPI	-1	JZ	STLV12	CPI	19H	JZ	STLV13	CPI	1AH	JZ	STLV14	CPI	20H	JNZ	STLV12	RETSTLV13:	LXI	H,WLEVEL	INR	M	MOV	A,M	CPI	65	JC	STLV10	MVI	M,1	JMP	STLV10STLV14:	LXI	H,WLEVEL	DCR	M	JNZ	STLV10	MVI	M,64	JMP	STLV10PECHAT:	MVI	A,8	CALL	SCR2	CALL	CLS	MVI	A,8	CALL	COLOR	LXI	B,5020H	MVI	A,2	CALL	PLOT	LXI	B,402H	MVI	A,3	CALL	LINE	LXI	H,STR4	CALL	PRINTD	LXI	B,7620H	MVI	A,2	CALL	PLOT	LXI	B,401H	MVI	A,3	CALL	LINE	LXI	H,STR2	CALL	PRINTD	LDA	WLEVEL	CALL	DES	CALL	HXOUT	LXI	H,STR3	CALL	PRINTD	LDA	LIFE	CALL	DES	CALL	HXOUT	LXI	H,PALET0	SHLD	COLORS	LXI	H,SETPAL	MVI	M,16	XRA	A	CMP	M	JNZ	$-1	LXI	B,0	CALL	ZAD	LXI	H,PALET1	SHLD	COLORS	LXI	H,SETPAL	MVI	M,16	XRA	A	CMP	M	JNZ	$-1	LXI	B,0	CALL	ZAD	DI	XRA	A	OUT	3	MOV	L,APEC10:	MVI	H,80H	XRA	APEC20:	MOV	M,A	INR	H	MOV	M,A	INR	H	MOV	M,A	INR	H	MOV	M,A	INR	H	JNZ	PEC20	LXI	B,150H	CALL	ZAD	IN	3	DCR	A	OUT	3	DCR	L	JNZ	PEC10	EI	RETDES:	LXI	B,16H	MOV	D,A	ANI	0F0H	JZ	DES20	RRC	RRC	RRC	RRC	MOV	E,ADES10:	MOV	A,B	ADD	C	DAA	MOV	B,A	DCR	E	JNZ	DES10DES20:	MOV	A,D	ANI	0FH	MOV	C,A	XRA	A	MOV	A,C	DAA	ADD	B	DAA	RETCLS:	MVI	C,0DH	CALL	PRNTC	MVI	C,1FH	JMP	PRNTCALMEND:	LXI	H,LIFE	INR	M	LXI	H,WLEVEL	INR	M	MOV	A,M	CPI	65	JNZ	ALME10	DCR	M	MVI	A,15	CALL	SCR2	CALL	LIST	CALL	CLS	LXI	H,MEL0	LXI	D,MEL1	LXI	B,0	CALL	PLAYAL00:	MVI	A,8	CALL	COLOR	LXI	H,60H	SHLD	COLORS	MVI	A,16	STA	SETPAL	LXI	B,6020H	MVI	A,2	CALL	PLOT	LXI	B,603H	MVI	A,3	CALL	LINE	LXI	H,STR0	CALL	PRINTD	LXI	H,PALET1	SHLD	COLORS	MVI	A,16	STA	SETPALAL10:	LDA	KEYS	INR	A	JZ	AL10AL20:	LXI	SP,8000H	JMP	GAMENDALME10:	EI	CALL	PLAYEN	LXI	H,PLPER	LXI	D,0	LXI	B,0	CALL	PLAYALME20:	CALL	VPLAY	ANA	A	JNZ	ALME20	JMP	BEGS00CHANGE:	CALL	CHBLD1	CALL	SCANER	CALL	CHALM	LXI	H,TIMERCHG10:	MOV	A,M	ANA	A	JP	CHG10	MVI	M,6	MVI	A,54	STA	PALETG+4	MVI	A,16	STA	SETPAL	CALL	CHBLD2	CALL	CHBLD3	CALL	SCANR2	CALL	CHBLD4	CALL	CHOHOT	CALL	SCANR3	MVI	A,197	STA	PALETG+4	MVI	A,16	STA	SETPAL	RETCHBLD3:	LDA	POLBLD	MVI	B,-10H	ADD	B	CALL	WHO	ANA	A	RNZ	MVI	A,1	STA	ZERO	RETCHBLD4:	LDA	POLBLD	MOV	B,A	ANI	0F0H	RZ	MOV	A,B	MOV	C,A	MVI	B,-10H	ADD	B	CALL	WHO	ANA	A	RZ	CPI	4	JC	CHB40L	CPI	8	JNC	CHB40L	XRA	A	STA	ZERO	RETCHB40L:	LDA	ZERO	ANA	A	RZ	JMP	CHE20CHOHOT:	LXI	H,WBABCH	SHLD	CHOHT1+1	LXI	H,BABCHS	SHLD	CHHTW1	LXI	H,BBCHS	SHLD	CHHTW2	LXI	H,BABCHP	SHLD	CHHT45+1	MVI	A,2	STA	CHHT42+1	STA	CHHTOP+1	CALL	CHOHT1	LXI	H,WMINA	SHLD	CHOHT1+1	LXI	H,MINS	SHLD	CHHTW1	LXI	H,MINES	SHLD	CHHTW2	LXI	H,MINAP	SHLD	CHHT45+1	MVI	A,3	STA	CHHT42+1	STA	CHHTOP+1	JMP	CHOHT1CHOHT1:	LDA	WBABCH	ANA	A	RZ	LHLD	CHHTW2	PUSH	H	POP	B	LHLD	CHHTW1CHHT05:	PUSH	PSW	PUSH	H	MOV	E,M	MOV	A,M	CALL	WHOCHHTOP:	CPI	2	JNZ	CHHT50	PUSH	B	LDAX	B	MOV	C,A	CALL	OHTNK0	JNZ	CHHT15	MOV	A,C	CALL	CHHT0H	JNZ	CHHT40CHHT15:	CALL	OHTNK1	JNZ	CHHT25	MOV	A,C	CALL	CHHT0H	JNZ	CHHT40CHHT25:	CALL	OHTNK2	JNZ	CHHT65	MOV	A,C	CALL	CHHT0H	JNZ	CHHT40CHHT65:	MOV	A,C	CPI	3	JNC	CHHT75	CALL	OHT500	CMP	C	JZ	CHHT67	CALL	OHTNK5	JNZ	CHHT35	CALL	OHT600	PUSH	D	CALL	CHHT60+1	CALL	OHT500CHHT69:	CALL	CHHT60+1	CALL	WHO	ANA	A	POP	D	JZ	CHHT35	CALL	OHTNK5	JMP	CHHT40CHHT67:	CALL	OHTNK5	JNZ	CHHT35	CALL	OHT600	PUSH	D	CALL	CHHT60+1	CALL	OHT400	JMP	CHHT69CHHT75:	CALL	OHT600	CMP	C	JZ	CHHT77	CALL	OHTNK6	JNZ	CHHT35	CALL	OHT500	PUSH	D	CALL	CHHT60+1	CALL	OHT600CHHT79:	CALL	CHHT60+1	CALL	WHO	ANA	A	POP	D	JZ	CHHT35	CALL	OHTNK6	JMP	CHHT40CHHT77:	CALL	OHTNK6	JNZ	CHHT35	CALL	OHT500	PUSH	D	CALL	CHHT60+1	CALL	OHT300	JMP	CHHT79CHHT35:	MOV	A,C	CALL	CHHT00	JZ	CHHT40	MOV	A,C	CPI	3	JNC	CHHT55	CALL	OHTNK5	JZ	CHHT40	CALL	OHTNK3	JZ	CHHT40	MOV	A,C	CPI	2	POP	B	MVI	A,1	JZ	CHHT04	MVI	A,2	JMP	CHHT04CHHT55:	CALL	OHTNK6	JZ	CHHT40	CALL	OHTNK4	JZ	CHHT40	MOV	A,C	CPI	4	POP	B	MVI	A,3	JZ	CHHT04	MVI	A,4	JMP	CHHT04CHHT0H:	CPI	3	JZ	CHHT1H	CPI	2	JNZ	CHHT2H	MOV	A,B	CPI	3	MOV	A,C	JNZ	CHHT2H	INR	A	JMP	CHHT2HCHHT1H:	MOV	A,B	CPI	2	MOV	A,C	JNZ	$+4	INR	ACHHT2H:	SUB	B	CPI	1	RZ	CPI	-1	RETCHHT04:	STAX	B	INX	B	JMP	CHHT50CHHT40:	MOV	A,B	POP	B	STAX	B	INX	B	MOV	D,A	MOV	A,E	PUSH	B	MVI	B,0	CALL	RECORD	POP	B	CALL	COORD	PUSH	D	LXI	D,PUSTP	CALL	COPY	POP	D	CALL	CHHT60	MOV	D,A	CALL	WHO	CPI	8	MOV	A,D	JNC	CHE10	PUSH	BCHHT42:	MVI	B,2	CALL	RECORD	POP	B	CALL	COORD	PUSH	DCHHT45:	LXI	D,BABCHP	CALL	COPY	POP	DCHHT50:	POP	H	MOV	M,E	INX	HCHHTOT:	POP	PSW	DCR	A	JNZ	CHHT05	RETCHHT60:	MOV	A,D	DCR	A	JZ	CHHT62	DCR	A	JZ	CHHT64	DCR	A	JZ	CHHT66	MVI	A,10HCHHT61:	ADD	E	MOV	E,A	RETCHHT62:	MVI	A,-1	JMP	CHHT61CHHT64:	MVI	A,1	JMP	CHHT61CHHT66:	MVI	A,-10H	JMP	CHHT61CHHTOO:	POP	H	INX	H	INX	B	JMP	CHHTOTCHHT00:	MVI	B,4	DCR	A	CZ	CHHT10	DCR	A	CZ	CHHT20	DCR	A	CZ	CHHT30	MOV	H,E	MOV	A,B	CALL	BACKS	RNZ	PUSH	D	MOV	D,B	CALL	CHHT60	POP	D	CALL	WHO	CPI	1	JZ	CHE20	CPI	8	CNC	CHH10T	ANA	A	RETCHH10T:	XRA	A	RETCHHT10:	MVI	B,1	RETCHHT20:	MVI	B,2	RETCHHT30:	MVI	B,3	RETOHTNK0:	CALL	OHOTNK	ANA	A	JZ	OHT010	CALL	CHHT00	RZOHT010:	MVI	A,1	ANA	A	RETOHTNK1:	CALL	OHT100	ANA	A	JZ	OHT010	JMP	CHHT00OHTNK2:	CALL	OHT200	ANA	A	JZ	OHT010	JMP	CHHT00OHTNK3:	CALL	OHT300	JMP	CHHT00OHTNK4:	CALL	OHT400	JMP	CHHT00OHTNK5:	CALL	OHT600	JMP	CHHT00OHTNK6:	CALL	OHT500	JMP	CHHT00OHT100:	LDA	POLBLD	MOV	H,A	ANI	0FH	MOV	D,A	MOV	A,E	ANI	0FH	CMP	D	MVI	L,1	JC	OHT110	MVI	L,-1OHT110:	PUSH	D	MOV	H,AOHT120:	MOV	A,L	ADD	H	MOV	H,A	CMP	D	JZ	OHT130	MOV	A,L	ADD	E	MOV	E,A	CALL	WHO	ANA	A	JZ	OHT120	POP	DOHT125:	XRA	A	RETOHT130:	MOV	A,L	ADD	E	MOV	E,A	LDA	POLBLD	ANI	0F0H	MOV	D,A	MOV	A,E	ANI	0F0H	CMP	D	MVI	H,16	JC	OHT140	MVI	H,-16OHT140:	PUSH	H	MOV	L,AOHT150:	MOV	A,H	ADD	L	MOV	L,A	CMP	D	JZ	OHT170	MOV	A,H	ADD	E	MOV	E,A	CALL	WHO	ANA	A	JZ	OHT150	POP	H	POP	D	XRA	A	RETOHT170:	POP	H	POP	D	MOV	A,L	CPI	1	JZ	OHT180	MVI	A,1	CMP	C	JNZ	OHT125	RETOHT180:	MVI	A,2	CMP	C	JNZ	OHT125	RETOHT500:	LDA	POLBLD	ANI	0FH	MOV	D,A	MOV	A,E	ANI	0FH	CMP	D	MVI	A,2	RC	MVI	A,1	RETOHT400:	LDA	POLBLD	ANI	0FH	MOV	D,A	MOV	A,E	ANI	0FH	CMP	D	MVI	A,1	RC	MVI	A,2	RETOHT200:	LDA	POLBLD	ANI	0F0H	MOV	D,A	MOV	A,E	ANI	0F0H	CMP	D	MVI	L,16	JC	OHT210	MVI	L,-16OHT210:	PUSH	D	MOV	H,AOHT220:	MOV	A,L	ADD	H	MOV	H,A	CMP	D	JZ	OHT230	MOV	A,L	ADD	E	MOV	E,A	CALL	WHO	ANA	A	JZ	OHT220	POP	D	XRA	A	RETOHT230:	MOV	A,L	ADD	E	MOV	E,A	LDA	POLBLD	ANI	15	MOV	D,A	MOV	A,E	ANI	15	CMP	D	MVI	H,1	JC	OHT240	MVI	H,-1OHT240:	PUSH	H	MOV	L,AOHT250:	MOV	A,H	ADD	L	MOV	L,A	CMP	D	JZ	OHT270	MOV	A,H	ADD	E	MOV	E,A	CALL	WHO	ANA	A	JZ	OHT250	POP	H	POP	D	XRA	A	RETOHT270:	POP	H	POP	D	MOV	A,L	CPI	16	JZ	OHT280	MVI	A,3	CMP	C	JNZ	OHT125	RETOHT280:	MVI	A,4	CMP	C	JNZ	OHT125	RETOHT600:	LDA	POLBLD	ANI	0F0H	MOV	D,A	MOV	A,E	ANI	0F0H	CMP	D	MVI	A,4	RC	MVI	A,3	RETOHT300:	LDA	POLBLD	ANI	0F0H	MOV	D,A	MOV	A,E	ANI	0F0H	CMP	D	MVI	A,3	RC	MVI	A,4	RETOHOTNK:	LDA	POLBLD	MOV	H,A	ANI	0F0H	MOV	D,A	MOV	A,E	ANI	0F0H	CMP	D	JZ	OHOT10	MOV	A,H	ANI	0FH	MOV	D,A	MOV	A,E	ANI	0FH	CMP	D	JZ	OHOT20	XRA	A	RETOHOT10:	MOV	A,H	ANI	0FH	MOV	D,A	MOV	A,E	ANI	0FH	CMP	D	JZ	CHE20	MVI	L,1	JC	OHOT15	MVI	L,-1OHOT15:	PUSH	DOHOT17:	MOV	A,L	ADD	E	MOV	E,A	CMP	H	JZ	OHOT16	CALL	WHO	ANA	A	JZ	OHOT17	POP	D	XRA	A	RETOHOT16:	POP	D	MOV	A,L	CPI	1	JZ	OHOT18	MVI	A,1	RETOHOT18:	MVI	A,2	RETOHOT20:	MOV	A,H	ANI	0F0H	MOV	D,A	MOV	A,E	ANI	0F0H	CMP	D	MVI	L,16	JC	OHOT25	MVI	L,-16OHOT25:	PUSH	DOHOT27:	MOV	A,L	ADD	E	MOV	E,A	CMP	H	JZ	OHOT26	CALL	WHO	ANA	A	JZ	OHOT27	POP	D	XRA	A	RETOHOT26:	POP	D	MOV	A,L	CPI	16	JZ	OHOT28	MVI	A,3	RETOHOT28:	MVI	A,4	RETSCANER:	LXI	H,OLEVEL	MVI	B,16SCAN10:	MVI	C,16SCAN20:	MOV	A,M	CPI	4	CZ	SCAN30	CPI	5	CZ	SCANAL	INX	H	DCR	C	JNZ	SCAN20	DCR	B	JNZ	SCAN10	RETSCANR2:	LXI	H,OLEVEL	MVI	B,16SC10AN:	MVI	C,16SC20AN:	MOV	A,M	CPI	8	CZ	SC30AN	CPI	9	CZ	SC30AN	INX	H	DCR	C	JNZ	SC20AN	DCR	B	JNZ	SC10AN	RETSCANR3:	LXI	H,OLEVEL	MVI	B,16SCA10N:	MVI	C,16SCA20N:	MOV	A,M	CPI	8	CZ	SCA30N	CPI	9	CZ	SCA30N	INX	H	DCR	C	JNZ	SCA20N	DCR	B	JNZ	SCA10N	RETSCA30N:	SUI	4	MOV	M,A	PUSH	PSW	CALL	KOORD	MOV	D,A	ANI	0F0H	CPI	0F0H	JZ	SCA35N	MVI	A,10H	ADD	D	CALL	WHO	ANA	A	JZ	SCA36NSCA35N:	PUSH	H	PUSH	B	LXI	H,0	LXI	D,PLPAD	LXI	B,0	CALL	PLAY	POP	B	POP	HSCA36N:	POP	PSW	RETSC30AN:	PUSH	H	PUSH	PSW	CALL	KOORD	CALL	COORD	PUSH	H	LXI	D,8	DAD	D	LXI	D,PUSTP	CALL	COPY	POP	H	POP	PSW	PUSH	PSW	CPI	8	JZ	SC35AN	LXI	D,ALMAZPSC40AN:	CALL	COPY	POP	PSW	POP	H	RETSC35AN:	LXI	D,KAMENP	JMP	SC40ANSCANAL:	PUSH	PSW	LDA	WALMAZ	INR	A	STA	WALMAZ	POP	PSWSCAN30:	PUSH	PSW	MOV	A,B	CPI	1	JZ	SCAN32	POP	PSW	PUSH	B	PUSH	PSW	PUSH	H	LXI	D,16	DAD	D	MOV	A,M	ANA	A	JZ	SCAN50	MOV	A,C	CPI	16	JZ	SCAN35	POP	H	PUSH	H	DCX	H	MOV	A,M	ANA	A	JNZ	SCAN35	LXI	D,16	DAD	D	MOV	A,M	ANA	A	JZ	SCAN52SCAN35:	POP	H	PUSH	H	MOV	A,C	CPI	1	JZ	SCAN40	INX	H	MOV	A,M	ANA	A	JNZ	SCAN40	LXI	D,16	DAD	D	MOV	A,M	ANA	A	JZ	SCAN54SCAN40:	POP	H	POP	PSW	CPI	8	CNC	SCAN70	POP	B	RETSCAN32:	POP	PSW	MOV	A,M	CPI	8	CNC	SCAN70	RETSCAN70:	SUI	4	MOV	M,A	RETSCAN50:	CALL	SCAN90	DCR	B	JMP	SCAN56SCAN52:	CALL	SCAN90	DCR	B	INR	C	JMP	SCAN56SCAN54:	CALL	SCAN90	DCR	B	DCR	CSCAN56:	XCHG	POP	H	MOV	A,M	CPI	8	JNC	SCAN58	ADI	4SCAN58:	STAX	D	MVI	M,0	POP	PSW	PUSH	PSW	CALL	SCAN60	POP	PSW	POP	B	RETSCAN90:	PUSH	H	CALL	KOORD	CALL	COORD	LXI	D,PUSTP	CALL	COPY	POP	H	RETSCAN60:	PUSH	H	PUSH	PSW	CALL	KOORD	CALL	COORD	LXI	D,8	DAD	D	POP	PSW	CPI	4	JZ	SCAN65	CPI	8	JZ	SCAN65	LXI	D,ALMAZPSCAN62:	CALL	COPY	POP	H	RETSCAN65:	LXI	D,KAMENP	JMP	SCAN62CHBLD1:	LDA	GOBOLD	ANA	A	RZ	LDA	KIRPAD	ANA	A	JNZ	CHBL10CHBL5:	LDA	POLBLD	STA	PLBLD1	CALL	COORD	LXI	D,PUSTP	CALL	COPY	LDA	POLBLD	MOV	B,A	LDA	GOSHAG	ADD	B	STA	POLBLD	CALL	COORD	LDA	GOBOLD	DCR	A	CZ	CH01BL	DCR	A	CZ	CH02BL	DCR	A	CZ	CH03BL	DCR	A	CZ	CH04BL	SHLD	PLBLD0	JMP	COPYCHALM:	LDA	DECALM	ANA	A	RZ	XRA	A	STA	DECALM	LDA	WALMAZ	DCR	A	STA	WALMAZ	JZ	ALMEND	LXI	B,PLALM	LXI	D,0	LXI	H,0	CALL	PLAY	RETCHE10:	CALL	NINALM	POP	H	INX	H	PUSH	H	PUSH	D	PUSH	B	PUSH	PSW	LXI	H,SCORE0-1CHE15:	INR	M	MOV	A,M	CPI	3AH	JNZ	CHE16	MVI	M,30H	LDA	LIFE	INR	A	STA	LIFE	DCX	H	JMP	CHE15CHE16:	LXI	B,0	LXI	H,PLUB	LXI	D,0	CALL	PLAY	POP	PSW	POP	B	POP	D	POP	H	JMP	CHHTOTNINALM:	PUSH	H	PUSH	D	PUSH	B	PUSH	PSW	MOV	H,A	CALL	ONALM2	MVI	A,1	MOV	L,A	CALL	BACKS	JNZ	NALM10	CALL	ONEALMNALM10:	MVI	A,2	MOV	L,A	CALL	BACKS	JNZ	NALM20	CALL	ONEALMNALM20:	MVI	A,3	MOV	L,A	CALL	BACKS	JNZ	NALM30	CALL	ONEALMNALM30:	MVI	A,4	MOV	L,A	CALL	BACKS	JNZ	NALM40	CALL	ONEALMNALM40:	MVI	A,1	CALL	BACKS	JNZ	NALM60+1	PUSH	H	MVI	A,-1	ADD	H	MOV	H,A	MVI	A,3	MOV	L,A	CALL	BACKS	JNZ	NALM50	CALL	ONEALMNALM50:	MVI	A,4	MOV	L,A	CALL	BACKS	JNZ	NALM60	CALL	ONEALMNALM60:	POP	H	MVI	A,2	CALL	BACKS	JNZ	NALM80	MVI	A,1	ADD	H	MOV	H,A	MVI	A,3	MOV	L,A	CALL	BACKS	JNZ	NALM70	CALL	ONEALMNALM70:	MVI	A,4	MOV	L,A	CALL	BACKS	JNZ	NALM80	CALL	ONEALMNALM80:	POP	PSW	POP	B	POP	D	POP	H	RETONEALM:	MOV	E,H	MOV	A,L	CALL	CHHT60+1ONALM2:	MOV	B,A	CALL	WHO	CPI	1	MOV	A,B	JZ	CH20E	MVI	B,5	CALL	RECORD	PUSH	H	CALL	COORD	LXI	D,ALMAZP	CALL	COPY	POP	H	RETCH20E:	MVI	B,5	CALL	RECORDCHE20:	LDA	POLBLD	CALL	NINALM	EI	CALL	PLAYEN	LXI	H,PLCHK	LXI	B,0	LXI	D,0	CALL	PLAY	CALL	KOVRCHE22:	CALL	VPLAY	ANA	A	JNZ	CHE22CHE24:	LXI	H,LIFE	DCR	M	JNZ	BEGS00	MVI	A,15	CALL	SCR2	CALL	CLS	JMP	AL00LIST:	DI	XRA	A	STA	WMINA	STA	WBABCH	CALL	LEVEL	LXI	H,PALETG	SHLD	COLORS	EI	LXI	H,SETPAL	MVI	M,16	XRA	A	CMP	M	JNZ	$-1	LXI	D,PLLST	LXI	B,PLLST	LXI	H,PLLST	CALL	PLAYLIST10:	CALL	VPLAY	ANA	A	JNZ	LIST10	LXI	H,TIMER	MVI	M,20	XRA	A	CMP	M	JNZ	$-1	LXI	H,WLEVEL	DCR	M	RZ	CALL	LEVS	JMP	LISTLEVS:	LXI	H,TLEVLS-80H	LXI	D,80H	LDA	WLEVELLEVS10:	DAD	D	DCR	A	JNZ	LEVS10	SHLD	LEVELS	RETKOVR:	LXI	D,900H	MVI	B,0KOVR10:	CALL	RND	MOV	A,H	ORI	80H	CPI	0A0H	JNC	$+5	ADI	20H	MOV	H,A	MOV	M,B	INR	L	MOV	M,B	INR	L	MOV	M,B	INR	L	MOV	M,B	INR	L	MOV	M,B	INR	L	MOV	M,B	INR	L	MOV	M,B	INR	L	MOV	M,B	DCX	D	MOV	A,D	ORA	E	JNZ	KOVR10	RETRND:	LHLD	SW	MVI	C,16RND10:	MOV	A,H	DAD	H	ANI	60H	JPE	$+4	INX	H	DCR	C	JNZ	RND10	SHLD	SW	RETCHBLD2:	LDA	GOBOLD	ANA	A	JZ	CH2BLD	LHLD	PLBLD0	LXI	D,PUSTP	CALL	COPY	LDA	PLBLD1	MVI	B,0	CALL	RECORD	LDA	KIRPAD	ANA	A	JNZ	CH2BLD	LDA	POLBLD	CALL	WHO	ANA	A	JZ	CH2BLD	CPI	1	JZ	CH2BLD	CPI	5	JC	CHE20	CPI	8	JNC	CHE20CH2BLD:	LDA	POLBLD	MVI	B,1	CALL	RECORD	CALL	COORD	XRA	A	STA	KIRPAD	LDA	GOBOLD	ANA	A	CZ	CH10BL	DCR	A	CZ	CH11BL	DCR	A	CZ	CH12BL	DCR	A	CZ	CH13BL	DCR	A	CZ	CH14BL	JMP	COPYCH10BL:	LXI	D,BOLDRP	RETCH11BL:	LXI	D,BOLDR5	RETCH12BL:	LXI	D,BOLDR3	RETCH13BL:	LXI	D,BOLDR9	RETCH14BL:	LXI	D,BOLDR7	RETCH01BL:	INR	H	LXI	D,BOLDR4	RETCH02BL:	DCR	H	LXI	D,BOLDR2	RETCH03BL:	LXI	D,-8	DAD	D	LXI	D,BOLDR8	RETCH04BL:	LXI	D,8	DAD	D	LXI	D,BOLDR6	RETCHBL10:	LDA	POLBLD	MOV	B,A	LDA	GOSHAG	ADD	B	MVI	B,1	CALL	RECORD	MOV	B,A	CALL	COORD	LXI	D,PUSTP	CALL	COPY	LDA	KIRP	MOV	C,ACHBL15:	LDA	GOSHAG	ADD	B	MOV	B,A	CALL	COORD	LXI	D,KAMENP	CALL	COPY	MOV	A,B	CMP	C	JNZ	CHBL15	MOV	A,C	MVI	B,4	CALL	RECORD	JMP	CHBL5HDCMP:	MOV	A,H	CMP	D	RNZ	MOV	A,L	CMP	E	RETZAD:	DCX	B	MOV	A,B	ORA	C	JNZ	ZAD	RETNOGOB:	XRA	A	STA	GOBOLD	JMP	BEGINDWIG:	LDA	POLBLD	MOV	H,A	MOV	A,C	CALL	BACKS	JNZ	NOGOB	MOV	A,H	ADD	B	CALL	OPRED	ANA	A	JZ	NOGOB	MOV	A,B	STA	GOSHAG	MOV	A,C	STA	GOBOLD	JMP	BEGINBACKS:	DCR	A	JZ	BACK10	DCR	A	JZ	BACK20	DCR	A	JZ	BACK30	MOV	A,H	ANI	0F0H	CPI	0F0H	JZ	BACK40BACK50:	XRA	A	RETBACK40:	MVI	A,1	ANA	A	RETBACK10:	MOV	A,H	ANI	0FH	JZ	BACK40	JMP	BACK50BACK20:	MOV	A,H	ANI	0FH	CPI	0FH	JZ	BACK40	JMP	BACK50BACK30:	MOV	A,H	ANI	0F0H	JZ	BACK40	JMP	BACK50OPRED:	CALL	WHO	CPI	2	JZ	CHE20	CPI	3	JZ	CHE20	CPI	5	JZ	OPRBA	CPI	6	JZ	OPRB10	CPI	4	JZ	OPRB20	CPI	8	JNC	CHE20OPRB5:	MVI	A,1	RETOPRBA:	MVI	A,1	STA	DECALM	RETOPRB10:	XRA	A	RETOPRB20:	PUSH	H	MOV	A,H	ADD	B	MOV	H,AOPR22B:	MOV	A,C	CALL	BACKS	JNZ	OPR24B	MOV	A,H	ADD	B	MOV	H,A	CALL	WHO	CPI	4	JZ	OPR22B	ANA	A	JNZ	OPR24B	MVI	A,1	STA	KIRPAD	MOV	A,H	STA	KIRP	POP	H	JMP	OPRB5OPR24B:	POP	H	JMP	OPRB10WHO:	PUSH	H	PUSH	D	PUSH	B	CALL	WHO00	MOV	A,M	POP	B	POP	D	POP	H	RETRECORD:	PUSH	H	PUSH	D	PUSH	PSW	PUSH	B	CALL	WHO00	POP	B	MOV	M,B	POP	PSW	POP	D	POP	H	RETWHO00:	LXI	H,OLEVEL	MOV	B,A	ANI	0FH	MOV	C,A	MOV	A,B	ANI	0F0H	RLC	RLC	RLC	RLC	LXI	D,16WHO10:	ANA	A	JZ	WHO20	DAD	D	DCR	A	JMP	WHO10WHO20:	MOV	A,CWHO30:	ANA	A	RZ	INX	H	DCR	A	JMP	WHO30WHO2:	LXI	D,-1COORD:	PUSH	D	PUSH	B	LXI	H,VIDEO	MOV	B,A	ANI	0FHCOOR10:	ANA	A	JZ	COOR20	INR	H	INR	H	DCR	A	JMP	COOR10COOR20:	MOV	A,B	ANI	0F0H	RLC	RLC	RLC	RLC	LXI	D,-16COOR30:	ANA	A	JZ	COOR40	DAD	D	DCR	A	JNZ	COOR30COOR40:	POP	B	POP	D	RETLEVEL:	LHLD	LEVELS	SHLD	TABLES	LXI	D,OLEVEL	XRA	A	STA	LPOINT	DI	MVI	A,0EFH	OUT	3	LXI	H,VIDEO	MVI	B,16LEV10:	MVI	C,16	PUSH	HLEV20:	CALL	GETCOD	STAX	D	INX	D	PUSH	D	CPI	1	JZ	BOLDR	CPI	2	JZ	BABCH	CPI	3	JZ	MINA	CPI	4	JZ	KAMEN	CPI	5	JZ	ALMAZ	CPI	6	JZ	STENA	CPI	7	JZ	ZEMLA	ANA	A	JZ	PUSTLEV30:	POP	D	INR	H	INR	H	DCR	C	JNZ	LEV20	POP	H	PUSH	D	LXI	D,-16	DAD	D	POP	D	PUSH	B	LXI	B,400H	CALL	ZAD	POP	B	IN	3	SUI	16	OUT	3	DCR	B	JNZ	LEV10	EI	RETBOLDR:	LXI	D,BOLDRP	CALL	KOORD	STA	POLBLDLEV15:	CALL	COPY	JMP	LEV30BABCH:	LXI	D,BABCHP	LDA	WBABCH	INR	A	CPI	33	JZ	PUST	STA	WBABCH	PUSH	H	LHLD	ABABCH	CALL	KOORD	MOV	M,A	INX	H	SHLD	ABABCH	POP	H	JMP	LEV15MINA:	LXI	D,MINAP	LDA	WMINA	INR	A	CPI	33	JZ	PUST	STA	WMINA	PUSH	H	LHLD	AMINA	CALL	KOORD	MOV	M,A	INX	H	SHLD	AMINA	POP	H	JMP	LEV15KOORD:	PUSH	B	MVI	A,10H	SUB	C	MOV	C,A	MVI	A,10H	SUB	B	RLC	RLC	RLC	RLC	ORA	C	POP	B	RETPUST:	LXI	D,PUSTP	JMP	LEV15KAMEN:	LXI	D,KAMENP	JMP	LEV15ALMAZ:	LXI	D,ALMAZP	JMP	LEV15STENA:	LXI	D,STENAP	JMP	LEV15ZEMLA:	LXI	D,ZEMLAP	JMP	LEV15COPY:	PUSH	H	CALL	COPY10	POP	H	RETCOPY10:	PUSH	B	LXI	B,1F10HCOPY20:	PUSH	H	LDAX	D	MOV	M,A	INX	D	INR	H	LDAX	D	MOV	M,A	INX	D	MOV	A,B	ADD	H	MOV	H,A	LDAX	D	MOV	M,A	INX	D	INR	H	LDAX	D	MOV	M,A	INX	D	MOV	A,B	ADD	H	MOV	H,A	LDAX	D	MOV	M,A	INX	D	INR	H	LDAX	D	MOV	M,A	INX	D	POP	H	DCR	L	DCR	C	JNZ	COPY20	POP	B	RETGETCOD:	PUSH	H	LHLD	TABLES	LDA	LPOINT	ANA	A	JZ	GETC10	XRA	A	STA	LPOINT	MOV	A,M	INX	H	SHLD	TABLES	ANI	0FH	POP	H	RETGETC10:	INR	A	STA	LPOINT	MOV	A,M	ANI	0F0H	RLC	RLC	RLC	RLC	POP	H	RETDYSPLY:	PUSH	H	PUSH	D	PUSH	B	PUSH	PSW	LXI	H,SETPAL	MOV	A,M	ANA	A	JZ	DYSP20	DCR	M	LXI	B,15	LHLD	COLORS	DAD	BDYSP10:	MOV	A,C	OUT	2	MOV	A,MINV:	NOP	OUT	12	DCX	H	OUT	12	INR	B	OUT	12	DCR	B	OUT	12	INR	B	OUT	12	DCR	B	OUT	12	DCR	C	OUT	12	JP	DYSP10DYSP20:	MVI	A,8AH	OUT	0	LXI	H,TIMER	DCR	M	XRA	A	OUT	3	IN	2	STA	KEYS	STA	CTLKEY	INR	A	JZ	DSPL10	MVI	A,0FEH	OUT	3	IN	2	STA	CTLKEYDSPL10:	MVI	A,88H	OUT	0	MVI	A,2	OUT	1	MVI	A,0	OUT	2	MVI	A,0FFH	OUT	3	CALL	DSPL20	LDA	WVOICE	RRC	RRC	RRC	LXI	B,2M0:	RLC	PUSH	PSW	CC	MUSIC	POP	PSW	DCR	C	JP	M0	POP	PSW	POP	B	POP	D	POP	H	EI	RETDSPL20:	LDA	SELJS	DCR	A	JZ	JOYS	DCR	A	JZ	JOYP	XRA	A	OUT	7	IN	7	CMA	LXI	H,TABJU	JMP	JOYS10JOYS:	MVI	A,40H	OUT	5	IN	6	LXI	H,TABJ	CALL	JOYS10	MVI	A,20H	OUT	5	IN	6	LXI	H,TABJ	JMP	JOYS10JOYS10:	MVI	B,4	MOV	C,A	LXI	D,CTLKEYJOYS12:	MOV	A,C	ANA	M	INX	H	JNZ	JOYS14	LDAX	D	ANA	M	STAX	D	STA	KEYSJOYS14:	INX	H	DCR	B	JNZ	JOYS12	RETJOYP:	IN	14	LXI	H,TABJ	CALL	JOYS10	IN	15	LXI	H,TABJ	JMP	JOYS10TABJ:	DB 2,0EFH,1,0BFH,4,0DFH,8,7FHTABJU:	DB 10H,0EFH,40H,0BFH,80H,0DFH,20H,7FHKEYS:	DB	0CTLKEY:	DB	0LPOINT:	DB	0GOBOLD:	DB	0KIRPAD:	DB	0KIRP:	DB	0WBABCH:	DB	0WMINA:	DB	0WALMAZ:	DB	0POLBLD:	DB	0GOSHAG:	DB	0ZERO:	DB	0PLBLD1:	DB	0DECALM:	DB	0WLEVEL:	DB	0LIFE:	DB	0SETPAL:	DB	0TIMER:	DB	0SCORE:	DW	0SW:	DW	1LEVELS:	DW	0CHHTW1:	DW	0CHHTW2:	DW	0ABABCH:	DW	0AMINA:	DW	0PLBLD0:	DW	0TABLES:	DW	0COLORS:	DW	PALETGVIDEO:	EQU	0A0FFHPUSTP:	EQU	60HBABCHS:	EQU	7800HBBCHS:	EQU	7820HMINS:	EQU	7840HMINES:	EQU	7860HOLEVEL:	EQU	7D00HTLEVLS:	EQU	3400HSTR0:	DB	'GAME OVER',0DH,0STR2:	DB	'LEVEL ',0STR3:	DB	'  LIFE ',0STR4:	DB	'SCORE 000'SCORE0:	DB	'0',0STRSTL:	DB 1BH,59H,2AH,2AH,'�������: ',0FILE:	EQU	1600HBOLDRP:	EQU	FILEBOLDR2:	EQU	FILE+96BOLDR4:	EQU	FILE+192BOLDR3:	EQU	FILE+288BOLDR5:	EQU	FILE+384BOLDR6:	EQU	FILE+480BOLDR8:	EQU	FILE+576BOLDR7:	EQU	FILE+672BOLDR9:	EQU	FILE+768BABCHP:	EQU	FILE+864ALMAZP:	EQU	FILE+960MINAP:	EQU	FILE+1056ZEMLAP:	EQU	FILE+1152KAMENP:	EQU	FILE+1248STENAP:	EQU	FILE+1344PLPER:	DB 'L8O3FEDEDCDCO2BO3GGEDE'	DB 'DC',0PLCHK:	DB 'L8O3FEDEDCDCO2BO3G',0PLUB:	DB 'L16O5DCO4BO5CO4BAGO5E',0PLALM:	DB 'L32O5AGFGF',0PLLST:	DB 'O4C4.D4F8.A8O5C16.E16G'	DB '32.B32',0PLPAD:	DB 'O2F32',0MEL0:	DB 'L4O3 CE-GE-F.E-DG.F.C.P E-GB-B- O4C.O3B-A-G.' DB 'PA.B.O4DCO3G.PD.C GFA-. PB-A-G.FE-G.F.C2.PR',0MEL1: DB 'L4O3 PP PP P.P PP.P.P.P PPG G  A.G F E-.PG.G.E-E' DB '-E-.P.PPO2A-PA-. PG F E-.DCE-.D.O5C2.PR',0MUS100:	PUSH	H	PUSH	H	LXI	D,128	LXI	H,TVOICE-128	MOV	A,CMUS110:	DAD	D	DCR	A	JP	MUS110	POP	D	LDAX	D	MOV	E,A	MVI	D,0	DAD	D	MOV	A,M	ANA	A	XCHG	POP	H	JZ	MUS05	CPI	'L'	JNZ	MUS120	INR	M	INX	D	LDAX	D	CPI	30H	JC	MUS112	CPI	3AH	JNC	MUS112	CALL	CHIS	JMP	MUS114MUS112:	MVI	A,4MUS114:	PUSH	H	LXI	H,TABL0	DAD	B	MOV	M,A	POP	H	LDAX	DMUS120:	CPI	'O'	JNZ	MUS130	INR	M	INX	D	LDAX	D	CPI	30H	JC	MUS130	CPI	39H	JNC	MUS130	PUSH	H	LXI	H,TABL2	DAD	B	SUI	2FH	MOV	M,A	POP	H	INR	M	INX	D	LDAX	DMUS130:	INR	M	INX	D	PUSH	H	PUSH	D	LXI	H,MUS140	PUSH	H	LXI	H,MUSTAB	LXI	D,4	CPI	'C'	RZ	DAD	D	CPI	'D'	RZ	DAD	D	CPI	'E'	RZ	INX	H	INX	H	CPI	'F'	RZ	DAD	D	CPI	'G'	RZ	DAD	D	CPI	'A'	RZ	DAD	D	CPI	'B'	RZ	POP	H	POP	D	POP	H	CPI	'P'	JZ	MUS132	CPI	'R'	JNZ	MUS15	MVI	M,0	JMP	MUS15MUS132:	CALL	MUS17	JMP	MUS150MUS140:	POP	D	LDAX	D	CPI	'#'	INX	H	INX	H	JZ	MUS142	CPI	'+'	JZ	MUS142	CPI	'-'	DCX	H	DCX	H	JNZ	MUS144	DCX	H	DCX	HMUS142:	XTHL	INR	M	XTHL	INX	DMUS144:	SHLD	MUS145+1MUS145:	LHLD	0	PUSH	H	LXI	H,TABL2	DAD	B	MOV	A,M	POP	H	PUSH	B	MOV	C,AMUS146:	DCR	C	JZ	MUS148	MOV	A,H	ORA	A	RAR	MOV	H,A	MOV	A,L	RAR	MOV	L,A	JMP	MUS146MUS148:	POP	B	CALL	MUS200	POP	HMUS150:	LDAX	D	CPI	30H	JC	MUS152	CPI	3AH	JNC	MUS152	CALL	CHIS	JMP	MUS160MUS152:	PUSH	H	LXI	H,TABL0	DAD	B	MOV	A,M	POP	HMUS160:	PUSH	H	LXI	H,TABL1	DAD	B	MOV	M,A	LDAX	D	CPI	'.'	MOV	A,M	JNZ	MUS162	ADD	A	ADD	M	ORA	A	RAR	MOV	M,A	POP	H	INR	M	RETMUS162:	POP	H	RETMUS200:	PUSH	PSW	MVI	A,9	ADD	C	STA	MUS210+1	STA	MUS220+1	MOV	A,C	INR	A	CMA	RRC	RRC	ANI	0C0H	ORI	36H	OUT	8	MOV	A,LMUS210:	OUT	9	MOV	A,HMUS220:	OUT	9	POP	PSW	RETCHIS:	SUI	30H	INR	M	INX	D	PUSH	B	MOV	C,A	LDAX	D	CPI	30H	JC	CHIS10	CPI	3AH	JNC	CHIS10	SUI	30H	MOV	B,A	MOV	A,C	ADD	A	ADD	A	ADD	C	ADD	A	ADD	B	MOV	C,A	INR	M	INX	DCHIS10:	MOV	A,C	ORI	1	RLC	MOV	B,A	MVI	A,80HCHIS20:	RLC	MOV	C,A	MOV	A,B	RLC	MOV	B,A	MOV	A,C	JNC	CHIS20	POP	B	RETMUSIC:	LXI	H,TABL1	DAD	B	DCR	M	RNZ	LXI	H,WNOT	DAD	B	MOV	A,M	CPI	128	JC	MUS100MUS05:	MVI	M,0	LXI	H,TABL2	DAD	B	MVI	M,5	LXI	H,TABL0	DAD	B	MVI	M,4	PUSH	B	MVI	A,7FHMUS10:	RLC	DCR	C	JP	MUS10	LXI	H,WVOICE	ANA	M	MOV	M,A	POP	BMUS15:	LXI	H,TABL1	DAD	B	MVI	M,1MUS17:	MOV	A,C	INR	A	CMA	RRC	RRC	ANI	0C0H	ORI	30H	OUT	8	RETPLAYEN:	PUSH	PSW	PUSH	H	PUSH	B	LXI	B,2KPL10:	LXI	H,WNOT	DAD	B	CALL	MUS05	DCR	C	JP	KPL10	POP	B	POP	H	POP	PSW	RETVPLAY:	LDA	WVOICE	RETPLAY:	PUSH	H	PUSH	D	PUSH	B	PUSH	PSW	PUSH	H	PUSH	D	PUSH	B	POP	H	MOV	A,H	ORA	L	MVI	C,1	LXI	D,TVOIC1	DI	CNZ	PLAY10	POP	H	MVI	C,2	MOV	A,H	ORA	L	LXI	D,TVOIC2	CNZ	PLAY10	POP	H	MOV	A,H	ORA	L	MVI	C,4	LXI	D,TVOIC3	CNZ	PLAY10	EI	POP	PSW	POP	B	POP	D	POP	H	RETPLAY10:	LDA	WVOICE	ORA	C	STA	WVOICE	PUSH	H	LXI	H,WNOT	DCR	C	JNZ	$+5	MVI	M,0	INX	H	DCR	C	JNZ	$+5	MVI	M,0	INX	H	DCR	C	DCR	C	JNZ	$+5	MVI	M,0	POP	H	MVI	C,128PLAY12:	MOV	A,M	CPI	20H	JNZ	PLAY14	INX	H	JMP	PLAY12PLAY14:	STAX	D	INX	H	INX	D	DCR	C	JNZ	PLAY12	RETTVOICE:	EQU	0C08HTVOIC1:	EQU	TVOICETVOIC2:	EQU	TVOICE+128TVOIC3:	EQU	TVOICE+256WVOICE:	DB	0WNOT:	DB	0,0,0TABL0:	DB	4,4,4TABL1:	DB	1,1,1TABL2:	DB	5,5,5	DW 0D2BDHMUSTAB:	DW 0B32BH,0A91CH,9F9EH,96A9H	DW 8E34H,8639H,7EB0H,7794H	DW 70DEH,6A88H,648EH,5EE9H	DW 5995H