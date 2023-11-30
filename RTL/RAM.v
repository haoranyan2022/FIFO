module RAM #(
    parameter fifo_addr_size = 5            ,
    parameter fifo_data_size = 16           
) (
    //wite signals
    input clk_w                             ,
    input rst_w                             ,
    input w_en                              ,
    input almost_full                       ,
    input [fifo_addr_size - 1 : 0] w_addr                            ,
    input full                              ,
    //read signals
    input clk_r                             ,
    input rst_r                             ,
    input r_en                              ,
    input almost_empty                      ,
    input [fifo_addr_size - 1 : 0] r_addr                            ,
    input empty                             ,
    //data in & out
    input  [fifo_data_size - 1 : 0] data_in  ,
    output reg [fifo_data_size - 1 : 0] data_out 
);
    //creat register
    reg [fifo_data_size - 1 : 0] register [{ fifo_addr_size {1'b1} } : 0]   ;//初始化寄存器数组
    integer i                                                               ;

    //write
    always @(posedge clk_w or negedge rst_w) begin
        if (~rst_w) begin
            for (i = 0; i <= fifo_data_size ; i = i + 1) begin
                register [i] <= { fifo_data_size {1'b0} }                   ;
            end
        end else if ((w_en == 1'b1) && (almost_full == 1'b0) && (full == 1'b0)) begin
                register[w_addr] <= data_in                                 ;//写入寄存器( ),满足写使能，未满
        end else begin
            register[w_addr] <= {fifo_data_size {1'b0}}                     ;
        end
    end

    //read
    always @(posedge clk_r or negedge rst_r) begin
        if (~rst_r) begin
            data_out <= {fifo_data_size{1'b0}}                              ;
        end else if ((r_en == 1'b1) && (almost_empty == 1'b0) && (empty == 1'b0)) begin
            data_out <= register[r_addr]                                    ;//读取寄存器中的值(地址为r_addr)，满足读使能，未空
        end else begin
            data_out <= {fifo_data_size{1'b0}}                              ;
        end
    end

endmodule