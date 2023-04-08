`timescale 1ns / 1ps


module maxpooling_tb(done,data_out);


localparam width =16;

output done;
output [49*width-1:0] data_out;



reg [width-1:0] data_in;
reg [width-1:0] data;

reg clk;
reg reset_n;
reg valid;
wire ready_for_data;


initial begin

	clk <= 1'b0;
	reset_n <= 1'b0;
	valid <= 1'b0;
	
	
	#100 reset_n = 1'b1;
	#100 valid = 1'b1;
	
	
end

always#10 clk = ~clk;
// always#500 valid = ~valid;

always@(posedge clk) begin
	
	data <= {$random}%65535 ;

end

always@(posedge clk or negedge reset_n) begin
	if(~reset_n)
		data_in <= 'h0;
	else if(valid & ready_for_data) data_in <= data;
	else data_in <= data_in;
end

	

maxpooling maxpooling_inst(
	.clk				(clk			),
	.reset_n			(reset_n		),
	.data_in			(data_in		),
	.valid				(valid			),
	.ready				(1'b1			),
	.ready_for_data		(ready_for_data	),
	.done				(done			),
	.data_out			(data_out		)
);








	
endmodule
