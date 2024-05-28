//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.05
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Wed May 29 01:02:29 2024

module notes128_pROM (dout, clk, oce, ce, reset, ad);

output [15:0] dout;
input clk;
input oce;
input ce;
input reset;
input [6:0] ad;

wire [15:0] prom_inst_0_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO({prom_inst_0_dout_w[15:0],dout[15:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,gw_gnd,gw_gnd,ad[6:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 16;
defparam prom_inst_0.RESET_MODE = "SYNC";
defparam prom_inst_0.INIT_RAM_00 = 256'h0A0B0AA40B460BF20CA80D680E340F0D0FF210E411E612F614171548168C17E4;
defparam prom_inst_0.INIT_RAM_01 = 256'h03FC0439047904BD0506055205A305F9065406B4071A078607F9087208F3097B;
defparam prom_inst_0.INIT_RAM_02 = 256'h019501AD01C701E201FE021D023D025F028302A902D202FC032A035A038D03C3;
defparam prom_inst_0.INIT_RAM_03 = 256'h00A100AA00B400BF00CA00D700E300F100FF010E011E012F014101550169017E;
defparam prom_inst_0.INIT_RAM_04 = 256'h004000440048004C00500055005A00600065006B0072007800800087008F0098;
defparam prom_inst_0.INIT_RAM_05 = 256'h0019001B001C001E00200022002400260028002B002D0030003300360039003C;
defparam prom_inst_0.INIT_RAM_06 = 256'h000A000B000B000C000D000D000E000F00100011001200130014001500170018;
defparam prom_inst_0.INIT_RAM_07 = 256'h0004000400040005000500050006000600060007000700080008000800090009;

endmodule //notes128_pROM
