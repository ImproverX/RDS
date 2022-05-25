;(перед компилированием преобразовать в CP866)
	.ORG	0AE00H
INITCN:	.EQU	DISP	; = 0CA00H
KEY:	.EQU	DISP+3	; = 0CA03H
INBYT:	.EQU	DISP+6	; = 0CA06H
PRINTC:	.EQU	DISP+9	; = 0CA09H
OUTBYT:	.EQU	DISP+12	; = 0CA0CH
LST:	.EQU	DISP+15	; = 0CA0FH
KEYS:	.EQU	DISP+18	; = 0CA12H
HEXOUT:	.EQU	DISP+21	; = 0CA15H
PRINT:	.EQU	DISP+24	; = 0CA18H
;
VIRD7:	.EQU	0D300H	;== адрес хранения vird7
ZAPL:	.EQU	0D800H	;DISP !
ZAPL2:	.EQU	0D880h	;было 0C000H	;+++++++++++ b7h
RDMA:	.EQU	0D900H	; (L должно быть =0) размер 1024 байта
BATPAR:	.EQU	0DD00H	; = VRTMOV
SWAP:	.EQU	0DD80H	; буфер для свапа ПП при чтении данных в адреса 9F00-E000
VDMA:	.EQU	0DE00H	; 128 байт
DRIVSP:	.EQU	0DEE0H	;+++++++++++ b7h DF70h
P10:	.EQU	20H	; 0010 0000b -- банк 3 как ОЗУ A000-DFFFh
;
VIRADR:	.EQU	0FB00h	;== адрес начала virt
VIRSRC:	.EQU	0D380H	;== адрес хранения virt
VPAR:	.EQU	0FDBAh	;== PARA (virt)
PARA:	.EQU	VPAR-VIRADR+VIRSRC	; == адрес хранения PARA virt
PARB:	.EQU	PARA+15
PARK:	.EQU	PARB+15
;PARD:	.EQU	PARC+15
DIRBUF:	.EQU	PARK+15
CSVA:	.EQU	DIRBUF+128
CSVB:	.EQU	CSVA+32
ALVA:	.EQU	CSVB+32
ALVB:	.EQU	ALVA+51
ALVC:	.EQU	ALVB+51
ALVD:	.EQU	ALVC+33
;
; обращения к bdos:
;BDSLDS:	.EQU	AAC21
;CURDSK:	.EQU	DA342
;BDPRNT:	.EQU	AA190
;BDDAT:		.EQU	DADB1
;BDDAT2:	.EQU	DADB9
;BDDAT3:	.EQU	DADD9
;CPM:		.EQU	AA011
;CPM0:		.EQU	AA006
;AAD56:		.EQU	AAD56
;
CBIOS:
	JMP	COLD	; +0
	JMP	WBOOT	; +3
	JMP	KEYS	; +6
	JMP	KEY	; +9
	JMP	PRINTC	; +C
	JMP	LST	; +F
	JMP	PUTCH	; +12
	JMP	READER	; +15
	JMP	HOME	; +18
	JMP	SELDSK	; +1B
	JMP	SETTRC	; +1E
	JMP	SETSEC	; +21
	JMP	SETDMA	; +24
	JMP	READ	; +27
	JMP	WRITE	; +2A
	JMP	LISTST	; +2D
	JMP	SECTRN	; +30
	.DW	DISKI	; +33
	JMP	VCPM	; +35
	JMP	BDSEAR	; +38
	JMP	BDREST	; +3B
	JMP	NBDOS	; +3E
	.DW	HDDAT+1	; +41 -- адрес для сохранения (10000h - (число дискет))
TYPEWR:	.DB	0	; +43 -- тип записываемого сектора (см.WRITE)
FTRACK:	.DB	0	; +44
WOPER:	.DB	0	; +45
DISKS:	.DB	3	; +46 -- количество дисковых устройств -1
;
BDSEAR:	SHLD	DMA
	CALL	READ10
	RET
;
BDREST:	LDA	CURDSK
	MOV	C,A
	LXI	H,1
	CALL	BDRS10
	CALL	AAD56	; >> bdos (сброс диска)
	JMP	BDSLDS	; (AAC21) >> bdos
;
BDRS10:	INR	C	; << A, C = CURDSK; HL = 0001
	DCR	C
	RZ		; >> [A][HL] = [A][HL] ^ (CURDSK + 1)
	DAD	H
	ADC	A
	JMP	BDRS10+1
;
COLD:	LDA	3EH
	ANA	A
	JZ	VIRADR+3	; 0FB03H
	DI
	DCR	A
	JZ	COLD10
	INR	A
	ANI	7FH
	JZ	COLD10
	STA	3EH
	MVI	A,0C9H	; = JMP
	STA	38H
	MVI	A,1
	STA	3FH	; режим обработки ошибок
	LHLD	DISKI
	LXI	D,DRIVEA
	MOV	A,H
	CMP	D
	JZ	SKCP	; >>> DRIVEA = ZAGA b7h, не надо копировать, пропуск
	PUSH	H	; -> ZAGA virt
;	PUSH	D	; -> ZAGA b7h
	MVI	C,4	; количество дисков
COLD02:	PUSH	B
	MVI	B,8
	CALL	COPY10	; копирование ZAGA из virt в b7h, 8 байт
	LXI	B,8
	DAD	B
	XCHG
	DAD	B
	XCHG
	POP	B	; пропуск 8 байт
	DCR	C
	JNZ	COLD02	; цикл
;	POP	H	; <- ZAGA b7h
;	LXI	B,124	; =[len(ZAGA)+len(PARA)]*(кол-во дисков); 3 диска == 93
;	DAD	B	; = DIRBUF b7h !!!!!!!!!!!!!!!!!!!!!
;	XCHG
	LXI	D,DIRBUF
	POP	H	; <- ZAGA virt
	LXI	B,124	; =[len(ZAGA)+len(PARA)]*(кол-во дисков); 3 диска == 93
	DAD	B	; = DIRBUF
	LXI	B,360	; 327 == 3 диска
;	CALL	BCOPY
BCOPY:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	BCOPY	; цикл копирования DIRBUF,CSVA,CSVB,ALVA-ALVD
	LXI	H,DRIVEA
	LXI	B,16
	SHLD	DISKI	; =ZAGA b7h
	DAD	B
	SHLD	DISKI+2	; =ZAGB b7h
	DAD	B
	SHLD	DISKI+4	; =ZAGC b7h
	DAD	B
	SHLD	DISKI+6	; =ZAGD b7h
SKCP:	CALL	BDSLDS
	LXI	H,40H
	SHLD	6
	SHLD	9
	MVI	A,0C3H	; = JMP
	STA	5
	STA	8
	LXI	D,M40
	MVI	B,17
	XCHG
	JMP	COPY10	; копирование из M40 в 0040h, 17 байт
;	RET
;
M40:	DI		; (копируется в 0040h)
	LDA	15
	OUT	10H
	JMP	CBIOS+35H
;
	LDA	3CH	; 0049h
	OUT	10H	; 
	MOV	A,C	; 
	EI		; 
	RET		; 

COLD10:	STA	3EH
	MVI	A,0C3H
	STA	M38
	XRA	A
	STA	3FH	; режим обработки ошибок
	CALL	INITCN
	CALL	BDSLDS
	RET
;
VCPM:	LXI	H,0
	DAD	SP
	SHLD	VCPM10+1
	LXI	H,38H
	MOV	A,M
	STA	M38
	MVI	M,0C9H
	LXI	SP,0E000H
	CALL	CPM0	; == 0A006h = 0A011h
	MOV	C,A
	DI
	LDA	M38
	STA	38H
VCPM10:	LXI	SP,0
	JMP	49H	; >>> !!
;
M38:	.DB	0
WBOOT:	DI
	LXI	H,VIRADR	; 0FB00H адрес virt
	SHLD	6
	XRA	A
	STA	PISAT
	MVI	A,-1
	STA	ODISK
	LDA	4
	PUSH	PSW
	CALL	COM
	POP	PSW
	STA	4
	MOV	C,A
	EI
	LHLD	PUSK
	RET
