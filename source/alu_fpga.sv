
// interface
`include "alu_if.vh"

module alu_fpga (
  input logic CLOCK_50,
  input logic [3:0] KEY,
  input logic [17:0] SW,
  output logic [17:0] LEDR
);

  // interface
  alu_if aluif();
  // rf
  alu ALU(aluif);

   assign aluif.aluop = KEY;
   assign aluif.portA = SW[15:0];

   always_ff

endmodule
