// ==============================================================================================
// 										    LED显示模块
//                                参考官方示例DisplayController模块
// ==============================================================================================

module LED_Show(
    input clk,
    input sys_rst_n,    // 置位按钮
    input wire [3:0] data,

    output reg [5:0] led
);

always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 6'b000000;   // led灯共阳极
    else begin
        case (data)
            4'h0 : led <= 6'b111111;    // 0
            4'h1 : led <= 6'b111110;    // 1
            4'h2 : led <= 6'b111101;    // 2
            4'h3 : led <= 6'b111100;    // 3
            4'h4 : led <= 6'b111011;    // 4
            4'h5 : led <= 6'b111010;    // 5
            4'h6 : led <= 6'b111001;    // 6
            4'h7 : led <= 6'b111000;    // 7
            4'h8 : led <= 6'b110111;    // 8
            4'h9 : led <= 6'b110110;    // 9
            4'hA : led <= 6'b110101;    // A
            4'hB : led <= 6'b110100;    // B
            4'hC : led <= 6'b110011;	// C
            4'hD : led <= 6'b110010;	// D
            4'hE : led <= 6'b110001;	// E
            4'hF : led <= 6'b110000;	// F
            default : led <= 6'b000000;
        endcase
	end
end

endmodule
