module contador#(parameter N = 8)(input osc_clk, input en, input reset_n, 
									input clk, output reg [N-1:0] count);

reg aux;
reg pre_aux;

always @(posedge osc_clk) begin
	if(!reset_n) aux <= 1;
	//else aux <= pre_aux;
end

always @(posedge osc_clk) begin
	if(clk && aux) begin
		aux <= 0;
		count <= 0;
	end
	else if(en) begin
		if(!clk) aux<= 1;
		count <= count + 1;
	end
end

endmodule
