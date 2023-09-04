`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tb ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs and outputs
    reg  clk;
    reg  rst_n;
    reg  ena;
    wire [7:0] ui_in;
    reg [7:0] uo_out;
    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    //inputs signals
    reg clk_external;
    reg clk_sel;
    reg en_inv_osc;
    reg en_nand_osc;
    reg rx;
    reg osc_sel;
    //outputs signals
    wire tx;
    wire [6:0] counter;

    //assign
    assign ui_in[1] = clk_external;
    assign ui_in[2] = clk_sel;
    assign ui_in[3] = en_inv_osc;
    assign ui_in[4] = en_nand_osc;
    assign ui_in[6] = rx;
    assign ui_in[7] = osc_sel;
    //outputs signals map
    assign tx           = uo_out[0];
    assign counter      = uo_out[7:1];

    tt_um_rodrigomunoz1_rotempsensor_top tt_rodrigomunoz1_rotempsensor_top (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .ui_in      (ui_in),    // Dedicated inputs
        .uo_out     (uo_out),   // Dedicated outputs
        .uio_in     (uio_in),   // IOs: Input path
        .uio_out    (uio_out),  // IOs: Output path
        .uio_oe     (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
        .ena        (ena),      // enable - goes high when design is selected
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
        );

endmodule
