

`ifndef ALU_IF_VH
`define ALU_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface alu_if;
   // import types
   import cpu_types_pkg::*;
   
   logic     negative, overflow, zero;
   word_t    portA, portB, output_port;
   aluop_t   aluop;
   
   
  // alu ports
  modport alu_port (
    input   portA, portB, aluop,
    output  negative, overflow, zero, output_port
  );
  // alu tb
  modport alu_tb (
    input   negative, overflow, zero, output_port,
    output  portA, portB, aluop
  );
endinterface

`endif //ALU_IF_VH
