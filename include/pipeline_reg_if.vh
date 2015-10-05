/*
 Zhaoyang Han & Jinyi Zhang
 han221 & zhan1128
 
 pipeline registers interface
 */

`ifndef PIPELINE_REG_IF
 `define PIPELINE_REG_IF

 `include "cpu_types_pkg.vh"

interface pipeline_reg_if;

   import cpu_types_pkg::*;
   parameter CPUS = 1;
   parameter CPUID = 0;

   // register enable
   logic dhit;
   

   // register flush
   logic flush;
   
   

   // FORMAT: signal_in/out_NO.register bar
   
   // IF/ID, first register bar
   
   //inputs
   word_t instr_in_1, pc_4_in_1;
 
   //outpus
   word_t instr_out_1, pc_4_out_1;

   

   // ID/EX, second register bar, pc4_out go through here
   //inputs
   word_t rdat1_in_2, rdat2_in_2, pc_4_in_2;
   logic [25:0] jumpAddr_in_2;
   
   regbits_t rt_in_2, rd_in_2, rs_in_2;
   logic [SHAM_W-1:0] shamt_in_2;
   
   logic [IMM_W-1:0] imm_in_2;
   logic 	RegWrite_in_2, dWEN_in_2, dREN_in_2, halt_in_2, overflow_flag_in_2, Lui_in_2, jal_in_2, j_in_2, JR_in_2, bne_in_2, sign_ext_in_2, shamt_flag_in_2, ALUSrc_in_2, beq_in_2, RegDst_in_2, MemtoReg_in_2;
   // outpus
   word_t rdat1_out_2, rdat2_out_2, pc_4_out_2;
   logic [25:0] jumpAddr_out_2;
   
   regbits_t	rt_out_2, rd_out_2, rs_out_2;
   logic [SHAM_W-1:0] shamt_out_2;
   logic [IMM_W-1:0] imm_out_2;
   logic 	RegWrite_out_2, dWEN_out_2, dREN_out_2, halt_out_2, overflow_flag_out_2, Lui_out_2, jal_out_2, j_out_2, JR_out_2, bne_out_2, sign_ext_out_2, shamt_flag_out_2, ALUSrc_out_2, beq_out_2, RegDst_out_2, MemtoReg_out_2;

   // ALU op
   aluop_t ALUOP_in_2, ALUOP_out_2;
   
   
   
   //EX/MEM, third register bar, RegWrite, dWEN, dREN, jal, bne, beq, MemtoReg, pc_4_out, rdat2 go through here

   // overflow & halt signal undone

   //inputs
   logic 	RegWrite_in_3, dWEN_in_3, dREN_in_3, jal_in_3, bne_in_3, beq_in_3, MemtoReg_in_3, halt_or_in_3, zero_in_3;
   logic [25:0] jumpAddr_in_3;
   
   
   word_t pc_imm_in_3, ALUout_in_3, pc_4_in_3, dmemstore_in_3;
   regbits_t wsel_in_3;

   logic 	j_in_3, JR_in_3;
   word_t rdat1_in_3;
   
   //outputs
   logic 	RegWrite_out_3, dWEN_out_3, dREN_out_3, halt_or_out_3, jal_out_3, bne_out_3, beq_out_3, MemtoReg_out_3, zero_out_3;
   logic [25:0] jumpAddr_out_3;
   
   word_t ALUout_out_3, dmemstore_out_3, pc_4_out_3, pc_imm_out_3;
   
   regbits_t wsel_out_3;
   logic 	j_out_3, JR_out_3;
   word_t rdat1_out_3;
   
   
   //MEM/WB, the fourth register bar
   //inputs
   logic 	RegWrite_in_4, halt_or_in_4, jal_in_4, MemtoReg_in_4;
   
   word_t dmemload_in_4, pc_4_in_4, ALUout_in_4;
   regbits_t wsel_in_4;
   

   //outputs
   logic 	RegWrite_out_4, halt_or_out_4, jal_out_4, MemtoReg_out_4;
   word_t pc_4_out_4;
   word_t dmemload_out_4, ALUout_out_4;
   regbits_t wsel_out_4;



   // new added for lab7, lw stall signal from 2 to 4
   logic 	lwForwardA_in_2, lwForwardA_in_3, lwForwardA_in_4, lwForwardA_out_2, lwForwardA_out_3, lwForwardA_out_4;
   logic 	lwForwardB_in_2, lwForwardB_in_3, lwForwardB_in_4, lwForwardB_out_2, lwForwardB_out_3, lwForwardB_out_4;
   
   
   
   modport pr (
	       input  dhit, instr_in_1, pc_4_in_1, rdat1_in_2, rdat2_in_2, pc_4_in_2, jumpAddr_in_2, jumpAddr_in_3, rs_in_2, rt_in_2, rd_in_2, shamt_in_2, imm_in_2, RegWrite_in_2, dWEN_in_2, dREN_in_2, halt_in_2, overflow_flag_in_2, Lui_in_2, jal_in_2, j_in_2, JR_in_2, bne_in_2, sign_ext_in_2, shamt_flag_in_2, ALUSrc_in_2, beq_in_2, RegDst_in_2, ALUOP_in_2, MemtoReg_in_2, RegWrite_in_3, dWEN_in_3, dREN_in_3, jal_in_3, bne_in_3, beq_in_3, MemtoReg_in_3, halt_or_in_3, zero_in_3, pc_imm_in_3, ALUout_in_3, pc_4_in_3, dmemstore_in_3, wsel_in_3, RegWrite_in_4, halt_or_in_4, jal_in_4, MemtoReg_in_4, dmemload_in_4, pc_4_in_4, ALUout_in_4, wsel_in_4, j_in_3, JR_in_3, rdat1_in_3, flush, lwForwardA_in_2, lwForwardA_in_3, lwForwardA_in_4, lwForwardB_in_2, lwForwardB_in_3, lwForwardB_in_4,
	       output instr_out_1, pc_4_out_1, rdat1_out_2, rdat2_out_2, pc_4_out_2, jumpAddr_out_2, jumpAddr_out_3, rs_out_2, rt_out_2, rd_out_2, shamt_out_2, imm_out_2, RegWrite_out_2, dWEN_out_2, dREN_out_2, halt_out_2, overflow_flag_out_2, Lui_out_2, jal_out_2, j_out_2, JR_out_2, bne_out_2, sign_ext_out_2, shamt_flag_out_2, ALUSrc_out_2, beq_out_2, RegDst_out_2, ALUOP_out_2, MemtoReg_out_2, RegWrite_out_3, dWEN_out_3, dREN_out_3, halt_or_out_3, jal_out_3, bne_out_3, beq_out_3, MemtoReg_out_3, zero_out_3, ALUout_out_3, dmemstore_out_3, pc_4_out_3, pc_imm_out_3, wsel_out_3, RegWrite_out_4, halt_or_out_4, jal_out_4, MemtoReg_out_4, pc_4_out_4, dmemload_out_4, ALUout_out_4, wsel_out_4, j_out_3, JR_out_3, rdat1_out_3, lwForwardA_out_2, lwForwardA_out_3, lwForwardA_out_4, lwForwardB_out_2, lwForwardB_out_3, lwForwardB_out_4
	       );
   
   modport tb (
	       input instr_out_1, pc_4_out_1, rdat1_out_2, rdat2_out_2, pc_4_out_2, jumpAddr_out_2, jumpAddr_out_3, rs_out_2, rt_out_2, rd_out_2, shamt_out_2, imm_out_2, RegWrite_out_2, dWEN_out_2, dREN_out_2, halt_out_2, overflow_flag_out_2, Lui_out_2, jal_out_2, j_out_2, JR_out_2, bne_out_2, sign_ext_out_2, shamt_flag_out_2, ALUSrc_out_2, beq_out_2, RegDst_out_2, ALUOP_out_2, MemtoReg_out_2, RegWrite_out_3, dWEN_out_3, dREN_out_3, halt_or_out_3, jal_out_3, bne_out_3, beq_out_3, MemtoReg_out_3, zero_out_3, ALUout_out_3, dmemstore_out_3, pc_4_out_3, pc_imm_out_3, wsel_out_3, RegWrite_out_4, halt_or_out_4, jal_out_4, MemtoReg_out_4, pc_4_out_4, dmemload_out_4, ALUout_out_4, wsel_out_4, j_out_3, JR_out_3, rdat1_out_3, lwForwardA_out_2, lwForwardA_out_3, lwForwardA_out_4, lwForwardB_out_2, lwForwardB_out_3, lwForwardB_out_4,
	       output dhit, instr_in_1, pc_4_in_1, rdat1_in_2, rdat2_in_2, pc_4_in_2, jumpAddr_in_2, jumpAddr_in_3, rs_in_2, rt_in_2, rd_in_2, shamt_in_2, imm_in_2, RegWrite_in_2, dWEN_in_2, dREN_in_2, halt_in_2, overflow_flag_in_2, Lui_in_2, jal_in_2, j_in_2, JR_in_2, bne_in_2, sign_ext_in_2, shamt_flag_in_2, ALUSrc_in_2, beq_in_2, RegDst_in_2, ALUOP_in_2, MemtoReg_in_2, RegWrite_in_3, dWEN_in_3, dREN_in_3, jal_in_3, bne_in_3, beq_in_3, MemtoReg_in_3, halt_or_in_3, zero_in_3, pc_imm_in_3, ALUout_in_3, pc_4_in_3, dmemstore_in_3, wsel_in_3, RegWrite_in_4, halt_or_in_4, jal_in_4, MemtoReg_in_4, dmemload_in_4, pc_4_in_4, ALUout_in_4, wsel_in_4, j_in_3, JR_in_3, rdat1_in_3, flush, lwForwardA_in_2, lwForwardA_in_3, lwForwardA_in_4, lwForwardB_in_2, lwForwardB_in_3, lwForwardB_in_4
	       );

endinterface // pipeline_reg_if
`endif //  `ifndef PIPELINE_REG_IF
