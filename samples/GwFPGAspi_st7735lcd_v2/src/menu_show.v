//----------------------------------------------------------------------------------------
// File name: menu_show
// Descriptions: 菜单显示模块
//----------------------------------------------------------------------------------------
//****************************************************************************************//
/*
电子琴: 
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

音乐播放: 
第一行中间显示“Music”共5个字符；
M   u   s   i   c
77-117-115-105-99
中央显示
[1] : [SEQUE|CYCLE]
[5] : [|>]--[PAUSE]
[2]-[8] : [|<]-[>|] 
[4]-[6] : [<<]-[>>]
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

module menu_show(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire init_done,
    input wire show_char_done,
    
    input wire IsPressed, // 接收按钮状态信息
    input wire [3:0] keyboard_data, // 接收矩阵键盘数据
    input wire [1:0] scale, // 接收当前音调数据
    
    // 音乐播放的模式切换
    input wire IsPause, // 歌曲暂停
    input wire IsCycle, // 单曲循环

    input wire [15:0] start_time,
    input wire [15:0] end_time,
    input wire [4:0] process,

    input wire mode, // 当前选定的模式
    
    output wire en_size,
    output reg show_char_flag,
    output reg [7:0] ascii_num,
    output reg [8:0] start_x,
    output reg [8:0] start_y,

    output reg [15:0] background_color, // 自行输出背景色
    output reg [15:0] front_color  // 自行输出字体颜色

);      

//****************** Parameter and Internal Signal *******************//        
reg     [1:0]   cnt1;            //展示 行 计数器？！？3行故cnt1值只需0，1，2
//也可能是延迟计数器，init_done为高电平后，延迟3拍，产生show_char_flag高脉冲
reg     [6:0]   cnt_ascii_num;

