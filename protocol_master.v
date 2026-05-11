//==============================================================
// FILE: chanakyalink_master.v
// MASTER CONTROLLER WITH UART + AI + TIMEOUT
//==============================================================

module chanakyalink_master
(
    input clk,
    input rst,

    input [2:0] threat_level,
    input [2:0] priority,

    input ack,

    output tx
);

    wire [7:0] ai_slave;
    wire [15:0] ai_delay;

    reg tx_start;
    reg [7:0] tx_data;

    wire tx_done;

    reg [7:0] command;
    reg [7:0] checksum;

    reg [31:0] timeout_counter;

    reg [3:0] state;

    localparam IDLE      = 0,
               SEND_ID   = 1,
               SEND_CMD  = 2,
               SEND_D1   = 3,
               SEND_D2   = 4,
               SEND_CSUM = 5,
               WAIT_ACK  = 6;

    ai_decision_module AI
    (
        .threat_level(threat_level),
        .priority(priority),
        .slave_id(ai_slave),
        .delay_value(ai_delay)
    );

    uart_tx UART_TX
    (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_serial(tx),
        .tx_done(tx_done)
    );

    always @(posedge clk or posedge rst)
    begin

        if(rst)
        begin
            state <= IDLE;
            tx_start <= 0;
            timeout_counter <= 0;
        end

        else
        begin

            checksum <= ai_slave ^ command ^
                        ai_delay[15:8] ^
                        ai_delay[7:0];

            case(state)

            IDLE:
            begin
                command <= 8'd1;

                $display("\n[MASTER] AI Selected Slave : %0d", ai_slave);
                $display("[MASTER] Delay Value      : %0d ms", ai_delay);

                state <= SEND_ID;
            end

            SEND_ID:
            begin
                tx_data <= ai_slave;
                tx_start <= 1;
                state <= SEND_CMD;
            end

            SEND_CMD:
            begin
                tx_start <= 0;

                if(tx_done)
                begin
                    tx_data <= command;
                    tx_start <= 1;
                    state <= SEND_D1;
                end
            end

            SEND_D1:
            begin
                tx_start <= 0;

                if(tx_done)
                begin
                    tx_data <= ai_delay[15:8];
                    tx_start <= 1;
                    state <= SEND_D2;
                end
            end

            SEND_D2:
            begin
                tx_start <= 0;

                if(tx_done)
                begin
                    tx_data <= ai_delay[7:0];
                    tx_start <= 1;
                    state <= SEND_CSUM;
                end
            end

            SEND_CSUM:
            begin
                tx_start <= 0;

                if(tx_done)
                begin
                    tx_data <= checksum;
                    tx_start <= 1;

                    $display("[MASTER] UART Frame Sent");
                    state <= WAIT_ACK;
                end
            end

            WAIT_ACK:
            begin

                tx_start <= 0;

                timeout_counter <= timeout_counter + 1;

                if(ack)
                begin
                    $display("[MASTER] ACK Received");
                    state <= IDLE;
                    timeout_counter <= 0;
                end

                else if(timeout_counter > 500000)
                begin
                    $display("[ERROR] ACK Timeout");
                    state <= IDLE;
                    timeout_counter <= 0;
                end
            end

            endcase
        end
    end

endmodule
