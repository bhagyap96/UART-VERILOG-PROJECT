module uart_top (
    input clk,
    input reset,
    input rx,
    input tx_start,
    input [7:0] tx_data,

    output tx,
    output [7:0] rx_data,
    output tx_done,
    output rx_done
);

    wire baud_tick;

    baud_gen bg (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .baud_tick(baud_tick),
        .tx(tx),
        .tx_busy(),
        .tx_done(tx_done)
    );

    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .baud_tick(baud_tick),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule
