module bin_to_gray #(
    parameter data_size = 8
) (
    input wire [data_size : 0] bin,
    output wire [data_size : 0] gray
);

    assign gray = (bin >> 1) ^ bin;
    
endmodule