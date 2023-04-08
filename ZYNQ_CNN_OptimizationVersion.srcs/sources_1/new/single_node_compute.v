`timescale 1ns / 1ps

// 结合实际，只有乘法，把线性加法的数据直接预先读取到reg_add_sum里面
// 只完成1个结点的计算
module single_node_compute(clk,reset_n,en_pulse,product_fac,bias,data_in,done,data_out);


parameter node = 49;
localparam width = 16;


input clk;
input reset_n;
input en_pulse;
input [width*node-1:0] product_fac;
input [width-1:0] bias;
input [width*node-1:0] data_in;
output done;
output [width-1:0] data_out;



// state machine
localparam s_idle = 0;
localparam s_run = 1;
localparam s_end = 2;

reg [1:0] state;
reg [5:0] cnt;
//

// Wire Reg
wire [width-1:0] wire_mult_buf;
wire [width-1:0] wire_add_buf;
reg [width-1:0] reg_add_sum;

(* keep = "true" *) reg [width-1:0] multA;
(* keep = "true" *) reg [width-1:0] multB;
(* keep = "true" *) reg [width-1:0] multAB;


assign done = (state == s_end);
assign data_out = reg_add_sum;

// 相乘的数据选通
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		multA <= 'h0;
		multB <= 'h0;
	end else begin
		case(state)
			
			s_idle: begin
				if(en_pulse) begin
					multA <= data_in[0+:width]		;
					multB <= product_fac[0+:width]	;					
				end else begin
					multA <= 'h0;
					multB <= 'h0;
				end
			end
			
			s_run: begin
				if(cnt > 6'd48) begin
					multA <= 'h0;
					multB <= 'h0;	
				end else begin
					multA <= data_in[cnt*width+:width]		;
					multB <= product_fac[cnt*width+:width]	;	
				end
			end			

			s_end: begin
				if(en_pulse) begin
					multA <= data_in[0+:width]		;
					multB <= product_fac[0+:width]	;					
				end else begin
					multA <= 'h0;
					multB <= 'h0;
				end	
			end

			default: begin

				multA <= 'h0;
				multB <= 'h0;

			end			
	
		endcase
	end
end


// 乘法数据FF
always@(posedge clk ) begin

	multAB <= wire_mult_buf;
	
end


// 数据迭代相加
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		reg_add_sum <= 'h0;
	end else if(state == s_idle || state == s_end) reg_add_sum <= bias;
	else reg_add_sum <= wire_add_buf;
end


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		state <= s_idle;
	end else begin
		case(state)
	
			s_idle: begin
				if(en_pulse) state <= s_run;
				else state <= s_idle;
			end
			
			s_run: begin
				if(cnt == 6'd50) state <= s_end;
				else state <= s_run;
			end
			
			s_end: begin
				if(en_pulse) state <= s_run;
				else state <= s_idle;
			end
			default: state <= s_idle;
		endcase
	end

end

// always@(posedge clk or negedge reset_n) begin
	// if(reset_n) begin
		// state <= s_idle;
	// end else if(state == s_idle && en_pulse) begin
		// state <= s_run;
	// end else if(cnt == 6'd50) begin
		// state <= s_end;
	// end else state <= state;

// end

// 当cnt计数到51的时候，刚好计算完成
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		cnt <= 6'd0;
	end else begin
		case(state)
		
			s_idle:	begin
				if(en_pulse) cnt <= cnt + 1'b1;
				else cnt <= 6'd0;
			end
			s_run: begin
				if(cnt == 6'd51) cnt <= cnt;
				else cnt <= cnt + 1'b1;
			end
			s_end:	begin
				if(en_pulse) cnt <= cnt + 1'b1;
				else cnt <= 6'd0;
			end
			
			default: cnt <= cnt;
		endcase
	end

end

	
FP16_mult fc_mult_inst(
	.floatA		(multA),
	.floatB		(multB),
	.product    (wire_mult_buf)

);		

FP16_add fc_add_inst(
	.floatA		(reg_add_sum)	,
	.floatB		(multAB)		,
	.sum    	(wire_add_buf)

);	
	

	
	
endmodule