;
PUSK:	.DW	0
COM:	LDA	FLBAT
	ANA	A
	JNZ	FRCOM
	LDA	FACOM
	ANA	A
	JZ	FRCOM
	LXI	H,ACOMBF
	CALL	COM00
	JZ	FRCOM
	LXI	H,100H
	SHLD	PUSK
	XCHG
	JMP	COM20
;
FRCOM:	LXI	H,FILE
	CALL	COM00
	JZ	COMER
	JMP	COM02
;
COM00:	LXI	D,5CH
	MVI	B,12
	CALL	COPY10	; копирование из adr(HL=FILE) в adr(DE=005Ch) B=12 байт
	XCHG
	LXI	B,1800H
	CALL	FILL	; заполнение памяти значением C с адр(HL) B байт
	MVI	E,-1
	MVI	C,32
	CALL	CPM
	STA	OLDUSR
	MVI	E,0
	MVI	C,32
	CALL	CPM
	MVI	E,2
	MVI	C,14
	CALL	CPM
	LXI	D,5CH
	MVI	C,15
	CALL	CPM
	INR	A
	RET
;
COM02: 	LXI	D,80H
	MVI	C,26
	CALL	CPM
	MVI	C,20
	LXI	D,5CH
	CALL	CPM
	LHLD	80H
	XCHG
	LHLD	82H
	SHLD	PUSK
COM20:	PUSH	D
	MVI	C,26
	CALL	CPM
	LXI	D,5CH
	MVI	C,20
	CALL	CPM
	POP	D
	LXI	H,128
	DAD	D
	XCHG
	ANA	A
	JZ	COM20
	LDA	OLDUSR
	MOV	E,A
	MVI	C,32
	JMP	CPM
;
COMER:	LXI	H,STRCE
	CALL	PRINT
	DI
	HLT
;
STRCE:;	.DB 10,"Отсутствует файл C:COMMAND.SYS !",7,0
	.DB 10,"я╘╙╒╘╙╘╫╒┼╘ ╞┴╩╠ C:COMMAND.SY"
	.DB "S !",7,0
FILE:	.DB 0,"COMMAND SYS"
OLDUSR:	.DB	0
ACOMBF:	.DS	12	; <=
;
PUTCH:	MOV	A,C
	JMP	OUTBYT
;
READER:	MOV	A,C
	JMP	INBYT
;
HOME:	LXI	B,0
SETTRC:	LXI	H,TRACK
	MOV	M,C
	INX	H
	MOV	M,B
	RET
;
SETSEC:	LXI	H,SECT
	MOV	M,C
	RET
;
SETDMA:	MOV	H,B
	MOV	L,C
	SHLD	DMA
	RET
;
LISTST:	IN	5
	ANI	1
	RET
;
SECTRN:	MOV	H,B
	INR	C
	MOV	L,C
	RET
;
SETDSK:	STA	DISK
	RET
;
SELDSK:	MOV	A,C
	CPI	0F0h
	JNC	SETDSK	; >> обращение к НЖМД в LBA
	LXI	H,0
	LDA	DISKS	; = количество дисков
	CMP	C
	MOV	A,C
	RC		; возврат, если (DISKS < С)
	STA	DISK
	CALL	VECT
DISKI:	.DW	DRIVEA
	.DW	DRIVEB
	.DW	DRIVEC
	.DW	DRIVED
;
VECT:	ADD	A
	POP	H
	MOV	E,A
	MVI	D,0
	DAD	D
	MOV	E,M
	INX	H
	MOV	H,M
	MOV	L,E
	RET
;
RWDFH:	MOV	A,M	; чтение/запись НЖМД по LBA
	ANI	07h	; 0000 0111
	STA	SSECT	; сохраняем смещение сектора CP/M в секторе НЖМД
	MVI	M,0F0h	; поправляем метку адресации LBA НЖМД
RWDF:	LXI	H,0	; чтение/запись НГМД/НЖМД...
	DAD	SP
	SHLD	SVSP+1
	LXI	SP,DRIVSP
	CALL	DRIV
	LDA	ERROR
	ANA	A
SVSP:	LXI	SP,0	; <- правится указатель стека
	RET
;
; При вызове этой функции в регистре С передается дополнительный флаг,
; обозначающий тип записываемого сектора:
; 0 - обычный сектор,
; 1 - сектор из области директория,
; 2 - первый сектор нового блока данных (начальное значение данного блока неважно).
WRITE:	XRA	A	; <<< запись на дисковое устройство
	JMP	DRIVE
;
READ:	MVI	A,1	; <<< чтение с дискового устройства
DRIVE:	STA	OPER	; 0-запись, 1-чтение
	LXI	H,PARAM
	LXI	D,PARAM0
	MVI	B,7
	CALL	COPY10	; копирование из adr(PARAM) в adr(PARAM0) B=7 байт
	LXI	H,DISK0
	MOV	A,M
	ANI	0FEh	; 1111 1110
	JZ	RWDF	; (00 / 01) >> не КД, переход к чтению/записи
	ANI	0FCh	; 1111 1100
	JZ	RWKV	; (02 / 03) >> КД, переход к чтению/записи
	ANI	0F8h	; 1111 1000
	CPI	0F0h
	JZ	RWDFH	; >> метка НЖМД, переход к чтению/записи
	MVI	A,-1
	RET		; >> если диск > 3
;
RWKV:	LDA	OPER0	; <<<<< чтение/запись КД
	ANA	A
	JZ	WRITKV	; >> КД, переход к записи
READ02:	CALL	KVRD
	LXI	H,VDMA
	SHLD	WRKDMA
READ04:	PUSH	PSW
	CALL	READ10
	POP	PSW
	RET
;
READ10:	LHLD	WRKDMA
	XCHG
	LHLD	DMA
READ11:	XCHG
	MOV	A,D
	CPI	09FH
	JC	READ12	; D < 09Fh
	CPI	0E0H
	JC	READ20	; (09Fh <= D < 0E0h) ->>>> чтение через свап
READ12:	MVI	B,16	;<<< читаем из HL, пишем в DE, 128 байт
	DI
	PUSH	H
	LXI	H,2
	DAD	SP
	SHLD	READ14+1
	POP	H
	SPHL
	XCHG
READ13:	POP	D
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	POP	D
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	POP	D
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	POP	D
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	DCR	B
	JNZ	READ13
READ14:	LXI	SP,0
	EI
	RET
;
READ20:	PUSH	H
	LXI	H,DIRBUF
	CALL	HDCMP
	POP	H
	JZ	READ12
	PUSH	H
	PUSH	D
	CALL	SWAPNG
	POP	D
	DI
	LXI	H,2
	DAD	SP
	SHLD	COPYX+1	; READ22+1
	POP	H
	LXI	SP,100H
	MVI	C,64
	CALL	80H
	JMP	COPYX
;READ22:	LXI	SP,0
;	EI
;	LXI	H,SWAP
;	LXI	D,128
;	MVI	B,128
;	CALL	COPY10	; копирование из adr(HL) в adr(DE) B байт
;	RET
;
SWAPNG:	LXI	H,128	; берём отсюда
	LXI	D,VIRD7	; отсюда пишем в adr(HL)
	LXI	B,SWAP	; сюда сохраняем из adr(HL)
SWAP10:	MOV	A,M
	STAX	B
	LDAX	D
	MOV	M,A
	INR	C
	INR	E
	INR	L
	MOV	A,M
	STAX	B
	LDAX	D
	MOV	M,A
	INR	C
	INR	E
	INR	L
	JNZ	SWAP10
	RET
;
HDCMP:	MOV	A,H	; возврат Z=0, если DE=HL
	SUB	D
	RNZ
	MOV	A,L
	SUB	E
	RET
;
WRIT10:	LHLD	WRKDMA
	XCHG
	LHLD	DMA
	MOV	A,H
	CPI	09FH	; читаем из HL, пишем в DE, 128 байт
	JC	READ12	; переход, если < 09Fxxh ????? (может надо А0?)
	CPI	0E0H
	JNC	READ12	; переход, если >=0E0xxh
	PUSH	D
	LXI	D,DIRBUF
	CALL	HDCMP	; возврат Z=0, если DE=HL
	POP	D
	JZ	READ12	; переход, если adr(DMA)=adr(DIRBUF)
	PUSH	H
	PUSH	D
	CALL	SWAPNG	; adr(128-255)-> SWAP, VIRD7 -> adr(128-255)
	POP	D
	DI
	LXI	H,2
	DAD	SP
	SHLD	COPYX+1	; WRIT22+1
	POP	H
	LXI	SP,100H
	LXI	B,128
	DAD	B
	XCHG
	DAD	B
	MVI	C,64
	CALL	83H	;>>> запись в vird7
	JMP	COPYX
