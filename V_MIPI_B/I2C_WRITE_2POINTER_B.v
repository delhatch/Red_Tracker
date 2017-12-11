module I2C_WRITE_2POINTER_B  (
   input  				RESET_N ,
	input      			PT_CK,
	input      			GO,
	input      [15:0]	POINTER,
	input      [7:0]	SLAVE_ADDRESS,	
	input      			SDAI,
	output reg 			SDAO,
	output reg 			SCLO,
	output reg 			END_OK,
	
	//--for test 
	output reg [7:0]	ST ,
	output reg 			ACK_OK,
	output reg [7:0] 	CNT ,
	output reg [7:0] 	BYTE  
	
);

reg   [8:0]A ;
reg   [7:0]DELY ;


always @( negedge RESET_N or posedge  PT_CK )begin
if ( !RESET_N ) ST <=0;
else 
	  case (ST)
	    0: begin  //start 		      
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;	
	         if (GO) ST  <=30 ; // inital 							
		    end	  
	    1: begin  //start 
		      ST <=2 ; 
			   { SDAO,  SCLO } <= 2'b01; 
				A <= {SLAVE_ADDRESS ,1'b1 };//WRITE COMMAND
		    end
	    2: begin  //start 
		      ST <=3 ; 
			   { SDAO,  SCLO } <= 2'b00; 
		    end			 
	    3: begin  //start 
		      ST <=4 ; 
			   { SDAO, A } <= { A ,1'b0 }; 
		    end
	    4: begin  //start 
		      ST <=5 ; 
			   SCLO <= 1'b1 ; 
				CNT <= CNT +1 ;
		    end
			 
	    5: begin  
			 SCLO <= 1'b0 ; 
			 if (CNT==9) begin
				      if ( BYTE ==2)  ST <= 6 ; 
					   else  
						begin 
							CNT <=0 ; 
							     if  (BYTE ==0)  begin  A <= {POINTER[15:8] ,1'b1 };   BYTE <=1 ; end 
							else if  (BYTE ==1)  begin  A <= {POINTER[7:0] ,1'b1 };    BYTE <=2 ; end 
							ST <= 2 ; 
						end
					   if   ( !SDAI ) ACK_OK <=1 ; 
					   else  ACK_OK <=0 ; 
				 end
			 else ST <= 2;
		    end
	    6: begin          //stop
				ST <=7 ; 
			   {SDAO,SCLO } <= 2'b00; 
         end

	    7: begin          //stop
		      ST <=8 ; 
			   {SDAO,SCLO } <= 2'b01; 
         end
	    8: begin          //stop
		      ST <=9 ; 
			   {SDAO,SCLO } <= 2'b11; 						
         end //stop
		9:	begin
		      ST     <= 30; 
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;					
		     end
		//--- END ---
		30: begin
            if (!GO) ST  <=31;
          end
	  //---SLEEP UP-----		 
	    31: begin  //
		      END_OK<=0;
				CNT <=0 ; 
		      ST <=32 ; 
			   { SDAO,  SCLO } <= 2'b01; 
				A <= {SLAVE_ADDRESS ,1'b1 };//WRITE COMMAND
		    end
	    32: begin  //start 
		      ST <=33 ; 
			   { SDAO,  SCLO } <= 2'b00; 
		    end			 
	    33: begin  //start 
		      ST <=34 ; 
			   { SDAO, A } <= { A ,1'b0 }; 
		    end
	    34: begin  //start 
		      ST <=35 ; 
			   SCLO <= 1'b1 ; 
				CNT <= CNT +1 ;
		    end
			 
	    35: begin  
			  
			  if (CNT==9)  begin DELY<=0;  ST <= 36;end 
			  else begin ST <= 32; SCLO <= 1'b0 ; end 
		    end	
 			 
	    36: begin  
		         DELY<=DELY+1;
				   if ( DELY > 1 )  begin 
				         if ( SDAI==1 ) begin ST <= 31 ;  { SDAO,  SCLO } <= 2'b11; end
			            else  begin ST <=5 ;SCLO <= 1'b0;  end 
			      end
				end	
	  endcase 
 end
 
endmodule
