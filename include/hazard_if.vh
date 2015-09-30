/*
 Zhaoyang Han & Jinyi Zhang
 han221 & zhan1128
 
 hazard unit interface
 */

`ifndef HAZARD_IF
 `define HAZARD_IF
 `include "cpu_types_pkg.vh"

interface hazard_if;
   import cpu_types_pkg::*;
   parameter CPUS = 1;
   parameter CPUID = 0;


   ////////////////// For EX Hazard ///////////////////////
   // Inputs
   regbits_t wsel_out_3, wsel_out_4, rt_out_2, rs_out_2;
   logic RegWrite_out_3, RegWrite_out_4;
   




   // Outputs
   logic [1:0] forwardA, forwardB;
   


   ////////////////// For EX Hazard ///////////////////////

   // ports
   modport hi (
	       input rt_out_2, rs_out_2, wsel_out_3, wsel_out_4, RegWrite_out_3, RegWrite_out_4,
	       output forwardA, forwardB
	       );

   modport tb (
	       input forwardA, forwardB,
	       output  rt_out_2, rs_out_2, wsel_out_3, wsel_out_4, RegWrite_out_3, RegWrite_out_4
	       );
   

endinterface // hazard_if
`endif //  `ifndef HAZARD_IF
