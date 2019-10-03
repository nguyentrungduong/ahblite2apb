////////////////////////////////////////////////////////////////////////////////
// Company     :
//
// Filename    : dffa_rstn.v
// Description : D flip flop with asynchronous active low reset signal
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module dffa_rstn
    (
    clk,
    rst_n,
    din,
    dout
    );

//------------------------------------------------------------------------------
//Parameters
parameter DW     = 1'b1;
parameter RST_VL = {DW{1'b0}};
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
always @ (posedge clk or negedge rst_n)
    begin
    if(!rst_n)
        dout <= RST_VL;
    else
        dout <= din;
    end

endmodule 

