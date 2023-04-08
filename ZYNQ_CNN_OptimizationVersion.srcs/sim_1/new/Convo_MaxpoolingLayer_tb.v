


`timescale 1ns / 1ps
module Convo_MaxpoolingLayer_tb(done,data_out);


localparam width =16;

output done;
output [49*width-1:0] data_out;

reg [63:0] filter;
// reg [width*28*28-1:0] data ; 
reg [width*4-1:0] data_in;
reg [width*4-1:0] data;

reg clk;
reg reset_n;
reg valid;
wire ready_for_data;




integer outputfile;

initial begin
	
	outputfile = $fopen("data_in.txt","w");
	
	clk <= 1'b0;
	reset_n <= 1'b0;
	filter <= 64'h0000_0000_3c00_0000;
	valid <= 1'b0;
	
	
	#100 reset_n = 1'b1;
	#100 valid = 1'b1;
	
	
end

always#10 clk = ~clk;
//always#500 valid = ~valid;



always@(posedge clk) begin
	
	data <= {$random,$random} ;

end

always@(posedge clk or negedge reset_n) begin
	if(~reset_n)
		data_in <= 'h0;
	else if(valid & ready_for_data) data_in <= data;

end

always@(posedge clk or negedge reset_n) begin
	if(valid & ready_for_data) 
		$fwrite(outputfile,"%h\n",data_in[width+:width]);

end

always@(posedge clk or negedge reset_n) begin
	if(done) 
		$fclose(outputfile);
end


Convo_MaxpoolingLayer Convo_MaxpoolingLayer_inst(
	.clk			(clk)	,
	.reset_n		(reset_n)	,
	.filter			(filter)	,
	.data_in		(data_in)	,
	.valid			(valid)		,
	.ready			(1'b1)		,
	.done			(done)		,
	.ready_for_data	(ready_for_data),
	.data_out		(data_out)	
);


	
	
endmodule
