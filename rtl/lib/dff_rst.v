////////////////////////////////////////////////////////////////////////////////
// Company     : SH Consulting
//
// Filename    : dff_rst.v
// Description : D flip flop with synchronous reset signal (active high)
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module dff_rst
    (
    clk,
    rst,
    din,
    dout
    );

//------------------------------------------------------------------------------
//Parameters
parameter DW = 1'b1;
parameter RST_VL = {DW{1'b0}};
//------------------------------------------------------------------------------
// Port declarations
input               clk;
input               rst;
input [DW-1:0]	    din;
output [DW-1:0]	    dout;
//------------------------------------------------------------------------------
//internal signal
reg  [DW-1:0]	    dout;
//------------------------------------------------------------------------------
// FF
always @(posedge clk)
    begin
    if(rst)
        dout <= RST_VL;
    else
        dout <= din;
    end

endmodule 

