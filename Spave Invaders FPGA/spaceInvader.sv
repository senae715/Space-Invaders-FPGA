//Modules for the design of a Space Invaders emulator
module spaceInv(input  logic clk, reset, start,
				input logic left, right, shoot,
				output logic vgaclk,          // 25.175 MHz VGA clock 
				output logic hsync, vsync, 
				output logic sync_b, blank_b, // to monitor & DAC 
				output logic [7:0] r, g, b);  // to video DAC
	
	//Pixel location
	logic [9:0] x, y;
	//Different entities to display
	logic player, laser, bul, border, text;
	//Position of entities
	logic [9:0] pEdge, aLeft, bulBot, bulL, lasBot, lasL, aLow;
	//Internal clocks
	logic pClk, aClk;
	//Counters for clocks
	logic[26:0] bCount, lCount;
	//player direction and player lives
	logic [1:0] dir, lives;
	//Output for if alien or player gets hit
	logic play, aCol, pCol;
	//Number of invaders alive
	logic [5:0] invaders;
	//Output logic for the aliens
	logic [49:0] aliens, aHit, aBot;
	
	//enumerated logic for gamestate
	typedef enum logic [1:0] {title, game, endS} statetype;
	statetype state, nextstate;
	
	//flip flip for generating state
	always_ff @(posedge clk, posedge reset)
	begin
		if(reset)
			state <= title;
		else
			state <= nextstate;
	end
	
	//flip flop for the clocks needed for game
	always_ff @(posedge clk, posedge reset)
	begin
		if (reset) 
		begin
		   vgaclk <= 1'b0;
		   aClk <= 1'b0;
		   bCount <= 0;
		   lCount <= 0;
		end
		else 
		begin
			vgaclk = ~vgaclk;
			bCount <= bCount + 27'd1;
			lCount <= lCount + 27'd1;
			if(bCount == 25000000) 
			begin
				bCount <= 0;
				aClk = ~aClk;
			end
			else if(lCount == 2000000)
			begin
				lCount <= 0;
				pClk <= ~pClk;
			end
		end
	end
	
	//Combinational logic for gamestate
	always_comb
	begin	
		case(state)
			title: begin
				   if(start) nextstate = game;
				   else		 nextstate = title;
				   end
			game:  begin
				   if(play)  nextstate = game;
				   else		 nextstate = endS;
				   end
			endS:  begin
				   if(reset) nextstate = title;
				   else		 nextstate = endS;
				   end
			default:		 nextstate = title;
		endcase
	end
	
	//Direction to move player
	assign dir = {left, right};
	//Assigns data for aliens
	assign aCol = (aHit != 50'd0);
	assign alien = (aliens != 50'd0);
	assign aLow = aBot[49];
				
	//Vga controller to do timings and set signals
	vgaController vgaCont(vgaclk, reset, hsync, vsync, sync_b, blank_b, x, y);
	//Video gen sets the color for each pixel
	videoGen vidGen(x, y, player, alien, laser, bul, border, text, r, g, b);
	
	
	//Keeps track of score and if game is active
	playG playG(pClk, start, aCol, pCol, aLow, invaders, lives, play);	
	//Generates the player, moves them, and determines if they got hit
	genP genP(x, y, lasBot, lasL, pClk, start, state, dir, pEdge, pCol, player);
	//Generates the player bullet
	pBul pBul(x, y, pEdge, pClk, shoot, aCol, bulBot, bulL, bul);
	//Generates the border for the game
	genB genB(x, y, border);
	//Generates the text displayed during the game
	genT genT(x, y, state, lives, vgaclk, text);
	//Generates the alien laser
	aLaser aLaser(x, y, pEdge, pClk, start, pCol, state, lasBot, lasL, laser);
	
	//Generates the alien invaders
	genA a1(x, y, 10'd174, 10'd12, bulTop, bulL, aclk, start, state, aBot[0], aHit[0], aliens[0]);
	genA a2(x, y, 10'd210, 10'd12, bulTop, bulL, aclk, start, state, aBot[1], aHit[1], aliens[1]);
	genA a3(x, y, 10'd246, 10'd12, bulTop, bulL, aclk, start, state, aBot[2], aHit[2], aliens[2]);
	genA a4(x, y, 10'd282, 10'd12, bulTop, bulL, aclk, start, state, aBot[3], aHit[3], aliens[3]);
	genA a5(x, y, 10'd318, 10'd12, bulTop, bulL, aclk, start, state, aBot[4], aHit[4], aliens[4]);
	genA a6(x, y, 10'd354, 10'd12, bulTop, bulL, aclk, start, state, aBot[5], aHit[5], aliens[5]);
	genA a7(x, y, 10'd390, 10'd12, bulTop, bulL, aclk, start, state, aBot[6], aHit[6], aliens[6]);
	genA a8(x, y, 10'd426, 10'd12, bulTop, bulL, aclk, start, state, aBot[7], aHit[7], aliens[7]);
	genA a9(x, y, 10'd462, 10'd12, bulTop, bulL, aclk, start, state, aBot[8], aHit[8], aliens[8]);
	genA a10(x, y, 10'd498, 10'd12, bulTop, bulL, aclk, start, state, aBot[9], aHit[9], aliens[9]);
	genA a11(x, y, 10'd174, 10'd40, bulTop, bulL, aclk, start, state, aBot[10], aHit[10], aliens[10]);
	genA a12(x, y, 10'd210, 10'd40, bulTop, bulL, aclk, start, state, aBot[11], aHit[11], aliens[11]);
	genA a13(x, y, 10'd246, 10'd40, bulTop, bulL, aclk, start, state, aBot[12], aHit[12], aliens[12]);
	genA a14(x, y, 10'd282, 10'd40, bulTop, bulL, aclk, start, state, aBot[13], aHit[13], aliens[13]);
	genA a15(x, y, 10'd318, 10'd40, bulTop, bulL, aclk, start, state, aBot[14], aHit[14], aliens[14]);
	genA a16(x, y, 10'd354, 10'd40, bulTop, bulL, aclk, start, state, aBot[15], aHit[15], aliens[15]);
	genA a17(x, y, 10'd390, 10'd40, bulTop, bulL, aclk, start, state, aBot[16], aHit[16], aliens[16]);
	genA a18(x, y, 10'd426, 10'd40, bulTop, bulL, aclk, start, state, aBot[17], aHit[17], aliens[17]);
	genA a19(x, y, 10'd462, 10'd40, bulTop, bulL, aclk, start, state, aBot[18], aHit[18], aliens[18]);
	genA a20(x, y, 10'd498, 10'd40, bulTop, bulL, aclk, start, state, aBot[19], aHit[19], aliens[19]);
	genA a21(x, y, 10'd174, 10'd68, bulTop, bulL, aclk, start, state, aBot[20], aHit[20], aliens[20]);
	genA a22(x, y, 10'd210, 10'd68, bulTop, bulL, aclk, start, state, aBot[21], aHit[21], aliens[21]);
	genA a23(x, y, 10'd246, 10'd68, bulTop, bulL, aclk, start, state, aBot[22], aHit[22], aliens[22]);
	genA a24(x, y, 10'd282, 10'd68, bulTop, bulL, aclk, start, state, aBot[23], aHit[23], aliens[23]);
	genA a25(x, y, 10'd318, 10'd68, bulTop, bulL, aclk, start, state, aBot[24], aHit[24], aliens[24]);
	genA a26(x, y, 10'd354, 10'd68, bulTop, bulL, aclk, start, state, aBot[25], aHit[25], aliens[25]);
	genA a27(x, y, 10'd390, 10'd68, bulTop, bulL, aclk, start, state, aBot[26], aHit[26], aliens[26]);
	genA a28(x, y, 10'd426, 10'd68, bulTop, bulL, aclk, start, state, aBot[27], aHit[27], aliens[27]);
	genA a29(x, y, 10'd462, 10'd68, bulTop, bulL, aclk, start, state, aBot[28], aHit[28], aliens[28]);
	genA a30(x, y, 10'd498, 10'd68, bulTop, bulL, aclk, start, state, aBot[29], aHit[29], aliens[29]);
	genA a31(x, y, 10'd174, 10'd96, bulTop, bulL, aclk, start, state, aBot[30], aHit[30], aliens[30]);
	genA a32(x, y, 10'd210, 10'd96, bulTop, bulL, aclk, start, state, aBot[31], aHit[31], aliens[31]);
	genA a33(x, y, 10'd246, 10'd96, bulTop, bulL, aclk, start, state, aBot[32], aHit[32], aliens[32]);
	genA a34(x, y, 10'd282, 10'd96, bulTop, bulL, aclk, start, state, aBot[33], aHit[33], aliens[33]);
	genA a35(x, y, 10'd318, 10'd96, bulTop, bulL, aclk, start, state, aBot[34], aHit[34], aliens[34]);
	genA a36(x, y, 10'd354, 10'd96, bulTop, bulL, aclk, start, state, aBot[35], aHit[35], aliens[35]);
	genA a37(x, y, 10'd390, 10'd96, bulTop, bulL, aclk, start, state, aBot[36], aHit[36], aliens[36]);
	genA a38(x, y, 10'd426, 10'd96, bulTop, bulL, aclk, start, state, aBot[37], aHit[37], aliens[37]);
	genA a39(x, y, 10'd462, 10'd96, bulTop, bulL, aclk, start, state, aBot[38], aHit[38], aliens[38]);
	genA a40(x, y, 10'd498, 10'd96, bulTop, bulL, aclk, start, state, aBot[39], aHit[39], aliens[39]);
	genA a41(x, y, 10'd174, 10'd124, bulTop, bulL, aclk, start, state, aBot[40], aHit[40], aliens[40]);
	genA a42(x, y, 10'd210, 10'd124, bulTop, bulL, aclk, start, state, aBot[41], aHit[41], aliens[41]);
	genA a43(x, y, 10'd246, 10'd124, bulTop, bulL, aclk, start, state, aBot[42], aHit[42], aliens[42]);
	genA a44(x, y, 10'd282, 10'd124, bulTop, bulL, aclk, start, state, aBot[43], aHit[43], aliens[43]);
	genA a45(x, y, 10'd318, 10'd124, bulTop, bulL, aclk, start, state, aBot[44], aHit[44], aliens[44]);
	genA a46(x, y, 10'd354, 10'd124, bulTop, bulL, aclk, start, state, aBot[45], aHit[45], aliens[45]);
	genA a47(x, y, 10'd390, 10'd124, bulTop, bulL, aclk, start, state, aBot[46], aHit[46], aliens[46]);
	genA a48(x, y, 10'd426, 10'd124, bulTop, bulL, aclk, start, state, aBot[47], aHit[47], aliens[47]);
	genA a49(x, y, 10'd462, 10'd124, bulTop, bulL, aclk, start, state, aBot[48], aHit[48], aliens[48]);
	genA a50(x, y, 10'd498, 10'd124, bulTop, bulL, aclk, start, state, aBot[49], aHit[49], aliens[49]);

endmodule

//Module to generate and move the player
module genP(input logic [9:0] x, y, lasBot, lasL,
			 input logic clk, start,
			 input logic [1:0] state, dir,
			 output logic [9:0] l,
			 output logic pCol, player);
	
	//right side of player character
	logic [9:0] r; 
	
	//character location on screen
	always_ff @(posedge clk)
	begin
		if(start)
		begin
			l <= 10'd300;
			r <= 10'd340;
		end
		//move left
		else if(dir == 2'd2 && l != 10'd100)
		begin
			l <= l - 10'd10;
			r <= r - 10'd10;
		end
		//move right
		else if(dir == 2'd1 && r != 10'd540)
		begin
			l <= l + 10'd10;
			r <= r + 10'd10;
		end
	end
	
	//detect collision
	always_ff @(posedge clk)
	begin
		if(lasL >= l && lasL <= r && lasBot == 10'd410 && (state == 2'd1))
			pCol <= 1;
		else
			pCol <= 0;
	end
	
	//If x,y coordinates are where player is goes high
	assign player = (x >= l & x < r & y >= 10'd410 & y <= 10'd440 & (state == 2'd1));
	
endmodule

//Module to generate and handle each alien
module genA(input logic [9:0] x, y, 
			 input logic [9:0] startR, startTop,
			 input logic [9:0] bulBot, bulL,
			 input logic clk, start,
			 input logic [1:0] state,
			 output logic aBot, aCol, alien);

	logic dir, active;
	logic [9:0] left, right, top, bot;
	logic [2:0] cnt;
	
	always_ff @(posedge clk, posedge start)
	begin
		if(start)
		begin
			dir <= 0;
			cnt <= 3'd3;
			left <= startR - 10'd32;
			bot <= startTop + 10'd24;
			right <= startR;
			top <= startTop;
			active <= 1;
		end
		else if(aCol == 1)
		begin
			active <= 0;
		end
		else if(bot == 10'd380)
		begin
			aBot <= 1;
		end
		else if(dir == 0 && cnt < 3'd7)
		begin
			left <= left + 10'd10;
			right <= right + 10'd10;
			cnt <= cnt + 1;
		end
		else if(dir == 1 && cnt < 3'd7)
		begin
			left <= left - 10'd10;
			right <= right - 10'd10;
			cnt <= cnt + 1;
		end
		else if(cnt == 3'd7)
		begin
			bot <= bot + 10'd10;
			top <= top + 10'd10;
			dir <= ~dir;
			cnt <= 3'd0;
		end
		else 
			active <= 0;
	end
	
	always_ff @(posedge clk)
	begin
		if(bulL >= left && bulL <= right && bulBot == bot && (state == 2'd1))
			aCol <= 1;
		else
			aCol <= 0;
	end

	assign alien = (x >= left & x <= right & y >= top & y <= bot & active & (state == 2'd1));

endmodule

//Module to allow the player to shoot
module pBul(input logic [9:0] x, y, pEdge,
			input logic clk, shoot, hit,
			output logic [9:0] bot, l,
			output logic bul);
	
	//right side and top of bullet
	logic [9:0] r, top;
	//if bullet is active
	logic active;
	
	//Generates and moves bullet accross screen
	always_ff @(posedge clk, posedge shoot)
	begin
		//starts bullet
		if(shoot)
		begin 
			l <= pEdge + 10'd20;
			r <= pEdge + 10'd21;
			top <= 10'd400;
			bot <= 10'd410;
			active <= 1;
		end
		//if bullet hits
		else if(hit)
		begin
			top <= 10'd0;
			active <= 0;
		end
		//if bullet leaves screen
		else if(top != 10'd0)
		begin
			top <= top - 10'd10;
			bot <= bot - 10'd10;
		end
		else
		begin
			top <= 10'd0;
			bot <= 10'd0;
			l  <= 10'd0;
			active <= 0;
		end
	end
	
	//Goes high if x,y coordinates are where bullet is
	assign bul = (x >= l & x <= r & y >= top & y <= bot & active);

endmodule

//Module to have aliens shoot at player
module aLaser(input logic [9:0] x, y, pEdge, 
			  input logic clk, start, hit, 
			  input logic [1:0] state, 
			  output logic [9:0] bot, left,
			  output logic laser);

	//Logic for the aliens laser
	logic [9:0] right, top;
	logic active;
	//count so alien doesn't shoot while laser is on screen
	logic [5:0] cnt; 
	
	//Counter for how long to wait between shots
	always_ff @(posedge clk, posedge start)
	begin
		if(start)
			cnt <= 0;
		else if (cnt == 6'd50) 
			cnt <= 0 ; 
		else
			cnt <= cnt + 1;
	end	
	
	//Generates and moves laser across screen
	always_ff @(posedge clk)
	begin
		//starts laser
		if(cnt == 0) 
		begin
			left <= pEdge + 10'd20;
			right <= pEdge + 10'd21;
			top <= 10'd0;
			bot <= 10'd10;
			active <= 1;
		end
		//if laser hits target
		else if(hit)
		begin
			active <= 0;
		end
		//if laser leaves screen
		else if(top <= 10'd480)
		begin
			top <= top + 10'd10;
			bot <= bot + 10'd10;
		end
		else 
			active <= 0; 
		
	end
	
	//Goes high if x,y coordinates are where laser is
	assign laser = (x >= left & x <= right & y >= top & y <= bot & active & (state == 2'b01));

endmodule

//Module to generate the game border
module genB(input logic [9:0] x, y,
			  output logic inBor);
	
	assign inBor = (x == 10'd99 | x == 10'd541 & y >= 10'd0 & y <= 10'd480);
	
endmodule

//Module to generate the text that appears during the game
module genT(input logic [9:0] x, y,
			input logic [1:0] state, lives,
			input logic clk,
			output logic text);
			
	logic [9:0] left, right, top, bot;
	
	
	always_ff @(posedge clk)
	begin
		if(state == 2'd0) //title
		begin
			left <= 10'd260;
			right <= 10'd380;
			top <= 10'd200;
			bot <= 10'd280;
		end
		else if(state == 2'd1 && lives == 2'd3) //3 lives
		begin
			left <= 10'd570;
			right <= 10'd610;
			top <= 10'd10;
			bot <= 10'd60;
		end
		else if(state == 2'd1 && lives == 2'd2) //2 lives
		begin
			left <= 10'd570;
			right <= 10'd610;
			top <= 10'd70;
			bot <= 10'd120;
		end
		else if(state == 2'd1 && lives == 2'd1) //1 life
		begin
			left <= 10'd570;
			right <= 10'd610;
			top <= 10'd130;
			bot <= 10'd180;
		end
		else if(state == 2'd2 && lives == 2'd0) //lose
		begin
			left <= 10'd260;
			right <= 10'd380;
			top <= 10'd100;
			bot <= 10'd180;
		end
		else // win
		begin
			left <= 10'd260;
			right <= 10'd380;
			top <= 10'd200;
			bot <= 10'd280;
		end
	end
	
	//Goes high if x,y corrdinate is in bounds
	assign text = (x >= left & x <= right & y >= top & y <= bot);
	
endmodule

//Module to determine if game is over and score
module playG(input logic clk, start, aCol, pCol, aBot,
			 output logic [5:0] invaders,
			 output logic [1:0] lives,
			 output logic play);
	
	//Determines the score
	always_ff @(posedge clk, posedge start)
	begin
		//On start sets lives and invader count
		if(start)
		begin
			invaders <= 6'd2;
			lives <= 2'd3;
		end
		//If aliens reach bottom loses
		else if(aBot)
		begin
			lives <= 0;
		end
		//If player gets shot
		else if(pCol)
		begin
			lives <= lives - 1;
		end
		//If alien gets shot
		else if(aCol)
		begin
			invaders <= invaders - 1;
		end
		else
			lives <= lives;
	end
	
	//Play is high while there are still aliens and the player has lives
	assign play = (invaders != 6'd0 & lives != 2'd0);

endmodule

//Determines the colors for each pixel
module videoGen(input logic [9:0] x, y,
				input logic player, alien, laser, bul, border, text,
				output logic [7:0] r, g, b);
							
	assign r = (alien | laser | text) ? 8'hFF : 8'h00;
	assign g = (player | alien | text) ? 8'hFF : 8'h00;
	assign b = (alien | bul | border | text) ? 8'hFF : 8'h00;

endmodule
	
	
module vgaController #(parameter HBP     = 10'd48,   // horizontal back porch
                                 HACTIVE = 10'd640,  // number of pixels per line
                                 HFP     = 10'd16,   // horizontal front porch
                                 HSYN    = 10'd96,   // horizontal sync pulse = 60 to move electron gun back to left
                                 HMAX    = HBP + HACTIVE + HFP + HSYN, //48+640+16+96=800: number of horizontal pixels (i.e., clock cycles)
                                 VBP     = 10'd32,   // vertical back porch
                                 VACTIVE = 10'd480,  // number of lines
                                 VFP     = 10'd11,   // vertical front porch
                                 VSYN    = 10'd2,    // vertical sync pulse = 2 to move electron gun back to top
                                 VMAX    = VBP + VACTIVE + VFP  + VSYN) //32+480+11+2=525: number of vertical pixels (i.e., clock cycles)                      

     (input  logic vgaclk, reset,
      output logic hsync, vsync, sync_b, blank_b, 
      output logic [9:0] hcnt, vcnt); 

      always @(posedge vgaclk, posedge reset) begin 
        if (reset) begin
          hcnt <= 0;
          vcnt <= 0;
        end
        else  begin
          hcnt++; 
      	   if (hcnt == HMAX) begin 
            hcnt <= 0; 
  	        vcnt++; 
  	        if (vcnt == VMAX) 
  	          vcnt <= 0; 
          end 
        end
      end 
	  
      assign hsync  = ~( (hcnt >= (HACTIVE + HFP)) & (hcnt < (HACTIVE + HFP + HSYN)) ); 
      assign vsync  = ~( (vcnt >= (VACTIVE + VFP)) & (vcnt < (VACTIVE + VFP + VSYN)) ); 
      assign sync_b = 1'b0;
 
      assign blank_b = (hcnt < HACTIVE) & (vcnt < VACTIVE); 
endmodule