//============================================================
// FILE : chanakyalink_slave.v
//============================================================

module chanakyalink_slave
#(
    parameter MY_ID = 1
)
(
    input clk,
    input rst,

    input [7:0] slave_id,
    input [7:0] command,
    input [15:0] delay_value,
    input [7:0] checksum,

    input frame_valid,

    output reg cmd_execute
);

reg [15:0] delay_counter;
reg [7:0] calc_checksum;

localparam IDLE  = 2'd0;
localparam VERIFY = 2'd1;
localparam DELAY  = 2'd2;
localparam EXECUTE = 2'd3;

reg [1:0] state;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        state <= IDLE;
        cmd_execute <= 0;
        delay_counter <= 0;
    end

    else
    begin

        case(state)

        IDLE:
        begin
            cmd_execute <= 0;

            if(frame_valid)
            begin

                if(slave_id == MY_ID)
                begin
                    $display("[SLAVE %0d] FRAME ACCEPTED", MY_ID);

                    calc_checksum =
                        slave_id ^
                        command ^
                        delay_value[15:8] ^
                        delay_value[7:0];

                    state <= VERIFY;
                end

                else
                begin
                    $display("[SLAVE %0d] FRAME IGNORED", MY_ID);
                end

            end
        end

        VERIFY:
        begin

            if(calc_checksum == checksum)
            begin
                $display("[SLAVE %0d] CHECKSUM PASSED", MY_ID);

                delay_counter <= delay_value;

                state <= DELAY;
            end

            else
            begin
                $display("[SLAVE %0d] CHECKSUM FAILED", MY_ID);

                state <= IDLE;
            end

        end

        DELAY:
        begin

            if(delay_counter > 0)
            begin
                delay_counter <= delay_counter - 1;
            end

            else
            begin
                state <= EXECUTE;
            end

        end

        EXECUTE:
        begin

            cmd_execute <= 1;

            if(command == 1)
            begin
                $display("[SLAVE %0d] DEVICE ACTIVATED", MY_ID);
            end

            else
            begin
                $display("[SLAVE %0d] DEVICE DEACTIVATED", MY_ID);
            end

            state <= IDLE;

        end

        endcase

    end

end

endmodule
