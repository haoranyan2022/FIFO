//输出almost_empty,empty标志
module read_fifo #(
    parameter fifo_addr_size = 5            ,
    parameter almost_empty_full_gap = 3     
) (
    //wite signals
    input clk_r                             ,
    input rst_r                             ,
    input r_en                              ,
    output reg almost_empty                     ,
    output reg empty                            ,
    
    input   [fifo_addr_size : 0] waddr_gray_sync               ,
    output  [fifo_addr_size - 1 : 0] r_addr                    ,
    output  [fifo_addr_size : 0] raddr_gray                      
);


    reg [fifo_addr_size : 0] r_pointer_bin                  ;
    wire flag_rd                                            ;
    reg [fifo_addr_size : 0] rd_gap                         ;
    wire [fifo_addr_size : 0] w_pointer_bin_sync             ;

    assign flag_rd = ((r_en == 1'b1) && (almost_empty == 1'b0) && (empty == 1'b0))   ;

    //产生读地址(多一位)
    always @(posedge clk_r or negedge rst_r) begin
        if (~rst_r) begin
            r_pointer_bin <= {fifo_addr_size{1'b0}}                                  ;
        end else if (flag_rd) begin
            r_pointer_bin <= r_pointer_bin + 1'b1           ;
        end else begin
            r_pointer_bin <= r_pointer_bin                  ;
        end
    end

    //同步信号需要同步多一位的读地址，用来判断wr——gap
    //bin_to_gray
    bin_to_gray #(
        .data_size(fifo_addr_size)
    ) U2_bin2gray(
        .bin(r_pointer_bin)         ,
        .gray(raddr_gray)           
    );

    //gray_to_bin  读地址为gray码，需要先转换
    gray_to_bin #(
        .data_size(fifo_addr_size)
    ) U2_gray2bin(
        .gray(waddr_gray_sync)      ,
        .bin(w_pointer_bin_sync)
    );

    //利用写指针计算间隔(读到写，直接用写指针-读)
    always @(*) begin
        rd_gap = w_pointer_bin_sync - r_pointer_bin             ;
    end

    //generate almost_empty          注意读指针用来判断是否将满
    always @(posedge clk_r or negedge rst_r) begin
        if (~rst_r) begin
            almost_empty <= 1'b0         ;
        end else begin
            if (rd_gap < almost_empty_full_gap) begin
                almost_empty <= 1'b1        ;
            end else begin
                almost_empty <= 1'b0        ;
            end
        end
    end


    //generate empty
    always @(posedge clk_r or negedge rst_r) begin
        if (~rst_r) begin
            empty <= 1'b0                ;
        end else begin
            if ((~(|rd_gap)) || ((rd_gap == 1) & (r_en == 1))) begin
                empty <= 1'b1   ;
            end else begin
                empty <= 1'b0   ;
            end
        end
    end

    //generate w_addr
    assign r_addr = r_pointer_bin[fifo_addr_size - 1 : 0]                       ;

endmodule