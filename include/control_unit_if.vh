`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface control_unit_if;
   // import types
   import cpu_types_pkg::*;

   logic iREN;
   logic dREN;
   logic dWEN;
   logic halt;
   
   logic sign_ext;
   logic j;
   logic jr;
   logic jal;
   logic lui;
   logic shamt_en;
   logic ALUSrc;
   logic PCSrc;
   logic RegDest;
   logic MemReg;
   // logic RegWrite;
   logic bne;
   
   logic WEN;
   // logic go_through;

   // overflow flag from alu
   logic overflow;
   
   aluop_t ALUcode;
   
   word_t instruction;
   
   
  // control unit ports
  modport cu (
	      input  instruction, overflow,
	      output halt, iREN, dREN, dWEN, sign_ext, j, jr, jal, lui, shamt_en, ALUSrc, PCSrc, RegDest, ALUcode, MemReg, bne, WEN
  );
  // control unit tb
  modport cutb (
  		input  halt, iREN, dREN, dWEN, sign_ext, j, jr, jal, lui, shamt_en, ALUSrc, PCSrc, RegDest, ALUcode, MemReg, bne,
		output instruction, overflow
  );
endinterface

`endif //CONTROL_UNIT_IF_VH
