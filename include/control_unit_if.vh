/*
 Zhaoyang Han
 han221@purdue.edu
 
 control unit interface
 */

`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

// types
`include "cpu_types_pkg.vh"

interface control_unit_if;
   import cpu_types_pkg::*;
   word_t instr;
   logic dREN, dWEN, JR, halt, bne, beq, zero_ext, Lui, RegWrite, MemWR, MemtoReg, RegDst, Jal, J, ALUSrc, shamt, sign_ext;
   aluop_t ALUOP;
   
   logic overf;
   

   // control_unit port
   modport cu (
	       input instr, overf,
	       output dREN, dWEN, JR, halt, bne, beq, zero_ext, Lui, ALUOP, RegWrite, MemWR, MemtoReg, RegDst, Jal, J, ALUSrc, shamt, sign_ext

	       );
   

   
   // testbench port
   modport tb (
	       input dREN, dWEN, JR, halt, bne, beq, zero_ext, Lui, ALUOP, RegWrite, MemWR, MemtoReg, RegDst, Jal, J, ALUSrc, shamt, sign_ext,
	       output instr, overf
	       );
   




endinterface // control_unit_if

`endif //  `ifndef CONTROL_UNIT_IF_VH
