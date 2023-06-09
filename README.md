# ADC

Данный репозиторий представляет из себя модуль для работы с АЦП(Аналогово-цифровым преобразователем) **AD9054A**. Даташит данного устройства лежит в каталоге ***Pics and datasheat***.

Данный модуль является соединяющим звеном, между ПЛИС и памятью, в которую идёт непосредственная записаь по интерйесу *AXISTREAM*. Также есть небольшой *констрейн-файл*, который так и не был доведён до ума в силу нехватки мною определённых значений в этой области. Однако сам модуль рабочий.

![adc](https://github.com/0TulipRose0/ADC/blob/main/Pics%20and%20datasheat/ADC-9054A.png)
___
## О  самом модуле
Модуль ***ad9054a*** представляет собой некий обработчик, который корректирует работы АЦП и принимает с него данные.

```Verilog
module ad9054A #(
    parameter DUALMODE_ENABLE = 1, //параметр, отвечающий за режим работы.
    parameter DIVIDE_ADC = 2'd3, //параметр для расчета частоты на АЦП
    parameter MASTER_DIVISION = 1'd1 //параметр, на который делится частота
)(
input logic clkin, //тактирование плисины
input logic rstn, //сигнал reset

//сигналы АЦП
input logic [7:0] da, db, //выходы ацп 
output logic encode, encode_b, //тактирование для ацп: без инверсии и с инверсией
output logic ds, ds_b, //каналы синхронизации для ацп
output logic demux, //сигнал в АЦП для выбора режима работы

//сигналы в память
axistream_if.master m_axis, //подключениие интерфейса AXISTREAM

output logic m_axis_aclk    //тактирование для памяти
    );
```

Модуль является параметризированным, благодаря чему удалось добиться симуляции сразу 2-х режимов работы:

+ 2 канала
+ 1 канал

Настраивается это при помощи параметра
```Verilog
parameter DUALMODE_ENABLE = 1, //параметр, отвечающий за режим работы.
```

В данном примере также используются встроенные в сапр *Vivado* шаблоны: PLL и DDR регистры на выходе тактовых сигналов. DDR регистры на выходах тактовых сигналов помогают сократить критический путь и сделать сигнал такта наиболее корректным. PLL же, в свою очередь, помогает добиться умножителя частоты до 200МГц. 

____

Синхронизация реализованна в режиме **ONE-SHOT**, что позволяет избежать лишних помех на сигналах:
![one-shot](https://github.com/0TulipRose0/ADC/blob/main/Pics%20and%20datasheat/one-shot.png)

Самая симуляция работы АЦП происходит в модуле тестового окружения или же, как он записан у меня, - ***tb***.

В нём есть модуль самого АЦП, которое просто генерит случайные данные в 1 или 2 канала, взависимости от установленного режима работы.
Отвечает за это тот самый параметр, о котором упомяналось выше.
____
## Немного про память

Работа с ней реализована по средству общения через интерфейс *AXISTREAM*, как упомяналось ранее. Также мы все знаем, что память никак не может работать на частоте в 200МГц, соответсвенно, принимать данные она не сможет по каждому такту. Поэтому было придумано и использовано простое, но гениальное решение в виде сдвигового регистра, который будет работать на частоте памяти, записывать в себя данные и отсылать их.

___
## Констрейн

Констрейн файл всё ещё находится в разработке. Требования, которые к нему выдвигаются, состоят в обработке того, что успевает ли модуль считывать данные. Характеристики выдвигаются в соответствии с даташитом.


## To do list
- [ ] Констрейн файл
- [ ] Проверка на железе
