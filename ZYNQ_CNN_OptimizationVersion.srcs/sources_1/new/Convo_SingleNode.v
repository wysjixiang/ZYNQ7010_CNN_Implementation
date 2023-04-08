

/*
该模块只需要接收到数据后进行卷积计算即可。
需要同时考虑上、下游的握手信号
下游信号的ready和模块内的done信号同时拉高时才能确认下级模块已经接收到卷积数据
而只要done信号拉高，就可以将新数据寄存进来，但暂时不拉高load信号，而只在数据被下游取走之后才拉高load

// 实际在CNN上，filter对于一层卷积层模块是不变的，所以把filter当作常量
*/
module Convo_SingleNode(clk,reset_n,filter,data_in,valid,ready,ready_for_data,done,data_out);
	

localparam width = 16;
localparam num_data = 4;	

input clk;
input reset_n;
input [num_data*width-1:0] filter;
input [num_data*width-1:0] data_in;
input valid;	//上级模块发送状态
input ready;	//下级模块接收状态
output ready_for_data;
output done;
output [width-1:0] data_out ;



reg load;
wire single_convo_done;
wire [width-1:0] convo_out;

// state machine

localparam s_idle =0;
localparam s_run =1;
reg state;



reg [num_data*width-1:0] convo_data_in;

assign done = (single_convo_done && state == s_run);
assign ready_for_data = (state == s_idle) || (single_convo_done & ready);


assign data_out = convo_out;


// 状态机切换
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		state <= s_idle;
	end else begin
		case(state) 
	
			s_idle: begin
				if(valid) state <= s_run;
				else state <= s_idle;
			end

			s_run: begin
				if((single_convo_done & ready) && (valid & ready_for_data)) state <= s_run;
				else if(single_convo_done & ready) state <= s_idle;
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
		load <= 1'b0;
		convo_data_in <= 'h0;
	end else begin
		load <= 1'b0;
		convo_data_in <= convo_data_in;
		case(state) 
			s_idle: begin
				if(valid) begin
					load <= 1'b1;
					convo_data_in <= data_in;				
				end 
			end
			
			s_run: begin
				if((single_convo_done & ready) && (valid & ready_for_data)) begin
					load <= 1'b1;
					convo_data_in <= data_in;				
				end 
			end			
			
			
				
		endcase
	end

end

// done信号拉高后只有load信号置1才能重置done信号
single_convo_compute single_convo_compute_inst(
	.clk			(clk)				,
	.reset_n		(reset_n)			,
	.load			(load)				,
	.din			(convo_data_in)		,
	.filter			(filter)			,
	.ready			(ready)				,
	.done			(single_convo_done)	,
	.reg_convo_out	(convo_out)			
    );



endmodule
