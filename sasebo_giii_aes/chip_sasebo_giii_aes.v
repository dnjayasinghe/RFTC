/*-------------------------------------------------------------------------
 AES cryptographic module for FPGA on SASEBO-GIII
 
 File name   : chip_sasebo_giii_aes.v
 Version     : 1.0
 Created     : APR/02/2012
 Last update : APR/25/2013
 Desgined by : Toshihiro Katashita
 
 
 Copyright (C) 2012,2013 AIST
 
 By using this code, you agree to the following terms and conditions.
 
 This code is copyrighted by AIST ("us").
 
 Permission is hereby granted to copy, reproduce, redistribute or
 otherwise use this code as long as: there is no monetary profit gained
 specifically from the use or reproduction of this code, it is not sold,
 rented, traded or otherwise marketed, and this copyright notice is
 included prominently in any copy made.
 
 We shall not be liable for any damages, including without limitation
 direct, indirect, incidental, special or consequential damages arising
 from the use of this code.
 
 When you publish any results arising from the use of this code, we will
 appreciate it if you can cite our paper.
 (http://www.risec.aist.go.jp/project/sasebo/)
 -------------------------------------------------------------------------*/


//================================================ CHIP_SASEBO_GIII_AES
module CHIP_SASEBO_GIII_AES
  (// Local bus for GII
   lbus_di_a, lbus_do, lbus_wrn, lbus_rdn,
   lbus_clkn, lbus_rstn,

   // GPIO and LED
   gpio_startn, gpio_endn, gpio_exec, led,

   // Clock OSC
   osc_en_b//,
	//clk1
	);
   
   //------------------------------------------------
   // Local bus for GII
   input [15:0]  lbus_di_a;
   output [15:0] lbus_do;
   input         lbus_wrn, lbus_rdn;
   input         lbus_clkn, lbus_rstn;

   // GPIO and LED
   output        gpio_startn, gpio_endn, gpio_exec;
   output [9:0]  led;

   // Clock OSC
   output        osc_en_b;
	
	//output clk1;
	//;

   //------------------------------------------------
   // Internal clock
   wire         clk, rst;

   // Local bus
   reg [15:0]   lbus_a, lbus_di;
   
   // Block cipher
   wire [127:0] blk_kin, blk_din, blk_dout;
   wire         blk_krdy, blk_kvld, blk_drdy, blk_dvld;
   wire         blk_encdec, blk_en, blk_rstn, blk_busy;
   reg          blk_drdy_delay;
  
  
  //------------------------------------------------
  
  
  

	reg [127:0] blk_kin1,  blk_kin2,  blk_kin3,blk_kin4;
	reg [127:0] blk_din1,  blk_din2,  blk_din3,blk_din4;
	reg [127:0] Blk_dout1, Blk_dout2, Blk_dout3,Blk_dout4;
	
	reg   blk_krdy1, blk_krdy2, blk_krdy3,blk_krdy4;
	reg   blk_drdy1, blk_drdy2, blk_drdy3,blk_drdy4;
	reg   Blk_kvld1, Blk_kvld2, Blk_kvld3,Blk_kvld4;
	reg   Blk_dvld1, Blk_dvld2, Blk_dvld3,Blk_dvld4;
	reg   blk_en1,   blk_en2,   blk_en3,blk_en4;
	reg   Blk_busy1, Blk_busy2, Blk_busy3,Blk_busy4;
	reg   blk_rstn1, blk_rstn2, blk_rstn3,blk_rstn4;
	reg   blk_encdec1, blk_encdec2, blk_encdec3,blk_encdec4;
	
	wire clk0, clk1, clk2, clk3, clk4, clk5;
	wire clko1, clko2, clko3, clko;
  
   //------------------------------------------------
   assign led[0] = rst;
   assign led[1] = lbus_rstn;
   assign led[2] = 1'b0;
   assign led[3] = blk_rstn;
   assign led[4] = blk_encdec;
   assign led[5] = blk_krdy;
   assign led[6] = blk_kvld;
   assign led[7] = 1'b0;
   assign led[8] = blk_dvld;
   assign led[9] = blk_busy;

   assign osc_en_b = 1'b0;
   //------------------------------------------------
   always @(posedge clk) if (lbus_wrn)  lbus_a  <= lbus_di_a;
   always @(posedge clk) if (~lbus_wrn) lbus_di <= lbus_di_a;
