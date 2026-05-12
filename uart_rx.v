//==============================================================
// FILE: uart_rx.v
// UART RECEIVER
//==============================================================

module uart_rx #(parameter CLKS_PER_BIT = 87)
(
    input clk,
    input rst,

    input rx_serial,

    output reg rx_done,
    output reg [7:0] rx_data
);

    reg [3:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;

    localparam IDLE      = 0,
               START_BIT = 1,
               DATA_BITS = 2,
               STOP_BIT  = 3,
               CLEANUP   = 4;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            state <= IDLE;
            rx_done <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end

        else
        begin
            case(state)

            IDLE:
            begin
                rx_done <= 0;

                if(rx_serial == 0)
                begin
                    clk_count <= 0;
                    state <= START_BIT;
                end
            end

            START_BIT:
            begin
                if(clk_count == (CLKS_PER_BIT-1)/2)
                begin
                    if(rx_serial == 0)
                    begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                    end
                    else
                        state <= IDLE;
                end
                else
                    clk_count <= clk_count + 1;
            end

            DATA_BITS:
            begin
                if(clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else
                begin
                    clk_count <= 0;
                    rx_data[bit_index] <= rx_serial;

                    if(bit_index < 7)
                        bit_index <= bit_index + 1;
                    else
                    begin
                        bit_index <= 0;
                        state <= STOP_BIT;
                    end
                end
            end

            STOP_BIT:
            begin
                if(clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else
                begin
                    rx_done <= 1'b1;
                    clk_count <= 0;
                    state <= CLEANUP;
                end
            end

            CLEANUP:
            begin
                state <= IDLE;
                rx_done <= 0;
            end

            endcase
        end
    end

endmodule
