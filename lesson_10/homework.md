# ДОМАШНЄ ЗАВДАННЯ ПІСЛЯ ЛЕКЦІЇ 10
## ЗАВДАННЯ 1. ZYNQ PS

Створити проект у Vivado.
Зібрати Block Design: 
- Zynq PS
- AXI GPIO (LED, кнопки, перемикачі)
- AXI Timer.

Реалізувати "біжучу доріжку" на світлодіодах:
- Один запалений LED переміщується по колу (LED0 → LED1 → LED2 →
  LED3 → LED0 → ...)
- Швидкість переміщення визначає AXI Timer (не програмна затримка
  циклом)
- Один перемикач обирає напрямок руху (вперед/назад)
- Кнопки змінюють швидкість руху/зупиняють/поновлють рух

## ЗАВДАННЯ 2. MICROBLAZE

Той самий Block Design, той самий функціонал, та сама логіка коду —
але з MicroBlaze замість Zynq PS.
Написати тестбенч для цього проекту з натисканням кнопок.
Симулювати проект з реальним .elf файлом згенерованим у Vitis.

## Що треба зробити
Або перше або друге завдання треба перевірити на реальному залізі, 
якщо є така можливість.

## Що треба здати

Для кожного із двох завдань ОБОВ'ЯЗКОВО залити на git наступне:
- Файли Vivado проекту. 
- Файли Vitis проекту.
Для заливки на git використовувати .gitignore з кореня \git\robot-dreams-code\FPGA\
- Результат: відео/скріншот реального заліза, або логи зібраних проектів Vitis
- Скріншот Waveform із симуляції проекту Microblaze

![microblaze_sim](microblaze_sim.png)

>> ```LOG
>> [13646.000 ns] Firmware boot detected: LED0 active
>> [13646.000 ns] PASS: LED = 0001
>> 
>> --- Checking forward LED cycle ---
>> [44716.000 ns] PASS: LED changed to 0010
>> [54756.000 ns] PASS: LED changed to 0100
>> [64766.000 ns] PASS: LED changed to 1000
>> [74726.000 ns] PASS: LED changed to 0001
>> 
>> --- Measuring normal speed ---
>> [94826.000 ns] Measured LED period = 10010.000 ns
>> 
>> --- BTN0: STOP ---
>> [94826.000 ns] Pressing BTN0
>> [165026.000 ns] PASS: LED remained stopped at 0100
>> 
>> --- BTN0: START ---
>> [165026.000 ns] Pressing BTN0
>> [215056.000 ns] PASS: running light resumed: 0100 -> 1000
>> 
>> --- BTN1: CHANGE DIRECTION ---
>> [215056.000 ns] Pressing BTN1
>> 
>> --- Checking reverse LED cycle ---
>> [265156.000 ns] PASS: LED changed to 0100
>> [275166.000 ns] PASS: LED changed to 0010
>> [285196.000 ns] PASS: LED changed to 0001
>> [295156.000 ns] PASS: LED changed to 1000
>> 
>> --- BTN2: FASTER ---
>> [295156.000 ns] Pressing BTN2
>> [344636.000 ns] Measured LED period = 5030.000 ns
>> [344636.000 ns] PASS: faster period 5030.000 ns < normal period 10010.000 ns
>> 
>> --- BTN3: SLOWER ---
>> [344636.000 ns] Pressing BTN3
>> [404046.000 ns] Measured LED period = 9950.000 ns
>> [404046.000 ns] PASS: slower period 9950.000 ns > fast period 5030.000 ns
>> 
>> ========================================
>>  TEST SUMMARY
>> ========================================
>>  PASS: 13
>>  FAIL: 0
>>  RESULT: ALL TESTS PASSED
>> ```
============================================================