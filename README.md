# RDS
Дисковая операционная система RDS для ПК Вектор-06ц. Поддерживает квази-диск (с патчем для КД на РУ7), два НГМД и НЖМД. Некоторое описание и документация [для пользователя](https://github.com/ImproverX/RDS/blob/master/manuals/rds-rpol.txt) и [для программиста](https://github.com/ImproverX/RDS/blob/master/manuals/rds-rpro.txt).

## Компиляция
Для сборки из исходников требуется компилятор TASM (Telemark Assembler, либо аналогичный для процессоров i8085) и упаковщик [LZSA](https://github.com/emmanuel-marty/lzsa).<br>
Бинарный файл собирается из:
|Смещение в файле|Содержимое|
|:-------|:----------|
|0000h   |rdsh|
|%OS%=(размер rdsh)|архив LZSA с остальными частями RDS|

Полученная программа запускается с адреса 0100h.
Содержимое архива собирается и при запуске распаковывается в память в таком порядке:
|Содержимое|Адрес распаковки, от..до|
|:------------------|:------------|
| loaderkd          |9400h..947Fh|
| ccph              |9480h..9FFFh|
| bdos              |A000h..ADFFh|
| bios (b7h)        |AE00h..BE78h|
| _(нули)_          |BE79h..BE97h|
| надпись 1 "РДС..."|BE98h..BF5Fh|
| надпись 2 "РДС..."|BF60h..BFFFh|
| шрифт             |C000h..C9FFh|
| disp              |CA00h..D2FFh|
| vird7             |D300h..D37Fh|
| virt              |D380h..D7DEh|
| _(нули)_          |D7DFh..DFFFh|

_Распаковка адресов от A000h до DFFFh выполняется на квази-диск, банк 3_

## История изменений
### Версия 3.07
- Перераспределение в памяти модулей
- Вызов SETTRC в БСВВ теперь выполняется в формате 16 бит, номер трекка передаётся в BC
- Немного улучшена работа подпрограмм WRITE и READ в БСВВ.
- Исправлены найденные ошибки.

### Версия 3.06
- Добавлена поддержка двух квази-дисков с автоопределением наличия второго КД при старте. Второй квази-диск должен быть подключён на порт 11h, в системе показывается, как диск D:.
- Исправлены найденные ошибки.
### Версия 3.05
Отлчия от всех предыдущих версий:

- Обращение к НЖМД выполняется в LBA-режиме, убрал ставшее ненужным сохранение характеристик НЖМД.<br>
- Переделал формат квази-диска, теперь он полностью совпадает с форматом МикроДОСа, можно переключаться из одной системы в другую без форматирования, и в то же время сохранён весь функционал РДС. Сделано это методом создания файла RDS.SYS в секторах 180-195 КД, которые используются для размещения системы. Простое решение -- сектора есть, их нумерация на КД не смещена и система не может быть затёрта (пока файл RDS.SYS существует). Тут только один минус: из-за того, что обращение к этой области выполняется мимо дисковой системы, контрольные суммы секторов нарушаются, но не думаю, что это критично. Для сокращения количества ошибок по команде TEST (или 8 в МДОС) сделал исправление контрольных сумм секторов под системой на квазидиске.<br>
- При запуске системы из COM-файла теперь на КД создаётся/перезаписывается файл COMMAND.SYS, т.е. исключена ситуация, когда выдаётся ошибка, что он не найден системой (при запуске без форматирования КД).<br>
- Загрузчик OS.COM также копируется на КД, но если не выполнялось форматирование, ему даётся имя RDS.COM, чтобы не затирать установленную до этого на КД систему. Если понадобится, то можно потом просто переименовать его вручную.<br>
- Большая часть системы сжата в архив lzsa1, для её запуска используется распаковщик ivagor-а, это позволило уменьшить размер файла с системой с 20 до 14 кБ.<br>
- Исправил работу команды HDD -- в предыдущих версиях была ошибка: запуск без параметров с любого диска, кроме А: вызывал сброс на 0 предыдущего диска (т.е. если, например, запустить HDD с диска В:, то вместо вывода конфигурации диску А: будет назначена нулевая дискета).<br>
- Исправил ошибку переключения на несуществующий диск (например, D: ), которая приводила к зависанию системы на этой ошибке до полного сброса.<br>
- Дополнил функционал команды TEST, теперь она может исправлять ошибки на квази-диске, для этого нужно к команде добавить ключик R:<br>
        TEST R<br>
        или<br>
        TEST C:R<br>
Ну и, кроме того, немного ускорил работу программы тестирования КД.<br>
- Сделал защиту на запись треков 180-195 квазидиска, в которых расположена система, на всякий случай.<br>
- Дополнил документацию на РДС и приложил её в комплект к системе.<br>
- Немного улучшил работу системы с командной строкой: теперь по нажатию клавиш "вверх" или "вниз" в командную строку копируются символы предыдущей выполненной команды (если буфер не был очищен). Собственно, этой функции мне серьёзно недоставало во всех версиях Векторовских ДОСов, теперь в случае ошибочного ввода легче исправить и повторить последнюю команду.
