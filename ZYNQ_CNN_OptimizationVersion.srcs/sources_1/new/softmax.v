`timescale 1ns / 1ps


// 输入10个数，已经经过convo-maxpooling-FC-relu等网络层处理
module softmax(clk,reset_n,valid,data_in,ready,ready_for_data,done,data_out);

localparam node = 10;
localparam width = 16;

input clk;
input reset_n;
(* keep = "true" *) input valid;
(* keep = "true" *) input [width*node-1:0] data_in;
(* keep = "true" *) input ready;
(* keep = "true" *) output ready_for_data;
(* keep = "true" *) output done;
(* keep = "true" *) output [width*node-1:0] data_out;



// wire & reg
(* keep = "true" *) wire softmax_func_ready_for_data;
(* keep = "true" *) wire exponent_and_sum_exp_done;
(* keep = "true" *) wire [width*node-1:0] exp_data_in;
(* keep = "true" *) wire [width-1:0] sum_exp;


// 需要144个时钟周期才能算完10个数的指数和他们的和
exponent_and_sum_exp exponent_and_sum_exp_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.valid				(valid),
	.ready				(softmax_func_ready_for_data),
	.data_in			(data_in),
	.done				(exponent_and_sum_exp_done),
	.ready_for_data		(ready_for_data),
	.reg_exponent		(exp_data_in),	
	.data_sum_exponent	(sum_exp)
);


// 大概只需要13-16个时钟周期即可，主要取决于算reciprocal收敛的速度
softmax_func softmax_func_inst(
	.clk			(clk)						,
	.reset_n		(reset_n)					,
	.valid			(exponent_and_sum_exp_done)			,
	.exp_data_in	(exp_data_in)			,
	.sum_exp		(sum_exp)			,
	.done			(done)	 ,
	.ready_for_data	(softmax_func_ready_for_data),
	.ready			(ready) ,
	.data_out		(data_out)	
);





endmodule

