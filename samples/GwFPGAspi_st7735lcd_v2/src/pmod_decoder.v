// ==============================================================================================
// 										参考官方示例Decoder代码
// ==============================================================================================

module pmod_decoder(
    input sys_clk,  // 100MHz
    input sys_rst_n,
    input wire [3:0] Row,    // 行
    output reg [3:0] Col,  // 列
    output reg [3:0] DecodeOut, // 输出数据
    output reg IsPressed    // 是否按下
);

// 暂存按钮状态
reg [2:0] nopressed;
// 计数器
reg [18:0] count;
// 检测时间4ms
localparam COUNT_COL0 = 19'd100_000;
localparam COUNT_COL1 = 19'd200_000;
localparam COUNT_COL2 = 19'd300_000;
localparam COUNT_COL3 = 19'd400_000;
localparam DELTA = 4'd8;

// 检测键盘按键部分
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        count <= 19'd0;
        nopressed <= 3'd4;
    end
    else begin
        if(count<COUNT_COL0-1) begin
            // 差不多有1ms时间检测是否按下
            if(nopressed!=3'd4) IsPressed <= 1'b1;
            else IsPressed <= 1'b0;
            count <= count + 1'b1;
        end 
        else if(count==COUNT_COL0-1) begin
            nopressed <= 3'd0;
            Col <= 4'b0111;
            count <= count + 1'b1;
        end
        else if(count==COUNT_COL0+DELTA-1) begin
            case (Row)
                4'b0111: DecodeOut <= 4'b0001;  //1
                4'b1011: DecodeOut <= 4'b0100;  //4
                4'b1101: DecodeOut <= 4'b0111;  //7
                4'b1110: DecodeOut <= 4'b0000;  //0
                default: nopressed <= nopressed + 1'b1;
            endcase
            count <= count + 1'b1;
        end
        else if(count==COUNT_COL1-1) begin
            Col <= 4'b1011;
            count <= count + 1'b1;
        end
        else if(count==COUNT_COL1+DELTA-1) begin
            case (Row)
                4'b0111: DecodeOut <= 4'b0010;  //2
                4'b1011: DecodeOut <= 4'b0101;  //5
                4'b1101: DecodeOut <= 4'b1000;  //8
                4'b1110: DecodeOut <= 4'b1111;  //F
                default: nopressed <= nopressed + 1'b1;
            endcase
            count <= count + 1'b1;
        end
        else if(count==COUNT_COL2-1) begin
            Col <= 4'b1101;
            count <= count + 1'b1;
        end
        else if(count==COUNT_COL2+DELTA-1) begin
            case (Row)
                4'b0111: DecodeOut <= 4'b0011;  //3
                4'b1011: DecodeOut <= 4'b0110;  //6
                4'b1101: DecodeOut <= 4'b1001;  //9
                4'b1110: DecodeOut <= 4'b1110;  //E
                default: nopressed <= nopressed + 1'b1;
            endcase
            count <= count + 1'b1;
        end
        else if(count==COUNT_COL3-1) begin
            Col <= 4'b1110;
            count <= count + 1'b1;
        end
        else if(count==COUNT_COL3+DELTA-1) begin
            case (Row)
                4'b0111: DecodeOut <= 4'b1010;  //A
                4'b1011: DecodeOut <= 4'b1011;  //B
                4'b1101: DecodeOut <= 4'b1100;  //C
                4'b1110: DecodeOut <= 4'b1101;  //D
                default: nopressed <= nopressed + 1'b1;
            endcase
            count <= 19'd0;
        end
        else begin
            count <= count + 1'b1;
        end
    end
end

endmodule

