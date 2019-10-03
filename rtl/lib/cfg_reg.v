//////////////////////////////////////////////////////////////////////////////////
//
//  SH Consulting
//
// Filename        : cfg_reg.v
// Description     : Read/Write configuration register
//
// Author          : Duong Nguyen
// Created On      : 9/9/2015
// History (Date, Changed By)
//
//////////////////////////////////////////////////////////////////////////////////
module cfg_reg
    (
    clk,
    rst_n,
    //--------------------------------------
    //cpu access
    cpuren_i,  	//read enable
    cpuwen_i,  	//write enable
    cpudi_i,  	// Input data from CPU
    cpudo_o,	// Output data for CPU
    //--------------------------------------
    //Output of configuration register
    reg_o,
    //--------------------------------------
    //Clear
    clr_i
     );
//-----------------------------------------------------------------------------
//Parameter	 
parameter	DW = 8;
parameter 	RST_VAL = {DW{1'b0}};
//-----------------------------------------------------------------------------
//Port
input                   clk;
input                   rst_n;
input                   cpuren_i;  
input                   cpuwen_i; 
input   [DW-1:0]        cpudi_i; 
output  [DW-1:0]        cpudo_o;

output  [DW-1:0]        reg_o;
input			clr_i;
//-----------------------------------------------------------------------------
//Internal variable
reg    [DW-1:0]         reg_o;
wire    [DW-1:0]        nxt_reg;

//-----------------------------------------------------------------------------
//Logic implementation
assign cpudo_o = cpuren_i ? reg_o : {DW{1'b0}};
assign nxt_reg = clr_i ? RST_VAL : 
                 cpuwen_i ? cpudi_i : 
                 reg_o;

always @(posedge clk or negedge rst_n)
    begin
    if(!rst_n)   
        reg_o <= RST_VAL;
    else  
        reg_o <= nxt_reg; 
    end 
	
endmodule
