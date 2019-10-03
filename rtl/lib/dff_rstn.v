////////////////////////////////////////////////////////////////////////////////
// Company     : SH Consulting
//
// Filename    : dff_rstn.v
// Description : D flip flop with synchronous reset signal (active low)
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module dff_rstn
    (
    clk,
    rst_n,
    din,
    dout
    );

//------------------------------------------------------------------------------
//Parameters
parameter DW = 1'b1;
//------------------------------------------------------------------------------
// Port declarations
input               clk;
input               rst_n;
input [DW-1:0]	    din;
output [DW-1:0]	    dout;
//------------------------------------------------------------------------------
//internal signal
reg  [DW-1:0]	    dout;
//------------------------------------------------------------------------------
// FF
always @ (posedge clk)
    begin
    if(!rst_n)
        dout <= {DW{1'b0}};
    else
        dout <= din;
    end

endmodule 

