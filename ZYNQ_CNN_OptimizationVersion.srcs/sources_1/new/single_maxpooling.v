`timescale 1ns / 1ps

module single_maxpooling(clk,reset_n,data_in,valid,ready,ready_for_data,done,data_out);
	

localparam width = 16;
localparam num = 4;
	
input clk;	
input reset_n;
input [num*width-1:0] data_in;
input valid;
input ready;
output ready_for_data;
output done;
output [width-1:0]data_out;
	



// wire & reg
reg [num*width-1:0] data_maxpooling;



// state machine
localparam s_idle =0;
localparam s_1 =1;
localparam s_2 =2;
localparam s_3 =3;
localparam s_4 =4;

reg [2:0] state;




// assign

assign done = (state == s_4);
assign ready_for_data = (state == s_idle) || ((state == s_4) & ready);



// 状态机切换
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		state <= s_idle;
	end else begin
		case(state) 
		
			s_idle: begin
				if(valid) state <= s_1;
				else state <= s_idle;
			end

			s_1: state <= s_2;
			
			s_2: state <= s_3;
			
			s_3: state <= s_4;
			
			s_4:	begin
				if(valid & ready)
					state <= s_1;
				else if(ready)
					state <= s_idle;
				else state <= state;
			
			end
			
			default: begin
				state <= state;
			
			end			
		
		endcase
	end
end


// load信号及输入到convo里面的数据更新
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		data_maxpooling <= 'h0;
	end else begin
		data_maxpooling <= data_maxpooling;
		case(state) 
			s_idle: begin
				if(valid) data_maxpooling <= data_in;
			end
			
			s_4	:	begin
				if(valid & ready)
					data_maxpooling <= data_in;
			end

		endcase
	end

end

	
	
	

// 纯组合逻辑电路，给3个时钟周期让他输出稳定	
find_FP16max find_FP16max_inst(
	.data_in	(data_maxpooling),
	.data_out	(data_out)
);
	
	
endmodule
