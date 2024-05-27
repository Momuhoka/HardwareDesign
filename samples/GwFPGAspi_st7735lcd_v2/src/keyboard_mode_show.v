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
新增两行表示示例乐谱:
SAMPLE: >M< ????????
-> 0 1 2 3 1 6 1 3 6
68+20*2=108个字符


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
    input       wire    [1:0]   scale               , // 接收当前音调数据
    
    output      wire            en_size             ,
    output      reg             show_char_flag      ,
    output      reg     [7:0]   ascii_num           ,
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
localparam CHAR_NUM = 7'd108;
// 符号 < - >
localparam SPACE = 'd0;
localparam LINE = 'd45-'d32;
localparam LEFT_MORE = 'd60-'d32;
localparam RIGHT_MORE = 'd62-'d32;

// 青花瓷
localparam SAMPLE_QHC = 'o35321235321212122335356532112532132355235321323551212233535653211253213235523532132355; // 音符0-7使用8进制，翻转存储
localparam QHC_LEN = 'd86; 
localparam QHC_NAME = 'h20_20_51_48_43_20_20_20; // 八个字符ascii码，转为16进制
// C418
localparam SAMPLE_C418 = 'o1642624616426122146622146611353645123213111353645123213112214662214665366332765617113536451232131113536451232131;
localparam C418_LEN = 'd112;
localparam C418_NAME = 'h20_20_43_34_31_38_20_20; //20是32的16进制，对应空格
// 葬花
localparam SAMPLE_ZH = 'o5612322352332363233235713332265633656335365636712612333226563365633536563;
localparam ZH_LEN = 'd73;
localparam ZH_NAME = 'h20_20_20_5A_48_20_20_20;
// 千本樱
localparam SAMPLE_QBY = 'o3335422216656211234321213443521665621123424565654421222611212225441222245656654212216121225442122;
localparam QBY_LEN = 'd97;
localparam QBY_NAME = 'h20_20_51_42_59_20_20_20;


// 对应数据反色
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        background_color <= 16'hAF7D;
        front_color <= 16'h0000;
    //TEXT_AREA
    end else if(init_done) begin // 初始化完毕才开始运行
        if(cnt_ascii_num<68) begin 
            if(cnt_ascii_num>7 && (cnt_ascii_num-8)%20<3) begin // LOW/MID/HIG
                background_color <= 16'h815B;
                front_color <= 16'hFFFF;
            end else if(keyboard_data>=1 && keyboard_data<=7 &&
                        keyboard_data==((cnt_ascii_num-12-20*scale)>>1)+1 &&
                        IsPressed) begin // 1-7按键触发时上色
                background_color <= 16'hFA20;
                front_color <= 16'hFFFF;
            end else begin // 正常显示
                background_color <= 16'hAF7D;
                front_color <= 16'h0000;
            end
        // MENU_AREA
        end else if(cnt_ascii_num<75) begin // SAMPLE
            background_color <= 16'hF810;
            front_color <= 16'hFFFF;
        end else if(cnt_ascii_num==77) begin // L/M/H
            background_color <= 16'h815B;
            front_color <= 16'hFFFF;
        end else if(cnt_ascii_num>79 && cnt_ascii_num<88) begin // 曲目名
            background_color <= 16'h97F9;
            front_color <= 16'h0000;
        end else if(cnt_ascii_num==91) begin // 第一个节拍
            background_color <= 16'hBFD9;
            front_color <= 16'h815B;
        end else begin // 正常显示
            background_color <= 16'hE73F;
            front_color <= 16'h0000;
        end
    end else begin
        background_color <= 16'hAF7D;
        front_color <= 16'h0000;
    end
end

reg [1:0] sample;
reg [349:0] sample_score;
reg [6:0] sample_len;
reg [63:0] sample_name;

reg [349:0] process_score;
reg [6:0] process_len;

