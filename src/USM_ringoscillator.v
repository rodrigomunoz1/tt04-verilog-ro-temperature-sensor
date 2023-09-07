`default_nettype none
`timescale 1ns/1ps

module nand_with_delay(
	input A, 
	output Y
);

`ifdef COCOTB_SIM
//assign #0.02 Y=~A;
assign #20 Y=~A;
`else
sky130_fd_sc_hd__nand4_4 nand4(.Y(Y), .A(A), .B(A), .C(A), .D(A));
//nor #(2) (Y,A,A);
`endif
endmodule

module inv_with_delay(
	input A, 
	output Y
);

`ifdef COCOTB_SIM
//assign #0.02 Y=~A;
assign #20 Y=~A;
`else
sky130_fd_sc_hd__inv_2 inv(.A(A),.Y(Y));
//nor #(2) (Y,A,A);
`endif
endmodule

module USM_ringoscillator_inv2#(parameter etapas = 15)(

	input en,
	output out

);


//localparam etapas = 15;

wire aux_wire [etapas:0];
    
genvar i;
generate
for(i=0; i<etapas; i=i+1) begin
   inv_with_delay inv(aux_wire[i], aux_wire[i+1]);
end
endgenerate

//assign aux_wire[0] = out & en;
and andd(aux_wire[0], out, en);
assign out = aux_wire[etapas];

endmodule

module USM_ringoscillator_nand4#(parameter etapas = 15)(

	input en,
	output out

);


//localparam etapas = 15;

wire aux_wire [etapas:0];
    
genvar i;
generate
for(i=0; i<etapas; i=i+1) begin
   nand_with_delay inv(aux_wire[i], aux_wire[i+1]);
end
endgenerate

//assign aux_wire[0] = out & en;
and andd(aux_wire[0], out, en);
assign out = aux_wire[etapas];

endmodule
