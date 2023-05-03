`timescale 1ns / 1ps
//тестовое окружение дл€ симул€ции работы

module ad9054A_device(  //модуль симул€ции работы ј÷ѕ
output logic [7:0] da, db, //выходы ацп 
input logic encode, encode_b, //тактирование дл€ ј÷ѕ инвертированное и нет
input logic ds, ds_b, //каналы синхронизации дл€ ацп
input logic demux //сигнал дл€ выбора режима работы ј÷ѕ
);

logic ds_int_d; //инициализаци€ внутреннего тактировани€ ј÷ѕ
always @(posedge encode) begin
    if (ds)
        ds_int_d <= 1'b1;
    else
        ds_int_d <= ~ds_int_d;
 end

   
//описание работы выдачи данных из ј÷ѕ в каналы 
initial
begin 
    da = 8'd10;
    db = 8'd15;
    
    forever begin
        @(posedge encode);
//        #1;
    case(demux)
    
    1'b0:   
//            #1
            if(ds_int_d)
            da = da + $random%16;
            else 
            db = db + $random%16;
    1'b1:   
//            #1  
            da <= da + $random%16;
    endcase
    end
end
endmodule
 
 
 
 //модуль тестбенча
 module tb();
logic clkin;
logic [7:0] da, db;
logic demux, encode, encode_b, ds, rstn;

logic aclk;
 
axistream_if axis(aclk);
 
ad9054A adc (
.clkin(clkin), //входной сигнал в 40 ћ√ц

.da(da),     //выход данных а
.db(db),   //выход данных б
.encode(encode), //тактирование в 200ћ√ц
.encode_b(encode_b), //инвертированный 
.demux(demux), //сигнал выбора режима работы
.ds(ds), //внешний сигнал синхронизации из модул€ в ј÷ѕсигнал тактировани€
.rstn(rstn), //сигнал reset
.ds_b(), //инвертированный сигнал синхрониации

//сигналы в пам€ть
.m_axis_aclk(aclk), //тактирование в пам€ть
.m_axis(axis)//.axis_tdata(),  //данные, которые идут в па€мть
//.axis_tvalid()  //сигнал валидности данных
);


ad9054A_device device(  //модуль симул€ции работы ј÷п
.encode(encode), //тактирование в 200ћ√ц

.da(da),  //выход данных а
.db(db), //выход данных б
.encode_b(), //тактирование дл€ ацп инвертированное и нет
.ds(ds),   //внешний сигнал синхронизации из модул€ в ј÷ѕсигнал тактировани€
.ds_b(), //каналы синхронизации дл€ ацпreset
.demux(demux) //сигнал дл€ выбора режима работы ј÷ѕ
);

//инициализаци€ тактировани€ в 40ћ√ц
parameter PERIOD = 25.0;
initial forever begin
      #(PERIOD/2) clkin = 1'b1;
      #(PERIOD/2) clkin = 1'b0;
end


initial
begin 
    //подача сигнала reset
    rstn = 0;
    #830;
    rstn = 1;
    #10;
end
endmodule
