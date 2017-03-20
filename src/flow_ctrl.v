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
   flash_rd       ,
   flash_addr     ,
   flash_rstatus  ,
   flash_data     ,
   flash_dv       ,
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
   dac_en         ,
   dac_dv         ,
   dac_data       ,
   dac_waitrequest
);


   ///////////////// PARAMETER ////////////////

   ////////////////// PORT ////////////////////
   
   input                          mclk;             // main clock
   
   // Flash Interface
   output [`FLASH_ADDR_NBIT-1:0]  flash_addr;
   input  [`FLASH_DATA_NBIT-1:0]  flash_data;
   output                         flash_rd;
   input                          flash_rstatus;
   input                          flash_dv;
   
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
   output                         dac_en;          // dac enable
   output                         dac_dv;          // dac data valid
   output [`DAC_DATA_NBIT-1:0]    dac_data;        // dac data
   input                          dac_waitrequest; // dac wait request

   ////////////////// ARCH ////////////////////

   ////////////////// Flash to SDRAM   
   
   
   reg                          f2s_start=`HIGH;
   reg                          f2s_done=`LOW;   

   assign flash_rd = f2s_start&flash_rstatus&sdram_wstatus;

   reg                          sdram_wren;
   reg  [`SDRAM_ADDR_NBIT-1:0]  sdram_waddr;
   reg  [`SDRAM_DATA_NBIT-1:0]  sdram_wdata;
   
   reg                          p_flash_rd;
   reg [`FLASH_ADDR_NBIT-1:0]   flash_addr;
   reg [1:0]                    flash_cnt;

   always@(posedge mclk) begin
      p_flash_rd <= flash_rd;
      if(flash_rd&~p_flash_rd) begin
         flash_addr <= flash_addr + 1'b1;
      end
      
      sdram_wren <= `LOW;
      if(flash_rd&~p_flash_rd&flash_dv) begin
         flash_cnt <= flash_cnt + 1'b1;
         sdram_wdata <= flash_cnt==0 ? {{`SDRAM_DATA_NBIT-`FLASH_DATA_NBIT{1'b0}},flash_data} :
                                       {sdram_wdata[`SDRAM_DATA_NBIT-`FLASH_DATA_NBIT-1:0],flash_data};
         if(flash_cnt==2'b10) begin
            flash_cnt <= 0;
            sdram_wren <= `HIGH;
         end
      end
      
      if(sdram_wren) begin
         sdram_waddr <= sdram_waddr + 1'b1;
         if(sdram_waddr==`FLASH_DATA_NUM-1) begin
            f2s_start <= `LOW;
            f2s_done  <= `HIGH;
         end
      end
      
      if(~f2s_start|f2s_done) begin
         flash_cnt <= 0;
         sdram_wdata <= 0;
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
   assign dac_en    = f2s_done;
   
   // read data from sdram
   wire                        sdram_rd = f2s_done&sdram_rstatus&dac_start;   
   reg [`SDRAM_ADDR_NBIT-1:0]  sdram_raddr;
   
   always@(posedge mclk) begin
      if(sdram_rd) begin
         sdram_raddr <= sdram_raddr + 1'b1;
         if(sdram_raddr==`FLASH_DATA_NUM-1) begin
            sdram_raddr <= 0;
         end
      end
   end
   
   // write sdram data to tx buffer in dac controller
   assign dac_dv   = sdram_rdv;   
   assign dac_data = sdram_rdata[`DAC_DATA_NBIT-1:0]; 
         
endmodule