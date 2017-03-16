/////////////////////////// INCLUDE /////////////////////////////
`include "./globals.v"

////////////////////////////////////////////////////////////////
//
//  Module  : top.v
//  Designer: Hoki
//  Company : HWorks
//  Date    : 2017/3/16 13:22:02
//
////////////////////////////////////////////////////////////////
// 
//  Description: top module of WaveGen project
//
////////////////////////////////////////////////////////////////
// 
//  Revision: 1.0

/////////////////////////// MODULE //////////////////////////////
module top
(
   // Clock Source
   CLK1,
   // AD5791
   SCLK,
   SDIN,
   SYNC,
   SDO,
   RESET,
   CLR,
   LDAC,
   // SDRAM
   SDRAM_A,
   SDRAM_D,
   SDRAM_DQM,
   SDRAM_BA,
   SDRAM_NCS,
   SDRAM_CKE,
   SDRAM_NRAS,
   SDRAM_NWE,
   SDRAM_CLK,
   SDRAM_NCAS
);

   ////////////////// PORT ////////////////////
   input                          CLK1; // 48MHz      

   output                         SCLK;
   input                          SDIN;
   output                         SYNC;
   output                         SDO;
   output                         RESET;
   output                         CLR;
   output                         LDAC;
                                        
   output [`SDRAM_ADDR_NBIT-1:0]  SDRAM_A;
   inout  [`SDRAM_DATA_NBIT-1:0]  SDRAM_D;
   output [`SDRAM_DQM_NBIT-1:0]   SDRAM_DQM;
   output [`SDRAM_BA_NBIT-1:0]    SDRAM_BA;
   output [`SDRAM_NCS_NBIT-1:0]   SDRAM_NCS;
   output                         SDRAM_CKE;
   output                         SDRAM_NRAS;
   output                         SDRAM_NWE;
   output                         SDRAM_CLK;
   output                         SDRAM_NCAS;

   ////////////////// ARCH ////////////////////
      
   ////////////////// Clock Generation
   wire mclk;
   wire locked_sig;
   clk_gen  main_clk_gen (
      .inclk0 (CLK1      ),
      .c0     (mclk      ),
      .c1     (SDRAM_CLK ),
      .locked (locked_sig)
   );

   ////////////////// SDRAM Controller
   wire                         sdram_wren ;
   reg  [`BUFFER_ADDR_NBIT-1:0] sdram_waddr;
   reg  [`BUFFER_DATA_NBIT-1:0] sdram_wdata;
   wire                         sdram_wstatus;
   
   assign sdram_wren  = sdram_wstatus&(sdram_waddr>=0&&sdram_waddr<4);
   
   always@(posedge mclk) begin
      if(sdram_wstatus) begin
         sdram_waddr <= sdram_waddr + 1'b1;
         sdram_wdata <= sdram_wdata + 1'b1;
//         if(sdram_waddr==8'hFF)
//            sdram_waddr <= sdram_waddr;
      end
   end
   
   wire                         sdram_rd;
   reg  [`BUFFER_ADDR_NBIT-1:0] sdram_raddr=8'h7F;
   wire [`BUFFER_DATA_NBIT-1:0] sdram_rdata;
   wire                         sdram_rdv;
   wire                         sdram_rstatus;   
   wire                         sdram_rst_n;
   wire                         sdram_cs_n;
   
   assign SDRAM_NCS[0] = sdram_cs_n;
   assign SDRAM_NCS[1] = sdram_cs_n;
   assign sdram_rst_n  = `HIGH;
   assign sdram_rd     = sdram_rstatus&(sdram_raddr>=0&&sdram_raddr<4);
   
   assign SDO = &sdram_rdata;
   
   always@(posedge mclk) begin
      if(sdram_rstatus) begin
         sdram_raddr <= sdram_raddr + 1'b1;
      end
   end
   
   sdram_ctrl #(`BUFFER_DATA_NBIT,`BUFFER_ADDR_NBIT)
   sdram_ctrl_u(
      .clk       (mclk          ),
      .rst_n     (`HIGH         ),
      .wren      (sdram_wren    ),
      .waddr     (sdram_waddr   ),
      .wdata     (sdram_wdata   ),
      .wstatus   (sdram_wstatus ),
      .rd        (sdram_rd      ),
      .raddr     (sdram_raddr   ),
      .rdata     (sdram_rdata   ),
      .rdv       (sdram_rdv     ),
      .rstatus   (sdram_rstatus ),
      .port_addr (SDRAM_A       ),
      .port_ba   (SDRAM_BA      ),
      .port_cas_n(SDRAM_NCAS    ),
      .port_cke  (SDRAM_CKE     ),
      .port_cs_n (sdram_cs_n    ),
      .port_dq   (SDRAM_D       ),
      .port_dqm  (SDRAM_DQM     ),
      .port_ras_n(SDRAM_NRAS    ),
      .port_we_n (SDRAM_NWE     )
   );
         
endmodule