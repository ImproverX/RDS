	.ORG    00100h
INITCN:	.EQU	0CA00H
DISKS:	.EQU	0AE46H	; количество дисковых устройств -1
L_0160:	.EQU	0BF66H	; надпись при загрузке ОС
DMARK:	.EQU	L_0160+99
L_BUFT:	.EQU	0D7F3h	; "AUTOEXEC..." для БУФ (в virt)
M_E000:	.EQU	0E000H	; БУФ для запуска AUTOEXEC.BAT (31 байт)
;
L_0100:	LXI  SP,00080h
	DI
	MVI  A, 020h	; 0010 0000b -- банк 3 как ОЗУ A000-DFFFh
	OUT     010h
	CALL    INITCN
	EI
	CALL	TDSK	; тест наличия КД11
	STA	DISKS	; сохраняем количество дисков в системе
	MVI  A, 44h	; ='D'
	JZ	L_DONE
	MVI  A, 20h	; =' '
L_DONE:	STA	DMARK	; затираем букву 'D'
	LXI  H, L_BUFT	; ссылка на данные для БУФ (AUTOEXEC.BAT)
	LXI  D, M_E000	; куда копировать (БУФ)
	PUSH D		; сохр.в стек
BUFLP:	MOV  A, M
	STAX D
	INX  H
	INX  D
	ANA  A		; признаки по А
	JNZ     BUFLP	; цикл, пока А не обнулится
	LXI  D, L_0160	; надпись РДС в прямоугольнике
STAUB:	LXI  H, 0E4F2h	; ='РД'		<<- переход из rdsh
	SHLD    0000Bh
	LXI  H, 030F3h	; ='С' 3.0
	SHLD    0000Dh
	MVI  C, 009h
	CALL    5	; вывод надписи
	MVI  C, 00Dh	; сброс дисков
	CALL    5	; <<!! тут выдаёт ошибку при отсутствии НГМД и НЖМД
	POP  D		; адрес БУФ из стека
	LXI  H, 0000h
	SHLD	0080h	; параметры запуска (пустые)
	PUSH H		; заносим в стек адрес выхода в систему 0000h
	LXI	B,0580H	; вызов функции "Запуск BAT-файла"
	PUSH D
	PUSH B
	CALL	5	; запуск c C:...
	POP  B
	POP  H
	ANA  A
	RZ		; запуск прошёл успешно, старт системы >>>>>
	MVI  M, 1	; меняем в БУФ номер диска на первый (А:)
	XCHG		; адрес БУФ в DE
	JMP	5	; запуск c A:... и старт системы >>>>>
;	JMP     00000h
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
	RZ		; всё отлично, возвращаем (кол-во дисков -1) = 3 [и Z = 1]
	DCR	A
	RET		; возвращаем (кол-во дисков -1) = 2 [и Z = 0]
;
	.ORG	017Fh	; выравнивание размера
	.DB 000h
	.END
