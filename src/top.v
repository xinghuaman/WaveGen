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
   input          CLK1; // 48MHz      

   output         SCLK;
   input          SDIN;
   output         SYNC;
   output         SDO;
   output         RESET;
   output         CLR;
   output         LDAC;
                                        
   output [12:0]  SDRAM_A;
   inout  [31:0]  SDRAM_D;
   output [3:0]   SDRAM_DQM;
   output [1:0]   SDRAM_BA;
   output [1:0]   SDRAM_NCS;
   output         SDRAM_CKE;
   output         SDRAM_NRAS;
   output         SDRAM_NWE;
   output         SDRAM_CLK;
   output         SDRAM_NCAS;

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
   wire                        sdram_wren ;
   wire [`SDRAM_ADDR_NBIT-1:0] sdram_waddr;
   wire [`SDRAM_DATA_NBIT-1:0] sdram_wdata;
   wire                        sdram_wstatus;
   wire                        sdram_rd;
   wire [`SDRAM_ADDR_NBIT-1:0] sdram_raddr;
   wire [`SDRAM_DATA_NBIT-1:0] sdram_rdata;
   wire                        sdram_rdv;
   wire                        sdram_rstatus;
    
   wire                        sdram_rst_n;
   wire                        sdram_cs_n;
   
   assign SDRAM_NCS[0] = sdram_cs_n;
   assign SDRAM_NCS[1] = sdram_cs_n;
   assign sdram_rst_n  = `HIGH;
   
   sdram_ctrl #(`SDRAM_DATA_NBIT,`SDRAM_ADDR_NBIT)
   sdram_ctrl_u(
      .clk       (mclk          ),
      .rst_n     (sdram_rst_n   ),
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
   
   ////////////////// AD5791 Controller
   
   wire                      dac_dv;         
   wire [`DAC_DATA_NBIT-1:0] dac_data;       
   wire                      dac_waitrequest;
   wire                      dac_start;         
   wire                      dac_sclk;          
   wire                      dac_sdin = SDIN;          
   wire                      dac_sdo;           
   wire                      dac_sync;          
   wire                      dac_ldac;          
   wire                      dac_reset;         
   wire                      dac_clr;           
   
   dacout ad5791_ctrl
   (
      .tx_clk        (mclk           ),
      .tx_dv         (dac_dv         ),
      .tx_data       (dac_data       ),
      .tx_waitrequest(dac_waitrequest),
      .mclk          (mclk           ),
      .start         (dac_start      ),
      .sclk          (dac_sclk       ),
      .sdin          (dac_sdin       ),
      .sdo           (dac_sdo        ),
      .sync          (dac_sync       ),
      .ldac          (dac_ldac       ),
      .reset         (dac_reset      ),
      .clr           (dac_clr        )
   );

   assign SCLK  =  dac_sclk;
   assign SYNC  = ~dac_sync;
   assign SDO   =  dac_sdo;
   assign RESET = ~dac_reset;
   assign CLR   = ~dac_clr;
   assign LDAC  = ~dac_ldac;
   
   ////////////////// Data Flow Control
   
   flow_ctrl data_flow_ctrl
   (
      .mclk           (mclk           ),
      .sdram_wren     (sdram_wren     ),
      .sdram_waddr    (sdram_waddr    ),
      .sdram_wdata    (sdram_wdata    ),
      .sdram_wstatus  (sdram_wstatus  ),
      .sdram_rd       (sdram_rd       ),
      .sdram_raddr    (sdram_raddr    ),
      .sdram_rdata    (sdram_rdata    ),
      .sdram_rdv      (sdram_rdv      ),
      .sdram_rstatus  (sdram_rstatus  ),
      .dac_start      (dac_start      ),
      .dac_dv         (dac_dv         ),
      .dac_data       (dac_data       ),
      .dac_waitrequest(dac_waitrequest)
   );   
         
endmodule