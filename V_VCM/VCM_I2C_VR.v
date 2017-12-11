module VCM_I2C_VR ( 
   input   RESET_N , 
	input   TR_IN , 
   input   RESET_SUB_N , 	
   input   CLK_50 ,
	
   output I2C_SCL, 
   inout  I2C_SDA,
   input  INT_n,
	
//----Test or ST-BUS --- 
   output reg [15:0] R_VCM_DATA  ,
   input      [15:0] VCM_DATA  , 
//test
	output      CLK_400K ,
   output reg  I2C_LO0P,
   output reg [7:0] ST ,
   output reg [7:0] CNT,
	output reg [7:0] WCNT,
   output reg [7:0] SLAVE_ADDR,	 	
   output reg [7:0] WORD_DATA,
   output reg [7:0] POINTER,
	
	output           W_WORD_END ,
   output reg       W_WORD_GO ,
	
	output [7:0]     WORD_ST,
	output [7:0]     WORD_CNT,
	output [7:0]     WORD_BYTE	,
   output [15:0]    R_DATA,
	output           SDAI_W ,
	output TR ,
	output    I2C_SCL_O  , 
	output reg VCM_RELEASE	,
	input CAMERA_I2C_SCL  
	
	);

reg rTR_IN  ; 
	
//-- I2C clock 400k generater 
CLOCKMEM c1(  .CLK ( CLK_50 ) , .CLK_FREQ ( 125 )  , .CK_1HZ (CLK_400K) ) ; 
  
//======== Main-ST =======
//==Pointer NUM==
parameter    SLAVE_ADDR1     = 8'h18 ;  // 2.5V_CORE_SENSE_P  2.5V_VCCIO_SENSE_P 

//-WRITE-  -READ-
parameter    P_STATUS        = 8'h00   ; 
//parameter    SOFT_POWER_SAVE = 16'h0000; //power normal 
parameter    SOFT_POWER_SAVE = 16'h0000; //power saveing 

parameter    TIME            = 32'd400000/400 ;  
parameter    TIME_LONG       = 250000000  ;  
//----
reg [31:0] DELY ;
always @(negedge RESET_N or posedge CLK_400K )begin 
if (!RESET_N  ) begin 
   ST <=0;
	W_POINTER_GO <=1;
   R_GO  <=1 ;		 
	W_WORD_GO <=1;
	WCNT <=0;  
	CNT  <=0;
	DELY <=0 ;
   VCM_RELEASE <=0;	
	R_VCM_DATA  <=0; 
end
else  begin 
rTR_IN  <= TR_IN  ; 
case (ST)
0: begin 
   ST<=30; //Config Reg
	W_POINTER_GO <=1;
   R_GO  <=1 ;		 
	W_WORD_GO <=1;
	WCNT <=0;  
	CNT <=0;
	DELY <=0 ;	
   end
//<----------------READ -------	
1: begin 
   ST<=2;
	end	
2: begin 
	     if ( CNT==0 )   { SLAVE_ADDR[7:0] , POINTER [7:0] } <= { SLAVE_ADDR1[7:0],  P_STATUS  }   ;
   if ( W_POINTER_END ) begin  W_POINTER_GO  <=0; ST<=3 ; DELY<=0;  end
	end                // Write pointer
3: begin 
    DELY  <=DELY +1;
    if ( DELY ==2 ) begin 
     W_POINTER_GO  <=1;
     ST<=4 ; 
	 end
	end       
4: begin 
   if  ( W_POINTER_END ) ST<=5 ; 	
	end              
5: begin ST<=6 ; end 
//read DATA 		 
6: begin 
	if ( R_END )  begin  R_GO  <=0; ST<=7 ; DELY<=0; end
	end                
7: begin 
    DELY  <=DELY +1;
    if ( DELY ==2 ) begin 	 
    R_GO  <=1;
    ST<=8 ; 
	 end
	 
	end       
8: begin 
   ST<=9 ; 
	end       
	
9: begin 
   if  ( R_END ) begin 
	       if ( CNT==0 )  R_VCM_DATA   <=  R_DATA ; 
	  CNT<=CNT+1 ;
	  ST<=10 ; 	
	  DELY <=0;
	end 
  end	
10: begin   
      if ( R_VCM_DATA[15] )   ST<=1;
		else  if (CNT ==1 )      begin 
		   ST<=10;  
		   if      ( DELY <= 10)   DELY <= DELY +1 ; 
		    else 	VCM_RELEASE <=1;  
		 end 
	   else    ST<=1;	
		   //DELY <=0;
	      W_POINTER_GO <=1;
         R_GO         <=1 ;		 
	      W_WORD_GO    <=1; 	 	  
	 end //delay
