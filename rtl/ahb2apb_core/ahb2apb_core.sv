////////////////////////////////////////////////////////////////////////////////
// Company     : 
//
// Filename    : ahb2apb_core.sv
// Description : AHB slave state machine
//
// Author      : Duong Nguyen
// Created On  : 
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module ahb2apb_core
    (
    ahb_clk    ,
    apb_clk    ,
    rst_n      ,//asynchronous reset, active-high
    //---------------------------------
    //AHB slave interface
    hsel_i     ,
    haddr_i    ,
    hwrite_i   ,
    htrans_i   ,
    hsize_i    ,
    hburst_i   ,
    hwdata_i   ,
    hready_i   ,
    hmastlock_i,
    hreadyout_o,
    hresp_o    ,
    hrdata_o   ,
    //---------------------------------
    //APB interface, 8 slaves
    psel_o     ,
    pwrite_o   ,
    penable_o  ,
    paddr_o    ,
    pwdata_o   ,
    pstrb_o    ,
    pprot_o    ,
    prdata_i   ,
    pslverr_i  ,
    pready_i   
    );

//------------------------------------------------------------------------------
//parameter
parameter AHB_AW  = 6'd32;
parameter AHB_DW  = 6'd32;

parameter APB_AW  = 6'd11;
parameter APB_DW  = 6'd32;
parameter SLV_NUM = 4'd8;
parameter AHB_OFFSET = 18'b0000_0000_0000_0000_00; 


//------------------------------------------------------------------------------
// Port declarations
input logic                             ahb_clk;
input logic                             apb_clk;
input logic                             rst_n;
//---------------------------------
//AHB inputs
input logic                             hsel_i;
input logic [AHB_AW-1:0]                haddr_i;
input logic                             hwrite_i;
input logic  [1:0]                      htrans_i;
input logic  [2:0]                      hsize_i;
input logic  [2:0]                      hburst_i;
input logic  [AHB_DW-1:0]               hwdata_i;
input logic                             hready_i;
input logic                             hmastlock_i;
output logic                            hreadyout_o;
output logic                            hresp_o;
output logic [AHB_DW-1:0]               hrdata_o;
//---------------------------------
//APB interface, 8 slaves
output logic [SLV_NUM-1:0]              psel_o   ;
output logic                            pwrite_o ;
output logic                            penable_o;
output logic [APB_AW-1:0]               paddr_o  ;
output logic [APB_DW-1:0]               pwdata_o ;
output logic [3:0]                      pstrb_o  ;
output logic [3:0]                      pprot_o  ;
input logic  [SLV_NUM-1:0][APB_DW-1:0]  prdata_i ;
input logic  [SLV_NUM-1:0]              pslverr_i;
input logic  [SLV_NUM-1:0]              pready_i ;



//------------------------------------------------------------------------------
//internal signal
logic                                   trans_vld;
logic                                   size_vld;
logic                                   burst_vld;
logic                                   nonseq_vld;
logic                                   vld;
logic                                   vld_1;
logic                                   wen;
logic [AHB_AW-1:0]                      haddr;
logic                                   check_offset;

logic                                   cmd_ff_wen;
logic [46:0]                            cmd_ff_wdata;
logic                                   cmd_ff_full;
logic                                   cmd_ff_ren;
logic [46:0]                            cmd_ff_rdata;
logic                                   cmd_ff_empty;

logic                                   rdata_ff_wen;
logic [31:0]                            rdata_ff_wdata;
logic                                   rdata_ff_full;
logic                                   rdata_ff_ren;
logic [31:0]                            rdata_ff_rdata;
logic                                   rdata_ff_empty;

logic                                   nxt_cmd_ff_ren;
logic                                   cmd_ff_ren_1;
logic                                   cmd_ff_ren_2;
logic                                   cmd_ff_ren_3;
logic [46:0]                            nxt_cmd;
logic [46:0]                            cmd;
logic [7:0]                             sel_apb;
logic [7:0]                             nxt_psel;
logic                                   trans_done;
logic                                   nxt_pen;
logic                                   nxt_rdata_ff_ren;
logic                                   nxt_hreadyout;

