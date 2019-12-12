////////////////////////////////////////////////////////////////////////////////
//
// Filename    : vld_mux4
// Description : 4:1 parallel mux with valid output.
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module vld_mux4
    (
    sel0,
    in0,
    //-------------------
    sel1,
    in1,
    //-------------------
    sel2,
    in2,
    //-------------------
    sel3,
    in3,
    //-------------------
    out,
    vld_o
    );

//------------------------------------------------------------------------------
//Parameters
parameter DW = 1'b1;
//------------------------------------------------------------------------------
// Port declarations
input               sel0;
input [DW-1:0]	    in0;
//
input               sel1;
input [DW-1:0]	    in1;
//
input               sel2;
input [DW-1:0]	    in2;
//
input               sel3;
input [DW-1:0]	    in3;
//
output [DW-1:0]	    out;
output              vld_o;
//------------------------------------------------------------------------------
//internal signal

//------------------------------------------------------------------------------
//Logic
assign out = ({DW{sel0}} & in0) |
             ({DW{sel1}} & in1) |
             ({DW{sel2}} & in2) |
             ({DW{sel3}} & in3);
assign vld_o = sel0 | sel1 | sel2 | sel3;

endmodule 

