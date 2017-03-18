////////////////////////////////////////////////////////////////
//
//  Module  : afifomem
//  Designer: Hoki
//  Company : 
//  Date    : 2015/3/5 15:44:10
//
////////////////////////////////////////////////////////////////
// 
//  Description: Memory used in FIFO design 
//  - Using Altera RAM primitive:
//  - Arria II GX: MLAB(640bits) M9K(9Kbits)      -             -               -         Logic Cell(LC)
//  - Arria II GZ: MLAB(640bits) M9K(9Kbits)      -             -         M144K(144Kbits) Logic Cell(LC)
//  - Arria V:     MLAB(640bits)     -        M10K(10Kbits)     -               -         Logic Cell(LC)
//  - Cyclone IV:       -         M9K(9Kbits)      -             -               -        Logic Cell(LC)
//  - Cyclone V:   MLAB(640bits)     -        M10K(10Kbits)     -               -         Logic Cell(LC)
//  - Max II:           -             -             -             -               -       Logic Cell(LC)
//  - Stratix IV:  MLAB(640bits) M9K(9Kbits)      -             -         M144K(144Kbits) Logic Cell(LC)
//  - Stratix V:   MLAB(640bits)     -             -        M20K(20Kbits)       -         Logic Cell(LC)
//
////////////////////////////////////////////////////////////////
// 
//  Revision: 1.0

/////////////////////////// MODULE //////////////////////////////
module afifomem
(
   wclk ,
   wr   ,
   waddr,
   wdata,
   rclk ,
   rd   ,
   raddr,
   rdata
);

   ///////////////// PARAMETER ////////////////
   parameter p_nbit_d = 8;
   parameter p_nbit_a = 4;
   parameter p_output_reg_en = 1'b1;
   
   ////////////////// PORT ////////////////////
   input                 wclk;
   input                 wr;   
   input  [p_nbit_d-1:0] wdata;
   input  [p_nbit_a-1:0] waddr;
   input                 rclk; 
   input                 rd;
   input  [p_nbit_a-1:0] raddr;
   output [p_nbit_d-1:0] rdata; 
   
   ////////////////// ARCH ////////////////////
   
   altsyncram altsyncram_u
   (
      .address_a     (waddr),
      .clock0        (wclk),
      .data_a        (wdata),
      .wren_a        (wr),
      .address_b     (raddr),
      .q_b           (rdata),
      .aclr0         (1'b0),
      .aclr1         (1'b0),
      .addressstall_a(1'b0),
      .addressstall_b(1'b0),
      .byteena_a     (1'b1),
      .byteena_b     (1'b1),
      .clock1        (rclk),
      .clocken0      (1'b1),
      .clocken1      (1'b1),
      .clocken2      (1'b1),
      .clocken3      (1'b1),
      .data_b        ({p_nbit_d{1'b1}}),
      .eccstatus     (),
      .q_a           (),
      .rden_a        (1'b1),
      .rden_b        (rd),
      .wren_b        (1'b0)
   );

   defparam
   	altsyncram_u.address_aclr_a = "UNUSED",
   	altsyncram_u.address_aclr_b = "NONE",
   	altsyncram_u.address_reg_b = "CLOCK1",
   	altsyncram_u.byte_size = 8,
   	altsyncram_u.byteena_aclr_a = "UNUSED",
   	altsyncram_u.byteena_aclr_b = "NONE",
   	altsyncram_u.byteena_reg_b = "CLOCK1",
   	altsyncram_u.clock_enable_input_a = "BYPASS",
   	altsyncram_u.clock_enable_input_b = "BYPASS",
   	altsyncram_u.clock_enable_output_a = "BYPASS",
   	altsyncram_u.clock_enable_output_b = "BYPASS",
   	altsyncram_u.indata_aclr_a = "UNUSED",
   	altsyncram_u.indata_aclr_b = "NONE",
   	altsyncram_u.indata_reg_b = "CLOCK1",
   	altsyncram_u.init_file = "UNUSED",
   	altsyncram_u.init_file_layout = "PORT_A",
   	altsyncram_u.intended_device_family = "Cyclone IV",
   	altsyncram_u.implement_in_les = "OFF",
   	altsyncram_u.lpm_hint = "UNUSED",
   	altsyncram_u.lpm_type = "altsyncram",
   	altsyncram_u.maximum_depth = 0,
   	altsyncram_u.numwords_a = 2**p_nbit_a,
   	altsyncram_u.numwords_b = 2**p_nbit_a,
   	altsyncram_u.operation_mode = "DUAL_PORT",
   	altsyncram_u.outdata_aclr_a = "NONE",
   	altsyncram_u.outdata_aclr_b = "NONE",
   	altsyncram_u.outdata_reg_a = "UNREGISTERED",
   	altsyncram_u.outdata_reg_b = p_output_reg_en ? "CLOCK1" : "UNREGISTERED",
   	altsyncram_u.power_up_uninitialized = "FALSE",
   	altsyncram_u.ram_block_type = "M9K",
   	altsyncram_u.rdcontrol_aclr_b = "NONE",
   	altsyncram_u.rdcontrol_reg_b = "CLOCK1",
   	altsyncram_u.read_during_write_mode_mixed_ports = "DONT_CARE",
   	altsyncram_u.width_a = p_nbit_d,
   	altsyncram_u.width_b = p_nbit_d,
   	altsyncram_u.width_byteena_a = 1,
   	altsyncram_u.width_byteena_b = 1,
   	altsyncram_u.widthad_a = p_nbit_a,
   	altsyncram_u.widthad_b = p_nbit_a,
   	altsyncram_u.wrcontrol_aclr_a = "UNUSED",
   	altsyncram_u.wrcontrol_aclr_b = "NONE",
   	altsyncram_u.wrcontrol_wraddress_reg_b = "CLOCK1",
   	altsyncram_u.clock_enable_core_a = "USE_INPUT_CLKEN",
   	altsyncram_u.clock_enable_core_b = "USE_INPUT_CLKEN",
   	altsyncram_u.enable_ecc = "FALSE",
   	altsyncram_u.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
   	altsyncram_u.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ";
      
endmodule