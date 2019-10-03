//-----------------------------------------------------------------------------
//Company       :
//File Name     : ahb2apb_async_fifo_wrctrl.v
//Description   : Control writing to async FIFO
//Author        : 
//Created On    : 
//-----------------------------------------------------------------------------
module	ahb2apb_async_fifo_wrctrl
    (
    clk    ,
    rst_n  ,
    //-----------------------------
    //Inputs
    rptr_i ,//Read pointer
    wfifo_i,//Request writing FIFO
    //-----------------------------
    //Outputs
    wen_o  ,
    wfull_o,
    waddr_o,
    wptr_o
    );


//-----------------------------------------------------------------------------
//Parameters
parameter  AW = 3;
parameter  AW1 = AW + 1;


//-----------------------------------------------------------------------------
//Port declaration
input              clk;
input              rst_n;
//-----------------------------
//Inputs
input [AW:0]       rptr_i;
input              wfifo_i;
//-----------------------------
//Outputs
output             wen_o;
output             wfull_o;
output [AW-1:0]    waddr_o;
output [AW:0]      wptr_o;

reg                wfull_o;
reg  [AW:0]        wptr_o;
reg                going_full_o;

//-----------------------------------------------------------------------------
//Internal variables
reg  [AW:0]        rptr_1;
reg  [AW:0]        rptr_sync;
reg  [AW:0]        wbin;
wire [AW:0]        nxt_wbin;
wire [AW:0]        nxt_wgray;

//-----------------------------------------------------------------------------
//Read pointer synchronization
always@(posedge clk or negedge rst_n)
    begin
    if (!rst_n)
        rptr_1 <= {AW1{1'b0}};
    else
        rptr_1 <= rptr_i;
    end
always@(posedge clk or negedge rst_n)
    begin
    if (!rst_n)
        rptr_sync <= {AW1{1'b0}};
    else
        rptr_sync <= rptr_1;
    end
//-----------------------------------------------------------------------------
//Writing control
always@(posedge clk or negedge rst_n)
    begin
    if(!rst_n)
        wbin <= {AW1{1'b0}};
    else
        wbin <= nxt_wbin;
    end
always@(posedge clk or negedge rst_n)
    begin
    if(!rst_n)
        wptr_o <= {AW1{1'b0}};
    else
        wptr_o <= nxt_wgray;
    end
always@(posedge clk or negedge rst_n)
    begin
    if(!rst_n)
        wfull_o <= 1'b0;
    else
        wfull_o <=(nxt_wgray == {~rptr_sync[AW:AW-1],rptr_sync[AW-2:0]});
    end

assign waddr_o = wbin[AW-1:0];
assign nxt_wbin = wen_o ? (wbin + 1'b1) : wbin;
assign nxt_wgray = (nxt_wbin >> 1) ^ nxt_wbin; // Binary to Gray code
assign wen_o = wfifo_i & (~wfull_o);


endmodule	
