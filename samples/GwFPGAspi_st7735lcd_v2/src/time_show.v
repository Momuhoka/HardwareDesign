module time_show (
    input sys_clk,  // 100Mhz
    input sys_rst_n,
    input [11:0] ram_addr_out,
    input [11:0] music_len,

    output reg [15:0] start_time, // RAM数据地址
    output reg [15:0] end_time // 音乐长度 
);

// 利用时钟计算显示时间
reg [9:0] start_time_count;
reg [15:0] start_time_temp;
reg [9:0] end_time_count;
reg [15:0] end_time_temp;

// 状态机
reg [2:0] state;
localparam STATE0 = 3'b000;
localparam STATE1 = 3'b001;
localparam SINIT = 3'b010;
localparam EINIT = 3'b011;
localparam SCOUNT = 3'b100;
localparam ECOUNT = 3'b101;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        state <= STATE0;
    end else begin
        case(state) 
            STATE0 : state <= start_time_count==(ram_addr_out>>2) ? STATE1 : SINIT;
            STATE1 : state <= end_time_count==(music_len>>2) ? STATE0 : EINIT;
            SINIT : state <= SCOUNT;
            EINIT : state <= ECOUNT;
            SCOUNT : state <= start_time_count==(ram_addr_out>>2) ? STATE0 : SCOUNT;
            ECOUNT : state <= end_time_count==(music_len>>2) ? STATE0 : ECOUNT;
        endcase
    end
end

// 进度计算
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
         // 当前进度
        start_time_count <= 10'd0;
        start_time_temp <= 16'd0;
        start_time <= 16'd0;
    end else begin
        if(state==SINIT) begin
            // 进度清零
            start_time_count <= 10'd0;
            start_time_temp <= 16'd0;
        end else if(state==SCOUNT) begin
            start_time_count <= start_time_count+1'd1;
            if(start_time_temp[3:0]==4'd9) begin
                if(start_time_temp[7:4]==4'd5) begin
                    if(start_time_temp[11:8]==4'd9) begin
                        start_time_temp <= start_time_temp+12'h6A7;
                    end else start_time_temp <= start_time_temp+8'hA7;
                end else start_time_temp <= start_time_temp+4'h7;
            end else start_time_temp <= start_time_temp+4'h1;
        end else start_time <= start_time_temp;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        // 总进度
        end_time_count <= 10'd0;
        end_time_temp <= 16'd0;
        end_time <= 16'd0;
    end else begin
        if(state==EINIT) begin
            end_time_count <= 10'd0;
            end_time_temp <= 16'd0;
        end else if(state==ECOUNT) begin
            end_time_count <= end_time_count+1'd1;
            if(end_time_temp[3:0]==4'd9) begin
                if(end_time_temp[7:4]==4'd5) begin
                    if(end_time_temp[11:8]==4'd9) begin
                        end_time_temp <= end_time_temp+12'h6A7;
                    end else end_time_temp <= end_time_temp+8'hA7;
                end else end_time_temp <= end_time_temp+4'h7;
            end else end_time_temp <= end_time_temp+4'h1;
        end else end_time <= end_time_temp;
    end
end

endmodule