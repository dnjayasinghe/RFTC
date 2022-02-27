///////////////////////////////////////////////////////////////////////////////
//    
//    Company:          Xilinx
//    Engineer:         Jim Tatsukawa, Karl Kurbjun and Carl Ribbing
//    Date:             10/22/2014
//    Design Name:      MMCME2 DRP
//    Module Name:      mmcme2_drp.v
//    Version:          1.30
//    Target Devices:   7 Series
//    Tool versions:    2014.3
//    Description:      This calls the DRP register calculation functions and
//                      provides a state machine to perform MMCM reconfiguration
//                      based on the calulated values stored in a initialized 
//                      ROM.
//
//    Revisions:        1/13/11 Updated ROM[18,41] LOCKED bitmask to 16'HFC00
//                      5/30/13 Adding Fractional support for CLKFBOUT_MULT_F, CLKOUT0_DIVIDE_F
//                      4/30/14 For fractional multiply changed order to enable fractional
//                              before the multiply is applied to prevent false VCO DRCs
//                              (e.g. DADDR 7'h15 must be set before updating 7'h14)
//                     10/24/14 Parameters have been added to clarify Reg1/Reg2/Shared registers
//                     6/8/15   WAIT_LOCK update
//                     5/2/16   Reordering FRAC_EN bits DADDR(7'h09, 7'h15)
//                              registers before frac settings (7'h08, 7'h14)
//                              
//
// 
//    Disclaimer:  XILINX IS PROVIDING THIS DESIGN, CODE, OR
//                 INFORMATION "AS IS" SOLELY FOR USE IN DEVELOPING
//                 PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
//                 PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
//                 ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
//                 APPLICATION OR STANDARD, XILINX IS MAKING NO
//                 REPRESENTATION THAT THIS IMPLEMENTATION IS FREE
//                 FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE
//                 RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY
//                 REQUIRE FOR YOUR IMPLEMENTATION.  XILINX
//                 EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH
//                 RESPECT TO THE ADEQUACY OF THE IMPLEMENTATION,
//                 INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//                 REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
//                 FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES
//                 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//                 PURPOSE.
// 
//                 (c) Copyright 2009-2010 Xilinx, Inc.
//                 All rights reserved.
// 
///////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module mmcme2_drp
   #(

