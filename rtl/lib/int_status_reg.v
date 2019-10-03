//////////////////////////////////////////////////////////////////////////////////
//  SH Consulting
//
// Filename    : int_status_reg.v
// Description : Latching interrupt status of the design.
// Author      : duong nguyen
// Created On  : 9/9/2015
// History (Date, Changed By)
//
//////////////////////////////////////////////////////////////////////////////////
module int_status_reg
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
wire  [DW-1:0] 	          sts_or_latch_sts;
wire  [DW-1:0]            wdata_or_sts;
reg   [DW-1:0] 	          latch_status;
wire  [DW-1:0]            nxt_latch_status;

//-----------------------------------------------------------------------------
//Logic implementation
assign sts_or_latch_sts = status_i | latch_status;
assign wdata_or_sts = (latch_status & cpudi_i) | status_i;// write 0 to clear
assign nxt_latch_status = cpuwen_i ? wdata_or_sts : 
                          clr_i ? {DW{1'b0}} :
                          sts_or_latch_sts;
assign cpudo_o = cpuren_i ? latch_status : {DW{1'b0}};

always @(posedge clk or negedge rst_n)
    begin
    if(!rst_n)   
        latch_status <= RST_VAL;
    else  
        latch_status <= nxt_latch_status; 
    end 
	
endmodule
