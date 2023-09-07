module FSM_controller (
	//INPUTS
	input clk, reset_n, sum_ready, 
	input tx_busy, 
	input rx_ready,
	input [7:0] rx_data,
	//OUTPUTS
	output reg sum_en,
	output reg tx_send,
	output reg [1:0] send_sel
);

reg [15:0] timer;

reg [3:0] state, next_state;
localparam IDLE = 0;
localparam DECODER = 1;
localparam WAIT_SUM = 2;
localparam SEND_SUM_1 = 3;
localparam WAIT_SEND_1 = 4;
localparam SEND_SUM_2 = 5;
localparam WAIT_SEND_2 = 6;
localparam SEND_SUM_3 = 7;
localparam WAIT_SEND_3 = 8;

localparam START_CODE = 0;

always @* begin
	//Default state of outputs
	next_state = state;
	sum_en = 0;
	tx_send = 0;
	send_sel = 0;
	//FSM core
	case(state)
		//Default state: de cicle start once a uart data has been receive.
		IDLE: begin
			if(rx_ready) next_state = DECODER;
			else next_state = state;
		end
		//Decoder state
		DECODER: begin
			if(rx_data == START_CODE) next_state = WAIT_SUM;
			else next_state = IDLE;
		end
		//State that starts de adder and wait for a result. Also wait for a code sent throught UART
		WAIT_SUM: begin
			sum_en = 1;
			if(rx_ready) next_state = DECODER;
			else if(sum_ready) next_state = SEND_SUM_1;
			else next_state = state;
		end
		//send state: enable the uart signal to send the sum with the UART.
		SEND_SUM_1: begin
			tx_send = 1;
			next_state = WAIT_SEND_1;
		end
		WAIT_SEND_1: begin
			//if(!tx_busy) next_state = SEND_SUM_2;
			if(timer >= 868) next_state = SEND_SUM_2;
		end
		SEND_SUM_2: begin
			tx_send = 1;
			send_sel = 1;
			next_state = WAIT_SEND_2;
		end
		WAIT_SEND_2: begin
			send_sel = 1;
			//if(!tx_busy) next_state = SEND_SUM_3;
			if(timer >= 868) next_state = SEND_SUM_3;
		end
		SEND_SUM_3: begin
			tx_send = 1;
			send_sel = 2;
			next_state = WAIT_SEND_3;
		end
		WAIT_SEND_3: begin
			send_sel = 2;
			//if(!tx_busy) next_state = IDLE;
			if(timer >= 868) next_state = IDLE;
		end
	endcase
end
//Stete control
always @(posedge clk) begin
	if(!reset_n) state <= IDLE;
	else state <= next_state;
end

always @(posedge clk) begin
	if(!reset_n) timer <= 0;
	else if(state != next_state) timer <= 0;
	else timer <= timer + 1;
end

endmodule
