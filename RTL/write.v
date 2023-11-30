//输出将满标志
module write_fifo #(
    parameter fifo_addr_size = 5            ,
    parameter almost_empty_full_gap = 3     
) (
    //wite signals
    input clk_w                             ,
    input rst_w                             ,
    input w_en                              ,
    output reg almost_full                      ,
    output reg full                             ,
    
    input   [fifo_addr_size : 0] raddr_gray_sync                ,//同步过来的读地址，主要判断wr_gap
    output  [fifo_addr_size - 1 : 0] w_addr                     ,
    output  [fifo_addr_size : 0] waddr_gray                 
);

    reg [fifo_addr_size : 0] w_pointer_bin                  ;//比w_addr多一位
    wire flag_wr                                            ;
    reg [fifo_addr_size : 0] wr_gap                         ;
    wire [fifo_addr_size : 0] r_pointer_bin_sync                  ;

    assign flag_wr = ((w_en == 1'b1) && (almost_full == 1'b0) && (full == 1'b0))    ;//判断标志，未满且写使能的情况下，w_addr+1

    //generate wrute addr
    always @(posedge clk_w or negedge rst_w ) begin
        if (~rst_w) begin
            w_pointer_bin <= {fifo_addr_size{1'b0}}         ;
        end else if (flag_wr) begin
            w_pointer_bin <= w_pointer_bin + 1              ;
        end else begin
            w_pointer_bin <= w_pointer_bin                  ;
        end  
    end

    //bin_to_gray
    bin_to_gray #(
        .data_size(fifo_addr_size)
    ) U1_bin2gray(
        .bin(w_pointer_bin)         ,
        .gray(waddr_gray)           
    );

    //gray_to_bin  读地址为gray码，需要先转换
    gray_to_bin #(
        .data_size(fifo_addr_size)
    ) U1_gray2bin(
        .gray(raddr_gray_sync)      ,
        .bin(r_pointer_bin_sync)
    );

    //利用读指针计算间隔
    always @(*) begin
        if (r_pointer_bin_sync[fifo_addr_size] ^ w_pointer_bin[fifo_addr_size]) begin
            wr_gap = r_pointer_bin_sync[fifo_addr_size - 1] - w_pointer_bin[fifo_addr_size - 1]          ; 
        end else begin
            wr_gap = {(fifo_addr_size - 1){1'b1}} + 1'b1 + r_pointer_bin_sync - w_pointer_bin            ; 
        end
    end



    //generate almost_full   注意读指针用来判断是否将满
    always @(posedge clk_w or negedge rst_w) begin
        if (~rst_w) begin
            almost_full <= 1'b0         ;
        end else begin
            if (wr_gap < almost_empty_full_gap ) begin
                almost_full <= 1'b1     ;
            end else begin
                almost_full <= 1'b0     ;
            end
        end
    end


    //generate full
    always @(posedge clk_w or negedge rst_w) begin
        if (~rst_w) begin
            full <= 1'b0                ;
        end else begin
            if ((~(|wr_gap)) || ((wr_gap == 1) & (w_en == 1))) begin
                full <= 1'b1    ;
            end else begin
                full <= 1'b0                ;
            end
        end
    end

    //generate w_addr
    assign w_addr = w_pointer_bin[fifo_addr_size - 1 : 0]                   ;


endmodule