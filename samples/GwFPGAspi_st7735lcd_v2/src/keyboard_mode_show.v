//----------------------------------------------------------------------------------------
// File name: keyboard_mode_show
// Descriptions: 电子琴模式的显示模块
//----------------------------------------------------------------------------------------
//****************************************************************************************//
/*
在屏幕上显示字符串
第一行中间显示“KeyBoard”共8个字符；
空一行；
第三四五行为低中高音: 160/8=20最多；
LOW> 1 2 3 4 5 6 7 ?
MID> 1 2 3 4 5 6 7 <
HIG> 1 2 3 4 5 6 7 ?
总共8+20*3=68个字符
cnt_ascii_num  0   1   2   3   4   5   6   7  
   char        K   e   y   B   o   a   r   d
 ascii码       75,101,121, 66,111, 97,114,100 = 库内码+32 
*/

module keyboard_mode_show
(
    input       wire            sys_clk             ,
    input       wire            sys_rst_n           ,
    input       wire            init_done           ,
    input       wire            show_char_done      ,
    
    input       wire            IsPressed           , // 接收按钮状态信息
    input       wire    [3:0]   keyboard_data       , // 接收矩阵键盘数据
    input       wire    [3:0]   scale               , // 接收当前音调数据
    
    output      wire            en_size             ,
    output      reg             show_char_flag      ,
    output      reg     [6:0]   ascii_num           ,
    output      reg     [8:0]   start_x             ,
    output      reg     [8:0]   start_y             ,

    output      reg    [15:0]   background_color    , // 自行输出背景色
    output      reg    [15:0]   front_color           // 自行输出字体颜色
);      
//****************** Parameter and Internal Signal *******************//        
reg     [1:0]   cnt1;            //展示 行 计数器？！？3行故cnt1值只需0，1，2
//也可能是延迟计数器，init_done为高电平后，延迟3拍，产生show_char_flag高脉冲
reg     [6:0]   cnt_ascii_num;

// 总字符数
localparam CHAR_NUM = 7'd68;
// 符号 < >
localparam SPACE = 'd0;
localparam LEFT_MORE = 'd60-'d32;
localparam RIGHT_MORE = 'd62-'d32;

// 对应数据反色
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        background_color <= 16'hAF7D;
        front_color <= 16'h0000;
    end else if(cnt_ascii_num>7 && (cnt_ascii_num-8)%20<3) begin
        background_color <= 16'h815B;
        front_color <= 16'hFFFF;
    end else if(keyboard_data>=1 && keyboard_data<=7 &&
                keyboard_data==((cnt_ascii_num-12-20*scale)>>1)+1 &&
                IsPressed) begin
        background_color <= 16'hFA20;
        front_color <= 16'hFFFF;
    end else begin // 正常显示
        background_color <= 16'hAF7D;
        front_color <= 16'h0000;
    end
end

//******************************* Main Code **************************//
//en_size为1时调用字体大小为16x8，为0时调用字体大小为12x6；
assign  en_size = 1'b1;

//产生输出信号show_char_flag，写到第2行！？就让show_char_flag产生一个高脉冲给后面模块
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt1 <= 'd0;
    else if(show_char_flag)
        cnt1 <= 'd0;
    else if(init_done && cnt1 < 'd3)
        cnt1 <= cnt1 + 1'b1;
    else
        cnt1 <= cnt1;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        show_char_flag <= 1'b0;
    else if(cnt1 == 'd2)
        show_char_flag <= 1'b1;
    else
        show_char_flag <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt_ascii_num <= 'd0;
    else if(init_done && show_char_done)         //展示数目的计数器：初始化完成和上一个char展示完成后，数目+1
        // 添加了达到字符上限循环判断，存在CHAR_NUM而不是CHAR_NUM-1是多一个输出结束时隙
        cnt_ascii_num <= (cnt_ascii_num==CHAR_NUM-1) ? 1'd0 : cnt_ascii_num + 1'b1;   //等于是展示字符的坐标（单位：个字符）
    else
        cnt_ascii_num <= cnt_ascii_num;

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        ascii_num <= 'd0;
    else if(init_done)
        case(cnt_ascii_num)         //根据当前展示数目（字符坐标）给出展示内容（ascii码）
//ascii码     75,101,121, 66,111, 97,114,100  =库内码+32
            0 : ascii_num <= 'd75-'d32; 
            1 : ascii_num <= 'd101-'d32;
            2 : ascii_num <= 'd121-'d32;
            3 : ascii_num <= 'd66-'d32;
            4 : ascii_num <= 'd111-'d32;
            5 : ascii_num <= 'd97-'d32;
            6 : ascii_num <= 'd114-'d32;
            7 : ascii_num <= 'd100-'d32;
            8 : ascii_num <= 'd76-'d32; // L
            9 : ascii_num <= 'd79-'d32; // O
            10 : ascii_num <= 'd87-'d32; // W
            11 : ascii_num <= RIGHT_MORE; // >
            27 : ascii_num <= (scale==4'd0) ? LEFT_MORE : SPACE;
            28 : ascii_num <= 'd77-'d32; // M
            29 : ascii_num <= 'd73-'d32; // I
            30 : ascii_num <= 'd68-'d32; // D
            31 : ascii_num <= RIGHT_MORE; // >
            47 : ascii_num <= (scale==4'd1) ? LEFT_MORE : SPACE;
            48 : ascii_num <= 'd72-'d32; // H
            49 : ascii_num <= 'd73-'d32; // I
            50 : ascii_num <= 'd71-'d32; // G
            51 : ascii_num <= RIGHT_MORE; // >
            67 : ascii_num <= (scale==4'd2) ? LEFT_MORE : SPACE;
            default: begin
                if(cnt_ascii_num<27 && cnt_ascii_num[0]==1) begin // 第三行LOW> 1 2 3 4 5 6 7 ?
                    ascii_num <= ((cnt_ascii_num-7'd13)>>1)+7'd49-7'd32;    // 简单换算(cnt_ascii_num-13)/2=0->1的ascii码为49
                end else if(cnt_ascii_num<47 && cnt_ascii_num[0]==1) begin // 第四行LOW> 1 2 3 4 5 6 7 ?
                    ascii_num <= ((cnt_ascii_num-7'd33)>>1)+7'd49-7'd32; 
                end else if(cnt_ascii_num<67 && cnt_ascii_num[0]==1) begin // 第五行LOW> 1 2 3 4 5 6 7 ?
                    ascii_num <= ((cnt_ascii_num-7'd53)>>1)+7'd49-7'd32; 
                end else ascii_num <= 1'd0;
            end
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        start_x <= 'd0;
    else if(init_done) 
        if(cnt_ascii_num<CHAR_NUM) begin  // 防止填充非必要区域
            if(cnt_ascii_num<8) begin //根据当前展示数目（字符坐标）给出展示位置（屏幕坐标）,先定横向x
                start_x <= 7'd48+(cnt_ascii_num<<3); //(16x)8的字模，注意是横屏，160/2-8x8/2=48
            end else start_x <= 7'd1+(((cnt_ascii_num-'d8)%20)<<3); //前面+1是因为字符贴左边界太近于是进行调整
        end else start_x <= 1'd0;
    else
        start_x <= 'd0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        start_y <= 'd0;
    else if(init_done)
        if(cnt_ascii_num<CHAR_NUM) begin  // 防止填充非必要区域
            if(cnt_ascii_num<8) start_y <= 'd0;
            else start_y <= 7'd16+(((cnt_ascii_num-7'd8)/7'd20+1'd1)<<4);
        end else start_y <= 1'd0;
    else
        start_y <= 'd0;

endmodule