`timescale 1ns / 1ps



module FP16_add(
floatA,floatB,sum
    );
	
	
input [15:0] floatA, floatB;
output reg [15:0] sum;

reg sign;
reg signed [5:0] exponent; //6th bit is the sign
reg [4:0] exponentA; //6th bit is the sign
reg [4:0] exponentB; //6th bit is the sign
reg [9:0] mantissa;
reg [10:0] fractionA, fractionB;	
reg [11:0] fraction;	
	

//和乘法一样的思路，先把隐藏位1加上，转成全小数。

always@(floatA or floatB) begin	

	exponentA = floatA[14:10];
	exponentB = floatB[14:10];
	fractionA = {1'b1,floatA[9:0]};
	fractionB = {1'b1,floatB[9:0]}; 
	
	if(floatA == 0) sum = floatB;
	else if(floatB == 0) sum = floatA;
	else if (floatA[14:0] == floatB[14:0] && floatA[15]^floatB[15]==1'b1) sum=0;
	else begin
	
		
		if(exponentA > exponentB) begin
			fractionB = fractionB >> (exponentA - exponentB);
			exponent = exponentA;
		end else begin
			fractionA = fractionA >> (exponentB - exponentA);
			exponent = exponentB;
		end
		
		//same sign
		if (floatA[15] == floatB[15]) begin
			sign = floatA[15];
			fraction = fractionA + fractionB;
			if(fraction[11] == 1'b1) begin
				fraction = fraction >> 1'b1;
				exponent = exponent + 1'b1;
			end
		end
		//different sign
		else begin
			if(floatA[15] == 1'b0) fraction = fractionA - fractionB;
			else fraction = fractionB - fractionA;
			
			//如果相减之后符号反了，则表示符号反了。
			if(fraction[11] == 1'b1) begin
				fraction[10:0] = -fraction[10:0];
			end
			
			sign = fraction[11];
			
		end
		
		//移位，找第一个1
		// 因为必定有1个1，如果这个1刚好在fraction [10]，可以直接得到结果了
		if (fraction [10] == 0) begin
			if (fraction[9] == 1'b1) begin
				fraction = fraction << 1;
				exponent = exponent - 1;
			end else if (fraction[8] == 1'b1) begin
				fraction = fraction << 2;
				exponent = exponent - 2;
			end else if (fraction[7] == 1'b1) begin
				fraction = fraction << 3;
				exponent = exponent - 3;
			end else if (fraction[6] == 1'b1) begin
				fraction = fraction << 4;
				exponent = exponent - 4;
			end else if (fraction[5] == 1'b1) begin
				fraction = fraction << 5;
				exponent = exponent - 5;
			end else if (fraction[4] == 1'b1) begin
				fraction = fraction << 6;
				exponent = exponent - 6;
			end else if (fraction[3] == 1'b1) begin
				fraction = fraction << 7;
				exponent = exponent - 7;
			end else if (fraction[2] == 1'b1) begin
				fraction = fraction << 8;
				exponent = exponent - 8;
			end else if (fraction[1] == 1'b1) begin
				fraction = fraction << 9;
				exponent = exponent - 9;
			end else if (fraction[0] == 1'b1) begin
				fraction = fraction << 10;
				exponent = exponent - 10;
			end 
		end
		
		
		mantissa = fraction[9:0];
		if(exponent[5]==1'b1) begin //exponent is negative
			sum = 16'b0000000000000000;
		end
		else begin
			sum = {sign,exponent[4:0],mantissa};
		end	
		
	end

	
end
	
	
endmodule
