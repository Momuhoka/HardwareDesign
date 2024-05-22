// ==============================================================================================
//                                          电子琴解码模块
// ==============================================================================================

module speaker_music(
    input clk,  // 100Mhz
    input sys_rst_n,

    input IsPressed,    // 按钮更新
    input [3:0]keyboard_data,

    output reg [3:0] scale, // 输出当前音调
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
reg [18:0] MUSIC[2:0][6:0];
initial begin
    MUSIC[0][0]=19'd382219; MUSIC[1][0]=19'd187882; MUSIC[2][0]=19'd95557;
    MUSIC[0][1]=19'd340518; MUSIC[1][1]=19'd170262; MUSIC[2][1]=19'd85131;
    MUSIC[0][2]=19'd303370; MUSIC[1][2]=19'd151688; MUSIC[2][2]=19'd75843;
    MUSIC[0][3]=19'd286344; MUSIC[1][3]=19'd143172; MUSIC[2][3]=19'd71586;
    MUSIC[0][4]=19'd255109; MUSIC[1][4]=19'd127553; MUSIC[2][4]=19'd63776;
    MUSIC[0][5]=19'd227273; MUSIC[1][5]=19'd113636; MUSIC[2][5]=19'd56818;
    MUSIC[0][6]=19'd202478; MUSIC[1][6]=19'd101239; MUSIC[2][6]=19'd50620;
end

// 当前音
reg [18:0] music;
// 播放音调计数器
reg [18:0] cnt;

// 对应音频部分
always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // 默认中音
        scale <= 4'd1;   
    end
    else if(keyboard_data>=4'hA&&keyboard_data<=4'hC) begin
            scale <= keyboard_data-4'hA;
    end
end

always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // 默认无音频
        music <= 19'd0;   
    end
    else if(IsPressed && keyboard_data>4'h0&&keyboard_data<4'h8) begin
            music <= MUSIC[scale][keyboard_data];
    end else music <= 19'd0;
end

// 更新播放器状态
always @(posedge clk or negedge sys_rst_n) begin
    // 置位或者没有music时清空
    if(!sys_rst_n) begin
        cnt <= 19'd0;
        speaker <= 1'b0;
    end
    else if(music==19'd0) begin
        speaker <= 1'b0;
    end
    else if(cnt<(music>>1)-1) begin // 右移一位除以2
        cnt <= cnt + 1'b1;
    end
    else begin
        cnt <= 19'd0;
        speaker <= ~speaker;
    end
end

endmodule