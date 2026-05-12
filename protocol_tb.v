//==============================================================
// FILE: tb_chanakyalink.v
// TESTBENCH
//==============================================================

`timescale 1ns/1ps

module tb_chanakyalink;

    reg clk;
    reg rst;

    reg [2:0] threat_level;
    reg [2:0] priority;

    wire tx;
    wire ack;

    chanakyalink_master MASTER
    (
        .clk(clk),
        .rst(rst),
        .threat_level(threat_level),
        .priority(priority),
        .ack(ack),
        .tx(tx)
    );

    chanakyalink_slave SLAVE
    (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .ack(ack)
    );

    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial
    begin

        rst = 1;
        threat_level = 0;
        priority = 0;

        #100;
        rst = 0;

        //-----------------------------------------
        // CASE 1
        //-----------------------------------------

        threat_level = 6;
        priority = 2;

        #500000;

        //-----------------------------------------
        // CASE 2
        //-----------------------------------------

        threat_level = 2;
        priority = 5;

        #500000;

        //-----------------------------------------
        // CASE 3
        //-----------------------------------------

        threat_level = 1;
        priority = 1;

        #500000;

        $finish;

    end

endmodule
