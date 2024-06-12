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

    output reg IsPause, // 歌曲暂停
    output reg IsCycle, // 单曲循环

    output reg [15:0] start_time, // RAM数据地址
    output reg [15:0] end_time, // 音乐长度 
    output reg [4:0] process, // 音乐进度

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
localparam PLAY = 4'b0111;
localparam MUSIC = 4'b1000;
localparam CHANPRO=4'b1010;
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
            KEYBOARD : state <= (keyboard_data>4'h0&&keyboard_data<4'h8) ? PLAY : FIN;
            PLAY : state <= !IsPressed ? STATE0 : PLAY; // 按钮不松一直播放
            // 音乐播放模式
            MUSIC : state <= wrt_en ? STATE0 : 
                             (keyboard_data==4'h4||keyboard_data==4'h6) ? CHANPRO :
                              FIN;
            CHANPRO : state <= !IsPressed ? STATE0 : CHANPRO; // 按钮不松一直加速\减速
            // 结束
            FIN : state <= !IsPressed ? STATE0 : FIN; // 监控按钮是否松开
        endcase
    end
end

localparam SPESTEP = 'd1000; // 100Mhz时钟除以1000倍
localparam PROSTEP = 'd25_000_000; // 0.25秒
localparam ADDRDELTA = 12'd4095;  // 歌曲地址差
localparam ADDRMAX = 12'd4095;  // 歌曲最大地址

// 数据地址
reg [6:0] note_addr;
// 读取的数据
wire [15:0] note_data;
wire [15:0] ram_data_out;
reg [15:0] ram_data_in;
 // RAM数据地址
reg [11:0] ram_addr;
// 音乐长度
reg [11:0] music_len;
// ram写使能信号
reg wrt_en;
// 多个存储的等待计时器
reg [2:0] wait_count;
// 初始音乐地址
reg [11:0] base_addr;
// 音乐地址
reg [11:0] music_addr;
// 音乐音符值，也是音符rom的地址
wire [7:0] music_data;
// 音乐播放计时器0.25s一节拍
reg [24:0] music_count;
// 针对按键的切歌信号
reg [1:0] music_next;

// 21C调音符地址，00填充，8位一个地址，64位切换高中低
localparam NOTE21_ADDRS = 'h00_5F_5D_5B_59_58_56_54_00_53_51_4F_4D_4C_4A_48_00_47_45_43_41_40_3E_3C;

