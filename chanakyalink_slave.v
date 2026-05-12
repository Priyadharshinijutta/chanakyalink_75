//==============================================================
// FILE : chanakyalink_slave.v
// UPDATED SLAVE MODULE
// FEATURES ADDED:
// 1. UNIQUE SLAVE ID PARAMETER
// 2. HARDWARE DELAY COUNTER
// 3. COMMAND EXECUTION OUTPUT
// 4. FIXED CHECKSUM RACE CONDITION
//==============================================================

module chanakyalink_slave
#(
    parameter MY_ID = 8'd1
)
(
    input clk,
    input rst,

    input rx,

    output reg ack,
    output reg cmd_execute
);

    //----------------------------------------------------------
    // UART RECEIVER
    //----------------------------------------------------------

    wire rx_done;
    wire [7:0] rx_data;

    uart_rx UART_RX
    (
        .clk(clk),
        .rst(rst),
        .rx_serial(rx),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

    //----------------------------------------------------------
    // INTERNAL REGISTERS
    //----------------------------------------------------------

    reg [7:0] slave_id;
    reg [7:0] command;

    reg [15:0] delay_value;

    reg [7:0] recv_checksum;
    reg [7:0] calc_checksum;

    reg [2:0] byte_count;

    reg [31:0] delay_counter;

    reg checksum_valid;

    //----------------------------------------------------------
    // FSM STATES
    //----------------------------------------------------------

    reg [2:0] state;

    localparam IDLE        = 0,
               RECEIVE     = 1,
               VERIFY      = 2,
               DELAY_WAIT  = 3,
               EXECUTE     = 4;

    //----------------------------------------------------------
    // MAIN LOGIC
    //----------------------------------------------------------

    always @(posedge clk or posedge rst)
    begin

        if(rst)
        begin

            slave_id       <= 0;
            command        <= 0;
            delay_value    <= 0;

            recv_checksum  <= 0;
            calc_checksum  <= 0;

            byte_count     <= 0;

            ack            <= 0;
            cmd_execute    <= 0;

            delay_counter  <= 0;

            checksum_valid <= 0;

            state          <= IDLE;

        end

        else
        begin

            case(state)

            //--------------------------------------------------
            // IDLE STATE
            //--------------------------------------------------

            IDLE:
            begin

                ack <= 0;
                cmd_execute <= 0;

                if(rx_done)
                begin

                    case(byte_count)

                    //------------------------------------------
                    // BYTE 0 : SLAVE ID
                    //------------------------------------------

                    0:
                    begin
                        slave_id <= rx_data;
                        byte_count <= 1;
                    end

                    //------------------------------------------
                    // BYTE 1 : COMMAND
                    //------------------------------------------

                    1:
                    begin
                        command <= rx_data;
                        byte_count <= 2;
                    end

                    //------------------------------------------
                    // BYTE 2 : DELAY MSB
                    //------------------------------------------

                    2:
                    begin
                        delay_value[15:8] <= rx_data;
                        byte_count <= 3;
                    end

                    //------------------------------------------
                    // BYTE 3 : DELAY LSB
                    //------------------------------------------

                    3:
                    begin
                        delay_value[7:0] <= rx_data;
                        byte_count <= 4;
                    end

                    //------------------------------------------
                    // BYTE 4 : CHECKSUM
                    //------------------------------------------

                    4:
                    begin

                        recv_checksum <= rx_data;

                        //--------------------------------------
                        // FIXED CHECKSUM RACE CONDITION
                        // BLOCKING ASSIGNMENT USED
                        //--------------------------------------

                        calc_checksum =
                            slave_id ^
                            command ^
                            delay_value[15:8] ^
                            delay_value[7:0];

                        byte_count <= 0;

                        state <= VERIFY;

                    end

                    endcase

                end

            end

            //--------------------------------------------------
            // VERIFY STATE
            //--------------------------------------------------

            VERIFY:
            begin

                $display("\n------------------------------------");
                $display("[SLAVE %0d] FRAME RECEIVED", MY_ID);
                $display("------------------------------------");

                $display("Received ID      : %0d", slave_id);
                $display("Command          : %0d", command);
                $display("Delay            : %0d", delay_value);

                $display("Checksum RX      : %0d",
                          recv_checksum);

                $display("Checksum CALC    : %0d",
                          calc_checksum);

                //--------------------------------------------------
                // SLAVE ID CHECK
                //--------------------------------------------------

                if(slave_id == MY_ID)
                begin

                    $display("[SLAVE %0d] ID MATCHED",
                              MY_ID);

                    //--------------------------------------------------
                    // CHECKSUM CHECK
                    //--------------------------------------------------

                    if(recv_checksum == calc_checksum)
                    begin

                        $display("[SLAVE %0d] CHECKSUM PASS",
                                  MY_ID);

                        ack <= 1;

                        checksum_valid <= 1;

                        delay_counter <= delay_value;

                        state <= DELAY_WAIT;

                    end

                    else
                    begin

                        $display("[SLAVE %0d] CHECKSUM FAIL",
                                  MY_ID);

                        checksum_valid <= 0;

                        state <= IDLE;

                    end

                end

                else
                begin

                    $display("[SLAVE %0d] FRAME NOT FOR THIS NODE",
                              MY_ID);

                    state <= IDLE;

                end

            end

            //--------------------------------------------------
            // DELAY WAIT STATE
            //--------------------------------------------------

            DELAY_WAIT:
            begin

                ack <= 0;

                if(delay_counter > 0)
                begin

                    delay_counter <= delay_counter - 1;

                    //--------------------------------------------------
                    // OPTIONAL DEBUG
                    //--------------------------------------------------

                    if(delay_counter % 1000 == 0)
                    begin
                        $display("[SLAVE %0d] DELAY COUNT = %0d",
                                  MY_ID,
                                  delay_counter);
                    end

                end

                else
                begin

                    state <= EXECUTE;

                end

            end

            //--------------------------------------------------
            // EXECUTE STATE
            //--------------------------------------------------

            EXECUTE:
            begin

                if(command == 8'd1)
                begin

                    cmd_execute <= 1'b1;

                    $display("\n[SLAVE %0d] COMMAND EXECUTED",
                              MY_ID);

                    $display("[ACTION] DEVICE ACTIVATED");

                end

                else
                begin

                    cmd_execute <= 1'b0;

                    $display("\n[SLAVE %0d] DEVICE DEACTIVATED",
                              MY_ID);

                end

                state <= IDLE;

            end

            //--------------------------------------------------
            // DEFAULT
            //--------------------------------------------------

            default:
                state <= IDLE;

            endcase

        end

    end

endmodule
