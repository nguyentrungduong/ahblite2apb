//----------------------------------------------------------------------------- 
//
//File Name   : regnb.v
//Description : N bits Register with no reset signal
//
//Author      : duongnguyen
//Created On  : 
//-----------------------------------------------------------------------------
module	regnb
    (
    clk,
    //-----------------------------
    //Write
    wen_i,//Write enable
    wdata_i,//write data
    //-----------------------------
    //Read
    rdata_o//Read data
    );


//-----------------------------------------------------------------------------
//Parameters
parameter    DW = 8;
//-----------------------------------------------------------------------------
//Port declaration
input          clk;
//-----------------------------
//Write
input          wen_i;//Write enable
input [DW-1:0] wdata_i;//write data
//-----------------------------
//Read
output [DW-1:0]rdata_o;//Read data

//-----------------------------------------------------------------------------
//Internal variables
reg [DW-1:0]   data;
wire [DW-1:0]  nxt_data;
//-----------------------------------------------------------------------------
//Write
always@(posedge clk)
    begin
    data <= nxt_data;
    end
//-----------------------------------------------------------------------------
//Read
assign nxt_data = wen_i ? wdata_i : data;
assign rdata_o  = data;

endmodule	
