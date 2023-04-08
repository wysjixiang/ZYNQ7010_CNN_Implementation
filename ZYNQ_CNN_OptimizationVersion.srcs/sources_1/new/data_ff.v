
module data_ff(clk,reset_n,data_in,valid,ready,ready_for_data,full,data_out);


parameter depth = 4;	//寄存数据的深度

localparam width = 16;

input clk;	
input reset_n;
input [width-1:0] data_in;
input valid;
input ready;
output ready_for_data;
output full;
(* keep = "true" *) output reg [depth*width-1:0] data_out;



// wire & reg
(* keep = "true" *) reg [$clog2(depth):0] addr;		//多留一位，用于指针地址和depth比较，判断满

// state machine
localparam s_notfull = 0;
localparam s_full = 1;
reg state;


// assign
assign full = (state == s_full);
assign ready_for_data = ~full;


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		state <= s_notfull;
	end else begin
		case(state)
			s_notfull: begin
				if(valid && (addr == depth-1))
					state <= s_full;
				else state <= state;
			end
	
			s_full: begin
				if(ready) state <= s_notfull;
				else state <= state;
			end
		
		endcase
	end

end


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		addr <= 'd0;
	end else begin
		case(state)
			s_notfull: begin
				if(valid) addr <= addr + 1'b1;
				else addr <= addr;
			end
	
			s_full: begin
				if(ready) addr <= 'd0;
				else addr <= addr;
			end
		
		endcase
	end

end


always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		data_out <= 'h0;
	end else begin
		data_out <= data_out;
		if(valid & ready_for_data)
			data_out[addr*width+:width] <= data_in;
	end

end

endmodule
