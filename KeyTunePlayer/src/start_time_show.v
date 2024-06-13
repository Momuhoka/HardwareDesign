module start_time_show (
    input sys_clk,  // 100Mhz
    input sys_rst_n,
    input [11:0] ram_addr_out,

    output reg [15:0] start_time // RAM数据地址
);

// 利用时钟计算显示时间
reg [9:0] pre_start_time;
reg [9:0] start_time_count;
reg [15:0] start_time_temp;

// 进度计算
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
         // 当前进度
        pre_start_time <= 10'd0;
        start_time_count <= 10'd0;
        start_time_temp <= 16'd0;
        start_time <= 16'd0;
    end else begin
        if(pre_start_time==(ram_addr_out>>2)) begin
            if(start_time_count==pre_start_time) begin
                start_time <= start_time_temp;
            end else begin
                start_time_count <= start_time_count+1'd1;
                if(start_time_temp[3:0]==4'd9) begin
                    if(start_time_temp[7:4]==4'd5) begin
                        if(start_time_temp[11:8]==4'd9) begin
                            start_time_temp <= start_time_temp+12'h6A7;
                        end else start_time_temp <= start_time_temp+8'hA7;
                    end else start_time_temp <= start_time_temp+4'h7;
                end else start_time_temp <= start_time_temp+4'h1;
            end
        end else begin
            // 进度清零
            pre_start_time <= (ram_addr_out>>2);
            start_time_count <= 10'd0;
            start_time_temp <= 16'd0;
        end
    end
end

endmodule