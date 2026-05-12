//============================================================
// FILE : chanakyalink_master.v
//============================================================

module chanakyalink_master(
    input clk,
    input rst,

    input [7:0] slave_id,
    input [15:0] delay_value,

    output reg [7:0] tx_slave_id,
    output reg [7:0] tx_command,
    output reg [15:0] tx_delay,
    output reg [7:0] tx_checksum,

    output reg frame_valid
);

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        frame_valid <= 0;
    end

    else
    begin

        tx_slave_id <= slave_id;
        tx_command <= 8'd1;
        tx_delay <= delay_value;

        tx_checksum <=
            slave_id ^
            8'd1 ^
            delay_value[15:8] ^
            delay_value[7:0];

        frame_valid <= 1;

        $display("[MASTER] FRAME SENT TO SLAVE %0d", slave_id);

    end

end

endmodule
