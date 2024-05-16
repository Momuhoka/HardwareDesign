// ==============================================================================================
// 										  矩阵键盘顶层模块
//                                   参考官方示例PmodeKYPD模块
// ==============================================================================================

module PmodKYPD_Top(
    input xtal_clk,
    input sys_rst_n,
    
    input wire [3:0] Row,
    output wire [3:0] Col,

    output wire [5:0] led,
    output wire speaker
);

wire clk;    // 100MHz
wire [3:0] data;    // 译码数据
wire IsPressed; // 按键按钮是否更新

// 锁相环获取所需频率
rPLL_27_100 rpll_27_100(
    .clkout(clk), // 100Mhz
    .clkin(xtal_clk) // 27Mhz
);

// 矩阵键盘译码
PmodKYPD_Decoder Decoder(
    .clk(clk),
    .sys_rst_n(sys_rst_n),
    .Row(Row),
    .Col(Col),
    .DecodeOut(data),
    .IsPressed(IsPressed)
);

// 音频播放
Music Music(
    .clk(clk),  // 100Mhz
    .sys_rst_n(sys_rst_n),
    .IsPressed(IsPressed),
    .data(data),
    .speaker(speaker)
);

// LED输出
LED_Show LShow(
    .clk(clk),
    .sys_rst_n(sys_rst_n),
    .IsPressed(IsPressed),
    .data(data),
    .led(led)
);

endmodule