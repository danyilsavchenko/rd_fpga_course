ДОМАШНЄ ЗАВДАННЯ ПІСЛЯ ЗАНЯТТЯ 5
Верифікація та Testbench (модуль: лічильник з реверсом і завантаженням)
============================================================

1. НАПИСАТИ МОДУЛЬ COUNTER

Створити файл counter.v. Модуль має такі порти (назви
й типи важливі — тестова перевірка вашого коду прив'язана
до цих імен):

  input  wire       clk       — тактовий сигнал
  input  wire       rst       — асинхронний reset, активний
                                 високим рівнем
  input  wire       load      — синхронне завантаження
  input  wire [3:0] data_in   — значення для завантаження
  input  wire       en        — дозвіл рахувати
  input  wire       up_down   — 1 = рахувати вгору, 0 = вниз
  output reg  [3:0] count     — поточне значення (реєстрове)

Поведінка на кожному фронті clk, у ПОРЯДКУ ПРІОРИТЕТУ (вища
умова в списку "перемагає", якщо кілька виконуються одночасно):

1) Якщо rst=1: count стає 0 (незалежно від решти сигналів,
   спрацьовує асинхронно, не чекаючи фронту).
2) Інакше якщо load=1: count <= data_in (навіть якщо en=1 —
   load має пріоритет над en).
3) Інакше якщо en=1: count <= count+1, якщо up_down=1;
   count <= count-1, якщо up_down=0.
4) Інакше (load=0 і en=0): count лишається без змін.

Розрядність 4 біти — рахунок прокручується природним чином:
15+1 дає 0, 0-1 дає 15 (звичайна арифметика 4-бітного лічильника,
нічого спеціально прописувати для цього не потрібно).

============================================================

2. НАПИСАТИ TESTBENCH ДЛЯ COUNTER

Створити файл tb_counter.v. У ньому по черзі:

1) Оголосити сигнали: clk, rst, load, data_in, en, up_down
   (усі reg, бо ви ними керуєте) і count (wire, бо це вихід DUT).

2) Інстанціювати counter, підключивши всі сигнали з пункту 1.

3) Додати генератор такту clk з частотою на ваш вибір.

============================================================

3. ПЕРЕВІРИТИ ЗАВАНТАЖЕННЯ (LOAD)

1) rst=1 на один такт, потім rst=0.
2) load=1, data_in=4'd10, зачекати фронт такту (@(posedge clk); #1;).
3) load=0.
4) Перевірити (if/else + $display PASS/FAIL): count === 10.

============================================================

4. ПЕРЕВІРИТИ РАХУНОК ВГОРУ, ВКЛЮЧНО З ПЕРЕХОДОМ ЧЕРЕЗ МЕЖУ

Це основне навантаження завдання — не одна перевірка, а
ПОСЛІДОВНІСТЬ:

1) Від значення 10 (продовження з пункту 3): en=1, up_down=1,
   зробити 3 такти поспіль (3 рази @(posedge clk); #1;).
2) Перевірити: count === 13.
3) Зробити ще 3 такти поспіль (усе ще en=1, up_down=1) — тепер
   лічильник має перейти через межу 15 -> 0.
4) Перевірити: count === 0.

============================================================

5. ПЕРЕВІРИТИ УТРИМАННЯ ЗНАЧЕННЯ (EN=0)

1) en=0 (up_down лишити яким завгодно — не повинен впливати).
2) Зробити 2 такти поспіль.
3) Перевірити: count не змінився (усе ще === 0 з кінця пункту 4).

============================================================

6. ПЕРЕВІРИТИ РАХУНОК ВНИЗ ІЗ ПЕРЕХОДОМ ЧЕРЕЗ МЕЖУ

1) en=1, up_down=0.
2) Один такт.
3) Перевірити: count === 15 (перехід 0 -> 15 у зворотний бік).

============================================================

7. ПЕРЕВІРИТИ ПРІОРИТЕТ LOAD НАД EN

Це прямо перевіряє порядок пріоритету з пункту 1 — навмисно
встановіть ОБИДВА сигнали разом:

1) load=1, data_in=4'd5, І ОДНОЧАСНО en=1, up_down=1.
2) Один такт.
3) Перевірити: count === 5 (не 16 чи інше значення від
   лічби — саме завантажене число, бо load має пріоритет).

============================================================

8. ЗІБРАТИ ВСІ ПЕРЕВІРКИ В TASK

1) Написати task automatic з іменем check_count, який приймає
   очікуване значення (input [3:0] expected) і текстову назву
   кроку (input string name).
2) Тіло task: порівняти count з expected (===), вивести
   PASS/FAIL через $display із назвою кроку.
3) Замінити ручні перевірки з пунктів 3-7 на виклики
   check_count(...) — по одному виклику одразу після кожної
   зміни входів і очікування такту.

