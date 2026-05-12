module chanakyalink_master
#(
parameter CLK_FREQ = 50000000,
parameter BAUD_RATE = 9600
)

(
    input clk,
    input rst,

    input start,

    input ack,
    input nack,

    input [7:0] slave_id,
    input [7:0] command,
    input [15:0] delay_value,

    output tx,

    output reg done,
    output reg error
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

localparam START_BYTE = 8'hAA;
localparam STOP_BYTE  = 8'h55;

localparam IDLE      = 0;
localparam SEND0     = 1;
localparam SEND1     = 2;
localparam SEND2     = 3;
localparam SEND3     = 4;
localparam SEND4     = 5;
localparam SEND5     = 6;
localparam SEND6     = 7;
localparam WAIT_ACK  = 8;
localparam DONE      = 9;
localparam ERROR     = 10;

wire tx_busy;

reg tx_start;
reg [7:0] tx_data;

reg [3:0] state;

reg [31:0] timeout_counter;

wire [7:0] checksum;

assign checksum =
        slave_id ^
        command ^
        delay_value[15:8] ^
        delay_value[7:0];

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

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        state <= IDLE;
        tx_start <= 0;
        tx_data <= 0;
        done <= 0;
        error <= 0;
        timeout_counter <= 0;
    end

    else
    begin

        tx_start <= 0;

        case(state)

        IDLE:
        begin
            done <= 0;
            error <= 0;

            if(start)
                state <= SEND0;
        end

        SEND0:
        begin
            if(!tx_busy)
            begin
                tx_data <= START_BYTE;
                tx_start <= 1;
                state <= SEND1;
            end
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
                state <= SEND6;
            end
        end

        SEND6:
        begin
            if(!tx_busy)
            begin
                tx_data <= STOP_BYTE;
                tx_start <= 1;
                state <= WAIT_ACK;
            end
        end

        WAIT_ACK:
        begin

            timeout_counter <= timeout_counter + 1;

            if(ack)
            begin
                state <= DONE;
            end

            else if(nack)
            begin
                state <= ERROR;
            end

            else if(timeout_counter > 100000)
            begin
                state <= ERROR;
            end
        end

        DONE:
        begin
            done <= 1;

            if(!start)
                state <= IDLE;
        end

        ERROR:
        begin
            error <= 1;

            if(!start)
                state <= IDLE;
        end

        endcase
    end
end

endmodule
