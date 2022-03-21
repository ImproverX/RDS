	.ORG    00100h
INITCN:	.EQU	0CA00H
DISKS:	.EQU	0AE46H	; количество дисковых устройств -1
L_0100: LXI  SP,00080h
        DI
        MVI  A, 020h	; 0010 0000b -- банк 3 как ОЗУ A000-DFFFh
        OUT     010h
        CALL    INITCN
        EI
	CALL	TDSK	; тест наличия КД11
	STA	DISKS
	CPI	3
	JZ	L_DONE
	MVI  A, 20h	; =" "
	STA	DMARK	; затираем букву "D"
L_DONE:	LXI  D, L_0160	; надпись
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
	.ORG    0015Fh
L_0160:	.DB 00Ch
	.DB 01Bh, 02Fh
	.DB 01Bh, 062h
	.DB 099h  ; <Щ> - |■  ■■  ■| (offset 0065h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0066h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0067h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0068h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0069h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Ah)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Bh)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Ch)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Dh)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Eh)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Fh)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0070h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0071h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0072h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0073h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0074h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0075h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0076h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0077h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0078h)
	.DB 08Bh  ; <Л> - |■   ■ ■■| (offset 0079h)
	.DB 00Ah  ; <_> - |    ■ ■ | (offset 007Ah)
	.DB 08Ah  ; <К> - |■   ■ ■ | (offset 007Bh)
	.DB "     "
	.DB 0F2h  ; <Є> - |■■■■  ■ | (offset 0081h)
	.DB 0E4h  ; <ф> - |■■■  ■  | (offset 0082h)
	.DB 0F3h  ; <є> - |■■■■  ■■| (offset 0083h)
	.DB " V3.07     "
	.DB 08Ah  ; <К> - |■   ■ ■ | (offset 008Fh)
	.DB 00Ah  ; <_> - |    ■ ■ | (offset 0090h)
	.DB 08Ah  ; <К> - |■   ■ ■ | (offset 0091h)
	.DB "    "
	.DB 0F7h  ; <ў> - |■■■■ ■■■| (offset 0096h)
	.DB 0C5h  ; <┼> - |■■   ■ ■| (offset 0097h)
	.DB 0CBh  ; <╦> - |■■  ■ ■■| (offset 0098h)
	.DB 0D4h  ; <╘> - |■■ ■ ■  | (offset 0099h)
	.DB 0CFh  ; <╧> - |■■  ■■■■| (offset 009Ah)
	.DB 0D2h  ; <╥> - |■■ ■  ■ | (offset 009Bh)
	.DB " 06"
	.DB 0E3h  ; <у> - |■■■   ■■| (offset 009Fh)
	.DB "+    "
	.DB 08Ah  ; <К> - |■   ■ ■ | (offset 00A5h)
	.DB 00Ah  ; <_> - |    ■ ■ | (offset 00A6h)
	.DB 08Ah  ; <К> - |■   ■ ■ | (offset 00A7h)
	.DB "  CP/M BDOS V2.2+  "
	.DB 08Ah  ; <К> - |■   ■ ■ | (offset 00BBh)
	.DB 00Ah  ; <_> - |    ■ ■ | (offset 00BCh)
	.DB 08Ah  ; <К> - |■   ■ ■ | (offset 00BDh)
	.DB "  ABC"
DMARK:	.DB "D-disk drive  "
	.DB 08Ah  ; <К> - |■   ■ ■ | (offset 00D1h)
	.DB 00Ah  ; <_> - |    ■ ■ | (offset 00D2h)
	.DB 098h  ; <Ш> - |■  ■■   | (offset 00D3h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0066h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0067h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0068h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0069h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Ah)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Bh)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Ch)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Dh)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Eh)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 006Fh)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0070h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0071h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0072h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0073h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0074h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0075h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0076h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0077h)
	.DB 09Dh  ; <Э> - |■  ■■■ ■| (offset 0078h)
	.DB 08Ch  ; <М> - |■   ■■  | (offset 00E7h)
	.DB 00Ah, 01Bh, 061h
	.DB " 62,5Kb free.", 00Ah,'$'
	.ORG	01FFh	; выравнивание размера
	.DB 000h
	.END
