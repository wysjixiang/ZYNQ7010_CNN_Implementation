

// 用时序电路实现，做一个3级pipeline的卷积模块
module single_convo_compute(
	clk,
	reset_n,
	load,
	din,
	filter,
	ready,
	done,
	reg_convo_out
    );
	
parameter num = 4;	
parameter width = 16;	

input clk;
input reset_n;
input load;
input [num*width-1:0] din;
input [num*width-1:0] filter;
input ready;
output done;	
output [width-1:0] reg_convo_out;	
	

wire [num*width-1:0] wire_mult_buf;
wire [2*width-1:0] wire_add_buf;
wire [width-1:0] wire_convo_out;

reg [num*width-1:0] reg_mult_buf;
reg [2*width-1:0] reg_add_buf;



// state machine 
localparam s_idle = 0;
localparam s_1 = 1;
localparam s_2 = 2;
localparam s_3 = 3;

reg [1:0] state;

assign done = (state == s_3);
assign reg_convo_out = wire_convo_out;

always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		state <= s_idle;
	end else begin
		case(state)
			s_idle: begin
				if(load) state <= s_1;
				else state <= state;
			end
			s_1: state <= s_2;
			
			s_2: state <= s_3;
			
			s_3: begin
				if(ready & load) begin
					state <= s_1;
				end else if(ready) state <= s_idle;
				else state <= state;
			end
	
			default: state <= state;
		endcase
	end
end


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		reg_add_buf <= 'h0;
	end else if(state == s_2)
		reg_add_buf <= wire_add_buf;
	else reg_add_buf <= reg_add_buf;
end


// generate for FP_mult
genvar n;

generate
	for(n=0;n<4;n=n+1) begin

		FP16_mult mult_inst(
			.floatA		(din[n*width+:width])	,
			.floatB		(filter[n*width+:width])	,
			.product    (wire_mult_buf[n*width+:width])
		
		);
	end
endgenerate


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		reg_mult_buf <= 0;
	end else begin
		case(state) 
			s_1: begin
				reg_mult_buf <= wire_mult_buf;
			end
			s_3: begin
				if(load) reg_mult_buf <= wire_mult_buf;
				else reg_mult_buf <= reg_mult_buf;
			end
			
			default: reg_mult_buf <= reg_mult_buf;
		endcase
	end
end


FP16_add add_inst0(
	.floatA		(reg_mult_buf[1*width-1:(1-1)*width])	,
	.floatB		(reg_mult_buf[2*width-1:(2-1)*width])	,
	.sum    	(wire_add_buf[1*width-1:(1-1)*width])
);

FP16_add add_inst1(
	.floatA		(reg_mult_buf[3*width-1:(3-1)*width])	,
	.floatB		(reg_mult_buf[4*width-1:(4-1)*width])	,
	.sum    	(wire_add_buf[2*width-1:(2-1)*width])

);


FP16_add add_inst2(
	.floatA		(reg_add_buf[1*width-1:(1-1)*width])	,
	.floatB		(reg_add_buf[2*width-1:(2-1)*width])	,
	.sum    	(wire_convo_out)

);

// always@(posedge clk or negedge reset_n) begin
	// if(~reset_n ) begin
		// reg_convo_out <= 0;
	// end else begin
		// reg_convo_out <= wire_convo_out;
	// end
// end



endmodule

