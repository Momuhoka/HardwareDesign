// ==============================================================================================
// 										    LED显示模块
//                                参考官方示例DisplayController模块
// ==============================================================================================

module LED_Show(
    input clk,
    input sys_rst_n,    // 置位按钮

    input IsPressed,
    input wire [3:0] data,

    output reg [5:0] led
);

always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 6'b000000;   // led灯共阳极
    else begin
        led[5] <= ~IsPressed;
        case (data)
            4'h0 : led[4:0] <= 5'b11111;    // 0
            4'h1 : led[4:0] <= 5'b11110;    // 1
            4'h2 : led[4:0] <= 5'b11101;    // 2
            4'h3 : led[4:0] <= 5'b11100;    // 3
            4'h4 : led[4:0] <= 5'b11011;    // 4
            4'h5 : led[4:0] <= 5'b11010;    // 5
            4'h6 : led[4:0] <= 5'b11001;    // 6
            4'h7 : led[4:0] <= 5'b11000;    // 7
            4'h8 : led[4:0] <= 5'b10111;    // 8
            4'h9 : led[4:0] <= 5'b10110;    // 9
            4'hA : led[4:0] <= 5'b10101;    // A
            4'hB : led[4:0] <= 5'b10100;    // B
            4'hC : led[4:0] <= 5'b10011;	// C
            4'hD : led[4:0] <= 5'b10010;	// D
            4'hE : led[4:0] <= 5'b10001;	// E
            4'hF : led[4:0] <= 5'b10000;	// F
            default : led <= 6'b000000;
        endcase
	end
end

endmodule
