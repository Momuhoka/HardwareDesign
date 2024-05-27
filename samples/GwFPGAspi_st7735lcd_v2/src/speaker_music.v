// ==============================================================================================
//                                          电子琴解码模块
// ==============================================================================================

module speaker_music(
    input sys_clk,  // 100Mhz
    input sys_rst_n,

    input wire init_done, // 屏幕初始化完毕

    input IsPressed,    // 按钮更新
    input [3:0] keyboard_data,

    input wire mode, // 当前选定的模式

    output reg [1:0] scale, // 输出当前音调
    output reg speaker
);

// 低音(hz)  中音(hz)  高音(hz)
// 261.63   532.25   1046.50
// 293.67   587.33   1174.66
// 329.63   659.25   1318.51
// 349.23   698.46   1396.92
// 391.99   783.99   1567.98
// 440.00   880.00   1760.00
// 493.88   987.76   1975.52
// 有21种频率
reg [18:0] NOTE[2:0][6:0];
initial begin
    NOTE[0][0]=19'd382219; NOTE[1][0]=19'd187882; NOTE[2][0]=19'd95557;
    NOTE[0][1]=19'd340518; NOTE[1][1]=19'd170262; NOTE[2][1]=19'd85131;
    NOTE[0][2]=19'd303370; NOTE[1][2]=19'd151688; NOTE[2][2]=19'd75843;
    NOTE[0][3]=19'd286344; NOTE[1][3]=19'd143172; NOTE[2][3]=19'd71586;
    NOTE[0][4]=19'd255109; NOTE[1][4]=19'd127553; NOTE[2][4]=19'd63776;
    NOTE[0][5]=19'd227273; NOTE[1][5]=19'd113636; NOTE[2][5]=19'd56818;
    NOTE[0][6]=19'd202478; NOTE[1][6]=19'd101239; NOTE[2][6]=19'd50620;
end

// 状态机
reg [2:0] state;
localparam STATE0 = 3'b000;
localparam PRESSED = 3'b001;
localparam KEYBOARD = 3'b010;
localparam CHANNOTE = 3'b011;
localparam SCALE = 3'b100;
localparam PLAY = 3'b101;
localparam MUSIC = 3'b110;
localparam FIN = 3'b111;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        state <= STATE0;
    // 显示屏初始化完毕
    end else if(init_done) begin
        case(state)
            STATE0 : state <= IsPressed ? PRESSED : STATE0; // 监控按钮是否按下
            PRESSED : state <= !mode ? KEYBOARD : MUSIC; // 切换到对应的模式状态
            // 电子琴模式
            KEYBOARD : state <= (keyboard_data>4'h0&&keyboard_data<4'h8) ? CHANNOTE :
                                (keyboard_data>=4'hA&&keyboard_data<=4'hC) ? SCALE :
                                 FIN;
            CHANNOTE : state <= PLAY; // 更新一次数据后进入播放模式
            SCALE : state <= FIN;
            PLAY : state <= !IsPressed ? STATE0 : PLAY; // 按钮不松一直播放
            // 音乐播放模式
            MUSIC : state <= FIN; // 暂时没做
            // 结束
            FIN : state <= !IsPressed ? STATE0 : FIN; // 监控按钮是否松开
        endcase
    end
end

// 当前音
reg [18:0] music;
// 播放音调计数器
reg [18:0] cnt;

// 状态判断部分
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // 默认中音
        scale <= 4'd1;   
        // 默认无音频
        music <= 19'd0;   
    end else if(init_done) begin
        if(state==CHANNOTE)
            music <= NOTE[scale][keyboard_data];
        else if(state==SCALE) begin
            case(keyboard_data)
                4'hA : scale <= 2'd0;
                4'hB : scale <= 2'd1;
                4'hC : scale <= 2'd2;
            endcase
        end
    end
end

// 更新播放器状态
always @(posedge sys_clk or negedge sys_rst_n) begin
    // 置位或者没有music时清空
    if(!sys_rst_n) begin
        cnt <= 19'd0;
        speaker <= 1'b0;
    end else if(init_done) begin
        if(state==PLAY) begin
            if(cnt<(music>>1)-1) begin // 右移一位除以2
                cnt <= cnt + 1'b1;
            end else begin
                cnt <= 19'd0;
                speaker <= ~speaker;
            end
        end else begin
            cnt <= 19'd0;
            speaker <= 1'b0;
        end
    end
end

endmodule