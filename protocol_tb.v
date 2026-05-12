`timescale 1ns/1ps

module protocol_tb;

reg clk;
reg rst;

reg start;

wire tx;

wire ack1;
wire nack1;

wire ack2;
wire nack2;

wire ack3;
wire nack3;

wire done;
wire error;

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

    .ack(ack1 | ack2 | ack3),
    .nack(nack1 | nack2 | nack3),

    .slave_id(slave_id),
    .command(command),
    .delay_value(delay_value),

    .tx(tx),

    .done(done),
    .error(error)
);

wire [7:0] rx_data;
wire rx_done;

uart_rx #(87)
UART_RX
(
    .clk(clk),
    .rst(rst),
    .rx(tx),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

reg [7:0] frame [0:6];

integer index;

always @(posedge clk)
begin

    if(rx_done)
    begin
        frame[index] <= rx_data;
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

    .rx_valid(index == 7),

    .start_byte(frame[0]),
    .slave_id(frame[1]),
    .command(frame[2]),
    .delay_value({frame[3],frame[4]}),
    .checksum(frame[5]),
    .stop_byte(frame[6]),

    .ack(ack1),
    .nack(nack1),

    .cmd_execute(exec1)
);

chanakyalink_slave #(2)
SLAVE2
(
    .clk(clk),
    .rst(rst),

    .rx_valid(index == 7),

    .start_byte(frame[0]),
    .slave_id(frame[1]),
    .command(frame[2]),
    .delay_value({frame[3],frame[4]}),
    .checksum(frame[5]),
    .stop_byte(frame[6]),

    .ack(ack2),
    .nack(nack2),

    .cmd_execute(exec2)
);

chanakyalink_slave #(3)
SLAVE3
(
    .clk(clk),
    .rst(rst),

    .rx_valid(index == 7),

    .start_byte(frame[0]),
    .slave_id(frame[1]),
    .command(frame[2]),
    .delay_value({frame[3],frame[4]}),
    .checksum(frame[5]),
    .stop_byte(frame[6]),

    .ack(ack3),
    .nack(nack3),

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

    #10000;

    if(exec1 == 0 &&
       exec2 == 1 &&
       exec3 == 0)
    begin
        $display("MULTI SLAVE TEST PASSED");
    end

    else
    begin
        $display("MULTI SLAVE TEST FAILED");
    end

    frame[5] = 8'hFF;

    #2000;

    if(error)
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
