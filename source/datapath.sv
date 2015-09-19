/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"
`include "control_unit_if.vh"
`include "request_unit_if.vh"
`include "register_file_if.vh"
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

   // PC counter tmp
   word_t pc, next_pc;
   word_t pc_4, pc_j, pc_jr;
   word_t imm_tmp_shift2, pc_imm;
   word_t pc_4_branch;

   // Branch tmp
   logic      branch_eq, branch_go;

   // Halt tmp
   logic      halt, next_halt;
   
   // Intruction from cache
   word_t instr;
   assign instr = dpif.imemload;
   
   // Register file wsel tmp
   logic [4:0] wsel_tmp;

   // Extention tmp
   logic [15:0] unext_tmp;
   word_t signext_tmp;
   word_t zeroext_tmp;
   word_t ext_tmp;
   word_t imm_tmp;

   // register write data tmp
   word_t wdat_tmp;
   
   
   // Load interface
   control_unit_if cu_if();
   request_unit_if ru_if();
   alu_if alu_if();
   register_file_if rf_if();

   // Connect modules
   control_unit CU(cu_if);
   request_unit RU(CLK, nRST, ru_if);
   alu ALU(alu_if);
   register_file RF(CLK, nRST, rf_if);   

   // Connect register file input signals
   assign rf_if.rsel1 = instr[25:21];
   assign rf_if.rsel2 = instr[20:16];
   assign rf_if.WEN = cu_if.WEN;
   assign rf_if.wsel = (cu_if.jal == 1) ? 5'b11111 : wsel_tmp;
   assign wsel_tmp = (cu_if.RegDest == 1) ? instr[20:16]:instr[15:11];

   // Connect alu inputs
   assign alu_if.portA = (cu_if.lui == 1) ? 32'h00000000:rf_if.rdat1;
   assign alu_if.portB = (cu_if.ALUSrc == 1) ? rf_if.rdat2 : imm_tmp;
   assign alu_if.aluop = cu_if.ALUcode;

   // Connect control unit input signals
   assign cu_if.instruction = dpif.imemload;
   assign cu_if.overflow = alu_if.overflow;

   // Connect request unit input signals
   assign ru_if.iREN = cu_if.iREN;
   assign ru_if.dREN = cu_if.dREN;
   assign ru_if.dWEN = cu_if.dWEN;
   // assign ru_if.halt = halt;
   // dhit
   assign ru_if.dhit = dpif.dhit;

   // Connect datapath output
   assign dpif.dmemstore = rf_if.rdat2;
   assign dpif.dmemaddr = alu_if.output_port;
   assign dpif.halt = halt;
   assign dpif.imemREN = ru_if.imemREN;
   assign dpif.imemaddr = pc;
   assign dpif.dmemREN = ru_if.dmemREN;
   assign dpif.dmemWEN = ru_if.dmemWEN;
   
   // PC counter
   always_ff @ (posedge CLK, negedge nRST)
     begin
	if(nRST == 1'b0)
	  begin
	     pc <= PC_INIT;	     
	  end
	else
	  begin
	     if(dpif.ihit == 1'b1 && dpif.dhit == 1'b0)
	       begin
		  pc <= next_pc;
	       end
	  end
     end
   

   // Calculate next pc position
   assign pc_4 = pc + 4;
   assign pc_j = {pc_4[31:28], instr[25:0], 2'b00};
   assign pc_jr = rf_if.rdat1;

   // Calculate branch addr
   assign imm_tmp_shift2 = imm_tmp << 2;
   assign pc_imm = pc_4 + imm_tmp_shift2;
   
   assign branch_eq = alu_if.zero & cu_if.PCSrc;
   assign branch_go = (cu_if.bne) ? (~branch_eq) : branch_eq;

   assign pc_4_branch = (branch_go) ? pc_imm : pc_4;
   // assign next_pc = (cu_if.jr & (~cu_if.j) ) ? pc_jr : (cu_if.j | cu_if.jal) ? pc_j : pc_4_branch;//add ~j
   always_comb
     begin
	next_pc = pc_4_branch;
	if(cu_if.jr)
	  begin
	     next_pc = pc_jr;
	  end
	else if(cu_if.j | cu_if.jal)
	  begin
	     next_pc = pc_j;
	  end
     end
   
   
   // Calculate zero/sign extension
   assign unext_tmp = (cu_if.shamt_en == 1) ? instr[15:0]:{11'b0,instr[10:6]};
   assign signext_tmp = (unext_tmp[15] == 1) ? {16'hffff, unext_tmp}:{16'h0000, unext_tmp};
   assign zeroext_tmp = {16'h0000, unext_tmp};
   assign ext_tmp = (cu_if.sign_ext == 1) ? signext_tmp:zeroext_tmp;
   assign imm_tmp = (cu_if.lui == 1) ? {unext_tmp, 16'h0000}:ext_tmp;


   // Calculate writing data back to register
   assign wdat_tmp = (cu_if.MemReg == 1) ? dpif.dmemload:alu_if.output_port;
   assign rf_if.wdat = (cu_if.jal == 1) ? pc_4 : wdat_tmp;
   
   always_ff @ (posedge CLK, negedge nRST)
     begin
	if(nRST == 1'b0)
	  begin
	     halt <= 1'b0;
	  end
	else
	  begin
	     halt = next_halt;
	  end
     end

   assign next_halt = cu_if.halt;
   
   
endmodule
