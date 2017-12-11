


module RAW_RGB_BIN  (
input CLK , 
input RST_N , 
input [11:0] D0,
input [11:0] D1,
input X,
input Y,

output reg		[11:0]	R,
output reg		[11:0]	G, 
output reg		[11:0]	B,
output reg		rDVAL,
input DVAL
);

reg  [11:0]	rD0;
reg  [11:0]	rD1;

always@(posedge CLK or negedge RST_N)
begin
	if(!RST_N)
	begin
		R	<=	0;
		G	<=	0;
		B	<=	0;
		rD0<=	0;
		rD1<=	0;
		rDVAL	<=	0;
	end
	else
	begin
		rD0	<=	D0;
		rD1	<=	D1;
		rDVAL		<=	{Y |X }	?	1'b0	:	DVAL;
		if({Y ,X }     == 2'b10)
		begin
			R	<=	 D0;
			G	<=  (rD0+D1)/2;
			B	<=	 rD1;
		end	
		else if({Y ,X }== 2'b11)
		begin
			R	<=	rD0;
			G	<=	(D0+rD1)/2;
			B	<=	D1;
		end
		else if({Y ,X }== 2'b00)
		begin
			R	<=	D1;
			G	<=	(D0+rD1)/2;
			B	<=	rD0;
		end
		else if({Y ,X }== 2'b01)
		begin
			R	<=	rD1;
			G	<=	(rD0+D1)/2;
			B	<=	D0;
		end
	end
end


endmodule 