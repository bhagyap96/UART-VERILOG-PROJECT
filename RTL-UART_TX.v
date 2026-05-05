module uart_tx (
    input        clk,
    input        reset,
    input        tx_start,
    input  [7:0] tx_data,
    input        baud_tick,

    output reg   tx,
    output reg   tx_busy,
    output reg   tx_done
);

    reg [3:0] bit_cnt;
    reg [9:0] shift_reg; // start + 8 data + stop

    typedef enum reg [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state    <= IDLE;
            tx       <= 1'b1; // idle line is high
            tx_busy  <= 1'b0;
            tx_done  <= 1'b0;
            bit_cnt  <= 0;
            shift_reg<= 0;
        end else begin
            tx_done <= 1'b0;

            case (state)

                IDLE: begin
                    tx <= 1'b1;
                    tx_busy <= 1'b0;

                    if (tx_start) begin
                        shift_reg <= {1'b1, tx_data, 1'b0}; // stop + data + start
                        state <= START;
                        tx_busy <= 1'b1;
                        bit_cnt <= 0;
                    end
                end

                START: begin
                    if (baud_tick) begin
                        tx <= shift_reg[0];
                        shift_reg <= shift_reg >> 1;
                        state <= DATA;
                    end
                end

                DATA: begin
                    if (baud_tick) begin
                        tx <= shift_reg[0];
                        shift_reg <= shift_reg >> 1;
                        bit_cnt <= bit_cnt + 1;

                        if (bit_cnt == 7)
                            state <= STOP;
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        tx <= 1'b1;
                        state <= IDLE;
                        tx_done <= 1'b1;
                    end
                end

            endcase
        end
    end

endmodule
