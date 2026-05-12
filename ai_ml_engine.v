//============================================================
// FILE : ai_ml_engine.v
//============================================================

module ai_ml_engine(
    input  [1:0] threat,
    input  [1:0] distance,
    input  [1:0] priority,

    output reg [7:0] slave_id,
    output reg [15:0] delay_value
);

always @(*)
begin

    case({threat,distance,priority})

        // HIGH RISK
        6'b111111:
        begin
            slave_id   = 8'd1;
            delay_value = 16'd1000;
        end

        // MEDIUM RISK
        6'b101110:
        begin
            slave_id   = 8'd2;
            delay_value = 16'd3000;
        end

        // LOW RISK
        6'b011001:
        begin
            slave_id   = 8'd3;
            delay_value = 16'd5000;
        end

        // DEFAULT
        default:
        begin
            slave_id   = 8'd4;
            delay_value = 16'd8000;
        end

    endcase

end

endmodule
