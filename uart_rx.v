module uart_rx
#(
parameter CLKS_PER_BIT = 87
)

(
    input clk,
    input rst,

    input rx,

    output reg [7:0] rx_data,
    output reg rx_done
);

reg [15:0] clk_count;
reg [3:0] bit_index;
reg [9:0] rx_shift;
reg busy;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        clk_count <= 0;
        bit_index <= 0;
        busy <= 0;
        rx_done <= 0;
    end

    else
    begin

        rx_done <= 0;

        if(!busy && rx == 0)
        begin
            busy <= 1;
            clk_count <= 0;
            bit_index <= 0;
        end

        else if(busy)
        begin

            if(clk_count < CLKS_PER_BIT-1)
            begin
                clk_count <= clk_count + 1;
            end

            else
            begin

                clk_count <= 0;

                rx_shift[bit_index] <= rx;

                if(bit_index < 9)
                    bit_index <= bit_index + 1;

                else
                begin
                    busy <= 0;
                    rx_data <= rx_shift[8:1];
                    rx_done <= 1;
                end
            end
        end
    end
end

endmodule
