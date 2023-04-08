`timescale 1ns / 1ps


// 目前的实现方案需要多个（包括寄存周期在内,12个时钟周期）个时钟周期运算才能得出9阶泰勒展开近似的e^x运算结果。
// 所以该模块需要考虑到握手！
module exponent_compute(clk,reset_n,valid,ready,ready_for_data,data_in,locked,data_out);
// 10阶泰勒展开计算指数。 在精度误差为10%要求之内时，输入值的范围为：-2.481445 ~ 3.999;
// 因为4^8 = 65536，超过FP16能表达的最大的数.
// 数值为负时，绝对值越大误差越大。3.999时，误差仅为2.1797%

// 但是，我们还要考虑到之前的节点是Relu层，因此所有的输入数都是正数！！所以精度大大提高。
// 最差精度即为误差精度2.1797%

localparam width = 16;

input clk;
input reset_n;
input valid;
input ready;
input [width-1:0] data_in;
output ready_for_data;
output locked;
output [width-1:0] data_out;




// state machine
localparam s_idle = 0;
localparam s_1 = 1;
localparam s_2 = 2;
localparam s_3 = 3;
localparam s_4 = 4;
localparam s_5 = 5;
localparam s_6 = 6;
localparam s_7 = 7;
localparam s_8 = 8;
localparam s_9 = 9;
localparam s_end = 10;

reg [3:0] state;


// wire & reg
(* keep = "true" *) reg [width-1:0] factorial;

// 寄存输入信号
(* keep = "true" *) reg [width-1:0] reg_data_in;

(* keep = "true" *) reg [width-1:0] data_pipe1_reg;
wire [width-1:0] data_pipe1_wire;

(* keep = "true" *) reg [width-1:0] data_pipe2_reg;
wire [width-1:0] data_pipe2_wire;

(* keep = "true" *) reg [width-1:0] data_pipe3_reg;

wire [width-1:0] data_sum;


// assign
assign ready_for_data = ((state == s_idle) || (locked & ready) );
assign locked = (state == s_end);
assign data_out = data_sum;


// state transaction
always@(posedge clk or negedge reset_n) begin
	if(~reset_n ) begin
		state <= s_idle;
	end else begin
		case(state)
			
			s_idle: if(valid)
				state <= s_1;
			else state <= state;
			
			s_1 	: state <= s_2 		;
			s_2 	: state <= s_3 		;
			s_3 	: state <= s_4 		;
			s_4 	: state <= s_5 		;
			s_5 	: state <= s_6 		;
			s_6 	: state <= s_7 		;
			s_7 	: state <= s_8 		;
			s_8 	: state <= s_9 		;			
			s_9 	: state <= s_end	;
			s_end 	: begin
				if(valid  & ready)
					state <= s_1;
				else if(ready) 
					state <= s_idle;
				else state <= state;
			end

		endcase
	end

end



always@(posedge clk or negedge reset_n) begin
	if(~reset_n ) factorial <= 16'h0;
	else begin
		case(state)
			s_idle 	: factorial <= 16'h3c00;
			s_1 	: factorial <= 16'h3c00;
			s_2 	: factorial <= 16'h3800;	// 1/2!
			s_3 	: factorial <= 16'h3155;	// 1/3!
			s_4 	: factorial <= 16'h2955;	// 1/4!
			s_5 	: factorial <= 16'h2044;	// 1/5!
			s_6 	: factorial <= 16'h15b0;	// 1/6!
			s_7 	: factorial <= 16'h0a80;	// 1/7!
			s_8 	: factorial <= 16'h01a0;	// 1/8!
			
			
			s_end	: if(valid  & ready)
				factorial <= 16'h3c00;
			
			default: factorial <= 16'h0;	
		
		
		endcase
	end

end


always@(posedge clk or negedge reset_n) begin
	if(~reset_n ) begin
		reg_data_in <= 16'd0;
	end else begin
		reg_data_in <= reg_data_in;
		case(state)
			
			s_idle	:if(valid)
				reg_data_in <= data_in;
					
			s_end	:if(valid  & ready)
				reg_data_in <= data_in;
	
		endcase
	end

end



// pipe_1 reg
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) data_pipe1_reg <= 16'd0;
	else begin
		data_pipe1_reg <= data_pipe1_wire;
		case(state)
			
			s_idle	:if(valid)
				data_pipe1_reg <= 16'h3c00;
					
			s_end	:if(valid  & ready)
				data_pipe1_reg <= 16'h3c00;
	
		endcase
	end

end


// pipe_2 reg
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) data_pipe2_reg <= 16'd0;
	else begin
		data_pipe2_reg <= data_pipe2_wire;
		case(state)
			
			s_idle	:if(valid)
				data_pipe2_reg <= 16'h0;
					
			s_end	:if(valid  & ready)
				data_pipe2_reg <= 16'h0;
	
		endcase
	end

end

// pipe_3 reg
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) data_pipe3_reg <= 16'd0;
	else begin
		data_pipe3_reg <= data_sum;
		case(state)
			
			s_idle	:if(valid)
				data_pipe3_reg <= 16'h0;
					
			s_end	:if(valid  & ready)
				data_pipe3_reg <= 16'h0;
	
		endcase
	end

end



// 3级流水运算
// Pipiline_1 : x的幂计算
FP16_mult FP16_mult_L0(
	.floatA		(reg_data_in),
	.floatB		(data_pipe1_reg),
	.product	(data_pipe1_wire)

);

// Pipiline_2 : x的幂与阶数相乘
FP16_mult FP16_mult_L1(
	.floatA		(data_pipe1_reg),
	.floatB		(factorial),
	.product	(data_pipe2_wire)

);

// Pipiline_3 : 累加
FP16_add FP16_add_L0(
	.floatA	(data_pipe2_reg),
	.floatB	(data_pipe3_reg),
	.sum	(data_sum)

);


endmodule



