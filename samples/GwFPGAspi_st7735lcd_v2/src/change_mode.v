// ==============================================================================================
//                                         模式切换模块
// ==============================================================================================
//最为重要的是pre继承上一状态，通过时序逻辑作差得出非时钟信号的上升沿//
module change_mode(
    input sys_clk,
    input sys_rst_n,

    input [3:0] keyboard_data,
    input IsPressed,

    output reg mode
);

reg pre_IsPressed; // 上一按钮状态，用于抽取上升沿

always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        pre_IsPressed <= 1'b0;  // 上一按钮状态
        mode <= 1'b0;   // 0电子琴模式，1音乐播放模式
    end else begin
        // 抽取IsPressed上升沿
        if(!pre_IsPressed && IsPressed) begin
            if(keyboard_data==4'hD) // 按钮D切换模式
                mode <= ~mode;  // 翻转mode
        end
        pre_IsPressed <= IsPressed;
    end
end

endmodule