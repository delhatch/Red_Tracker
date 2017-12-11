// This module low-pass filters the red pixel data.
// The input is a three-element column of data above the current camera pixel.
// This module fills a 1-bit frame buffer.
module red_frame ( 
   input VGA_clock,
   input reset,
   input [23:0] pixel_data,
   input [9:0] x_cont,
   input [8:0] y_cont,
   input h_sync,
   input v_sync,
   output reg red_pixel,
   output reg [8:0] horz_line,   // passes up the value of the number of the horizontal line of the center of the red object.
   output reg [9:0] vert_line,
   input filter_on,
   output [6:0] EX_IO   // De-bug signals out to pins
);

localparam START_UP = 0, WAIT = 1, IS_RED = 2;

wire tap_top, tap_middle, tap_bottom;
reg d1_top, d2_top, d1_middle, d2_middle, d1_bottom, d2_bottom;
reg [3:0] sum;
reg [9:0] cntr;    // counts consecutive red pixels on the active video row (line)). Max value of 640.
reg [9:0] max_ever; // Holds the value of the largest number of consecutive pixels encountered in any line so far, this video frame.
reg [9:0] end_x;      // column that the red streak ended on.
reg [8:0] line_of_max;  // video line (0-479) that contained the maximum number of sequential red pixels.
reg [1:0] state;

// This is the value that gets passed up a level. It represents the pixel two rows above the current
//   camera pixel location. (The filtering creates 2 raster lines of latency.)
always @ (*) begin
   sum = d2_top  +  d1_top  +  tap_top +
         d2_middle + d1_middle + tap_middle +
         d2_bottom + d1_bottom + tap_bottom;
   if( filter_on == 1'b1 ) begin
      if( sum >= 5 ) red_pixel = 1'b1;
      else red_pixel = 1'b0;
      end
   else 
      red_pixel = tap_middle;
end

// Counts the number of consecutive horizontal red pixels.
// If greater than ever encountered so far, save the line number (y_cont) into the line_of_max register.
// The line_of_max gets transferred into the horiz_line register at the end of each video frame.
always @ (posedge VGA_clock or negedge reset)
   if( ~reset ) begin
      cntr <= 0;     // counts consecutive red pixels.
      horz_line <= 240;
      state <= START_UP;
      end
   else
      case( state )
         START_UP : begin
                       cntr <= 0;
                       if( v_sync == 1'b0 ) state <= START_UP;   // Wait for start of new video frame.
                       else state <= WAIT;
                    end
 
         WAIT : begin        // waiting for h_sync to go high, to start evaluating the next line.
                   cntr <= 0;
                   if( v_sync == 1'b0 ) begin
                      state <= START_UP;   // If v_sync is low, then current video frame has ended.
                      horz_line <= line_of_max;   // output the line number that had the max sequential red pixels.
                      vert_line <= end_x - ( max_ever >> 1 );
                      end
                   else if( h_sync == 1'b0 ) state <= WAIT;
                   else state <= IS_RED;
                end
                   
         IS_RED : begin      // in active video area. start counting red pixels
                      if( h_sync == 1'b0 ) state <= WAIT;
                      else if( red_pixel == 1'b1 ) begin
                              cntr <= cntr + 1;
                              state <= IS_RED;
                              end
                           else begin     // Did not see a red pixel, and still in active area.
                              cntr <= 0;
                              state <= IS_RED;
                              end
                  end
       endcase

always @ (posedge VGA_clock or negedge reset)  // If cntr (consequtive red pixels) sets a new record, save the record value, and the line it occured on.
   if( ~reset ) begin
      max_ever <= 0;  // new video frame, so reset the "max number of sequential red pixels in this video frame" register.
      line_of_max <= 240;  // default is middle of screen, if no red object is ever detected.
      end
   else begin
      if( (state == START_UP) ) begin
         max_ever <= 0;  // new video frame, so reset the "max number of sequential red pixels in this video frame" register.
         line_of_max <= 240;  // default is middle of screen, if no red object is ever detected.
         end
      else if( cntr > max_ever ) begin
         end_x <= x_cont;     // save the column the red streak ends on (so far).
         max_ever <= cntr;
         line_of_max <= y_cont;
         end
      end


// Create a 3x3 array from the 1x3 incoming column of pixel data.
always @ (posedge VGA_clock) begin
   d2_top <= d1_top;
   d1_top <= tap_top;
   d2_middle <= d1_middle;
   d1_middle <= tap_middle;
   d2_bottom <= d1_bottom;
   d1_bottom <= tap_bottom;
end
   

// This is the module that buffers three lines of video data so that the 3x3 low-pass
//    algorithm can operate.
red_line_buffer u1 ( 
   .bit_clk( VGA_clock ),
   .pixel( pixel_data ),
   .h_sync( h_sync ),
   .x_cont( x_cont ),
   // The tap outputs are the column of 3 pixels above the current camera pixel location.
   .tap_top( tap_top ),
   .tap_middle( tap_middle ),
   .tap_bottom( tap_bottom )
);

assign EX_IO[0] = v_sync;
assign EX_IO[1] = h_sync;
assign EX_IO[2] = cntr[0];
assign EX_IO[3] = cntr[1];
assign EX_IO[4] = state[0];
assign EX_IO[5] = state[1];
assign EX_IO[6] = red_pixel;

endmodule