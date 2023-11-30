module gray_to_bin #(
    parameter data_size = 8
) (
    input reg [data_size : 0] gray,
    output reg [data_size : 0] bin
);

    integer  i;
    always @(*) begin
        bin[data_size] = gray[data_size];
        for (i = data_size - 1; i >= 0; i = i - 1 ) begin
            bin[i] = bin[i + 1] ^ gray[i];
        end
    end
    
endmodule