;WRIT22:	LXI	SP,0
;	EI
;	LXI	H,SWAP
;	LXI	D,128
;	MVI	B,128
;	CALL	COPY10	; копирование из adr(HL) в adr(DE) B байт
;	RET
;
BDWRIT:	PUSH	D
	DI
	CALL	SWAPNG	; adr(128-255)-> SWAP, VIRD7 -> adr(128-255)
	LXI	H,0
	POP	D
	DAD	SP
	SHLD	COPYX+1	; BDWR10+1
	LXI	H,VRTBUF
	LXI	B,40
	DAD	B
	XCHG
	DAD	B
	XCHG
	LXI	SP,100H
	MVI	C,20	; счётчик
	CALL	83H	; >> VIRD7, пишем в SP:=HL (КД) из adr(DE)
	JMP	COPYX
;BDWR10:	LXI	SP,0
;	LXI	H,SWAP	; восстановление adr(128-255)
;	LXI	D,128
;	MVI	B,128
;	EI
;	JMP	COPY10	; копирование из adr(HL) в adr(DE) B байт
;
BDREAD:	DI
	PUSH	H
	CALL	SWAPNG	; adr(128-255)-> SWAP, VIRD7 -> adr(128-255)
	POP	D
	LXI	H,0
	DAD	SP
	SHLD	COPYX+1
	LXI	H,VRTBUF
	LXI	SP,100H
	MVI	C,20
	CALL	80H	; >> VIRD7, пишем в adr(DE) из SP:=HL (КД)
COPYX:	LXI	SP,0
	LXI	H,SWAP	; восстановление adr(128-255)
	LXI	D,128
	MVI	B,128
	EI
COPY10:	MOV	A,M	; копирование из adr(HL) в adr(DE) B байт
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	COPY10
	RET
;
KVRD:	CALL	KVRAS	; расчёт адреса сектора на КД	; <<<<< чтение с КД
	LXI	H,0
	DI
	DAD	SP
	SHLD	KVDR10+1
	CALL	RDSIX	; (патч для РУ7)
	LHLD	KADR
	LXI	B,0FF80h	; =-80h
	DAD	B	; HL=HL-0080h
	SPHL
	LXI	H,VDMA	; куда читать
	LXI	B,0040h	; B=0 (КС), C=64 (счётчик)
KVRD10:	LDA	PORT10
	JMP	10H	; >>> чтение КД РУ7
KVRD11:	MOV	A,B	; <<< возврат из ПП 0010h
	MOV	M,E
	ADD	E
	INX	H
	MOV	M,D
	INX	H
	ADD	D
	MOV	B,A
	DCR	C
	JNZ	KVRD10	; цикл чтения сектора
	MVI	A,1CH
	LXI	H,KVR11D
	SHLD	18H
	LHLD	KCRC	; адрес контрольной суммы
	SPHL
	JMP	10H	; >>> чтение КД РУ7
KVR11D:	MOV	A,E	; <<< возврат из ПП 0010h
	CMP	D
	JNZ	KVRD12	; > ошибка чтения КС (D<>E)
	CMP	B
	JZ	KVDR10	; > всё ок
	MVI	C,2	; Ошибка: КС не совпадает
KVDR09:	MOV	E,B
	LDA	3FH	; режим обработки ошибок
	CPI	3	; >=3
	JNC	KVRD13	; исправление КС по сектору (!)
KVDR10:	LXI	SP,0
	LXI	H,0011h	; 
	SHLD	11h	; делаем OUT 11h и NOP
	LXI	H,KVDR11
	SHLD	18H	; поправляем адрес возврата
	XRA	A	; отключение КД11
	JMP	10H	; >>> (nop) КД РУ7
KVDR11:	LXI	H,SIXBUF; откуда	; <<< возврат из ПП 0010h
	LXI	D,10H	; куда
	MVI	B,10	; сколько
	CALL	COPY10	; восстанавливаем память
	EI
	MOV	A,C
	STA	ERROR
	ANA	A
	RZ		; >> выход, ошибок нет (А= код ошибки, B= КС)
	JMP	FSWR20	; обработка ошибок
;
KVRD12:	CMP	B	; < ошибка чтения КС
	JZ	KVRD13	; Е совпадает, перезаписываем D
	MOV	A,D
	CMP	B
	MOV	E,D
	JZ	KVRD14	; D совпадает, перезаписываем E
	MVI	C,3	; Ошибка: вообще ничего не совпало
	JMP	KVDR09
;
KVRD13:	MOV	D,E	; исправление КС
KVRD14:	LXI	H,KVDR10
	SHLD	18H	; правим адрес возврата
	MVI	A,0D5H	; = PUSH D
	STA	12H
	MVI	A,1CH
	JMP	10H	; >>> запись КД РУ7
;
			; <<<<< запись на КД
WRITKV:	MOV	A,M	; A=DISK0
	ANI	001h	; 0000 0001 ( = 3 ? )
	JNZ	KVWR00	; если КД11, то пропускаем >>(1)
	LDA	TRC0	; (защита от записи в системную область КД)
	CPI	180
	JC	KVWR00	; < 180 >>(1)
	CPI	196
	RC		; возврат, если (180 <= ТРЕК < 196)
KVWR00:	LXI	H,VDMA	; <(1)
	SHLD	WRKDMA
	CALL	WRIT10
	CALL	KVRAS	; расчёт адреса сектора на КД
	LXI	H,0
	DI
	DAD	SP
	SHLD	KVDR10+1
	CALL	WRSIX
	LHLD	KADR
	LXI	D,128
	SPHL
	LXI	B,0040h	; B=0 (КС), C=64 (счётчик)
	LXI	H,VDMA
	DAD	D
KVWR10:	DCX	H
	MOV	D,M
	MOV	A,B
	ADD	D
	DCX	H
	MOV	E,M
	ADD	E
	MOV	B,A	; B= КС
	LDA	PORT10
	JMP	10H	; >>> запись КД РУ7
KVWR11:	DCR	C	; <<< возврат из ПП 10h
	JNZ	KVWR10	; цикл записи сектора
	LHLD	KCRC	; адрес контрольной суммы
	INX	H
	INX	H
	SPHL
	MOV	D,B	; KC
	MOV	E,B
	JMP	KVRD14	; >> запись КС
;
RDSIX:	LXI	H,RDRU7	; часть патча для РУ7 (и КД11)
RDSIX0: LXI	D,10H
	LXI	B,SIXBUF
	MVI	A,10
SIXC10:	PUSH	PSW
	LDAX	D
	STAX	B
	MOV	A,M
	STAX	D
	INX	H
	INX	D
	INX	B
	POP	PSW
	DCR	A
	JNZ	SIXC10
	LDA	DISK	; проверка на КД11
	CPI	2
	RZ		; =КД10, пропускаем настройку на КД11
	MVI	A,11h	; тут правим ПП по адресу 10h на КД11
	STA	0011h
	RET
;
WRSIX:	LXI	H,WRRU7
	JMP	RDSIX0
;
RDRU7:	OUT	10H	; (менять на 11h)
	POP	D
	MVI	A,P10	; = 20h
	OUT	10H
	JMP	KVRD11
;
WRRU7:	OUT	10H	; (менять на 11h)
	PUSH	D
	MVI	A,P10	; = 20h
	OUT	10H
	JMP	KVWR11
;
SIXBUF:	.DS	10	; <=
;
KVRAS:	LDA	TRC0	; <<< расчёт адреса сектора на КД
	MOV	B,A
	MVI	A,0FBH
	SUB	B
	CPI	0F8H
	JNC	$+5	; (1) переход, если трек <= 3 (обход экранной области)
	SUI	10H
