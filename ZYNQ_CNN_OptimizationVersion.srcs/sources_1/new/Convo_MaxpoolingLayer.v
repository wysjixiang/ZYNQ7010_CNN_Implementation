

module Convo_MaxpoolingLayer(clk,reset_n,data_in,filter,valid,ready,ready_for_data,done,data_out);


localparam width = 16;
localparam num = 4;

input clk;
input reset_n;
input [num*width-1:0] data_in;
input [num*width-1:0] filter;
input valid;
input ready;
output ready_for_data;
output done;
output [49*width-1:0] data_out;




wire ready_Convo_SingleNode;
wire done_Convo_SingleNode;
wire [width-1:0] data_out_Convo_SingleNode ;


Convo_SingleNode Convo_SingleNode_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.filter				(filter),
	.data_in			(data_in),
	.valid				(valid),
	.ready				(ready_Convo_SingleNode),
	.ready_for_data		(ready_for_data),
	.done				(done_Convo_SingleNode),
	.data_out			(data_out_Convo_SingleNode)
);


maxpooling maxpooling_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.data_in			(data_out_Convo_SingleNode),
	.valid				(done_Convo_SingleNode),
	.ready				(ready),
	.ready_for_data		(ready_Convo_SingleNode),
	.done				(done),
	.data_out			(data_out)
);




endmodule
