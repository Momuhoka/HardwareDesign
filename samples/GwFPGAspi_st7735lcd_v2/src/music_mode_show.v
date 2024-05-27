//----------------------------------------------------------------------------------------
// File name: music_mode_show
// Descriptions: 音乐模式的显示模块
//----------------------------------------------------------------------------------------
//****************************************************************************************//
/*
在屏幕上显示字符串
第一行中间显示“Music”共5个字符；
M   u   s   i   c
77-117-115-105-99

倒数第二行20字符
TIME >00:00 / 00:00<
最后一行20
|> @S ====----------
或者
|| #C =====---------

总共5+20*2=45个字符
cnt_ascii_num  0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
   char        T   I   M   E   >   0   :   /   <   |   @   S   =   -   #   C
 ascii码       84  73  77  69  62  48  58  47  60 124  64  83  61  45  35  67 = 库内码+32 
*/

module music_mode_show
(
    input       wire            sys_clk             ,
    input       wire            sys_rst_n           ,
    input       wire            init_done           ,
    input       wire            show_char_done      ,
    
    input       wire            IsPressed           , // 接收按钮状态信息
    input       wire    [3:0]   keyboard_data       , // 接收矩阵键盘数据
    input       wire    [1:0]   scale               , // 接收当前音调数据
    
    output      wire            en_size             ,
    output      reg             show_char_flag      ,
    output      reg     [7:0]   ascii_num           ,
    output      reg     [8:0]   start_x             ,
    output      reg     [8:0]   start_y             ,

    output      reg    [15:0]  background_color     , // 自行输出背景色
    output      reg    [15:0]  front_color           // 自行输出字体颜色
);      
//****************** Parameter and Internal Signal *******************//        
reg     [1:0]   cnt1;            //展示 行 计数器？！？3行故cnt1值只需0，1，2
//也可能是延迟计数器，init_done为高电平后，延迟3拍，产生show_char_flag高脉冲
reg     [5:0]   cnt_ascii_num;

// 总字符数
localparam CHAR_NUM = 6'd45;

reg IsPause; // 歌曲暂停
reg IsRelay; // 单曲循环
reg pre_IsPressed; // 上一按钮状态，用于抽取上升沿
// 播放模式切换
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        pre_IsPressed <= 1'b0;  // 上一按钮状态
        IsPause <= 1'b0;    // 是否暂停
        IsRelay <= 1'b0;    // 是否循环
    end else if(init_done) begin // 初始化完毕才开始运行
        if(!pre_IsPressed && IsPressed) begin
            case(keyboard_data)
                4'h5 : IsPause <= ~IsPause; // 按键5切换暂停状态
                4'h1 : IsRelay <= ~IsRelay; // 按键1切换循环状态
            endcase
        end
        pre_IsPressed <= IsPressed;
    end
end

// 对应数据颜色
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        background_color <= 16'hE73F;
        front_color <= 16'h0000;
    end else if(init_done) begin // 初始化完毕才开始运行
        if(cnt_ascii_num<'d5) begin
            background_color <= 16'hAF7D;
            front_color <= 16'h0000;
        end else if(cnt_ascii_num<'d9 && cnt_ascii_num>'d4) begin
            background_color <= 16'h815B;
            front_color <= 16'hFFFF;
        end else if(cnt_ascii_num=='d25 || cnt_ascii_num=='d26) begin
            if(IsPause) begin
                background_color <= 16'hFA20;
                front_color <= 16'hFFFF;
            end else begin
                background_color <= 16'h2E65;
                front_color <= 16'hFFFF;
            end
        end else if(cnt_ascii_num=='d28 || cnt_ascii_num=='d29) begin
            if(IsRelay) begin
                background_color <= 16'hF892;
                front_color <= 16'hFFFF;
            end else begin
                background_color <= 16'hFB08;
                front_color <= 16'hFFFF;
            end
        end else begin // 正常显示
            background_color <= 16'hE73F;
            front_color <= 16'h0000;
        end
    end else begin
        background_color <= 16'hE73F;
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
        cnt_ascii_num <= (cnt_ascii_num==CHAR_NUM-1) ? 1'd0 : cnt_ascii_num + 1'b1;   //等于是展示字符的坐标（单位：个字符
    else
        cnt_ascii_num <= cnt_ascii_num;

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        ascii_num <= 'd0;
    else if(init_done)
        case(cnt_ascii_num)         //根据当前展示数目（字符坐标）给出展示内容（ascii码）
//          M   u   s   i   c
//          77-117-115-105-99
//  char        T   I   M   E   >   0   :   /   <   |   @   S   =   -   #   C
//ascii码       84  73  77  69  62  48  58  47  60 124  64  83  61  45  35  67 = 库内码+32 
//          TIME >00:00 / 00:00<
//          |> @S ====----------
//          || #C =====---------
            0 : ascii_num <= 'd77-'d32; // M
            1 : ascii_num <= 'd117-'d32; // U
            2 : ascii_num <= 'd115-'d32;  // S
            3 : ascii_num <= 'd105-'d32; // I
            4 : ascii_num <= 'd99-'d32; // C
            5 : ascii_num <= 'd84-'d32; // T
            6 : ascii_num <= 'd73-'d32; // I
            7 : ascii_num <= 'd77-'d32; // M
            8 : ascii_num <= 'd69-'d32; // E
            9 : ascii_num <= 'd0; // 空格
            10 : ascii_num <= 'd62-'d32; // >
            13 : ascii_num <= 'd58-'d32; // :
            16 : ascii_num <= 'd0; // 空格
            17 : ascii_num <= 'd47-'d32; // 斜杠
            18 : ascii_num <= 'd0; // 空格
            21 : ascii_num <= 'd58-'d32; // :
            24 : ascii_num <= 'd60-'d32; // <
            25 : ascii_num <= 'd124-'d32; // |
            26 : ascii_num <= IsPause ? 'd124-'d32 : 'd62-'d32; // 取决于播放模式
            27 : ascii_num <= 'd0; // 空格
            28 : ascii_num <= IsRelay ? 'd35-'d32 : 'd64-'d32; // 取决于循环模式
            29 : ascii_num <= IsRelay ? 'd67-'d32 : 'd83-'d32; // 取决于循环模式
            30 : ascii_num <= 'd0; // 空格
            default: begin
                if(cnt_ascii_num<25) begin  // 数字位
                    ascii_num <= 'd48-'d32;    // 临时置数字0
                end else ascii_num <= 'd45-'d32;  // 进度条暂时为-
            end
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        start_x <= 'd0;
    else if(init_done) 
        if(cnt_ascii_num<CHAR_NUM) begin  // 防止填充非必要区域
            if(cnt_ascii_num<5) begin //根据当前展示数目（字符坐标）给出展示位置（屏幕坐标）,先定横向x
                start_x <= 9'd60+(cnt_ascii_num<<3); //(16x)8的字模，注意是横屏，160/2-8x8/2=48
            end else start_x <= (((cnt_ascii_num-6'd5)%20)<<3);
        end else start_x <= 'd0;
    else
        start_x <= 'd0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        start_y <= 'd0;
    else if(init_done)
        if(cnt_ascii_num<CHAR_NUM) begin  // 防止填充非必要区域
            if(cnt_ascii_num<5) start_y <= 'd0;
            else start_y <= 9'd80+(((cnt_ascii_num-6'd5)/6'd20+1'd1)<<4);                                                                          
        end else start_y <= 'd0;
    else
        start_y <= 'd0;

endmodule