////////////////////////////////////////////////////////////////
//
//  Module  : globals
//  Designer: Hoki
//  Company : HWorks
//  Date    : 2015/11/13 
//
////////////////////////////////////////////////////////////////
// 
//  Description: global definition, macro, variables
//
////////////////////////////////////////////////////////////////
// 
//  Revision: 1.0

`define HIGH 1'b1
`define LOW  1'b0

////////////////// SDRAM
`define SDRAM_ADDR_NBIT     13
`define SDRAM_DATA_NBIT     32
`define SDRAM_DQM_NBIT      4
`define SDRAM_BA_NBIT       2
`define SDRAM_NCS_NBIT      2
`define SDRAM_RA_NBIT       13 // row address width
`define SDRAM_CA_NBIT       10 // column address width
                         
// BUFFER
`define BUFFER_ADDR_NBIT    8
`define BUFFER_DATA_NBIT    16