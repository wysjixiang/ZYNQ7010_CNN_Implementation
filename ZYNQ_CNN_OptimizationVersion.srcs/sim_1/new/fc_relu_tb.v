



module fc_relu_tb(done,data_out);

localparam width =16;

output done;
output [width*49-1:0] data_out;


reg [width-1:0] data [7*7-1:0] ; 
reg [width*7*7-1:0] data_in;
reg [49*width-1:0] bias;

reg clk;
reg reset_n;
reg valid;

integer i;
integer outputfile;

initial begin
	$readmemh("D:/Vivado_Project/CNN_Implement_ZYNQ7010/FC_RELU_data.txt",data);
	outputfile = $fopen("fc_relu.txt","w");//打开文件
	clk <= 1'b0;
	reset_n <= 1'b0;

	valid <= 1'b0;
	
	for(i=0;i<14*14;i=i+1) begin	
		data_in[i*width+:width] = data[i];
	end	
	
	for(i=0;i<49;i=i+1) begin	
		bias[i*width+:width] = 'h0;
	end
	
	
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


Fc_Relu #( 
	.input_node(49),
	.output_node(49)
) Fc_Relu_inst(
	.clk				(clk),
	.reset_n			(reset_n),
	.data_in			(data_in),
	.bias				(bias),
	.valid				(valid),
	.ready				(1'b1),
	.ready_for_data		(),
	.done				(done),
	.data_out			(data_out)
);


endmodule
