//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.05
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Thu May 16 15:50:17 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Integer_Multiply_Divider_Top your_instance_name(
		.clk(clk_i), //input clk
		.rstn(rstn_i), //input rstn
		.kill(kill_i), //input kill
		.tagI(tagI_i), //input [4:0] tagI
		.tagO(tagO_o), //output [4:0] tagO
		.req_ready(req_ready_o), //output req_ready
		.req_valid(req_valid_i), //input req_valid
		.resp_ready(resp_ready_i), //input resp_ready
		.resp_valid(resp_valid_o), //output resp_valid
		.func(func_i), //input [3:0] func
		.op0(op0_i), //input [31:0] op0
		.op1(op1_i), //input [31:0] op1
		.res0(res0_o), //output [31:0] res0
		.res1(res1_o) //output [31:0] res1
	);

//--------Copy end-------------------
