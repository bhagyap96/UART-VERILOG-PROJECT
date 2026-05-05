module uart_rx (
    input        clk,
    input        reset,
    input        rx,
    input        baud_tick,

    output reg [7:0] rx_data,
    output reg       rx_done
);

    reg [3:0] bit_cnt;
    reg [7:0] data_shift;

    typedef enum reg [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    reg [1:0] sample_count; // for mid-bit sampling

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rx_done <= 0;
            bit_cnt <= 0;
            data_shift <= 0;
            sample_count <= 0;
        end else begin
            rx_done <= 0;

            case (state)

                IDLE: begin
                    if (rx == 1'b0) begin // start bit detected
                        state <= START;
                        sample_count <= 0;
                    end
                end

                START: begin
                    if (baud_tick) begin
                        // validate start bit mid-sample
                        if (sample_count == 1) begin
                            state <= DATA;
                            bit_cnt <= 0;
                        end
                        sample_count <= sample_count + 1;
                    end
                end

                DATA: begin
                    if (baud_tick) begin
                        data_shift[bit_cnt] <= rx;
                        bit_cnt <= bit_cnt + 1;

                        if (bit_cnt == 7)
                            state <= STOP;
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        rx_data <= data_shift;
                        rx_done <= 1;
                        state <= IDLE;
                    end
                end

            endcase
        end
    end

endmodule
