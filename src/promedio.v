module promedio #(parameter N=8)(
	input clk, 
	input reset_n, 
	input en,
	input [2:0] sum_sel,
	input sum_en,
	input [15:0] in,
	output reg [N-1:0] out,
	output reg sum_redy
); 

reg [7:0] contador;
reg [N-1:0] promedio;
wire [7:0] contador_max;

assign contador_max = (sum_sel + 1) << 4;

always @(posedge clk) begin
	if(!reset_n | !en | !sum_en) contador <= 0;
	else contador <= contador + 1;
end

always @(posedge clk) begin
	if(!reset_n | contador == 0 | !en) promedio <= 0;
	else if(contador == contador_max) promedio <= promedio;
	else promedio <= promedio + in;
end	

always @(posedge clk) begin
	if(!reset_n) sum_redy <= 0;
	else if(contador == contador_max) sum_redy <= 1;
	else sum_redy <= 0;
end

always @(posedge clk) begin
	if(!reset_n) out <= 0;
	else if(sum_redy) out <= promedio;
end
	
endmodule
