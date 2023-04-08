`timescale 1ns / 1ps


module ZYNQ_implement(clk,reset_n,done);
	
input clk;
input reset_n;	
output done;
	
localparam width =16;


(* keep = "true" *) reg [width-1:0] data_in;

(* keep = "true" *) wire [10*width-1:0] data_out;
reg valid;
// reg [9:0] cnt;


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		data_in <= 16'h3c00;
	end else if(data_in == 16'h4000)
		data_in <= 16'h3c00;
	else data_in <= data_in + 16'h0001;

end
	
	
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		valid <= 1'b0;
	end else 
		valid <= 1'b1;

end




top_layer top_layer_inst(
	.clk			(clk)		,
	.reset_n		(reset_n)	,
	.data_in		({48'h0000_0000_0000,data_in})	,
	.filter			(64'h0000_0000_0000_3c00)	,
	.bias_1			('h0)		,
	.bias_2			('h0)		,
	.valid			(valid)		,
	.ready			(1'b1)		,
	.ready_for_data	()			,
	.done			(done)		,
	.data_out		(data_out)	
);	
	


ila_0 ila_0_inst (
	.clk(clk), // input wire clk
	.probe0(done), // input wire [0:0]  probe0  
	.probe1(data_out) // input wire [159:0]  probe1
);






	
endmodule
