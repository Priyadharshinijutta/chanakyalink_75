`timescale 1ns/1ps

//======================================================
// CHANAKYALINK PROTOCOL  -  FULL RTL DESIGN
// Master FSM + Slave Node + Checksum Unit
//======================================================


//------------------------------------------------------
// MODULE 1 : CHECKSUM UNIT
// XOR reduction of all frame fields
//------------------------------------------------------

module chanakyalink_checksum (
    input  [7:0]  slave_id,
    input  [7:0]  command,
    input  [15:0] delay_time,
    output [7:0]  checksum
);
    assign checksum = slave_id         ^
                      command          ^
                      delay_time[15:8] ^
                      delay_time[7:0];
endmodule


//------------------------------------------------------
// MODULE 2 : SLAVE NODE
// Parameterized SLAVE_ID
// Clocked RTL : address comparator, checksum verifier,
//               delay counter, command output register
//------------------------------------------------------

module chanakyalink_slave #(
    parameter [7:0] SLAVE_ID = 8'd1
)(
    input         clk,
    input         rst,
    input         frame_valid,
    input  [7:0]  slave_id_in,
    input  [7:0]  command_in,
    input  [15:0] delay_in,
    input  [7:0]  checksum_in,

    output reg    address_match,
    output reg    checksum_pass,
    output reg    counter_done,
    output reg    activate_line,
    output reg    deactivate_line,
    output reg    status_check_line,
    output reg    output_line,
    output reg    ack
);

    // FSM states
    localparam S_IDLE     = 3'd0;
    localparam S_ADDR     = 3'd1;
    localparam S_CSUM     = 3'd2;
    localparam S_DELAY    = 3'd3;
    localparam S_EXECUTE  = 3'd4;
    localparam S_DONE     = 3'd5;

    reg [2:0]  state;
    reg [15:0] delay_counter;
    reg [7:0]  calc_checksum;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state             <= S_IDLE;
            address_match     <= 1'b0;
            checksum_pass     <= 1'b0;
            counter_done      <= 1'b0;
            activate_line     <= 1'b0;
            deactivate_line   <= 1'b0;
            status_check_line <= 1'b0;
            output_line       <= 1'b0;
            ack               <= 1'b0;
            delay_counter     <= 16'd0;
            calc_checksum     <= 8'd0;
        end
        else begin
            case (state)

                S_IDLE : begin
                    counter_done  <= 1'b0;
                    delay_counter <= 16'd0;
                    if (frame_valid)
                        state <= S_ADDR;
                end

                S_ADDR : begin
                    if (slave_id_in == SLAVE_ID) begin
                        address_match <= 1'b1;
                        ack           <= 1'b1;
                        state         <= S_CSUM;
                    end else begin
                        address_match <= 1'b0;
                        ack           <= 1'b0;
                        state         <= S_IDLE;
                    end
                end

                S_CSUM : begin
                    calc_checksum = slave_id_in  ^
                                    command_in   ^
                                    delay_in[15:8] ^
                                    delay_in[7:0];
                    if (calc_checksum == checksum_in) begin
                        checksum_pass <= 1'b1;
                        state         <= S_DELAY;
                    end else begin
                        checksum_pass <= 1'b0;
                        state         <= S_IDLE;
                    end
                end

                S_DELAY : begin
                    if (delay_counter < delay_in) begin
                        delay_counter <= delay_counter + 1'b1;
                    end else begin
                        counter_done  <= 1'b1;
                        delay_counter <= 16'd0;
                        state         <= S_EXECUTE;
                    end
                end

                S_EXECUTE : begin
                    activate_line     <= (command_in == 8'd1);
                    deactivate_line   <= (command_in == 8'd2);
                    status_check_line <= (command_in == 8'd3);
                    output_line       <= (command_in == 8'd1) ? 1'b1 :
                                        (command_in == 8'd2) ? 1'b0 : 1'b1;
                    state             <= S_DONE;
                end

                S_DONE : begin
                    state <= S_IDLE;
                end

            endcase
        end
    end

endmodule


//------------------------------------------------------
// MODULE 3 : MASTER CONTROLLER FSM
// States : IDLE -> AI_SELECT -> FRAME_BUILD ->
//          TRANSMIT -> WAIT_ACK -> DONE
// Generates and serializes ChanakyaLink frame
//------------------------------------------------------

module chanakyalink_master (
    input         clk,
    input         rst,
    input         start,
    input  [7:0]  ai_slave_id,
    input  [7:0]  ai_command,
    input  [15:0] ai_delay,
    input         slave_ack,

    output reg [7:0]  slave_id_out,
    output reg [7:0]  command_out,
    output reg [15:0] delay_out,
    output reg [7:0]  checksum_out,
    output reg        frame_valid,
    output reg        ai_select_line,
    output reg [7:0]  ai_slave_select,
    output reg        tx_done,
    output reg [2:0]  state
);

    localparam IDLE        = 3'd0;
    localparam AI_SELECT   = 3'd1;
    localparam FRAME_BUILD = 3'd2;
    localparam TRANSMIT    = 3'd3;
    localparam WAIT_ACK    = 3'd4;
    localparam DONE        = 3'd5;

    wire [7:0] csum_wire;

    chanakyalink_checksum CSUM_UNIT (
        .slave_id  (slave_id_out),
        .command   (command_out),
        .delay_time(delay_out),
        .checksum  (csum_wire)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state           <= IDLE;
            frame_valid     <= 1'b0;
            ai_select_line  <= 1'b0;
            ai_slave_select <= 8'd0;
            tx_done         <= 1'b0;
            slave_id_out    <= 8'd0;
            command_out     <= 8'd0;
            delay_out       <= 16'd0;
            checksum_out    <= 8'd0;
        end
        else begin
            case (state)

                IDLE : begin
                    frame_valid    <= 1'b0;
                    tx_done        <= 1'b0;
                    ai_select_line <= 1'b0;
                    if (start)
                        state <= AI_SELECT;
                end

                AI_SELECT : begin
                    ai_select_line  <= 1'b1;
                    ai_slave_select <= ai_slave_id;
                    slave_id_out    <= ai_slave_id;
                    command_out     <= ai_command;
                    delay_out       <= ai_delay;
                    state           <= FRAME_BUILD;
                end

                FRAME_BUILD : begin
                    ai_select_line <= 1'b0;
                    checksum_out   <= csum_wire;
                    state          <= TRANSMIT;
                end

                TRANSMIT : begin
                    frame_valid <= 1'b1;
                    state       <= WAIT_ACK;
                end

                WAIT_ACK : begin
                    if (slave_ack) begin
                        frame_valid <= 1'b0;
                        state       <= DONE;
                    end
                end

                DONE : begin
                    tx_done <= 1'b1;
                    state   <= IDLE;
                end

            endcase
        end
    end

endmodule
