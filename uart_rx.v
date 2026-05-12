//============================================================
// FILE : uart_rx.v
//============================================================

module uart_rx(
    input clk,
    input rst,
    input rx,

    output reg [7:0] rx_data,
    output reg rx_done
);

reg [3:0] bit_index;
reg [7:0] shift_reg;
reg receiving;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        bit_index <= 0;
        shift_reg <= 0;
        rx_done <= 0;
        receiving <= 0;
    end

    else
    begin

        rx_done <= 0;

        if(!receiving && rx == 0)
        begin
            receiving <= 1;
            bit_index <= 0;
        end

        else if(receiving)
        begin
            shift_reg[bit_index] <= rx;
            bit_index <= bit_index + 1;

            if(bit_index == 7)
            begin
                receiving <= 0;
                rx_data <= shift_reg;
                rx_done <= 1;
            end
        end

    end

end

endmodule
