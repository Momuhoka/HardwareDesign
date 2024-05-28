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
//reg [18:0] NOTE[2:0][6:0];
//initial begin
//    NOTE[0][0]=19'd382219; NOTE[1][0]=19'd187882; NOTE[2][0]=19'd95557;
//    NOTE[0][1]=19'd340518; NOTE[1][1]=19'd170262; NOTE[2][1]=19'd85131;
//    NOTE[0][2]=19'd303370; NOTE[1][2]=19'd151688; NOTE[2][2]=19'd75843;
//    NOTE[0][3]=19'd286344; NOTE[1][3]=19'd143172; NOTE[2][3]=19'd71586;
//    NOTE[0][4]=19'd255109; NOTE[1][4]=19'd127553; NOTE[2][4]=19'd63776;
//    NOTE[0][5]=19'd227273; NOTE[1][5]=19'd113636; NOTE[2][5]=19'd56818;
//    NOTE[0][6]=19'd202478; NOTE[1][6]=19'd101239; NOTE[2][6]=19'd50620;
//end

// 状态机
reg [3:0] state;
localparam STATE0 = 4'b0000;
localparam PRESSED = 4'b0001;
localparam KEYBOARD = 4'b0010;
localparam CHANNOTE = 4'b0011;
localparam WAIT = 4'b0100;
localparam READDATA = 4'b0101;
localparam SCALE = 4'b0110;
localparam PLAY = 4'b0111;
localparam MUSIC = 4'b1000;
localparam FIN = 4'b1111;
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
            // 需要更新note，地址计算后等待一个时钟周期
            CHANNOTE : state <= WAIT; 
            // 等待一个时钟周期后读取值
            WAIT : state <= READDATA;
            READDATA : state <= PLAY;
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
reg [15:0] note;
// 播放音调计数器
reg [18:0] cnt;
// 分频计数器
reg [9:0] count;

localparam STEP = 'd1000; // 100Mhz时钟除以100倍
// 数据地址
reg [6:0] rom_addr;
// 读取的数据
wire [15:0] note_data;

// 存储note的prom
notes128_pROM notes128_prom(
    .dout(note_data), //output [15:0] dout
    .clk(sys_clk), //input clk
    .oce(1'b0), //input oce
    .ce(1'b1), //input ce
    .reset(~sys_rst_n), //input reset
    .ad(rom_addr) //input [6:0] ad
);

// 21C调音符地址，00填充，8位一个地址，64位切换高中低
localparam NOTE21_ADDRS = 'h00_5F_5D_5B_59_58_56_54_00_53_51_4F_4D_4C_4A_48_00_47_45_43_41_40_3E_3C;

// 状态判断部分
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // 默认中音
        scale <= 4'd1; 
        // 默认地址
        rom_addr <= 7'd69; // 69标准音440Hz
        // 默认无音频
        note <= 16'd0;   
    end else if(init_done) begin
        if(state==CHANNOTE) begin
            // 前7位有效
            rom_addr <= NOTE21_ADDRS>>(scale*64+(keyboard_data-1)*8)&7'h7F;
        end else if(state==READDATA)
            note <= note_data;
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
        count <= 10'd0; // 分频计数器
        cnt <= 19'd0; // 音调计数器
        speaker <= 1'b0;
    end else if(init_done) begin
        if(state==PLAY) begin
            if(count<STEP-1) begin // 100_000Hz
                count <= count + 1'd1;
            end else begin
                count <= 10'd0;
                if(cnt<note-1) begin // 右移一位除以2
                    cnt <= cnt + 1'b1;
                end else begin
                    cnt <= 19'd0;
                    speaker <= ~speaker;
                end
            end
        end else begin
            count <= 10'd0;
            cnt <= 19'd0;
            speaker <= 1'b0;
        end
    end
end

endmodule