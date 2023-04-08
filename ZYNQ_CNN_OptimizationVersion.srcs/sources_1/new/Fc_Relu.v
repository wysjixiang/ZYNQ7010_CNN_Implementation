


// 要实现49->49的线性层，需要49*50个时钟周期，即2450个
// 以50MHz为例，则需要2450*20ns = 49us
// 实现49输入，49输出的一个fc、relu层
// 考虑到实际板子资源，选择将每一个节点的product_fac设置为相同的值
module Fc_Relu(clk,reset_n,data_in,bias,valid,ready,ready_for_data,done,data_out);


parameter input_node = 49;
parameter output_node = 49;
localparam width = 16;



input clk;
input reset_n;
input [input_node*width-1:0] data_in ;
input [output_node*width-1:0] bias;
// input [input_node*output_node*width-1:0] product_fac ;
(* keep = "true" *) input valid;			//上游数据发送状态
(* keep = "true" *) input ready;			//下游数据接收状态
(* keep = "true" *) output ready_for_data;	//自身数据接收状态
(* keep = "true" *) output done;
(* keep = "true" *) output reg [output_node*width-1:0] data_out;


// wire & reg
reg en_pulse_fc;
(* keep = "true" *) reg [input_node*width-1:0] data_fc ;

(* keep = "true" *) reg [width-1:0] bias_fc;
// reg [input_node*width-1:0] product_fc;
localparam product_fc = 784'h211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E211E; // 49个211E
(* keep = "true" *) wire [width-1:0] data_out_fc;
(* keep = "true" *) wire [width-1:0] data_relu;
(* keep = "true" *) wire done_node;


// state machine
localparam s_idle =0;
localparam s_switch =1;
localparam s_run =2;
localparam s_end =3;
reg [1:0] state;


(* keep = "true" *) reg [5:0] cnt;


// initial不可综合，只能仿真时候用用
// integer i;
// initial begin
	// for(i=0;i<input_node;i=i+1) begin: loop
		// product_fc[i*width+:width] = 16'h211E;	// 0.01
	// end
// end

// assign 
assign done = (state == s_end);
assign ready_for_data = (state == s_idle);


assign data_relu = ((data_out_fc[width-1] == 1'b1)? 'h0:data_out_fc);


///////////////////
// 状态机切换
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		state <= s_idle;
	end else begin
		case(state) 
	
			s_idle: begin
				if(valid) state <= s_switch;
				else state <= s_idle;
			end
		
			s_switch: begin
				state <= s_run;
			end

			s_run: begin
				if(done_node && cnt == output_node) state <= s_end;
				else if(done_node) state <= s_switch;
				else state <= state;
			end
			
			s_end: begin
				if(ready) state <= s_idle;
				else state <= state;
			end

			default: begin
				state <= state;
			end			
		
		endcase
	end
end


// data_fc FF
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		data_fc <= 'h0;
	end else if(state == s_idle && valid) 
		data_fc <= data_in;
	else data_fc <= data_fc;

end

// en_pulse_fc信号
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		en_pulse_fc <= 1'b0;
		// product_fc <= 'h0;
		bias_fc <= 'h0;
	end else begin
		en_pulse_fc <= 1'b0;
		// product_fc <= product_fc;
		bias_fc <= bias_fc;
		case(state) 
			s_idle: begin
				if(valid) begin
					en_pulse_fc <= 1'b1;
					// product_fc <= product_fac[0+:width*input_node];
					bias_fc <= bias[0+:width];
				end 
			end
		
			s_run: begin
				if(done_node && cnt == output_node) begin
					en_pulse_fc <= 1'b0;
				end else if(done_node) begin
					en_pulse_fc <= 1'b1;
					// product_fc <= product_fac[cnt*width*input_node+:width*input_node];
					bias_fc <= bias[cnt*width+:width];
				end
			
			end
				
		endcase
	end

end


// 计数cnt模块
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		cnt <= 'd1;
	end else begin
	
		case(state) 
			s_idle: cnt <= 'd1;
			s_run: begin
				if(done_node && cnt == output_node) cnt <= cnt;
				else if(done_node) cnt <= cnt + 1'b1;
				else cnt <= cnt;
			end
			default: cnt <= cnt;
		
		endcase
	
	end

end


// data_out模块
always@(posedge clk or negedge reset_n) begin
	if(~reset_n) begin
		data_out <= 'h0;
	end else if(state == s_run && done_node) data_out[(cnt-1)*width+:width] <= data_relu;
	else data_out <= data_out;
end	



////////////////////




single_node_compute #(
	.node(input_node)
)single_node_compute_inst(
	.clk			(clk),
	.reset_n		(reset_n),
	.en_pulse		(en_pulse_fc),
	.product_fac	(product_fc),
	.bias			(bias_fc),
	.data_in		(data_fc),
	.done			(done_node),
	.data_out		(data_out_fc)
);
	
	
endmodule
