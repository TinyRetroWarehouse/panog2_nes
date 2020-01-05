// Based on apu.sv from https://github.com/MiSTer-devel/NES_MiSTer.git

// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.
// Ported to verilog by Skip Hansen, 2019

// http://wiki.nesdev.com/w/index.php/APU_Mixer
// I generated three LUT's for each mix channel entry and one lut for the squares, then a
// 282 entry lut for the mix channel. It's more accurate than the original LUT system listed on
// the NesDev page.

module APUMixer (
  input  wire [3:0] mute_in,      // mute specific channels
  input [3:0] square1,
  input [3:0] square2,
  input [3:0] triangle,
  input [3:0] noise,
  input [6:0] dmc,
  output reg [15:0] sample
);

wire [3:0] square1_m;
wire [3:0] square2_m;
wire [3:0] triangle_m;
wire [3:0] noise_m;
wire [6:0] dmc_m;

assign square1_m = (mute_in[0]) ? 4'h0 : square1;
assign square2_m = (mute_in[1]) ? 4'h0 : square2;
assign triangle_m = (mute_in[2]) ? 4'h0 : triangle;
assign noise_m = (mute_in[3]) ? 4'h0 : noise;

wire [4:0] squares = square1_m + square2_m;

reg [5:0] tri_lookup;
reg [5:0] noise_lookup;
reg [7:0] dmc_lookup;
reg [8:0] mix;
reg [15:0] ch1;
reg [15:0] ch2;
reg [16:0] chan_mix;
reg [16:0] adj_mix;

