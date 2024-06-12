module gw_gao(
    \music_len[11] ,
    \music_len[10] ,
    \music_len[9] ,
    \music_len[8] ,
    \music_len[7] ,
    \music_len[6] ,
    \music_len[5] ,
    \music_len[4] ,
    \music_len[3] ,
    \music_len[2] ,
    \music_len[1] ,
    \music_len[0] ,
    \speaker_data[15] ,
    \speaker_data[14] ,
    \speaker_data[13] ,
    \speaker_data[12] ,
    \speaker_data[11] ,
    \speaker_data[10] ,
    \speaker_data[9] ,
    \speaker_data[8] ,
    \speaker_data[7] ,
    \speaker_data[6] ,
    \speaker_data[5] ,
    \speaker_data[4] ,
    \speaker_data[3] ,
    \speaker_data[2] ,
    \speaker_data[1] ,
    \speaker_data[0] ,
    \music_init/ram_data_in[15] ,
    \music_init/ram_data_in[14] ,
    \music_init/ram_data_in[13] ,
    \music_init/ram_data_in[12] ,
    \music_init/ram_data_in[11] ,
    \music_init/ram_data_in[10] ,
    \music_init/ram_data_in[9] ,
    \music_init/ram_data_in[8] ,
    \music_init/ram_data_in[7] ,
    \music_init/ram_data_in[6] ,
    \music_init/ram_data_in[5] ,
    \music_init/ram_data_in[4] ,
    \music_init/ram_data_in[3] ,
    \music_init/ram_data_in[2] ,
    \music_init/ram_data_in[1] ,
    \music_init/ram_data_in[0] ,
    \music_init/ram_data_out[15] ,
    \music_init/ram_data_out[14] ,
    \music_init/ram_data_out[13] ,
    \music_init/ram_data_out[12] ,
    \music_init/ram_data_out[11] ,
    \music_init/ram_data_out[10] ,
    \music_init/ram_data_out[9] ,
    \music_init/ram_data_out[8] ,
    \music_init/ram_data_out[7] ,
    \music_init/ram_data_out[6] ,
    \music_init/ram_data_out[5] ,
    \music_init/ram_data_out[4] ,
    \music_init/ram_data_out[3] ,
    \music_init/ram_data_out[2] ,
    \music_init/ram_data_out[1] ,
    \music_init/ram_data_out[0] ,
    \music_init/wrt_en ,
    \music_init/ram_addr[11] ,
    \music_init/ram_addr[10] ,
    \music_init/ram_addr[9] ,
    \music_init/ram_addr[8] ,
    \music_init/ram_addr[7] ,
    \music_init/ram_addr[6] ,
    \music_init/ram_addr[5] ,
    \music_init/ram_addr[4] ,
    \music_init/ram_addr[3] ,
    \music_init/ram_addr[2] ,
    \music_init/ram_addr[1] ,
    \music_init/ram_addr[0] ,
    sys_clk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \music_len[11] ;
input \music_len[10] ;
input \music_len[9] ;
input \music_len[8] ;
input \music_len[7] ;
input \music_len[6] ;
input \music_len[5] ;
input \music_len[4] ;
input \music_len[3] ;
input \music_len[2] ;
input \music_len[1] ;
input \music_len[0] ;
input \speaker_data[15] ;
input \speaker_data[14] ;
input \speaker_data[13] ;
input \speaker_data[12] ;
input \speaker_data[11] ;
input \speaker_data[10] ;
input \speaker_data[9] ;
input \speaker_data[8] ;
input \speaker_data[7] ;
input \speaker_data[6] ;
input \speaker_data[5] ;
input \speaker_data[4] ;
input \speaker_data[3] ;
input \speaker_data[2] ;
input \speaker_data[1] ;
input \speaker_data[0] ;
input \music_init/ram_data_in[15] ;
input \music_init/ram_data_in[14] ;
input \music_init/ram_data_in[13] ;
input \music_init/ram_data_in[12] ;
input \music_init/ram_data_in[11] ;
input \music_init/ram_data_in[10] ;
input \music_init/ram_data_in[9] ;
input \music_init/ram_data_in[8] ;
input \music_init/ram_data_in[7] ;
input \music_init/ram_data_in[6] ;
input \music_init/ram_data_in[5] ;
input \music_init/ram_data_in[4] ;
input \music_init/ram_data_in[3] ;
input \music_init/ram_data_in[2] ;
input \music_init/ram_data_in[1] ;
input \music_init/ram_data_in[0] ;
input \music_init/ram_data_out[15] ;
input \music_init/ram_data_out[14] ;
input \music_init/ram_data_out[13] ;
input \music_init/ram_data_out[12] ;
input \music_init/ram_data_out[11] ;
input \music_init/ram_data_out[10] ;
input \music_init/ram_data_out[9] ;
input \music_init/ram_data_out[8] ;
input \music_init/ram_data_out[7] ;
input \music_init/ram_data_out[6] ;
input \music_init/ram_data_out[5] ;
input \music_init/ram_data_out[4] ;
input \music_init/ram_data_out[3] ;
input \music_init/ram_data_out[2] ;
input \music_init/ram_data_out[1] ;
input \music_init/ram_data_out[0] ;
input \music_init/wrt_en ;
input \music_init/ram_addr[11] ;
input \music_init/ram_addr[10] ;
input \music_init/ram_addr[9] ;
input \music_init/ram_addr[8] ;
input \music_init/ram_addr[7] ;
input \music_init/ram_addr[6] ;
input \music_init/ram_addr[5] ;
input \music_init/ram_addr[4] ;
input \music_init/ram_addr[3] ;
input \music_init/ram_addr[2] ;
input \music_init/ram_addr[1] ;
input \music_init/ram_addr[0] ;
input sys_clk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \music_len[11] ;
wire \music_len[10] ;
wire \music_len[9] ;
wire \music_len[8] ;
wire \music_len[7] ;
wire \music_len[6] ;
wire \music_len[5] ;
wire \music_len[4] ;
wire \music_len[3] ;
wire \music_len[2] ;
wire \music_len[1] ;
wire \music_len[0] ;
wire \speaker_data[15] ;
wire \speaker_data[14] ;
wire \speaker_data[13] ;
wire \speaker_data[12] ;
wire \speaker_data[11] ;
wire \speaker_data[10] ;
wire \speaker_data[9] ;
wire \speaker_data[8] ;
wire \speaker_data[7] ;
wire \speaker_data[6] ;
wire \speaker_data[5] ;
wire \speaker_data[4] ;
wire \speaker_data[3] ;
wire \speaker_data[2] ;
wire \speaker_data[1] ;
wire \speaker_data[0] ;
wire \music_init/ram_data_in[15] ;
wire \music_init/ram_data_in[14] ;
wire \music_init/ram_data_in[13] ;
wire \music_init/ram_data_in[12] ;
wire \music_init/ram_data_in[11] ;
wire \music_init/ram_data_in[10] ;
wire \music_init/ram_data_in[9] ;
wire \music_init/ram_data_in[8] ;
wire \music_init/ram_data_in[7] ;
wire \music_init/ram_data_in[6] ;
wire \music_init/ram_data_in[5] ;
wire \music_init/ram_data_in[4] ;
wire \music_init/ram_data_in[3] ;
wire \music_init/ram_data_in[2] ;
wire \music_init/ram_data_in[1] ;
wire \music_init/ram_data_in[0] ;
wire \music_init/ram_data_out[15] ;
wire \music_init/ram_data_out[14] ;
wire \music_init/ram_data_out[13] ;
wire \music_init/ram_data_out[12] ;
wire \music_init/ram_data_out[11] ;
wire \music_init/ram_data_out[10] ;
wire \music_init/ram_data_out[9] ;
wire \music_init/ram_data_out[8] ;
wire \music_init/ram_data_out[7] ;
wire \music_init/ram_data_out[6] ;
wire \music_init/ram_data_out[5] ;
wire \music_init/ram_data_out[4] ;
wire \music_init/ram_data_out[3] ;
wire \music_init/ram_data_out[2] ;
wire \music_init/ram_data_out[1] ;
wire \music_init/ram_data_out[0] ;
wire \music_init/wrt_en ;
wire \music_init/ram_addr[11] ;
wire \music_init/ram_addr[10] ;
wire \music_init/ram_addr[9] ;
wire \music_init/ram_addr[8] ;
wire \music_init/ram_addr[7] ;
wire \music_init/ram_addr[6] ;
wire \music_init/ram_addr[5] ;
wire \music_init/ram_addr[4] ;
wire \music_init/ram_addr[3] ;
wire \music_init/ram_addr[2] ;
wire \music_init/ram_addr[1] ;
wire \music_init/ram_addr[0] ;
wire sys_clk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(\music_init/wrt_en ),
    .trig1_i({\music_init/ram_addr[11] ,\music_init/ram_addr[10] ,\music_init/ram_addr[9] ,\music_init/ram_addr[8] ,\music_init/ram_addr[7] ,\music_init/ram_addr[6] ,\music_init/ram_addr[5] ,\music_init/ram_addr[4] ,\music_init/ram_addr[3] ,\music_init/ram_addr[2] ,\music_init/ram_addr[1] ,\music_init/ram_addr[0] }),
    .data_i({\music_len[11] ,\music_len[10] ,\music_len[9] ,\music_len[8] ,\music_len[7] ,\music_len[6] ,\music_len[5] ,\music_len[4] ,\music_len[3] ,\music_len[2] ,\music_len[1] ,\music_len[0] ,\speaker_data[15] ,\speaker_data[14] ,\speaker_data[13] ,\speaker_data[12] ,\speaker_data[11] ,\speaker_data[10] ,\speaker_data[9] ,\speaker_data[8] ,\speaker_data[7] ,\speaker_data[6] ,\speaker_data[5] ,\speaker_data[4] ,\speaker_data[3] ,\speaker_data[2] ,\speaker_data[1] ,\speaker_data[0] ,\music_init/ram_data_in[15] ,\music_init/ram_data_in[14] ,\music_init/ram_data_in[13] ,\music_init/ram_data_in[12] ,\music_init/ram_data_in[11] ,\music_init/ram_data_in[10] ,\music_init/ram_data_in[9] ,\music_init/ram_data_in[8] ,\music_init/ram_data_in[7] ,\music_init/ram_data_in[6] ,\music_init/ram_data_in[5] ,\music_init/ram_data_in[4] ,\music_init/ram_data_in[3] ,\music_init/ram_data_in[2] ,\music_init/ram_data_in[1] ,\music_init/ram_data_in[0] ,\music_init/ram_data_out[15] ,\music_init/ram_data_out[14] ,\music_init/ram_data_out[13] ,\music_init/ram_data_out[12] ,\music_init/ram_data_out[11] ,\music_init/ram_data_out[10] ,\music_init/ram_data_out[9] ,\music_init/ram_data_out[8] ,\music_init/ram_data_out[7] ,\music_init/ram_data_out[6] ,\music_init/ram_data_out[5] ,\music_init/ram_data_out[4] ,\music_init/ram_data_out[3] ,\music_init/ram_data_out[2] ,\music_init/ram_data_out[1] ,\music_init/ram_data_out[0] }),
    .clk_i(sys_clk)
);

endmodule
