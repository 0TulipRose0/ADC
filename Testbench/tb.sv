`timescale 1ns / 1ps
//�������� ��������� ��� ��������� ������

module ad9054A_device(  //������ ��������� ������ ���
output logic [7:0] da, db, //������ ��� 
input logic encode, encode_b, //������������ ��� ��� ��������������� � ���
input logic ds, ds_b, //������ ������������� ��� ���
input logic demux //������ ��� ������ ������ ������ ���
);

logic ds_int_d; //������������� ����������� ������������ ���
always @(posedge encode) begin
    if (ds)
        ds_int_d <= 1'b1;
    else
        ds_int_d <= ~ds_int_d;
 end

   
//�������� ������ ������ ������ �� ��� � ������ 
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
 
 
 
 //������ ���������
 module tb();
logic clkin;
logic [7:0] da, db;
logic demux, encode, encode_b, ds, rstn;

logic aclk;
 
axistream_if axis(aclk);
 
ad9054A adc (
.clkin(clkin), //������� ������ � 40 ���

.da(da),     //����� ������ �
.db(db),   //����� ������ �
.encode(encode), //������������ � 200���
.encode_b(encode_b), //��������������� 
.demux(demux), //������ ������ ������ ������
.ds(ds), //������� ������ ������������� �� ������ � ��������� ������������
.rstn(rstn), //������ reset
.ds_b(), //��������������� ������ ������������

//������� � ������
.m_axis_aclk(aclk), //������������ � ������
.m_axis(axis)//.axis_tdata(),  //������, ������� ���� � ������
//.axis_tvalid()  //������ ���������� ������
);


ad9054A_device device(  //������ ��������� ������ ���
.encode(encode), //������������ � 200���

.da(da),  //����� ������ �
.db(db), //����� ������ �
.encode_b(), //������������ ��� ��� ��������������� � ���
.ds(ds),   //������� ������ ������������� �� ������ � ��������� ������������
.ds_b(), //������ ������������� ��� ���reset
.demux(demux) //������ ��� ������ ������ ������ ���
);

//������������� ������������ � 40���
parameter PERIOD = 25.0;
initial forever begin
      #(PERIOD/2) clkin = 1'b1;
      #(PERIOD/2) clkin = 1'b0;
end


initial
begin 
    //������ ������� reset
    rstn = 0;
    #830;
    rstn = 1;
    #10;
end
endmodule
