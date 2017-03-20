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
   // Wave Control
   wave_sel,
   wave_gain,
   wave_start,
   wave_clk,
   // AD5791
   SCLK,
   SDIN,
   SYNC,
   SDO,
   RESET,
   CLR,
   LDAC,
   // FLASH
   FLASH_SCLK,
   FLASH_CS,
   FLASH_SDI,
   FLASH_SDO,
   FLASH_WP,
   FLASH_HOLD,
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

   input  [2:0]   wave_sel;
   input  [2:0]   wave_gain;
   input          wave_start;
   input          wave_clk;

   output         SCLK;
   input          SDIN;
   output         SYNC;
   output         SDO;
   output         RESET;
   output         CLR;
   output         LDAC;

   output         FLASH_SCLK;
   output         FLASH_CS;
   input          FLASH_SDI;
   output         FLASH_SDO;
   output         FLASH_WP;
   output         FLASH_HOLD;

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
   
   ////////////////// Data Source
   
//   wire [`FLASH_ADDR_NBIT-1:0]  dsrc_addr;
//   wire [`FLASH_DATA_NBIT-1:0]  dsrc_data;
//
//   buffered_ram #(`FLASH_ADDR_NBIT,`FLASH_DATA_NBIT,"../src/sin.mif")
//   data_source(
//      .inclk       (mclk),
//      .in_wren     (`LOW),
//      .in_wraddress(0),
//      .in_wrdata   (0),
//      .in_rdaddress(dsrc_addr),
//      .out_rddata  (dsrc_data)
//   );

   wire                         flash_rd;
   wire [`FLASH_ADDR_NBIT-1:0]  flash_raddr;
   wire                         flash_rstatus;
   wire [`FLASH_DATA_NBIT-1:0]  flash_rdata;
   wire                         flash_rdv;
   wire                         flash_sclk;
   wire                         flash_cs;
   wire                         flash_sdo;
   wire                         flash_wp;
   wire                         flash_hold;

   flash_ctrl u_flash
   (
      .mclk   (mclk         ),
      .rd     (flash_rd     ),
      .raddr  (flash_raddr  ),
      .rstatus(flash_rstatus),
      .rdata  (flash_rdata  ),
      .rdv    (flash_rdv    ),
      .sclk   (flash_sclk   ),
      .cs     (flash_cs     ),
      .sdi    (FLASH_SDI    ),
      .sdo    (flash_sdo    ),
      .wp     (flash_wp     ),
      .hold   (flash_hold   )
   );
   
   assign FLASH_SCLK = flash_sclk;
   assign FLASH_CS   =~flash_cs  ;
   assign FLASH_SDO  = flash_sdo ; 
   assign FLASH_WP   =~flash_wp  ;
   assign FLASH_HOLD =~flash_hold;
   
   reg  [16:0]                    int_gain;
   reg  [`FLASH_DATA_NBIT-1+16:0] m_dsrc_data;
   reg                            flash_dv;
   
   always@(posedge mclk) begin
      case({wave_sel,wave_gain})
         // waveform 0, gain 0
         6'b001_001: int_gain <= 16'h8000;
         // waveform 1, gain 0
         6'b010_001: int_gain <= 16'h6666;
         // waveform 1, gain 1
         6'b010_010: int_gain <= 16'h3333;
         // waveform 2, gain 0
         6'b100_001: int_gain <= 16'h6666;
         // waveform 2, gain 1
         6'b100_010: int_gain <= 16'h6000;
         // waveform 2, gain 2
         6'b100_100: int_gain <= 16'h3333;
         // others
         default:    int_gain <= 16'h8000;
      endcase
      m_dsrc_data <= flash_rdata * int_gain;
      flash_dv    <= flash_rdv;
   end

   wire [`FLASH_DATA_NBIT-1:0]  flash_data = m_dsrc_data[`FLASH_DATA_NBIT-1+15:15];

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
   wire                      dac_en;
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
      .en            (dac_en         ),
      .sclk          (dac_sclk       ),
      .sdin          (dac_sdin       ),
      .sdo           (dac_sdo        ),
      .sync          (dac_sync       ),
      .ldac          (dac_ldac       ),
      .reset         (dac_reset      ),
      .clr           (dac_clr        )
   );

   assign SCLK  =  dac_sclk;
   assign SDO   =  dac_sdo;
   assign SYNC  = ~dac_sync;
   assign LDAC  = `LOW;//~dac_ldac;
   assign RESET = ~dac_reset;
   assign CLR   = ~dac_clr;
   
   ////////////////// Data Flow Control
   
   flow_ctrl data_flow_ctrl
   (
      .mclk           (mclk           ),
      .flash_rd       (flash_rd       ),
      .flash_addr     (flash_raddr    ),
      .flash_rstatus  (flash_rstatus  ),
      .flash_data     (flash_data     ),
      .flash_dv       (flash_dv       ),
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
      .dac_en         (dac_en         ),
      .dac_dv         (dac_dv         ),
      .dac_data       (dac_data       ),
      .dac_waitrequest(dac_waitrequest)
   );   
         
endmodule