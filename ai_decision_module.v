//==============================================================
// FILE: ai_decision_module.v
// AI SLAVE SELECTION MODULE
//==============================================================

module ai_decision_module
(
    input [2:0] threat_level,
    input [2:0] priority,

    output reg [7:0] slave_id,
    output reg [15:0] delay_value
);

    always @(*)
    begin

        if(threat_level >= 5)
        begin
            slave_id = 8'd1;
            delay_value = 16'd2000;
        end

        else if(priority >= 3)
        begin
            slave_id = 8'd2;
            delay_value = 16'd5000;
        end

        else
        begin
            slave_id = 8'd3;
            delay_value = 16'd8000;
        end

    end

endmodule