//<----------------------------------READ-----------------------
28: begin
    if (DELY < TIME_LONG    ) DELY <=DELY+1; 
    else begin 
	    ST<=29; 
		 DELY <=0; 
	 end  
end 
//<----------------------------------WRITE WORD-----------------
29: begin
      I2C_LO0P <= 0 ;  
      if ( DELY < TIME  ) DELY <=DELY+1; 
	   else  ST<=30; 
    end	
30: begin 
    ST<=31; 
	 WCNT<=0 ; 
    end	
31: begin 
    if ( WCNT==0) begin { SLAVE_ADDR[7:0] , POINTER [7:0] ,WORD_DATA [7:0]} <= { SLAVE_ADDR1[7:0], SOFT_POWER_SAVE[15:0]  };  end									 				
				if (  W_WORD_END ) begin  W_WORD_GO  <=0; ST<=32 ;  DELY<=0;  end
	end                // Write ID pointer 
32: begin 
    if ( DELY ==3 ) begin 
       W_WORD_GO  <=1;
       ST<=33 ; 
	 end
	 else  DELY <=DELY +1;
	end       
33: begin 
    ST<=34 ; 
	end       	
34: begin 
     if  ( W_WORD_END )  begin 	
			 WCNT<=WCNT+1 ;			 
			 ST<=35 ; 
	  end
	end              
35: begin 
        if  ( WCNT ==1)   begin   ST<=1  ;  WCNT <=0;  CNT <=0; DELY <= 0; I2C_LO0P <= 1 ;  end 
	     else   ST<=31 ; 	 
	 end 
	  
endcase 
end 
end
//<-----------------------------MAIN-ST END ------------------------------------------
//I2C-BUS
wire   SDAO; 

//assign I2C_SCL_O       = W_POINTER_SCL  & R_SCL   & W_WORD_SCL ; 
assign I2C_SCL_O       = W_WORD_SCL & W_POINTER_SCL & R_SCL;
assign SDAO            = W_POINTER_SDAO & R_SDAO  & W_WORD_SDAO;
assign I2C_SDA =     ( ( SDAO )  ||  ( RESET_N==0 )    )?1'bz :1'b0 ; 
assign I2C_SCL =     ( ( I2C_SCL_O)  || ( RESET_N==0 ) )?1'b1 :1'b0 ; 

//==== I2C WRITE WORD ===
wire   W_WORD_SCL ; 
wire   W_WORD_SDAO ;  

I2C_WRITE_BYTE_VR  wrd(
   .RESET_N      ( RESET_N),
	.PT_CK        (CLK_400K),
	.GO           (W_WORD_GO),
	.LIGHT_INT    (),
	.POINTER      (POINTER),
   .WDATA8	     (WORD_DATA),
	.SLAVE_ADDRESS(SLAVE_ADDR ),
	.SDAI  (I2C_SDA),
	.SDAO  (W_WORD_SDAO),
	.SCLO  (W_WORD_SCL ),
	.END_OK(W_WORD_END),
	//--for test 
	.ST  (WORD_ST ),
	.CNT (WORD_CNT),
	.BYTE(WORD_BYTE),
	.ACK_OK(),
	.SDAI_W (SDAI_W )
	
);

//==== I2C WRITE POINTER ===
wire   W_POINTER_SCL ; 
wire   W_POINTER_END ; 
reg    W_POINTER_GO ; 
wire   W_POINTER_SDAO ;  

I2C_WRITE_POINTER_VR  wpt(
   .RESET_N (RESET_N),
	.PT_CK        (CLK_400K),
	.GO           (W_POINTER_GO),
	.POINTER      (POINTER),
	.SLAVE_ADDRESS(SLAVE_ADDR ),//37
	.SDAI  (I2C_SDA),
	.SDAO  (W_POINTER_SDAO),
	.SCLO  (W_POINTER_SCL ),
	.END_OK(W_POINTER_END),
	//--for test 
	.ST (),
	.ACK_OK(),
	.CNT (),
	.BYTE()  	
);


//==== I2C READ ===

wire R_SCL; 
wire R_END; 
reg  R_GO; 
wire R_SDAO;  

I2C_READ_2BYTE_VR rd( //
   .RESET_N (RESET_N),
	.PT_CK        (CLK_400K),
	.GO           (R_GO),
	.SLAVE_ADDRESS(SLAVE_ADDR ),
	.SDAI  (I2C_SDA),
	.SDAO  (R_SDAO),
	.SCLO  (R_SCL),
	.END_OK(R_END),
	.DATA16 (R_DATA),
	
	//--for test 
	.ST    (),
	.ACK_OK(),
	.CNT   (),
	.BYTE  ()  	
);
	
endmodule
	