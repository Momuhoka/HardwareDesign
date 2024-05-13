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

wire clk;    // 100MHz
wire [3:0] data;    // 译码数据

// 锁相环获取所需频率
Gowin_rPLL uPLL(
    .clkout(clk), // 输出频率
    .clkin(xtal_clk) // 输入频率
);

// 矩阵键盘译码
PmodKYPD_Decoder Decoder(
    .clk(clk),
    .Row(Row),
    .Col(Col),
    .DecodeOut(data)
);

// LED输出
LED_Show LShow(
    .clk(clk),
    .sys_rst_n(sys_rst_n),
    .data(data),
    .led(led)
);

endmodule