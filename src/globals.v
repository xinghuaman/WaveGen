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

`define FLASH_SCLK_DIV_NBIT 7
`define FLASH_SCLK_DIV      4   // max 50MHz

`define FLASH_ADDR_NBIT     24
`define FLASH_DATA_NBIT     8

`define FLASH_DATA_NUM      80000

////////////////// Gain

`define GAIN_NBIT           16
`define GAIN_1              `GAIN_NBIT'h7FFF
`define GAIN_500mv          `GAIN_NBIT'h5B6E
`define GAIN_160mv          `GAIN_NBIT'h6BCA
`define GAIN_80mv           `GAIN_NBIT'h2EB3
`define GAIN_40mv           `GAIN_NBIT'h2E8B
`define GAIN_30mv           `GAIN_NBIT'h23B8
`define GAIN_20mv           `GAIN_NBIT'h1111

`define OFFSET_0            `DAC_DATA_NBIT'd0
`define OFFSET_1            `DAC_DATA_NBIT'd0
`define OFFSET_2            `DAC_DATA_NBIT'd0
`define OFFSET_3            `DAC_DATA_NBIT'd0
`define OFFSET_4            `DAC_DATA_NBIT'd0
`define OFFSET_5            `DAC_DATA_NBIT'd0
`define OFFSET_6            `DAC_DATA_NBIT'd0