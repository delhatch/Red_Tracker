module F_BACK ( 
input RESET_n ,
input CLK  , 
output reg [9:0]STEP,
output reg V_C 

) ; 

reg [3:0] C2 ; 
always @( posedge CLK  )  C2 <= C2+1 ; 

always @( negedge RESET_n  or posedge CLK )  
begin 
if (!RESET_n )  begin 
   V_C <=0 ; 
	STEP <= 0;  
end 
else 
  if ( !V_C ) begin 
       STEP <=STEP +1 ; 
		 if (STEP > 10'h3f0 ) V_C <=1 ;
		 end 
  else 
    begin 
	   STEP <= STEP - 1 ;  
		if (STEP < 5 ) V_C <=0 ;
	 end 
end 	 
endmodule 
	 