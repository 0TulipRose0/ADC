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
    
    logic CLKFBOUT, ADC_clk, ADC_clk_b; 
    logic RST = 0, PWRDWN = 0, LOCKED;

   //блок умножителя частоты
   MMCME2_BASE #(
      .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
      .CLKFBOUT_MULT_F(15.0),     // Multiply value for all CLKOUT (2.000-64.000).
      .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
      .CLKIN1_PERIOD(25.0),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      .CLKOUT1_DIVIDE(DIVIDE_ADC),
      .CLKOUT2_DIVIDE(4*DIVIDE_ADC),
      .CLKOUT3_DIVIDE(1),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT5_DIVIDE(1),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT0_DIVIDE_F(1.0),    // Divide amount for CLKOUT0 (1.000-128.000).
      // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      .CLKOUT6_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(0.0),
      .CLKOUT2_PHASE(0.0),
      .CLKOUT3_PHASE(0.0),
      .CLKOUT4_PHASE(0.0),
      .CLKOUT5_PHASE(0.0),
      .CLKOUT6_PHASE(0.0),
      .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      .DIVCLK_DIVIDE(MASTER_DIVISION),         // Master division value (1-106)
      .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
      .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
   )
   MMCME2_BASE_inst (
      // Clock Outputs: 1-bit (each) output: User configurable clock outputs
      .CLKOUT0(),     // 1-bit output: CLKOUT0
      .CLKOUT0B(),   // 1-bit output: Inverted CLKOUT0
      .CLKOUT1(ADC_clk),     // 1-bit output: CLKOUT1
      .CLKOUT1B(ADC_clk_b),   // 1-bit output: Inverted CLKOUT1
      .CLKOUT2(m_axis_aclk),     // 1-bit output: CLKOUT2
      .CLKOUT2B(),   // 1-bit output: Inverted CLKOUT2
      .CLKOUT3(),     // 1-bit output: CLKOUT3
      .CLKOUT3B(),   // 1-bit output: Inverted CLKOUT3
      .CLKOUT4(),     // 1-bit output: CLKOUT4
      .CLKOUT5(),     // 1-bit output: CLKOUT5
      .CLKOUT6(),     // 1-bit output: CLKOUT6
      // Feedback Clocks: 1-bit (each) output: Clock feedback ports
      .CLKFBOUT(CLKFBOUT),   // 1-bit output: Feedback clock
      .CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT
      // Status Ports: 1-bit (each) output: MMCM status ports
      .LOCKED(LOCKED),       // 1-bit output: LOCK
      // Clock Inputs: 1-bit (each) input: Clock input
      .CLKIN1(clkin),       // 1-bit input: Clock
      // Control Ports: 1-bit (each) input: MMCM control ports
      .PWRDWN(PWRDWN),       // 1-bit input: Power-down
      .RST(RST),             // 1-bit input: Reset
      // Feedback Clocks: 1-bit (each) input: Clock feedback ports
      .CLKFBIN(CLKFBOUT)      // 1-bit input: Feedback clock
   );
   
    // End of MMCME2_BASE_inst instantiation
    
     
   //DDR регистры на тактирование в АЦП
       ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) clock_encode (
      .Q(encode),   // 1-bit DDR output
      .C(ADC_clk), // 1-bit clock input
      .CE(1'b1),    // 1-bit clock enable input
      .D1(1'b0), // 1-bit data input (positive edge)
      .D2(1'b1), // 1-bit data input (negative edge)
      .R(1'b0), // 1-bit reset
      .S(1'b0) // 1-bit set
   );
     
            ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) clock_encode_b (
      .Q(encode_b),   // 1-bit DDR output
      .C(ADC_clk_b), // 1-bit clock input
      .CE(1'b1),    // 1-bit clock enable input
      .D1(1'b0), // 1-bit data input (positive edge)
      .D2(1'b1), // 1-bit data input (negative edge)
      .R(1'b0), // 1-bit reset
      .S(1'b0) // 1-bit set
   );
				

    assign demux = ~DUALMODE_ENABLE; //сигнал в АЦП для выбора режима работы
    logic ds_int; //Внутренний сигнал синхронизации
    logic rstn_reg; 
    
    //Регистр сигнала сброса 
    always_ff @(ADC_clk)
    rstn_reg = rstn & LOCKED; 
    
    always @(posedge ADC_clk) //блок описания работы внутреннего data select 
        if (~rstn_reg) begin
            ds_int <= 0;
        end else begin
            ds_int <= ~ds_int;
        end

    
 //подача сигнала синхронизации ds в режиме ONE-SHOT           
//инициализация счётчика для сигнала valid
    logic [2:0] count_valid;
    always_ff @(posedge ADC_clk)
           if(~rstn_reg) begin
                count_valid <= 0;
           end else begin
                count_valid <= count_valid +1;
           end
 
  //Состояния для настройки режима работы в ONE-SHOT DATA SYNC 
    logic state;
    enum logic [1:0] {n_give = 2'b00,
                       give  = 2'b01
                         } states;
  //описание работы автомата конечных состояний для сигнала data select и валидности данных на шине
   always @(posedge ADC_clk)
         if (~rstn_reg) begin
         ds <= n_give;
         ds_b <= give;
         state <= n_give; //при сбросе ставим состояние "не выдан"
         m_axis.tvalid <= 0;
         end
         else case(state)
            n_give: begin
                    ds <= give;
                    ds_b <= n_give;
                    state <= ~state;
                    end
              give: begin  
                    ds <= n_give; //когда выдается такт синхронизации, сигнал ds остаётся в нуле
                    ds_b <= give;
                    if(count_valid == 3'b101)
                    m_axis.tvalid <= 1;
                    end
         endcase
         
    logic [7:0] dout_adc; //канал данных из ацп на частоте 200МГц
    
    always_ff @(posedge ADC_clk) //сигнал выходных данных, который поступает в память
    begin if (~demux) 
              begin if (ds_int)
              dout_adc <= da;
            else begin
                 dout_adc <= db;
                 end
            end else if(demux) 
                 dout_adc <= da;           
    end 
    
    //сдвиговый регистр для работы с 32 битами
    logic [31:0] store;
    always_ff @(posedge ADC_clk)
        if (~rstn_reg) begin
            store <= 0;
        end else begin
            store <= { store[23:0], dout_adc }; 
        end
    
    //посылка данных в память на частоте в 50 МГц
    always_ff @(posedge m_axis_aclk)
    begin 
         m_axis.tdata <= store;
    end


endmodule