`timescale 1ns / 1ps


module find_FP16max(data_in,data_out);


localparam width = 16;
localparam num = 4;

input [width*num-1:0] data_in ;
output reg [width-1:0] data_out;

reg [10*num-1:0] mantissa;
reg [5*num-1:0] exponent;

reg [10*2-1:0] mantissa_buf;
reg [5*2-1:0] exponent_buf;



// 先把等于0的数都特么全部变成0
// always@(*) begin
	// for(int i=0;i<num;i=i+1) begin
	
		// if(data_in[(i+1)*width-1] == 1'b1) begin
			// mantissa[(i+1)*10-1:i*10] = 'd0;
			// exponent[(i+1)*5-1:i*5] = 'd0;
			
		// end else begin
			// mantissa[(i+1)*10-1:i*10] = data_in[(i+1)*16-7:i*16];
			// exponent[(i+1)*5-1:i*5] = data_in[(i+1)*16-2:i*16+10];		
		
		// end
		
	// end
// end

// 这里不能用always-for语句来循环生成组合逻辑
// 而要用for-always语句来循环生成组合逻辑电路

genvar i;
for(i=0;i<num;i=i+1) begin: loop1
	always@(*) begin

		if(data_in[(i+1)*width-1] == 1'b1) begin
			mantissa[(i+1)*10-1:i*10] = 'd0;
			exponent[(i+1)*5-1:i*5] = 'd0;
			
		end else begin
			mantissa[(i+1)*10-1:i*10] = data_in[(i+1)*16-7:i*16];
			exponent[(i+1)*5-1:i*5] = data_in[(i+1)*16-2:i*16+10];		
		
		end

	end

end


// 找出最大的exponent
always@(*) begin
	if(exponent[4:0] > exponent[9:5]) begin
		mantissa_buf[9:0] = mantissa[9:0];
		exponent_buf[4:0] = exponent[4:0];
	end	else if(exponent[9:5] > exponent[4:0]) begin
		mantissa_buf[9:0] = mantissa[19:10];
		exponent_buf[4:0] = exponent[9:5];		
	
	end else begin
		if(mantissa[9:0] > mantissa[19:10]) begin
			mantissa_buf[9:0] = mantissa[9:0];
			exponent_buf[4:0] = exponent[4:0];		
		end else begin
			mantissa_buf[9:0] = mantissa[19:10];
			exponent_buf[4:0] = exponent[9:5];				
		end
	
	end

end

always@(*) begin
	if(exponent[14:10] > exponent[19:15]) begin
			mantissa_buf[19:10] = mantissa[29:20];
			exponent_buf[9:5] = exponent[14:10];
	end	else if(exponent[19:15] > exponent[14:10]) begin
			mantissa_buf[19:10] = mantissa[39:30];
			exponent_buf[9:5] = exponent[19:15];		
	
	end else begin
		if(mantissa[29:20] > mantissa[39:30]) begin
			mantissa_buf[19:10] = mantissa[29:20];
			exponent_buf[9:5] = exponent[14:10];	
		end else begin
			mantissa_buf[19:10] = mantissa[39:30];
			exponent_buf[9:5] = exponent[19:15];				
		end
	
	end

end


always@(*) begin
	if(exponent_buf[4:0] > exponent_buf[9:5]) begin
		data_out = {1'b0,exponent_buf[4:0],mantissa_buf[9:0]};
	end	else if(exponent[9:5] > exponent[4:0]) begin
		data_out = {1'b0,exponent_buf[9:5],mantissa_buf[19:10]};		
	
	end else begin
		if(mantissa_buf[9:0] > mantissa_buf[19:10]) begin
			data_out = {1'b0,exponent_buf[4:0],mantissa_buf[9:0]};		
		end else begin
			data_out = {1'b0,exponent_buf[9:5],mantissa_buf[19:10]};			
		end
	
	end

end



endmodule
