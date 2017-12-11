
module RAW2RGB_J(	
//---ccd 
input	  [11:0]	 mCCD_DATA,
input			    CCD_PIXCLK ,
input		       CCD_FVAL,
input		       CCD_LVAL,
input	  [15:0]	 X_Cont,
input	  [15:0]	 Y_Cont,
input			    DVAL,
input			    RST,
input           VGA_CLK, 
input           READ_Request ,
input           VGA_VS ,	
input           VGA_HS ,	
input   [12:0]  READ_Cont ,
input   [12:0]  V_Cont , 
output	[11:0] oRed,
output 	[11:0] oGreen,
output	 [11:0]oBlue,
output	   	 oDVAL

);
//----- WIRE /REG 
wire	   [11:0]	mDAT0_0;
wire	   [11:0]	mDAT0_1;
wire	   [11:0]	mDAT0_2;
reg		[11:0]	mDAT1_0;
reg		[11:0]	mDAT1_1;
reg		[11:0]	mDAT1_2;
reg		[11:0]	mDAT2_0;
reg		[11:0]	mDAT2_1;
reg		[11:0]	mDAT2_2;
reg		[11:0]	mDAT3_0;
reg		[11:0]	mDAT3_1;
reg		[11:0]	mDAT3_2;
wire 		[11:0]	mCCD_R;
wire 		[13:0]	mCCD_G; 
wire 		[11:0]	mCCD_B;
reg				   mDVAL;


//-------- RGB OUT ---- 
assign   oRed	 = mCCD_R[11:0];
assign  oGreen  = mCCD_G[11:0] ;
assign	oBlue	 = mCCD_B[11:0];

//-------- VALID OUT ---- 
assign	oDVAL	 =	mDVAL;


//--------
reg	[10:0]	mX_Cont;
reg	[10:0]	mY_Cont;

//--------
reg rDVAL ; 
always @(negedge VGA_VS or posedge VGA_CLK )begin
  if ( !VGA_VS ) begin 
    mX_Cont<=0;
    mY_Cont<=0;
end 
else 
begin 
  rDVAL <= READ_Request   ; 
  if ( !rDVAL)    mX_Cont<=0;  else mX_Cont<=mX_Cont+1 ;   
  if (  rDVAL  && !READ_Request)  mY_Cont <= mY_Cont+1 ; 
end 
end 
//--------

//----3 2-PORT-LINE-BUFFER----  
Line_Buffer_J 	u0	(	
						.CCD_PIXCLK( VGA_CLK ),
						.mCCD_FVAL ( VGA_VS) ,
                  .mCCD_LVAL ( VGA_HS) , 	
						.X_Cont    ( mX_Cont) , 
						.mCCD_DATA ( mCCD_DATA),
						.VGA_CLK   ( VGA_CLK), 
                  .READ_Request (READ_Request),
                  .VGA_VS    ( VGA_VS),	
                  .READ_Cont ( mX_Cont ),
                  .V_Cont    ( mY_Cont ),
					
						.taps0x    ( mDAT0_1),
						.taps1x    ( mDAT0_0)
						);					
			
						
RAW_RGB_BIN  bin(
      .CLK  ( VGA_CLK ), 
      .RST_N( RST ) , 
      .D0   ( mDAT0_0),
      .D1   ( mDAT0_1),
      .X    ( mX_Cont [0] ),
      .Y    ( mY_Cont [0] ),
       
      .R    ( mCCD_B),
      .G    ( mCCD_G), 
      .B    ( mCCD_R)
); 


endmodule
