module chanakyalink_master #(parameter CLK_FREQ = 50000000,
                             parameter BAUD_RATE = 9600)

(
    input clk,
    input rst,

    input start,

    input [7:0] slave_id,
    input [7:0] command,
    input [15:0] delay_value,

    output tx,
    output reg done
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

wire tx_busy;
reg tx_start;
reg [7:0] tx_data;

uart_tx #(CLKS_PER_BIT)
UART_TX
(
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

reg [2:0] state;

localparam IDLE  = 0;
localparam SEND1 = 1;
localparam SEND2 = 2;
localparam SEND3 = 3;
localparam SEND4 = 4;
localparam SEND5 = 5;
localparam DONE  = 6;

wire [7:0] checksum;

assign checksum =
        slave_id ^
        command ^
        delay_value[15:8] ^
        delay_value[7:0];

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        state <= IDLE;
        tx_start <= 0;
        tx_data <= 0;
        done <= 0;
    end

    else
    begin

        tx_start <= 0;

        case(state)

        IDLE:
        begin
            done <= 0;

            if(start)
                state <= SEND1;
        end

        SEND1:
        begin
            if(!tx_busy)
            begin
                tx_data <= slave_id;
                tx_start <= 1;
                state <= SEND2;
            end
        end

        SEND2:
        begin
            if(!tx_busy)
            begin
                tx_data <= command;
                tx_start <= 1;
                state <= SEND3;
            end
        end

        SEND3:
        begin
            if(!tx_busy)
            begin
                tx_data <= delay_value[15:8];
                tx_start <= 1;
                state <= SEND4;
            end
        end

        SEND4:
        begin
            if(!tx_busy)
            begin
                tx_data <= delay_value[7:0];
                tx_start <= 1;
                state <= SEND5;
            end
        end

        SEND5:
        begin
            if(!tx_busy)
            begin
                tx_data <= checksum;
                tx_start <= 1;
                state <= DONE;
            end
        end

        DONE:
        begin
            done <= 1;

            if(!start)
                state <= IDLE;
        end

        endcase
    end
end

endmodule
