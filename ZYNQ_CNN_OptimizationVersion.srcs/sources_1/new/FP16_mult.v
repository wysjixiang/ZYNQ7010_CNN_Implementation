`timescale 1ns / 1ps


module FP16_mult(floatA,floatB,product);
	
	
input [15:0] floatA, floatB;
output reg [15:0] product;

reg sign;
reg signed [5:0] exponent; //6th bit is the sign
reg [9:0] mantissa;
reg [10:0] fractionA, fractionB;	//fraction = {1,mantissa}
reg [21:0] fraction;


always @ (floatA or floatB) begin
	if (floatA == 0 || floatB == 0) begin
		product = 0;
	end else begin
		//最高位S相异或，就得到乘积后的符号
		sign = floatA[15] ^ floatB[15];
		
		//思路是把尾数省略的头部1补回，并且右移1位，将有效数全部表示为小数，然后阶数
		//就要+1;
		//例如： 1.10011 x 2^5 fraction = 100110...
		//给他补1后右移，变为 0.110011 x 2^6 fraction = 1100110...
		//这时候fraction再相乘即可得到乘积。再判断进位溢出，
		exponent = floatA[14:10] + floatB[14:10] - 5'd15 + 5'd2;
		fractionA = {1'b1,floatA[9:0]};
		fractionB = {1'b1,floatB[9:0]};
		fraction = fractionA * fractionB;
		//
		
		//似乎没有考虑fraction[21] == 1’b0 溢出的情况？？
		// 11X11,原码相乘最多就22位，所以不可能会溢出。
		//将乘积后的数转换为规格形式，即 1.xxxxx X 2^e 的形式，然后把第一位1隐去(左移)
		
		// 此处有一个问题：
		// 因为fraA、fraB的首项都是1，且不会溢出，那么必定在前两项就会出现1
		// 所以视乎不用判断这么多级吧？？？ 2023-03-17 疑问
		if (fraction[21] == 1'b1) begin
			fraction = fraction << 1;
			exponent = exponent - 1; 
		end else if (fraction[20] == 1'b1) begin
			fraction = fraction << 2;
			exponent = exponent - 2;
		end else if (fraction[19] == 1'b1) begin
			fraction = fraction << 3;
			exponent = exponent - 3;
		end else if (fraction[18] == 1'b1) begin
			fraction = fraction << 4;
			exponent = exponent - 4;
		end else if (fraction[17] == 1'b1) begin
			fraction = fraction << 5;
			exponent = exponent - 5;
		end else if (fraction[16] == 1'b1) begin
			fraction = fraction << 6;
			exponent = exponent - 6;
		end else if (fraction[15] == 1'b1) begin
			fraction = fraction << 7;
			exponent = exponent - 7;
		end else if (fraction[14] == 1'b1) begin
			fraction = fraction << 8;
			exponent = exponent - 8;
		end else if (fraction[13] == 1'b1) begin
			fraction = fraction << 9;
			exponent = exponent - 9;
			
		//为何这里判断的是等于0而不是1呢？
		
		
		end else if (fraction[12] == 1'b0) begin
			fraction = fraction << 10;
			exponent = exponent - 10;
		end 
	
		mantissa = fraction[21:12];
		//很小很小的数
		if(exponent[5]==1'b1) begin //exponent is negative
			product=16'b0000000000000000;
		end
		else begin
			product = {sign,exponent[4:0],mantissa};
		end
	end
end

endmodule
