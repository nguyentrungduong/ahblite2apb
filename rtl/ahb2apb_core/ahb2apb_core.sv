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


parameter IDLE    = 2'b00;
parameter SETUP   = 2'b01;
parameter ACCESS  = 2'b10;
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

logic [46:0]                            nxt_cmd;
logic [46:0]                            cmd;
logic [7:0]                             sel_apb;
logic [7:0]                             nxt_psel;
logic                                   trans_done;
logic                                   nxt_pen;
logic                                   nxt_rdata_ff_ren;
logic                                   nxt_hreadyout;
logic                                   hreadyout;

logic [1:0]                             nxt_apb_st;
logic [1:0]                             apb_st;
logic                                   idle_2_setup;
logic                                   access_2_setup;
logic                                   access_2_idle;
logic                                   st_idle;
logic                                   st_access;


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
assign nxt_hreadyout = ((~hwrite_i) & vld) ? 1'b0 :
                       rdata_ff_ren ? 1'b1 : hreadyout;
                       
dffa_rstn  #(1,1'b1)  dff_hreadyout (ahb_clk,rst_n,nxt_hreadyout,hreadyout);

assign hreadyout_o = hreadyout & (~cmd_ff_full);
//------------------------------------------------------------------------------
//Asynchronous command FIFO
assign cmd_ff_wen = vld_1 & (~cmd_ff_full) & check_offset;
assign cmd_ff_wdata = {wen,hwdata_i[31:0],haddr[13:0]}; //47 bits

ahb2apb_async_fifo  #(.AW(2),
                      .DW(47))  async_cmd_fifo  
    (
    .rst_n   (rst_n)       ,
    //-----------------------------
    //Write
    .wclk    (ahb_clk)     ,//Write clock
    .wfifo_i (cmd_ff_wen)  ,//Request writing FIFO
    .wdata_i (cmd_ff_wdata),
    .wfull_o (cmd_ff_full) ,
    //-----------------------------
    //Read
    .rclk    (apb_clk)     ,//Read clock
    .rfifo_i (cmd_ff_ren)  ,
    .rempty_o(cmd_ff_empty),
    .rdata_o (cmd_ff_rdata)
    );

//------------------------------------------------------------------------------
//APB master state machine

assign idle_2_setup   = (~cmd_ff_empty) & st_idle;
assign access_2_setup = pready_i & (~cmd_ff_empty) & st_access;
assign access_2_idle  = pready_i & cmd_ff_empty & st_access;


always @ (*)
    begin
    case (apb_st)
    	IDLE :
            begin
    	    nxt_apb_st = idle_2_setup ? SETUP : IDLE;
    	    end	
    	SETUP :
    	    begin
    	    nxt_apb_st = ACCESS;
    	    end	
    	ACCESS :
    	    begin
    	    nxt_apb_st = access_2_setup ? SETUP :
                         access_2_idle  ? IDLE  : ACCESS;
    	    end	
    	default :
    	    begin
    	    nxt_apb_st = IDLE;
    	    end	
    endcase
    end

dffa_rstn #(2) dff_apb_st (apb_clk,rst_n,nxt_apb_st,apb_st);

assign st_idle   = (apb_st == IDLE);
assign st_access = (apb_st == ACCESS);
//------------------------------------------------------------------------------
//Reading command FIFO
assign cmd_ff_ren = idle_2_setup | access_2_setup;


//Latching output data of command fifo
assign nxt_cmd = cmd_ff_ren ? cmd_ff_rdata : cmd;

dffa_rstn  #(47)  dff_cmd_rdata (apb_clk,rst_n,nxt_cmd,cmd);

//Adress decode
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

assign psel_o = sel_apb;

//------------------------------------------------------------------------------
//PENABLE control
assign nxt_pen = st_access; 
dffa_rstn  #(1)  dff_pen (apb_clk,rst_n,nxt_pen,penable_o);
//------------------------------------------------------------------------------
//PADDR control
assign paddr_o = cmd[10:0];

//------------------------------------------------------------------------------
//PWDATA control
assign pwdata_o = cmd[45:14];

//------------------------------------------------------------------------------
//PSTRB control
assign pstrb_o = 4'b1111;

//------------------------------------------------------------------------------
//PWRITE control
assign pwrite_o = cmd[46];
//------------------------------------------------------------------------------
//Control writing to read data fifo
assign rdata_ff_wen = (~rdata_ff_full) & (access_2_setup | access_2_idle) & 
                      (~pwrite_o);

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

