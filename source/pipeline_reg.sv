/*
 Zhaoyang Han & Jinyi Zhang
 han221 & zhan1128
 
 pipeline registers source file
 */

`include "pipeline_reg_if.vh"
`include "cpu_types_pkg.vh"

module pipeline_reg(
		    input logic CLK, nRST,
		    pipeline_reg_if.pr prif
		    );
   import cpu_types_pkg::*;

   always_ff @ (posedge CLK, negedge nRST) begin
      if (nRST == 0) begin
	 prif.instr_out_1 <= 0;
	 prif.pc_4_out_1 <= 0;
	 prif.rdat1_out_2 <= 0;
	 // prif.JRaddr_out_2 <= 0;
	 prif.rdat2_out_2 <= 0;
	 prif.pc_4_out_2 <= 0;

	 prif.jumpAddr_out_2 <= 0;
	 
	 
	 prif.rt_out_2 <= 0; //change in to out
	 prif.rd_out_2 <= 0; //chnage in to out
	 prif.rs_out_2 <= 0;
	 
	 prif.shamt_out_2 <= 0;
	 prif.imm_out_2 <= 0;
	 prif.RegWrite_out_2 <= 0;
	 prif.dWEN_out_2 <= 0;
	 prif.dREN_out_2 <= 0;
	 // prif.iREN_2 <= 0;
	 prif.halt_out_2 <= 0;
	 prif.overflow_flag_out_2 <= 0;
	 prif.Lui_out_2 <= 0;
	 prif.jal_out_2 <= 0;
	 prif.j_out_2 <= 0;
	 prif.JR_out_2 <= 0;
	 prif.bne_out_2 <= 0;
	 prif.sign_ext_out_2 <= 0;
	 prif.shamt_flag_out_2 <= 0;
	 prif.ALUSrc_out_2 <= 0;
	 prif.beq_out_2 <= 0;
	 prif.RegDst_out_2 <= 0;
	 prif.ALUOP_out_2 <= ALU_SLL;
	 prif.MemtoReg_out_2 <= 0;
	 
	 // part of third reg
	 prif.j_out_3 <= 0;
	 prif.jal_out_3 <= 0;
	 prif.JR_out_3 <= 0;
	 prif.bne_out_3 <= 0;
	 prif.beq_out_3 <= 0;
	 
	 prif.dWEN_out_3 <= 0;

	 prif.halt_or_out_3 <= 0;

	 prif.RegWrite_out_3 <= 0;
	 prif.atomic_out_2 <= 0;
	 prif.atomic_out_3 <= 0;
	 
	 
	 
      end // if (nRST == 0)
      else if(prif.flush & prif.enable == 1)
	begin
	   prif.instr_out_1 <= 0;
	   prif.pc_4_out_1 <= 0;
	   prif.rdat1_out_2 <= 0;
	   // prif.JRaddr_out_2 <= 0;
	   prif.rdat2_out_2 <= 0;
	   prif.pc_4_out_2 <= 0;
	   
	   prif.jumpAddr_out_2 <= 0;
	   
	   
	   prif.rt_out_2 <= 0; //change in to out
	   prif.rd_out_2 <= 0; //chnage in to out
	   prif.rs_out_2 <= 0;
	 
	   prif.shamt_out_2 <= 0;
	   prif.imm_out_2 <= 0;
	   prif.RegWrite_out_2 <= 0;
	   prif.dWEN_out_2 <= 0;
	   prif.dREN_out_2 <= 0;
	   // prif.iREN_2 <= 0;
	   prif.halt_out_2 <= 0;
	   prif.overflow_flag_out_2 <= 0;
	   prif.Lui_out_2 <= 0;
	   prif.jal_out_2 <= 0;
	   prif.j_out_2 <= 0;
	   prif.JR_out_2 <= 0;
	   prif.bne_out_2 <= 0;
	   prif.sign_ext_out_2 <= 0;
	   prif.shamt_flag_out_2 <= 0;
	   prif.ALUSrc_out_2 <= 0;
	   prif.beq_out_2 <= 0;
	   prif.RegDst_out_2 <= 0;
	   prif.ALUOP_out_2 <= ALU_SLL;
	   prif.MemtoReg_out_2 <= 0;

	   // part of third reg
	   prif.dWEN_out_3 <= 0;
	   prif.halt_or_out_3 <= 0;
	   prif.RegWrite_out_3 <= 0;

	   prif.j_out_3 <= 0;
	   prif.jal_out_3 <= 0;
	   prif.JR_out_3 <= 0;
	   prif.bne_out_3 <= 0;
	   prif.beq_out_3 <= 0;
	   // part of fourth reg
	   prif.atomic_out_2 <= 0;
	   prif.atomic_out_3 <= 0;
	 

	   
	end
     
      else if (prif.enable == 1)begin
	 prif.instr_out_1 <= prif.instr_in_1;
	 prif.pc_4_out_1 <= prif.pc_4_in_1;
	 prif.rdat1_out_2 <= prif.rdat1_in_2;
	 prif.rdat2_out_2 <= prif.rdat2_in_2;
	 // prif.JRaddr_out_2 <= prif.JRaddr_in_2;
	 prif.pc_4_out_2 <= prif.pc_4_in_2;

	 // remember to assign instruction to jumpAddr_2
	 prif.jumpAddr_out_2 <= prif.jumpAddr_in_2; 
	 
	 prif.rt_out_2 <= prif.rt_in_2;
	 prif.rd_out_2 <= prif.rd_in_2;
	 prif.rs_out_2 <= prif.rs_in_2;
	 
	 prif.shamt_out_2 <= prif.shamt_in_2;
	 prif.imm_out_2 <= prif.imm_in_2;
	 prif.RegWrite_out_2 <= prif.RegWrite_in_2;
	 prif.dWEN_out_2 <= prif.dWEN_in_2;
	 prif.dREN_out_2 <= prif.dREN_in_2;
	 // prif.iREN_out_2 <= prif.iREN_in_2; // No need for iREN
	 prif.halt_out_2 <= prif.halt_in_2;
	 prif.overflow_flag_out_2 <= prif.overflow_flag_in_2;
	 prif.Lui_out_2 <= prif.Lui_in_2;
	 prif.jal_out_2 <= prif.jal_in_2;
	 prif.j_out_2 <= prif.j_in_2;
	 prif.JR_out_2 <= prif.JR_in_2;
	 prif.bne_out_2 <= prif.bne_in_2;
	 prif.sign_ext_out_2 <= prif.sign_ext_in_2;
	 prif.shamt_flag_out_2 <= prif.shamt_flag_in_2;
	 prif.ALUSrc_out_2 <= prif.ALUSrc_in_2;
	 prif.beq_out_2 <= prif.beq_in_2;
	 prif.RegDst_out_2 <= prif.RegDst_in_2;
	 prif.ALUOP_out_2 <= prif.ALUOP_in_2;
	 prif.MemtoReg_out_2 <= prif.MemtoReg_in_2;

	 // part of third reg
	 // deleted regwrite
	 prif.dWEN_out_3 <= prif.dWEN_in_3;
	 prif.RegWrite_out_3 <= prif.RegWrite_in_3;
	 
	 // deleted dREN
	 prif.halt_or_out_3 <= prif.halt_or_in_3;

	 prif.j_out_3 <= prif.j_in_3;
	 prif.jal_out_3 <= prif.jal_in_3;
	 prif.JR_out_3 <= prif.JR_in_3;
	 prif.bne_out_3 <= prif.bne_in_3;
	 prif.beq_out_3 <= prif.beq_in_3;
	 // deleted memtoreg	 
	 prif.atomic_out_2 <= prif.atomic_in_2;
	 prif.atomic_out_3 <= prif.atomic_in_3;
	 
      end // else: !if(nRST == 0)
      
     
   end // always_ff @ (posedge CLK, negedge nRST)


   always_ff @ (posedge CLK, negedge nRST)
     begin
	if (nRST == 0) 
	  begin
	     prif.jumpAddr_out_3 <= 0;

	     
	     prif.zero_out_3 <= 0;
	     prif.ALUout_out_3 <= 0;
	     prif.dmemstore_out_3 <= 0;
	     prif.pc_4_out_3 <= 0;
	     prif.pc_imm_out_3 <= 0;
	     prif.wsel_out_3 <= 0;
	     prif.RegWrite_out_4 <= 0;
	     prif.halt_or_out_4 <= 0;
	     prif.jal_out_4 <= 0;
	     prif.MemtoReg_out_4 <= 0;
	     prif.pc_4_out_4 <= 0;
	     // prif.pc_branch_out_4 <= 0;
	     prif.dmemload_out_4 <= 0;
	     prif.ALUout_out_4 <= 0;
	     prif.wsel_out_4 <= 0;

	     prif.rdat1_out_3 <= 0;

	     prif.lwForwardA_out_2 <= 0;


	     prif.lwForwardB_out_2 <= 0;

	     prif.dREN_out_3 <= 0;
	     prif.MemtoReg_out_3 <= 0;
	     
	  end // if (nRST == 0)
	else if (prif.enable == 1)
	  begin
	     // third register
	     prif.jumpAddr_out_3 <= prif.jumpAddr_in_3;

	     prif.zero_out_3 <= prif.zero_in_3;
	     prif.ALUout_out_3 <= prif.ALUout_in_3;
	     prif.dmemstore_out_3 <= prif.dmemstore_in_3;
	     prif.pc_4_out_3 <= prif.pc_4_in_3;
	     prif.pc_imm_out_3 <= prif.pc_imm_in_3;
	     prif.wsel_out_3 <= prif.wsel_in_3;
	     // fourth register
	     prif.RegWrite_out_4 <= prif.RegWrite_in_4;
	     prif.halt_or_out_4 <= prif.halt_or_in_4;
	     prif.jal_out_4 <= prif.jal_in_4;
	     prif.MemtoReg_out_4 <= prif.MemtoReg_in_4;
	     prif.pc_4_out_4 <= prif.pc_4_in_4;
	     // prif.pc_branch_out_4 <= prif.pc_branch_in_4;
	     prif.dmemload_out_4 <= prif.dmemload_in_4;
	     prif.ALUout_out_4 <= prif.ALUout_in_4;
	     prif.wsel_out_4 <= prif.wsel_in_4;

	     prif.rdat1_out_3 <= prif.rdat1_in_3;

	     prif.lwForwardA_out_2 <= prif.lwForwardA_in_2;


	     prif.lwForwardB_out_2 <= prif.lwForwardB_in_2;

	     prif.dREN_out_3 <= prif.dREN_in_3;
	     prif.MemtoReg_out_3 <= prif.MemtoReg_in_3;
	  end
     end
   

   

endmodule // pipeline_reg
