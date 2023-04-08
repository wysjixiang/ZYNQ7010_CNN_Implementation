`timescale 1ns / 1ps


module exponent_and_sum_exp(clk,reset_n,valid,ready,data_in,done,ready_for_data,reg_exponent,data_sum_exponent);

localparam node = 10;
localparam width = 16;

input clk;
input reset_n;
input valid;
input ready;
input [width*node-1:0] data_in;
output done;
(* keep = "true" *) output ready_for_data;
(* keep = "true" *) output reg [width*node-1:0] reg_exponent;
output [width-1:0] data_sum_exponent;



// state reg
localparam s_idle = 0;
localparam s_1 = 	1 ;
localparam s_2 = 	2 ;
localparam s_3 = 	3 ;
localparam s_4 = 	4 ;
localparam s_5 = 	5 ;
localparam s_6 = 	6 ;
localparam s_7 = 	7 ;
localparam s_8 = 	8 ;
localparam s_9 = 	9 ;
localparam s_10 = 	10;
localparam s_sum = 	11;
localparam s_end = 	12;
// state machine
reg [3:0] state;

// wire & reg
(* keep = "true" *) wire exp_done;
(* keep = "true" *) wire exp_valid;
(* keep = "true" *) wire exp_ready;
(* keep = "true" *) wire exp_ready_for_data;
(* keep = "true" *) reg [width-1:0] exp_data_in;
(* keep = "true" *) wire [width-1:0] exp_data_out;

(* keep = "true" *) reg [width-1:0] exp_sum;
(* keep = "true" *) reg [width-1:0]	reg_add_input;	
(* keep = "true" *) wire [width-1:0] wire_add_output;


// assign 
assign ready_for_data = (state == s_idle) ;
assign done = (state == s_end);
assign exp_valid = ~((state == s_idle) || (state == s_sum) || state == s_end);
assign exp_ready = 1'b1;
assign data_sum_exponent = exp_sum;



// state transaction
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		state <= s_idle;
	end else begin
		state <= state;
		case(state)

			s_idle 	: if(valid)
				state <= s_1;
		    s_1 	: 	if(exp_done) state <= s_2;
		    s_2 	:	if(exp_done) state <= s_3;
		    s_3 	:	if(exp_done) state <= s_4;
		    s_4 	:	if(exp_done) state <= s_5;
		    s_5 	:	if(exp_done) state <= s_6;
		    s_6 	:	if(exp_done) state <= s_7;
		    s_7 	:	if(exp_done) state <= s_8;
		    s_8 	:	if(exp_done) state <= s_9;
		    s_9 	:	if(exp_done) state <= s_10;
            s_10 	:	if(exp_done) state <= s_sum;
            s_sum 	:	state <= s_end;
			s_end	: 	if(ready) state <= s_idle;
		endcase
	end


end


// exp_data_in
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		exp_data_in <= 'h0;
	end else begin
		exp_data_in <= exp_data_in;
		case(state)

			s_idle 	: if(valid)
				exp_data_in <= data_in[0*width+:width];
		    s_1 	: 	if(exp_done) 
				exp_data_in <= data_in[1*width+:width];
		    s_2 	:	if(exp_done) 
				exp_data_in <= data_in[2*width+:width];
		    s_3 	:	if(exp_done) 
				exp_data_in <= data_in[3*width+:width];
		    s_4 	:	if(exp_done) 
				exp_data_in <= data_in[4*width+:width];
		    s_5 	:	if(exp_done) 
				exp_data_in <= data_in[5*width+:width];
		    s_6 	:	if(exp_done) 
				exp_data_in <= data_in[6*width+:width];
		    s_7 	:	if(exp_done) 
				exp_data_in <= data_in[7*width+:width];
		    s_8 	:	if(exp_done) 
				exp_data_in <= data_in[8*width+:width];
		    s_9 	:	if(exp_done) 
				exp_data_in <= data_in[9*width+:width];
		endcase
	end

end


// reg_exponent
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		reg_exponent <= 'h0;
	end else begin
		reg_exponent <= reg_exponent;
		case(state)

		    s_1 	: 	if(exp_done) 
				reg_exponent[0*width+:width] <= exp_data_out;
		    s_2 	:	if(exp_done) 
				reg_exponent[1*width+:width] <= exp_data_out;
		    s_3 	:	if(exp_done) 
				reg_exponent[2*width+:width] <= exp_data_out;
		    s_4 	:	if(exp_done) 
				reg_exponent[3*width+:width] <= exp_data_out;
		    s_5 	:	if(exp_done) 
				reg_exponent[4*width+:width] <= exp_data_out;
		    s_6 	:	if(exp_done) 
				reg_exponent[5*width+:width] <= exp_data_out;
		    s_7 	:	if(exp_done) 
				reg_exponent[6*width+:width] <= exp_data_out;
		    s_8 	:	if(exp_done) 
				reg_exponent[7*width+:width] <= exp_data_out;
		    s_9 	:	if(exp_done) 
				reg_exponent[8*width+:width] <= exp_data_out;
            s_10 	:	if(exp_done) 
				reg_exponent[9*width+:width] <= exp_data_out;

		endcase
	end

end


// reg_add_input
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		reg_add_input <= 'h0;
	end else begin
		reg_add_input <= reg_add_input;
		case(state)

		    s_1 	: 	if(exp_done) 
				reg_add_input <= exp_data_out;
		    s_2 	:	if(exp_done) 
				reg_add_input <= exp_data_out;
		    s_3 	:	if(exp_done) 
				reg_add_input <= exp_data_out;
		    s_4 	:	if(exp_done) 
				reg_add_input <= exp_data_out;
		    s_5 	:	if(exp_done) 
				reg_add_input <= exp_data_out;
		    s_6 	:	if(exp_done) 
				reg_add_input <= exp_data_out;
		    s_7 	:	if(exp_done) 
				reg_add_input <= exp_data_out;
		    s_8 	:	if(exp_done) 
				reg_add_input <= exp_data_out;
		    s_9 	:	if(exp_done) 
				reg_add_input <= exp_data_out;
            s_10 	:	if(exp_done) 
				reg_add_input <= exp_data_out;
		endcase
	end

end


// exp_sum
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		exp_sum <= 'h0;
	end else begin
		exp_sum <= exp_sum;
		case(state)
			s_1		: exp_sum <= 'h0;
		    s_2 	:	if(exp_done) 
				exp_sum <= wire_add_output;
		    s_3 	:	if(exp_done) 
				exp_sum <= wire_add_output;
		    s_4 	:	if(exp_done) 
				exp_sum <= wire_add_output;
		    s_5 	:	if(exp_done) 
				exp_sum <= wire_add_output;
		    s_6 	:	if(exp_done) 
				exp_sum <= wire_add_output;
		    s_7 	:	if(exp_done) 
				exp_sum <= wire_add_output;
		    s_8 	:	if(exp_done) 
				exp_sum <= wire_add_output;
		    s_9 	:	if(exp_done) 
				exp_sum <= wire_add_output;
            s_10 	:	if(exp_done) 
				exp_sum <= wire_add_output;
			s_sum	: exp_sum <= wire_add_output;
		endcase
	end

end




// reg [width-1:0] exp_sum;
// reg [width-1:0]	reg_add_input;	
// wire [width-1:0] wire_add_output;

// FP16 adder inst
FP16_add FP16_add_inst(
	.floatA		(reg_add_input)		,
	.floatB		(exp_sum)	,
	.sum		(wire_add_output)	
);


// 这里只用了一个模块循环地算指数，但是速度太慢了，10个周期才能计算出一个指数值


exponent_compute exponent_compute_inst(
	.clk				(clk			),
	.reset_n			(reset_n		),
	.valid				(exp_valid		),
	.ready				(exp_ready		),
	.ready_for_data		(exp_ready_for_data	),
	.data_in			(exp_data_in),
	.locked				(exp_done	),
	.data_out			(exp_data_out)
);



endmodule
