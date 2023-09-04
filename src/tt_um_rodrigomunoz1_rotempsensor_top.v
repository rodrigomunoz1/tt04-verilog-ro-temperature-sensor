`timescale 1ns / 1ps

module tt_um_rodrigomunoz1_rotempsensor_top(
	input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

//INPUTS
assign clk_internal	= clk;
//assign clk_internal	= ui_in[0];
assign clk_external	= ui_in[1];
assign clk_sel		= ui_in[2];
assign en_inv_osc	= ui_in[3];
assign en_nand_osc	= ui_in[4];
//assign reset		= ui_in[5];
assign rx			= ui_in[6];
assign osc_sel		= ui_in[7];

//OUTPUTS
assign uo_out[0] = tx;
assign uo_out[1] = count_reg[8];
assign uo_out[2] = count_reg[9];
assign uo_out[3] = count_reg[10];
assign uo_out[4] = count_reg[11];
assign uo_out[5] = count_reg[12];
assign uo_out[6] = count_reg[13];
assign uo_out[7] = count_reg[14];

//INTERNALS
wire rx, rx_ready, tx, tx_start, tx_busy, test;
wire sum_ready, sum_en;
wire osc_sel, en_inv_osc, en_nand_osc, en;
wire clk_external, clk_sel, clk_internal, clk1;
wire out_osc_inv, out_osc_nand, out_osc;
wire [23:0] promedio;
wire [15:0] count;
reg [15:0] count_reg;
wire [7:0] rx_data;
reg [7:0] tx_data;
wire [1:0] send_sel;


//Clocks management
mux m(clk_external, clk_internal, clk_sel, clk1);

mux m3(en_inv_osc, en_nand_osc, osc_sel, en);

//tx_data management
always @* begin
	case(send_sel)
		0: tx_data = promedio[7:0];
		1: tx_data = promedio[15:8];
		2: tx_data = promedio[23:16];
		default: tx_data = promedio[7:0];
	endcase
end

//Oscillators
USM_ringoscillator_inv2 osc1(en_inv_osc, out_osc_inv);
USM_ringoscillator_nand4 osc2(en_nand_osc, out_osc_nand);
mux m2(out_osc_inv, out_osc_nand, osc_sel, out_osc);

//Counters
contador #(16) cont(out_osc, en, rst_n, clk1, count);

always @(posedge clk1) begin
	if(!rst_n) count_reg <= 0;
	else count_reg <= count; 
end

promedio #(24) prom(clk1, rst_n, en, sum_en, count, promedio, sum_ready);

//Controller
FSM_controller controller(clk1, rst_n, sum_ready, test, rx_ready, 
							rx_data, sum_en, tx_start, send_sel);

//Comunication
uart_basic #(10000,1000) uart(clk1, rst_n, rx, rx_data, rx_ready, tx, 
								tx_start, tx_data, test);

endmodule