parameter	DataPath=	15,
//***********************************************************************
 // State0   Parameters - These are for the second reconfiguration state.
 //***********************************************************************
 parameter	S0_CLKFBOUT_MULT	=	12,
 parameter	S0_CLKFBOUT_PHASE	=	0,
 parameter	S0_CLKFBOUT_FRAC	=	000,
 parameter	S0_CLKFBOUT_FRAC_EN	=	1,
 parameter	S0_BANDWIDTH		=	"OPTIMIZED",
 parameter	S0_DIVCLK_DIVIDE	=	1,
 parameter	S0_CLKOUT0_DIVIDE	=	24,
 parameter	S0_CLKOUT0_PHASE	=	0,
 parameter	S0_CLKOUT0_DUTY		=	50000,
 parameter	S0_CLKOUT0_FRAC		=	000,
 parameter	S0_CLKOUT0_FRAC_EN	=	0,

 parameter	S0_CLKOUT1_DIVIDE 	=	20,
 parameter	S0_CLKOUT1_PHASE	=	0,
 parameter	S0_CLKOUT1_DUTY	=	50000,

 parameter	S0_CLKOUT2_DIVIDE 	=	21,
 parameter	S0_CLKOUT2_PHASE	=	0,
 parameter	S0_CLKOUT2_DUTY	=	50000,
 //***********************************************************************
 // State1   Parameters - These are for the second reconfiguration state.
 //***********************************************************************
 parameter	S1_CLKFBOUT_MULT	=	15,
 parameter	S1_CLKFBOUT_PHASE	=	0,
 parameter	S1_CLKFBOUT_FRAC	=	910,
 parameter	S1_CLKFBOUT_FRAC_EN	=	1,
 parameter	S1_BANDWIDTH		=	"OPTIMIZED",
 parameter	S1_DIVCLK_DIVIDE	=	1,
 parameter	S1_CLKOUT0_DIVIDE	=	24,
 parameter	S1_CLKOUT0_PHASE	=	0,
 parameter	S1_CLKOUT0_DUTY		=	50000,
 parameter	S1_CLKOUT0_FRAC		=	000,
 parameter	S1_CLKOUT0_FRAC_EN	=	0,

 parameter	S1_CLKOUT1_DIVIDE 	=	32,
 parameter	S1_CLKOUT1_PHASE	=	0,
 parameter	S1_CLKOUT1_DUTY	=	50000,

 parameter	S1_CLKOUT2_DIVIDE 	=	21,
 parameter	S1_CLKOUT2_PHASE	=	0,
 parameter	S1_CLKOUT2_DUTY	=	50000,
 //***********************************************************************
 // State2   Parameters - These are for the second reconfiguration state.
 //***********************************************************************
 parameter	S2_CLKFBOUT_MULT	=	19,
 parameter	S2_CLKFBOUT_PHASE	=	0,
 parameter	S2_CLKFBOUT_FRAC	=	820,
 parameter	S2_CLKFBOUT_FRAC_EN	=	1,
 parameter	S2_BANDWIDTH		=	"OPTIMIZED",
 parameter	S2_DIVCLK_DIVIDE	=	1,
 parameter	S2_CLKOUT0_DIVIDE	=	24,
 parameter	S2_CLKOUT0_PHASE	=	0,
 parameter	S2_CLKOUT0_DUTY		=	50000,
 parameter	S2_CLKOUT0_FRAC		=	000,
 parameter	S2_CLKOUT0_FRAC_EN	=	0,

 parameter	S2_CLKOUT1_DIVIDE 	=	44,
 parameter	S2_CLKOUT1_PHASE	=	0,
 parameter	S2_CLKOUT1_DUTY	=	50000,

 parameter	S2_CLKOUT2_DIVIDE 	=	25,
 parameter	S2_CLKOUT2_PHASE	=	0,
 parameter	S2_CLKOUT2_DUTY	=	50000,
 //***********************************************************************
 // State3   Parameters - These are for the second reconfiguration state.
 //***********************************************************************
 parameter	S3_CLKFBOUT_MULT	=	23,
 parameter	S3_CLKFBOUT_PHASE	=	0,
 parameter	S3_CLKFBOUT_FRAC	=	730,
 parameter	S3_CLKFBOUT_FRAC_EN	=	1,
 parameter	S3_BANDWIDTH		=	"OPTIMIZED",
 parameter	S3_DIVCLK_DIVIDE	=	1,
 parameter	S3_CLKOUT0_DIVIDE	=	24,
 parameter	S3_CLKOUT0_PHASE	=	0,
 parameter	S3_CLKOUT0_DUTY		=	50000,
 parameter	S3_CLKOUT0_FRAC		=	000,
 parameter	S3_CLKOUT0_FRAC_EN	=	0,

 parameter	S3_CLKOUT1_DIVIDE 	=	26,
 parameter	S3_CLKOUT1_PHASE	=	0,
 parameter	S3_CLKOUT1_DUTY	=	50000,

 parameter	S3_CLKOUT2_DIVIDE 	=	21,
 parameter	S3_CLKOUT2_PHASE	=	0,
 parameter	S3_CLKOUT2_DUTY	=	50000,
 //***********************************************************************
 // State4   Parameters - These are for the second reconfiguration state.
 //***********************************************************************
 parameter	S4_CLKFBOUT_MULT	=	27,
 parameter	S4_CLKFBOUT_PHASE	=	0,
 parameter	S4_CLKFBOUT_FRAC	=	640,
 parameter	S4_CLKFBOUT_FRAC_EN	=	1,
 parameter	S4_BANDWIDTH		=	"OPTIMIZED",
 parameter	S4_DIVCLK_DIVIDE	=	1,
 parameter	S4_CLKOUT0_DIVIDE	=	24,
 parameter	S4_CLKOUT0_PHASE	=	0,
 parameter	S4_CLKOUT0_DUTY		=	50000,
 parameter	S4_CLKOUT0_FRAC		=	000,
 parameter	S4_CLKOUT0_FRAC_EN	=	0,

 parameter	S4_CLKOUT1_DIVIDE 	=	38,
 parameter	S4_CLKOUT1_PHASE	=	0,
 parameter	S4_CLKOUT1_DUTY	=	50000,

 parameter	S4_CLKOUT2_DIVIDE 	=	31,
 parameter	S4_CLKOUT2_PHASE	=	0,
 parameter	S4_CLKOUT2_DUTY	=	50000,
 //***********************************************************************
 // State5   Parameters - These are for the second reconfiguration state.
 //***********************************************************************
 parameter	S5_CLKFBOUT_MULT	=	31,
 parameter	S5_CLKFBOUT_PHASE	=	0,
 parameter	S5_CLKFBOUT_FRAC	=	550,
 parameter	S5_CLKFBOUT_FRAC_EN	=	1,
 parameter	S5_BANDWIDTH		=	"OPTIMIZED",
 parameter	S5_DIVCLK_DIVIDE	=	1,
 parameter	S5_CLKOUT0_DIVIDE	=	24,
 parameter	S5_CLKOUT0_PHASE	=	0,
 parameter	S5_CLKOUT0_DUTY		=	50000,
 parameter	S5_CLKOUT0_FRAC		=	000,
 parameter	S5_CLKOUT0_FRAC_EN	=	0,

 parameter	S5_CLKOUT1_DIVIDE 	=	20,
 parameter	S5_CLKOUT1_PHASE	=	0,
 parameter	S5_CLKOUT1_DUTY	=	50000,

 parameter	S5_CLKOUT2_DIVIDE 	=	21,
 parameter	S5_CLKOUT2_PHASE	=	0,
 parameter	S5_CLKOUT2_DUTY	=	50000,
 //***********************************************************************
 // State6   Parameters - These are for the second reconfiguration state.
 //***********************************************************************
 parameter	S6_CLKFBOUT_MULT	=	35,
 parameter	S6_CLKFBOUT_PHASE	=	0,
 parameter	S6_CLKFBOUT_FRAC	=	460,
 parameter	S6_CLKFBOUT_FRAC_EN	=	1,
 parameter	S6_BANDWIDTH		=	"OPTIMIZED",
 parameter	S6_DIVCLK_DIVIDE	=	1,
 parameter	S6_CLKOUT0_DIVIDE	=	24,
 parameter	S6_CLKOUT0_PHASE	=	0,
 parameter	S6_CLKOUT0_DUTY		=	50000,
 parameter	S6_CLKOUT0_FRAC		=	000,
 parameter	S6_CLKOUT0_FRAC_EN	=	0,

 parameter	S6_CLKOUT1_DIVIDE 	=	32,
 parameter	S6_CLKOUT1_PHASE	=	0,
 parameter	S6_CLKOUT1_DUTY	=	50000,

 parameter	S6_CLKOUT2_DIVIDE 	=	33,
 parameter	S6_CLKOUT2_PHASE	=	0,
 parameter	S6_CLKOUT2_DUTY	=	50000,
 //***********************************************************************
 // State7   Parameters - These are for the second reconfiguration state.
 //***********************************************************************
 parameter	S7_CLKFBOUT_MULT	=	39,
 parameter	S7_CLKFBOUT_PHASE	=	0,
 parameter	S7_CLKFBOUT_FRAC	=	370,
 parameter	S7_CLKFBOUT_FRAC_EN	=	1,
 parameter	S7_BANDWIDTH		=	"OPTIMIZED",
 parameter	S7_DIVCLK_DIVIDE	=	1,
 parameter	S7_CLKOUT0_DIVIDE	=	24,
 parameter	S7_CLKOUT0_PHASE	=	0,
 parameter	S7_CLKOUT0_DUTY		=	50000,
 parameter	S7_CLKOUT0_FRAC		=	000,
 parameter	S7_CLKOUT0_FRAC_EN	=	0,

 parameter	S7_CLKOUT1_DIVIDE 	=	44,
 parameter	S7_CLKOUT1_PHASE	=	0,
 parameter	S7_CLKOUT1_DUTY	=	50000,

 parameter	S7_CLKOUT2_DIVIDE 	=	43,
 parameter	S7_CLKOUT2_PHASE	=	0,
 parameter	S7_CLKOUT2_DUTY	=	50000
 
	) (
      // These signals are controlled by user logic interface and are covered
      // in more detail within the XAPP.
      input[9:0]             SADDR,
      input             SEN,
      input             SCLK,
      input             RST,
      output reg        SRDY,
      
      // These signals are to be connected to the MMCM_ADV by port name.
      // Their use matches the MMCM port description in the Device User Guide.
      input      [15:0] DO,
      input             DRDY,
      input             LOCKED,
      output reg        DWE,
      output reg        DEN,
      output reg [6:0]  DADDR,
      output reg [15:0] DI,
      output            DCLK,
      output reg        RST_MMCM
   );

   // 100 ps delay for behavioral simulations
   localparam  TCQ = 100;
   
   // Make sure the memory is implemented as distributed
   (* rom_style = "block" *)
   reg [38:0]  rom [127:0];  // 39 bit word 64 words deep
   reg [DataPath:0]   rom_addr;
   reg [38:0]  rom_do;
   
   reg         next_srdy;

   reg [DataPath:0]   next_rom_addr;
   reg [6:0]   next_daddr;
   reg         next_dwe;
   reg         next_den;
   reg         next_rst_mmcm;
   reg [15:0]  next_di;
   
   // Integer used to initialize remainder of unused ROM
   integer     ii;
   
   // Pass SCLK to DCLK for the MMCM
   assign DCLK = SCLK;

   // Include the MMCM reconfiguration functions.  This contains the constant
   // functions that are used in the calculations below.  This file is 
   // required.
   `include "mmcm_drp_func.h"
//**************************************************************************
// State 0 Calculations
//**************************************************************************

localparam[37:0] S0_CLKFBOUT =
  mmcm_count_calc(S0_CLKFBOUT_MULT, S0_CLKFBOUT_PHASE, 50000);

localparam[37:0] S0_CLKFBOUT_FRAC_CALC =
  mmcm_frac_count_calc(S0_CLKFBOUT_MULT, S0_CLKFBOUT_PHASE, 50000, S0_CLKFBOUT_FRAC);

localparam[9:0] S0_DIGITAL_FILT =
  mmcm_filter_lookup(S0_CLKFBOUT_MULT, S0_BANDWIDTH);

localparam[39:0] S0_LOCK =
  mmcm_lock_lookup(S0_CLKFBOUT_MULT);

localparam[37:0] S0_DIVCLK =
  mmcm_count_calc(S0_DIVCLK_DIVIDE, 0, 50000);

localparam[37:0] S0_CLKOUT0 =
  mmcm_count_calc(S0_CLKOUT0_DIVIDE, S0_CLKOUT0_PHASE, S0_CLKOUT0_DUTY);

localparam [15:0] S0_CLKOUT0_REG1        = S0_CLKOUT0[15:0];
localparam [15:0] S0_CLKOUT0_REG2        = S0_CLKOUT0[31:16];

localparam [37:0] S0_CLKOUT0_FRAC_CALC        =
mmcm_frac_count_calc(S0_CLKOUT0_DIVIDE, S0_CLKOUT0_PHASE, 50000, S0_CLKOUT0_FRAC);
localparam [15:0] S0_CLKOUT0_FRAC_REG1        = S0_CLKOUT0_FRAC_CALC[15:0];
localparam [15:0] S0_CLKOUT0_FRAC_REG2        = S0_CLKOUT0_FRAC_CALC[31:16];
localparam [5:0] S0_CLKOUT0_FRAC_REGSHARED        = S0_CLKOUT0_FRAC_CALC[37:32];

localparam[37:0] S0_CLKOUT1 =
mmcm_count_calc(S0_CLKOUT1_DIVIDE, S0_CLKOUT1_PHASE, S0_CLKOUT1_DUTY); 

localparam[37:0] S0_CLKOUT2 =
mmcm_count_calc(S0_CLKOUT2_DIVIDE, S0_CLKOUT2_PHASE, S0_CLKOUT2_DUTY); 

//**************************************************************************
// State 1 Calculations
//**************************************************************************

localparam[37:0] S1_CLKFBOUT =
  mmcm_count_calc(S1_CLKFBOUT_MULT, S1_CLKFBOUT_PHASE, 50000);

localparam[37:0] S1_CLKFBOUT_FRAC_CALC =
  mmcm_frac_count_calc(S1_CLKFBOUT_MULT, S1_CLKFBOUT_PHASE, 50000, S1_CLKFBOUT_FRAC);

localparam[9:0] S1_DIGITAL_FILT =
  mmcm_filter_lookup(S1_CLKFBOUT_MULT, S1_BANDWIDTH);

localparam[39:0] S1_LOCK =
  mmcm_lock_lookup(S1_CLKFBOUT_MULT);

localparam[37:0] S1_DIVCLK =
  mmcm_count_calc(S1_DIVCLK_DIVIDE, 0, 50000);

localparam[37:0] S1_CLKOUT0 =
  mmcm_count_calc(S1_CLKOUT0_DIVIDE, S1_CLKOUT0_PHASE, S1_CLKOUT0_DUTY);

localparam [15:0] S1_CLKOUT0_REG1        = S1_CLKOUT0[15:0];
localparam [15:0] S1_CLKOUT0_REG2        = S1_CLKOUT0[31:16];

localparam [37:0] S1_CLKOUT0_FRAC_CALC        =
mmcm_frac_count_calc(S1_CLKOUT0_DIVIDE, S1_CLKOUT0_PHASE, 50000, S1_CLKOUT0_FRAC);
localparam [15:0] S1_CLKOUT0_FRAC_REG1        = S1_CLKOUT0_FRAC_CALC[15:0];
localparam [15:0] S1_CLKOUT0_FRAC_REG2        = S1_CLKOUT0_FRAC_CALC[31:16];
localparam [5:0] S1_CLKOUT0_FRAC_REGSHARED        = S1_CLKOUT0_FRAC_CALC[37:32];

localparam[37:0] S1_CLKOUT1 =
mmcm_count_calc(S1_CLKOUT1_DIVIDE, S1_CLKOUT1_PHASE, S1_CLKOUT1_DUTY); 

localparam[37:0] S1_CLKOUT2 =
mmcm_count_calc(S1_CLKOUT2_DIVIDE, S1_CLKOUT2_PHASE, S1_CLKOUT2_DUTY); 

//**************************************************************************
// State 2 Calculations
//**************************************************************************

localparam[37:0] S2_CLKFBOUT =
  mmcm_count_calc(S2_CLKFBOUT_MULT, S2_CLKFBOUT_PHASE, 50000);

localparam[37:0] S2_CLKFBOUT_FRAC_CALC =
  mmcm_frac_count_calc(S2_CLKFBOUT_MULT, S2_CLKFBOUT_PHASE, 50000, S2_CLKFBOUT_FRAC);

localparam[9:0] S2_DIGITAL_FILT =
  mmcm_filter_lookup(S2_CLKFBOUT_MULT, S2_BANDWIDTH);

localparam[39:0] S2_LOCK =
  mmcm_lock_lookup(S2_CLKFBOUT_MULT);

localparam[37:0] S2_DIVCLK =
  mmcm_count_calc(S2_DIVCLK_DIVIDE, 0, 50000);

localparam[37:0] S2_CLKOUT0 =
  mmcm_count_calc(S2_CLKOUT0_DIVIDE, S2_CLKOUT0_PHASE, S2_CLKOUT0_DUTY);

localparam [15:0] S2_CLKOUT0_REG1        = S2_CLKOUT0[15:0];
localparam [15:0] S2_CLKOUT0_REG2        = S2_CLKOUT0[31:16];

localparam [37:0] S2_CLKOUT0_FRAC_CALC        =
mmcm_frac_count_calc(S2_CLKOUT0_DIVIDE, S2_CLKOUT0_PHASE, 50000, S2_CLKOUT0_FRAC);
localparam [15:0] S2_CLKOUT0_FRAC_REG1        = S2_CLKOUT0_FRAC_CALC[15:0];
localparam [15:0] S2_CLKOUT0_FRAC_REG2        = S2_CLKOUT0_FRAC_CALC[31:16];
localparam [5:0] S2_CLKOUT0_FRAC_REGSHARED        = S2_CLKOUT0_FRAC_CALC[37:32];

localparam[37:0] S2_CLKOUT1 =
mmcm_count_calc(S2_CLKOUT1_DIVIDE, S2_CLKOUT1_PHASE, S2_CLKOUT1_DUTY); 

localparam[37:0] S2_CLKOUT2 =
mmcm_count_calc(S2_CLKOUT2_DIVIDE, S2_CLKOUT2_PHASE, S2_CLKOUT2_DUTY); 

//**************************************************************************
// State 3 Calculations
//**************************************************************************

localparam[37:0] S3_CLKFBOUT =
  mmcm_count_calc(S3_CLKFBOUT_MULT, S3_CLKFBOUT_PHASE, 50000);

localparam[37:0] S3_CLKFBOUT_FRAC_CALC =
  mmcm_frac_count_calc(S3_CLKFBOUT_MULT, S3_CLKFBOUT_PHASE, 50000, S3_CLKFBOUT_FRAC);

localparam[9:0] S3_DIGITAL_FILT =
  mmcm_filter_lookup(S3_CLKFBOUT_MULT, S3_BANDWIDTH);

localparam[39:0] S3_LOCK =
  mmcm_lock_lookup(S3_CLKFBOUT_MULT);

localparam[37:0] S3_DIVCLK =
  mmcm_count_calc(S3_DIVCLK_DIVIDE, 0, 50000);

localparam[37:0] S3_CLKOUT0 =
  mmcm_count_calc(S3_CLKOUT0_DIVIDE, S3_CLKOUT0_PHASE, S3_CLKOUT0_DUTY);

localparam [15:0] S3_CLKOUT0_REG1        = S3_CLKOUT0[15:0];
localparam [15:0] S3_CLKOUT0_REG2        = S3_CLKOUT0[31:16];

localparam [37:0] S3_CLKOUT0_FRAC_CALC        =
mmcm_frac_count_calc(S3_CLKOUT0_DIVIDE, S3_CLKOUT0_PHASE, 50000, S3_CLKOUT0_FRAC);
localparam [15:0] S3_CLKOUT0_FRAC_REG1        = S3_CLKOUT0_FRAC_CALC[15:0];
localparam [15:0] S3_CLKOUT0_FRAC_REG2        = S3_CLKOUT0_FRAC_CALC[31:16];
localparam [5:0] S3_CLKOUT0_FRAC_REGSHARED        = S3_CLKOUT0_FRAC_CALC[37:32];

localparam[37:0] S3_CLKOUT1 =
mmcm_count_calc(S3_CLKOUT1_DIVIDE, S3_CLKOUT1_PHASE, S3_CLKOUT1_DUTY); 

localparam[37:0] S3_CLKOUT2 =
mmcm_count_calc(S3_CLKOUT2_DIVIDE, S3_CLKOUT2_PHASE, S3_CLKOUT2_DUTY); 

//**************************************************************************
// State 4 Calculations
//**************************************************************************

localparam[37:0] S4_CLKFBOUT =
  mmcm_count_calc(S4_CLKFBOUT_MULT, S4_CLKFBOUT_PHASE, 50000);

localparam[37:0] S4_CLKFBOUT_FRAC_CALC =
  mmcm_frac_count_calc(S4_CLKFBOUT_MULT, S4_CLKFBOUT_PHASE, 50000, S4_CLKFBOUT_FRAC);

localparam[9:0] S4_DIGITAL_FILT =
  mmcm_filter_lookup(S4_CLKFBOUT_MULT, S4_BANDWIDTH);

localparam[39:0] S4_LOCK =
  mmcm_lock_lookup(S4_CLKFBOUT_MULT);

localparam[37:0] S4_DIVCLK =
  mmcm_count_calc(S4_DIVCLK_DIVIDE, 0, 50000);

localparam[37:0] S4_CLKOUT0 =
  mmcm_count_calc(S4_CLKOUT0_DIVIDE, S4_CLKOUT0_PHASE, S4_CLKOUT0_DUTY);

localparam [15:0] S4_CLKOUT0_REG1        = S4_CLKOUT0[15:0];
localparam [15:0] S4_CLKOUT0_REG2        = S4_CLKOUT0[31:16];

localparam [37:0] S4_CLKOUT0_FRAC_CALC        =
mmcm_frac_count_calc(S4_CLKOUT0_DIVIDE, S4_CLKOUT0_PHASE, 50000, S4_CLKOUT0_FRAC);
localparam [15:0] S4_CLKOUT0_FRAC_REG1        = S4_CLKOUT0_FRAC_CALC[15:0];
localparam [15:0] S4_CLKOUT0_FRAC_REG2        = S4_CLKOUT0_FRAC_CALC[31:16];
localparam [5:0] S4_CLKOUT0_FRAC_REGSHARED        = S4_CLKOUT0_FRAC_CALC[37:32];

localparam[37:0] S4_CLKOUT1 =
mmcm_count_calc(S4_CLKOUT1_DIVIDE, S4_CLKOUT1_PHASE, S4_CLKOUT1_DUTY); 

localparam[37:0] S4_CLKOUT2 =
mmcm_count_calc(S4_CLKOUT2_DIVIDE, S4_CLKOUT2_PHASE, S4_CLKOUT2_DUTY); 

//**************************************************************************
// State 5 Calculations
//**************************************************************************

localparam[37:0] S5_CLKFBOUT =
  mmcm_count_calc(S5_CLKFBOUT_MULT, S5_CLKFBOUT_PHASE, 50000);

localparam[37:0] S5_CLKFBOUT_FRAC_CALC =
  mmcm_frac_count_calc(S5_CLKFBOUT_MULT, S5_CLKFBOUT_PHASE, 50000, S5_CLKFBOUT_FRAC);

localparam[9:0] S5_DIGITAL_FILT =
  mmcm_filter_lookup(S5_CLKFBOUT_MULT, S5_BANDWIDTH);

localparam[39:0] S5_LOCK =
  mmcm_lock_lookup(S5_CLKFBOUT_MULT);

localparam[37:0] S5_DIVCLK =
  mmcm_count_calc(S5_DIVCLK_DIVIDE, 0, 50000);

localparam[37:0] S5_CLKOUT0 =
  mmcm_count_calc(S5_CLKOUT0_DIVIDE, S5_CLKOUT0_PHASE, S5_CLKOUT0_DUTY);

localparam [15:0] S5_CLKOUT0_REG1        = S5_CLKOUT0[15:0];
localparam [15:0] S5_CLKOUT0_REG2        = S5_CLKOUT0[31:16];

localparam [37:0] S5_CLKOUT0_FRAC_CALC        =
mmcm_frac_count_calc(S5_CLKOUT0_DIVIDE, S5_CLKOUT0_PHASE, 50000, S5_CLKOUT0_FRAC);
localparam [15:0] S5_CLKOUT0_FRAC_REG1        = S5_CLKOUT0_FRAC_CALC[15:0];
localparam [15:0] S5_CLKOUT0_FRAC_REG2        = S5_CLKOUT0_FRAC_CALC[31:16];
localparam [5:0] S5_CLKOUT0_FRAC_REGSHARED        = S5_CLKOUT0_FRAC_CALC[37:32];

localparam[37:0] S5_CLKOUT1 =
mmcm_count_calc(S5_CLKOUT1_DIVIDE, S5_CLKOUT1_PHASE, S5_CLKOUT1_DUTY); 

localparam[37:0] S5_CLKOUT2 =
mmcm_count_calc(S5_CLKOUT2_DIVIDE, S5_CLKOUT2_PHASE, S5_CLKOUT2_DUTY); 

//**************************************************************************
// State 6 Calculations
//**************************************************************************

localparam[37:0] S6_CLKFBOUT =
  mmcm_count_calc(S6_CLKFBOUT_MULT, S6_CLKFBOUT_PHASE, 50000);

localparam[37:0] S6_CLKFBOUT_FRAC_CALC =
  mmcm_frac_count_calc(S6_CLKFBOUT_MULT, S6_CLKFBOUT_PHASE, 50000, S6_CLKFBOUT_FRAC);

localparam[9:0] S6_DIGITAL_FILT =
  mmcm_filter_lookup(S6_CLKFBOUT_MULT, S6_BANDWIDTH);

localparam[39:0] S6_LOCK =
  mmcm_lock_lookup(S6_CLKFBOUT_MULT);

localparam[37:0] S6_DIVCLK =
  mmcm_count_calc(S6_DIVCLK_DIVIDE, 0, 50000);

localparam[37:0] S6_CLKOUT0 =
  mmcm_count_calc(S6_CLKOUT0_DIVIDE, S6_CLKOUT0_PHASE, S6_CLKOUT0_DUTY);

localparam [15:0] S6_CLKOUT0_REG1        = S6_CLKOUT0[15:0];
localparam [15:0] S6_CLKOUT0_REG2        = S6_CLKOUT0[31:16];

localparam [37:0] S6_CLKOUT0_FRAC_CALC        =
mmcm_frac_count_calc(S6_CLKOUT0_DIVIDE, S6_CLKOUT0_PHASE, 50000, S6_CLKOUT0_FRAC);
localparam [15:0] S6_CLKOUT0_FRAC_REG1        = S6_CLKOUT0_FRAC_CALC[15:0];
localparam [15:0] S6_CLKOUT0_FRAC_REG2        = S6_CLKOUT0_FRAC_CALC[31:16];
localparam [5:0] S6_CLKOUT0_FRAC_REGSHARED        = S6_CLKOUT0_FRAC_CALC[37:32];

localparam[37:0] S6_CLKOUT1 =
mmcm_count_calc(S6_CLKOUT1_DIVIDE, S6_CLKOUT1_PHASE, S6_CLKOUT1_DUTY); 

localparam[37:0] S6_CLKOUT2 =
mmcm_count_calc(S6_CLKOUT2_DIVIDE, S6_CLKOUT2_PHASE, S6_CLKOUT2_DUTY); 

//**************************************************************************
// State 7 Calculations
//**************************************************************************

localparam[37:0] S7_CLKFBOUT =
  mmcm_count_calc(S7_CLKFBOUT_MULT, S7_CLKFBOUT_PHASE, 50000);

localparam[37:0] S7_CLKFBOUT_FRAC_CALC =
  mmcm_frac_count_calc(S7_CLKFBOUT_MULT, S7_CLKFBOUT_PHASE, 50000, S7_CLKFBOUT_FRAC);

localparam[9:0] S7_DIGITAL_FILT =
  mmcm_filter_lookup(S7_CLKFBOUT_MULT, S7_BANDWIDTH);

localparam[39:0] S7_LOCK =
  mmcm_lock_lookup(S7_CLKFBOUT_MULT);

localparam[37:0] S7_DIVCLK =
  mmcm_count_calc(S7_DIVCLK_DIVIDE, 0, 50000);

localparam[37:0] S7_CLKOUT0 =
  mmcm_count_calc(S7_CLKOUT0_DIVIDE, S7_CLKOUT0_PHASE, S7_CLKOUT0_DUTY);

localparam [15:0] S7_CLKOUT0_REG1        = S7_CLKOUT0[15:0];
localparam [15:0] S7_CLKOUT0_REG2        = S7_CLKOUT0[31:16];

localparam [37:0] S7_CLKOUT0_FRAC_CALC        =
mmcm_frac_count_calc(S7_CLKOUT0_DIVIDE, S7_CLKOUT0_PHASE, 50000, S7_CLKOUT0_FRAC);
localparam [15:0] S7_CLKOUT0_FRAC_REG1        = S7_CLKOUT0_FRAC_CALC[15:0];
localparam [15:0] S7_CLKOUT0_FRAC_REG2        = S7_CLKOUT0_FRAC_CALC[31:16];
localparam [5:0] S7_CLKOUT0_FRAC_REGSHARED        = S7_CLKOUT0_FRAC_CALC[37:32];

localparam[37:0] S7_CLKOUT1 =
mmcm_count_calc(S7_CLKOUT1_DIVIDE, S7_CLKOUT1_PHASE, S7_CLKOUT1_DUTY); 

localparam[37:0] S7_CLKOUT2 =
mmcm_count_calc(S7_CLKOUT2_DIVIDE, S7_CLKOUT2_PHASE, S7_CLKOUT2_DUTY); 


  initial begin
  
 // rom entries contain (in order) the address, a bitmask, and a bitset
 //***********************************************************************
// State 0 Initialization
//***********************************************************************

// Store the power bits
rom[0] = { 7'h28, 16'h0000, 16'hFFFF};

// Store CLKOUT0 divide and phase
rom[1] = (S0_CLKOUT0_FRAC_EN == 0) ? { 7'h09, 16'h8000, S0_CLKOUT0[31:16]}: {7'h09, 16'h8000, S0_CLKOUT0_FRAC_CALC[31:16]};
rom[2] = (S0_CLKOUT0_FRAC_EN == 0) ? { 7'h08, 16'h1000, S0_CLKOUT0[15:0]}: { 7'h08, 16'h1000, S0_CLKOUT0_FRAC_CALC[15:0]};

// Store CLKOUT1 divide and phase
rom[3] = { 7'h0A, 16'h1000, S0_CLKOUT1[15:0]};
rom[4] = { 7'h0B, 16'hFC00, S0_CLKOUT1[31:16]};

// Store CLKOUT2 divide and phase
rom[5] = { 7'h0C, 16'h1000, S0_CLKOUT1[15:0]};
rom[6] = { 7'h0D, 16'hFC00, S0_CLKOUT1[31:16]};

// Store the input divider
rom[7] = {7'h16, 16'hC000, {2'h0, S0_DIVCLK[23:22], S0_DIVCLK[11:0]} };

// Store the feedback divide and phase
rom[8] = (S0_CLKFBOUT_FRAC_EN == 0) ? { 7'h14, 16'h1000, S0_CLKFBOUT[15:0]}: { 7'h14, 16'h1000, S0_CLKFBOUT_FRAC_CALC[15:0]};
rom[9] = (S0_CLKFBOUT_FRAC_EN == 0) ? { 7'h15, 16'h8000, S0_CLKFBOUT[31:16]}: { 7'h15, 16'h8000, S0_CLKFBOUT_FRAC_CALC[31:16]};

// Store the lock settings
rom[10] = {7'h18, 16'hFC00, {6'h00, S0_LOCK[29:20]} };
rom[11] = { 7'h19, 16'h8000, { 1'b0 , S0_LOCK[34:30], S0_LOCK[9:0]} };
rom[12] = { 7'h1A, 16'h8000, { 1'b0 , S0_LOCK[39:35], S0_LOCK[19:10]} };

// Store the filter settings
rom[13] = { 7'h4E, 16'h66FF, S0_DIGITAL_FILT[9], 2'h0, S0_DIGITAL_FILT[8:7], 2'h0, S0_DIGITAL_FILT[6], 8'h00 };
rom[14] = { 7'h4F, 16'h666F, S0_DIGITAL_FILT[5], 2'h0, S0_DIGITAL_FILT[4:3], 2'h0, S0_DIGITAL_FILT[2:1], 2'h0, S0_DIGITAL_FILT[0], 4'h0 };


// rom entries contain (in order) the address, a bitmask, and a bitset
 //***********************************************************************
// State 1 Initialization
//***********************************************************************

// Store the power bits
rom[15] = { 7'h28, 16'h0000, 16'hFFFF};

// Store CLKOUT0 divide and phase
rom[16] = (S1_CLKOUT0_FRAC_EN == 0) ? { 7'h09, 16'h8000, S1_CLKOUT0[31:16]}: {7'h09, 16'h8000, S1_CLKOUT0_FRAC_CALC[31:16]};
rom[17] = (S1_CLKOUT0_FRAC_EN == 0) ? { 7'h08, 16'h1000, S1_CLKOUT0[15:0]}: { 7'h08, 16'h1000, S1_CLKOUT0_FRAC_CALC[15:0]};

// Store CLKOUT1 divide and phase
rom[18] = { 7'h0A, 16'h1000, S1_CLKOUT1[15:0]};
rom[19] = { 7'h0B, 16'hFC00, S1_CLKOUT1[31:16]};

// Store CLKOUT2 divide and phase
rom[20] = { 7'h0C, 16'h1000, S1_CLKOUT1[15:0]};
rom[21] = { 7'h0D, 16'hFC00, S1_CLKOUT1[31:16]};

// Store the input divider
rom[22] = {7'h16, 16'hC000, {2'h0, S1_DIVCLK[23:22], S1_DIVCLK[11:0]} };

// Store the feedback divide and phase
rom[23] = (S1_CLKFBOUT_FRAC_EN == 0) ? { 7'h14, 16'h1000, S1_CLKFBOUT[15:0]}: { 7'h14, 16'h1000, S1_CLKFBOUT_FRAC_CALC[15:0]};
rom[24] = (S1_CLKFBOUT_FRAC_EN == 0) ? { 7'h15, 16'h8000, S1_CLKFBOUT[31:16]}: { 7'h15, 16'h8000, S1_CLKFBOUT_FRAC_CALC[31:16]};

// Store the lock settings
rom[25] = {7'h18, 16'hFC00, {6'h00, S1_LOCK[29:20]} };
rom[26] = { 7'h19, 16'h8000, { 1'b0 , S1_LOCK[34:30], S1_LOCK[9:0]} };
rom[27] = { 7'h1A, 16'h8000, { 1'b0 , S1_LOCK[39:35], S1_LOCK[19:10]} };

// Store the filter settings
rom[28] = { 7'h4E, 16'h66FF, S1_DIGITAL_FILT[9], 2'h0, S1_DIGITAL_FILT[8:7], 2'h0, S1_DIGITAL_FILT[6], 8'h00 };
rom[29] = { 7'h4F, 16'h666F, S1_DIGITAL_FILT[5], 2'h0, S1_DIGITAL_FILT[4:3], 2'h0, S1_DIGITAL_FILT[2:1], 2'h0, S1_DIGITAL_FILT[0], 4'h0 };


// rom entries contain (in order) the address, a bitmask, and a bitset
 //***********************************************************************
// State 2 Initialization
//***********************************************************************

// Store the power bits
rom[30] = { 7'h28, 16'h0000, 16'hFFFF};

// Store CLKOUT0 divide and phase
rom[31] = (S2_CLKOUT0_FRAC_EN == 0) ? { 7'h09, 16'h8000, S2_CLKOUT0[31:16]}: {7'h09, 16'h8000, S2_CLKOUT0_FRAC_CALC[31:16]};
rom[32] = (S2_CLKOUT0_FRAC_EN == 0) ? { 7'h08, 16'h1000, S2_CLKOUT0[15:0]}: { 7'h08, 16'h1000, S2_CLKOUT0_FRAC_CALC[15:0]};

// Store CLKOUT1 divide and phase
rom[33] = { 7'h0A, 16'h1000, S2_CLKOUT1[15:0]};
rom[34] = { 7'h0B, 16'hFC00, S2_CLKOUT1[31:16]};

// Store CLKOUT2 divide and phase
rom[35] = { 7'h0C, 16'h1000, S2_CLKOUT1[15:0]};
rom[36] = { 7'h0D, 16'hFC00, S2_CLKOUT1[31:16]};

// Store the input divider
rom[37] = {7'h16, 16'hC000, {2'h0, S2_DIVCLK[23:22], S2_DIVCLK[11:0]} };

// Store the feedback divide and phase
rom[38] = (S2_CLKFBOUT_FRAC_EN == 0) ? { 7'h14, 16'h1000, S2_CLKFBOUT[15:0]}: { 7'h14, 16'h1000, S2_CLKFBOUT_FRAC_CALC[15:0]};
rom[39] = (S2_CLKFBOUT_FRAC_EN == 0) ? { 7'h15, 16'h8000, S2_CLKFBOUT[31:16]}: { 7'h15, 16'h8000, S2_CLKFBOUT_FRAC_CALC[31:16]};

// Store the lock settings
rom[40] = {7'h18, 16'hFC00, {6'h00, S2_LOCK[29:20]} };
rom[41] = { 7'h19, 16'h8000, { 1'b0 , S2_LOCK[34:30], S2_LOCK[9:0]} };
rom[42] = { 7'h1A, 16'h8000, { 1'b0 , S2_LOCK[39:35], S2_LOCK[19:10]} };

// Store the filter settings
rom[43] = { 7'h4E, 16'h66FF, S2_DIGITAL_FILT[9], 2'h0, S2_DIGITAL_FILT[8:7], 2'h0, S2_DIGITAL_FILT[6], 8'h00 };
rom[44] = { 7'h4F, 16'h666F, S2_DIGITAL_FILT[5], 2'h0, S2_DIGITAL_FILT[4:3], 2'h0, S2_DIGITAL_FILT[2:1], 2'h0, S2_DIGITAL_FILT[0], 4'h0 };


// rom entries contain (in order) the address, a bitmask, and a bitset
 //***********************************************************************
// State 3 Initialization
//***********************************************************************

// Store the power bits
rom[45] = { 7'h28, 16'h0000, 16'hFFFF};

// Store CLKOUT0 divide and phase
rom[46] = (S3_CLKOUT0_FRAC_EN == 0) ? { 7'h09, 16'h8000, S3_CLKOUT0[31:16]}: {7'h09, 16'h8000, S3_CLKOUT0_FRAC_CALC[31:16]};
rom[47] = (S3_CLKOUT0_FRAC_EN == 0) ? { 7'h08, 16'h1000, S3_CLKOUT0[15:0]}: { 7'h08, 16'h1000, S3_CLKOUT0_FRAC_CALC[15:0]};

// Store CLKOUT1 divide and phase
rom[48] = { 7'h0A, 16'h1000, S3_CLKOUT1[15:0]};
rom[49] = { 7'h0B, 16'hFC00, S3_CLKOUT1[31:16]};

// Store CLKOUT2 divide and phase
rom[50] = { 7'h0C, 16'h1000, S3_CLKOUT1[15:0]};
rom[51] = { 7'h0D, 16'hFC00, S3_CLKOUT1[31:16]};

// Store the input divider
rom[52] = {7'h16, 16'hC000, {2'h0, S3_DIVCLK[23:22], S3_DIVCLK[11:0]} };

// Store the feedback divide and phase
rom[53] = (S3_CLKFBOUT_FRAC_EN == 0) ? { 7'h14, 16'h1000, S3_CLKFBOUT[15:0]}: { 7'h14, 16'h1000, S3_CLKFBOUT_FRAC_CALC[15:0]};
rom[54] = (S3_CLKFBOUT_FRAC_EN == 0) ? { 7'h15, 16'h8000, S3_CLKFBOUT[31:16]}: { 7'h15, 16'h8000, S3_CLKFBOUT_FRAC_CALC[31:16]};

// Store the lock settings
rom[55] = {7'h18, 16'hFC00, {6'h00, S3_LOCK[29:20]} };
rom[56] = { 7'h19, 16'h8000, { 1'b0 , S3_LOCK[34:30], S3_LOCK[9:0]} };
rom[57] = { 7'h1A, 16'h8000, { 1'b0 , S3_LOCK[39:35], S3_LOCK[19:10]} };

// Store the filter settings
rom[58] = { 7'h4E, 16'h66FF, S3_DIGITAL_FILT[9], 2'h0, S3_DIGITAL_FILT[8:7], 2'h0, S3_DIGITAL_FILT[6], 8'h00 };
rom[59] = { 7'h4F, 16'h666F, S3_DIGITAL_FILT[5], 2'h0, S3_DIGITAL_FILT[4:3], 2'h0, S3_DIGITAL_FILT[2:1], 2'h0, S3_DIGITAL_FILT[0], 4'h0 };


// rom entries contain (in order) the address, a bitmask, and a bitset
 //***********************************************************************
// State 4 Initialization
//***********************************************************************

// Store the power bits
rom[60] = { 7'h28, 16'h0000, 16'hFFFF};

// Store CLKOUT0 divide and phase
rom[61] = (S4_CLKOUT0_FRAC_EN == 0) ? { 7'h09, 16'h8000, S4_CLKOUT0[31:16]}: {7'h09, 16'h8000, S4_CLKOUT0_FRAC_CALC[31:16]};
rom[62] = (S4_CLKOUT0_FRAC_EN == 0) ? { 7'h08, 16'h1000, S4_CLKOUT0[15:0]}: { 7'h08, 16'h1000, S4_CLKOUT0_FRAC_CALC[15:0]};

// Store CLKOUT1 divide and phase
rom[63] = { 7'h0A, 16'h1000, S4_CLKOUT1[15:0]};
rom[64] = { 7'h0B, 16'hFC00, S4_CLKOUT1[31:16]};

// Store CLKOUT2 divide and phase
rom[65] = { 7'h0C, 16'h1000, S4_CLKOUT1[15:0]};
rom[66] = { 7'h0D, 16'hFC00, S4_CLKOUT1[31:16]};

// Store the input divider
rom[67] = {7'h16, 16'hC000, {2'h0, S4_DIVCLK[23:22], S4_DIVCLK[11:0]} };

// Store the feedback divide and phase
rom[68] = (S4_CLKFBOUT_FRAC_EN == 0) ? { 7'h14, 16'h1000, S4_CLKFBOUT[15:0]}: { 7'h14, 16'h1000, S4_CLKFBOUT_FRAC_CALC[15:0]};
rom[69] = (S4_CLKFBOUT_FRAC_EN == 0) ? { 7'h15, 16'h8000, S4_CLKFBOUT[31:16]}: { 7'h15, 16'h8000, S4_CLKFBOUT_FRAC_CALC[31:16]};

// Store the lock settings
rom[70] = {7'h18, 16'hFC00, {6'h00, S4_LOCK[29:20]} };
rom[71] = { 7'h19, 16'h8000, { 1'b0 , S4_LOCK[34:30], S4_LOCK[9:0]} };
rom[72] = { 7'h1A, 16'h8000, { 1'b0 , S4_LOCK[39:35], S4_LOCK[19:10]} };

// Store the filter settings
rom[73] = { 7'h4E, 16'h66FF, S4_DIGITAL_FILT[9], 2'h0, S4_DIGITAL_FILT[8:7], 2'h0, S4_DIGITAL_FILT[6], 8'h00 };
rom[74] = { 7'h4F, 16'h666F, S4_DIGITAL_FILT[5], 2'h0, S4_DIGITAL_FILT[4:3], 2'h0, S4_DIGITAL_FILT[2:1], 2'h0, S4_DIGITAL_FILT[0], 4'h0 };


// rom entries contain (in order) the address, a bitmask, and a bitset
 //***********************************************************************
// State 5 Initialization
//***********************************************************************

// Store the power bits
rom[75] = { 7'h28, 16'h0000, 16'hFFFF};

// Store CLKOUT0 divide and phase
rom[76] = (S5_CLKOUT0_FRAC_EN == 0) ? { 7'h09, 16'h8000, S5_CLKOUT0[31:16]}: {7'h09, 16'h8000, S5_CLKOUT0_FRAC_CALC[31:16]};
rom[77] = (S5_CLKOUT0_FRAC_EN == 0) ? { 7'h08, 16'h1000, S5_CLKOUT0[15:0]}: { 7'h08, 16'h1000, S5_CLKOUT0_FRAC_CALC[15:0]};

// Store CLKOUT1 divide and phase
rom[78] = { 7'h0A, 16'h1000, S5_CLKOUT1[15:0]};
rom[79] = { 7'h0B, 16'hFC00, S5_CLKOUT1[31:16]};

// Store CLKOUT2 divide and phase
rom[80] = { 7'h0C, 16'h1000, S5_CLKOUT1[15:0]};
rom[81] = { 7'h0D, 16'hFC00, S5_CLKOUT1[31:16]};

// Store the input divider
rom[82] = {7'h16, 16'hC000, {2'h0, S5_DIVCLK[23:22], S5_DIVCLK[11:0]} };

// Store the feedback divide and phase
rom[83] = (S5_CLKFBOUT_FRAC_EN == 0) ? { 7'h14, 16'h1000, S5_CLKFBOUT[15:0]}: { 7'h14, 16'h1000, S5_CLKFBOUT_FRAC_CALC[15:0]};
rom[84] = (S5_CLKFBOUT_FRAC_EN == 0) ? { 7'h15, 16'h8000, S5_CLKFBOUT[31:16]}: { 7'h15, 16'h8000, S5_CLKFBOUT_FRAC_CALC[31:16]};

// Store the lock settings
rom[85] = {7'h18, 16'hFC00, {6'h00, S5_LOCK[29:20]} };
rom[86] = { 7'h19, 16'h8000, { 1'b0 , S5_LOCK[34:30], S5_LOCK[9:0]} };
rom[87] = { 7'h1A, 16'h8000, { 1'b0 , S5_LOCK[39:35], S5_LOCK[19:10]} };

// Store the filter settings
rom[88] = { 7'h4E, 16'h66FF, S5_DIGITAL_FILT[9], 2'h0, S5_DIGITAL_FILT[8:7], 2'h0, S5_DIGITAL_FILT[6], 8'h00 };
rom[89] = { 7'h4F, 16'h666F, S5_DIGITAL_FILT[5], 2'h0, S5_DIGITAL_FILT[4:3], 2'h0, S5_DIGITAL_FILT[2:1], 2'h0, S5_DIGITAL_FILT[0], 4'h0 };


// rom entries contain (in order) the address, a bitmask, and a bitset
 //***********************************************************************
// State 6 Initialization
//***********************************************************************

// Store the power bits
rom[90] = { 7'h28, 16'h0000, 16'hFFFF};

// Store CLKOUT0 divide and phase
rom[91] = (S6_CLKOUT0_FRAC_EN == 0) ? { 7'h09, 16'h8000, S6_CLKOUT0[31:16]}: {7'h09, 16'h8000, S6_CLKOUT0_FRAC_CALC[31:16]};
rom[92] = (S6_CLKOUT0_FRAC_EN == 0) ? { 7'h08, 16'h1000, S6_CLKOUT0[15:0]}: { 7'h08, 16'h1000, S6_CLKOUT0_FRAC_CALC[15:0]};

// Store CLKOUT1 divide and phase
rom[93] = { 7'h0A, 16'h1000, S6_CLKOUT1[15:0]};
rom[94] = { 7'h0B, 16'hFC00, S6_CLKOUT1[31:16]};

// Store CLKOUT2 divide and phase
rom[95] = { 7'h0C, 16'h1000, S6_CLKOUT1[15:0]};
rom[96] = { 7'h0D, 16'hFC00, S6_CLKOUT1[31:16]};

// Store the input divider
rom[97] = {7'h16, 16'hC000, {2'h0, S6_DIVCLK[23:22], S6_DIVCLK[11:0]} };

// Store the feedback divide and phase
rom[98] = (S6_CLKFBOUT_FRAC_EN == 0) ? { 7'h14, 16'h1000, S6_CLKFBOUT[15:0]}: { 7'h14, 16'h1000, S6_CLKFBOUT_FRAC_CALC[15:0]};
rom[99] = (S6_CLKFBOUT_FRAC_EN == 0) ? { 7'h15, 16'h8000, S6_CLKFBOUT[31:16]}: { 7'h15, 16'h8000, S6_CLKFBOUT_FRAC_CALC[31:16]};

// Store the lock settings
rom[100] = {7'h18, 16'hFC00, {6'h00, S6_LOCK[29:20]} };
rom[101] = { 7'h19, 16'h8000, { 1'b0 , S6_LOCK[34:30], S6_LOCK[9:0]} };
rom[102] = { 7'h1A, 16'h8000, { 1'b0 , S6_LOCK[39:35], S6_LOCK[19:10]} };

// Store the filter settings
rom[103] = { 7'h4E, 16'h66FF, S6_DIGITAL_FILT[9], 2'h0, S6_DIGITAL_FILT[8:7], 2'h0, S6_DIGITAL_FILT[6], 8'h00 };
rom[104] = { 7'h4F, 16'h666F, S6_DIGITAL_FILT[5], 2'h0, S6_DIGITAL_FILT[4:3], 2'h0, S6_DIGITAL_FILT[2:1], 2'h0, S6_DIGITAL_FILT[0], 4'h0 };


// rom entries contain (in order) the address, a bitmask, and a bitset
 //***********************************************************************
// State 7 Initialization
//***********************************************************************

// Store the power bits
rom[105] = { 7'h28, 16'h0000, 16'hFFFF};

// Store CLKOUT0 divide and phase
rom[106] = (S7_CLKOUT0_FRAC_EN == 0) ? { 7'h09, 16'h8000, S7_CLKOUT0[31:16]}: {7'h09, 16'h8000, S7_CLKOUT0_FRAC_CALC[31:16]};
rom[107] = (S7_CLKOUT0_FRAC_EN == 0) ? { 7'h08, 16'h1000, S7_CLKOUT0[15:0]}: { 7'h08, 16'h1000, S7_CLKOUT0_FRAC_CALC[15:0]};

// Store CLKOUT1 divide and phase
rom[108] = { 7'h0A, 16'h1000, S7_CLKOUT1[15:0]};
rom[109] = { 7'h0B, 16'hFC00, S7_CLKOUT1[31:16]};

// Store CLKOUT2 divide and phase
rom[110] = { 7'h0C, 16'h1000, S7_CLKOUT1[15:0]};
rom[111] = { 7'h0D, 16'hFC00, S7_CLKOUT1[31:16]};

// Store the input divider
rom[112] = {7'h16, 16'hC000, {2'h0, S7_DIVCLK[23:22], S7_DIVCLK[11:0]} };

// Store the feedback divide and phase
rom[113] = (S7_CLKFBOUT_FRAC_EN == 0) ? { 7'h14, 16'h1000, S7_CLKFBOUT[15:0]}: { 7'h14, 16'h1000, S7_CLKFBOUT_FRAC_CALC[15:0]};
rom[114] = (S7_CLKFBOUT_FRAC_EN == 0) ? { 7'h15, 16'h8000, S7_CLKFBOUT[31:16]}: { 7'h15, 16'h8000, S7_CLKFBOUT_FRAC_CALC[31:16]};

// Store the lock settings
rom[115] = {7'h18, 16'hFC00, {6'h00, S7_LOCK[29:20]} };
rom[116] = { 7'h19, 16'h8000, { 1'b0 , S7_LOCK[34:30], S7_LOCK[9:0]} };
rom[117] = { 7'h1A, 16'h8000, { 1'b0 , S7_LOCK[39:35], S7_LOCK[19:10]} };

// Store the filter settings
rom[118] = { 7'h4E, 16'h66FF, S7_DIGITAL_FILT[9], 2'h0, S7_DIGITAL_FILT[8:7], 2'h0, S7_DIGITAL_FILT[6], 8'h00 };
rom[119] = { 7'h4F, 16'h666F, S7_DIGITAL_FILT[5], 2'h0, S7_DIGITAL_FILT[4:3], 2'h0, S7_DIGITAL_FILT[2:1], 2'h0, S7_DIGITAL_FILT[0], 4'h0 };







     
      // Initialize the rest of the ROM
   //   rom[60] = {7'h28,32'h0000_0000};
      for(ii = 120; ii < 128; ii = ii +1) begin
         rom[ii] = 0;
      end
   end

   // Output the initialized rom value based on rom_addr each clock cycle
   always @(posedge SCLK) begin
      rom_do<= #TCQ rom[rom_addr];
   end
   
   //**************************************************************************
   // Everything below is associated whith the state machine that is used to
   // Read/Modify/Write to the MMCM.
   //**************************************************************************
   
   // State Definitions
   localparam RESTART      = 4'h1;
   localparam WAIT_LOCK    = 4'h2;
   localparam WAIT_SEN     = 4'h3;
   localparam ADDRESS      = 4'h4;
   localparam WAIT_A_DRDY  = 4'h5;
   localparam BITMASK      = 4'h6;
   localparam BITSET       = 4'h7;
   localparam WRITE        = 4'h8;
   localparam WAIT_DRDY    = 4'h9;
   
   // State sync
   reg [3:0]  current_state   = RESTART;
   reg [3:0]  next_state      = RESTART;
   
   // These variables are used to keep track of the number of iterations that 
   //    each state takes to reconfigure.
   // STATE_COUNT_CONST is used to reset the counters and should match the
   //    number of registers necessary to reconfigure each state.
   localparam STATE_COUNT_CONST  = 15;
   reg [4:0] state_count         = STATE_COUNT_CONST; 
   reg [4:0] next_state_count    = STATE_COUNT_CONST;
   
   // This block assigns the next register value from the state machine below
   always @(posedge SCLK) begin
      DADDR       <= #TCQ next_daddr;
      DWE         <= #TCQ next_dwe;
      DEN         <= #TCQ next_den;
      RST_MMCM    <= #TCQ next_rst_mmcm;
      DI          <= #TCQ next_di;
      
      SRDY        <= #TCQ next_srdy;
      
      rom_addr    <= #TCQ next_rom_addr;
      state_count <= #TCQ next_state_count;
   end
   
   // This block assigns the next state, reset is syncronous.
   always @(posedge SCLK) begin
      if(RST) begin
         current_state <= #TCQ RESTART;
      end else begin
         current_state <= #TCQ next_state;
      end
   end
   
   always @* begin
      // Setup the default values
      next_srdy         = 1'b0;
      next_daddr        = DADDR;
      next_dwe          = 1'b0;
      next_den          = 1'b0;
      next_rst_mmcm     = RST_MMCM;
      next_di           = DI;
      next_rom_addr     = rom_addr;
      next_state_count  = state_count;
   
      case (current_state)
         // If RST is asserted reset the machine
         RESTART: begin
            next_daddr     = 7'h00;
            next_di        = 16'h0000;
            next_rom_addr  = 6'h00;
            next_rst_mmcm  = 1'b1;
            next_state     = WAIT_LOCK;
         end
         
         // Waits for the MMCM to assert LOCKED - once it does asserts SRDY
         WAIT_LOCK: begin
            // Make sure reset is de-asserted
            next_rst_mmcm   = 1'b0;
            // Reset the number of registers left to write for the next 
            // reconfiguration event.
            next_state_count = STATE_COUNT_CONST ;
            next_rom_addr = SADDR ? (STATE_COUNT_CONST* SADDR) : 8'h00;
            
            if(LOCKED) begin
               // MMCM is locked, go on to wait for the SEN signal
               next_state  = WAIT_SEN;
               // Assert SRDY to indicate that the reconfiguration module is
               // ready
               next_srdy   = 1'b1;
            end else begin
               // Keep waiting, locked has not asserted yet
               next_state  = WAIT_LOCK;
            end
         end
         
         // Wait for the next SEN pulse and set the ROM addr appropriately 
         //    based on SADDR
         WAIT_SEN: begin
            next_rom_addr = SADDR ? (STATE_COUNT_CONST* SADDR) : 8'h00;
            if (SEN) begin
               next_rom_addr = SADDR ? (STATE_COUNT_CONST* SADDR) : 8'h00;
               // Go on to address the MMCM
               next_state = ADDRESS;
            end else begin
               // Keep waiting for SEN to be asserted
               next_state = WAIT_SEN;
            end
         end
         
         // Set the address on the MMCM and assert DEN to read the value
         ADDRESS: begin
            // Reset the DCM through the reconfiguration
            next_rst_mmcm  = 1'b1;
            // Enable a read from the MMCM and set the MMCM address
            next_den       = 1'b1;
            next_daddr     = rom_do[38:32];
            
            // Wait for the data to be ready
            next_state     = WAIT_A_DRDY;
         end
         
         // Wait for DRDY to assert after addressing the MMCM
         WAIT_A_DRDY: begin
            if (DRDY) begin
               // Data is ready, mask out the bits to save
               next_state = BITMASK;
            end else begin
               // Keep waiting till data is ready
               next_state = WAIT_A_DRDY;
            end
         end
         
         // Zero out the bits that are not set in the mask stored in rom
         BITMASK: begin
            // Do the mask
            next_di     = rom_do[31:16] & DO;
            // Go on to set the bits
            next_state  = BITSET;
         end
         
         // After the input is masked, OR the bits with calculated value in rom
         BITSET: begin
            // Set the bits that need to be assigned
            next_di           = rom_do[15:0] | DI;
            // Set the next address to read from ROM
            next_rom_addr     = rom_addr + 1'b1;
            // Go on to write the data to the MMCM
            next_state        = WRITE;
         end
         
         // DI is setup so assert DWE, DEN, and RST_MMCM.  Subtract one from the
         //    state count and go to wait for DRDY.
         WRITE: begin
            // Set WE and EN on MMCM
            next_dwe          = 1'b1;
            next_den          = 1'b1;
            
            // Decrement the number of registers left to write
            next_state_count  = state_count - 1'b1;
            // Wait for the write to complete
            next_state        = WAIT_DRDY;
         end
         
         // Wait for DRDY to assert from the MMCM.  If the state count is not 0
         //    jump to ADDRESS (continue reconfiguration).  If state count is
         //    0 wait for lock.
         WAIT_DRDY: begin
            if(DRDY) begin
               // Write is complete
               if(state_count > 0) begin
                  // If there are more registers to write keep going
                  next_state  = ADDRESS;
               end else begin
                  // There are no more registers to write so wait for the MMCM
                  // to lock
                  next_state  = WAIT_LOCK;
               end
            end else begin
               // Keep waiting for write to complete
               next_state     = WAIT_DRDY;
            end
         end
         
         // If in an unknown state reset the machine
         default: begin
            next_state = RESTART;
         end
      endcase
   end
endmodule