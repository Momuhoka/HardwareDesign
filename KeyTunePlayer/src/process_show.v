module process_show (
    input sys_clk,  // 100Mhz
    input sys_rst_n,
    input [11:0] ram_addr_out,
    input [11:0] music_len,

    output reg [4:0] process // 音乐进度
);

// 利用时钟计算显示进度条
reg [9:0] pre_start_time;
reg [11:0] process_count; // 进度条计数
reg [4:0] process_temp;

// 进度条计算
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin // 进度条清零     
        pre_start_time <= 10'd0;
        process_temp <= 5'd0;
        process_count <= 12'd0;
        process <= 5'd0;
    end else begin
        if(pre_start_time==(ram_addr_out>>2)) begin
            if(process_count>=ram_addr_out) begin
                process <= process_temp;
            end else begin
                process_temp <= process_temp+1'd1;
                process_count <= process_count+(music_len>>4);
            end
        end else begin
            // 进度清零
            pre_start_time <= (ram_addr_out>>2);
            process_temp <= 5'd0;
            process_count <= 12'd0;
        end
    end
end

endmodule