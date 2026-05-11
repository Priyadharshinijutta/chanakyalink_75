//==============================================================
// FILE: chanakyalink_slave.v
// SLAVE NODE
//==============================================================

module chanakyalink_slave
(
    input clk,
    input rst,

    input rx,

    output reg ack
);

    wire rx_done;
    wire [7:0] rx_data;

    reg [7:0] slave_id;
    reg [7:0] command;
    reg [15:0] delay_value;
    reg [7:0] recv_checksum;

    reg [7:0] calc_checksum;

    reg [2:0] byte_count;

    uart_rx UART_RX
    (
        .clk(clk),
        .rst(rst),
        .rx_serial(rx),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

    always @(posedge clk or posedge rst)
    begin

        if(rst)
        begin
            byte_count <= 0;
            ack <= 0;
        end

        else
        begin

            if(rx_done)
            begin

                case(byte_count)

                0:
                begin
                    slave_id <= rx_data;
                    byte_count <= 1;
                end

                1:
                begin
                    command <= rx_data;
                    byte_count <= 2;
                end

                2:
                begin
                    delay_value[15:8] <= rx_data;
                    byte_count <= 3;
                end

                3:
                begin
                    delay_value[7:0] <= rx_data;
                    byte_count <= 4;
                end

                4:
                begin
                    recv_checksum <= rx_data;

                    calc_checksum <= slave_id ^
                                     command ^
                                     delay_value[15:8] ^
                                     delay_value[7:0];

                    $display("\n[SLAVE] Packet Received");
                    $display("ID       = %0d", slave_id);
                    $display("COMMAND  = %0d", command);
                    $display("DELAY    = %0d", delay_value);

                    if(recv_checksum == calc_checksum)
                    begin
                        $display("[SLAVE] Checksum PASS");
                        ack <= 1;
                    end
                    else
                    begin
                        $display("[SLAVE] Checksum FAIL");
                        ack <= 0;
                    end

                    byte_count <= 0;
                end

                endcase

            end

            else
                ack <= 0;

        end

    end

endmodule
