//-----------------------------------------------------------------------------
//Company       :
//File Name     : ahb2apb_async_fifo_rdctrl.v
//Description   : Control reading data from FIFO
//Author        : 
//Created On    : 
//----------------------------------------------------------------------------
module	ahb2apb_async_fifo_rdctrl
    (
    clk     ,
    rst_n   ,    
    //-----------------------------
    //Inputs
    wptr_i  ,//Read pointer
    rfifo_i ,//Request writing FIFO
    //-----------------------------
    //Outputs
    ren_o   ,
    rempty_o,
    raddr_o ,
    rptr_o
    );


//-----------------------------------------------------------------------------
//Parameters
parameter AW = 3;
parameter AW1 = AW + 1;


//-----------------------------------------------------------------------------
//Port declaration
input            clk;
input            rst_n;
//-----------------------------
//Inputs
input [AW:0]     wptr_i;
input            rfifo_i;
//-----------------------------
//Outputs
output           ren_o;
output           rempty_o;
output [AW-1:0]	 raddr_o;
output [AW:0]    rptr_o;

reg              rempty_o;
reg [AW:0]       rptr_o;		
//-----------------------------------------------------------------------------
//Internal variables
reg [AW:0]       wptr_1;
reg [AW:0]       wptr_sync;
reg [AW:0]       rbin;
wire [AW:0]		nxt_rbin;
wire [AW:0]		nxt_rgray;
//-----------------------------------------------------------------------------
//Write pointer synchronization
always@(posedge clk or negedge rst_n)
    begin
    if (!rst_n)
        wptr_1 <= {AW1{1'b0}};
    else
        wptr_1 <= wptr_i;
    end
always@(posedge clk or negedge rst_n)
    begin
    if (!rst_n)
        wptr_sync <= {AW1{1'b0}};
    else
        wptr_sync <= wptr_1;
    end
//-----------------------------------------------------------------------------
//Writing control
always@(posedge clk or negedge rst_n)
    begin
    if(!rst_n)
        begin
        rbin <= {AW1{1'b0}};
        rptr_o <= {AW1{1'b0}};
        rempty_o <= 1'b1; // After reset FIFO is empty
        end
    else
        begin
        rbin <= nxt_rbin;
        rptr_o <= nxt_rgray;
        rempty_o <=(nxt_rgray == wptr_sync);
        end
    end

assign raddr_o = rbin[AW-1:0];
assign nxt_rbin = ren_o ? (rbin + 4'd1) : rbin;
assign nxt_rgray = (nxt_rbin >> 1) ^ nxt_rbin; // Binary to Gray code
assign ren_o = rfifo_i & (~rempty_o);

endmodule	
