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
assign clk_external	= ui_in[0];
assign clk_sel		= ui_in[1];
assign sum_sel[2:0]	= ui_in[4:2];
assign rx			= ui_in[5];
assign osc_sel[1:0]	= ui_in[7:6];

//OUTPUTS
assign uo_out[0] = tx;
assign uo_out[7:1] = count_reg[7:1];//7'b0000000;
assign uio_out[7:0] = count_reg[15:8];
assign uio_oe = 8'b11111111;

//INTERNALS
//ring oscillators
wire [1:0] osc_sel;
wire [3:0] en_osc;
wire en;
wire [3:0] out_osc_n;
wire out_osc;

//selection of clock
wire clk_external, clk_sel, clk_internal, clk1;

wire rx, rx_ready, tx, tx_start, tx_busy, test;
wire sum_ready, sum_en;
wire [2:0] sum_sel;
wire [23:0] promedio;
wire [15:0] count;
reg [15:0] count_reg;
wire [7:0] rx_data;
reg [7:0] tx_data;
wire [1:0] send_sel;


//Clocks management
mux m(clk_external, clk_internal, clk_sel, clk1);

assign en_osc = (ena && rst_n) ? 4'b0001 << osc_sel : 4'b0000; //enable selected oscillator

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
USM_ringoscillator_inv2 #(15) osc1(en_osc[0], out_osc_n[0]);
USM_ringoscillator_nand4 #(15) osc2(en_osc[1], out_osc_n[1]);
USM_ringoscillator_inv2 #(7) osc3(en_osc[2], out_osc_n[2]);
USM_ringoscillator_nand4 #(21) osc4(en_osc[3], out_osc_n[3]);

mux4in m2(	out_osc_n[0], out_osc_n[1], out_osc_n[2], out_osc_n[3], 
			osc_sel, out_osc);

//Counters
contador #(16) cont(out_osc, ena, rst_n, clk1, count);

always @(posedge clk1) begin
	if(!rst_n) count_reg <= 0;
	else count_reg <= count; 
end

promedio #(24) prom(clk1, rst_n, ena, sum_sel, sum_en, count, promedio,
					sum_ready);

//Controller
FSM_controller controller(clk1, rst_n, sum_ready, test, rx_ready, 
							rx_data, sum_en, tx_start, send_sel);

//Comunication
uart_basic #(10000000,115200) uart(clk1, rst_n, rx, rx_data, rx_ready, tx, 
								tx_start, tx_data, test);

endmodule
