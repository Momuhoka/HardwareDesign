//----------------------------------------------------------------------------------------
// File name: show_string_number_ctrl
// Descriptions: 控制展示内容的高层模块
//----------------------------------------------------------------------------------------
//****************************************************************************************//
/*
在屏幕上显示字符串
第一行中间显示“pxm hust”共8个字符；
第二行为空；
第三行最左边显示“TST6”共4个字符； 
cnt_ascii_num  0   1   2   3  4   5   6   7   8   9  10   11  
   char        p   x   m      h   u   s   t   T   S   T   6
 ascii码     112,120,109, 32,104,117,115,116, 84, 83, 84, 54 =库内码+32 
*/

module show_string_number_ctrl
(
    input       wire            sys_clk             ,
    input       wire            sys_rst_n           ,
    input       wire            init_done           ,
    input       wire            show_char_done      ,
    
    output      wire            en_size             ,
    output      reg             show_char_flag      ,
    output      reg     [6:0]   ascii_num           ,
    output      reg     [8:0]   start_x             ,
    output      reg     [8:0]   start_y             
);      
//****************** Parameter and Internal Signal *******************//        
reg     [1:0]   cnt1;            //展示 行 计数器？！？3行故cnt1值只需0，1，2
//也可能是延迟计数器，init_done为高电平后，延迟3拍，产生show_char_flag高脉冲
reg     [4:0]   cnt_ascii_num;

//******************************* Main Code **************************//
//en_size为1时调用字体大小为16x8，为0时调用字体大小为12x6；
assign  en_size = 1'b1;

//产生输出信号show_char_flag，写到第2行！？就让show_char_flag产生一个高脉冲给后面模块
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt1 <= 'd0;
    else if(show_char_flag)
        cnt1 <= 'd0;
    else if(init_done && cnt1 < 'd3)
        cnt1 <= cnt1 + 1'b1;
    else
        cnt1 <= cnt1;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        show_char_flag <= 1'b0;
    else if(cnt1 == 'd2)
        show_char_flag <= 1'b1;
    else
        show_char_flag <= 1'b0;



always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt_ascii_num <= 'd0;
    else if(init_done && show_char_done)         //展示数目的计数器：初始化完成和上一个char展示完成后，数目+1
        cnt_ascii_num <= cnt_ascii_num + 1'b1;   //等于是展示字符的坐标（单位：个字符）
    else
        cnt_ascii_num <= cnt_ascii_num;

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        ascii_num <= 'd0;
    else if(init_done)
        case(cnt_ascii_num)         //根据当前展示数目（字符坐标）给出展示内容（ascii码）
//ascii码     112,120,109, 32,104,117,115,116, 84, 83, 84, 54  =库内码+32
            0 : ascii_num <= 'd112-'d32; 
            1 : ascii_num <= 'd112-'d32;
            2 : ascii_num <= 'd109-'d32;
            3 : ascii_num <= 'd 32-'d32;
            4 : ascii_num <= 'd104-'d32;
            5 : ascii_num <= 'd117-'d32;
            6 : ascii_num <= 'd115-'d32;
            7 : ascii_num <= 'd116-'d32;
            8 : ascii_num <= 'd 84-'d32;
            9 : ascii_num <= 'd 83-'d32;
            10: ascii_num <= 'd 84-'d32;
            11: ascii_num <= 'd 54-'d32;
            default: ascii_num <= 'd0;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        start_x <= 'd0;
    else if(init_done)
        case(cnt_ascii_num)        //根据当前展示数目（字符坐标）给出展示位置（屏幕坐标）,先定横向x
            0 : start_x <= 'd32 ;  //(16x)8的字模，第一行128x128屏满行16字符；
            1 : start_x <= 'd40 ;  //首行居中显示8个字符，起始128/4，后续++8(简单粗略)
            2 : start_x <= 'd48 ;
            3 : start_x <= 'd56 ;
            4 : start_x <= 'd64 ;
            5 : start_x <= 'd72 ;
            6 : start_x <= 'd80 ;
            7 : start_x <= 'd88 ;  //首行居中显示8个字符
            8 : start_x <= 'd8;    //第二行空，第三行（换行是y计算）从几乎最左边显示，共4个字符
            9 : start_x <= 'd16;
            10: start_x <= 'd24;
            11: start_x <= 'd32;
            default: start_x <= 'd0;
        endcase
    else
        start_x <= 'd0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        start_y <= 'd0;
    else if(init_done)
        case(cnt_ascii_num)        //根据当前展示数目（字符坐标）给出展示位置（屏幕坐标）,再定纵向y
            0 : start_y <= 'd16;   //首行居中显示8个字符，靠屏幕上边
            1 : start_y <= 'd16;
            2 : start_y <= 'd16;
            3 : start_y <= 'd16;
            4 : start_y <= 'd16;
            5 : start_y <= 'd16;
            6 : start_y <= 'd16;
            7 : start_y <= 'd16;
            8 : start_y <= 'd48;   //第三行显示4个字符
            9 : start_y <= 'd48;
            10: start_y <= 'd48;
            11: start_y <= 'd48;
            default: start_y <= 'd0;
        endcase
    else
        start_y <= 'd0;

endmodule