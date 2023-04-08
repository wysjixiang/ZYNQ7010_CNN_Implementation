`timescale 1ns / 1ps


module ZYNQ_tb(done,wire_out);



localparam width =16;

output done;
output [width-1:0] wire_out;

reg clk;
reg reset_n;

initial begin
	clk <= 1'b0;
	reset_n <= 1'b0;
	
	#100 reset_n = 1'b1;

	
end

always#10 clk = ~clk;



ZYNQ_implement ZYNQ_implement(
	.clk		(clk),
	.reset_n	(reset_n),
	.done		(done)
);


endmodule

