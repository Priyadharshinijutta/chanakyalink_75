//==============================================================
// FILE: uart_tx.v
// UART TRANSMITTER
//==============================================================

module uart_tx #(parameter CLKS_PER_BIT = 87)
(
    input clk,
    input rst,

    input tx_start,
    input [7:0] tx_data,

    output reg tx_serial,
    output reg tx_done
);

    reg [3:0] state;
    reg [7:0] data_reg;
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
            state      <= IDLE;
            tx_serial  <= 1'b1;
            tx_done    <= 0;
            clk_count  <= 0;
            bit_index  <= 0;
        end

        else
        begin
            case(state)

            IDLE:
            begin
                tx_serial <= 1'b1;
                tx_done   <= 0;
                clk_count <= 0;
                bit_index <= 0;

                if(tx_start)
                begin
                    data_reg <= tx_data;
                    state <= START_BIT;
                end
            end

            START_BIT:
            begin
                tx_serial <= 1'b0;

                if(clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else
                begin
                    clk_count <= 0;
                    state <= DATA_BITS;
                end
            end

            DATA_BITS:
            begin
                tx_serial <= data_reg[bit_index];

                if(clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else
                begin
                    clk_count <= 0;

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
                tx_serial <= 1'b1;

                if(clk_count < CLKS_PER_BIT-1)
                    clk_count <= clk_count + 1;
                else
                begin
                    tx_done <= 1'b1;
                    clk_count <= 0;
                    state <= CLEANUP;
                end
            end

            CLEANUP:
            begin
                tx_done <= 0;
                state <= IDLE;
            end

            endcase
        end
    end

endmodule
