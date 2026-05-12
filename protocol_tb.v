`timescale 1ns/1ps

module protocol_tb;

reg clk;
reg rst;

reg start;

wire tx_line;

wire master_done;

reg [7:0] slave_id;
reg [7:0] command;
reg [15:0] delay_value;

initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial
begin

    $dumpfile("chanakyalink.vcd");
    $dumpvars(0, protocol_tb);

end

chanakyalink_master MASTER
(
    .clk(clk),
    .rst(rst),
    .start(start),
    .slave_id(slave_id),
    .command(command),
    .delay_value(delay_value),
    .tx(tx_line),
    .done(master_done)
);

wire [7:0] rx_data;
wire rx_done;

uart_rx #(87)
UART_RX
(
    .clk(clk),
    .rst(rst),
    .rx(tx_line),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

reg [7:0] frame_mem [0:4];
integer index;

always @(posedge clk)
begin

    if(rx_done)
    begin
        frame_mem[index] <= rx_data;
        index <= index + 1;
    end

end

wire exec1;
wire exec2;
wire exec3;

chanakyalink_slave #(1)
SLAVE1
(
    .clk(clk),
    .rst(rst),

    .rx_valid(index == 5),

    .slave_id(frame_mem[0]),
    .command(frame_mem[1]),
    .delay_value({frame_mem[2],frame_mem[3]}),
    .checksum(frame_mem[4]),

    .cmd_execute(exec1)
);

chanakyalink_slave #(2)
SLAVE2
(
    .clk(clk),
    .rst(rst),

    .rx_valid(index == 5),

    .slave_id(frame_mem[0]),
    .command(frame_mem[1]),
    .delay_value({frame_mem[2],frame_mem[3]}),
    .checksum(frame_mem[4]),

    .cmd_execute(exec2)
);

chanakyalink_slave #(3)
SLAVE3
(
    .clk(clk),
    .rst(rst),

    .rx_valid(index == 5),

    .slave_id(frame_mem[0]),
    .command(frame_mem[1]),
    .delay_value({frame_mem[2],frame_mem[3]}),
    .checksum(frame_mem[4]),

    .cmd_execute(exec3)
);

initial
begin

    rst = 1;
    start = 0;
    index = 0;

    #100;

    rst = 0;

    slave_id = 2;
    command = 1;
    delay_value = 20;

    #20;

    start = 1;

    #20;

    start = 0;

    #5000;

    if(exec1 == 0 &&
       exec2 == 1 &&
       exec3 == 0)
    begin
        $display("ADDRESS MATCH TEST PASSED");
    end

    else
    begin
        $display("ADDRESS MATCH TEST FAILED");
    end

    frame_mem[4] = 8'hFF;

    #2000;

    if(exec1 == 0 &&
       exec3 == 0)
    begin
        $display("CHECKSUM FAILURE TEST PASSED");
    end

    else
    begin
        $display("CHECKSUM FAILURE TEST FAILED");
    end

    $finish;

end

endmodule