//
//
//  LBUS_IF lbus_if
//     (.lbus_a(lbus_a), .lbus_di(lbus_di), .lbus_do(lbus_do),
//      .lbus_wr(lbus_w), .lbus_rd(lbus_r),
//      .blk_kin(blk_kin), .blk_din(blk_din), .blk_dout(Blk_dout4),
//      .blk_krdy(blk_krdy), .blk_drdy(blk_drdy), 
//      .blk_kvld(Blk_kvld4), .blk_dvld(Blk_dvld4),
//      .blk_encdec(blk_encdec), .blk_en(blk_en), .blk_rstn(blk_rstn),
//      .clk(clk), .rst(rst));

   LBUS_IF lbus_if
     (.lbus_a(lbus_a), .lbus_di(lbus_di), .lbus_do(lbus_do),
      .lbus_wr(lbus_wrn), .lbus_rd(lbus_rdn),
      .blk_kin(blk_kin), .blk_din(blk_din), .blk_dout(Blk_dout4),
      .blk_krdy(blk_krdy), .blk_drdy(blk_drdy), 
      .blk_kvld(Blk_kvld4), .blk_dvld(Blk_dvld4),
      .blk_encdec(blk_encdec), .blk_en(blk_en), .blk_rstn(blk_rstn),
      .clk(lbus_clkn), .rst(rst));

   //------------------------------------------------
   assign gpio_startn = ~blk_drdy4;
   assign gpio_endn   = 1'b0; //~blk_dvld;
   assign gpio_exec   = 1'b0; //blk_busy;

   always @(posedge clk) blk_drdy_delay <= blk_drdy;

   AES_Composite_enc AES_Composite_enc
     (.Kin(blk_kin4), .Din(blk_din4), .Dout(blk_dout),
      .Krdy(blk_krdy4), .Drdy1(blk_drdy4), .Kvld(blk_kvld), .Dvld(blk_dvld),
      .EncDec(blk_encdec4), .EN(blk_en4), .BSY(blk_busy),
      .CLK(clko), .RSTn(blk_rstn4));

   //------------------------------------------------   
   MK_CLKRST mk_clkrst (.clkin(lbus_clkn), .rstnin(lbus_rstn),
                        .clk(clk), .rst(rst));

//  AES_ENC AES_ENC
//     (.Kin(blk_kin4), .Din(blk_din4), .Dout(blk_dout),
//      .Krdy(blk_krdy4), .Drdy(blk_drdy4), .Kvld(blk_kvld), .Dvld(blk_dvld),
//      .EncDec(blk_encdec4), .EN(blk_en4), .BSY(blk_busy),
//      .CLK(clko), .RSTn(blk_rstn4));
//
//   //------------------------------------------------   
//   MK_CLKRST mk_clkrst (.clkin(lbus_clk), .rstnin(lbus_rstn),
//                        .clk(clk), .rst(rst));
								
//wire clkoo1, clko2, clkoo;
wire lsfrout,lsfrout1;
reg [127:0] lsfr; reg Sready; reg [9:0] cou, cou1; reg en, en1; wire clocked2;

