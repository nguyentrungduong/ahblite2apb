////////////////////////////////////////////////////////////////////////////////
// Company     : 
//
// Filename    : dff.v
// Description : D flip flop with no reset signal
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module dff
    (
    clk,
    din,
    dout
    );

//------------------------------------------------------------------------------
//Parameters
parameter DW = 1'b1;
//------------------------------------------------------------------------------
// Port declarations
input               clk;
input [DW-1:0]	    din;
output [DW-1:0]	    dout;
//------------------------------------------------------------------------------
//internal signal
reg  [DW-1:0]	    dout;

//------------------------------------------------------------------------------
// FF
always @(posedge clk)
    begin
    dout <= din;
    end

endmodule 

