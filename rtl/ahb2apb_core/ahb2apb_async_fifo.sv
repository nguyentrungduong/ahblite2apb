//----------------------------------------------------------------------------- 
//Company       :
//File Name     : ahb2apb_async_fifo.v
//Description   : Asynchronous FIFO
//
//Author        : 
//Created On	: 
//-----------------------------------------------------------------------------
module	ahb2apb_async_fifo
    (
    rst_n   ,
    //-----------------------------
    //Write
    wclk    ,//Write clock
    wfifo_i ,//Request writing FIFO
    wdata_i ,
    wfull_o ,
    //-----------------------------
    //Read
    rclk    ,//Read clock
    rfifo_i ,
    rempty_o,
    rdata_o
    );


//-----------------------------------------------------------------------------
//Parameters
parameter AW = 2;
parameter DW = 8;


//-----------------------------------------------------------------------------
//Port declaration
input				rst_n;
//-----------------------------
//Write
input                           wclk;
input                           wfifo_i;
input [DW-1:0]                  wdata_i;
output                          wfull_o;
//-----------------------------
//Read
input                           rclk;
input                           rfifo_i;
output                          rempty_o;
output [DW-1:0]                 rdata_o;
//-----------------------------------------------------------------------------
//Internal variables
wire [AW:0]                     wptr;
wire [AW:0]                     rptr;
wire                            ren;
wire                            wen;
wire [AW-1:0]                   raddr;
wire [AW-1:0]                   waddr;
wire [DW-1:0]                   nxt_rdata;

//-----------------------------------------------------------------------------
//Read control inst
ahb2apb_async_fifo_rdctrl  #(.AW (AW)) async_fifo_rdctrl_00
	(
	.clk     (rclk),
	.rst_n   (rst_n),
	//-----------------------------
	//Inputs
	.wptr_i  (wptr),//Write pointer
	.rfifo_i (rfifo_i),//Request writing FIFO
	//-----------------------------
	//Outputs
	.ren_o   (ren),
	.rempty_o(rempty_o),
	.raddr_o (raddr),
	.rptr_o	 (rptr)
	);

//-----------------------------------------------------------------------------
//Write control inst
ahb2apb_async_fifo_wrctrl  #(.AW (AW))  async_fifo_wrctrl_00
	(
	.clk     (wclk),
	.rst_n   (rst_n),
	//-----------------------------
	//Inputs
	.rptr_i  (rptr),//Read pointer
	.wfifo_i (wfifo_i),//Request writing FIFO
	//-----------------------------
	//Outputs
	.wen_o   (wen),
	.wfull_o (wfull_o),
	.waddr_o (waddr),
	.wptr_o	 (wptr)
	);
//-----------------------------------------------------------------------------
//Reg file inst
regfile_4xnb_1clk   #(.DW (DW),
                      .AW (AW))  regfile_4xnb_00
	(
	//-----------------------------
	//Write
	.clk    (wclk),
	.wen_i  (wen),//Write enable
	.waddr_i(waddr),//write address
	.wdata_i(wdata_i),//write data
	//-----------------------------
	//Read
	.raddr_i(raddr),//Read address
	.rdata_o(nxt_rdata)//Read data
	);
//-----------------------------------------------------------------------------
//Pipeline 1 clock for good timing
dffa_rstn  #(.DW(DW))  dff_rdata (rclk,rst_n,nxt_rdata,rdata_o);



endmodule
