`timescale 		1ns/1ns
module tb_FIFO_async ();
	//============parameter	=================
	parameter 			fifo_data_size		=		16 		;
	parameter 			fifo_addr_size		=		5 		;
	parameter           almost_empty_full_gap   =   3       ;

	//	======	reg wire======================================
	reg 									clk_r 			;
	reg 									rst_r 			;
	reg        								r_en 			;
			
	reg 									clk_w 			;
	reg 									rst_w 			;
	reg        								w_en 			;

	reg   		[fifo_data_size-1:0]		data_in 		;
	wire 		[fifo_data_size-1:0]		data_out 		;

	wire 									empty 			;
	wire 									full 			;
    wire                                    almost_empty    ;
    wire                                    almost_full     ;

	integer  i  	;

	// clk_w  写模块信号
	initial 	begin
		clk_w 		=		0 						;
		rst_w 		= 		1 						;
		data_in 	=	{fifo_data_size{1'b0}}		;

	#15
		rst_w  		= 		0 				;
	#20
		rst_w 		= 		1 				;

	end

	//clk_r  读模块信号
	initial 	begin
		clk_r 		= 		0 			;
		rst_r  		= 		1 			;
		r_en  		= 		0 			;
	#25
		rst_r 		= 		0 			;
	#50
		rst_r 		= 		1 			;
	end

	//w_en 写使能
	initial 	begin
		w_en 		= 		0 			;
	#450
		w_en 		= 		1 			;
	#400
		w_en 		= 		0 			;
	#750
		w_en 		= 		1 			;
	end

	//r_en 读使能
	initial  	begin
		r_en 		= 		0 			;
	#900
		r_en 		= 		1 			;
	#400
		r_en 		= 		0 			;
	#300
	 	r_en 		= 		1 			;

	end

	initial 	begin
		for ( i = 0; i <= 20; i=i+1) begin
			/* code */
			#100
				data_in 	= 	i 		;
		end
	end

	//always block
	always #25 clk_w 	= 		~clk_w 			;

	always #50 clk_r 	=		~clk_r 			;

	top_module #(
			.fifo_data_size(fifo_data_size),
			.fifo_addr_size(fifo_addr_size),
            .almost_empty_full_gap(almost_empty_full_gap)
		) inst_FIFO_async (
			.clk_w    (clk_w 		),
			.rst_w    (rst_w 		),
			.w_en     (w_en 		),
			.clk_r    (clk_r 		),
			.rst_r    (rst_r 		),
			.r_en     (r_en 		),
			.data_in  (data_in 		),
			.data_out (data_out 	),
            .almost_empty(almost_empty),
            .almost_full(almost_full),
			.empty    (empty 		),
			.full     (full 		)
		);

endmodule 
