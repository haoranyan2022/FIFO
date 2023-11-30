module top_module #(
    parameter fifo_data_size = 16           ,
    parameter fifo_addr_size = 5            ,
    parameter almost_empty_full_gap = 3     
) (
    //wite signals
    input clk_w                             ,
    input rst_w                             ,
    input w_en                              ,
    output almost_full                      ,
    output full                             ,
    //read signals
    input clk_r                             ,
    input rst_r                             ,
    input r_en                              ,
    output almost_empty                     ,
    output empty                            ,
    //data in & out
    input  [fifo_data_size - 1 : 0] data_in  ,
    output [fifo_data_size - 1 : 0] data_out 
);

    //parameter reg or wire
    wire [fifo_addr_size : 0] waddr_gray_sync ;//多出一位用来判断是否回卷，输出空慢标志
    wire [fifo_addr_size : 0] raddr_gray_sync ;
    
    wire [fifo_addr_size : 0] waddr_gray      ;
    wire [fifo_addr_size : 0] raddr_gray      ;

    wire [fifo_addr_size - 1 : 0] w_addr      ;
    wire [fifo_addr_size - 1 : 0] r_addr      ;

    //inst model
    RAM #(
        .fifo_addr_size(fifo_addr_size)     ,
        .fifo_data_size(fifo_data_size)
    )   inst_RAM(
        .clk_w(clk_w)                       ,
        .rst_w(rst_w)                       ,
        .w_en(w_en)                         ,
        .almost_full(almost_full)           ,
        .w_addr(w_addr)                     ,
        .full(full)                         ,
        .clk_r(clk_r)                       ,
        .rst_r(rst_r)                       ,
        .r_en(r_en)                         ,
        .almost_empty(almost_empty)         ,
        .r_addr(r_addr)                     ,
        .empty(empty)                       ,
        .data_in(data_in)                   ,
        .data_out(data_out)                 
    );

    write_fifo #(
        .fifo_addr_size(fifo_addr_size)     ,
        .almost_empty_full_gap(almost_empty_full_gap)       
    )   inst_write(
        .clk_w(clk_w)                       ,
        .rst_w(rst_w)                       ,
        .w_en(w_en)                         ,
        .almost_full(almost_full)           ,
        .full(full)                         ,
        .raddr_gray_sync(raddr_gray_sync)   ,
        .w_addr(w_addr)                     ,
        .waddr_gray(waddr_gray)             
    ); 

    read_fifo #(
        .fifo_addr_size(fifo_addr_size)     ,
        .almost_empty_full_gap(almost_empty_full_gap)       
    )   inst_read(
        .clk_r(clk_r)                       ,
        .rst_r(rst_r)                       ,
        .r_en(r_en)                         ,
        .almost_empty(almost_empty)         ,
        .empty(empty)                       ,
        .waddr_gray_sync(waddr_gray_sync)   ,
        .r_addr(r_addr)                     ,
        .raddr_gray(raddr_gray)             
    );

    sync #(
        .fifo_addr_size(fifo_addr_size)     
    )   inst_sync_wr2rd(
        .clk(clk_w)                         ,
        .rst(rst_w)                         ,
        .addr_in(waddr_gray)                ,
        .addr_out(waddr_gray_sync)          
    );

    sync #(
        .fifo_addr_size(fifo_addr_size)     
    )   inst_sync_rd2wr(
        .clk(clk_r)                         ,
        .rst(rst_r)                         ,
        .addr_in(raddr_gray)                ,
        .addr_out(raddr_gray_sync)          
    );
endmodule