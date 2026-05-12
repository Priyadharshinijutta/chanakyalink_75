module uart_tx
#(
parameter CLKS_PER_BIT = 87
)

(
    input clk,
    input rst,

    input tx_start,
    input [7:0] tx_data,

    output reg tx,
    output reg tx_busy
);

reg [15:0] clk_count;
reg [3:0] bit_index;
reg [9:0] tx_shift;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        tx <= 1;
        tx_busy <= 0;
        clk_count <= 0;
        bit_index <= 0;
    end

    else
    begin

        if(tx_start && !tx_busy)
        begin
            tx_shift <= {1'b1, tx_data, 1'b0};
            tx_busy <= 1;
            bit_index <= 0;
            clk_count <= 0;
        end

        else if(tx_busy)
        begin

            if(clk_count < CLKS_PER_BIT-1)
            begin
                clk_count <= clk_count + 1;
            end

            else
            begin
                clk_count <= 0;

                tx <= tx_shift[bit_index];

                if(bit_index < 9)
                    bit_index <= bit_index + 1;

                else
                begin
                    tx_busy <= 0;
                    tx <= 1;
                end
            end
        end
    end
end

endmodule
