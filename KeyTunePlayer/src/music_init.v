module music_init(
    input sys_clk,  // 100Mhz
    input sys_rst_n,

    input IsPressed,    // 按钮更新
    input [3:0] keyboard_data,

    input wire mode, // 当前选定的模式

    output reg [1:0] scale, // 输出当前音调

    output reg IsPause, // 歌曲暂停
    output reg IsCycle, // 单曲循环

    output reg [11:0] ram_addr_out, // RAM数据地址
    output reg [11:0] music_len, // 音乐长度 

    output reg [15:0] speaker_data, // 播放数据
    output reg play // 播放标志
);

localparam PROSTEP = 'd25_000_000; // 0.25秒
localparam ADDRDELTA = 14'd4095;  // 歌曲地址差
localparam ADDRMAX = 14'd12287;  // 歌曲最大地址


localparam STATE0 = 4'b0000;
localparam PRESSED = 4'b0001;
localparam WAIT = 4'b0010;
localparam FIN = 4'b1111;

// 音乐盒状态机
reg [3:0] key_state;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        key_state <= STATE0;
    end else if(mode==1'b0) begin
        case(key_state)
            STATE0 : key_state <= IsPressed ? PRESSED : STATE0; // 监控按钮是否按下
            PRESSED : key_state <= WAIT;
            WAIT : key_state <= FIN;
            FIN : key_state <= !IsPressed ? STATE0 : FIN;
        endcase
    end else key_state <= STATE0;
end

// 切歌状态机
reg [3:0] next_state;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        next_state <= STATE0;
    end else if(mode==1'b1) begin
        case(next_state)
            STATE0 : next_state <= (ram_addr_out==(music_len-1)) ? WAIT : 
                                   IsPressed ? PRESSED : // 监控按钮是否按下
                                   STATE0; 
            WAIT : next_state <= STATE0;
            PRESSED : next_state <= FIN;
            FIN : next_state <= !IsPressed ? STATE0 : FIN;
        endcase
    end else next_state <= STATE0;
end


reg wrt_en;
reg [1:0] IsNext; // 切歌标志
reg [2:0] wait_count;
reg [13:0] music_addr;
wire [7:0] music_data;
reg [6:0] key_note_addr;
reg [6:0] music_note_addr;
wire [15:0] note_data;
reg [13:0] base_addr;
reg [11:0] ram_addr_in;
reg [15:0] ram_data_in;
reg [1:0] music_next;
reg [24:0] music_count;
wire [15:0] ram_data_out;

// 21C调音符地址，00填充，8位一个地址，64位切换高中低
localparam NOTE21_ADDRS = 'h00_5F_5D_5B_59_58_56_54_00_53_51_4F_4D_4C_4A_48_00_47_45_43_41_40_3E_3C;

wire [6:0] note_addr;
assign note_addr = (wrt_en==1'b1) ? music_note_addr : key_note_addr;

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
    .ad(music_addr) //input [13:0] ad
);

wire [11:0] ram_addr;
assign ram_addr = (wrt_en==1'b1) ? ram_addr_in : ram_addr_out;

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

// 电子琴
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // 状态切换
        scale <= 2'd1;
        key_note_addr <= 7'd0;
    end else if(key_state==PRESSED) begin
        case(keyboard_data)
            4'hA : scale <= 2'd0;
            4'hB : scale <= 2'd1;
            4'hC : scale <= 2'd2;
            default : begin 
                if((keyboard_data>4'h0)&&(keyboard_data<4'h8)) begin
                    // 前7位有效
                    key_note_addr <= NOTE21_ADDRS>>(scale*64+(keyboard_data-1)*8)&7'h7F;
                end
            end
        endcase
    end 
end

// 音乐盒
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // 状态切换
        IsCycle <= 1'b0;
        IsPause <= 1'b1;
        IsNext <= 2'b00;
    end else if(next_state==PRESSED) begin
        case(keyboard_data)
            4'h1 : IsCycle <= ~IsCycle; // 按键1切换循环状态
            4'h2 : IsNext <= 2'b10; // 高位1则需要切歌，低位0表示上一首
            4'h5 : IsPause <= ~IsPause; // 按键5切换暂停状态
            4'h8 : IsNext <= 2'b11; // 高位1则需要切歌，低位1表示下一首
            4'hD : IsPause <= 1'b1; // 切换菜单必定暂停
        endcase
    end else if(next_state==WAIT) begin
        if(IsCycle) IsNext <= 2'b01; // 单曲循环不切歌但是需要刷新歌曲
        else IsNext <= 2'b11; // 播放完毕，下一首
    end else IsNext <= 2'b00; // 恢复正常播放
end

// 数据读取延迟计数器
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        wait_count <= 3'd0;
    end else if(wrt_en==1'b1) begin
        wait_count <= wait_count+1'd1;
    end else if(wrt_en==1'b0) begin
        wait_count <= 3'd0;
    end
end

// 音乐盒数据处理
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        wrt_en <= 1'b1; // 默认先写
        // 地址数据
        music_note_addr <= 7'd0;
        music_len <= 12'd0;
        music_addr <= 13'd0;
        ram_addr_in <= 12'd0;
        ram_data_in <= 16'd0;
        ram_addr_out <= 12'd0;
    end else if(wrt_en==1'b1) begin // 写
        if(wait_count==3'd0) begin // 更新音乐地址
            music_addr <= base_addr + ram_addr_in; // 基础地址为4096整数倍，为了实现切歌因此没有紧凑地址
        end else if(wait_count==3'd3) begin // 隔一个时钟即可取出音符值，然后音乐长度加一
            if(music_data!=8'hFF) begin // 8位高位为1表示结束
                // 前7位有效
                music_note_addr <= music_data[6:0]; // 音乐值就是音符地址0-127
            end else begin
                music_len <= ram_addr_in; // 更新音乐长度
                ram_addr_in <= 12'd0;
                wrt_en <= 1'b0; // 读取歌曲完毕
            end
        end else if(wait_count==3'd6) begin // 取出音乐值
            ram_data_in <= note_data; // 更新ram数据
            ram_addr_in <= ram_addr_in + 1'd1;
        end
    end else if(wrt_en==1'b0) begin // 读
        if(IsNext==2'b00) begin // 00表示正常播放
            if(!IsPause) begin
                if(music_count==25'd0) begin // 歌曲播放加一
                    if(IsPressed) begin // 存在按键加减进度的情况
                        case(keyboard_data)
                            4'h4 : ram_addr_out <= (ram_addr_out>'d16) ? ram_addr_out-12'd16 : 12'd0;
                            4'h6 : ram_addr_out <= (ram_addr_out<music_len-'d17) ? ram_addr_out+12'd16 : music_len-12'd2;
                            default : ram_addr_out <= ram_addr_out+12'd1; // 正常进度加一
                        endcase
                    end else begin // 正常进度加一
                        ram_addr_out <= ram_addr_out+12'd1;
                    end
                end
            end
        end else begin
            wrt_en <= 1'b1; // 重新初始化读歌曲
            ram_addr_out <= 12'd0; // 地址清零
        end
    end
end



always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        music_count <= 25'd0;
        base_addr <= 13'd0;
    end else if(mode==1'b1) begin
        if(IsNext==2'b00) begin
            if(!IsPause) begin
                music_count <= (music_count==(PROSTEP-1)) ? 25'd0 : music_count+1'd1;
            end
        end else begin 
            music_count <= 25'd0; // 重新计数
            case(IsNext) // 切歌
                2'b10 : base_addr <= base_addr==12'd0 ? ADDRMAX-ADDRDELTA : base_addr-ADDRDELTA-1'd1;
                2'b11 : base_addr <= base_addr==ADDRMAX-ADDRDELTA ? 12'd0 : base_addr+ADDRDELTA+1'd1;
                2'b01 : base_addr <= base_addr;
            endcase
        end
    end
end

// 决定播放器的状态
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // speaker是否播放
        play <= 1'b0;
    end else if(mode==1'b0) begin
        if(key_state==FIN) begin
            if(keyboard_data>0&&keyboard_data<8) play <= 1'b1;
            else play <= 1'b0;
        end else play <= 1'b0;
    end else if(mode==1'b1) begin
        if(!IsPause) begin  
            if(music_count==25'd1) play <= 1'b0; // 用于清空cnt播放下一音调
            else play <= 1'b1;
        end else play <= 1'b0;
    end
end

// 决定播放器的数据
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // speaker数据
        speaker_data <= 16'd0;
    end else if(mode==1'b0) begin
        speaker_data <= note_data;
    end else if(mode==1'b1) begin
        speaker_data <= ram_data_out;
    end
end

endmodule
