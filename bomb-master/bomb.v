module bomb(reset, clock, button, stop, iwanttostep, isBomb, cancel, led, verf, verf1, keypadC, keypadR, dotC, dotR, hex1, hex2, hex3, hex4, hex5, hex6, vga_hs, vga_vs, vga_r, vga_g, vga_b);
`define fre 32'd50000000
input clock, reset, stop, cancel, isBomb, iwanttostep;
input [3:0]button;
input [3:0]keypadC;

output [3:0]keypadR;
output [15:0]dotC;
output [7:0]dotR;
output [6:0]hex1, hex2, hex3, hex4, hex5, hex6;
output [7:0]led;
output verf, verf1;

reg [15:0]dotC;
reg [7:0]dotR;
reg [31:0]cnt1, cnt2, cnt3;//1s, 10k, 0.5s
reg [7:0]led;
reg [3:0]tmp1, tmp2, tmp3, tmp4, tmp5, tmp6;//for timing
reg div_clk_1s, div_clk_10k;//frequency divider
reg twinkle;//frequency divider fo miner targget
reg [3:0]area;
reg [3:0]State,NextState;
reg [3:0]times;
reg [127:0]pos, twink;
reg second;//count if click twice
reg gameover;
reg verf;
reg win;
wire verf1;
wire [3:0]isMove;
wire [3:0]index;
wire K;
parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6, S7 = 7, S8 = 8, S9 = 9;

reg [2:0]type;
reg typeGameover;
output vga_hs, vga_vs;
output [3:0] vga_r, vga_g, vga_b;

reg vga_hs, vga_vs;
reg [3:0] vga_r, vga_g, vga_b;
reg [10:0] counths;
reg [9:0] countvs;
reg [9:0] p_h, p_v;
reg valid;

reg [31:0]c1,c3;
reg [1:0]c2;
reg [2:0]c4;
reg [31:0]c5,c7;
reg c6;
reg [2:0]c8;

always @(posedge clock)
begin
	if(c5 == `fre/4)
	begin
		c5 = 0;
		c6 = c6 + 1;
	end
	else 
	begin 
		c5 = c5 + 1;
	end	
end

always @(posedge clock)
begin
	if(c7 == 5000)
	begin
		c7 = 0;
		c8 = c8 + 1;
	end
	else 
		c7 = c7 + 1;
end

always @(posedge clock)
begin
	
