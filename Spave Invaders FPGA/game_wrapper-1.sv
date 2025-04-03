module game_wrapper(input  logic       CLOCK_50,
                  input  logic [1:0] SW,
				  input	 logic [3:0] KEY,
                  output logic       VGA_CLK, 
                  output logic       VGA_HS,
                  output logic       VGA_VS,
                  output logic       VGA_SYNC_N,
                  output logic       VGA_BLANK_N,
                  output logic [7:0] VGA_R,
                  output logic [7:0] VGA_G,
                  output logic [7:0] VGA_B);
						

  spaceInv spaceInv(CLOCK_50, SW[0], ~KEY[1], ~KEY[3], ~KEY[2], ~KEY[0], VGA_CLK, VGA_HS, VGA_VS, VGA_SYNC_N, VGA_BLANK_N,
			 VGA_R, VGA_G, VGA_B);
			 
endmodule