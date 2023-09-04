module mux(input a,input b,input sel,output reg y);

always @(a or b or sel) begin
	case(sel)
		0: begin
			y <= a;
		end
		1: begin
			y <= b;
		end
		default y <= a;
	endcase
end

endmodule
