////////////////////////////////////////////////////////////////////////////////
//
// Filename    : mux8
// Description : 8:1 parallel mux.
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module mux8
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
    sel6,
    in6,
    //-------------------
    sel7,
    in7,
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
input               sel6;
input [DW-1:0]	    in6;
//
input               sel7;
input [DW-1:0]	    in7;
//
output [DW-1:0]	    out;
//------------------------------------------------------------------------------
//internal signal
wire [DW-1:0]       out03;
wire [DW-1:0]       out47;
//------------------------------------------------------------------------------
//Mux 4:1
mux4   #(.DW(DW))   mux4_0 
    (
    .sel0  (sel0),
    .in0   (in0),
    //-------------------
    .sel1  (sel1),
    .in1   (in1),
    //-------------------
    .sel2  (sel2),
    .in2   (in2),
    //-------------------
    .sel3  (sel3),
    .in3   (in3),
    //-------------------
    .out   (out03)
    );
//------------------------------------------------------------------------------
//Mux 4:1
mux4   #(.DW(DW))   mux4_1 
    (
    .sel0  (sel4),
    .in0   (in4),
    //-------------------
    .sel1  (sel5),
    .in1   (in5),
    //-------------------
    .sel2  (sel6),
    .in2   (in6),
    //-------------------
    .sel3  (sel7),
    .in3   (in7),
    //-------------------
    .out   (out47)
    );
//------------------------------------------------------------------------------
//Mux 2:1
assign out = out03 | out47;

endmodule 

