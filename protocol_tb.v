`timescale 1ns/1ps

//======================================================
// CHANAKYALINK PROTOCOL  -  TESTBENCH
// Signal-level stimulus + self-checking assertions
// Tests : ACTIVATE, DEACTIVATE, STATUS_CHECK,
//         Checksum integrity, Slave isolation
//======================================================

module chanakyalink_tb;

    reg clk, rst;
    always #5 clk = ~clk;

    reg        start;
    reg  [7:0] ai_slave_id;
    reg  [7:0] ai_command;
    reg [15:0] ai_delay;

    wire [7:0]  slave_id_out;
    wire [7:0]  command_out;
    wire [15:0] delay_out;
    wire [7:0]  checksum_out;
    wire        frame_valid;
    wire        ai_select_line;
    wire [7:0]  ai_slave_select;
    wire        tx_done;
    wire [2:0]  master_state;

    wire slv1_addr_match, slv1_csum_pass, slv1_done,
         slv1_activate,   slv1_deactivate, slv1_status_check,
         slv1_output,     slv1_ack;

    wire slv2_addr_match, slv2_csum_pass, slv2_done,
         slv2_activate,   slv2_deactivate, slv2_status_check,
         slv2_output,     slv2_ack;

    wire slv3_addr_match, slv3_csum_pass, slv3_done,
         slv3_activate,   slv3_deactivate, slv3_status_check,
         slv3_output,     slv3_ack;

    wire slv4_addr_match, slv4_csum_pass, slv4_done,
         slv4_activate,   slv4_deactivate, slv4_status_check,
         slv4_output,     slv4_ack;

    wire slave_ack = slv1_ack | slv2_ack | slv3_ack | slv4_ack;

    integer pass_count;
    integer fail_count;

    //--------------------------------------------------
    // DUT : MASTER
    //--------------------------------------------------

    chanakyalink_master MASTER (
        .clk(clk), .rst(rst), .start(start),
        .ai_slave_id(ai_slave_id),
        .ai_command(ai_command),
        .ai_delay(ai_delay),
        .slave_ack(slave_ack),
        .slave_id_out(slave_id_out),
        .command_out(command_out),
        .delay_out(delay_out),
        .checksum_out(checksum_out),
        .frame_valid(frame_valid),
        .ai_select_line(ai_select_line),
        .ai_slave_select(ai_slave_select),
        .tx_done(tx_done),
        .state(master_state)
    );

    //--------------------------------------------------
    // DUT : SLAVES
    //--------------------------------------------------

    chanakyalink_slave #(.SLAVE_ID(8'd1)) SLAVE1 (
        .clk(clk), .rst(rst), .frame_valid(frame_valid),
        .slave_id_in(slave_id_out), .command_in(command_out),
        .delay_in(delay_out),       .checksum_in(checksum_out),
        .address_match(slv1_addr_match), .checksum_pass(slv1_csum_pass),
        .counter_done(slv1_done),        .activate_line(slv1_activate),
        .deactivate_line(slv1_deactivate), .status_check_line(slv1_status_check),
        .output_line(slv1_output),       .ack(slv1_ack)
    );

    chanakyalink_slave #(.SLAVE_ID(8'd2)) SLAVE2 (
        .clk(clk), .rst(rst), .frame_valid(frame_valid),
        .slave_id_in(slave_id_out), .command_in(command_out),
        .delay_in(delay_out),       .checksum_in(checksum_out),
        .address_match(slv2_addr_match), .checksum_pass(slv2_csum_pass),
        .counter_done(slv2_done),        .activate_line(slv2_activate),
        .deactivate_line(slv2_deactivate), .status_check_line(slv2_status_check),
        .output_line(slv2_output),       .ack(slv2_ack)
    );

    chanakyalink_slave #(.SLAVE_ID(8'd3)) SLAVE3 (
        .clk(clk), .rst(rst), .frame_valid(frame_valid),
        .slave_id_in(slave_id_out), .command_in(command_out),
        .delay_in(delay_out),       .checksum_in(checksum_out),
        .address_match(slv3_addr_match), .checksum_pass(slv3_csum_pass),
        .counter_done(slv3_done),        .activate_line(slv3_activate),
        .deactivate_line(slv3_deactivate), .status_check_line(slv3_status_check),
        .output_line(slv3_output),       .ack(slv3_ack)
    );

    chanakyalink_slave #(.SLAVE_ID(8'd4)) SLAVE4 (
        .clk(clk), .rst(rst), .frame_valid(frame_valid),
        .slave_id_in(slave_id_out), .command_in(command_out),
        .delay_in(delay_out),       .checksum_in(checksum_out),
        .address_match(slv4_addr_match), .checksum_pass(slv4_csum_pass),
        .counter_done(slv4_done),        .activate_line(slv4_activate),
        .deactivate_line(slv4_deactivate), .status_check_line(slv4_status_check),
        .output_line(slv4_output),       .ack(slv4_ack)
    );

    //--------------------------------------------------
    // TASK : RESET
    //--------------------------------------------------

    task do_reset;
        begin
            rst = 1; start = 0;
            @(posedge clk); @(posedge clk);
            rst = 0;
            @(posedge clk);
        end
    endtask

    //--------------------------------------------------
    // TASK : RUN TRANSACTION
    //--------------------------------------------------

    task run_transaction;
        input [7:0]  t_slave;
        input [7:0]  t_cmd;
        input [15:0] t_delay;
        begin
            ai_slave_id = t_slave;
            ai_command  = t_cmd;
            ai_delay    = t_delay;
            start = 1; @(posedge clk); #1; start = 0;
            wait(frame_valid);
            wait(slave_ack);
            wait(slv1_done | slv2_done | slv3_done | slv4_done);
            @(posedge clk); @(posedge clk);
        end
    endtask

    //--------------------------------------------------
    // TASK : ASSERT
    //--------------------------------------------------

    task assert_signal;
        input       actual;
        input       expected;
        input [8*40-1:0] label;
        begin
            if (actual === expected) begin
                pass_count = pass_count + 1;
                $display("[PASS]  %0s", label);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL]  %0s  |  expected=%b  got=%b",
                          label, expected, actual);
            end
        end
    endtask

    //--------------------------------------------------
    // TEST SEQUENCE
    //--------------------------------------------------

    initial begin

        pass_count = 0;
        fail_count = 0;
        clk        = 0;

        $display("==================================================");
        $display("       CHANAKYALINK  -  VERIFICATION REPORT");
        $display("==================================================");

        //----------------------------------------------
        // TEST 1 : SLAVE 2  |  ACTIVATE
        //----------------------------------------------

        $display("--------------------------------------------------");
        $display("  TEST 1  :  SLAVE 2  |  ACTIVATE");
        $display("--------------------------------------------------");
        do_reset;
        run_transaction(8'd2, 8'd1, 16'd5);
        assert_signal(slv2_addr_match, 1, "Slave 2  :  Address Match");
        assert_signal(slv2_csum_pass,  1, "Slave 2  :  Checksum Pass");
        assert_signal(slv2_done,       1, "Slave 2  :  Delay Done");
        assert_signal(slv2_activate,   1, "Slave 2  :  ACTIVATE Line HIGH");
        assert_signal(slv2_output,     1, "Slave 2  :  Output HIGH");
        assert_signal(slv1_addr_match, 0, "Slave 1  :  Not Selected");
        assert_signal(slv3_addr_match, 0, "Slave 3  :  Not Selected");
        assert_signal(slv4_addr_match, 0, "Slave 4  :  Not Selected");

        //----------------------------------------------
        // TEST 2 : SLAVE 4  |  DEACTIVATE
        //----------------------------------------------

        $display("--------------------------------------------------");
        $display("  TEST 2  :  SLAVE 4  |  DEACTIVATE");
        $display("--------------------------------------------------");
        do_reset;
        run_transaction(8'd4, 8'd2, 16'd5);
        assert_signal(slv4_addr_match, 1, "Slave 4  :  Address Match");
        assert_signal(slv4_csum_pass,  1, "Slave 4  :  Checksum Pass");
        assert_signal(slv4_done,       1, "Slave 4  :  Delay Done");
        assert_signal(slv4_deactivate, 1, "Slave 4  :  DEACTIVATE Line HIGH");
        assert_signal(slv4_output,     0, "Slave 4  :  Output LOW");
        assert_signal(slv1_addr_match, 0, "Slave 1  :  Not Selected");
        assert_signal(slv2_addr_match, 0, "Slave 2  :  Not Selected");
        assert_signal(slv3_addr_match, 0, "Slave 3  :  Not Selected");

        //----------------------------------------------
        // TEST 3 : SLAVE 1  |  STATUS CHECK
        //----------------------------------------------

        $display("--------------------------------------------------");
        $display("  TEST 3  :  SLAVE 1  |  STATUS CHECK");
        $display("--------------------------------------------------");
        do_reset;
        run_transaction(8'd1, 8'd3, 16'd5);
        assert_signal(slv1_addr_match,   1, "Slave 1  :  Address Match");
        assert_signal(slv1_csum_pass,    1, "Slave 1  :  Checksum Pass");
        assert_signal(slv1_done,         1, "Slave 1  :  Delay Done");
        assert_signal(slv1_status_check, 1, "Slave 1  :  STATUS CHECK Line HIGH");
        assert_signal(slv1_output,       1, "Slave 1  :  Health Status HIGH");

        //----------------------------------------------
        // TEST 4 : SLAVE 3  |  ACTIVATE
        //----------------------------------------------

        $display("--------------------------------------------------");
        $display("  TEST 4  :  SLAVE 3  |  ACTIVATE");
        $display("--------------------------------------------------");
        do_reset;
        run_transaction(8'd3, 8'd1, 16'd5);
        assert_signal(slv3_addr_match, 1, "Slave 3  :  Address Match");
        assert_signal(slv3_csum_pass,  1, "Slave 3  :  Checksum Pass");
        assert_signal(slv3_activate,   1, "Slave 3  :  ACTIVATE Line HIGH");
        assert_signal(slv3_output,     1, "Slave 3  :  Output HIGH");

        //----------------------------------------------
        // TEST 5 : CHECKSUM INTEGRITY
        //----------------------------------------------

        $display("--------------------------------------------------");
        $display("  TEST 5  :  CHECKSUM INTEGRITY");
        $display("--------------------------------------------------");
        assert_signal(
            (slave_id_out ^ command_out ^
             delay_out[15:8] ^ delay_out[7:0]) == checksum_out,
            1, "Checksum  :  Integrity Verified");

        //----------------------------------------------
        // TEST 6 : AI SELECT LINE
        // Fix : sample AFTER posedge where AI_SELECT fires
        //----------------------------------------------

        $display("--------------------------------------------------");
        $display("  TEST 6  :  AI SELECT LINE TOGGLE");
        $display("--------------------------------------------------");
        do_reset;
        ai_slave_id = 8'd2;
        ai_command  = 8'd1;
        ai_delay    = 16'd5;
        start = 1;
        @(posedge clk); #1; start = 0;
        // FSM moves to AI_SELECT on this clock — sample after next posedge
        @(posedge clk); #1;
        assert_signal(ai_select_line, 1, "AI Select  :  Line HIGH During Selection");
        wait(frame_valid == 1); #1;
        assert_signal(ai_select_line, 0, "AI Select  :  Line LOW After Handoff");

        //----------------------------------------------
        // SUMMARY
        //----------------------------------------------

        $display("==================================================");
        $display("  TOTAL PASS  :  %0d", pass_count);
        $display("  TOTAL FAIL  :  %0d", fail_count);
        if (fail_count == 0)
            $display("  RESULT      :  ALL TESTS PASSED");
        else
            $display("  RESULT      :  SOME TESTS FAILED");
        $display("==================================================");

        #50; $finish;

    end

endmodule
