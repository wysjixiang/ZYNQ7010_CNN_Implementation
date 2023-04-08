`timescale 1ns / 1ps

module exponent_reciprocal_tb(ready_for_data,done,exp_data,exp_sum);


localparam width = 16;

reg clk;
reg reset_n;
reg valid;
reg [10*width-1:0] data_in;
output ready_for_data;
output done;
output [10*width-1:0] exp_data;
output [width-1:0] exp_sum;


initial begin

	clk <= 1'b0;
	reset_n <= 1'b0;
	valid <= 1'b0;
	data_in <= 160'h3c003c003c003c003c003c003c003c003c003c00;
	
	#100 reset_n = 1'b1;
	#100 valid = 1'b1;
	
	#2000 data_in <= 160'h4000400040004000400040004000400040004000;
	
end

always#10 clk = ~clk;
// always#500 valid = ~valid;

	
	
exponent_and_sum_exp exponent_and_sum_exp_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.valid				(valid),
	.ready				(1'b1),
	.data_in			(data_in),
	.done				(done),
	.ready_for_data		(ready_for_data),
	.reg_exponent		(exp_data),
	.data_sum_exponent	(exp_sum)
);	
	
	
	
	
	
	
endmodule