Зверніть увагу: сам такт (@(posedge clk); #1;) task не робить —
він лишається в основному коді, бо кількість тактів очікування
різна для різних кроків. Task відповідає тільки за порівняння
й вивід.

============================================================

9. ЗНАЙТИ X-СТАН У Wave window

Відкрити Wave window , подивитись на count до першого фронту
такту (до reset) — має бути X. Одним реченням пояснити чому.

---
> вигляд дампу
>
> ![sim_dump](lesson_5/screenshots/simulation_dump.png)
>
> `X` стан з'являється тому, що на початок тесту ресет не ініціалізований в симуляції. Відповідно невизначений вхід схеми не може визначити її вихід
> ```
> wait_n_clocks(1); #1; // Wait for one clock cycle
> rst = 0;
> ```
> Якщо ресет визначити на початок симуляції - або в окремому блоці initial, або в цьому ж блоці без очікування клоку - все було би без `X` стану
---

============================================================

10. ЗАПУСТИТИ У КОНСОЛЬНОМУ РЕЖИМІ

xvlog counter.v tb_counter.v
xelab tb_counter -s tb_sim
xsim tb_sim -R

Скріншот текстового виводу з усіма PASS/FAIL.

```
danyil@danyil-aspirea51541g:~/rd_fpga_course/lesson_5$ source /home/amd/2026.1/Vivado/settings64.sh
danyil@danyil-aspirea51541g:~/rd_fpga_course/lesson_5$ xvlog -sv src/counter.v sim/tb_counter.sv
INFO: [VRFC 10-2263] Analyzing SystemVerilog file "/home/danyil/rd_fpga_course/lesson_5/src/counter.v" into library work
INFO: [VRFC 10-311] analyzing module counter
INFO: [VRFC 10-2263] Analyzing SystemVerilog file "/home/danyil/rd_fpga_course/lesson_5/sim/tb_counter.sv" into library work
INFO: [VRFC 10-311] analyzing module tb_counter
danyil@danyil-aspirea51541g:~/rd_fpga_course/lesson_5$ xelab -debug typical -s tb_sim work.tb_counter
Vivado Simulator v2026.1
Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
Running: /home/amd/2026.1/Vivado/bin/unwrapped/lnx64.o/xelab -debug typical -s tb_sim work.tb_counter 
Multi-threading is on. Using 2 slave threads.
WARNING: [XSIM 43-3431] One or more environment variables have been detected which affect the operation of the C compiler. These are typically not set in standard installations and are not tested by AMD, however they may be appropriate for your system, so the flow will attempt to continue.  If errors occur, try running xelab with the "-mt off -v 1" switches to see more information from the C compiler. The following environment variables have been detected:
    LIBRARY_PATH
Starting static elaboration
Pass Through NonSizing Optimizer
Completed static elaboration
Starting simulation data flow analysis
Completed simulation data flow analysis
Time Resolution for simulation is 1ps
Compiling module work.counter
Compiling module work.tb_counter
Built simulation snapshot tb_sim
danyil@danyil-aspirea51541g:~/rd_fpga_course/lesson_5$ xsim tb_sim -R

****** xsim v2026.1 (64-bit)
  **** SW Build 6511674 on Tue Jun 16 11:01:26 MDT 2026
  **** IP Build 6504888 on Tue Jun 09 09:05:25 MDT 2026
  **** SharedData Build 6501428 on Mon Jun 08 17:34:18 MDT 2026
  **** Start of session at: Wed Sep  2 22:52:51 2026
    ** Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
    ** Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.

source xsim.dir/tb_sim/xsim_script.tcl
# xsim {tb_sim} -autoloadwcfg -runall
Time resolution is 1 ps
run -all
Starting counter simulation...
Testing load functionality...
[PASS] counter load
Testing count up functionality...
[PASS] counter load
[PASS] Counter up: value incremented correctly to 11
[PASS] Counter up: value incremented correctly to 12
[PASS] Counter up: value incremented correctly to 13
[PASS] Counter up: value incremented correctly to 14
[PASS] Counter up: value incremented correctly to 15
[PASS] Counter up: value wrapped around to 0 as expected
Testing hold functionality...
[PASS] counter load
[PASS] counter hold
Testing count down functionality...
[PASS] counter load
[PASS] Counter down: value decremented correctly to  4
[PASS] Counter down: value decremented correctly to  3
[PASS] Counter down: value decremented correctly to  2
[PASS] Counter down: value decremented correctly to  1
[PASS] Counter down: value decremented correctly to  0
[PASS] Counter down: value wrapped around to 15 as expected
Testing load priority functionality...
[PASS] load priority
Counter simulation completed.
$finish called at time : 306 ns : File "/home/danyil/rd_fpga_course/lesson_5/sim/tb_counter.sv" Line 235
exit
INFO: xsimkernel Simulation Memory Usage: 299544 KB (Peak: 348364 KB), Simulation CPU Usage: 2300 ms
INFO: [Common 17-206] Exiting xsim at Wed Sep  2 22:53:05 2026...
danyil@danyil-aspirea51541g:~/rd_fpga_course/lesson_5$ 
```

============================================================

БОНУС (ОПЦІЙНО)

Написати ще один тестовий випадок, якого немає в пунктах вище:
рахунок ВНИЗ від значення, відмінного від 0/15, БЕЗ переходу
через межу (наприклад, завантажити 8, порахувати вниз один раз,
перевірити 7) — переконатись, що звичайний, "не крайовий"
випадок теж працює, а не тільки межові значення.

============================================================