;;	CPI	38H	; <-(1)
;;	JNC	$+5	; (2) переход, если трек <= 179 (обход области РДС)
;;	SUI	10H
	RRC		; <-(2)
	RRC
	RRC
	RRC
	MOV	H,A
	ANI	0CH	; =00001100b
	ORI	10H
	MOV	B,A
	MOV	A,H
	RRC
	RRC
	ORI	3
	MOV	H,A
	MVI	L,-1
	INX	H
	LDA	SECT0
	LXI	D,-128
KVRS10:	DCR	A
	JZ	KVRS12
	DAD	D
	JMP	KVRS10
;
KVRS12:	SHLD	KADR	; адрес сектора на КД
	MOV	A,B
	STA	PORT10	; конфигурация порта 10
	LDA	TRC0
	MOV	L,A
	MVI	H,0
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	LDA	SECT0
	DCR	A
	ADD	A
	ADD	L
	MOV	L,A
	LXI	D,0F000H
	DAD	D
	SHLD	KCRC	; адрес контрольной суммы
	RET
;
KADR:	.DW	0
KCRC:	.DW	0
PORT10:	.DB	0
;
; преобразование TRС/SEC CP/M в LBA для НЖМД
; HL = adr(HDDx+1) -- ссылка на номер дискеты НЖМД
; на выходе исправленные TRC0, SECT0
TOLBA:	PUSH	H
	LHLD	TRC0
;	MVI	H,000H
	MOV	D,H
	MOV	E,L
	DAD	H
	DAD	H
	DAD	D	; HL= дорожка * 5
	LDA	SECT0
	MOV	E,A
	MVI	D,0
	DAD	D
	DAD	H	; HL= дорожка * 10 + сектор * 2
	LDA	TRC0	; дорожка, = FFh при инициализации НЖМД (чтении 1-го сектора)
	CPI	8
	JNC	TLBA2	; переход если дорожка >= 08h (несистемная область)
	POP	D
	LXI	D,2
	XRA	A
	JMP	TLBA3
;
TLBA1:	POP	D
	CPI	0FFH
	LXI	D,0F60AH	; = -09F6h	;ЧТО БЫ 0 СЕКТ.
	JZ	TLBA3
	JMP	TLBA4
;
TLBA2:	CPI	0A5H	; максимальный номер дорожки 0A4h
	JNC	TLBA1	; переход если дорожка >= 0A5h
	XTHL		; HL <-> [стек]
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	MOV	A,M	; (A,DE)=(номер первого сектора дискеты из таблицы)
	POP	H
TLBA3:	DAD	D
	ACI	000H
	STA	HTRC0	; (A,HL) = (номер сектора) + (номер первого сектора дискеты) = 00 0000h
	MOV	A,L
	STA	SECT0
	MOV	A,H
	STA	TRC0
	XRA	A
TLBA4:	STA	ERROR
	RET
;
CDTS:	LDA	DISK0	; проверка совпадения Disk/Track/Sector
	LXI	H,ODISK
	CMP	M
	RNZ		; >> диск не совпадает
	LDA	SECT0
	LXI	H,OSECT
	CMP	M
	RNZ		; >> сектор не совпадает
	LHLD	OTRACK
	LDA	TRC0
	CMP	L
	RNZ		; >> трек не совпадает
	LDA	HTRC0
	CMP	H
	RET		; >> трек не совпадает
;
DRIV:;	DCR	D	; кэширование чтения/записи с НГМД и НЖМД
;	MOV	A,D
;	STA	OPER	; 0-запись, 1-чтение
;	PUSH	PSW
;	LXI	H,PARAM	; откуда
;	LXI	D,PARAM0	; куда
;	MVI	B,7	; сколько
;	CALL	COPY10	; копируем
	LDA	DISK0
	CPI	0F0h	; Диск = 0F0h?
	JZ	DRIV21	; переданы TRC/SECT для НЖМД в режиме LBA, пропускаем пересчёт
	MOV	D,A	; сохраняем диск в D
	LXI	H,SECT0
	DCR	M
	MOV	A,M
	ANI     7	; 0000 0111
	STA	SSECT	; SSECT = (SECT0-1) % 8 (смещение)
	MOV	A,M
	ANI     0F8h	; 1111 1000
	RRC
	RRC
	RRC
	MOV	M,A	; SECT0 = (SECT0-1) / 8 (перевод в сектора НГМД)
	DCX	H	; HL = adr(HTRC0)
	MVI	M,0	; обнуляем старший разряд TRC0, во избежание глюков
	MOV	A,D	;	LDA	DISK0
	ANA	A
	LXI	H,HDDA
	JZ	$+6	; (1)>>
	LXI	H,HDDB
	MOV	A,M	; <<(1)
	INX	H
	ORA	M	; проверка НГМД или НЖМД? (HL = ссылка на HDDx+1)
	JZ	DRIV21	; >> значит флопик
	MVI	A,0F0h
	STA	DISK0	; метка, что это НЖМД
	CALL	TOLBA	; расчёт LBA и корректировка TRC0, SECT0
	RNZ		; >> выход по ошибке (неправильный трек)
DRIV21:;	POP	PSW
	LDA	OPER0
	ANA	A
	JZ	DRIV22	; >> запись
	CALL	DRIV50	; чтение
	JMP	DRIV30
;
DRIV50:	LDA	OOPER	; (чтение)
	ANA	A
	RNZ		; >> до этого было чтение
	LDA	TYPEWR	; тип записываемого сектора
	DCR	A
	RZ		; >> если писалась директория
	LDA	SSECT0
	CPI	7
	RZ		; >> или сектор 7
	JMP	FISWR
;
DRIV22:	LDA	OOPER	; (запись)
	ANA	A
	JNZ	DRI23V
	CALL	CDTS	; проверка совпадения Disk/Track/Sector
;	JNZ	DRIV23	; >> не совпадает
	JZ	DRI23V	; всё совпало
DRIV23:	LDA	PISAT
	ANA	A
	JNZ	DRI23V
	MVI	C,1
DRI23V:	MOV	A,C
	PUSH	PSW
	DCR	A
	CZ	DRIV50
	POP	PSW
	STA	TYPEWR	; тип записываемого сектора
	LXI	H,OOPER
	MOV	A,M
	ANA	A
	LDA	OPER0	; 0-запись, 1-чтение
	MOV	M,A
	JNZ	DRIV32
DRIV30:	LDA	PISAT
	ANA	A
	CNZ	FISWR
	LDA	OPER0	; 0-запись, 1-чтение
	STA	OOPER
	XRA	A
	STA	PISAT
	CALL	CDTS	; проверка совпадения Disk/Track/Sector
	JNZ	DRIV32	; >> не совпадает
	LDA	OPER0	; 0-запись, 1-чтение
	ANA	A
	JZ	DRIV34	; >>
	LDA	SSECT
	ANA	A	; (сектор % 8) <>0 ?
	JNZ	DRIV34	; >>
DRIV32:	LDA	DISK0	; обновляем...
	STA	ODISK	; ...диск
	LHLD	TRC0
	SHLD	OTRACK	; ...трек
	LDA	SECT0
	STA	OSECT	; ...сектор
	CALL	FISRD
DRIV34:	LDA	SSECT
	RAR
	MOV	H,A
	MVI	A,0
	RAR
	MOV	L,A	; HL = (сектор % 8) * 128
	LXI	D,RDMA
	DAD	D
	SHLD	WRKDMA
	LDA	OPER0	; 0-запись, 1-чтение
	DCR	A
	JZ	DRIV35	; >> чтение
	CALL	WRIT10
	JMP	DRIV36
;
DRIV35:	CALL	READ10
DRIV36:	LDA	OPER0	; 0-запись, 1-чтение
	DCR	A
	RZ		; >> выход, если чтение
	LDA	TYPEWR	; тип записываемого сектора
	CPI	1
	JZ	DRIV40	; >> если это директория
	LDA	SSECT
	STA	SSECT0
	CPI	7	; (сектор % 8) <> 7 ?
	RNZ
	MVI	A,1
	STA	PISAT
	RET
;
DRIV40:	XRA	A
	STA	PISAT
	CALL	FISWR
	RET
;
FISRD:	MVI	A,8
	STA	WOPER
	LDA	ODISK
	CPI	0F0h
;	CALL	TSTHDD
	JZ	RDHDD	; >> чтение с НЖМД
