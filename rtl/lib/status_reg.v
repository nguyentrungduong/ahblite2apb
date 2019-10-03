//////////////////////////////////////////////////////////////////////////////////
//  SH Consulting
//
// Filename    : status_reg.v
// Description : Latching status of the design.
// Author      : duong nguyen
// Created On  : 9/9/2015
// History (Date, Changed By)
//
//////////////////////////////////////////////////////////////////////////////////
module status_reg
    (
     clk,
     rst_n,
     //--------------------------------------
     //cpu access
     cpuren_i, //read enable
     cpuwen_i, //write enable
     cpudi_i,// Input data from CPU
     cpudo_o,// Output data for CPU
     //--------------------------------------
     //Status signal from IP
     status_i,
     //--------------------------------------
     //Clear
     clr_i
     );
//-----------------------------------------------------------------------------
//Parameter	 
parameter DW = 8;
parameter RST_VAL = {DW{1'b0}};
//-----------------------------------------------------------------------------
//Port
input                     clk;
input                     rst_n;
input                     cpuren_i;  
input                     cpuwen_i; 
input   [DW-1:0]          cpudi_i; 
output  [DW-1:0]          cpudo_o;

input  [DW-1:0]           status_i;
input	                  clr_i;
//-----------------------------------------------------------------------------
//Internal variable
reg   [DW-1:0] 	          latch_status;
wire  [DW-1:0]            nxt_latch_status;
//-----------------------------------------------------------------------------
//Logic implementation
assign nxt_latch_status = clr_i ? {DW{1'b0}} : status_i;
assign cpudo_o = cpuren_i ? latch_status : {DW{1'b0}};

always @(posedge clk or negedge rst_n)
    begin
    if(!rst_n)   
        latch_status <= RST_VAL;
    else  
        latch_status <= nxt_latch_status; 
    end 
	
endmodule
