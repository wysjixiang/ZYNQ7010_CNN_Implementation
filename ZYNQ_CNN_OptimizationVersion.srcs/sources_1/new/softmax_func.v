`timescale 1ns / 1ps
module softmax_func(clk,reset_n,valid,ready,exp_data_in,sum_exp,done,ready_for_data,data_out);



localparam width = 16;
localparam node = 10;

input clk;
input reset_n;
input valid;
input ready;
input [width*node-1:0] exp_data_in;
input [width-1:0] sum_exp;

(* keep = "true" *) output done;
(* keep = "true" *) output ready_for_data;
(* keep = "true" *) output reg [width*node-1:0] data_out;



// state machine
localparam s_idle = 4'd0;
localparam s_reciprocal = 4'd1;
localparam s_e0 = 4'd2;
localparam s_e1 = 4'd3;
localparam s_e2 = 4'd4;
localparam s_e3 = 4'd5;
localparam s_e4 = 4'd6;
localparam s_e5 = 4'd7;
localparam s_e6 = 4'd8;
localparam s_e7 = 4'd9;
localparam s_e8 = 4'd10;
localparam s_e9 = 4'd11;
localparam s_end = 4'd12;


reg [3:0] state;

// wire & reg 
// wire of reciprocal signal
(* keep = "true" *) wire reciprocal_locked;
(* keep = "true" *) wire [width-1:0] exp_reciprocal;
(* keep = "true" *) reg [width-1:0] reg_exp_reciprocal;

(* keep = "true" *) // wire of FP16 mult
(* keep = "true" *) wire [width-1:0] exp_mult;
(* keep = "true" *) reg [width-1:0] mult_input;
(* keep = "true" *) wire reciprocal_valid;

(* keep = "true" *) reg [width*node-1:0] reg_exp_data_in;
(* keep = "true" *) reg [width-1:0] reg_sum_exp;


// assign 
assign ready_for_data = (state == s_idle);
assign done = (state == s_end);
assign reciprocal_valid = (state == s_reciprocal);



// state transaction
always@(posedge clk or negedge reset_n) begin
	if(~reset_n )  begin
		state <= s_idle;
	end else begin
		state <= state;
		case(state)
			s_idle			: begin if(valid)
				state <= s_reciprocal;	
			end	
			s_reciprocal	: begin
				if(reciprocal_locked) state <= s_e0;
			end
			s_e0 			:	state <= s_e1	;
			s_e1 			:	state <= s_e2   ;
			s_e2 			:	state <= s_e3   ;
			s_e3 			:	state <= s_e4   ;
			s_e4 			:	state <= s_e5   ;
			s_e5 			:	state <= s_e6   ;
			s_e6 			:	state <= s_e7   ;
			s_e7 			:	state <= s_e8   ;
		    s_e8 			:	state <= s_e9   ;
	        s_e9			:	state <= s_end  ;
			s_end			:	if(ready)
				state <= s_idle;
			default			:	state <= state	;
		endcase
	end

end


// reg_exp_data_in/reg_sum_exp
always@(posedge clk) begin
	reg_exp_data_in <= reg_exp_data_in;
	reg_sum_exp	<= reg_sum_exp;
	if(state == s_idle && valid) begin
		reg_exp_data_in <= exp_data_in;
		reg_sum_exp	<= sum_exp;	
		
	end

end

// reg_exp_reciprocal
always@(posedge clk or negedge reset_n) begin
	if(~reset_n )  begin
		reg_exp_reciprocal <= 'h0;	
	end else if(state == s_reciprocal && reciprocal_locked) begin
		reg_exp_reciprocal <= exp_reciprocal;
	end else 
		reg_exp_reciprocal <= reg_exp_reciprocal;
end


// data_out
always@(posedge clk) begin
	data_out <= data_out;
	
	case(state)
		s_idle			: data_out <= 'h0;

		s_e0 			: data_out[width*0+:width] <= exp_mult;
		s_e1 			: data_out[width*1+:width] <= exp_mult;
		s_e2 			: data_out[width*2+:width] <= exp_mult;
		s_e3 			: data_out[width*3+:width] <= exp_mult;
		s_e4 			: data_out[width*4+:width] <= exp_mult;
        s_e5 			: data_out[width*5+:width] <= exp_mult;
        s_e6 			: data_out[width*6+:width] <= exp_mult;
        s_e7 			: data_out[width*7+:width] <= exp_mult;
        s_e8 			: data_out[width*8+:width] <= exp_mult;
		s_e9			: data_out[width*9+:width] <= exp_mult;

		default			:	data_out <= data_out;

	endcase
end


always@(posedge clk ) begin
	case(state) 
		s_idle			: mult_input <= 16'h0;
		s_reciprocal 	: begin
			if(reciprocal_locked ) mult_input <= reg_exp_data_in[width*0+:width];
			else mult_input <= 16'h0;
		end
		s_e0 			:   mult_input <= reg_exp_data_in[width*1+:width];
		s_e1 			:   mult_input <= reg_exp_data_in[width*2+:width];
		s_e2 			:   mult_input <= reg_exp_data_in[width*3+:width];
		s_e3 			:   mult_input <= reg_exp_data_in[width*4+:width];
		s_e4 			:   mult_input <= reg_exp_data_in[width*5+:width];
		s_e5 			:   mult_input <= reg_exp_data_in[width*6+:width];
		s_e6 			:   mult_input <= reg_exp_data_in[width*7+:width];
		s_e7 			:   mult_input <= reg_exp_data_in[width*8+:width];
		s_e8 			:   mult_input <= reg_exp_data_in[width*9+:width];

		default			: mult_input <= 16'h3c00;
	endcase
end


FP16_mult FP16_mult_inst(
	.floatA		(reg_exp_reciprocal),
	.floatB		(mult_input)	,
	.product	(exp_mult)	
);


FP16_reciprocal FP16_reciprocal_inst(
	.clk		(clk)				,
	.reset_n	(reset_n)			,
	.valid		(reciprocal_valid)		,
	.data_in	(reg_sum_exp)			,
	.data_out	(exp_reciprocal)	,
	.locked		(reciprocal_locked)			
);


endmodule
