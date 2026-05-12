module chanakyalink_slave
#(
parameter MY_ID = 1
)

(
    input clk,
    input rst,

    input rx_valid,

    input [7:0] start_byte,
    input [7:0] slave_id,
    input [7:0] command,
    input [15:0] delay_value,
    input [7:0] checksum,
    input [7:0] stop_byte,

    output reg ack,
    output reg nack,

    output reg cmd_execute
);

localparam START_BYTE = 8'hAA;
localparam STOP_BYTE  = 8'h55;

wire [7:0] calc_checksum;

assign calc_checksum =
        slave_id ^
        command ^
        delay_value[15:8] ^
        delay_value[7:0];

reg [31:0] delay_counter;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        ack <= 0;
        nack <= 0;
        cmd_execute <= 0;
        delay_counter <= 0;
    end

    else
    begin

        ack <= 0;
        nack <= 0;

        if(rx_valid)
        begin

            if(start_byte == START_BYTE &&
               stop_byte  == STOP_BYTE)
            begin

                if(slave_id == MY_ID)
                begin

                    if(checksum == calc_checksum)
                    begin

                        ack <= 1;

                        delay_counter <= delay_value;

                    end

                    else
                    begin
                        nack <= 1;
                    end
                end
            end
        end

        if(delay_counter > 0)
        begin

            delay_counter <= delay_counter - 1;

            if(delay_counter == 1)
            begin
                cmd_execute <= 1;
            end
        end

        else
        begin
            cmd_execute <= 0;
        end
    end
end

endmodule