BUFGCTRL #(
.INIT_OUT(0), // Initial value of BUFGCTRL output ($VALUES;)
.PRESELECT_I0("FALSE"), // BUFGCTRL output uses I0 input ($VALUES;)
.PRESELECT_I1("FALSE") // BUFGCTRL output uses I1 input ($VALUES;)
)
BUFGCTRL_inst (
.O(clko), // 1-bit output: Clock output
.CE0(1'b1), // 1-bit input: Clock enable input for I0
.CE1(1'b1), // 1-bit input: Clock enable input for I1
.I0(lbus_clkn), // 1-bit input: Primary clock
.I1(clko2), // 1-bit input: Secondary clock
.IGNORE0(1'b0), // 1-bit input: Clock ignore input for I0
.IGNORE1(1'b0), // 1-bit input: Clock ignore input for I1
.S0((blk_drdy |~en |~blk_busy )), // 1-bit input: Clock select for I0
.S1(~((blk_drdy |~en |~blk_busy ))) // 1-bit input: Clock select for I1
);


//BUFGCTRL #(
//.INIT_OUT(0), // Initial value of BUFGCTRL output ($VALUES;)
//.PRESELECT_I0("FALSE"), // BUFGCTRL output uses I0 input ($VALUES;)
//.PRESELECT_I1("FALSE") // BUFGCTRL output uses I1 input ($VALUES;)
//)
//BUFGCTRL_inst1 (
//.O(clko1), // 1-bit output: Clock output
//.CE0(1'b1), // 1-bit input: Clock enable input for I0
//.CE1(1'b1), // 1-bit input: Clock enable input for I1
//.I0(clk2), // 1-bit input: Primary clock
//.I1(clk1), // 1-bit input: Secondary clock
//.IGNORE0(1'b0), // 1-bit input: Clock ignore input for I0
//.IGNORE1(1'b0), // 1-bit input: Clock ignore input for I1
//.S0(lsfr[127]), // 1-bit input: Clock select for I0
//.S1(~(lsfr[127])) // 1-bit input: Clock select for I1
//);
//assign clko1 = (lsfrout)? clk1:clk2;
//assign clko2 = (lsfrout)? clk3:clk4;
//assign clko3 = (lsfrout1)? clko1:clko2;

BUFGMUX_CTRL BUFGMUX_CTRL_inst0 (
.O(clko1 ), // 1-bit output: Clock output
.I0(clk1), // 1-bit input: Clock input (S=0)
.I1(clk2), // 1-bit input: Clock input (S=1)
.S(lsfrout) // 1-bit input: Clock select
);

BUFGMUX_CTRL BUFGMUX_CTRL_inst1 (
.O(clko2 ), // 1-bit output: Clock output
.I0(clk3), // 1-bit input: Clock input (S=0)
.I1(clko1), // 1-bit input: Clock input (S=1)
.S(lsfrout1) // 1-bit input: Clock select
);
//
//BUFGMUX_CTRL BUFGMUX_CTRL_inst11 (
//.O(clko3 ), // 1-bit output: Clock output
//.I0(clko1), // 1-bit input: Clock input (S=0)
//.I1(clko2), // 1-bit input: Clock input (S=1)
//.S(lsfrout1) // 1-bit input: Clock select
//);

 //comp	comp(.CLKIN1_IN(lbus_clkn), .RST_IN(~lbus_rstn),.CLKOUT0_OUT(clk0), .CLKOUT1_OUT(clk1), .CLKOUT2_OUT(clk2), .CLKOUT3_OUT(clk3), .CLKOUT4_OUT(clk4), .CLKOUT5_OUT(clk5), .LOCKED_OUT(locked));
//assign clko= clk1;
 //clkswitch1 c1(lbus_clkn, clk1,(blk_drdy |~en |~blk_busy ), clko);
 // clkswitch c2(clk0, clk1, lsfr[127], clkoo1);


 //test t0(clk1, ~lbus_rstn, clk3, clk4, clocked2);
	
//MUXF7 MUXF7_inst (
//.O(clkoo2), // Output of MUX to general routing
//.I0(clkoo1), // Input (tie to LUT6 O6 pin)
//.I1(clk3), // Input (tie to LUT6 O6 pin)
//.S(lsfr[126]) // Input select to MUX
//);
//	
//BUFGMUX BUFGMUX_inst0 (
//.O(clkoo1), // 1-bit output: Clock output
//.I0(clk1), // 1-bit input: Clock input (S=0)
//.I1(clk2), // 1-bit input: Clock input (S=1)
//.S(lsfr[127]) // 1-bit input: Clock select
//);	


//BUFGMUX BUFGMUX_inst1 (
//.O(clkoo2), // 1-bit output: Clock output
//.I0(clk3), // 1-bit input: Clock input (S=0)
//.I1(clk4), // 1-bit input: Clock input (S=1)
//.S(lsfr[127]) // 1-bit input: Clock select
//);	
	
//BUFGMUX BUFGMUX_inst2 (
//.O(clkoo), // 1-bit output: Clock output
//.I0(clkoo1), // 1-bit input: Clock input (S=0)
//.I1(clk3), // 1-bit input: Clock input (S=1)
//.S(lsfr[126]) // 1-bit input: Clock select
//);	
	
//	reg tick; //always @(posedge clk or negedge locked)
//	always @ (posedge blk_dvld1 or negedge blk_dvld ) begin
//	//if(lbus_rstn==0) begin
//	//lsfr <= 128'h0000000000000000000000000000000f;
//	//end
//	//else begin
//	//lsfr[127:0]<={lsfr[126:0],lsfr[127] ^ lsfr[126] ^ lsfr[125] ^ lsfr[120] ^ lsfr[0]} ; //X128+ X127 + X126 + X121 + 1
//	//end
//	
//	if(blk_dvld==1) lsfr[127:0]<={lsfr[126:0],lsfr[127] ^ lsfr[126] ^ lsfr[125] ^ lsfr[120] ^ lsfr[0]} ; //X128+ X127 + X126 + X121 + 1
//	else lsfr[127] <= 1'b1;
//	end

reg[4:0] counter; 
reg[9:0] saddr;
//reg[11:0] saddr;
reg sen;  wire srdy;
    wire [15:0]do1;
    wire drdy;
    wire locked;
    wire dwe;
    wire den;
    wire [6:0]daddr;
    wire [15:0]di;
    wire dclk;
    wire rst_mmcm; 
    
    wire CLKFBOUT, CLKFBIN;
    
    wire psdone_unused, locked_unused, clkinstopped_unused, clkfbstopped_unused;  
//    reg sen; 


//
//always @(posedge clk or negedge lbus_rstn) begin
//if (lbus_rstn==0)begin
//lsfr <=128'h0000000000000000000000000f0f003;
//sen <= 1'b0;
//saddr <= 12'b0;
//counter <=0;
//end
//else begin
//if(blk_drdy==0) begin counter <=0;
//sen  <=0;
//end
//else if (Blk_dvld1==1 & counter !=4)begin
//lsfr[127:0]<={lsfr[126:0],lsfr[127] ^ lsfr[126] ^ lsfr[125] ^ lsfr[120] ^ lsfr[0]} ; //X128+ X127 + X126 + X121 + 1
//counter <= counter+1;
//if(saddr==31) saddr <= 0;
//else saddr <= saddr+1;
//sen   <= 0;
//end else if(srdy==1 & counter ==4) begin
//sen <=1;
//end
//end
//end
	
//wire run = lbus_rstn | srdy;
assign lsfrout  =lsfr[127];
assign lsfrout1 =lsfr[126];
//assign clk0 = (en==0 )? clk: clk1;
	
 
always @(posedge lbus_clkn ) begin
if (lbus_rstn==0)begin
 cou <=0;
 sen  <=0;
 en1  <=0;
 saddr <=0;
 Sready <=0;
 cou1   <=0;
 lsfr <= 128'h890000000057c03b00f1000000000000f;
end
else begin
lsfr[127:0]<={lsfr[126:0],lsfr[127] ^ lsfr[126] ^ lsfr[125] ^ lsfr[120] ^ lsfr[0]} ; //X128+ X127 + X126 + X121 + 1
	if(srdy==1) begin
	Sready <=1;
	end

	if(Sready==1) begin
		if(cou1==3) begin
			cou1 <=0;
			en <=1;
		end
		else begin
			cou1 <= cou1 +1;
		end
	end
	//else en <=0;

	if(sen==1) begin 
		sen  <=0;
		en1  <=0;
			if(saddr==8) saddr <= 0;
			else saddr <= saddr +1;
			//saddr <= ~saddr;
			//saddr <= ~saddr;
		end
	else if(cou==4& Sready ==1)begin
		cou <=0;
		sen  <=1;
		Sready <=0;
		en1  <=0;
		en   <=0;
		//en  <=0;
	end
	else if(Blk_dvld2==1 & en1==1) begin
   	cou <=cou+1;
		en1 <=0;
	 //  en  <=1;
	 //sen  <=1;
	end
	else if (blk_dvld==0) begin
		en1 <=1;
	end
end
end

//
//always @(posedge lbus_clkn or negedge lbus_rstn) begin
//if (lbus_rstn==0)begin
////sen <= 1'b0;
//saddr <= 12'b0;
//counter <=0;
//en      <=0;
//end
//else begin  // when rst high
//if(en ==1 & srdy==1 & sen ==0 & blk_dvld==1) begin 
////sen  <=1;
//en <=0;
//	if(saddr==4) saddr <= 0;
//	else saddr <= saddr +1;
//
//end
////else if (en ==0) //sen <=0;
//else if (blk_dvld==0) begin
//en <=1;
//end	
//end // end rst high	
//end	

	always @(posedge lbus_clkn) begin
	
	if (lbus_rstn == 0) begin
		blk_kin1 <=0;
		blk_din1 <=0;
		
		Blk_dout2 <= 0;
		Blk_dout3 <= 0;
		Blk_dout4 <= 0;
		
		blk_krdy1 <= 0;
		blk_drdy1 <= 0;
		blk_en1   <= 0;
		blk_rstn1 <= 0;
		
		Blk_kvld2 <= 0;
		Blk_kvld3 <= 0;
		Blk_kvld4 <= 0;
		
		Blk_dvld2 <= 0;
		Blk_dvld3 <= 0;
		
	end else begin
		blk_kin1 <= blk_kin;
		blk_din1 <= blk_din;
		
		Blk_dout2 <= Blk_dout1;
		Blk_dout3 <= Blk_dout2;
		Blk_dout4 <= Blk_dout3;
		
		blk_krdy1 <= blk_krdy;
		blk_drdy1 <= blk_drdy;
		blk_en1   <= blk_en;
		blk_rstn1 <= blk_rstn;
		
		Blk_kvld2 <= Blk_kvld1;
		Blk_kvld3 <= Blk_kvld2;
		Blk_kvld4 <= Blk_kvld3;
		
		//Blk_dvld2 <= Blk_dvld1;
		//Blk_dvld3 <= Blk_dvld2;
		
		//if(blk_drdy==1) begin
		//	Blk_dvld4 <= 0;
		//	Blk_dvld2 <= 0;
		//	Blk_dvld3 <= 0;
		//	end
		//	else begin
			Blk_dvld4 <= Blk_dvld3;
			Blk_dvld2 <= Blk_dvld1;
			Blk_dvld3 <= Blk_dvld2;
		//end
		
		Blk_busy2 <= Blk_busy1;
		Blk_busy3 <= Blk_busy2;
		Blk_busy4 <= Blk_busy3;
		blk_encdec1 <= blk_encdec;
		end
		
	end	
	always @(posedge clko) begin
			blk_kin2 <= blk_kin1;
			blk_kin3 <= blk_kin2;
			blk_kin4 <= blk_kin3;
		
			blk_din2 <= blk_din1;
			blk_din3 <= blk_din2;
			blk_din4 <= blk_din3;
		
			Blk_dout1 <= blk_dout;
			
			blk_krdy2 <= blk_krdy1;
			blk_krdy3 <= blk_krdy2;
			blk_krdy4 <= blk_krdy3;
			
			blk_drdy2 <= blk_drdy1;
			blk_drdy3 <= blk_drdy2;
			blk_drdy4 <= blk_drdy3;
			
			blk_en2   <= blk_en1;
			blk_en3   <= blk_en2;
			blk_en4   <= blk_en3;
			
			blk_rstn2 <= blk_rstn1;
			blk_rstn3 <= blk_rstn2;
			blk_rstn4 <= blk_rstn3;
			
			Blk_kvld1 <= blk_kvld;
			Blk_dvld1 <= blk_dvld;
			
			Blk_busy1 <= blk_busy;
			
			blk_encdec2 <= blk_encdec1;
			blk_encdec3 <= blk_encdec2;
			blk_encdec4 <= blk_encdec3;
	end	
	

     mmcme2_drp drp(
    .SADDR(saddr),   // input             SADDR,
    .SEN(sen),     // input             SEN,
    .SCLK(lbus_clkn),    // input             SCLK,
    .RST(~lbus_rstn),     // input             RST,
    .SRDY(srdy),    // output reg        SRDY,
    
//    // These signals are to be connected to the MMCM_ADV by port name.
//    // Their use matches the MMCM port description in the Device User Guide.
     
    .DO(do1),      //  input      [15:0] DO,
    .DRDY(drdy),    //  input             DRDY,  
    .LOCKED(locked),  //  input             LOCKED,  
    .DWE(dwe),     //  output reg        DWE,  
    .DEN(den),     //  output reg        DEN,  
    .DADDR(daddr),   //  output reg [6:0]  DADDR,  
    .DI(di),      //  output reg [15:0] DI,  
    .DCLK(dclk),    //  output            DCLK,  
    .RST_MMCM(rst_mmcm) //  output reg        RST_MMCM  
     );
 
   MMCME2_ADV
 #(.BANDWIDTH            ("OPTIMIZED"),
   .CLKOUT4_CASCADE      ("FALSE"),
   .COMPENSATION         ("ZHOLD"),
   .STARTUP_WAIT         ("TRUE"),
   .DIVCLK_DIVIDE        (2),
   .CLKFBOUT_MULT_F      (40.000),
   .CLKFBOUT_PHASE       (0.000),
   .CLKFBOUT_USE_FINE_PS ("FALSE"),
   .CLKOUT0_DIVIDE_F     (40.000),
   .CLKOUT0_PHASE        (0.000),
   .CLKOUT0_DUTY_CYCLE   (0.500),
   .CLKOUT0_USE_FINE_PS  ("FALSE"),
   .CLKOUT1_DIVIDE       (40),
   .CLKOUT1_PHASE        (0.000),
   .CLKOUT1_DUTY_CYCLE   (0.500),
   .CLKOUT1_USE_FINE_PS  ("FALSE"),
   .CLKOUT2_DIVIDE       (32),
   .CLKOUT2_PHASE        (0.000),
   .CLKOUT2_DUTY_CYCLE   (0.500),
   .CLKOUT2_USE_FINE_PS  ("FALSE"),
   .CLKOUT3_DIVIDE       (28),
   .CLKOUT3_PHASE        (0.000),
   .CLKOUT3_DUTY_CYCLE   (0.500),
   .CLKOUT3_USE_FINE_PS  ("FALSE"),
   .CLKIN1_PERIOD        (41.0),
   .REF_JITTER1          (0.00010))
 mmcm_adv_inst
   // Output clocks
  (.CLKFBOUT            (CLKFBOUT),
   .CLKFBOUTB           (),
   .CLKOUT0             (clk1),
   .CLKOUT0B            (),
   .CLKOUT1             (clk2),
   .CLKOUT1B            (),
   .CLKOUT2             (clk3),
   .CLKOUT2B            (),
   .CLKOUT3             (clk4),
   .CLKOUT3B            (),
   .CLKOUT4             (),
   .CLKOUT5             (),
   .CLKOUT6             (),
    // Input clock control
   .CLKFBIN             (CLKFBOUT),
   .CLKIN1              (lbus_clkn),
   .CLKIN2              (1'b0),
    // Tied to always select the primary input clock
   .CLKINSEL            (1'b1),
   // Ports for dynamic reconfiguration
   .DADDR               (daddr),
   .DCLK                (dclk),
   .DEN                 (den),
   .DI                  (di),
   .DO                  (do1),
   .DRDY                (drdy),
   .DWE                 (dwe),
   // Ports for dynamic phase shift
   .PSCLK               (1'b0),
   .PSEN                (1'b0),
   .PSINCDEC            (1'b0),
   .PSDONE              (psdone_unused),
   // Other control and status signals
   .LOCKED              (locked),
   .CLKINSTOPPED        (clkinstopped_unused),
   .CLKFBSTOPPED        (clkfbstopped_unused),
   .PWRDWN              (1'b0),
   .RST                 (rst_mmcm));
 
// wire CLKFBOUT_CLKFBIN;
//   PLL_ADV #( .BANDWIDTH("OPTIMIZED"), .CLKIN1_PERIOD(40), //41.667
//         .CLKIN2_PERIOD(), .CLKOUT0_DIVIDE(30), .CLKOUT1_DIVIDE(40), 
//         .CLKOUT2_DIVIDE(20), .CLKOUT3_DIVIDE(8), .CLKOUT4_DIVIDE(14), 
//         .CLKOUT5_DIVIDE(7.5), .CLKOUT0_PHASE(0.000), .CLKOUT1_PHASE(0.000), 
//         .CLKOUT2_PHASE(0.000), .CLKOUT3_PHASE(0.000), .CLKOUT4_PHASE(0.000), 
//         .CLKOUT5_PHASE(0.000), .CLKOUT0_DUTY_CYCLE(0.500), 
//         .CLKOUT1_DUTY_CYCLE(0.500), .CLKOUT2_DUTY_CYCLE(0.500), 
//         .CLKOUT3_DUTY_CYCLE(0.500), .CLKOUT4_DUTY_CYCLE(0.500), 
//         .CLKOUT5_DUTY_CYCLE(0.500), .COMPENSATION("SYSTEM_SYNCHRONOUS"), 
//         .DIVCLK_DIVIDE(1), .CLKFBOUT_MULT(20), .CLKFBOUT_PHASE(0.0), 
//         .REF_JITTER(0.000500) ) 
//			PLL_ADV_INST (.CLKFBIN(CLKFBOUT_CLKFBIN), 
//                         .CLKINSEL(1'b1), 
//                         //.CLKINSEL(1'b0), 
//                         .CLKIN1(clk1), 
//                         .CLKIN2(),  
//                         .RST(rst_mmcm), 
//                         .CLKFBDCM(CLKFBOUT_CLKFBIN), 
//                         .CLKFBOUT(), 
//                         .CLKOUTDCM0(), 
//                         .CLKOUTDCM1(), 
//                         .CLKOUTDCM2(), 
//                         .CLKOUTDCM3(), 
//                         .CLKOUTDCM4(), 
//                         .CLKOUTDCM5(), 
//                         .CLKOUT0(clk4), 
//                         .CLKOUT1(), 
//                         .CLKOUT2(), 
//                         .CLKOUT3(), 
//                         .CLKOUT4(), 
//                         .CLKOUT5(), 
//                         .DO(), 
//                         .DRDY(), 
//                         .LOCKED(LOCKED_OUT));
 
 
 
 //wire CLKFBIN1;
 //  BUFG clkf_buf
 //     (.O (CLKFBIN1),
 //      .I (CLKFBOUT));
          	
//BUFG clkf_buf1
//      (.O (CLKFBIN),
//       .I (CLKFBIN1));
          	
	
								
endmodule // CHIP_SASEBO_GIII_AES




////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 14.7
//  \   \         Application : xaw2verilog
//  /   /         Filename : comp1.v
// /___/   /\     Timestamp : 11/27/2017 12:14:10
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: xaw2verilog -st E:\Microblaze\CLK-scrmb\GII\randclkswitch\v00.0\sasebo_gii_aes_comp\sasebo_gii_aes_comp_lx50\ipcore_dir\.\comp1.xaw E:\Microblaze\CLK-scrmb\GII\randclkswitch\v00.0\sasebo_gii_aes_comp\sasebo_gii_aes_comp_lx50\ipcore_dir\.\comp1
//Design Name: comp1
//Device: xc5vlx50-2ff324
//
// Module comp1
// Generated by Xilinx Architecture Wizard
// Written for synthesis tool: XST
// For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT0 = 0.246 ns
// For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT1 = 0.248 ns
// For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT2 = 0.250 ns
// For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT3 = 0.252 ns
// For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT4 = 0.253 ns
// For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT5 = 0.255 ns
`timescale 1ns / 1ps

module comp(CLKIN1_IN, 
             RST_IN, 
             CLKOUT0_OUT, 
             CLKOUT1_OUT, 
             CLKOUT2_OUT, 
             CLKOUT3_OUT, 
             CLKOUT4_OUT, 
             CLKOUT5_OUT, 
             LOCKED_OUT);

    input CLKIN1_IN;
    input RST_IN;
   output CLKOUT0_OUT;
   output CLKOUT1_OUT;
   output CLKOUT2_OUT;
   output CLKOUT3_OUT;
   output CLKOUT4_OUT;
   output CLKOUT5_OUT;
   output LOCKED_OUT;
   
  
   wire CLKFBOUT_CLKFBIN;
   wire CLKIN1_IBUFG;
   wire CLKOUT0_BUF;
   wire CLKOUT1_BUF;
   wire CLKOUT2_BUF;
   wire CLKOUT3_BUF;
   wire CLKOUT4_BUF;
   wire CLKOUT5_BUF;
   wire GND_BIT;
   wire [4:0] GND_BUS_5;
   wire [15:0] GND_BUS_16;
   wire VCC_BIT;
   
   assign GND_BIT = 0;
   assign GND_BUS_5 = 5'b00000;
   assign GND_BUS_16 = 16'b0000000000000000;
   assign VCC_BIT = 1;
  // IBUFG  CLKIN1_IBUFG_INST (.I(CLKIN1_IN), 
  //                          .O(CLKIN1_IBUFG));
   //BUFG  CLKOUT0_BUFG_INST (.I(CLKOUT0_BUF), 
   //                        .O(CLKOUT0_OUT));
   //BUFG  CLKOUT1_BUFG_INST (.I(CLKOUT1_BUF), 
   //                        .O(CLKOUT1_OUT));
   //BUFG  CLKOUT2_BUFG_INST (.I(CLKOUT2_BUF), 
   //                        .O(CLKOUT2_OUT));
   //BUFG  CLKOUT3_BUFG_INST (.I(CLKOUT3_BUF), 
   //                        .O(CLKOUT3_OUT));
   //BUFG  CLKOUT4_BUFG_INST (.I(CLKOUT4_BUF), 
   //                        .O(CLKOUT4_OUT));
   //BUFG  CLKOUT5_BUFG_INST (.I(CLKOUT5_BUF), 
   //                        .O(CLKOUT5_OUT));
   PLL_ADV #( .BANDWIDTH("OPTIMIZED"), .CLKIN1_PERIOD(31.6666667), //41.667
         .CLKIN2_PERIOD(10.000), .CLKOUT0_DIVIDE(33), .CLKOUT1_DIVIDE(40), 
         .CLKOUT2_DIVIDE(30), .CLKOUT3_DIVIDE(8), .CLKOUT4_DIVIDE(14), 
         .CLKOUT5_DIVIDE(7.5), .CLKOUT0_PHASE(0.000), .CLKOUT1_PHASE(0.000), 
         .CLKOUT2_PHASE(0.000), .CLKOUT3_PHASE(0.000), .CLKOUT4_PHASE(0.000), 
         .CLKOUT5_PHASE(0.000), .CLKOUT0_DUTY_CYCLE(0.500), 
         .CLKOUT1_DUTY_CYCLE(0.500), .CLKOUT2_DUTY_CYCLE(0.500), 
         .CLKOUT3_DUTY_CYCLE(0.500), .CLKOUT4_DUTY_CYCLE(0.500), 
         .CLKOUT5_DUTY_CYCLE(0.500), .COMPENSATION("SYSTEM_SYNCHRONOUS"), 
         .DIVCLK_DIVIDE(2), .CLKFBOUT_MULT(60), .CLKFBOUT_PHASE(0.0), 
         .REF_JITTER(0.000050) ) PLL_ADV_INST (.CLKFBIN(CLKFBOUT_CLKFBIN), 
                         .CLKINSEL(1'b1), 
                         //.CLKINSEL(1'b0), 
                         .CLKIN1(CLKIN1_IN), 
                         .CLKIN2(), 
                         .DADDR(GND_BUS_5[4:0]), 
                         .DCLK(GND_BIT), 
                         .DEN(GND_BIT), 
                         .DI(GND_BUS_16[15:0]), 
                         .DWE(GND_BIT), 
                         .REL(GND_BIT), 
                         .RST(RST_IN), 
                         .CLKFBDCM(), 
                         .CLKFBOUT(CLKFBOUT_CLKFBIN), 
                         .CLKOUTDCM0(), 
                         .CLKOUTDCM1(), 
                         .CLKOUTDCM2(), 
                         .CLKOUTDCM3(), 
                         .CLKOUTDCM4(), 
                         .CLKOUTDCM5(), 
                         .CLKOUT0(CLKOUT0_OUT), 
                         .CLKOUT1(CLKOUT1_OUT), 
                         .CLKOUT2(CLKOUT2_OUT), 
                         .CLKOUT3(CLKOUT3_OUT), 
                         .CLKOUT4(CLKOUT4_OUT), 
                         .CLKOUT5(CLKOUT5_OUT), 
                         .DO(), 
                         .DRDY(), 
                         .LOCKED(LOCKED_OUT));


// DCM_ADV #( .CLK_FEEDBACK("1X"), .CLKDV_DIVIDE(2.0), .CLKFX_DIVIDE(1), 
//         .CLKFX_MULTIPLY(4), .CLKIN_DIVIDE_BY_2("FALSE"), 
//         .CLKIN_PERIOD(25.000), .CLKOUT_PHASE_SHIFT("NONE"), 
//         .DCM_AUTOCALIBRATION("TRUE"), .DCM_PERFORMANCE_MODE("MAX_SPEED"), 
//         .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), .DFS_FREQUENCY_MODE("LOW"), 
//         .DLL_FREQUENCY_MODE("LOW"), .DUTY_CYCLE_CORRECTION("TRUE"), 
//         .FACTORY_JF(16'hF0F0), .PHASE_SHIFT(0), .STARTUP_WAIT("FALSE"), 
//         .SIM_DEVICE("KINTEX7") ) DCM_ADV_INST (.CLKFB(CLKFB_IN), 
//                         .CLKIN(CLKIN_IBUFG), 
//                         .DADDR(GND_BUS_7[6:0]), 
//                         .DCLK(GND_BIT), 
//                         .DEN(GND_BIT), 
//                         .DI(GND_BUS_16[15:0]), 
//                         .DWE(GND_BIT), 
//                         .PSCLK(GND_BIT), 
//                         .PSEN(GND_BIT), 
//                         .PSINCDEC(GND_BIT), 
//                         .RST(RST_IN), 
//                         .CLKDV(), 
//                         .CLKFX(), 
//                         .CLKFX180(), 
//                         .CLK0(CLK0_BUF), 
//                         .CLK2X(), 
//                         .CLK2X180(), 
//                         .CLK90(), 
//                         .CLK180(), 
//                         .CLK270(), 
//                         .DO(), 
//                         .DRDY(), 
//                         .LOCKED(DCM_LOCKED_INV_IN), 
//                         .PSDONE());

endmodule
   
//================================================ MK_CLKRST
module MK_CLKRST (clkin, rstnin, clk, rst);
   //synthesis attribute keep_hierarchy of MK_CLKRST is no;
   
   //------------------------------------------------
   input  clkin, rstnin;
   output clk, rst;
   
   //------------------------------------------------
   wire   refclk;
//   wire   clk_dcm, locked;

   //------------------------------------------------ clock
  // IBUFG u10 (.I(clkin), .O(refclk)); 

/*
   DCM_BASE u11 (.CLKIN(refclk), .CLKFB(clk), .RST(~rstnin),
                 .CLK0(clk_dcm),     .CLKDV(),
                 .CLK90(), .CLK180(), .CLK270(),
                 .CLK2X(), .CLK2X180(), .CLKFX(), .CLKFX180(),
                 .LOCKED(locked));
   BUFG  u12 (.I(clk_dcm),   .O(clk));
*/

  // BUFG  u12 (.I(refclk),   .O(clk));
  assign clk= clkin;

   //------------------------------------------------ reset
   MK_RST u20 (.locked(rstnin), .clk(clk), .rst(rst));
endmodule // MK_CLKRST



//================================================ MK_RST
module MK_RST (locked, clk, rst);
   //synthesis attribute keep_hierarchy of MK_RST is no;
   
   //------------------------------------------------
   input  locked, clk;
   output rst;

   //------------------------------------------------
   reg [15:0] cnt;
   
   //------------------------------------------------
   always @(posedge clk or negedge locked) 
     if (~locked)    cnt <= 16'h0;
     else if (~&cnt) cnt <= cnt + 16'h1;

   assign rst = ~&cnt;
endmodule // MK_RST





module clkswitch(clk0, clk1, SELECT, clko);
	input clk0;
	input clk1;
	input SELECT;
	output clko;
	
wire Q10, Q11, Q21, Q20;
wire CE=1'b1;
wire R=1'b0;
wire SELECT1 =  SELECT & ~Q21;
wire SELECT2 = ~SELECT & ~Q11;
wire clko1, clko2, clkoT;

assign clko1 = clk0& Q11;
assign clko2 = clk1& Q21;
assign clkoT = clko1 | clko2;

BUFG  u12 (.I(clkoT),   .O(clko));

FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst0 (
.Q(Q10), // 1-bit Data output
.C(clk0), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(SELECT1) // 1-bit Data input
);

FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst1 (
.Q(Q11), // 1-bit Data output
.C(~clk0), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(Q10) // 1-bit Data input
);

FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst2 (
.Q(Q20), // 1-bit Data output
.C(clk1), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(SELECT2) // 1-bit Data input
);

FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst3 (
.Q(Q21), // 1-bit Data output
.C(~clk1), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(Q20) // 1-bit Data input
);	
	


endmodule



module clkswitch1(clk0, clk1, SELECT, clko);
	input clk0;
	input clk1;
	input SELECT;
	output clko;
	
wire Q10, Q11, Q21, Q20, Q1, Q2;
wire CE=1'b1;
wire R=1'b0;
wire SELECT1 =  SELECT & ~Q21;
wire SELECT2 = ~SELECT & ~Q11;
wire clko1, clko2, clkoT;

assign clko1 = clk0& Q11;
assign clko2 = clk1& Q21;
assign clkoT = clko1 | clko2;

BUFG  u12 (.I(clkoT),   .O(clko));

FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst0 (
.Q(Q10), // 1-bit Data output
.C(clk0), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(SELECT1) // 1-bit Data input
);

FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst01 (
.Q(Q1), // 1-bit Data output
.C(clk0), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(Q10) // 1-bit Data input
);

FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst1 (
.Q(Q11), // 1-bit Data output
.C(~clk0), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(Q1) // 1-bit Data input
);



FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst2 (
.Q(Q20), // 1-bit Data output
.C(clk1), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(SELECT2) // 1-bit Data input
);

FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst21 (
.Q(Q2), // 1-bit Data output
.C(clk1), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(Q20) // 1-bit Data input
);	

FDRE #(
.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
) FDRE_inst3 (
.Q(Q21), // 1-bit Data output
.C(~clk1), // 1-bit Clock input
.CE(CE), // 1-bit Clock enable input
.R(R), // 1-bit Synchronous reset input
.D(Q2) // 1-bit Data input
);	
	


endmodule