FSRD00:	DI
	CALL	POWER
	LDA	OSECT
	INR	A
	OUT	19H
	LXI	H,RDMA
	MVI	C,3
	MVI	A,80H
	OUT	1BH
FSRD10:	IN	1BH
	RRC
	JNC	FSRD10
	DCX	H
	MOV	A,M
FSRD11:	MOV	M,A
	INX	H
FSRD12:	IN	1BH
	ANA	C
	JPO	FSRD12
	IN	18H
	JM	FSRDNR
	JNZ	FSRD11
	MOV	A,B
	OUT	1CH
	IN	1BH
	ANI	0DDH
	STA	ERROR
	EI
	RZ
	ANI	10H
	CNZ	TRAN99
	LXI	H,WOPER
	DCR	M
	JNZ	FSRD00
	LDA	ERROR
	ANI	10H
	JZ	FSWR20
	LXI	H,STRSEE
	CALL	ASK
	JMP	FISRD
;
FSRDNR:	LXI	H,STRNTR
	CALL	ASK
	JMP	FSRD00
;
FISWR:	MVI	A,8
	STA	WOPER
	LDA	ODISK
	CPI	0F0h
;	CALL	TSTHDD
	JZ	WRHDD	; >> запись на НЖМД
FSWR00:	DI
	CALL	POWER
	LDA	OSECT
	INR	A
	OUT	19H
	LXI	H,RDMA
	MVI	C,83H
	MVI	A,0A0H
	OUT	1BH
FSWR10:	IN	1BH
	RRC
	JNC	FSWR10
FSWR11:	IN	1BH
	ANA	C
	JPO	FSWR11
	MOV	A,M
	OUT	18H
	INX	H
	JM	FSWRNR
	JNZ	FSWR11
	MOV	A,B
	OUT	1CH
	IN	1BH
	ANI	0DDH
	STA	ERROR
	MOV	H,A
	EI
	ANI	40H
	JNZ	WRPROT
	MOV	A,H
	ANA	A
	RZ
	ANI	10H
	CNZ	TRAN99
	LXI	H,WOPER
	DCR	M
	JNZ	FSWR00
	LDA	ERROR
	ANI	10H
	JZ	FSWR20
	LXI	H,STRSEE
	CALL	ASK
	JMP	FISWR
;
FSWR20:	LDA	3FH	; режим обработки ошибок
	CPI	2
	RNC
	DCR	A
	RZ
	LXI	H,STR1	; вывод ошибки диска
	CALL	FSWR22
	LDA	ERROR
	CALL	HEXOUT	; код ошибки
	CALL	FSWR22
	LDA	OPER0	; 0-запись, 1-чтение
	CALL	HEXOUT	; операция
	CALL	FSWR22
	LDA	DISK0
	CALL	HEXOUT	; диск
	CALL	FSWR21	; трек и сектор
	CALL	FSWR22	; вопрос...
	CALL	KEYE
	ANI	5FH
	CPI	'D'
	JZ	FSSC10
	CPI	'Y'
	JZ	FSSC10
	LDA	ERROR
	RET

FSWR21:	CALL	FSWR22	; вывод номера трека и сектора
	LDA	HTRC0	; старший разряд
	CALL	HEXOUT
	LDA	TRC0	; младший разряд
	CALL	HEXOUT
	CALL	FSWR22
	LDA	SECT0
	CALL	HEXOUT
	RET
;
FSWRNR:	LXI	H,STRNTR
	CALL	ASK
	JMP	FSWR00
;
FSWR22:	MOV	A,M
	INX	H
	ANA	A
	RZ
	MOV	C,A
	CALL	PRINTC
	JMP	FSWR22
;
KEYE:	CALL	KEY
	PUSH	PSW
	MOV	C,A
	CALL	PRINTC
	POP	PSW
	RET
;
STR1:;	.DB 10,"ERR=",0," OPR=",0," DSK=",0," TRK=",0," SEC=",0
;	.DB 10,"ОШИБКА ",0,", Опер.=",0," Диск=",0
	.DB 10,"я√щтыс ",0,", я╨┼╥.=",0," ф╔╙╦=",0
STR2:;	.DB " Дор.=",0," Сект.=",0
	.DB " ф╧╥.=",0," є┼╦╘.=",0
STR0:;	.DB 10," ОШИБКА ДИСКА,ПРОДОЛЖИМ ?",7,0
	.DB 10," я√щтыс фщєыс,ЁЄяфяьЎщэ ?",7,0
STRSEE:;.DB 10," ОШИБКА ПОЗИЦИОНИРОВАНИЯ !",7,0
	.DB 10," я√щтыс Ёя·щущяющЄяўсющё !",7,0
STRSE0:;.DB 10,"1-Повторить,2-Прервать ?",0
	.DB 10,"1-Ё╧╫╘╧╥╔╘╪,2-Ё╥┼╥╫┴╘╪ ?",0
STRWPR:;.DB 10," ДИСК ЗАЩИЩ╟Н ОТ ЗАПИСИ !",7,0
	.DB 10," фщєы ·с¤щ¤░ю яЇ ·сЁщєщ !",7,0
STRNTR:;.DB 10," ДИСК НЕ ГОТОВ !",7,0
	.DB 10," фщєы юх чяЇяў !",7,0
;
FSSC10:	XRA	A
	STA	ERROR
	RET
;
PRINTH:	MOV	A,H
	CALL	HEXOUT
	MOV	A,L
	JMP	HEXOUT
;
ASK:	CALL	PRINT
	LXI	H,STRSE0
	CALL	PRINT
	LDA	3FH	; режим обработки ошибок
	DCR	A
	RZ
	EI
	CALL	KEYE
	DI
	CPI	31H
	RZ
	JMP	0
;
WRPROT:	LXI	H,STRWPR
	CALL	ASK
	JMP	FSWR00
;
PORT1C:	.DB	34H
POWER:	CALL	MOTOR
	LDA	OTRACK	; <- можно 8 бит
	ANA	A
	RAR
	STA	FTRACK
	LDA	ODISK
	ANI	1
	LXI	H,TTRC
	JZ	$+4
	INX	H
	MOV	A,M
	OUT	1AH
	LDA	FTRACK
	MOV	M,A
TRAN2F:	OUT	18H
TRAN30:	MVI	A,10H
	OUT	1BH
	CALL	WAIT
TRAN31:	MOV	A,B
	OUT	1CH
	IN	1BH
	RRC
	JC	TRAN31
	LDA	PORT1C
	OUT	1CH
WAIT:	MVI	A,60H
	DCR	A
	JNZ	$-1
	RET
;
TRAN99:	XRA	A
	OUT	1BH
	CALL	WAIT
TRAN9A:	MOV	A,B
	OUT	1CH
	IN	1BH
	RRC
	JC	TRAN9A
	CALL	WAIT
	LDA	FTRACK
	JMP	TRAN2F
;
MOTOR:	LDA	ODISK
	ANI	3
	MOV	H,A
	LDA	OTRACK	; <- можно 8 бит
	ANI	1
	XRI	1
	RLC
	RLC
	ORA	H
	MOV	B,A
	ORI	30H
	STA	PORT1C
	LXI	H,0
MOTR10:	MOV	A,B
	OUT	1CH
	IN	1BH
	RLC
	RNC		; >>>>
	XTHL
	XTHL
	DCX	H
	XTHL
	XTHL
	MOV	A,H
	ORA	L
	JNZ	MOTR10
	MVI	A,80H
	STA	ERROR
	LXI	H,STRNTR
	CALL	ASK
	JMP	MOTR10-3
;
NBDSPR:	MOV	C,E
	JMP	BDPRNT
;
NBDOS:	MOV	A,C	; << сюда в итоге прилетает по call 5
	CPI	2
	JZ	NBDSPR
	LXI	H,TBTRAP
NBDS00:	MOV	A,M
	ANA	A
	JZ	NBDS10
	CMP	C
	INX	H
	JNZ	NBDS00	; цикл
	MOV	A,D
	CPI	9FH
	JC	CPM	; >> D < 9Fh
	CPI	0E0H
	JNC	CPM	; >> D => E0h
	PUSH	D
	PUSH	B
	CALL	BDWRIT	; >> запись на КД через vird7
	LXI	D,VRTBUF	; исп. как буфер командной строки???
	POP	B
	CALL	CPM
	XTHL
	PUSH	D
	PUSH	PSW
	CALL	BDREAD	; >> чтение с КД через vird7
	POP	PSW
	POP	D
	POP	H
	RET