// 总字符数
localparam K_CHAR_NUM = 7'd108;
localparam M_CHAR_NUM = 7'd125;
// 符号 < - > : | /
localparam SPACE = 'd0; // 空格
localparam LINE = 'd45-'d32; // -
localparam EQUAL = 'd61-'d32; // =
localparam LEFT_MORE = 'd60-'d32; // <
localparam RIGHT_MORE = 'd62-'d32; // >
localparam COLON = 'd58-'d32; // :
localparam VER_BAR = 'd124-'d32; // |
localparam SLASH = 'd47-'d32; // /
localparam LSB = 'd91-'d32; // [
localparam RSB = 'd93-'d32; // ]

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
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        background_color <= 16'hFFFF;
        front_color <= 16'h0000;
    //TEXT_AREA
    end else if(init_done) begin // 初始化完毕才开始运行
        // mode0为电子琴模式
        if(mode==1'b0) begin 
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
            end else if(cnt_ascii_num>75 && cnt_ascii_num<79) begin // L/M/H
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
        // mode1为音乐播放模式
        end else begin 
            if(cnt_ascii_num<'d5) begin // MUSIC
                background_color <= 16'hAF7D;
                front_color <= 16'h0000;
            end else if(cnt_ascii_num<'d85) begin
                if(cnt_ascii_num<'d8 && cnt_ascii_num>'d4) begin // [1]
                    if(keyboard_data==4'h1 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d28 && cnt_ascii_num>'d24) begin // [5]
                    if(keyboard_data==4'h5 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d48 && cnt_ascii_num>'d44) begin // [2]
                    if(keyboard_data==4'h2 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d52 && cnt_ascii_num>'d48) begin // [8]
                    if(keyboard_data==4'h8 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d58 && cnt_ascii_num>'d55) begin // [|<]
                    if(keyboard_data==4'h2 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d63 && cnt_ascii_num>'d60) begin // [>|]
                    if(keyboard_data==4'h8 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d68 && cnt_ascii_num>'d64) begin // [4]
                    if(keyboard_data==4'h4 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d72 && cnt_ascii_num>'d68) begin // [6]
                    if(keyboard_data==4'h6 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d78 && cnt_ascii_num>'d75) begin // [<<]
                    if(keyboard_data==4'h4 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d83 && cnt_ascii_num>'d80) begin // [>>]
                    if(keyboard_data==4'h6 && IsPressed) begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h0679;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d17 && cnt_ascii_num>'d11) begin // SEQUE
                    if(!IsCycle) begin
                        background_color <= 16'hFB08;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'hAF7D;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d23 && cnt_ascii_num>'d17) begin // CYCLE
                    if(IsCycle) begin
                        background_color <= 16'hF892;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'hAF7D;
                        front_color <= 16'h0000;
                    end
                end else if(cnt_ascii_num<'d43 && cnt_ascii_num>'d37) begin // || 或者 |>
                    if(IsPause) begin
                        background_color <= 16'hFA20;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end
                end else if(cnt_ascii_num=='d32 || cnt_ascii_num=='d33) begin // PAUSE 或者 PALY~
                    if(IsPause) begin
                        background_color <= 16'hFA20;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end
                end else begin // 正常显示
                    background_color <= 16'hAF7D;
                    front_color <= 16'h0000;
                end
            end else begin
                if(cnt_ascii_num>'d84 && cnt_ascii_num<'d89) begin
                    background_color <= 16'h815B;
                    front_color <= 16'hFFFF;
                end else if(cnt_ascii_num=='d105 || cnt_ascii_num=='d106) begin
                    if(IsPause) begin
                        background_color <= 16'hFA20;
                        front_color <= 16'hFFFF;
                    end else begin
                        background_color <= 16'h2E65;
                        front_color <= 16'hFFFF;
                    end
                end else if(cnt_ascii_num=='d107 || cnt_ascii_num=='d108) begin
                    if(IsCycle) begin
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
            end
        end
    end else begin
        background_color <= 16'hFFFF;
        front_color <= 16'h0000;
    end
end

// 示例乐谱进度
reg [349:0] process_score;
reg [6:0] process_len;

// 状态机
reg [2:0] state;
localparam STATE0 = 3'b000;
localparam PRESSED = 3'b001;
localparam KEYBOARD = 3'b010;
localparam PROCESS = 3'b011;
localparam CHANSAM = 3'b100;
localparam NEWSAM = 3'b101;
localparam MUSIC = 3'b110;
localparam FIN = 3'b111;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        state <= STATE0;
    end
    else if(init_done) begin
        case(state)
            STATE0 : state <= IsPressed ? PRESSED : STATE0; // 监控按钮是否按下
            PRESSED : state <= !mode ? KEYBOARD : MUSIC; // 切换到对应的模式状态
            // 电子琴模式
            KEYBOARD : state <= (keyboard_data==process_score[2:0]) ? PROCESS : 
                                (keyboard_data==4'hF || keyboard_data==4'hE) ? CHANSAM :
                                 FIN;
            PROCESS : state <= FIN; // 监控乐谱是否需要进一位
            CHANSAM : state <= NEWSAM; // 监控sample的值是否需要更新
            NEWSAM : state <= FIN; // 用一个时钟周期更新乐谱
            // 音乐播放模式
            MUSIC : state <= FIN; // 用一个时钟周期切换播放状态
            // 结束
            FIN : state <= !IsPressed ? STATE0 : FIN; // 监控按钮是否松开
        endcase
    end
end

// 电子琴的示例乐谱
reg [1:0] sample;
reg [349:0] sample_score;
reg [6:0] sample_len;
reg [63:0] sample_name;

always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        sample_score <= SAMPLE_QHC;
        sample_len <= QHC_LEN;
        sample_name <= QHC_NAME;
        process_score <= SAMPLE_QHC;
        process_len <= 7'd0;
    end else if(init_done) begin
        // 电子琴部分
        if(state==PROCESS) begin
            // 按对乐谱第一个值，乐谱进一位
            if(process_len==(sample_len-1)) begin
                process_len <= 7'd0;
                process_score <= sample_score;
            end else begin
                process_len <= process_len+1'd1;
                process_score <= (process_score>>3);
            end 
        // F/E切换乐谱
        end else if(state==CHANSAM) begin
            sample <= keyboard_data==4'hF ? sample-1'd1 : sample+1'd1;
        // STATE1状态用于更新乐谱，一定比sample更新晚一个时钟周期
        end else if(state==NEWSAM) begin
            // 进度清零
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
//         音乐盒部分
//        end else if(state==MUSIC) begin
//            case(keyboard_data)
//                4'h5 : IsPause <= ~IsPause; // 按键5切换暂停状态
//                4'h1 : IsCycle <= ~IsCycle; // 按键1切换循环状态
//            endcase
        end
    end
end

//******************************* Main Code **************************//
//en_size为1时调用字体大小为16x8，为0时调用字体大小为12x6；
assign  en_size = 1'b1;

//产生输出信号show_char_flag，写到第2行！？就让show_char_flag产生一个高脉冲给后面模块
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt1 <= 'd0;
    else if(show_char_flag)
        cnt1 <= 'd0;
    else if(init_done && cnt1 < 'd3)
        cnt1 <= cnt1 + 1'b1;
    else
        cnt1 <= cnt1;
end
        
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        show_char_flag <= 1'b0;
    else if(cnt1 == 'd2)
        show_char_flag <= 1'b1;
    else
        show_char_flag <= 1'b0;
end


// 显示字符加一
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_ascii_num <= 'd0;
    // 查看lcd_show_char部分可以发现，使用状态机转换使得show_char_done的信号只有一个时钟周期
    else if(init_done && show_char_done) //展示数目的计数器：初始化完成和上一个char展示完成后，数目+1
        if(mode==1'b0) // 电子琴
            cnt_ascii_num <= (cnt_ascii_num<K_CHAR_NUM-1) ? cnt_ascii_num + 1'b1 : 1'd0;   //等于是展示字符的坐标（单位：个字符）
        else // 音乐播放
            cnt_ascii_num <= (cnt_ascii_num<M_CHAR_NUM-1) ? cnt_ascii_num + 1'b1 : 1'd0;
    else
        cnt_ascii_num <= cnt_ascii_num;
end


always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        ascii_num <= 'd0;
    else if(init_done) begin
        // 电子琴
        if(mode==1'b0) begin
            case(cnt_ascii_num) //根据当前展示数目（字符坐标）给出展示内容（ascii码）
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
                74 : ascii_num <= COLON; // :
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
                        if((((cnt_ascii_num-'d90)>>1)+process_len)<sample_len)
                            ascii_num <= process_score[((cnt_ascii_num-'d90)>>1)*3+:3]+'d48-'d32; // 0的ascii码为48，3位一个值，反向
                        else ascii_num <= SPACE;
                    end else ascii_num <= SPACE;
                end
            endcase
        // 音乐播放
        end else begin
            case(cnt_ascii_num) //根据当前展示数目（字符坐标）给出展示内容（ascii码）
                //          M   u   s   i   c
                //          77-117-115-105-99
                //          中央显示
                //      [1] : [SEQUE|CYCLE] 
                //      [5] : [|>]--[PAUSE] 
                //      [2]-[8] : [|<]-[>|] 
                //      [4]-[6] : [<<]-[>>] 
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

                6 : ascii_num <= 'd49-'d32; // 1
                12 : ascii_num <= 'd83-'d32; // S
                13 : ascii_num <= 'd69-'d32; // E
                14 : ascii_num <= 'd81-'d32; // Q
                15 : ascii_num <= 'd85-'d32; // U
                16 : ascii_num <= 'd69-'d32; // E
                17 : ascii_num <= VER_BAR; // |
                18 : ascii_num <= 'd67-'d32; // C
                19 : ascii_num <= 'd89-'d32; // Y
                20 : ascii_num <= 'd67-'d32; // C
                21 : ascii_num <= 'd76-'d32; // L
                22 : ascii_num <= 'd69-'d32; // E

                26 : ascii_num <= 'd53-'d32; // 5
                32 : ascii_num <= VER_BAR; // |
                33 : ascii_num <= IsPause ? 'd124-'d32 : 'd62-'d32; // 取决于播放模式
                35 : ascii_num <= LINE; // -
                36 : ascii_num <= LINE; // -
                38 : ascii_num <= 'd80-'d32; // P
                39 : ascii_num <= IsPause ? 'd65-'d32 : 'd76-'d32; // A 或者 L
                40 : ascii_num <= IsPause ? 'd85-'d32 : 'd65-'d32; // U 或者 A
                41 : ascii_num <= IsPause ? 'd83-'d32 : 'd89-'d32; // S 或者 Y
                42 : ascii_num <= IsPause ? 'd69-'d32 : 'd126-'d32; // E 或者 ~

                46 : ascii_num <= 'd50-'d32; // 2
                48 : ascii_num <= LINE; // -
                50 : ascii_num <= 'd56-'d32; // 8
                56 : ascii_num <= VER_BAR; // |
                57 : ascii_num <= LEFT_MORE; // <
                59 : ascii_num <= LINE; // -
                61 : ascii_num <= RIGHT_MORE; // >
                62 : ascii_num <= VER_BAR; // |

                66 : ascii_num <= 'd52-'d32; // 4
                68 : ascii_num <= LINE; // -
                70 : ascii_num <= 'd54-'d32; // 6
                76 : ascii_num <= LEFT_MORE; // <
                77 : ascii_num <= LEFT_MORE; // <
                79 : ascii_num <= LINE; // -
                81 : ascii_num <= RIGHT_MORE; // >
                82 : ascii_num <= RIGHT_MORE; // >

                85 : ascii_num <= 'd84-'d32; // T
                86 : ascii_num <= 'd73-'d32; // I
                87 : ascii_num <= 'd77-'d32; // M
                88 : ascii_num <= 'd69-'d32; // E
                90 : ascii_num <= RIGHT_MORE; // >
                91 : ascii_num <= start_time[15:12]+'d48-'d32;
                92 : ascii_num <= start_time[11:8]+'d48-'d32;
                93 : ascii_num <= COLON; // :
                94 : ascii_num <= start_time[7:4]+'d48-'d32;
                95 : ascii_num <= start_time[3:0]+'d48-'d32;
                97 : ascii_num <= SLASH; // /
                99 : ascii_num <= end_time[15:12]+'d48-'d32;
                100 : ascii_num <= end_time[11:8]+'d48-'d32;
                101 : ascii_num <= COLON; // :
                102 : ascii_num <= end_time[7:4]+'d48-'d32;
                103 : ascii_num <= end_time[3:0]+'d48-'d32;
                104 : ascii_num <= LEFT_MORE; // <
                105 : ascii_num <= VER_BAR; // |
                106 : ascii_num <= IsPause ? 'd124-'d32 : 'd62-'d32; // 取决于播放模式
                107 : ascii_num <= IsCycle ? 'd35-'d32 : 'd64-'d32; // 取决于循环模式
                108 : ascii_num <= IsCycle ? 'd67-'d32 : 'd83-'d32; // 取决于循环模式
                default: begin
                    if((cnt_ascii_num==5)||(cnt_ascii_num==25)||(cnt_ascii_num==45)||(cnt_ascii_num==65)||
                       (cnt_ascii_num==11)||(cnt_ascii_num==31)||(cnt_ascii_num==49)||(cnt_ascii_num==69)||
                       (cnt_ascii_num==37)||(cnt_ascii_num==55)||(cnt_ascii_num==60)||(cnt_ascii_num==75)||
                       (cnt_ascii_num==80)) 
                        ascii_num <= LSB;
                    else if((cnt_ascii_num==7)||(cnt_ascii_num==27)||(cnt_ascii_num==47)||(cnt_ascii_num==67)||
                           (cnt_ascii_num==51)||(cnt_ascii_num==71)||(cnt_ascii_num==23)||(cnt_ascii_num==43)||
                           (cnt_ascii_num==63)||(cnt_ascii_num==83)||(cnt_ascii_num==34)||(cnt_ascii_num==58)||
                           (cnt_ascii_num==78)) 
                        ascii_num <= RSB;
                    else if((cnt_ascii_num==9)||(cnt_ascii_num==29)||(cnt_ascii_num==53)||(cnt_ascii_num==73))
                        ascii_num <= COLON;
                    else if(cnt_ascii_num>108) begin
                        // 有16个长度
                        if((cnt_ascii_num-109)<process) ascii_num <= EQUAL; // 已播放进度条为 = 
                        else ascii_num <= LINE; // 未播放进度条为 -
                    end else ascii_num <= SPACE;
                end
            endcase
        end
    end
end

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        start_x <= 'd0;
    else if(init_done) begin
        if(mode==1'b0) begin
            if(cnt_ascii_num<K_CHAR_NUM) begin  // 防止填充非必要区域
                if(cnt_ascii_num<8) begin //根据当前展示数目（字符坐标）给出展示位置（屏幕坐标）,先定横向x
                    start_x <= 7'd48+(cnt_ascii_num<<3); //(16x)8的字模，注意是横屏，160/2-8x8/2=48
                end else start_x <= 7'd1+(((cnt_ascii_num-'d8)%20)<<3); //前面+1是因为字符贴左边界太近于是进行调整
            end else start_x <= 'd160; // 丢出屏幕外
        end else begin
            if(cnt_ascii_num<M_CHAR_NUM) begin  // 防止填充非必要区域
            if(cnt_ascii_num<5) begin //根据当前展示数目（字符坐标）给出展示位置（屏幕坐标）,先定横向x
                start_x <= 9'd60+(cnt_ascii_num<<3); //(16x)8的字模，注意是横屏，160/2-8x8/2=48
            end else if(cnt_ascii_num<85) start_x <= 3'd6+(((cnt_ascii_num-6'd5)%20)<<3);
            else start_x <= (((cnt_ascii_num-6'd5)%20)<<3);
        end else start_x <= 'd160; // 丢出屏幕外
        end
    end else start_x <= 'd0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        start_y <= 'd0;
    else if(init_done) begin
        if(mode==1'b0) begin
            if(cnt_ascii_num<K_CHAR_NUM) begin  // 防止填充非必要区域
                if(cnt_ascii_num<8) start_y <= 'd0;
                else if(cnt_ascii_num<68)
                    start_y <= 7'd16+(((cnt_ascii_num-7'd8)/7'd20+1'd1)<<4);
                else start_y <= 7'd80+(((cnt_ascii_num-7'd68)/7'd20+1'd1)<<4);
            end else start_y <= 'd128; // 丢出屏幕外
        end else begin
            if(cnt_ascii_num<M_CHAR_NUM) begin  // 防止填充非必要区域
                if(cnt_ascii_num<5) start_y <= 'd0;
                else if(cnt_ascii_num<85) start_y <= 6'd8+(((cnt_ascii_num-6'd5)/6'd20+1'd1)<<4);     
                else start_y <= 9'd80+(((cnt_ascii_num-7'd85)/6'd20+1'd1)<<4);  
            end else start_y <= 'd128; // 丢出屏幕外
        end
    end else start_y <= 'd0;

endmodule