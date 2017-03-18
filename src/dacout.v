/////////////////////////// INCLUDE /////////////////////////////
`include "../src/globals.v"

////////////////////////////////////////////////////////////////
//
//  Module  : dacout.v
//  Designer: Hoki
//  Company : HWorks
//  Date    : 2017/3/17 9:47:45
//
////////////////////////////////////////////////////////////////
// 
//  Description: AD5791 Controller
//
////////////////////////////////////////////////////////////////
// 
//  Revision: 1.0

/////////////////////////// DEFINE /////////////////////////////

`define  ST_IDLE     2'b00
`define  ST_RW       2'b01
`define  ST_CMD      2'b11
`define  ST_DATA     2'b10

`define  DAC_CMD_NBIT   3

`define  DAC_RW_WRITE   1'b0
`define  DAC_RW_READ    1'b1

`define  DAC_CMD_NOP    `DAC_CMD_NBIT'b000
`define  DAC_CMD_RG     `DAC_CMD_NBIT'b001
`define  DAC_CMD_CTRL   `DAC_CMD_NBIT'b010
`define  DAC_CMD_CLR    `DAC_CMD_NBIT'b011

/////////////////////////// MODULE //////////////////////////////

module dacout
(
   tx_clk,
   tx_dv,
   tx_data,
   tx_waitrequest,
   mclk,
   start,
   sclk,
   sdin,
   sdo,
   sync,
   ldac,
   reset,
   clr
);

   ///////////////// PARAMETER ////////////////

   ////////////////// PORT ////////////////////
   
   input                       tx_clk;         // tx clock
   input                       tx_dv;          // tx data valid
   input  [`DAC_DATA_NBIT-1:0] tx_data;        // tx data
   output                      tx_waitrequest; // tx wait request
   
   input                       mclk;           // main clock
   input                       start;          // start input
   output                      sclk;           // AD5791 serial clock output
   input                       sdin;           // AD5791 serial data input
   output                      sdo;            // AD5791 serial data output
   output                      sync;           // AD5791 sync output
   output                      ldac;           // AD5791 load output
   output                      reset;          // AD5791 reset output
   output                      clr;            // AD5791 clear

   ////////////////// ARCH ////////////////////

   ////////////////// Cache TX Data
   
   wire                      txbuf_empty;
   wire [`DAC_DATA_NBIT-1:0] txbuf_data;
   reg                       txbuf_rd;
   
   asyn_fifo #(`DAC_DATA_NBIT,9,1,0)
   txbuf(
     .wclk  (tx_clk        ),
     .wrst_n(`HIGH         ),
     .wr    (tx_dv         ),
     .wdata (tx_data       ),
     .wfull (tx_waitrequest),
     .rclk  (mclk          ),
     .rrst_n(`HIGH         ),
     .rd    (txbuf_rd      ),
     .rdata (txbuf_data    ),
     .rempty(txbuf_empty   )
   );
   
   ////////////////// Serial Clock Generate
   
   reg  [`DAC_SCLK_DIV_NBIT-1:0] sclk_div_cnt;
   
   always@(posedge mclk) begin   
      sclk_div_cnt <= sclk_div_cnt + 1'b1;
      if(sclk_div_cnt==`DAC_SCLK_DIV-1)
         sclk_div_cnt <= 0;
   end
   
   assign sclk = sync ? (sclk_div_cnt>=0 && sclk_div_cnt<`DAC_SCLK_DIV/2) : `HIGH;
   
   ////////////////// Serial Output
   
   reg  [1:0]                fsm_st;
   reg                       fsm_start;
   reg  [4:0]                fsm_cnt;
   reg  [`DAC_DATA_NBIT-1:0] fsm_sf_data;
   wire fsm_en = (sclk_div_cnt==`DAC_SCLK_DIV-1);
   
   always@(posedge mclk) begin
      fsm_start = ~txbuf_empty&start ? `HIGH : (fsm_st!=`ST_IDLE ? `LOW : fsm_start);
      txbuf_rd <= `LOW;
      if(fsm_en) begin
         case(fsm_st)
            `ST_IDLE: begin // IDLE state, wait for start
               fsm_cnt <= 0;
               fsm_sf_data <= 0;
               if(fsm_start) begin
                  txbuf_rd    <= `HIGH;
                  fsm_st      <= `ST_RW;
               end
            end
            `ST_RW: begin  // RW, 1 bit: HIGH - read; LOW - write
               fsm_cnt <= fsm_cnt - 1'b1;
               if(fsm_cnt==0) begin
                  fsm_cnt     <= 5'd`DAC_CMD_NBIT-1'b1;   
                  fsm_sf_data <= {`DAC_CMD_RG,{`DAC_DATA_NBIT-`DAC_CMD_NBIT{1'b0}}};
                  fsm_st      <= `ST_CMD;
               end
            end
            `ST_CMD: begin // RW  CMD(3 bits) : 
                           //  -  000           - no operation
                           //  0  001           - write to the DAC register
                           //  0  010           - write to the control register
                           //  0  011           - write to the clearcode register
                           //  0  100           - write to the software control register
                           //  1  001           - read from the DAC register
                           //  1  010           - read from the control register
                           //  1  011           - read from the clearcode register            
               fsm_cnt <= fsm_cnt - 1'b1;
               fsm_sf_data <= fsm_sf_data<<1;
               if(fsm_cnt==0) begin
                  fsm_cnt     <= 5'd`DAC_DATA_NBIT+1'b1;
                  fsm_sf_data <= txbuf_data;
                  fsm_st      <= `ST_DATA;
               end
            end
            `ST_DATA: begin // Data, 20 bits
               fsm_cnt     <= fsm_cnt - 1'b1;
               fsm_sf_data <= fsm_sf_data<<1;
               if(fsm_cnt==0) begin
                  fsm_st  <= `ST_IDLE;
               end
            end
            default: 
               fsm_st <= `ST_IDLE;
         endcase               
      end
   end
   
   reg  sync;
   reg  sdo ;
   reg  ldac;
   
   assign reset = `LOW;
   assign clr   = `LOW;
   
   always@* begin
      case(fsm_st)
         `ST_IDLE: begin
            sync <= `LOW;
            sdo  <= `LOW;
            ldac <= `LOW;
         end
         `ST_RW: begin
            sync <= `HIGH;
            sdo  <= `DAC_RW_WRITE;
            ldac <= `LOW;
         end
         `ST_CMD: begin            
            sync <= `HIGH;
            sdo  <= fsm_sf_data[`DAC_DATA_NBIT-1];
            ldac <= `LOW;
         end
         `ST_DATA: begin
            sync <= (fsm_cnt>1);
            sdo  <= fsm_sf_data[`DAC_DATA_NBIT-1];
            ldac <= (fsm_cnt==0);
         end
         default: begin
            sync <= `LOW;
            sdo  <= `LOW;
            ldac <= `LOW;
         end
      endcase
   end           

endmodule