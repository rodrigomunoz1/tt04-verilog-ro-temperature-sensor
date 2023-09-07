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

module mux4in(	input a,
				input b,
				input c,
				input d,
				input[1:0] sel,
				output reg y);

always @(a or b or c or d or sel) begin
	case(sel)
		2'b00: y <= a;
		2'b01: y <= b;
		2'b10: y <= c;
		2'b11: y <= d;
	endcase
end

endmodule
