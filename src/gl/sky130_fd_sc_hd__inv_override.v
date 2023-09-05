// This is a workaround for the simulation model of sky130_fd_sc_hd__inv, which is missing `UNIT_DELAY before the not primitive.
// Without this, the simulation never completes.
// Taken from https://github.com/TinyTapeout/tt03p5-ringosc-cnt/

`ifndef SKY130_FD_SC_HD__INV_FUNCTIONAL_PP_V
`define SKY130_FD_SC_HD__INV_FUNCTIONAL_PP_V

/**
 * inv: Inverter.
 *
 * Verilog simulation functional model.
 */

`timescale 1ns / 1ps
`default_nettype none

// Import user defined primitives.

`celldefine
module sky130_fd_sc_hd__inv (
    Y   ,
    A   ,
    VPWR,
    VGND,
    VPB ,
    VNB
);

    // Module ports
    output Y   ;
    input  A   ;
    input  VPWR;
    input  VGND;
    input  VPB ;
    input  VNB ;

    // Local signals
    wire not0_out_Y       ;
    wire pwrgood_pp0_out_Y;

    //                                 Name         Output             Other arguments
    not            `UNIT_DELAY         not0        (not0_out_Y       , A                     );
    sky130_fd_sc_hd__udp_pwrgood_pp$PG pwrgood_pp0 (pwrgood_pp0_out_Y, not0_out_Y, VPWR, VGND);
    buf                                buf0        (Y                , pwrgood_pp0_out_Y     );

endmodule
`endcelldefine
`endif