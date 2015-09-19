/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"
`include "register_file_if.vh"
`include "control_unit_if.vh"
`include "request_unit_if.vh"
`include "alu_if.vh"
// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  // import types
  import cpu_types_pkg::*;

  // pc init
  parameter PC_INIT = 0;

   // interfaces
   register_file_if rfif ();
   alu_if aluif ();
   control_unit_if cuif();
   request_unit_if ruif();

   //maps
   register_file RF (CLK, nRST, rfif);
   alu ALU (aluif);
   control_unit CU (cuif);
   request_unit RU (CLK, nRST, ruif);

   
   
   // PC
   word_t pc_wait, pc_curr, pc_next;
   word_t pc_out, pc_jjal, pc_out4, pc_outbranch, pc_iextnshft;
   
   
   assign pc_jjal = {pc_out4[31:28], dpif.imemload[25:0], 2'b00};
   
   assign pc_wait = pc_curr;
   assign pc_iextnshft = (dpif.imemload[15] == 1 ? {16'b1, dpif.imemload[15:0]}:{16'b0, dpif.imemload[15:0]}) << 2;
   
   
   always_ff @ (posedge CLK, negedge nRST) begin
      
      if (nRST == 0) begin
	 pc_curr <= 0;
      end
      else if (dpif.ihit == 1 && dpif.dhit == 0) begin
	 pc_curr <= pc_next;
      end
      else begin
	 pc_curr <= pc_wait;
      end
      
   end
   always_comb begin
      pc_out4 = pc_curr + 4;
      pc_outbranch = pc_out4 + pc_iextnshft;
      // the branch or + 4 block
      if (cuif.bne == 1 && aluif.zero != 1) begin
	 pc_out = pc_outbranch;
      end
      else if(cuif.beq == 1 && aluif.zero == 1)begin
	 pc_out = pc_outbranch;
      end
      else begin
	 pc_out = pc_out4;
      end
      // the 3 way mux
      if (cuif.J == 1 || cuif.Jal == 1) begin
	 pc_next = pc_jjal;
      end
      else if (cuif.JR == 1)begin
	 pc_next = rfif.rdat1;
      end
      else begin
	 pc_next = pc_out;
      end
   end
   ////// where does the pc_curr go?????


   // register file
   assign rfif.rsel1 = dpif.imemload[25:21];
   assign rfif.rsel2 = dpif.imemload[20:16];
   assign rfif.WEN = cuif.RegWrite;
   assign rfif.wsel = cuif.Jal == 1 ? 5'd31 : (cuif.RegDst == 1 ? dpif.imemload[15:11] : dpif.imemload[20:16]);
   assign rfif.wdat = cuif.Jal == 1 ? pc_out4 : (cuif.MemtoReg == 1 ? dpif.dmemload : aluif.out);

   // alu
   // shift amount
   word_t shiftAmount;
   always_comb begin
      // the extend block logic
      if (cuif.sign_ext == 1)begin
	 if (cuif.shamt == 1)begin
	    shiftAmount = dpif.imemload[10] == 1 ? {27'h7FFFFFF, dpif.imemload[10:6]} : {27'b0, dpif.imemload[10:6]};
	 end
	 else begin
	    shiftAmount = dpif.imemload[15] == 1 ? {16'hFFFF, dpif.imemload[15:0]} : {16'b0, dpif.imemload[15:0]};
	 end
      end
      else if (cuif.zero_ext == 1)begin
	 if (cuif.shamt == 1)begin
	    shiftAmount = {27'b0, dpif.imemload[10:6]};
	 end
	 else begin
	    shiftAmount = {16'b0, dpif.imemload[15:0]};
	 end
      end
      else if (cuif.Lui == 1) begin
	 shiftAmount = {dpif.imemload[15:0], 16'b0};
      end
      else begin
	 shiftAmount = 0;
      end
   end
   
   assign aluif.porta = cuif.Lui == 1 ? 0 : rfif.rdat1;
   assign aluif.portb = cuif.ALUSrc == 1 ? shiftAmount : rfif.rdat2;
   assign aluif.ALUOP = cuif.ALUOP;

   // control unit
   assign cuif.instr = dpif.imemload;
   assign cuif.overf = aluif.overflow;

   // request unit
   assign ruif.ihit = dpif.ihit;
   assign ruif.dhit = dpif.dhit;
   assign ruif.dREN = cuif.dREN;
   assign ruif.dWEN = cuif.dWEN;

   // datapath
   logic halt_next, halt_curr;
   assign halt_next = cuif.halt;
   always_ff @ (posedge CLK, negedge nRST) begin
      if(nRST == 0)begin
	 halt_curr <= 0;
      end
      else begin
	 halt_curr <= halt_next;
      end
   end
   
   assign dpif.imemREN = ruif.imemREN;
   assign dpif.dmemREN = ruif.dmemREN;
   assign dpif.dmemWEN = ruif.dmemWEN;
   assign dpif.halt = halt_curr;
   assign dpif.dmemstore = rfif.rdat2;
   assign dpif.dmemaddr = aluif.out;
   assign dpif.imemaddr = pc_curr;
   
   
endmodule
