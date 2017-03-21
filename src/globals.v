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

`define HIGH                1'b1
`define LOW                 1'b0

////////////////// SDRAM

`define SDRAM_DATA_NBIT     32
`define SDRAM_ADDR_NBIT     24

////////////////// AD5791

`define DAC_DATA_NBIT       20

`define DAC_SCLK_DIV_NBIT   5
`define DAC_SCLK_DIV        8

`define DAC_SYNC_DIV_NBIT  (8+`DAC_SCLK_DIV_NBIT) 
`define DAC_SYNC_DIV       (30*`DAC_SCLK_DIV)

////////////////// FLASH

`define FLASH_SCLK_DIV_NBIT 3
`define FLASH_SCLK_DIV      6   // max 50MHz

`define FLASH_ADDR_NBIT     15
`define FLASH_DATA_NBIT     8

`define FLASH_DATA_NUM     (99*1000000/`DAC_SYNC_DIV/55)  // N = fs/fc = (132MHz/30/8)/55Hz = 10000 