;
TBTRAP:	.DB 15,16,17,19,20,21,22,23,30,33,34,35,36,40,0
;
NBDS10:	MOV	A,C
	CPI	80H	; проверка на функции 80h
	JNZ	CPM
	MOV	A,B
	CPI	16
	JNC	CPM
	MOV	C,B
	MVI	B,0
	LXI	H,NBDSTB
	DAD	B
	DAD	B
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	PCHL
;
NBDSTB:	.DW TEST,USED,CINP,COUT,COUCLS,IBAT,BATS
	.DW GBATP,GFBAT,VBIOS,FBAT,SCOM,DCOM
	.DW CHKDSK,GETHDD,SETHDD
;
CHKDSK:	MVI	C,29	; Получение вектора защиты записи
	CALL	CPM
	XCHG		; DE = [PONMLKJI HGFEDCBA]
	LDA	CURDSK
	LXI	H,1
	MOV	C,A
	CALL	BDRS10	; [A][HL] = [A][HL] ^ (CURDSK + 1)
	MOV	A,D
	ANA	H
	MOV	H,A
	MOV	A,E
	ANA	L
	ORA	H
	RZ		; >> выход при HL&DE = 0
	JMP	BDREST
;
SCOM:	LXI	H,ACOMBF
	XCHG		; DE= куда, HL= откуда
	MVI	B,12	; сколько
	CALL	COPY10	; кипируем
	MVI	A,-1
	STA	FACOM
	RET
;
DCOM:	INR	E
	LDA	FACOM
	RZ
	XRA	A
	STA	FACOM
	RET
;
VBIOS:	XCHG
	MOV	E,M
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
	LXI	H,CBIOS+6
	MOV	A,E
	ADD	A
	ADD	E
	CALL	HLA
	PCHL
GFBAT:	LDA	FLBAT
	RET
;
GBATP:	XCHG
	MOV	C,M
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	LXI	H,BATPAR
	MOV	A,M
	ANA	A
	JZ	GBAT10
	INX	H
	INR	C
GBAT04:	CALL	GBAT02
	JC	GBAT10
	INX	H
	JZ	GBAT04
	DCX	H
	DCR	C
	JZ	GBAT06
GBAT05:	CALL	GBAT02
	JC	GBAT10
	INX	H
	JNZ	GBAT05
	JMP	GBAT04
;
GBAT06:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	CALL	GBAT02
	JC	GBAT07
	JNZ	GBAT06
GBAT07:	XRA	A
	STAX	D
	XCHG
	RET
;
GBAT10:	MVI	A,-1
	RET
;
GBAT02:	MOV	A,M
	CPI	20H
	RZ
	CPI	9
	RZ
	ANA	A
	STC
	RZ
	CMC
	RET
;
CINP:	LDAX	D
	ANA	A
	JNZ	CINP02
	PUSH	D
	MVI	C,25
	CALL	CPM
	INR	A
	POP	D
	STAX	D
CINP02:	LXI	H,CINPBF
	PUSH	H
	XCHG		; DE= куда, HL= откуда
	MVI	B,12	; сколько
	CALL	COPY10	; копируем
	XCHG
	LXI	B,1800H
	CALL	FILL	; заполнение памяти значением C с адр(HL) B байт
	POP	D
	MVI	C,15
	CALL	CPM
	CPI	-1
	RZ
	XRA	A
	STA	ACCTYP
	LXI	H,CINDAT
	CALL	ACCE20
	JNZ	CINP10
	XRA	A
	STA	CINSCN
	DCR	A
	STA	FLCINP
	STA	KLAV
	LXI	H,CINKEY
	SHLD	CBIOS+10
CINP10:	XRA	A
	RET
;
IBAT:	LDAX	D
	ANA	A
	JNZ	IBAT02
	PUSH	D
	MVI	C,25
	CALL	CPM
	INR	A
	POP	D
	STAX	D
IBAT02:	LXI	H,BATBF
	PUSH	H
	XCHG		; DE= куда, HL= откуда
	MVI	B,12	; сколько
	CALL	COPY10	; копируем
	XCHG
	LXI	B,1800H
	CALL	FILL	; заполнение памяти значением C с адр(HL) B байт
	LXI	H,80H	; откуда
	LXI	D,BATPAR	; куда
	MVI	B,128	; сколько
	CALL	COPY10	; копируем
	POP	D
	MVI	C,15
	CALL	CPM
	CPI	-1
	RZ
	XRA	A
	STA	ACCTYP
	LXI	H,BATDAT
	CALL	ACCE20
	JNZ	IBAT10
IBAT04:	XRA	A
	STA	BATSCN
	DCR	A
	STA	FLBAT
	STA	BTKLAV
IBAT10:	XRA	A
	RET
;
FBAT:	LXI	H,80H	; откуда
	LXI	D,BATDMA	; куда
	MVI	B,128	; сколько
	CALL	COPY10	; копируем
	JMP	IBAT04
;
COUT:	LDAX	D
	ANA	A
	JNZ	COUT02
	PUSH	D
	MVI	C,25
	CALL	CPM
	POP	D
	INR	A
	STAX	D
COUT02:	LXI	H,COUTBF
	PUSH	H
	XCHG		; DE= куда, HL= откуда
	MVI	B,12	; сколько
	CALL	COPY10	; копируем
	XCHG
	LXI	B,1800H
	CALL	FILL	; заполнение памяти значением C с адр(HL) B байт
	POP	D
	MVI	C,15
	CALL	CPM
	CPI	-1
	MVI	A,-1
	RNZ
	LXI	D,COUTBF
	MVI	C,22
	CALL	CPM
	CPI	-1
	RZ
	LXI	H,COUDMA
	LXI	B,801AH
	CALL	FILL	; заполнение памяти значением C с адр(HL) B байт
	XRA	A
	STA	COUSCN
	DCR	A
	STA	FLCOUT
	LXI	H,COUPRN
	SHLD	CBIOS+13
	XRA	A
	RET
;
COUCLS:	LDA	FLCOUT
	ANA	A
	RZ
	MVI	A,-1
	STA	ACCTYP
	LXI	H,COUDAT
	CALL	ACCE20
	LXI	D,COUTBF
	MVI	C,16
	CALL	CPM
	XRA	A
	STA	FLCOUT
	LXI	H,PRINTC
	SHLD	CBIOS+13
	RET
;
COUPRN:	LXI	H,COUDAT
	CALL	WACCES
	CNZ	COUCLS
	JMP	PRINTC
;
CINKEY:	LDA	FLCINP
	INR	A
	JNZ	CINK10
	LXI	H,CINDAT
	CALL	CINK00
	RC
CINK10:	XRA	A
	STA	FLCINP
	LXI	H,KEY
	SHLD	CBIOS+10
	JMP	KEY
;
BATS:	LDA	FLBAT
	ANA	A
	MVI	A,1AH
	RZ
	LXI	H,BATDAT
	CALL	CINK00
	RC
	XRA	A
	STA	FLBAT
	MVI	A,1AH
	RET
;
CINK00:	DCX	H
	MOV	A,M
	CPI	-1
	JNZ	CINK08
	INX	H
	CALL	RACCES
	JNZ	CINK09
	PUSH	PSW
	CALL	TS0D0A
	JNZ	CINK06
	CALL	RACCES
	DCX	H
	MVI	M,1AH
	JNZ	CINK06
	CALL	TS0D0A
	MVI	M,-1
	JZ	CINK06
	MOV	M,A
CINK06:	POP	PSW
CINK08:	CPI	1AH
	STC
	RNZ
CINK09:	XRA	A
	RET
;
TS0D0A:	CPI	10
	RZ
	CPI	13
	RET
;
WACCES:	MVI	A,-1
	JMP	ACCES
;
RACCES:	XRA	A
ACCES:	STA	ACCTYP
	PUSH	H
	MOV	A,M
	ANA	A
	JP	ACCE10
	PUSH	B
	CALL	ACCE20
	POP	B
	POP	H
	RNZ
	PUSH	H
	XRA	A
	MOV	M,A