//------------------------------------------------------------------------------
//Checking transfer is valid 
assign trans_vld  = hsel_i & hready_i;//transfer valid
assign size_vld   = (hsize_i == 3'b010);//32bit word
assign burst_vld  = (hburst_i == 3'b000);//only support single burst
assign nonseq_vld = (htrans_i == 2'b10);//only support NONSEQUENTIAL
assign vld = trans_vld & size_vld & burst_vld & nonseq_vld;

dffa_rstn  #(1)  dff_vld (ahb_clk,rst_n,vld,vld_1);

dffa_rstn  #(1)  dff_wen (ahb_clk,rst_n,hwrite_i,wen);

dffa_rstn  #(32)  dff_haddr (ahb_clk,rst_n,haddr_i,haddr);

assign check_offset = (haddr[31:14] == AHB_OFFSET); 
//------------------------------------------------------------------------------
//HREADYOUT control 
assign hresp_o = 1'b0;
assign nxt_hreadyout = ((~hwrite_i) & vld)  ? 1'b0 :
                       rdata_ff_ren ? 1'b1 : hreadyout_o;
                       
dffa_rstn  #(1,1'b1)  dff_hreadyout (ahb_clk,rst_n,nxt_hreadyout,hreadyout_o);


//------------------------------------------------------------------------------
//Asynchronous command FIFO
assign cmd_ff_wen = vld_1 & (~cmd_ff_full) & check_offset;
assign cmd_ff_wdata = {wen,hwdata_i[31:0],haddr[13:0]}; //47 bits

ahb2apb_async_fifo  #(.AW(2),
                      .DW(47))  async_cmd_fifo  
    (
    .rst_n   (rst_n),
    //-----------------------------
    //Write
    .wclk    (ahb_clk),//Write clock
    .wfifo_i (cmd_ff_wen),//Request writing FIFO
    .wdata_i (cmd_ff_wdata),
    .wfull_o (cmd_ff_full),
    //-----------------------------
    //Read
    .rclk    (apb_clk),//Read clock
    .rfifo_i (cmd_ff_ren),
    .rempty_o(cmd_ff_empty),
    .rdata_o (cmd_ff_rdata)
    );

//------------------------------------------------------------------------------
//Reading cmd fifo at APB site

assign nxt_cmd_ff_ren = (~cmd_ff_empty) & (~penable_o) & (~cmd_ff_ren) & 
                        (~cmd_ff_ren_1) & (~cmd_ff_ren_2) & (~cmd_ff_ren_3);

dffa_rstn  #(1)  dff_cmd_ff_ren (apb_clk,rst_n,nxt_cmd_ff_ren,cmd_ff_ren);
dffa_rstn  #(1)  dff_cmd_ff_ren_1 (apb_clk,rst_n,cmd_ff_ren,cmd_ff_ren_1);
dffa_rstn  #(1)  dff_cmd_ff_ren_2 (apb_clk,rst_n,cmd_ff_ren_1,cmd_ff_ren_2);
dffa_rstn  #(1)  dff_cmd_ff_ren_3 (apb_clk,rst_n,cmd_ff_ren_2,cmd_ff_ren_3);

//Latching output data of command fifo 
assign nxt_cmd = cmd_ff_ren_1 ? cmd_ff_rdata : cmd;

dffa_rstn  #(47)  dff_cmd_rdata (apb_clk,rst_n,nxt_cmd,cmd);

//Decode
assign sel_apb[0] = (cmd[13:11] == 3'b000);  
assign sel_apb[1] = (cmd[13:11] == 3'b001);  
assign sel_apb[2] = (cmd[13:11] == 3'b010);  
assign sel_apb[3] = (cmd[13:11] == 3'b011);  
assign sel_apb[4] = (cmd[13:11] == 3'b100);  
assign sel_apb[5] = (cmd[13:11] == 3'b101);  
assign sel_apb[6] = (cmd[13:11] == 3'b110);  
assign sel_apb[7] = (cmd[13:11] == 3'b111);  

//------------------------------------------------------------------------------
//PSEL0-7 control
assign trans_done  = penable_o & (|(pready_i & sel_apb));
assign nxt_psel[0] = trans_done ? 1'b0 :
                     (cmd_ff_ren_2 & sel_apb[0]) ? 1'b1 : psel_o[0];

assign nxt_psel[1] = trans_done ? 1'b0 :
                     (cmd_ff_ren_2 & sel_apb[1]) ? 1'b1 : psel_o[1];

assign nxt_psel[2] = trans_done ? 1'b0 :
                     (cmd_ff_ren_2 & sel_apb[2]) ? 1'b1 : psel_o[2];

assign nxt_psel[3] = trans_done ? 1'b0 :
                     (cmd_ff_ren_2 & sel_apb[3]) ? 1'b1 : psel_o[3];

assign nxt_psel[4] = trans_done ? 1'b0 :
                     (cmd_ff_ren_2 & sel_apb[4]) ? 1'b1 : psel_o[4];

assign nxt_psel[5] = trans_done ? 1'b0 :
                     (cmd_ff_ren_2 & sel_apb[5]) ? 1'b1 : psel_o[5];

assign nxt_psel[6] = trans_done ? 1'b0 :
                     (cmd_ff_ren_2 & sel_apb[6]) ? 1'b1 : psel_o[6];

assign nxt_psel[7] = trans_done ? 1'b0 :
                     (cmd_ff_ren_2 & sel_apb[7]) ? 1'b1 : psel_o[7];


dffa_rstn  #(8)  dff_psel (apb_clk,rst_n,nxt_psel,psel_o);

//------------------------------------------------------------------------------
//PENABLE control
assign nxt_pen = trans_done   ? 1'b0 :
                 cmd_ff_ren_3 ? 1'b1 : penable_o;
                  

dffa_rstn  #(1)  dff_pen (apb_clk,rst_n,nxt_pen,penable_o);
//------------------------------------------------------------------------------
//PADDR control
dffa_rstn  #(11)  dff_paddr (apb_clk,rst_n,cmd[10:0],paddr_o);

//------------------------------------------------------------------------------
//PWDATA control
dffa_rstn  #(32)  dff_pwdata (apb_clk,rst_n,cmd[45:14],pwdata_o);

//------------------------------------------------------------------------------
//PSTRB control
assign pstrb_o = 4'b1111;

//------------------------------------------------------------------------------
//PWRITE control
dffa_rstn  #(1)  dff_pwrite (apb_clk,rst_n,cmd[46],pwrite_o);

//------------------------------------------------------------------------------
//Control writing to read data fifo
assign rdata_ff_wen = (~rdata_ff_full) & trans_done & (~pwrite_o);
assign rdata_ff_wdata = sel_apb[0] ? prdata_i[0] :
                        sel_apb[1] ? prdata_i[1] :
                        sel_apb[2] ? prdata_i[2] :
                        sel_apb[3] ? prdata_i[3] :
                        sel_apb[4] ? prdata_i[4] :
                        sel_apb[5] ? prdata_i[5] :
                        sel_apb[6] ? prdata_i[6] : prdata_i[7];

//------------------------------------------------------------------------------
//Asynchronous read data FIFO

ahb2apb_async_fifo  #(.AW(2),
                      .DW(32))  async_rdata_fifo  
    (
    .rst_n   (rst_n),
    //-----------------------------
    //Write
    .wclk    (apb_clk),//Write clock, APB clock
    .wfifo_i (rdata_ff_wen),//Request writing FIFO
    .wdata_i (rdata_ff_wdata),
    .wfull_o (rdata_ff_full),
    //-----------------------------
    //Read
    .rclk    (ahb_clk),//Read clock, AHB clock
    .rfifo_i (rdata_ff_ren),
    .rempty_o(rdata_ff_empty),
    .rdata_o (rdata_ff_rdata)
    );

//------------------------------------------------------------------------------
//Control reading RDATA fifo
assign nxt_rdata_ff_ren = (~rdata_ff_empty) & (~rdata_ff_ren);

dffa_rstn  #(1)  dff_rdata_ff_ren (ahb_clk,rst_n,nxt_rdata_ff_ren,rdata_ff_ren);
//------------------------------------------------------------------------------
//Control reading RDATA fifo
assign hrdata_o = rdata_ff_rdata;

endmodule 

