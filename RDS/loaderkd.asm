	.ORG    00100h
INITCN:	.EQU	0CA00H
DISKS:	.EQU	0AE46H	; количество дисковых устройств -1
L_0160:	.EQU	0BF60H	; надпись при загрузке ОС
DMARK:	.EQU	L_0160+99
;
L_0100: LXI  SP,00080h
        DI
        MVI  A, 020h	; 0010 0000b -- банк 3 как ОЗУ A000-DFFFh
        OUT     010h
        CALL    INITCN
        EI
	CALL	TDSK	; тест наличия КД11
	STA	DISKS
	CPI	3
	MVI  A, 44h	; ='D'
	JZ	L_DONE
	MVI  A, 20h	; =" "
L_DONE:	STA	DMARK	; затираем букву "D"
	LXI  D, L_0160	; надпись
        MVI  C, 009h
        CALL    00005h	; вывод
        MVI  C, 00Dh
        CALL    00005h	; сброс дисков
        LXI  H, 0E4F2h	; ='РД'
        SHLD    0000Bh
        LXI  H, 030F3h	; ='С3'
        SHLD    0000Dh
        JMP     00000h
;
TDSK:	DI		; проверка наличия второго КД, возвр. кол-во дисков -1
	XRA	A
	OUT	10h
	OUT	11h	; отключаем все КД
	LXI	H,0A001h
	MOV	D,M	; считываем байт
	MVI	A,23h	; 0010 0011b -- банк 0 как ОЗУ A000-DFFFh
	OUT     011h	; на КД11
	MOV	A,D
	CMA		; инвертируем А
	MOV	M,A	; пишем инвертированную метку на КД2 (или память, если его нет)
	XRA     A
	OUT     011h	; отключаем второй КД
	MOV	A,M	; считываем байт
	XRA	D	; проверяем...
	MOV	M,D	; восстанавливаем значение в памяти (на всякий случай)
	MVI	A,020h	; 0010 0000b -- банк 3 как ОЗУ A000-DFFFh
	OUT     010h	; подключаем КД1 для РДС
	EI
	MVI	A,3
	RZ		; всё отлично, возвращаем (кол-во дисков -1) = 3
	DCR	A
	RET		; возвращаем (кол-во дисков -1) = 2
;
	.ORG	017Fh	; выравнивание размера
	.DB 000h
	.END
