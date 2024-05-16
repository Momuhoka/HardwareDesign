// ==============================================================================================
// 										  矩阵键盘顶层模块
//                                   参考官方示例PmodeKYPD模块
// ==============================================================================================

module PmodKYPD_Top(
    input xtal_clk,
    input sys_rst_n,
    
    input wire [3:0] Row,
    output wire [3:0] Col,

    output wire [5:0] led
);

wire clk_100Mhz;
wire [3:0] data;    // 译码数据

// 锁相环获取所需频率
rPLL_27_100 rPLL_init(
    .clkout(clk_100Mhz), // 输出100Mhz
    .clkin(xtal_clk) // 输入系统频率
);

// 矩阵键盘译码
PmodKYPD_Decoder Decoder(
    .clk(clk_100Mhz),
    .Row(Row),
    .Col(Col),
    .DecodeOut(data)
);

// LED输出
LED_Show LShow(
    .clk(clk_100Mhz),
    .sys_rst_n(sys_rst_n),
    .data(data),
    .led(led)
);

endmodule