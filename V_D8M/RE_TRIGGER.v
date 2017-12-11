module RE_TRIGGER ( 
 input iCLK , 
 input [9:0] iD , 
 output reg [9:0]  oD , 
 input iHS,
 input iVS,
 output reg  oHS,
 output reg  oVS

);
always @(posedge iCLK )begin 
   oD <=iD ; 
   oVS<=iVS;  
   oHS<=iHS;  
end  

endmodule 