ACCE10:	INR	M
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	CALL	HLA
	LDA	ACCTYP
	INR	A
	JZ	ACCE12
	XRA	A
	MOV	A,M
	POP	H
	RET
;
ACCE12:	MOV	M,C
	POP	H
	RET
;
ACCE20:	XCHG
	LHLD	BDDAT
	PUSH	H
	LHLD	BDDAT2
	PUSH	H
	LHLD	BDDAT3
	PUSH	H
	XCHG
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
	LDA	ACCTYP
	INR	A
	JZ	ACCE22
	PUSH	D
	PUSH	B
	LXI	D,DIRBUF
	MVI	C,1AH
	CALL	CPM
	POP	D
	MVI	C,20
	CALL	CPM
	POP	D
	LXI	H,DIRBUF	; DE= куда, HL= откуда
	PUSH	PSW
	MVI	B,128	; сколько
	CALL	COPY10	; копируем
	POP	PSW
	ANA	A
ACCE21:	POP	H
	SHLD	BDDAT3
	POP	H
	SHLD	BDDAT2
	POP	H
	SHLD	BDDAT
	RET
;
ACCE22:	PUSH	D
	PUSH	B
	LXI	H,DIRBUF
	PUSH	H
	XCHG		; DE= куда, HL= откуда
	MVI	B,128	; сколько
	CALL	COPY10	; копируем
	POP	D
	MVI	C,1AH
	CALL	CPM
	POP	D
	MVI	C,21
	CALL	CPM
	POP	H
	PUSH	PSW
	LXI	B,801AH
	CALL	FILL	; заполнение памяти значением C с адр(HL) B байт
	POP	PSW
	ANA	A
	JMP	ACCE21
;
HLA:	ADD	L
	MOV	L,A
	RNC
	INR	H
	RET
;
; тестирование КД: вход DE
; D= номер диска; E= Х-тест, 1-восстановить КС, 2-форматирование
TEST:	LDA	3FH	; режим обработки ошибок
	PUSH	PSW
	MOV	C,D	; установка диска
	PUSH	D
	CALL	SELDSK
	POP	D
	CPI	2
	JC	TSTOK	; D<2  >>> неправильный диск
	MOV	A,H
	ORA	L
	JZ	TSTOK	; HL=0 >>> неправильный диск
	LXI	B,000Ah
	DAD	B	; HL = ссылка на пареметры диска (DRIVEC)
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A	; HL = ссылка на PARC
	MOV	A,M	; начальный сектор (8, тестируем с конца КД)
	STA	SECT
	STA	TSECT+1	; -> заносим в цикл по секторам
	MVI	C,5
	DAD	B	; HL = ссылка на количество секторов
	MOV	A,M	; начальный трек (235)
	STA	TRACK
	LXI	H,DIRBUF
	SHLD	DMA
	LXI	B,80E5H
	CALL	FILL	; заполнение памяти значением C с адр(HL) B байт
	MVI	A,1	; проверяем режим тестирования
	CMP	E
	JC	TST0	; E>1 (тест/форматирование КД)
	ADD	E	; E=1 (тест с исправлением КС) или Е=0
TST0:	INR	A
	STA	3FH	; режим обработки ошибок (тест.и форм.=2, испр.=3)
	SUB	E
	JZ	TST1	; А=0, форматирование
	MVI	A,1	; <<< чтение с дискового устройства
TST1:	STA	OPER	; 0-запись, 1-чтение
;;	LXI	H,STTS2	; "Форматирование квази-диска"
;;	CZ	FSWR22
	LXI	H,PARAM
	LXI	D,PARAM0
	MVI	B,7
	CALL	COPY10	; копирование из adr(PARAM) в adr(PARAM0) B=7 байт
TEST20:	LDA	OPER0
	ANA	A
	JZ	FRMTKV	; >> КД, переход к форматированию
	CALL	KVRD	; чтение сектора
	ANA	A
	JZ	TEST22
	LXI	H,STRTS	; вывод ошибки
	CALL	FSWR22
	LDA	ERROR
	CALL	HEXOUT	; код ошибки
	PUSH	H
	LXI	H,STR2
	CALL	FSWR21	; трек и сектор
	POP	H
	LDA	3FH	; режим обработки ошибок
	CPI	3
	CNC	FSWR22	; "исправлено"
	JMP	TEST22
;
FRMTKV:	LXI	H,DISK0	; (нужно для WRITKV)
	CALL	WRITKV	; запись сектора
TEST22:	LXI	H,SECT0
	DCR	M
	JNZ	TEST20	; цикл по секторам 8..1
TSECT:	MVI	M,8	; <- изменяется по конфигурации КД
	LXI	H,TRC0
	MOV	A,M
	DCR	M
	ORA	A	; CPI	0FFh
	JNZ	TEST20	; цикл по трекам 235..0 (на выходе А=0)
	DCX	H	; =OPER0: 0-запись, 1-чтение
	ORA	M
	LXI	H,STTS1	; "Квази-диск отформатирован."
	CZ	FSWR22
TSTOK:	POP	PSW
	STA	3FH	; режим обработки ошибок
	XRA	A
	RET
;
STRTS:;	.DB 10,"ОШИБКА КВАЗИДИСКА:",0
	.DB 10,"я√щтыс ыўс·щфщєыс:",0
;;	.DB ",ДОРОЖКА=",0,",СЕКТОР=",0
;;	.DB ",фяЄяЎыс=",0,",єхыЇяЄ=",0
;	.DB " -ИСПРАВЛЕНО",0
	.DB " -щєЁЄсўьхюя",0
STTS1:;	.DB 10,"Квази-диск отформатирован."
	.DB 10,"ы╫┴┌╔-─╔╙╦ ╧╘╞╧╥═┴╘╔╥╧╫┴╬.",0
;
ZAGA:	.DW 0,0,0,0,DIRBUF,PARA,CSVA,ALVA
ZAGB:	.DW 0,0,0,0,DIRBUF,PARB,CSVB,ALVB
ZAGC:	.DW 0,0,0,0,DIRBUF,PARK,0,ALVC
ZAGD:	.DW 0,0,0,0,DIRBUF,PARK,0,ALVD
;PARA:	.DW 40			; перенесено в virt.asm
;	.DB 4,15,0
;	.DW 187H,127,0C0H,32,8
;PARB:	.DW 40
;	.DB 4,15,0
;	.DW 187H,127,0C0H,32,8
;PARC:	.DW 8
;	.DB 3,7,0
;	.DW 235,63,0C0H,0,0	; было 219...
;DIRBUF:	.DS	128	; <=
;CSVA:	.DS	32	; <=
;CSVB:	.DS	32	; <=
;ALVA:	.DS	51	; <=
;ALVB:	.DS	51	; <=
;ALVC:	.DS	33	; <=
;
TTRC:	.DB 0,0
PARAM0:	.DS	7	; <=
PARAM:	.DS	7	; <=
ODISK:	.DB	-1	; номер диска	-- что сейчас в DMA
OOPER:	.DB	1	; операция	-- что сейчас в DMA	0-запись, 1-чтение
OTRACK:	.DW	-1	; номер трека	-- что сейчас в DMA
OSECT:	.DB	-1	; сектор диска	-- что сейчас в DMA
SSECT:	.DB	-1	; (сектор CPM - 1) % 8 -- смещение
PISAT:	.DB	0
ERROR:	.EQU	3DH
DISK:	.EQU	PARAM	; диск
OPER:	.EQU	PARAM+1	; 0-запись, 1-чтение
TRACK:	.EQU	PARAM+2	; трек, мл.байт
HTRC:	.EQU	PARAM+3	; трек, ст.байт
SECT:	.EQU	PARAM+4	; сектор
DMA:	.EQU	PARAM+5	; адрес DMA
DISK0:	.EQU	PARAM0
OPER0:	.EQU	PARAM0+1
TRC0:	.EQU	PARAM0+2
HTRC0:	.EQU	PARAM0+3
SECT0:	.EQU	PARAM0+4
DMA0:	.EQU	PARAM0+5
DRIVEA:	.EQU	ZAGA
DRIVEB:	.EQU	ZAGB
DRIVEC:	.EQU	ZAGC
DRIVED:	.EQU	ZAGD
VRTBUF:	.DS	40	; <=
SSECT0:	.DB	0	; сектор СРМ в DMA (смещение)
WRKDMA:	.DW	0	; ссылка на сектор CPM в DMA
;
USED:	MVI	C,31	; <<<< функция 1/80h -- свободно на диске, Кб
	CALL	CPM	; Получение адреса блока параметров диска
	INX	H
	INX	H
	MOV	A,M
	CPI	3
	PUSH	PSW
	INX	H
	INX	H
	INX	H
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A	; HL = (число секторов диска) - 1
	INX	H
	PUSH	H
	PUSH	H
	MVI	C,27
	CALL	CPM	; Получить адрес вектора распределения диска ALVC
	POP	D
	LXI	B,0
