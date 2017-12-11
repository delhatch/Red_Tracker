module LCD_COUNTER_B (
input CLK ,
input VS  , 
input HS  , 
output reg [11:0] V_CNT ,
output reg [11:0] H_CNT ,
output reg  LINE ,
output reg  ACTIV_C,
output reg  ACTIV_V
) ; 
reg rHS ;
reg rVS ;

parameter H_OFF =12'd200 ; 
parameter V_OFF =12'd200 ; 

parameter H_CEN =12'd450 ; 
parameter V_CEN =12'd250 ; 


always @( posedge CLK  ) begin 
    ACTIV_V <=  HS & VS ; 
    rHS <= HS ;
	 rVS <= VS ;
	 //--H
	 if (!rHS &&  HS  ) begin  
	     H_CNT<=0; 
	 end
	 else H_CNT <=H_CNT+1 ; 
	 //--V
	 if (!rVS &&  VS  ) begin  
	     V_CNT<=0; 
	 end
	 else if (!rHS &&  HS  ) V_CNT <=V_CNT+1 ; 
	 
	LINE  <= (
	 (( V_CNT == ( V_CEN -V_OFF/2)  ) && ( H_CNT >= ( H_CEN -H_OFF/2)  )  &&  ( H_CNT < ( H_CEN +H_OFF/2)  )) ||
	 (( V_CNT == ( V_CEN +V_OFF/2)  ) && ( H_CNT >= ( H_CEN -H_OFF/2)  )  &&  ( H_CNT < ( H_CEN +H_OFF/2)  )) ||
	 (( H_CNT == ( H_CEN -H_OFF/2)  ) && ( V_CNT >= ( V_CEN -V_OFF/2)  )  &&  ( V_CNT < ( V_CEN +V_OFF/2)  )) ||
	 (( H_CNT == ( H_CEN +H_OFF/2)  ) && ( V_CNT >= ( V_CEN -V_OFF/2)  )  &&  ( V_CNT < ( V_CEN +V_OFF/2)  ))
	 ) ?
	 1:0 ; 
	
	ACTIV_C <= ( 
	  (( H_CNT >= ( H_CEN -H_OFF/2)  ) &&  ( H_CNT < ( H_CEN +H_OFF/2)  ))
	   &&
	  (( V_CNT >= ( V_CEN -V_OFF/2)  ) &&  ( V_CNT < ( V_CEN +V_OFF/2)  ))
	  )?1:0; 
end


endmodule 