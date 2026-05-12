//============================================================
// FILE : protocol_tb.v
//============================================================

`timescale 1ns/1ps

module protocol_tb;

reg clk;
reg rst;

wire [7:0] ai_slave;
wire [15:0] ai_delay;

wire [7:0] tx_slave_id;
wire [7:0] tx_command;
wire [15:0] tx_delay;
wire [7:0] tx_checksum;

wire frame_valid;

wire exec1;
wire exec2;
wire exec3;
wire exec4;

integer logfile;

//============================================================
// CLOCK
//============================================================

always #5 clk = ~clk;

//============================================================
// LOG FILE
//============================================================

initial
begin
    logfile = $fopen("simulation_log.txt","w");
end

//============================================================
// AI ENGINE
//============================================================

ai_ml_engine AI(
    .threat(2'b11),
    .distance(2'b11),
    .priority(2'b11),

    .slave_id(ai_slave),
    .delay_value(ai_delay)
);

//============================================================
// MASTER
//============================================================

chanakyalink_master MASTER(

    .clk(clk),
    .rst(rst),

    .slave_id(ai_slave),
    .delay_value(ai_delay),

    .tx_slave_id(tx_slave_id),
    .tx_command(tx_command),
    .tx_delay(tx_delay),
    .tx_checksum(tx_checksum),

    .frame_valid(frame_valid)
);

//============================================================
// SLAVES
//============================================================

chanakyalink_slave #(.MY_ID(1)) S1(
    .clk(clk),
    .rst(rst),

    .slave_id(tx_slave_id),
    .command(tx_command),
    .delay_value(tx_delay),
    .checksum(tx_checksum),

    .frame_valid(frame_valid),

    .cmd_execute(exec1)
);

chanakyalink_slave #(.MY_ID(2)) S2(
    .clk(clk),
    .rst(rst),

    .slave_id(tx_slave_id),
    .command(tx_command),
    .delay_value(tx_delay),
    .checksum(tx_checksum),

    .frame_valid(frame_valid),

    .cmd_execute(exec2)
);

chanakyalink_slave #(.MY_ID(3)) S3(
    .clk(clk),
    .rst(rst),

    .slave_id(tx_slave_id),
    .command(tx_command),
    .delay_value(tx_delay),
    .checksum(tx_checksum),

    .frame_valid(frame_valid),

    .cmd_execute(exec3)
);

chanakyalink_slave #(.MY_ID(4)) S4(
    .clk(clk),
    .rst(rst),

    .slave_id(tx_slave_id),
    .command(tx_command),
    .delay_value(tx_delay),
    .checksum(tx_checksum),

    .frame_valid(frame_valid),

    .cmd_execute(exec4)
);

//============================================================
// TEST
//============================================================

initial
begin

    clk = 0;
    rst = 1;

    #20;

    rst = 0;

    $display("====================================");
    $display("CHANAKYALINK PROTOCOL SIMULATION");
    $display("====================================");

    $fwrite(logfile,
    "[MASTER] SYSTEM INITIALIZED\n");

    #5000;

    $display("====================================");
    $display("SIMULATION COMPLETE");
    $display("====================================");

    $finish;

end

endmodule