reg [1:0] state;
localparam STATE0 = 2'b00;
localparam STATE1 = 2'b01;
localparam STATE2 = 2'b10;
localparam FIN = 2'b11;
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n) begin
        state <= STATE0;
        sample_score <= SAMPLE_QHC;
        sample_len <= QHC_LEN;
        sample_name <= QHC_NAME;
        process_score <= SAMPLE_QHC;
        process_len <= 7'd0;
    end
    else if(init_done) begin
        case(state)
            STATE0 : state <= IsPressed ? STATE1 : STATE0;
            STATE1 : begin
                if(keyboard_data==process_score[2:0]) begin
                    if(process_len < sample_len) begin
                        process_len <= process_len+1'd1;
                        process_score <= (process_score>>3);
                    end else begin
                        process_len <= 7'd0;
                        process_score <= sample_score;
                    end
                    state <= FIN;
                end else if(keyboard_data==4'hF || keyboard_data==4'hE) begin
                    sample <= keyboard_data==4'hF ? sample-1'd1 : sample+1'd1;
                    state <= STATE2;
                end
            end
            STATE2 : begin
                process_len <= 7'd0;
                if(sample==2'd0) begin
                    sample_score <= SAMPLE_QHC;
                    sample_len <= QHC_LEN;
                    sample_name <= QHC_NAME;
                    process_score <= SAMPLE_QHC;
                end else if(sample==2'd1) begin
                    sample_score <= SAMPLE_C418;
                    sample_len <= C418_LEN;
                    sample_name <= C418_NAME;
                    process_score <= SAMPLE_C418;
                end else if(sample==2'd2) begin
                    sample_score <= SAMPLE_ZH;
                    sample_len <= ZH_LEN;
                    sample_name <= ZH_NAME;
                    process_score <= SAMPLE_ZH;
                end else begin
                    sample_score <= SAMPLE_QBY;
                    sample_len <= QBY_LEN;
                    sample_name <= QBY_NAME;
                    process_score <= SAMPLE_QBY;
                end
                state <= FIN;
            end
            FIN : state <= !IsPressed ? STATE0 : FIN;
        endcase
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

// 显示字符加一
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt_ascii_num <= 'd0;
    // 查看lcd_show_char部分可以发现，使用状态机转换使得show_char_done的信号只有一个时钟周期
    else if(init_done && show_char_done)         //展示数目的计数器：初始化完成和上一个char展示完成后，数目+1
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
            68 : ascii_num <= 'd83-'d32; // S
            69 : ascii_num <= 'd65-'d32; // A
            70 : ascii_num <= 'd77-'d32; // M
            71 : ascii_num <= 'd80-'d32; // P
            72 : ascii_num <= 'd76-'d32; // L
            73 : ascii_num <= 'd69-'d32; // E
            74 : ascii_num <= 'd58-'d32; // :
            76 : ascii_num <= RIGHT_MORE; // >
            78 : ascii_num <= LEFT_MORE; // <
            88 : ascii_num <= LINE; // -
            89 : ascii_num <= RIGHT_MORE; // >
            default: begin
                if(cnt_ascii_num<27 && cnt_ascii_num[0]==1) begin // 第三行LOW> 1 2 3 4 5 6 7 ?
                    ascii_num <= ((cnt_ascii_num-7'd13)>>1)+7'd49-7'd32;    // 简单换算(cnt_ascii_num-13)/2=0->1的ascii码为49
                end else if(cnt_ascii_num<47 && cnt_ascii_num[0]==1) begin // 第四行LOW> 1 2 3 4 5 6 7 ?
                    ascii_num <= ((cnt_ascii_num-7'd33)>>1)+7'd49-7'd32; 
                end else if(cnt_ascii_num<67 && cnt_ascii_num[0]==1) begin // 第五行LOW> 1 2 3 4 5 6 7 ?
                    ascii_num <= ((cnt_ascii_num-7'd53)>>1)+7'd49-7'd32; 
                end else if(cnt_ascii_num==77) begin // 显示当前音调
                    if(scale==4'h0) ascii_num<='d76-'d32; // L
                    else if(scale==4'h1) ascii_num<='d77-'d32; // M
                    else ascii_num<='d72-'d32; // H
                end else if(cnt_ascii_num>79 && cnt_ascii_num<88) begin // 乐谱名
                    ascii_num <= sample_name[(('d88-cnt_ascii_num)<<3)-1 -: 8]-8'd32; // 16位一个值，反向
                end else if(cnt_ascii_num>89 && cnt_ascii_num[0]==1) begin
                    if(((cnt_ascii_num-'d90)>>1)+process_len<sample_len)
                        ascii_num <= process_score[((cnt_ascii_num-'d90)>>1)*3+:3]+'d48-'d32; // 0的ascii码为48，3位一个值，反向
                    else ascii_num <= SPACE;
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
            else if(cnt_ascii_num<68)
                start_y <= 7'd16+(((cnt_ascii_num-7'd8)/7'd20+1'd1)<<4);
            else start_y <= 7'd80+(((cnt_ascii_num-7'd68)/7'd20+1'd1)<<4);
        end else start_y <= 1'd0;
    else
        start_y <= 'd0;

endmodule