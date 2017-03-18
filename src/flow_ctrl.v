/////////////////////////// INCLUDE /////////////////////////////
`include "../src/globals.v"

////////////////////////////////////////////////////////////////
//
//  Module  : flow_ctrl
//  Designer: Hoki
//  Company : HWorks
//  Date    : 2017/3/17 13:10:40
//
////////////////////////////////////////////////////////////////
// 
//  Description: Control all the data flow
//
////////////////////////////////////////////////////////////////
// 
//  Revision: 1.0

/////////////////////////// DEFINE /////////////////////////////

/////////////////////////// MODULE //////////////////////////////

module flow_ctrl
(
   mclk           ,
   sdram_wren     ,
   sdram_waddr    ,
   sdram_wdata    ,
   sdram_wstatus  ,
   sdram_rd       ,
   sdram_raddr    ,
   sdram_rdata    ,
   sdram_rdv      ,
   sdram_rstatus  ,
   dac_start      ,
   dac_dv         ,
   dac_data       ,
   dac_waitrequest
);


   ///////////////// PARAMETER ////////////////

   ////////////////// PORT ////////////////////
   
   input                          mclk;             // main clock
   
   // Flash Interface
   
   // SDRAM Interface
   output                         sdram_wren;       // sdram write enable
   output [`SDRAM_ADDR_NBIT-1:0]  sdram_waddr;      // sdram write address
   output [`SDRAM_DATA_NBIT-1:0]  sdram_wdata;      // sdram write data
   input                          sdram_wstatus;    // sdram write buffer status: HIGH - empty, LOW - full
   output                         sdram_rd;         // sdram read
   output [`SDRAM_ADDR_NBIT-1:0]  sdram_raddr;      // sdram read address
   input  [`SDRAM_DATA_NBIT-1:0]  sdram_rdata;      // sdram read data
   input                          sdram_rdv;        // sdram read data valid
   input                          sdram_rstatus;    // sdram read buffer status: HIGH - empty, LOW - full
   
   // AD5791 Interface
   output                         dac_start;       // dac start transmission
   output                         dac_dv;          // dac data valid
   output [`DAC_DATA_NBIT-1:0]    dac_data;        // dac data
   input                          dac_waitrequest; // dac wait request

   ////////////////// ARCH ////////////////////

   ////////////////// Flash to SDRAM   
   
   reg                         f2s_start=`HIGH;
   reg                         f2s_done=`LOW;
   reg                         sdram_wren;
   reg [`SDRAM_ADDR_NBIT-1:0]  sdram_waddr=0;
   reg [`SDRAM_DATA_NBIT-1:0]  sdram_wdata;

   always@(posedge mclk) begin
      sdram_wren <= `LOW;
      if(f2s_start&sdram_wstatus) begin
         sdram_wren <= `HIGH;
         sdram_waddr <= sdram_waddr + 1'b1;
         sdram_wdata <= sdram_waddr<512 ? {1'b1,{`DAC_DATA_NBIT-1{1'b0}}} : {1'b0,{`DAC_DATA_NBIT-1{1'b1}}};
         if(sdram_waddr==1023) begin
            f2s_start <= `LOW;
            f2s_done  <= `HIGH;
         end
      end
   end
   
   ////////////////// SDRAM to AD5791
      
   // sync generate
   reg [`DAC_SYNC_DIV_NBIT-1:0] dac_sync_cnt;
   
   always@(posedge mclk) begin
      dac_sync_cnt <= dac_sync_cnt + 1'b1;
      if(dac_sync_cnt==`DAC_SYNC_DIV-1'b1)
         dac_sync_cnt <= 0;
   end
   
   assign dac_start = (dac_sync_cnt==0);
   
   // read data from sdram
   wire                        sdram_rd = f2s_done&sdram_rstatus&dac_start;   
   reg [`SDRAM_ADDR_NBIT-1:0]  sdram_raddr;
   
   always@(posedge mclk) begin
      if(sdram_rd) begin
         sdram_raddr <= sdram_raddr + 1'b1;
         if(sdram_raddr==1023) begin
            sdram_raddr <= 0;
         end
      end
   end
   
   // write sdram data to tx buffer in dac controller
   assign dac_dv   = sdram_rdv;   
   assign dac_data = sdram_rdata[`DAC_DATA_NBIT-1:0]; 
         
endmodule