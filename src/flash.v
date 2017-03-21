/////////////////////////// INCLUDE /////////////////////////////
`include "../src/globals.v"

////////////////////////////////////////////////////////////////
//
//  Module  : flash_ctrl
//  Designer: Hoki
//  Company : HWorks
//  Date    : 2017/3/20 14:42:24
//
////////////////////////////////////////////////////////////////
// 
//  Description: Flash controller
//
////////////////////////////////////////////////////////////////
// 
//  Revision: 1.0

/////////////////////////// DEFINE /////////////////////////////

`define ST_IDLE      2'b00
`define ST_INS       2'b01
`define ST_ADDR      2'b11
`define ST_DATA      2'b10

`define INS_NBIT     8
`define ADDR_NBIT    24
`define DATA_NBIT    8

`define INS_READDATA `INS_NBIT'h03
`define INS_JEDECID  `INS_NBIT'h9F

/////////////////////////// MODULE //////////////////////////////
module flash_ctrl
(
   mclk,
   rd,
   raddr,
   rstatus,
   rdata,
   rdv,
   sclk,
   cs,
   sdi,
   sdo,
   wp,
   hold
);

   ///////////////// PARAMETER ////////////////

   ////////////////// PORT ////////////////////
   input                          mclk;    // main clock
   
   input                          rd;      // read
   input  [`FLASH_ADDR_NBIT-1:0]  raddr;   // read address
   output                         rstatus; // read status
   output [`FLASH_DATA_NBIT-1:0]  rdata;   // read data
   output                         rdv;     // read data valid
   
   output                         sclk;    // flash serial clock output
   output                         cs;      // flash chip select
   input                          sdi;     // flash serial data input
   output                         sdo;     // flash serial data output
   output                         wp;      // flash write protect
   output                         hold;    // flash hold 

   ////////////////// ARCH ////////////////////

   ////////////////// serial clock generate
   
   reg  [`FLASH_SCLK_DIV_NBIT-1:0]  sclk_cnt;
   
   always@(posedge mclk) begin
      sclk_cnt <= sclk_cnt + 1'b1;
      if(sclk_cnt==`FLASH_SCLK_DIV-1)
         sclk_cnt <= 0;
   end
      
   ////////////////// FSM
   
   wire  fsm_do_en = (sclk_cnt==`FLASH_SCLK_DIV-1);
   wire  fsm_di_en = ((fsm_st==`ST_DATA) && (sclk_cnt==`FLASH_SCLK_DIV/2-1));
   
   reg  [1:0]  fsm_st;
   reg         fsm_start;
   reg  [5:0]  fsm_cnt;
   reg  [47:0] fsm_data;

   reg                         rstatus;
   reg [`FLASH_DATA_NBIT-1:0]  rdata;
   reg                         rdv;
   
   always@(posedge mclk) begin
      fsm_start <= (rd&(fsm_st==`ST_IDLE)) ? `HIGH : (fsm_st!=`ST_IDLE ? `LOW : fsm_start);
      rstatus   <= (fsm_st==`ST_IDLE);
      fsm_data  <= fsm_di_en ? {fsm_data[46:0],sdi} : fsm_data;
      if(fsm_do_en) begin
         case(fsm_st)
            `ST_IDLE: begin
               fsm_cnt <= 0;
               rstatus <= `HIGH;
               if(fsm_start) begin
                  rdv <= `LOW;
                  fsm_cnt <= 6'd`INS_NBIT-1'b1;
                  fsm_data<= {`INS_READDATA,{48-`INS_NBIT{1'b0}}};
                  fsm_st  <= `ST_INS;
               end
            end
            `ST_INS : begin
               fsm_cnt  <= fsm_cnt - 1'b1;
               fsm_data <= fsm_data<<1;
               if(fsm_cnt==0) begin
                  fsm_cnt  <= (`ADDR_NBIT!=0) ? (6'd`ADDR_NBIT-1'b1) : (6'd`DATA_NBIT-1'b1);
                  fsm_data <= {raddr,{48-`ADDR_NBIT{1'b0}}};
                  fsm_st   <= (`ADDR_NBIT!=0) ? `ST_ADDR : ((`DATA_NBIT!=0) ? `ST_DATA : `ST_IDLE);
               end
            end
            `ST_ADDR: begin
               fsm_cnt  <= fsm_cnt - 1'b1;
               fsm_data <= fsm_data<<1;
               if(fsm_cnt==0) begin
                  fsm_cnt  <= 6'd`DATA_NBIT-1'b1;
                  fsm_data <= 0;
                  fsm_st   <= `DATA_NBIT!=0 ? `ST_DATA : `ST_IDLE;
               end
            end
            `ST_DATA: begin
               fsm_cnt  <= fsm_cnt - 1'b1;
               if(fsm_cnt==0) begin
                  fsm_cnt  <= 0;
                  fsm_data <= 0;
                  fsm_st   <= `ST_IDLE;
                  rdv      <= `HIGH;                                // output data valid
                  rdata    <= {fsm_data[`FLASH_DATA_NBIT-2:0],sdi}; // output data
               end
            end
            default:  begin
               fsm_cnt  <= 0;
               fsm_data <= 0;
               fsm_st   <= `ST_IDLE;
            end
         endcase
      end
   end

   reg                         sclk_en;
   reg                         cs;
   reg                         sdo; 
   reg                         wp;  
   reg                         hold;

   assign sclk = sclk_en&(sclk_cnt>=`FLASH_SCLK_DIV/2);
   
   always@* begin
      case(fsm_st)
         `ST_IDLE: begin
            sclk_en <= `LOW;
            cs      <= `LOW;
            sdo     <= `LOW;
            wp      <= `LOW;
            hold    <= `LOW;
         end
         `ST_INS : begin
            sclk_en <= `HIGH;
            cs      <= `HIGH;
            sdo     <= fsm_data[47];
            wp      <= `LOW;
            hold    <= `LOW;
         end
         `ST_ADDR: begin
            sclk_en <= `HIGH;
            cs      <= `HIGH;
            sdo     <= fsm_data[47];
            wp      <= `LOW;
            hold    <= `LOW;
         end
         `ST_DATA: begin
            sclk_en <= `HIGH;
            cs      <= `HIGH;
            sdo     <= `LOW;
            wp      <= `LOW;
            hold    <= `LOW;
         end
         default:  begin
            sclk_en <= `LOW;
            cs      <= `LOW;
            sdo     <= `LOW;
            wp      <= `LOW;
            hold    <= `LOW;
         end
      endcase   
   end

endmodule   