`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);
    logic [9:0] high_q;
    logic [9:0] low_q;
    logic [9:0] data_in;
    assign data_in = io_in[9:0];
    logic go_started;
    logic debug_error;
    logic go;
    logic finish;
    assign go = io_in[10];
    assign finish = io_in[11];

    assign io_out[9:0] = high_q - low_q;

    always_comb begin
        debug_error = 1'b0;
        if (debug_error) begin
            debug_error = (go && !finish) ? 1'b0 : 1'b1;
        end else begin
            debug_error = ((go && finish) || (finish && !go_started)) ? 1'b1 : 1'b0;
        end
    end

    // Sequential Logic
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            go_started <= 1'b0;
        end else begin
            if (!debug_error) begin
                if (go && !go_started) begin
                    go_started <= 1'b1;
                    high_q <= data_in;
                    low_q <= data_in;
                end
                if (finish) go_started <= 1'b0;
                if (data_in < low_q) low_q <= data_in;
                if (data_in > high_q) high_q <= data_in;
            end
        end
    end    

endmodule
