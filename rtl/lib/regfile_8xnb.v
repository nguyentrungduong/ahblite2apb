//----------------------------------------------------------------------------- 
//
//File Name   : regfile_8xnb.v
//Description : Refister file with depth = 8 and width is defined by DW
//              parameter, read data is returned at current clock.
//
//Author      : duongnguyen
//Created On  :
//-----------------------------------------------------------------------------
module	regfile_8xnb
	(
	clk    ,
	//-----------------------------
	//Write
	wen_i  ,//Write enable
	waddr_i,//write address
	wdata_i,//write data
	//-----------------------------
	//Read
	raddr_i,//Read address
	rdata_o//Read data
	);


//-----------------------------------------------------------------------------
//Parameters
parameter		AW = 3;
parameter		DW = 8;
//-----------------------------------------------------------------------------
//Port declaration
input                   clk;
//-----------------------------
//Write
input                   wen_i;//Write enable
input	[AW-1:0]	waddr_i;//write address
input	[DW-1:0]	wdata_i;//write data
//-----------------------------
//Read
input	[AW-1:0]	raddr_i;//Read address
output	[DW-1:0]	rdata_o;//Read data

reg 	[DW-1:0]	rdata_o;//Read data

//-----------------------------------------------------------------------------
//Internal variables
wire                    wen0;
wire                    wen1;
wire                    wen2;
wire                    wen3;
wire                    wen4;
wire                    wen5;
wire                    wen6;
wire                    wen7;

wire	[DW-1:0]	rdata0;
wire	[DW-1:0]	rdata1;
wire	[DW-1:0]	rdata2;
wire	[DW-1:0]	rdata3;
wire	[DW-1:0]	rdata4;
wire	[DW-1:0]	rdata5;
wire	[DW-1:0]	rdata6;
wire	[DW-1:0]	rdata7;

//-----------------------------------------------------------------------------
//Reg 0
regnb #(.DW(DW))	reg0
	(
	.clk		(clk),
	.wen_i		(wen0),
	.wdata_i	(wdata_i),
	.rdata_o	(rdata0)
	);
//-----------------------------------------------------------------------------
//Reg 1
regnb  #(.DW(DW))	reg1
	(
	.clk		(clk),
	.wen_i		(wen1),
	.wdata_i	(wdata_i),
	.rdata_o	(rdata1)
	);
//-----------------------------------------------------------------------------
//Reg 2
regnb  #(.DW(DW))	reg2
	(
	.clk		(clk),
	.wen_i		(wen2),
	.wdata_i	(wdata_i),
	.rdata_o	(rdata2)
	);
//-----------------------------------------------------------------------------
//Reg 3
regnb  #(.DW(DW))	reg3
	(
	.clk		(clk),
	.wen_i		(wen3),
	.wdata_i	(wdata_i),
	.rdata_o	(rdata3)
	);
//-----------------------------------------------------------------------------
//Reg 4
regnb
	#(.DW	(DW)
	)	reg4
	(
	.clk		(clk),
	.wen_i		(wen4),
	.wdata_i	(wdata_i),
	.rdata_o	(rdata4)
	);

//-----------------------------------------------------------------------------
//Reg 5
regnb  #(.DW(DW))	reg5
	(
	.clk		(clk),
	.wen_i		(wen5),
	.wdata_i	(wdata_i),
	.rdata_o	(rdata5)
	);
//-----------------------------------------------------------------------------
//Reg 6
regnb  #(.DW(DW))	reg6
	(
	.clk		(clk),
	.wen_i		(wen6),
	.wdata_i	(wdata_i),
	.rdata_o	(rdata6)
	);
//-----------------------------------------------------------------------------
//Reg 7
regnb  #(.DW(DW))	reg7
	(
	.clk		(clk),
	.wen_i		(wen7),
	.wdata_i	(wdata_i),
	.rdata_o	(rdata7)
	);


//-----------------------------------------------------------------------------
//Write control
assign wen0 = (waddr_i == 3'd0) & wen_i;
assign wen1 = (waddr_i == 3'd1) & wen_i;
assign wen2 = (waddr_i == 3'd2) & wen_i;
assign wen3 = (waddr_i == 3'd3) & wen_i;
assign wen4 = (waddr_i == 3'd4) & wen_i;
assign wen5 = (waddr_i == 3'd5) & wen_i;
assign wen6 = (waddr_i == 3'd6) & wen_i;
assign wen7 = (waddr_i == 3'd7) & wen_i;
//-----------------------------------------------------------------------------
//Read control

always @(*)
	begin
	case(raddr_i)
            3'd0 : rdata_o = rdata0;
            3'd1 : rdata_o = rdata1;
            3'd2 : rdata_o = rdata2;
            3'd3 : rdata_o = rdata3;
            3'd4 : rdata_o = rdata4;
            3'd5 : rdata_o = rdata5;
            3'd6 : rdata_o = rdata6;
            3'd7 : rdata_o = rdata7;
            default : rdata_o = {DW{1'b0}};
	endcase
	end

endmodule	
