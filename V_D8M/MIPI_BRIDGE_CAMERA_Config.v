module MIPI_BRIDGE_CAMERA_Config   (
 input  RESET_N , 
 input  CLK_50 , 
 
 output MIPI_I2C_SCL , 
 inout  MIPI_I2C_SDA , 
 output MIPI_I2C_RELEASE ,  
 output CAMERA_I2C_SCL,
 inout  CAMERA_I2C_SDA,
 output CAMERA_I2C_RELAESE
 ); 
//--D8M CAMERA I2C -- 
MIPI_CAMERA_CONFIG  camiv( 
   .RESET_N ( RESET_N ),
	.TR_IN   ( ) , 	
   .CLK_50  ( CLK_50) ,
   .I2C_SCL ( CAMERA_I2C_SCL ), 
   .I2C_SDA ( CAMERA_I2C_SDA),
   .INT_n   (),
	.MIPI_CAMERA_RELAESE  ( CAMERA_I2C_RELAESE )
);


//--MIPI BRIDGE I2C -- 
MIPI_BRIDGE_CONFIG  mpiv( 
   .RESET_N (RESET_N) ,  	
   .CLK_50  (CLK_50 ) ,
   .I2C_SCL (MIPI_I2C_SCL), 
   .I2C_SDA (MIPI_I2C_SDA),
	.MIPI_BRIDGE_CONFIG_RELEASE (MIPI_I2C_RELEASE)  , 
   .INT_n()
);

endmodule  