USED10:	PUSH	H
	MOV	L,M
	MVI	H,8
USED12:	MOV	A,L
	RLC
	MOV	L,A
	JC	$+4	; (1)>
	INX	B
	DCX	D	; <(1)
	MOV	A,D
	ORA	E
	JZ	USED14
	DCR	H
	JNZ	USED12
	POP	H
	INX	H
	JMP	USED10
;
USED14:	POP	H
	POP	D
	MOV	H,B
	MOV	L,C
	DCX	D
	DCX	D
	POP	PSW
	RZ
	DAD	H
	XCHG
	DAD	H
	XCHG
	RET
;
FILL:	MOV	M,C	; заполнение памяти значением C с адр(HL) B байт
	INX	H
	DCR	B
	JNZ	FILL
	RET
;
KLAV:	.DB	0
CINDAT:
CINSCN:	.DB	0
	.DW	CINDMA
	.DW	CINPBF
FLCINP:	.DB	0
COUDAT:
COUSCN:	.DB	0
	.DW	COUDMA
	.DW	COUTBF
FLCOUT:	.DB	0
BTKLAV:	.DB	0
BATDAT:
BATSCN:	.DB	0
	.DW	BATDMA
	.DW	BATBF
FLBAT:	.DB	0
ACCTYP:	.DB	0
FACOM:	.DB	0
CINPBF:	.DS	36	; <=
CINDMA:	.EQU	ZAPL
COUTBF:	.DS	36	; <=
COUDMA:	.EQU	ZAPL2
BATBF:	.DS	36	; <=
BATDMA:	.DS	128	; <=
HDDA:	.DW	00001h	; номер дискеты в HEX
	.DW	00002h	; номер первого сектора в HEX, мл.разряд 24bit
	.DB	000h	; номер первого сектора в HEX, ст.разряд 24bit
;	.DB	1,0,2,0,0
HDDB:	.DB	0,0,0,0,0
;
SETHDD:	LDA	4
	CPI	2
	MOV	C,A
	MVI	A,0FFH
	RNC
HDDAT:	LXI	H,-1	; <= значение меняется из RDSH  -- (FFFFh - (число дискет))
	DAD	D
	RC
	LXI	H,HDDB
	DCR	C
	JZ	$+6
	LXI	H,HDDA
	MOV	M,E
	INX	H
	MOV	M,D
	PUSH	H
	LXI	H,0F3BEH	; = 2 - 0622h * 2
	MVI	A,-1
	INX	D
SETH10:	LXI	B,1570	; = 0622h -- суммарное количество секторов на одной дискете
	DAD	B
	ACI	0
	DCX	D
	MOV	B,A
	MOV	A,D
	ORA	E
	MOV	A,B
	JNZ	SETH10
	XCHG
	POP	H
	INX	H
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	MOV	M,A
	XRA	A
	RET
;
GETHDD:	LHLD	HDDAT+1
	CALL	NEGHL
	DCX	H
	PUSH	H
	LXI	H,HDDB
	DCR	E
	JZ	$+6
	LXI	H,HDDA
	MOV	E,M
	INX	H
	MOV	D,M
	POP	H
	XCHG
	RET
;
NEGHL:	MOV	A,L
	CMA
	MOV	L,A
	MOV	A,H
	CMA
	MOV	H,A
	INX	H
	RET
;
WRHDD:	MVI	C,10h	; C=10h признак записи
	JMP	HDD
RDHDD:	MVI	C,0	; C=0 признак чтения
HDD:	CALL	READY
	JZ	HDDERR
	LHLD	OTRACK
	LDA	OSECT	; (HL,A) = номер сектора LBA (24 бита)
	OUT	053H	; LBA [7..0]
	MOV	A,L
	OUT	054H	; LBA [15..8]
	MOV	A,H
	OUT	055H	; LBA [23..16]
	MVI	A,0E0h	; 1110 0000
	OUT	056H	; режим и LBA[27..24]
REPOP:	MVI	A,2	; количество читемых/записываемых секторов
	OUT	052H	; Счетчик числа секторов для операции чтения/записи
	LXI	H,RDMA
	MVI	A,020H	; A = 2xH - сектор чтения (x = retry and ECC-read)
	ADD	C	; A = 3xH - сектор записи
	OUT	057H
	MVI	E,2	; счётчик секторов
AD8AD:	CALL	READY
	JZ	ERHDD
;;;	IN	057H
	ANI	008H	; 0000 1000 :	запрос данных. Буфер ждет данных (занято)
	JZ	ERHDD
	MVI	B,2	; 2*256 -- размер сектора НЖМД
AD8BC:	INR	C
	DCR	C	; установка признака Z по C
	JNZ	AD8CF
AD8C1:	IN	050H	; чтение с НЖМД
	MOV	M,A
	INR	L
	IN	058H
	MOV	M,A
	INR	L
	JNZ	AD8C1
	INR	H
	DCR	B
	JNZ	AD8C1	; цикл чтения сектора НЖМД
	JMP	AD8DC
;
AD8CF:	INR	L	; запись на НЖМД
	MOV	A,M
	OUT	058H
	DCR	L
	MOV	A,M
	OUT	050H
	INR	L
	INR	L
	JNZ	AD8CF
	INR	H
	DCR	B
	JNZ	AD8CF	; цикл записи сектора НЖМД
AD8DC:	DCR	E
	JNZ	AD8AD
	CALL	READY
	JZ	ERHDD
	ANI	0DDH	; 1101 1101 -- маскируем лишнее
	CPI	050H	; норм. код возврата
	RZ
ERHDD:	LXI	H,WOPER
	DCR	M
	JNZ	REPOP
	JMP	HDDERR
;
READY:	PUSH	D
	PUSH	B
	MVI	D,005H	; пять раз...
AD9DD:	IN	057H	; регистр статуса
	ANI	0C0H	; 1100 0000
	CPI	040H	; 0100 0000 устройство готово к операции
	JZ	AD9F2	; >> выход из цикла, при выходе A=40h
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	AD9DD	; цикл на 65536 попыток
	DCR	D
	JNZ	AD9DD	; цикл на 5*65536 попыток, при выходе A,B,C,D=0
;;;	OUT	05FH	; <= !!!!!
AD9F2:	ANA	A
	POP	B
	POP	D
	IN	057H
	RET		; <= !!!!!
;
HDDERR:;IN	057H	; регистр статуса
	RRC		; сдвиг вправо, бит 0 заносится в признак С
	IN	051H	; Чтение:	Регистр ошибок. Содержит признаки последней ошибки.
	JC	ADA02	; если предыдущая команда закончилась с ошибкой
	XRA	A	; ошибки нет
ADA02:	MOV	B,A	; В = код ошибки
	IN	057H	; регистр статуса
	ANI	020H	; выделяем ошибку "сбой записи"
	ORA	B
	MOV	B,A	; дополняем код ошибки в В
	IN	057H
	ANI	0C0H	; выделение сигналов "устройство готово" и "занято"
	CPI	040H	; уст.Z если "готово"
	MOV	A,B	; код ошибки в A
	JZ	ADA15	; переход, если сигнал "готово"
	MVI     A,10h	; 1xH = сброс на цилиндр 0 (x = step rate)
	OUT	05FH	; Системный сброс (лучше не пользоваться, сходство с 57Н без обнуления микросхем жесткого диска).
ADA15:	STA	ERROR
	JMP	FSWR20	; На обработку ошибки
;
