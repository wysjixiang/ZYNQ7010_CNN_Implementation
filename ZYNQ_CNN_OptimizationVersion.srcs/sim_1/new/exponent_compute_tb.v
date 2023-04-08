`timescale 1ns / 1ps



module exponent_compute_tb(ready_for_data,locked,data_out);



localparam width = 16;

reg clk;
reg reset_n;
reg valid;
reg [width-1:0] data_in;
output ready_for_data;
output locked;
output [width-1:0] data_out;



initial begin

	clk <= 1'b0;
	reset_n <= 1'b0;
	valid <= 1'b0;
	data_in <= 16'h3c00;
	
	#100 reset_n = 1'b1;
	#100 valid = 1'b1;
	
	#200 data_in = 16'h4100;
	
end

always#10 clk = ~clk;
// always#500 valid = ~valid;






exponent_compute exponent_compute_inst(
	.clk				(clk			),
	.reset_n			(reset_n		),
	.valid				(valid			),
	.ready				(1'b1			),
	.ready_for_data		(ready_for_data	),
	.data_in			(data_in		),
	.locked				(locked			),
	.data_out			(data_out		)
);


endmodule
