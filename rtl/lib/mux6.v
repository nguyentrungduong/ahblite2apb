////////////////////////////////////////////////////////////////////////////////
// Company     : SH Consulting
//
// Filename    : mux6
// Description : 6:1 parallel mux.
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module mux6
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
    sel4,
    in4,
    //-------------------
    sel5,
    in5,
    //-------------------
    out
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
input               sel4;
input [DW-1:0]	    in4;
//
input               sel5;
input [DW-1:0]	    in5;
//
output [DW-1:0]	    out;
//------------------------------------------------------------------------------
//internal signal

//------------------------------------------------------------------------------
//Logic
assign out = ({DW{sel0}} & in0) |
             ({DW{sel1}} & in1) |
             ({DW{sel2}} & in2) |
             ({DW{sel3}} & in3) |
             ({DW{sel4}} & in4) |
             ({DW{sel5}} & in5);

endmodule 