// 存储note的prom
notes128_pROM notes128_prom(
    .dout(note_data), //output [15:0] dout
    .clk(sys_clk), //input clk
    .oce(1'b0), //input oce
    .ce(1'b1), //input ce
    .reset(~sys_rst_n), //input reset
    .ad(note_addr) //input [6:0] ad
);

// 存储music的prom
music_pROM music_prom(
    .dout(music_data), //output [7:0] dout
    .clk(sys_clk), //input clk
    .oce(1'b0), //input oce
    .ce(1'b1), //input ce
    .reset(~sys_rst_n), //input reset
    .ad(music_addr) //input [11:0] ad
);

// 暂存当前播放音乐的sram
music_SP music_sp(
    .dout(ram_data_out), //output [15:0] dout
    .clk(sys_clk), //input clk
    .oce(1'b0), //input oce
    .ce(1'b1), //input ce
    .reset(~sys_rst_n), //input reset
    .wre(wrt_en), //input wre
    .ad(ram_addr), //input [11:0] ad
    .din(ram_data_in) //input [15:0] din
);

// 利用时钟计算显示时间
reg [9:0] pre_start_time;
reg [9:0] start_time_count;
reg [9:0] pre_end_time;
reg [9:0] end_time_count;
reg [9:0] process_count; // 进度条计数

// 播放音调计数器
reg [18:0] cnt;
// 分频计数器
reg [9:0] speaker_count;

// 状态判断部分
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // 默认中音
        scale <= 4'd1; 
        // 默认地址
        note_addr <= 7'd69; // 69标准音440Hz
        // 默认无音频
        IsPause <= 1'b1; // 默认暂停
        // ram初始值
        wrt_en <= 1'b1; // 先写后读
        wait_count <= 3'd0;
        ram_data_in <= 16'd0;
        ram_addr <= 12'd0;
        // 音乐初始值
        base_addr <= 12'd0;
        music_addr <= 12'd0;
        music_len <= 12'd0;
        music_count <= 25'd0;
        // 切换音乐
        music_next <= 2'b00;
        // 播放部分
        speaker_count <= 10'd0;
        cnt <= 19'd0;
        speaker <= 1'b0;
    end else if(init_done) begin
        if(mode==1'b0) begin // 电子琴模式
            IsPause <= 1'b1; // 电子琴模式不播放音乐
            if(state==PRESSED) begin
                case(keyboard_data)
                    4'hA : scale <= 2'd0;
                    4'hB : scale <= 2'd1;
                    4'hC : scale <= 2'd2;
                    default : begin 
                        if((keyboard_data>4'h0)&&(keyboard_data<4'h8)) begin
                            // 前7位有效
                            note_addr <= NOTE21_ADDRS>>(scale*64+(keyboard_data-1)*8)&7'h7F;
                        end
                    end
                endcase
            end else if(state==PLAY) begin // 播放部分
                if(speaker_count==SPESTEP-1) begin // 100_000Hz
                    if(cnt==note_data-1) begin
                        speaker <= ~speaker;
                        cnt <= 19'd0;
                    end else cnt <= cnt + 1'b1;
                    speaker_count <= 10'd0;
                end else speaker_count <= speaker_count + 1'd1;
            end else begin
                speaker_count <= 10'd0;
                cnt <= 19'd0;
                speaker <= 1'b0;
            end
        end else begin // 音乐播放模式
            // 状态切换
            if(state==PRESSED) begin
                case(keyboard_data)
                    4'h1 : IsCycle <= ~IsCycle; // 按键1切换循环状态
                    4'h2 : music_next <= 2'b10; // 高位表示需要切歌，0前一首，1后一首
                    4'h5 : IsPause <= ~IsPause; // 按键5切换暂停状态
                    4'h8 : music_next <= 2'b11; // 高位表示需要切歌，0前一首，1后一首
                endcase
            end else begin
                // 音乐播放
                if(wrt_en==1'b1) begin // 写
                    if(wait_count==3'd0) begin // 更新音乐地址
                        music_addr <= base_addr + ram_addr; // 基础地址为4096整数倍，为了实现切歌因此没有紧凑地址
                        wait_count <= wait_count+1'b1;
                    end else if(wait_count==3'd2) begin // 隔一个时钟取出音乐值
                        if(music_data!=8'hFF) begin // 8位高位为1表示结束
                            // 前7位有效
                            note_addr <= music_data&7'h7F; // 音乐值就是音符地址0-127
                        end else begin
                            music_len <= ram_addr; // 更新音乐长度
                            ram_addr <= 12'd0; // 第一个地址为1，因为地址0由于时钟关系无效
                            wrt_en <= 1'b0; // 读使能
                            // 计数器清空
                            wait_count <= 3'd0;
                        end
                        wait_count <= wait_count+1'b1;
                    end else if(wait_count==3'd4) begin // 隔一个时钟即可取出音符值，然后音乐长度加一
                        ram_data_in <= note_data; // 更新ram数据
                        ram_addr <= ram_addr + 1'd1;
                        wait_count <= 3'd0;
                    end else wait_count <= wait_count+1'b1;
                end else begin // 读
                    // 播放判断参考矩阵键盘
                    if(!IsPause) begin
                        if(music_count==PROSTEP-1) begin
                            music_count <= 25'd0;
                            if((music_next!=2'b00)||(ram_addr==music_len)) begin // 是否需要切歌
                                case(music_next) // 按键切歌
                                    2'b10 : base_addr <= base_addr==12'd0 ? ADDRMAX-ADDRDELTA : base_addr-ADDRDELTA-1'd1;
                                    2'b11 : base_addr <= base_addr==ADDRMAX-ADDRDELTA ? 12'd0 : base_addr+ADDRDELTA+1'd1;
                                    default : begin // 播放完毕切歌
                                        if(!IsCycle) begin // 非单曲循环则下一首
                                            base_addr <= base_addr==ADDRMAX-ADDRDELTA ? 12'd0 : base_addr+ADDRDELTA+1'd1;
                                        end else base_addr <= base_addr; 
                                    end
                                endcase
                                wrt_en <= 1'b1; // 写使能，重新初始化读歌曲
                                ram_addr <= 12'd0; // 地址置0
                                music_next <= 2'b00; // 切歌标志置0
                            end else begin // 播放进度
                                if(state==CHANPRO) begin // 存在按键加减进度的情况
                                    case(keyboard_data)
                                        4'h4 : ram_addr <= (ram_addr>'d8) ? ram_addr-12'd8 : 12'd0;
                                        4'h6 : ram_addr <= (ram_addr<music_len-'d9) ? ram_addr+12'd8 : music_len-12'd1;
                                    endcase
                                end else begin // 正常进度加一
                                    ram_addr <= ram_addr+12'd1;
                                end
                            end
                        end else music_count <= music_count+1'd1;
                        // 播放部分
                        if(music_count==25'd0) begin
                            music_count <= music_count+1'd1;
                            speaker_count <= 10'd0;
                            cnt <= 19'd0;
                        end else if(speaker_count==SPESTEP-1) begin // 100_000Hz
                            if(cnt==ram_data_out-1) begin
                                speaker <= ~speaker;
                                cnt <= 19'd0;
                            end else cnt <= cnt + 1'b1;
                            speaker_count <= 10'd0;
                        end else speaker_count <= speaker_count + 1'd1;
                    end else speaker <= 1'b0; // 暂停不播放
                end
            end
        end
    end
end


// 播放状态
//always @(posedge sys_clk or negedge sys_rst_n) begin
//    if(!sys_rst_n) begin
//        speaker_count <= 10'd0;
//        cnt <= 19'd0;
//        speaker <= 1'b0;
//    end else if(init_done) begin
//        if((mode==1'd0&&state==PLAY)||(mode==1'd1&&music_count!=25'd0)) begin
//            if(speaker_count==SPESTEP-1) begin // 100_000Hz
//                if(cnt==speaker_data-1) begin
//                    speaker <= ~speaker;
//                    cnt <= 19'd0;
//                end else cnt <= cnt + 1'b1;
//                speaker_count <= 10'd0;
//            end else speaker_count <= speaker_count + 1'd1;
//        end else begin
//            speaker_count <= 10'd0;
//            cnt <= 19'd0;
//            speaker <= 1'b0;
//        end
//    end
//end

endmodule