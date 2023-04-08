`timescale 1ns / 1ps


module top_tb(done,data_out);


localparam width =16;

output done;
output [width*10-1:0] data_out;

reg [63:0] filter; 
reg [width-1:0] data [28*28-1:0] ; 
reg [width*28*28-1:0] data_in;
reg [49*width-1:0] bias_1;
reg [10*width-1:0] bias_2;

reg clk;
reg reset_n;
reg valid;

integer i;
integer outputfile;

initial begin
	$readmemh("D:/Vivado_Project/CNN_Implement_ZYNQ7010/FPGA_CNN_data.txt",data);
	outputfile = $fopen("fc_softnax.txt","w");//打开文件
	clk <= 1'b0;
	reset_n <= 1'b0;
	filter <= 64'h3c00_3c00_3c00_3c00;
	valid <= 1'b0;
	
	for(i=0;i<28*28;i=i+1) begin	
		data_in[i*width+:width] = data[i];
	end	
	bias_1 = 'h0;
	bias_2 = 'h0;
	
	#100 reset_n = 1'b1;
	#100 valid = 1'b1;
	
end

always#10 clk = ~clk;


always@(posedge clk) begin
	if(done) begin
		$fwrite(outputfile,"%h/n",data_out);
		#10 $fclose(outputfile);
	end


end



top_layer top_layer_inst(
	.clk			(clk)		,
	.reset_n		(reset_n)	,
	.data_in		(data_in)	,
	.filter			(filter)	,
	.bias_1			(bias_1)	,
	.bias_2			(bias_2)	,
	.valid			(valid)		,
	.ready			()			,
	.done			(done)		,
	.data_out		(data_out)	
);


endmodule
