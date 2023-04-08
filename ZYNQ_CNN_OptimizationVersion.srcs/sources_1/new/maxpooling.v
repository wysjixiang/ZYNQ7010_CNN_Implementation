

module maxpooling(clk,reset_n,data_in,valid,ready,ready_for_data,done,data_out);
	
	
localparam width = 16;
localparam num = 4;

input clk;
input reset_n;
input [width-1:0] data_in;
input valid;
input ready;
output ready_for_data;
output done;
output [49*width-1:0] data_out;	
	


// wire & reg


wire ready_ff4;
wire full_ff4;
wire [4*width-1:0] data_out_ff4;
wire ready_max;
wire done_max;
wire [width-1:0] data_out_max;



wire [width-1:0] data_in_ff49;
wire valid_ff49;
wire ready_ff49;
wire ready_for_data_ff49;
wire full_ff49;
wire [49*width-1:0] data_out_ff49;

// assign 
// assign语句对接口方向有要求，在仿真时有影响
// assign data_in_ff4 = data_in;
// assign valid_ff4 = valid;
// assign ready_for_data_max = ready_ff4;
// assign ready_for_data = ready_for_data_ff4;
// assign full_ff4 = valid_max;
// assign data_out_ff4 = data_in_max;

// assign ready_for_data_ff49 = ready_max;
// assign done_max = valid_ff49;
// assign data_out_max = data_in_ff49;


data_ff #(
	.depth(4)
	
)	data_ff_4FPdata(
	.clk				(clk),
	.reset_n			(reset_n),
	.data_in			(data_in),
	.valid				(valid),
	.ready				(ready_ff4),
	.ready_for_data		(ready_for_data),
	.full				(full_ff4),
	.data_out			(data_out_ff4)	
);	



single_maxpooling single_maxpooling_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.data_in			(data_out_ff4),
	.valid				(full_ff4),
	.ready				(ready_max),
	.ready_for_data		(ready_ff4),
	.done				(done_max),
	.data_out			(data_out_max)
);




data_ff #(
	.depth(49)
	
)	data_ff_49FPdata(
	.clk				(clk),
	.reset_n			(reset_n),
	.data_in			(data_out_max),
	.valid				(done_max),
	.ready				(ready),
	.ready_for_data		(ready_max),
	.full				(done),
	.data_out			(data_out)	
);


	
endmodule
