/*
 Zhaoyang Han
 han221@purdue.edu
 alu interface
 */

`ifndef ALU_IF_VH
 `define ALU_IF_VH

 `include "cpu_types_pkg.vh"

interface alu_if;
   import cpu_types_pkg::*;
   aluop_t ALUOP;
   word_t porta, portb, out;
   
     logic overflow, zero, negative;

   //ports
   modport aluif (
		input porta, portb, ALUOP,
		output negative, zero, overflow, out
		);

   modport alutb (
		  output negative, zero, overflow, out,
		  input porta, portb, ALUOP
		  );
   endinterface
`endif //  `ifndef ALU_IF_VH
