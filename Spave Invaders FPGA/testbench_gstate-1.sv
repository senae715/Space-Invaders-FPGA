module testbench_gstate();
	logic clk, reset, start;
	logic left, right, shoot, play;
	logic vgaclk, hsync, vsync;
	logic sync_b, blank_b;
	logic [7:0] r, g, b;
	
	spaceInv dut(clk, reset, start, left, right, shoot, play, vgaclk, hsync, vsync, sync_b, blank_b, r, g, b);
	
	always
	begin
		clk = 1'b1; #5; clk = 1'b0; #5;
	end
	
	initial
	begin
		start = 1'b0; play = 1'b0;
		reset = 1'b1; #22; reset = 1'b0;
		#70; start = 1'b1; play = 1'b1;
		#70; start = 1'b0; play = 1'b1;
		#70; start = 1'b0; play = 1'b0;
	end
	
endmodule