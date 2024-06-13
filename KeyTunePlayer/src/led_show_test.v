// ==============================================================================================
// 										    LED显示模块
//                                参考官方示例DisplayController模块
// ==============================================================================================

module led_show_test(
    input sys_clk,
    input sys_rst_n,    // 置位按钮

    input IsPressed,
    input wire [3:0] keyboard_data,

    output reg [4:0] led
);

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 5'b00000;   // led灯共阳极
    else begin
        led[4] <= ~IsPressed;
        case (keyboard_data)
            4'h0 : led[3:0] <= 4'b1111;    // 0
            4'h1 : led[3:0] <= 4'b1110;    // 1
            4'h2 : led[3:0] <= 4'b1101;    // 2
            4'h3 : led[3:0] <= 4'b1100;    // 3
            4'h4 : led[3:0] <= 4'b1011;    // 4
            4'h5 : led[3:0] <= 4'b1010;    // 5
            4'h6 : led[3:0] <= 4'b1001;    // 6
            4'h7 : led[3:0] <= 4'b1000;    // 7
            4'h8 : led[3:0] <= 4'b0111;    // 8
            4'h9 : led[3:0] <= 4'b0110;    // 9
            4'hA : led[3:0] <= 4'b0101;    // A
            4'hB : led[3:0] <= 4'b0100;    // B
            4'hC : led[3:0] <= 4'b0011;	   // C
            4'hD : led[3:0] <= 4'b0010;	   // D
            4'hE : led[3:0] <= 4'b0001;    // E
            4'hF : led[3:0] <= 4'b0000;	   // F
            default : led <= 5'b00000;
        endcase
	end
end

endmodule
