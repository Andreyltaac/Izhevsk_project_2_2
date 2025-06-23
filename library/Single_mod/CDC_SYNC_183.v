`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module CDC_SYNC_183
    #(
     parameter BURST_LENGTH_rel = 8'd191, //����� ������� ������� ������ RELOAD  
     parameter DELAY_LENGTH_conf = 16'd200, //�������� �������� ������� CONFIG 
     parameter LENGTH_rst = 8'd5 //�������� �������� ������� RESET 
     )
     (
     input wire clk, //�����
     input wire IN_val, //����   
     input wire rst_ext, //������� �����   
     
     output reg tlast = 0, //��������� �����
     output reg OUT_val_rel = 0, //������ ��������� ������ RELOAD  
     output reg OUT_val_conf = 0, //������ ��������� ������ CONFIG   
     output reg rst_FIR = 1 //������ ������ ���� FIR Compiler 
     );
    
reg first = 0;
reg second = 0;
reg third = 0;
reg add_reg = 0; // �������������� �������

reg rst_all = 0; // ������� ������ ���� �������
reg flag_0 = 0; // ������� ������/����� �������� ���������� �������������
reg flag_1 = 0; // ������� ��������� ���������� ������
reg flag_2 = 0; // ������� ������� TLAST
reg flag_3 = 0; // ������� ������� CONFIG

reg [15:0] count_1 = 0; //������� ������������ �������
reg [15:0] count_2 = 0; //������� �������� ������� CONFIG 
reg [7:0] count_3 = 0; //������� ������������ ������  


//����������������� ������� ���������  
always @(posedge clk)
begin
	 first <= IN_val;
	 second <= first;
	 third <= second;
	 add_reg <= ~third & second;
end
//����������������� ������� ���������

//�������� ������� add_reg
always @(posedge clk)
begin
      if(add_reg) 
         OUT_val_rel <= 1;
    else OUT_val_rel <= 0;
end
//�������� ������� add_reg

//������ ��������� ������/����� �������� ���������� �������������
always @(posedge clk)
begin
      if(add_reg & flag_0 == 0)
         begin
           flag_0 <= 1;
         end
 else if(flag_3 & rst_all == 0)
         begin 
           flag_0 <= 0;
           rst_all <= 1;
         end
    else 
         begin
         rst_all <= 0;
         end
end
//������ ��������� ������/����� �������� ���������� �������������

//������ ������ FIR Compiler.
always @(posedge clk)
begin
      if(rst_all | rst_ext) 
         begin
            count_3 <= 0;
            flag_1 <= 0;
         end
    else 
         begin
           if (flag_0 & count_3 <= LENGTH_rst) 
              begin 
                count_3 <= count_3 [6:0] + 1'b1;
                rst_FIR <= 0;
              end
           if (count_3 == LENGTH_rst) 
              begin
                rst_FIR <= 1;
                flag_1 <= 1;
              end
         end   
end
//������ ������ FIR Compiler.

//������������ ������� TLAST
always @(posedge clk)
begin
      if(rst_all | rst_ext) 
         begin
            flag_2 <= 0;
         end
    else 
         begin
           if (add_reg & flag_1 & count_1 <= BURST_LENGTH_rel)
              begin
                count_1 <= count_1 [14:0] + 1'b1;
                if (count_1 == BURST_LENGTH_rel)
                    begin
                      count_1 <= 0;
                      tlast <= 1;
                      flag_2 <= 1;
                    end
              end      
           else 
               begin
                 tlast <= 0;
               end
         end
   
end      
//������������ ������� TLAST

//������������ ������� CONFIG
always @(posedge clk)
begin
      if(rst_all | rst_ext) 
         begin
            flag_3 <= 0;
         end
    else 
         begin
           if (flag_2 & count_2 <= DELAY_LENGTH_conf)
             begin
               count_2 <= count_2 [14:0] + 1'b1;
               if (count_2 == DELAY_LENGTH_conf)
                   begin
                     OUT_val_conf <= 1;
                     count_2 <= 0;
                     flag_3 <= 1;  
                   end
             end
           else
              begin 
                OUT_val_conf <= 0;
              end  
          end
end
//������������ ������� CONFIG

endmodule