always @*
  begin
    case (triangle_m)
        5'd0 : tri_lookup = 6'd0;
        5'd1 : tri_lookup = 6'd3;
        5'd2 : tri_lookup = 6'd7;
        5'd3 : tri_lookup = 6'd11;
        5'd4 : tri_lookup = 6'd15;
        5'd5 : tri_lookup = 6'd19;
        5'd6 : tri_lookup = 6'd23;
        5'd7 : tri_lookup = 6'd27;
        5'd8 : tri_lookup = 6'd31;
        5'd9 : tri_lookup = 6'd35;
        5'd10 : tri_lookup = 6'd39;
        5'd11 : tri_lookup = 6'd43;
        5'd12 : tri_lookup = 6'd47;
        5'd13 : tri_lookup = 6'd51;
        5'd14 : tri_lookup = 6'd55;
        5'd15 : tri_lookup = 6'd59;
    endcase

    case (noise_m)
        5'd0 : noise_lookup = 6'd0;
        5'd1 : noise_lookup = 6'd2;
        5'd2 : noise_lookup = 6'd5;
        5'd3 : noise_lookup = 6'd8;
        5'd4 : noise_lookup = 6'd10;
        5'd5 : noise_lookup = 6'd13;
        5'd6 : noise_lookup = 6'd16;
        5'd7 : noise_lookup = 6'd18;
        5'd8 : noise_lookup = 6'd21;
        5'd9 : noise_lookup = 6'd24;
        5'd10 : noise_lookup = 6'd26;
        5'd11 : noise_lookup = 6'd29;
        5'd12 : noise_lookup = 6'd32;
        5'd13 : noise_lookup = 6'd34;
        5'd14 : noise_lookup = 6'd37;
        5'd15 : noise_lookup = 6'd40;
    endcase

    case (dmc)
        8'd0 : dmc_lookup = 8'd0;
        8'd1 : dmc_lookup = 8'd1;
        8'd2 : dmc_lookup = 8'd2;
        8'd3 : dmc_lookup = 8'd4;
        8'd4 : dmc_lookup = 8'd5;
        8'd5 : dmc_lookup = 8'd7;
        8'd6 : dmc_lookup = 8'd8;
        8'd7 : dmc_lookup = 8'd10;
        8'd8 : dmc_lookup = 8'd11;
        8'd9 : dmc_lookup = 8'd13;
        8'd10 : dmc_lookup = 8'd14;
        8'd11 : dmc_lookup = 8'd15;
        8'd12 : dmc_lookup = 8'd17;
        8'd13 : dmc_lookup = 8'd18;
        8'd14 : dmc_lookup = 8'd20;
        8'd15 : dmc_lookup = 8'd21;
        8'd16 : dmc_lookup = 8'd23;
        8'd17 : dmc_lookup = 8'd24;
        8'd18 : dmc_lookup = 8'd26;
        8'd19 : dmc_lookup = 8'd27;
        8'd20 : dmc_lookup = 8'd28;
        8'd21 : dmc_lookup = 8'd30;
        8'd22 : dmc_lookup = 8'd31;
        8'd23 : dmc_lookup = 8'd33;
        8'd24 : dmc_lookup = 8'd34;
        8'd25 : dmc_lookup = 8'd36;
        8'd26 : dmc_lookup = 8'd37;
        8'd27 : dmc_lookup = 8'd39;
        8'd28 : dmc_lookup = 8'd40;
        8'd29 : dmc_lookup = 8'd41;
        8'd30 : dmc_lookup = 8'd43;
        8'd31 : dmc_lookup = 8'd44;
        8'd32 : dmc_lookup = 8'd46;
        8'd33 : dmc_lookup = 8'd47;
        8'd34 : dmc_lookup = 8'd49;
        8'd35 : dmc_lookup = 8'd50;
        8'd36 : dmc_lookup = 8'd52;
        8'd37 : dmc_lookup = 8'd53;
        8'd38 : dmc_lookup = 8'd55;
        8'd39 : dmc_lookup = 8'd56;
        8'd40 : dmc_lookup = 8'd57;
        8'd41 : dmc_lookup = 8'd59;
        8'd42 : dmc_lookup = 8'd60;
        8'd43 : dmc_lookup = 8'd62;
        8'd44 : dmc_lookup = 8'd63;
        8'd45 : dmc_lookup = 8'd65;
        8'd46 : dmc_lookup = 8'd66;
        8'd47 : dmc_lookup = 8'd68;
        8'd48 : dmc_lookup = 8'd69;
        8'd49 : dmc_lookup = 8'd70;
        8'd50 : dmc_lookup = 8'd72;
        8'd51 : dmc_lookup = 8'd73;
        8'd52 : dmc_lookup = 8'd75;
        8'd53 : dmc_lookup = 8'd76;
        8'd54 : dmc_lookup = 8'd78;
        8'd55 : dmc_lookup = 8'd79;
        8'd56 : dmc_lookup = 8'd81;
        8'd57 : dmc_lookup = 8'd82;
        8'd58 : dmc_lookup = 8'd83;
        8'd59 : dmc_lookup = 8'd85;
        8'd60 : dmc_lookup = 8'd86;
        8'd61 : dmc_lookup = 8'd88;
        8'd62 : dmc_lookup = 8'd89;
        8'd63 : dmc_lookup = 8'd91;
        8'd64 : dmc_lookup = 8'd92;
        8'd65 : dmc_lookup = 8'd94;
        8'd66 : dmc_lookup = 8'd95;
        8'd67 : dmc_lookup = 8'd96;
        8'd68 : dmc_lookup = 8'd98;
        8'd69 : dmc_lookup = 8'd99;
        8'd70 : dmc_lookup = 8'd101;
        8'd71 : dmc_lookup = 8'd102;
        8'd72 : dmc_lookup = 8'd104;
        8'd73 : dmc_lookup = 8'd105;
        8'd74 : dmc_lookup = 8'd107;
        8'd75 : dmc_lookup = 8'd108;
        8'd76 : dmc_lookup = 8'd110;
        8'd77 : dmc_lookup = 8'd111;
        8'd78 : dmc_lookup = 8'd112;
        8'd79 : dmc_lookup = 8'd114;
        8'd80 : dmc_lookup = 8'd115;
        8'd81 : dmc_lookup = 8'd117;
        8'd82 : dmc_lookup = 8'd118;
        8'd83 : dmc_lookup = 8'd120;
        8'd84 : dmc_lookup = 8'd121;
        8'd85 : dmc_lookup = 8'd123;
        8'd86 : dmc_lookup = 8'd124;
        8'd87 : dmc_lookup = 8'd125;
        8'd88 : dmc_lookup = 8'd127;
        8'd89 : dmc_lookup = 8'd128;
        8'd90 : dmc_lookup = 8'd130;
        8'd91 : dmc_lookup = 8'd131;
        8'd92 : dmc_lookup = 8'd133;
        8'd93 : dmc_lookup = 8'd134;
        8'd94 : dmc_lookup = 8'd136;
        8'd95 : dmc_lookup = 8'd137;
        8'd96 : dmc_lookup = 8'd138;
        8'd97 : dmc_lookup = 8'd140;
        8'd98 : dmc_lookup = 8'd141;
        8'd99 : dmc_lookup = 8'd143;
        8'd100 : dmc_lookup = 8'd144;
        8'd101 : dmc_lookup = 8'd146;
        8'd102 : dmc_lookup = 8'd147;
        8'd103 : dmc_lookup = 8'd149;
        8'd104 : dmc_lookup = 8'd150;
        8'd105 : dmc_lookup = 8'd151;
        8'd106 : dmc_lookup = 8'd153;
        8'd107 : dmc_lookup = 8'd154;
        8'd108 : dmc_lookup = 8'd156;
        8'd109 : dmc_lookup = 8'd157;
        8'd110 : dmc_lookup = 8'd159;
        8'd111 : dmc_lookup = 8'd160;
        8'd112 : dmc_lookup = 8'd162;
        8'd113 : dmc_lookup = 8'd163;
        8'd114 : dmc_lookup = 8'd165;
        8'd115 : dmc_lookup = 8'd166;
        8'd116 : dmc_lookup = 8'd167;
        8'd117 : dmc_lookup = 8'd169;
        8'd118 : dmc_lookup = 8'd170;
        8'd119 : dmc_lookup = 8'd172;
        8'd120 : dmc_lookup = 8'd173;
        8'd121 : dmc_lookup = 8'd175;
        8'd122 : dmc_lookup = 8'd176;
        8'd123 : dmc_lookup = 8'd178;
        8'd124 : dmc_lookup = 8'd179;
        8'd125 : dmc_lookup = 8'd180;
        8'd126 : dmc_lookup = 8'd182;
        8'd127 : dmc_lookup = 8'd183;
    endcase

    mix = tri_lookup + noise_lookup + dmc_lookup;

    // wire [15:0] ch1 = pulse_lut[squares];
    case (squares)
        6'd0 : ch1 = 16'd0;
        6'd1 : ch1 = 16'd763;
        6'd2 : ch1 = 16'd1509;
        6'd3 : ch1 = 16'd2236;
        6'd4 : ch1 = 16'd2947;
        6'd5 : ch1 = 16'd3641;
        6'd6 : ch1 = 16'd4319;
        6'd7 : ch1 = 16'd4982;
        6'd8 : ch1 = 16'd5630;
        6'd9 : ch1 = 16'd6264;
        6'd10 : ch1 = 16'd6883;
        6'd11 : ch1 = 16'd7490;
        6'd12 : ch1 = 16'd8083;
        6'd13 : ch1 = 16'd8664;
        6'd14 : ch1 = 16'd9232;
        6'd15 : ch1 = 16'd9789;
        6'd16 : ch1 = 16'd10334;
        6'd17 : ch1 = 16'd10868;
        6'd18 : ch1 = 16'd11392;
        6'd19 : ch1 = 16'd11905;
        6'd20 : ch1 = 16'd12408;
        6'd21 : ch1 = 16'd12901;
        6'd22 : ch1 = 16'd13384;
        6'd23 : ch1 = 16'd13858;
        6'd24 : ch1 = 16'd14324;
        6'd25 : ch1 = 16'd14780;
        6'd26 : ch1 = 16'd15228;
        6'd27 : ch1 = 16'd15668;
        6'd28 : ch1 = 16'd16099;
        6'd29 : ch1 = 16'd16523;
        6'd30 : ch1 = 16'd16939;
        6'd31 : ch1 = 16'd17348;
    endcase


    // wire [15:0] ch2 = mix_lut[mix];
    case (mix)
        10'd0 : ch2 = 16'd0;
        10'd1 : ch2 = 16'd318;
        10'd2 : ch2 = 16'd635;
        10'd3 : ch2 = 16'd950;
        10'd4 : ch2 = 16'd1262;
        10'd5 : ch2 = 16'd1573;
        10'd6 : ch2 = 16'd1882;
        10'd7 : ch2 = 16'd2190;
        10'd8 : ch2 = 16'd2495;
        10'd9 : ch2 = 16'd2799;
        10'd10 : ch2 = 16'd3101;
        10'd11 : ch2 = 16'd3401;
        10'd12 : ch2 = 16'd3699;
        10'd13 : ch2 = 16'd3995;
        10'd14 : ch2 = 16'd4290;
        10'd15 : ch2 = 16'd4583;
        10'd16 : ch2 = 16'd4875;
        10'd17 : ch2 = 16'd5164;
        10'd18 : ch2 = 16'd5452;
        10'd19 : ch2 = 16'd5739;
        10'd20 : ch2 = 16'd6023;
        10'd21 : ch2 = 16'd6306;
        10'd22 : ch2 = 16'd6588;
        10'd23 : ch2 = 16'd6868;
        10'd24 : ch2 = 16'd7146;
        10'd25 : ch2 = 16'd7423;
        10'd26 : ch2 = 16'd7698;
        10'd27 : ch2 = 16'd7971;
        10'd28 : ch2 = 16'd8243;
        10'd29 : ch2 = 16'd8514;
        10'd30 : ch2 = 16'd8783;
        10'd31 : ch2 = 16'd9050;
        10'd32 : ch2 = 16'd9316;
        10'd33 : ch2 = 16'd9581;
        10'd34 : ch2 = 16'd9844;
        10'd35 : ch2 = 16'd10105;
        10'd36 : ch2 = 16'd10365;
        10'd37 : ch2 = 16'd10624;
        10'd38 : ch2 = 16'd10881;
        10'd39 : ch2 = 16'd11137;
        10'd40 : ch2 = 16'd11392;
        10'd41 : ch2 = 16'd11645;
        10'd42 : ch2 = 16'd11897;
        10'd43 : ch2 = 16'd12147;
        10'd44 : ch2 = 16'd12396;
        10'd45 : ch2 = 16'd12644;
        10'd46 : ch2 = 16'd12890;
        10'd47 : ch2 = 16'd13135;
        10'd48 : ch2 = 16'd13379;
        10'd49 : ch2 = 16'd13622;
        10'd50 : ch2 = 16'd13863;
        10'd51 : ch2 = 16'd14103;
        10'd52 : ch2 = 16'd14341;
        10'd53 : ch2 = 16'd14579;
        10'd54 : ch2 = 16'd14815;
        10'd55 : ch2 = 16'd15050;
        10'd56 : ch2 = 16'd15284;
        10'd57 : ch2 = 16'd15516;
        10'd58 : ch2 = 16'd15747;
        10'd59 : ch2 = 16'd15978;
        10'd60 : ch2 = 16'd16206;
        10'd61 : ch2 = 16'd16434;
        10'd62 : ch2 = 16'd16661;
        10'd63 : ch2 = 16'd16886;
        10'd64 : ch2 = 16'd17110;
        10'd65 : ch2 = 16'd17333;
        10'd66 : ch2 = 16'd17555;
        10'd67 : ch2 = 16'd17776;
        10'd68 : ch2 = 16'd17996;
        10'd69 : ch2 = 16'd18215;
        10'd70 : ch2 = 16'd18432;
        10'd71 : ch2 = 16'd18649;
        10'd72 : ch2 = 16'd18864;
        10'd73 : ch2 = 16'd19078;
        10'd74 : ch2 = 16'd19291;
        10'd75 : ch2 = 16'd19504;
        10'd76 : ch2 = 16'd19715;
        10'd77 : ch2 = 16'd19925;
        10'd78 : ch2 = 16'd20134;
        10'd79 : ch2 = 16'd20342;
        10'd80 : ch2 = 16'd20549;
        10'd81 : ch2 = 16'd20755;
        10'd82 : ch2 = 16'd20960;
        10'd83 : ch2 = 16'd21163;
        10'd84 : ch2 = 16'd21366;
        10'd85 : ch2 = 16'd21568;
        10'd86 : ch2 = 16'd21769;
        10'd87 : ch2 = 16'd21969;
        10'd88 : ch2 = 16'd22169;
        10'd89 : ch2 = 16'd22367;
        10'd90 : ch2 = 16'd22564;
        10'd91 : ch2 = 16'd22760;
        10'd92 : ch2 = 16'd22955;
        10'd93 : ch2 = 16'd23150;
        10'd94 : ch2 = 16'd23343;
        10'd95 : ch2 = 16'd23536;
        10'd96 : ch2 = 16'd23727;
        10'd97 : ch2 = 16'd23918;
        10'd98 : ch2 = 16'd24108;
        10'd99 : ch2 = 16'd24297;
        10'd100 : ch2 = 16'd24485;
        10'd101 : ch2 = 16'd24672;
        10'd102 : ch2 = 16'd24858;
        10'd103 : ch2 = 16'd25044;
        10'd104 : ch2 = 16'd25228;
        10'd105 : ch2 = 16'd25412;
        10'd106 : ch2 = 16'd25595;
        10'd107 : ch2 = 16'd25777;
        10'd108 : ch2 = 16'd25958;
        10'd109 : ch2 = 16'd26138;
        10'd110 : ch2 = 16'd26318;
        10'd111 : ch2 = 16'd26497;
        10'd112 : ch2 = 16'd26674;
        10'd113 : ch2 = 16'd26852;
        10'd114 : ch2 = 16'd27028;
        10'd115 : ch2 = 16'd27203;
        10'd116 : ch2 = 16'd27378;
        10'd117 : ch2 = 16'd27552;
        10'd118 : ch2 = 16'd27725;
        10'd119 : ch2 = 16'd27898;
        10'd120 : ch2 = 16'd28069;
        10'd121 : ch2 = 16'd28240;
        10'd122 : ch2 = 16'd28410;
        10'd123 : ch2 = 16'd28579;
        10'd124 : ch2 = 16'd28748;
        10'd125 : ch2 = 16'd28916;
        10'd126 : ch2 = 16'd29083;
        10'd127 : ch2 = 16'd29249;
        10'd128 : ch2 = 16'd29415;
        10'd129 : ch2 = 16'd29580;
        10'd130 : ch2 = 16'd29744;
        10'd131 : ch2 = 16'd29907;
        10'd132 : ch2 = 16'd30070;
        10'd133 : ch2 = 16'd30232;
        10'd134 : ch2 = 16'd30393;
        10'd135 : ch2 = 16'd30554;
        10'd136 : ch2 = 16'd30714;
        10'd137 : ch2 = 16'd30873;
        10'd138 : ch2 = 16'd31032;
        10'd139 : ch2 = 16'd31190;
        10'd140 : ch2 = 16'd31347;
        10'd141 : ch2 = 16'd31503;
        10'd142 : ch2 = 16'd31659;
        10'd143 : ch2 = 16'd31815;
        10'd144 : ch2 = 16'd31969;
        10'd145 : ch2 = 16'd32123;
        10'd146 : ch2 = 16'd32276;
        10'd147 : ch2 = 16'd32429;
        10'd148 : ch2 = 16'd32581;
        10'd149 : ch2 = 16'd32732;
        10'd150 : ch2 = 16'd32883;
        10'd151 : ch2 = 16'd33033;
        10'd152 : ch2 = 16'd33182;
        10'd153 : ch2 = 16'd33331;
        10'd154 : ch2 = 16'd33479;
        10'd155 : ch2 = 16'd33627;
        10'd156 : ch2 = 16'd33774;
        10'd157 : ch2 = 16'd33920;
        10'd158 : ch2 = 16'd34066;
        10'd159 : ch2 = 16'd34211;
        10'd160 : ch2 = 16'd34356;
        10'd161 : ch2 = 16'd34500;
        10'd162 : ch2 = 16'd34643;
        10'd163 : ch2 = 16'd34786;
        10'd164 : ch2 = 16'd34928;
        10'd165 : ch2 = 16'd35070;
        10'd166 : ch2 = 16'd35211;
        10'd167 : ch2 = 16'd35352;
        10'd168 : ch2 = 16'd35492;
        10'd169 : ch2 = 16'd35631;
        10'd170 : ch2 = 16'd35770;
        10'd171 : ch2 = 16'd35908;
        10'd172 : ch2 = 16'd36046;
        10'd173 : ch2 = 16'd36183;
        10'd174 : ch2 = 16'd36319;
        10'd175 : ch2 = 16'd36456;
        10'd176 : ch2 = 16'd36591;
        10'd177 : ch2 = 16'd36726;
        10'd178 : ch2 = 16'd36860;
        10'd179 : ch2 = 16'd36994;
        10'd180 : ch2 = 16'd37128;
        10'd181 : ch2 = 16'd37261;
        10'd182 : ch2 = 16'd37393;
        10'd183 : ch2 = 16'd37525;
        10'd184 : ch2 = 16'd37656;
        10'd185 : ch2 = 16'd37787;
        10'd186 : ch2 = 16'd37917;
        10'd187 : ch2 = 16'd38047;
        10'd188 : ch2 = 16'd38176;
        10'd189 : ch2 = 16'd38305;
        10'd190 : ch2 = 16'd38433;
        10'd191 : ch2 = 16'd38561;
        10'd192 : ch2 = 16'd38689;
        10'd193 : ch2 = 16'd38815;
        10'd194 : ch2 = 16'd38942;
        10'd195 : ch2 = 16'd39068;
        10'd196 : ch2 = 16'd39193;
        10'd197 : ch2 = 16'd39318;
        10'd198 : ch2 = 16'd39442;
        10'd199 : ch2 = 16'd39566;
        10'd200 : ch2 = 16'd39690;
        10'd201 : ch2 = 16'd39813;
        10'd202 : ch2 = 16'd39935;
        10'd203 : ch2 = 16'd40057;
        10'd204 : ch2 = 16'd40179;
        10'd205 : ch2 = 16'd40300;
        10'd206 : ch2 = 16'd40421;
        10'd207 : ch2 = 16'd40541;
        10'd208 : ch2 = 16'd40661;
        10'd209 : ch2 = 16'd40780;
        10'd210 : ch2 = 16'd40899;
        10'd211 : ch2 = 16'd41017;
        10'd212 : ch2 = 16'd41136;
        10'd213 : ch2 = 16'd41253;
        10'd214 : ch2 = 16'd41370;
        10'd215 : ch2 = 16'd41487;
        10'd216 : ch2 = 16'd41603;
        10'd217 : ch2 = 16'd41719;
        10'd218 : ch2 = 16'd41835;
        10'd219 : ch2 = 16'd41950;
        10'd220 : ch2 = 16'd42064;
        10'd221 : ch2 = 16'd42178;
        10'd222 : ch2 = 16'd42292;
        10'd223 : ch2 = 16'd42406;
        10'd224 : ch2 = 16'd42519;
        10'd225 : ch2 = 16'd42631;
        10'd226 : ch2 = 16'd42743;
        10'd227 : ch2 = 16'd42855;
        10'd228 : ch2 = 16'd42966;
        10'd229 : ch2 = 16'd43077;
        10'd230 : ch2 = 16'd43188;
        10'd231 : ch2 = 16'd43298;
        10'd232 : ch2 = 16'd43408;
        10'd233 : ch2 = 16'd43517;
        10'd234 : ch2 = 16'd43626;
        10'd235 : ch2 = 16'd43735;
        10'd236 : ch2 = 16'd43843;
        10'd237 : ch2 = 16'd43951;
        10'd238 : ch2 = 16'd44058;
        10'd239 : ch2 = 16'd44165;
        10'd240 : ch2 = 16'd44272;
        10'd241 : ch2 = 16'd44378;
        10'd242 : ch2 = 16'd44484;
        10'd243 : ch2 = 16'd44589;
        10'd244 : ch2 = 16'd44695;
        10'd245 : ch2 = 16'd44799;
        10'd246 : ch2 = 16'd44904;
        10'd247 : ch2 = 16'd45008;
        10'd248 : ch2 = 16'd45112;
        10'd249 : ch2 = 16'd45215;
        10'd250 : ch2 = 16'd45318;
        10'd251 : ch2 = 16'd45421;
        10'd252 : ch2 = 16'd45523;
        10'd253 : ch2 = 16'd45625;
        10'd254 : ch2 = 16'd45726;
        10'd255 : ch2 = 16'd45828;
        10'd256 : ch2 = 16'd45929;
        10'd257 : ch2 = 16'd46029;
        10'd258 : ch2 = 16'd46129;
        10'd259 : ch2 = 16'd46229;
        10'd260 : ch2 = 16'd46329;
        10'd261 : ch2 = 16'd46428;
        10'd262 : ch2 = 16'd46527;
        10'd263 : ch2 = 16'd46625;
        10'd264 : ch2 = 16'd46723;
        10'd265 : ch2 = 16'd46821;
        10'd266 : ch2 = 16'd46919;
        10'd267 : ch2 = 16'd47016;
        10'd268 : ch2 = 16'd47113;
        10'd269 : ch2 = 16'd47209;
        10'd270 : ch2 = 16'd47306;
        10'd271 : ch2 = 16'd47402;
        10'd272 : ch2 = 16'd47497;
        10'd273 : ch2 = 16'd47592;
        10'd274 : ch2 = 16'd47687;
        10'd275 : ch2 = 16'd47782;
        10'd276 : ch2 = 16'd47876;
        10'd277 : ch2 = 16'd47970;
        10'd278 : ch2 = 16'd48064;
        10'd279 : ch2 = 16'd48157;
        10'd280 : ch2 = 16'd48250;
        10'd281 : ch2 = 16'd48343;
        10'd282 : ch2 = 16'd48436;
        default : ch2 = 0;
    endcase

    chan_mix = ch1 + ch2;

    if(chan_mix > 16'hFFFF)
        sample = 16'h7fff;
    else
        sample = chan_mix[15:0] - 16'd32768;

  end

endmodule
