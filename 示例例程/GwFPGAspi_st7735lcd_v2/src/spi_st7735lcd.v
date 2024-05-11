//****************************************Copyright (c)***********************************//
//----------------------------------------------------------------------------------------
// Author：Pxm
// File name: spi_st7735lcd
// First establish Date: 2022/12/15 
// Descriptions: st7735R-SPI-LCD-demo顶层模块
// OutPin--CS    屏（从机）片选
// OutPin--RESET ST7735复位          （也有标RST）
// OutPin--DC    命令or数据指示      （也有标RS）
// OutPin--MOSI  主机输出数据给屏从机（也有标SDI）
// OutPin--SCLK  主机输出数据时钟    （也有标SCK）
// OutPin--LED   背光开关            （也有标BLK）
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module  spi_st7735lcd
(
    input           xtal_clk      ,
    input           sys_rst_n     ,
    
    output          lcd_rst       ,
    output          lcd_dc        ,
    output          lcd_sclk      ,
    output          lcd_mosi      ,
    output          lcd_cs        ,
    output          lcd_led       ,
    output          testled
);
wire    [8:0]   data;   
wire            en_write;
wire            wr_done; 

wire    [8:0]   init_data;
wire            en_write_init;
wire            init_done;

wire    [6:0]   ascii_num           ;
wire    [8:0]   start_x             ;
wire    [8:0]   start_y             ;

wire    [8:0]   show_char_data      ;

assign  testled = ~init_done;
assign  lcd_led = 1'b1;  //屏背光常亮

wire sys_clk;
Gowin_rPLL uPLL( .clkout(sys_clk), .clkin (xtal_clk) ); //以PLL核产生高频提升运行速度--100M。
//assign sys_clk = xtal_clk;     //不用PLL核，直接用板载12MHz主频。仿真时也改用此句，免得引入PLL仿真核。

lcd_init    lcd_init_inst
(
    .sys_clk      (sys_clk      ),
    .sys_rst_n    (sys_rst_n    ),
    .wr_done      (wr_done      ),

    .lcd_rst      (lcd_rst      ),
    .init_data    (init_data    ),
    .en_write     (en_write_init),
    .init_done    (init_done    )
);

wire en_write_show_char;
wire show_char_done;
wire en_size;
wire show_char_flag;

muxcontrol  muxcontrol_inst
(
    .sys_clk            (sys_clk           ) ,   
    .sys_rst_n          (sys_rst_n         ) ,
    .init_done          (init_done         ) ,

    .init_data          (init_data         ) ,
    .en_write_init      (en_write_init     ) ,
    .show_char_data     (show_char_data    ) ,
    .en_write_show_char (en_write_show_char) ,

    .data               (data              ) ,
    .en_write           (en_write          )
);

lcd_write
#( .HALFDIV('d2) )     // 为适应系统时钟设置的分频比参数，>0，且sys_clk/2/HALFDIV不能超过spi硬件最大速率
                       // 实测sys_clk为100MHz，HALFDIV=1也能正常运行，一般就用2吧。
  lcd_write_inst (
    .sys_clk      (sys_clk      ),
    .sys_rst_n    (sys_rst_n    ),
    .data         (data         ),
    .en_write     (en_write     ),
                                
    .wr_done      (wr_done      ),
    .cs           (lcd_cs       ),
    .dc           (lcd_dc       ),
    .sclk         (lcd_sclk     ),
    .mosi         (lcd_mosi     )
);


show_string_number_ctrl  show_string_number_inst
(
    .sys_clk        (sys_clk        ) ,
    .sys_rst_n      (sys_rst_n      ) ,
    .init_done      (init_done      ) ,
    .show_char_done (show_char_done ) ,

    .en_size        (en_size        ) ,
    .show_char_flag (show_char_flag ) ,
    .ascii_num      (ascii_num      ) ,
    .start_x        (start_x        ) ,
    .start_y        (start_y        ) 
);  


lcd_show_char  lcd_show_char_inst
(
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (sys_rst_n          ),
    .wr_done            (wr_done            ),
    .en_size            (en_size            ),   //为0时字体大小的12x6，为1时字体大小的16x8
    .show_char_flag     (show_char_flag     ),   //显示字符标志信号
    .ascii_num          (ascii_num          ),   //需要显示字符的ascii码
    .start_x            (start_x            ),   //起点的x坐标    
    .start_y            (start_y            ),   //起点的y坐标    

    .show_char_data     (show_char_data     ),   //传输的命令或者数据
    .en_write_show_char (en_write_show_char ),   //使能写spi信号
    .show_char_done     (show_char_done     )    //显示字符完成标志信号
);

endmodule