// sdram.v

// Generated using ACDS version 15.1 185

`timescale 1 ps / 1 ps
module sdram (
		input  wire [23:0] avalon_mms_address,       // avalon_mms.address
		input  wire [3:0]  avalon_mms_byteenable_n,  //           .byteenable_n
		input  wire        avalon_mms_chipselect,    //           .chipselect
		input  wire [31:0] avalon_mms_writedata,     //           .writedata
		input  wire        avalon_mms_read_n,        //           .read_n
		input  wire        avalon_mms_write_n,       //           .write_n
		output wire [31:0] avalon_mms_readdata,      //           .readdata
		output wire        avalon_mms_readdatavalid, //           .readdatavalid
		output wire        avalon_mms_waitrequest,   //           .waitrequest
		input  wire        in_clk_clk,               //     in_clk.clk
		input  wire        in_rst_reset_n,           //     in_rst.reset_n
		output wire [12:0] port_addr,                //       port.addr
		output wire [1:0]  port_ba,                  //           .ba
		output wire        port_cas_n,               //           .cas_n
		output wire        port_cke,                 //           .cke
		output wire        port_cs_n,                //           .cs_n
		inout  wire [31:0] port_dq,                  //           .dq
		output wire [3:0]  port_dqm,                 //           .dqm
		output wire        port_ras_n,               //           .ras_n
		output wire        port_we_n                 //           .we_n
	);

	wire    rst_controller_reset_out_reset; // rst_controller:reset_out -> sdram_controller:reset_n

	sdram_sdram_controller sdram_controller (
		.clk            (in_clk_clk),                      //   clk.clk
		.reset_n        (~rst_controller_reset_out_reset), // reset.reset_n
		.az_addr        (avalon_mms_address),              //    s1.address
		.az_be_n        (avalon_mms_byteenable_n),         //      .byteenable_n
		.az_cs          (avalon_mms_chipselect),           //      .chipselect
		.az_data        (avalon_mms_writedata),            //      .writedata
		.az_rd_n        (avalon_mms_read_n),               //      .read_n
		.az_wr_n        (avalon_mms_write_n),              //      .write_n
		.za_data        (avalon_mms_readdata),             //      .readdata
		.za_valid       (avalon_mms_readdatavalid),        //      .readdatavalid
		.za_waitrequest (avalon_mms_waitrequest),          //      .waitrequest
		.zs_addr        (port_addr),                       //  wire.export
		.zs_ba          (port_ba),                         //      .export
		.zs_cas_n       (port_cas_n),                      //      .export
		.zs_cke         (port_cke),                        //      .export
		.zs_cs_n        (port_cs_n),                       //      .export
		.zs_dq          (port_dq),                         //      .export
		.zs_dqm         (port_dqm),                        //      .export
		.zs_ras_n       (port_ras_n),                      //      .export
		.zs_we_n        (port_we_n)                        //      .export
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (1),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (~in_rst_reset_n),                // reset_in0.reset
		.clk            (in_clk_clk),                     //       clk.clk
		.reset_out      (rst_controller_reset_out_reset), // reset_out.reset
		.reset_req      (),                               // (terminated)
		.reset_req_in0  (1'b0),                           // (terminated)
		.reset_in1      (1'b0),                           // (terminated)
		.reset_req_in1  (1'b0),                           // (terminated)
		.reset_in2      (1'b0),                           // (terminated)
		.reset_req_in2  (1'b0),                           // (terminated)
		.reset_in3      (1'b0),                           // (terminated)
		.reset_req_in3  (1'b0),                           // (terminated)
		.reset_in4      (1'b0),                           // (terminated)
		.reset_req_in4  (1'b0),                           // (terminated)
		.reset_in5      (1'b0),                           // (terminated)
		.reset_req_in5  (1'b0),                           // (terminated)
		.reset_in6      (1'b0),                           // (terminated)
		.reset_req_in6  (1'b0),                           // (terminated)
		.reset_in7      (1'b0),                           // (terminated)
		.reset_req_in7  (1'b0),                           // (terminated)
		.reset_in8      (1'b0),                           // (terminated)
		.reset_req_in8  (1'b0),                           // (terminated)
		.reset_in9      (1'b0),                           // (terminated)
		.reset_req_in9  (1'b0),                           // (terminated)
		.reset_in10     (1'b0),                           // (terminated)
		.reset_req_in10 (1'b0),                           // (terminated)
		.reset_in11     (1'b0),                           // (terminated)
		.reset_req_in11 (1'b0),                           // (terminated)
		.reset_in12     (1'b0),                           // (terminated)
		.reset_req_in12 (1'b0),                           // (terminated)
		.reset_in13     (1'b0),                           // (terminated)
		.reset_req_in13 (1'b0),                           // (terminated)
		.reset_in14     (1'b0),                           // (terminated)
		.reset_req_in14 (1'b0),                           // (terminated)
		.reset_in15     (1'b0),                           // (terminated)
		.reset_req_in15 (1'b0)                            // (terminated)
	);

endmodule
