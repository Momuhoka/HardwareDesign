module speaker_play (
    input sys_clk,
    input sys_rst_n,

    input [15:0] speaker_data, // 播放数据
    input play, // 播放标志

    output reg speaker
);

localparam SPESTEP = 'd1000; // 100Mhz时钟除以1000倍

// 播放音调计数器
reg [18:0] cnt;
// 分频计数器
reg [9:0] speaker_count;

// 播放状态
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        speaker_count <= 10'd0;
        cnt <= 19'd0;
        speaker <= 1'b0;
    end else begin
        if(play) begin
            if(speaker_count==SPESTEP-1) begin // 100_000Hz
                if(cnt==speaker_data-1) begin
                    speaker <= ~speaker;
                    cnt <= 19'd0;
                end else cnt <= cnt + 1'b1;
                speaker_count <= 10'd0;
            end else speaker_count <= speaker_count + 1'd1;
        end else begin
            speaker <= 1'b0;
            speaker_count <= 10'd0;
            cnt <= 19'd0;
        end
    end
end

endmodule