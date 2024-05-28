//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Mon May 27 23:15:30 2024

module note128_pROM (dout, clk, oce, ce, reset, ad);

output [13:0] dout;
input clk;
input oce;
input ce;
input reset;
input [6:0] ad;

wire [17:0] prom_inst_0_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO({prom_inst_0_dout_w[17:0],dout[13:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,gw_gnd,gw_gnd,ad[6:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 16;
defparam prom_inst_0.RESET_MODE = "SYNC";
defparam prom_inst_0.INIT_RAM_00 = 256'h0013001200110010000F000F000E000D000C000C000B000A000A000900090008;
defparam prom_inst_0.INIT_RAM_01 = 256'h0031002E002C00290027002500230021001F001D001C001A0018001700160015;
defparam prom_inst_0.INIT_RAM_02 = 256'h007B0075006E00680062005C00570052004E004900450041003E003A00370034;
defparam prom_inst_0.INIT_RAM_03 = 256'h013701260115010600F700E900DC00D000C400B900AF00A5009C0093008B0083;
defparam prom_inst_0.INIT_RAM_04 = 256'h031002E402BA0293026E024B022A020B01EE01D201B8019F01880172015D014A;
defparam prom_inst_0.INIT_RAM_05 = 256'h07B8074906E0067D062005C80575052704DD04970455041703DC03A40370033F;
defparam prom_inst_0.INIT_RAM_06 = 256'h1372125B1153105A0F6F0E910DC00CFA0C400B900AEA0A4D09B9092D08A9082D;
defparam prom_inst_0.INIT_RAM_07 = 256'h31002E402BA7293426E424B522A620B41EDE1D231B8019F51880172015D4149A;

endmodule //note128_pROM
