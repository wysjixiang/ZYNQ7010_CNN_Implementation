

// 单一一个数据从输入到输出，需要共计 3910 ~= 4000个时钟周期
// 但由于是流水线计算，且在考虑到FC1的计算时间(2450个clk)大于其他模块，因此该模块会造成堵塞，所以当流水线跑起来的时候，每一个输出数据帧间隔是2450clk。
// 所以在50MHz的速率下，可以实现size28*28的帧处理速率大约为19000帧/s,即帧速率为1万9千帧
// bias不变,其实可以写到底层模块里面,和product_fac一样
module top_layer(clk,reset_n,data_in,filter,bias_1,bias_2,valid,ready,ready_for_data,done,data_out);


localparam width = 16;


input clk;
input reset_n;
input valid;
input ready;
input [4*width-1:0] data_in;
input [4*width-1:0] filter;
input [49*width-1:0] bias_1;
input [10*width-1:0] bias_2;
output ready_for_data;
output done;
output [10*width-1:0]data_out;


// wire & reg
// Convo-maxpooling

(* keep = "true" *) wire done_convo;
(* keep = "true" *) wire [7*7*width-1:0] data_out_convo;
// fc1
(* keep = "true" *) wire ready_fd_fc1;
(* keep = "true" *) wire done_fc1;
(* keep = "true" *) wire [7*7*width-1:0] data_out_fc1;
// fc2
(* keep = "true" *) wire ready_fd_fc2;
(* keep = "true" *) wire done_fc2;
(* keep = "true" *) wire [10*width-1:0] data_out_fc2;
//softmax
(* keep = "true" *) wire ready_softmax;
(* keep = "true" *) wire done_softmax;
(* keep = "true" *) wire [10*width-1:0] data_out_softmax;

// assign 

assign done = done_softmax;
assign data_out = data_out_softmax;


// 需要大约800个时钟周期
// Convo-maxpooling
Convo_MaxpoolingLayer Convo_MaxpoolingLayer_inst(
	.clk			(clk)	,
	.reset_n		(reset_n)	,
	.filter			(filter)	,
	.data_in		(data_in)	,
	.valid			(valid)		,
	.ready			(ready_fd_fc1)		,
	.done			(done_convo)		,
	.ready_for_data	(ready_for_data),
	.data_out		(data_out_convo)	
);



// 49个节点需要50*49 = 2450个时钟周期
// FC1-Relu1
Fc_Relu #( 
	.input_node(49),
	.output_node(49)
) Fc_Relu_node49(
	.clk				(clk),
	.reset_n			(reset_n),
	.data_in			(data_out_convo),
	.bias				(bias_1),
	.valid				(done_convo),
	.ready				(ready_fd_fc2),
	.ready_for_data		(ready_fd_fc1),
	.done				(done_fc1),
	.data_out			(data_out_fc1)
);


// 10个节点需要50*10 = 500 个时钟周期
// FC2-Relu2
Fc_Relu #( 
	.input_node(49),
	.output_node(10)
) Fc_Relu_node10(
	.clk				(clk),
	.reset_n			(reset_n),
	.data_in			(data_out_fc1),
	.bias				(bias_2),
	.valid				(done_fc1),
	.ready				(ready_softmax),
	.ready_for_data		(ready_fd_fc2),
	.done				(done_fc2),
	.data_out			(data_out_fc2)
);



// 需要144 + 16 个时钟周期左右。取决于计算reciprocal得收敛速度
// softmax
softmax softmax_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.valid				(done_fc2),
	.data_in			(data_out_fc2),
	.ready				(ready)	,
	.ready_for_data		(ready_softmax),
	.done				(done_softmax),
	.data_out			(data_out_softmax)
);




endmodule