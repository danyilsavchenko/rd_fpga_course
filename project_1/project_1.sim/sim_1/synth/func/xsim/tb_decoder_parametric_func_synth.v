// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (lin64) Build 6511674 Tue Jun 16 11:01:26 MDT 2026
// Date        : Sat Aug 29 17:59:56 2026
// Host        : danyil-aspirea51541g running 64-bit Ubuntu 26.04.1 LTS
// Command     : write_verilog -mode funcsim -nolib -force -file
//               /home/danyil/rd_fpga_course/project_1/project_1.sim/sim_1/synth/func/xsim/tb_decoder_parametric_func_synth.v
// Design      : decoder_parametric
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xa7a12tcpg238-2I
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* WIDTH = "4" *) 
(* NotValidForBitStream *)
(* \DesignAttr:TELEMETRY_DATA  = "{\n  \"Design Flow Data\": {\n    \"Design Data\": {\n      \"Design Mode\": \"Project flow\",\n      \"Top Methodology\": \"Verilog\"\n    },\n    \"Synthesis\": {\n      \"Run Time\": \"367.350000 seconds\"\n    }\n  }\n}" *) 
module decoder_parametric
   (i_addr,
    i_en,
    o_decoded);
  input [3:0]i_addr;
  input i_en;
  output [15:0]o_decoded;

  wire [3:0]i_addr;
  wire [3:0]i_addr_IBUF;
  wire i_en;
  wire i_en_IBUF;
  wire [15:0]o_decoded;
  wire [15:0]o_decoded_OBUF;

  IBUF \i_addr_IBUF[0]_inst 
       (.I(i_addr[0]),
        .O(i_addr_IBUF[0]));
  IBUF \i_addr_IBUF[1]_inst 
       (.I(i_addr[1]),
        .O(i_addr_IBUF[1]));
  IBUF \i_addr_IBUF[2]_inst 
       (.I(i_addr[2]),
        .O(i_addr_IBUF[2]));
  IBUF \i_addr_IBUF[3]_inst 
       (.I(i_addr[3]),
        .O(i_addr_IBUF[3]));
  IBUF i_en_IBUF_inst
       (.I(i_en),
        .O(i_en_IBUF));
  OBUF \o_decoded_OBUF[0]_inst 
       (.I(o_decoded_OBUF[0]),
        .O(o_decoded[0]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h00000002)) 
    \o_decoded_OBUF[0]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[0]));
  OBUF \o_decoded_OBUF[10]_inst 
       (.I(o_decoded_OBUF[10]),
        .O(o_decoded[10]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'h00200000)) 
    \o_decoded_OBUF[10]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[0]),
        .I2(i_addr_IBUF[1]),
        .I3(i_addr_IBUF[2]),
        .I4(i_addr_IBUF[3]),
        .O(o_decoded_OBUF[10]));
  OBUF \o_decoded_OBUF[11]_inst 
       (.I(o_decoded_OBUF[11]),
        .O(o_decoded[11]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h00800000)) 
    \o_decoded_OBUF[11]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[2]),
        .I4(i_addr_IBUF[3]),
        .O(o_decoded_OBUF[11]));
  OBUF \o_decoded_OBUF[12]_inst 
       (.I(o_decoded_OBUF[12]),
        .O(o_decoded[12]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h02000000)) 
    \o_decoded_OBUF[12]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[12]));
  OBUF \o_decoded_OBUF[13]_inst 
       (.I(o_decoded_OBUF[13]),
        .O(o_decoded[13]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h20000000)) 
    \o_decoded_OBUF[13]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[13]));
  OBUF \o_decoded_OBUF[14]_inst 
       (.I(o_decoded_OBUF[14]),
        .O(o_decoded[14]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h20000000)) 
    \o_decoded_OBUF[14]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[0]),
        .I2(i_addr_IBUF[1]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[14]));
  OBUF \o_decoded_OBUF[15]_inst 
       (.I(o_decoded_OBUF[15]),
        .O(o_decoded[15]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    \o_decoded_OBUF[15]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[15]));
  OBUF \o_decoded_OBUF[1]_inst 
       (.I(o_decoded_OBUF[1]),
        .O(o_decoded[1]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h00000020)) 
    \o_decoded_OBUF[1]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[1]));
  OBUF \o_decoded_OBUF[2]_inst 
       (.I(o_decoded_OBUF[2]),
        .O(o_decoded[2]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h00000020)) 
    \o_decoded_OBUF[2]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[0]),
        .I2(i_addr_IBUF[1]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[2]));
  OBUF \o_decoded_OBUF[3]_inst 
       (.I(o_decoded_OBUF[3]),
        .O(o_decoded[3]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h00000080)) 
    \o_decoded_OBUF[3]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[3]));
  OBUF \o_decoded_OBUF[4]_inst 
       (.I(o_decoded_OBUF[4]),
        .O(o_decoded[4]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h00020000)) 
    \o_decoded_OBUF[4]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[4]));
  OBUF \o_decoded_OBUF[5]_inst 
       (.I(o_decoded_OBUF[5]),
        .O(o_decoded[5]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h00200000)) 
    \o_decoded_OBUF[5]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[5]));
  OBUF \o_decoded_OBUF[6]_inst 
       (.I(o_decoded_OBUF[6]),
        .O(o_decoded[6]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'h00200000)) 
    \o_decoded_OBUF[6]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[0]),
        .I2(i_addr_IBUF[1]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[6]));
  OBUF \o_decoded_OBUF[7]_inst 
       (.I(o_decoded_OBUF[7]),
        .O(o_decoded[7]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h00800000)) 
    \o_decoded_OBUF[7]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[3]),
        .I4(i_addr_IBUF[2]),
        .O(o_decoded_OBUF[7]));
  OBUF \o_decoded_OBUF[8]_inst 
       (.I(o_decoded_OBUF[8]),
        .O(o_decoded[8]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'h00020000)) 
    \o_decoded_OBUF[8]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[2]),
        .I4(i_addr_IBUF[3]),
        .O(o_decoded_OBUF[8]));
  OBUF \o_decoded_OBUF[9]_inst 
       (.I(o_decoded_OBUF[9]),
        .O(o_decoded[9]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'h00200000)) 
    \o_decoded_OBUF[9]_inst_i_1 
       (.I0(i_en_IBUF),
        .I1(i_addr_IBUF[1]),
        .I2(i_addr_IBUF[0]),
        .I3(i_addr_IBUF[2]),
        .I4(i_addr_IBUF[3]),
        .O(o_decoded_OBUF[9]));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