if(c1 == `fre/2)
	begin
		c1 = 0;
		c2 = c2 + 1;
		if(c2 == 4)
		begin
			c2 = 0;
		end
	end
	else 
	begin 
		c1 = c1 + 1;
	end	
end

always @(posedge clock)
begin
	if(c3 == 5000)
	begin
		c3 = 0;
		c4 = c4 + 1;
	end
	else
	begin
		c3 = c3 + 1;
	end
end

assign verf1 = verf;

key(.clk(clock), .rst(reset), .Data(index), .keypadRow(keypadR), .keypadCol(keypadC), .KEY(K));

/*scan all rows using 10 KHz*/
always @(negedge reset or posedge div_clk_10k)
begin
	if(!reset)
		times=4'b0000;
	else
	begin
		if(times == 8)
			times=0;
		else
			times=times+1;
	end
end

always @(negedge reset or posedge K or posedge cancel)
begin
	if(!reset)
	begin
		type <= 0;
		pos[127:0] <= 0;
//		pos[127:0] <= -1-(1<<87)-(1<<86)-(1<<85);
		twink[127:0] <= 0 ;
		second <= 0;
		verf <= 1;
	end
	else
	begin
		if(cancel == 1)
		begin
			if(stop == 1)
			begin
				second <= 0;
				verf <= 1;
			end
		end
		else if(stop == 1)
		begin
			if(second == 0) 
			begin
				second <= 1;
				verf <= ~verf;
			end
			else if(isBomb == 1 && pos[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] != 1 && twink[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] == 0)//bug2 fixed
			begin
				type <= 3;
				twink[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] <= 1;
				second <= 0;
				verf <= ~verf;
			end
			else if(isBomb == 1 && pos[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] != 1 && twink[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] == 1)//bug2 fixed
			begin
				type <= 4;
				twink[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] <= 0;
				second <= 0;
				verf <= ~verf;
			end
			else
			begin
				if(iwanttostep == 1 && twink[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] == 1)
				begin
					type <= 1;
					pos[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] <= 1;
					twink[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] <= 0;
					verf <= ~verf;
					second <= 0;
				end
				else if(twink[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] == 0 && pos[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] == 0)
				begin
					type <= 1;
					pos[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] <= 1;
					verf <= ~verf;
					second <= 0;
				end
				else if(twink[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] == 1)
				begin
					type <= 3;
					verf <= ~verf;
					second <= 0;
				end
				else if(pos[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] == 0)
				begin
					type <= 1;
					pos[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] <= 1;
					verf <= ~verf;
					second <= 0;
				end
				else if(pos[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] == 1)
				begin
					type <= 5;
					pos[16*((index/4)+(State/4)*4)+4*(State%4)+index%4] <= 1;
					verf <= ~verf;
					second <= 0;
				end
				else//bug1 fixed
				begin
					second <= 0;
					verf <= ~verf;
				end
			end
		end
		else
			verf <= 1;
	end
end

always @(times)
begin
	if(!reset)
	begin
		dotC = 16'b0000000000000000;
		dotR = 8'b11111111;
	end
	else if(win)
	begin
		begin
			if(c2 == 0)
			begin
				case(c4)
					0:dotR=8'b01111111;
					1:dotR=8'b10111111;
					2:dotR=8'b11011111;
					3:dotR=8'b11101111;
					4:dotR=8'b11110111;
					5:dotR=8'b11111011;
					6:dotR=8'b11111101;
					7:dotR=8'b11111110;
				endcase
				case(c4)
					0:dotC=16'b0000_0000_0000_0000;
					1:dotC=16'b1110_1110_1110_1110;
					2:dotC=16'b0010_0010_0010_0010;
					3:dotC=16'b1110_1110_1110_1110;
					4:dotC=16'b1010_1010_1010_1010;
					5:dotC=16'b1110_1110_1110_1110;
					6:dotC=16'b0000_0000_0000_0000;
					7:dotC=16'b0000_0000_0000_0000;
				endcase
			end
			else if(c2 == 3)
			begin
				case(c4)
					0:dotR=8'b01111111;
					1:dotR=8'b10111111;
					2:dotR=8'b11011111;
					3:dotR=8'b11101111;
					4:dotR=8'b11110111;
					5:dotR=8'b11111011;
					6:dotR=8'b11111101;
					7:dotR=8'b11111110;
				endcase
				case(c4)
					0:dotC=16'b0000_0000_0000_0000;
					1:dotC=16'b1101110_1110_11101;
					2:dotC=16'b0100010001000100;
					3:dotC=16'b1101110_1110_11101;
					4:dotC=16'b0101010_1010_10101;
					5:dotC=16'b1101110_1110_11101;
					6:dotC=16'b0000_0000_0000_0000;
					7:dotC=16'b0000_0000_0000_0000;
				endcase
			end
			else if(c2 == 2)
			begin
				case(c4)
					0:dotR=8'b01111111;
					1:dotR=8'b10111111;
					2:dotR=8'b11011111;
					3:dotR=8'b11101111;
					4:dotR=8'b11110111;
					5:dotR=8'b11111011;
					6:dotR=8'b11111101;
					7:dotR=8'b11111110;
				endcase
				case(c4)
					0:dotC=16'b0000_0000_0000_0000;
					1:dotC=16'b10_1110_1110_111011;
					2:dotC=16'b1000100010001000;
					3:dotC=16'b10_1110_1110_111011;
					4:dotC=16'b10_1010_1010_101010;
					5:dotC=16'b10_1110_1110_111011;
					6:dotC=16'b0000_0000_0000_0000;
					7:dotC=16'b0000_0000_0000_0000;
				endcase
			end
			else
			begin
				case(c4)
					0:dotR=8'b01111111;
					1:dotR=8'b10111111;
					2:dotR=8'b11011111;
					3:dotR=8'b11101111;
					4:dotR=8'b11110111;
					5:dotR=8'b11111011;
					6:dotR=8'b11111101;
					7:dotR=8'b11111110;
				endcase
				case(c4)
					0:dotC=16'b0000_0000_0000_0000;
					1:dotC=16'b0_1110_1110_1110111;
					2:dotC=16'b0001000100010001;
					3:dotC=16'b0_1110_1110_1110111;
					4:dotC=16'b0_1010_1010_1010101;
					5:dotC=16'b0_1110_1110_1110111;
					6:dotC=16'b0000_0000_0000_0000;
					7:dotC=16'b0000_0000_0000_0000;
				endcase
			end
		end
	end
	else if(!gameover)
	begin
		case(times)
			0:
			begin
				dotR = 8'b01111111;
				dotC = twinkle ? pos[15:0] + twink[15:0] : pos[15:0];
			end
			1:
			begin
				dotR = 8'b10111111;
				dotC = twinkle ? pos[31:16] + twink[31:16] : pos[31:16];
			end
			2:
			begin
				dotR = 8'b11011111;
				dotC = twinkle ? pos[47:32] + twink[47:32] : pos[47:32];
			end
			3:
			begin
				dotR = 8'b11101111;
				dotC = twinkle ? pos[63:48] + twink[63:48] : pos[63:48];
			end
			4:
			begin
				dotR = 8'b11110111;
				dotC = twinkle ? pos[79:64] + twink[79:64] : pos[79:64];
			end
			5:
			begin
				dotR = 8'b11111011;
				dotC = twinkle ? pos[95:80] + twink[95:80] : pos[95:80];
			end
			6:
			begin
				dotR = 8'b11111101;
				dotC = twinkle ? pos[111:96] + twink[111:96] : pos[111:96];
			end
			7:
			begin
				dotR = 8'b11111110;
				dotC = twinkle ? pos[127:112] + twink[127:112] : pos[127:112];
			end
		endcase
	end
	else
	begin
		if(c6 == 1)
		begin
		case(c8)
				0:dotR=8'b01111111;
				1:dotR=8'b10111111;
				2:dotR=8'b11011111;
				3:dotR=8'b11101111;
				4:dotR=8'b11110111;
				5:dotR=8'b11111011;
				6:dotR=8'b11111101;
				7:dotR=8'b11111110;
		endcase
		case(c8)
				0:dotC=16'b0111111001111110;
				1:dotC=16'b0111111001111110;
				2:dotC=16'b0000011000000110;
				3:dotC=16'b0111011001110110;
				4:dotC=16'b0111011001110110;
				5:dotC=16'b0110011001100110;
				6:dotC=16'b0111111001111110;
				7:dotC=16'b0111111001111110;
		endcase
	   end
		else
		begin
			 dotR = 8'b11111111;
			 dotC = 0;
		end
	end
end

/*gameover*/
always @(negedge reset or posedge clock or posedge pos[87])//miner
begin
	if(!reset)
	begin
		gameover = 0;
		State = S0;
		typeGameover = 0;
		win = 0;
	end
	else
	begin
		if(pos[87] == 1)
		begin
			gameover = 1;
			State = S8;
			typeGameover = 1;
		end
		else if(pos == -1-(1<<87))
		begin
			win = 1;
			State = S9;
		end
		else
		begin
			State = NextState;
			typeGameover = 0;
			gameover = 0;
		end
	end
end
	
/*create 10 KHz*/
always @(negedge reset or posedge clock)
begin
	if( !reset )
	begin
		cnt2 <= 32'd0;
		div_clk_10k <= 1'b0;
	end
	else
	begin
		if( cnt2 == 32'd2500)
		begin
			cnt2 <= 32'd0;
			div_clk_10k <= ~div_clk_10k;
		end
		else
		begin
			cnt2 <= cnt2 + 32'd1;
		end
	end
end

/*create 1 sec*/
always @(negedge reset or posedge clock)
begin
	if( !reset )
	begin
		cnt1 <=32'd0;
		div_clk_1s <= 1'b0;
		cnt3 <=32'd0;
		twinkle <= 1'b0;
	end
	else
	begin
		if( cnt3 == 32'd12500000)
		begin
			twinkle <= ~twinkle;
			cnt3 <= 32'd0;
		end
		else
			cnt3 <= cnt3 + 32'd1;
		if(cnt1 == 32'd25000000)
		begin
			cnt1 <= 32'd0;
			div_clk_1s <= ~div_clk_1s;
		end
		else
		begin
			cnt1 <= cnt1 + 32'd1;
		end
	end
end

/*timing using 1 sec*/
always @(negedge reset or posedge div_clk_1s)
begin
	if(!reset)
	begin
		tmp1 = 0;
		tmp2 = 0;
		tmp3 = 0;
		tmp4 = 0;
		tmp5 = 0;
		tmp6 = 0;
	end
	else
	begin
		if(stop == 1 && gameover != 1 && win != 1)
		begin
			tmp1 = tmp1+1;
			if(tmp1 == 10)
			begin
				tmp1 = 0;
				tmp2 = tmp2+1;
			end
			if(tmp2 == 6)
			begin
				tmp2 = 0;
				tmp3 = tmp3+1;
			end
			if(tmp3 == 10)
			begin
				tmp3 = 0;
				tmp4 = tmp4+1;
			end
			if(tmp4 == 6)
			begin
				tmp4 = 0;
				tmp5 = tmp5+1;
			end
			if(tmp5 == 10)
			begin
				tmp5 = 0;
				tmp6 = tmp6+1;
			end
		end
		else
		begin
			tmp1 = tmp1;//when pause
		end
	end
end

/*call seven to display time (hh:mm:ss)*/
Seven s1(.sin(tmp1), .sout(hex1));//s
Seven s2(.sin(tmp2), .sout(hex2));//s
Seven s3(.sin(tmp3), .sout(hex3));//m
Seven s4(.sin(tmp4), .sout(hex4));//m
Seven s5(.sin(tmp5), .sout(hex5));//h
Seven s6(.sin(tmp6), .sout(hex6));//h

/*call move to detect if move button is click*/
move(.clk(clock), .rst(reset), .button(button[0]), .LED(isMove[0]));
move(.clk(clock), .rst(reset), .button(button[1]), .LED(isMove[1]));
move(.clk(clock), .rst(reset), .button(button[2]), .LED(isMove[2]));
move(.clk(clock), .rst(reset), .button(button[3]), .LED(isMove[3]));

/*select area after moving*/
always@(posedge isMove[0] or posedge isMove[1] or posedge isMove[2] or posedge isMove[3])
begin
	case(State)//Moore
		S0:
		begin
			if(isMove[0] == 1)
				NextState = S1;
			else if(isMove[2] == 1)
				NextState = S4;
			else
				NextState = S0;
		end
		S1:
		begin
			if(isMove[0] == 1)
				NextState = S2;
			else if(isMove[2] == 1)
				NextState = S5;
			else if(isMove[1] == 1)
				NextState = S0;
			else
				NextState = S1;
		end
		S2:
		begin
			if(isMove[0] == 1)
				NextState = S3;
			else if(isMove[2] == 1)
				NextState = S6;
			else if(isMove[1] == 1)
				NextState = S1;
			else
				NextState = S2;
		end
		S3:
		begin
			if(isMove[2] == 1)
				NextState = S7;
			else if(isMove[1] == 1)
				NextState = S2;
			else
				NextState = S3;
		end
		S4:
		begin
			if(isMove[0] == 1)
				NextState = S5;
			else if(isMove[3] == 1)
				NextState = S0;
			else
				NextState = S4;
		end
		S5:
		begin
			if(isMove[0] == 1)
				NextState = S6;
			else if(isMove[3] == 1)
				NextState = S1;
			else if(isMove[1] == 1)
				NextState = S4;
			else
				NextState = S5;
			end
		S6:
		begin
			if(isMove[0] == 1)
				NextState = S7;
			else if(isMove[3] == 1)
				NextState = S2;
			else if(isMove[1] == 1)
				NextState = S5;
			else 
				NextState = S6;
		end
		S7:
		begin
			if(isMove[1] == 1)
				NextState = S6;
			else if(isMove[3] == 1)
				NextState = S3;
			else
				NextState = S7;
		end
		default:
			NextState = S0;//bug3 fixed
	endcase
end

/*display area by led*/
always@(State)
begin 
	case(State)
		S7:led = 8'b00000001;
		S6:led = 8'b00000010;
		S5:led = 8'b00000100;
		S4:led = 8'b00001000;
		S3:led = 8'b00010000;
		S2:led = 8'b00100000;
		S1:led = 8'b01000000;
		S0:led = 8'b10000000;
		default:led = 8'b11111111;
	endcase
end

//VGA
always@(negedge reset or posedge clock)
begin
	if(!reset)
	begin
		counths <= 11'd0;
		countvs <= 10'd0;
	end
	else
	begin
		counths <= (counths == 11'd1600) ? 11'd0 : counths + 16'd1;
		countvs <= (countvs == 10'd525) ? 10'd0 : (counths == 11'd1600) ? countvs + 10'd1 : countvs; 
	end
end

always@(negedge reset or posedge clock)
begin
	if(!reset)
	begin
		vga_hs <= 1'b0;
		vga_vs <= 1'b0;
		valid <= 1'b0;
	end
	else
	begin
		vga_hs <= (counths < 11'd192 || counths > 11'd1568) ? 1'b0 : 1'b1;
		vga_vs <= (countvs < 10'd2 || countvs > 10'd515) ? 1'b0 : 1'b1;
		valid <= (countvs > 10'd35 && countvs < 10'd516 && counths > 11'd288 && counths < 11'd1568) ? 1'b1 : 1'b0;
	end
end

always@(negedge reset or posedge clock)
begin
	if(!reset)
	begin
//		type <= 0;
		vga_r <= 4'd0;
		vga_g <= 4'd0;
		vga_b <= 4'd0;
	end
	else
	begin
		if(valid)
		begin
			if(typeGameover == 1)
			begin
				if((countvs - counths + 683 +  928 > 928) && (countvs - counths + 623 +  928 < 928) || (countvs + counths - 1173 +  928 > 928) && (countvs + counths - 1233 +  928 < 928))
				begin
					vga_r <= 4'd15;
					vga_g <= 4'd0;
					vga_b <= 4'd0;
				end
				else
				begin
					vga_r <= 4'd0;
					vga_g <= 4'd0;
					vga_b <= 4'd0;
				end
			end
			else if(type == 1)
			begin
				if(8*(countvs-35-240)*(countvs-275) + 3*(counths-288-640)*(counths-288-640) < 432900 && 8*(countvs-35-240)*(countvs-275) + 3*(counths-288-640)*(counths-288-640) > 156300)
				begin
					vga_r <= 4'd0;
					vga_g <= 4'd15;
					vga_b <= 4'd0;
				end
				else
				begin
					vga_r <= 4'd0;
					vga_g <= 4'd0;
					vga_b <= 4'd0;
				end
			end 
			else if(type == 3)
			begin
				if(8*17*(countvs-275)*(countvs-275)-5*16*(countvs-275)*(counths<928? (counths-928) :928-counths)+3*17*(counths-928)*(counths-928) < 1000000)
				begin
					vga_r <= 4'd15;
					vga_g <= 4'd8;
					vga_b <= 4'd11;
				end
				else
				begin
					vga_r <= 4'd0;
					vga_g <= 4'd0;
					vga_b <= 4'd0;
				end
			end
			else if(type == 4)
			begin
				if(8*17*(countvs-275)*(countvs-275)-5*16*(countvs-275)*(counths<928? (counths-928) :928-counths)+3*17*(counths-928)*(counths-928) < 1000000)
				begin
					vga_r <= 4'd0;
					vga_g <= 4'd0;
					vga_b <= 4'd0;
				end
				else
				begin
					vga_r <= 4'd15;
					vga_g <= 4'd15;
					vga_b <= 4'd15;
				end
			end
			else if(type == 5)
			begin
				if((counths < 668 || counths > 1188 || countvs < 95 || countvs > 455) && counths > 578 && counths < 1278)
				//if((countvs < 335 && countvs > 215 || counths < 988 && counths > 868) && (countvs > 245 || counths > 898))//8*17*(countvs-275)*(countvs-275)-5*16*(countvs-275)*(counths<928? (counths-928) :928-counths)+3*17*(counths-928)*(counths-928) < 1000000)
				begin
					vga_r <= 4'd0;
					vga_g <= 4'd0;
					vga_b <= 4'd15;
				end
				else
				begin
					vga_r <= 4'd0;
					vga_g <= 4'd0;
					vga_b <= 4'd0;
				end
			end
			else
			begin
				vga_r <= 4'd0;
				vga_g <= 4'd0;
				vga_b <= 4'd0;
			end
		end
		else
		begin			
			vga_r <= 4'd0;
			vga_g <= 4'd0;
			vga_b <= 4'd0;
		end
	end
end
endmodule 

/*output number in seven display*/
module Seven(sin, sout);
input [3:0]sin;
output [6:0]sout;
reg [6:0]sout;
always@(sin)
begin
	case(sin)
		4'b 0000:sout=7'b 1000000;
		4'b 0001:sout=7'b 1111001;
		4'b 0010:sout=7'b 0100100;
		4'b 0011:sout=7'b 0110000;
		4'b 0100:sout=7'b 0011001;
		4'b 0101:sout=7'b 0010010;
		4'b 0110:sout=7'b 0000010;
		4'b 0111:sout=7'b 1111000;
		4'b 1000:sout=7'b 0000000;
		4'b 1001:sout=7'b 0010000;
		4'b 1010:sout=7'b 0001000;
		4'b 1011:sout=7'b 0000011;
		4'b 1100:sout=7'b 1000110;
		4'b 1101:sout=7'b 0100001;
		4'b 1110:sout=7'b 0000110;
		4'b 1111:sout=7'b 0001110;
	endcase
end
endmodule

/*move key*/
module move(clk, rst, button, LED);
input clk, rst, button;	
output LED;

reg flagButton;
reg LED;
reg [24:0]delayButton;

always@(posedge clk)
begin
	if(!rst)
	begin
		LED = 1'b0;
		flagButton = 1'b0;
		delayButton = 25'd0;
	end
	else
	begin
		if((!button)&&(!flagButton)) flagButton = 1'b1;
		else if(flagButton)
		begin
			delayButton = delayButton + 1'b1;
			if(delayButton == 25'b1000000000000000000000000)
			begin
				flagButton = 1'b0;
				delayButton = 25'd0;
				LED = 1'b1;
			end
		end
		else LED = 1'b0;
	end
end
endmodule 

/*return index after clicking keypad*/
`define TimeExpire_KEY 32'd3000000//25'b00100000000000000000000000
module key(clk, rst, Data, keypadRow, keypadCol, KEY);
input clk, rst;
input [3:0]keypadCol;

output [3:0]keypadRow;
output [3:0]Data;
output KEY;

reg KEY;
reg [3:0]keypadRow;
reg [3:0]keypadBuf;
reg [24:0]keypadDelay;

SevenSegment seven(.in(keypadBuf), .out(Data));

always@(posedge clk)
begin
	if(!rst)
	begin
		keypadRow = 4'b1110;
		keypadBuf = 4'b0000;
		keypadDelay = 25'd0;
		KEY = 0;
	end
	else
	begin
		if(keypadDelay == `TimeExpire_KEY)
		begin
			keypadDelay = 25'd0;
			case({keypadRow, keypadCol})
				8'b1110_1110 : 
				begin
					keypadBuf = 4'h7;
					KEY = 1;
					end
				8'b1110_1101 : 
				begin
					keypadBuf = 4'h4;
					KEY = 1;
				end
				8'b1110_1011 : 
				begin
					keypadBuf = 4'h1;
					KEY = 1;
				end
				8'b1110_0111 : 
				begin
					keypadBuf = 4'h0;
					KEY = 1;
				end
				8'b1101_1110 : 
				begin
					keypadBuf = 4'h9;
					KEY = 1;
				end
				8'b1101_1101 : 
				begin
					keypadBuf = 4'h6;
					KEY = 1;
				end
				8'b1101_1011 : 
				begin
					keypadBuf = 4'h3;
					KEY = 1;
				end
				8'b1101_0111 : 
				begin
					keypadBuf = 4'hb;
					KEY = 1;
				end
				8'b1011_1110 : 
				begin
					keypadBuf = 4'h8;
					KEY = 1;
				end
				8'b1011_1101 : 
				begin
					keypadBuf = 4'h5;
					KEY = 1;
				end
				8'b1011_1011 : 
				begin
					keypadBuf = 4'h2;
					KEY = 1;
				end
				8'b1011_0111 : 
				begin
					keypadBuf = 4'ha;
					KEY = 1;
				end
				8'b0111_1110 : 
				begin
					keypadBuf = 4'hc;
					KEY = 1;
				end
				8'b0111_1101 : 
				begin
					keypadBuf = 4'hd;
					KEY = 1;
				end
				8'b0111_1011 : 
				begin
					keypadBuf = 4'he;
					KEY = 1;
				end
				8'b0111_0111 : 
				begin
					keypadBuf = 4'hf;
					KEY = 1;
				end
				default     : 
				begin
					keypadBuf = keypadBuf;
					KEY = 0;
				end
			endcase
			case(keypadRow)
				4'b1110 : keypadRow = 4'b1101;
				4'b1101 : keypadRow = 4'b1011;
				4'b1011 : keypadRow = 4'b0111;
				4'b0111 : keypadRow = 4'b1110;
				default: keypadRow = 4'b1110;
			endcase
		end
		else
		begin
			KEY = 0;
			keypadDelay = keypadDelay + 1'b1;
		end
	end
end
endmodule 

/*return number of keypad*/
module SevenSegment(in,out);
input [3:0]in;
output [3:0]out;
reg [3:0]out;
	always@(*)
	begin
		case(in)
			4'h0: out = 12;
			4'h1: out = 13;
			4'h2: out = 9;
			4'h3: out = 5;
			4'h4: out = 14;
			4'h5: out = 10;
			4'h6: out = 6;
			4'h7: out = 15;
			4'h8: out = 11;
			4'h9: out = 7;
			4'ha: out = 8;
			4'hb: out = 4;
			4'hc: out = 3;
			4'hd: out = 2;
			4'he: out = 1;
			4'hf: out = 0;
		endcase
	end
endmodule 