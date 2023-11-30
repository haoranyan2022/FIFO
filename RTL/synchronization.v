//将写指针传到read模块，读指针传到write模块
//采用单bit同步
module sync #(
    parameter   fifo_addr_size = 5          
) (
    input clk                               ,
    input rst                               ,
    input reg [fifo_addr_size : 0] addr_in      ,
    output reg [fifo_addr_size : 0] addr_out    
);
    //慢一拍
    reg [fifo_addr_size : 0]    addr_temp   ;
    //同步
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            addr_temp <= {fifo_addr_size{1'b0}}         ;
            addr_out  <= {fifo_addr_size{1'b0}}         ;
        end else begin
            addr_temp <= addr_in                        ;
            addr_out  <= addr_temp                      ;
        end
    end

endmodule