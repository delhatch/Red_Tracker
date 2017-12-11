// This module buffers four lines of camera pixel data AFTER deciding if the pixel is red or not.
//    So the 4 line buffers hold 1 bit at each address. Each buffer holds 1 line of camera data.
// The output of this module is a column (three pixels) of the already-filled data, above
//    the currently filling line.
module red_line_buffer ( 
   input bit_clk,
   input [23:0] pixel,
   input h_sync,
   input [9:0] x_cont,
   // The taps are the column of 3 pixels above the current camera pixel location.
   output reg tap_top,
   output reg tap_middle,
   output reg tap_bottom
);

localparam NUM_BUFFERS = 4;  // number of line buffers.

reg [1:0] WR;
reg [NUM_BUFFERS-1:0] EN;   // one-hot-coded write-enable (wren) signal for the line buffers.

wire [7:0] RED;
wire [7:0] GREEN;
wire [7:0] BLUE;
reg seems_red;

wire T0, T1, T2, T3;

assign RED = pixel[23:16];
assign GREEN = pixel[15:8];
assign BLUE = pixel[7:0];

// Detect red. Put a '1' in the line buffer if this pixel seems very red.
always @ (*) begin
   if( ({1'b0,RED[6:1]} > BLUE[7:0]) && ({1'b0,RED[6:1]} > GREEN[7:0]) ) seems_red = 1'b1; else seems_red = 1'b0;
   end

// WR is a pointer to the line buffer that is currently being filled.
always @ (posedge h_sync) begin
   if( ~h_sync ) begin
      WR <= 0;
      end
   else begin
      if( WR >= (NUM_BUFFERS-1) ) WR <= 0;  // counts from 0 up to the number of buffers - 1.
      else WR <= WR + 1;
   end
end

integer i;
always @(*)
for( i=0; i<NUM_BUFFERS; i=i+1) begin
   if( WR == i ) EN[i] = 1; else EN[i] = 0;
end

// Organize the outputs to allow for easy low-pass filtering
always @ (*)
   case( WR )    // synthesis full_case parallel_case
      0 : begin
             tap_top = T1;
             tap_middle = T2;
             tap_bottom = T3;
          end
      1 : begin
             tap_top = T2;
             tap_middle = T3;
             tap_bottom = T0;
          end
      2 : begin
             tap_top = T3;
             tap_middle = T0;
             tap_bottom = T1;
          end
      3 : begin
             tap_top = T0;
             tap_middle = T1;
             tap_bottom = T2;
          end
      endcase

// Line buffers.
red_line_x line0 ( 
   .clock( bit_clk ),
	.data( seems_red ),
	.rdaddress( x_cont ),
	.wraddress( x_cont ),
	.wren( EN[0] & h_sync ),
	.q( T0 )
);

red_line_x line1 ( 
   .clock( bit_clk ),
	.data( seems_red ),
	.rdaddress( x_cont ),
	.wraddress( x_cont ),
	.wren( EN[1] & h_sync ),
	.q( T1 )
);

red_line_x line2 ( 
   .clock( bit_clk ),
	.data( seems_red ),
	.rdaddress( x_cont ),
	.wraddress( x_cont ),
	.wren( EN[2] & h_sync ),
	.q( T2 )
);

red_line_x line3 ( 
   .clock( bit_clk ),
	.data( seems_red ),
	.rdaddress( x_cont ),
	.wraddress( x_cont ),
	.wren( EN[3] & h_sync ),
	.q( T3 )
);
 
endmodule

