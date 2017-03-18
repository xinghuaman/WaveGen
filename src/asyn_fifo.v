////////////////////////////////////////////////////////////////
//
//  Module  : asyn_fifo
//  Designer: Hoki
//  Company : HWorks
//  Date    : 2015/3/5 14:02:55
//
////////////////////////////////////////////////////////////////
// 
//  Description: top-level module of the asynchronous fifo design,
//               base on the paper of Clifford E Cummings,
//               write&read pointer is in gray-code style
//
////////////////////////////////////////////////////////////////
// 
//  Revision: 1.0

/////////////////////////// MODULE //////////////////////////////
module asyn_fifo
(
  wclk  ,
  wrst_n,
  wr    ,
  wdata ,
  wfull ,
  rclk  ,
  rrst_n,
  rd    ,
  rdata ,
  rempty
);
 
   ///////////////// PARAMETER ////////////////
   parameter p_nbit_d = 16;
   parameter p_nbit_a = 9; // assume that depth of fifo is power of 2
                           // Optimization Level -- Read clk sync stages,metastability protextion,area,fmax
                           // 1: Lowest latency but requires synchronized clocks 1 sync stage
                           // 2: minimal setting for unsynchronized clock 2 sync stages
                           // 3: Best metastability protection,best fmax,unsynchronized clocks 3 or more sync stages
   parameter p_opt_level = 3;
   parameter p_datafirst = 0; // data available before rdreq
   parameter p_vendor    = "altera";
   
   ////////////////// PORT ////////////////////
   input                 wclk;
   input                 wrst_n;
   input                 wr;
   input [p_nbit_d-1:0]  wdata;
   output                wfull;
   input                 rclk;
   input                 rrst_n;
   input                 rd;
   output [p_nbit_d-1:0] rdata;
   output                rempty;
   
   ////////////////// ARCH ////////////////////

   ////////////////// Write Clock Domain
   
   // Synchronize read pointer
   reg [p_nbit_a:0] rptr;     // Total p_nbit_a+1 bits for pointer:                
   reg [p_nbit_a:0] wq1_rptr; // -  p_nbit_a-1 LSB bits are used to address memory;
   reg [p_nbit_a:0] wq2_rptr; // -  2 MSB bits are used to detect full condition                                     
   always@(posedge wclk or negedge wrst_n) begin
      if(~wrst_n)
         {wq2_rptr,wq1_rptr} <= 0;
      else
         {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
   end
   
   // Write pointer
   wire [p_nbit_a:0] wptr_bin_next;
   wire [p_nbit_a:0] wptr_gray_next;
   reg  [p_nbit_a:0] wbin; // address the memory, in binary style
   reg  [p_nbit_a:0] wptr; // transfer to read clock domain, in gray-code style
   
   assign wptr_bin_next  = wbin + (wr & ~wfull); // increment binary count
   assign wptr_gray_next = (wptr_bin_next>>1) ^ wptr_bin_next; // binary-to-gray conversion
   
   always@(posedge wclk or negedge wrst_n) begin
      if(~wrst_n)
         {wbin,wptr} <= 0;
      else
         {wbin,wptr} <= {wptr_bin_next,wptr_gray_next};
   end
   
   // Address memory
   wire [p_nbit_a-1:0] waddr;
   assign waddr = wbin[p_nbit_a-1:0];

   // Full condition
   reg wfull;
   always@(posedge wclk or negedge wrst_n) begin
      if(~wrst_n)
         wfull <= 1'b0;
      else
         wfull <= (wptr_gray_next=={~wq2_rptr[p_nbit_a:p_nbit_a-1],
                                     wq2_rptr[p_nbit_a-2:0]});
   end
   
   ////////////////// Read Clock Domain
   
   // Synchronize write point
   reg [p_nbit_a:0] rq1_wptr;
   reg [p_nbit_a:0] rq2_wptr;
   
   always@(posedge rclk or negedge rrst_n) begin
      if(~rrst_n)
         {rq2_wptr,rq1_wptr} <= 0;
      else
         {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
   end
   
   // Read pointer
   wire [p_nbit_a:0] rptr_bin_next;
   wire [p_nbit_a:0] rptr_gray_next;
   reg  [p_nbit_a:0] rbin; // address the memory
   
   assign rptr_bin_next  = rbin + (rd & ~rempty); // increment binary count
   assign rptr_gray_next = (rptr_bin_next>>1) ^ rptr_bin_next; // binary-to-gray conversion

   always@(posedge rclk or negedge rrst_n) begin
      if(~rrst_n)
         {rbin,rptr} <= 0;
      else
         {rbin,rptr} <= {rptr_bin_next,rptr_gray_next};
   end
   
   // Address memory
   wire [p_nbit_a-1:0] raddr;
   assign raddr = rbin[p_nbit_a-1:0];
   
   // Empty condition
   reg rempty;
   always@(posedge rclk or negedge rrst_n) begin
      if(~rrst_n)
         rempty <= 1'b1;
      else
         rempty <= (rptr_gray_next == rq2_wptr);
   end
   
   ////////////////// FIFO Memory   
   wire [p_nbit_d-1:0] mem_rdata;
   wire                mem_rd = p_datafirst ? 1'b1 : rd;
generate if(p_vendor=="altera") begin: altera_ram
   afifomem #(p_nbit_d,p_nbit_a,~(p_opt_level == 1)) 
   fifomem_u
   (
      .wclk (wclk     ),
      .wr   (wr       ),
      .waddr(waddr    ),
      .wdata(wdata    ),
      .rclk (rclk     ),
      .rd   (mem_rd   ),
      .raddr(raddr    ),
      .rdata(mem_rdata)
   );
end
endgenerate
   
   // Read Data Output Register, Depend on optimization level
   reg [p_nbit_d-1:0] rdata;
   generate
      if(p_opt_level>2)
         always@(posedge rclk)
            rdata <= mem_rdata;
      else
         always@*
            rdata <= mem_rdata;
   endgenerate   

endmodule