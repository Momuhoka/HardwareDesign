module end_time_show (
    input sys_clk,  // 100Mhz
    input sys_rst_n,
    input [11:0] music_len,

    output reg [15:0] end_time // 音乐长度 
);

// 利用时钟计算显示时间
reg [9:0] pre_end_time;
reg [9:0] end_time_count;
reg [15:0] end_time_temp;

// 进度计算
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // 总进度
        pre_end_time <= 10'd0;
        end_time_count <= 10'd0;
        end_time_temp <= 16'd0;
        end_time <= 16'd0;
    end else begin
        if(pre_end_time==(music_len>>2)) begin
            if(end_time_count==pre_end_time) begin
                end_time <= end_time_temp;
            end else begin
                end_time_count <= end_time_count+1'd1;
                if(end_time_temp[3:0]==4'd9) begin
                    if(end_time_temp[7:4]==4'd5) begin
                        if(end_time_temp[11:8]==4'd9) begin
                            end_time_temp <= end_time_temp+12'h6A7;
                        end else end_time_temp <= end_time_temp+8'hA7;
                    end else end_time_temp <= end_time_temp+4'h7;
                end else end_time_temp <= end_time_temp+4'h1;
            end
        end else begin
            pre_end_time <= (music_len>>2);
            end_time_count <= 10'd0;
            end_time_temp <= 16'd0;
        end
    end
end

endmodule