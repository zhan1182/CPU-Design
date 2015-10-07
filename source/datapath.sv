/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"
`include "control_unit_if.vh"
`include "register_file_if.vh"
`include "alu_if.vh"
`include "pipeline_reg_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"



/////////////// NEW ADDED: Hazard Unit 9/29/2015 ///////////////////////
`include "hazard_if.vh"





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
   word_t pc_4;
   word_t pc_imm;

   /////////////// NEW ADDED: Move pc updated to MEM stage 9/29/2015 ///////////////////////
   word_t pc_final;
   logic      BRJ;// Signal to judge jump or pc + 4
   
   
   // branch tmp
   word_t imm_tmp_shift2;
   logic      branch_eq, branch_go;
   
   
   // Halt tmp
   // logic      halt, next_halt;

   // overflow signal
   logic      overflow;   
      
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
   


   /////////////// NEW ADDED: Hazard Unit 9/29/2015 ///////////////////////
   logic [1:0] 	forwardA, forwardB;
   word_t tempA, tempB; // for line 320



   
   // Load interface
   control_unit_if cu_if();
   alu_if alu_if();
   register_file_if rf_if();
   pipeline_reg_if pr_if();
   
   /////////////// NEW ADDED: Hazard Unit 9/29/2015 ///////////////////////
   hazard_if hiif();
   
   // Connect modules
   control_unit CU(cu_if);
   alu ALU(alu_if);
   register_file RF(CLK, nRST, rf_if);   
   // Add pipeline reg module here
   pipeline_reg PR(CLK, nRST, pr_if);
   
   /////////////// NEW ADDED: Hazard Unit 9/29/2015 ///////////////////////

   hazard HI(hiif);
   


   
   /***************************************************************************/
   // Assign datapath instruction read enable to 1
   assign dpif.imemREN = cu_if.iREN;
   
   
   /***************************************************************************/

   assign pr_if.dhit = dpif.dhit; // added dhit
   
   
   // Connect stage 1, fetch
   // Intruction from cache (dpif.imemload)
   assign pr_if.instr_in_1 = dpif.imemload;
   assign pr_if.pc_4_in_1 = pc_4;


   /***************************************************************************/
   
   // Connect stage 2, Decode
   // Connect control unit input signals
   assign cu_if.instruction = pr_if.instr_out_1;
   assign pr_if.RegWrite_in_2 = cu_if.WEN;
   assign pr_if.dWEN_in_2 = cu_if.dWEN;
   assign pr_if.dREN_in_2 = cu_if.dREN;
   assign pr_if.halt_in_2 = cu_if.halt;
   assign pr_if.overflow_flag_in_2 = cu_if.overflow_flag;
   assign pr_if.Lui_in_2 = cu_if.lui;
   assign pr_if.jal_in_2 = cu_if.jal;
   assign pr_if.j_in_2 = cu_if.j;
   assign pr_if.JR_in_2 = cu_if.jr;
   assign pr_if.bne_in_2 = cu_if.bne;
   assign pr_if.sign_ext_in_2 = cu_if.sign_ext;
   assign pr_if.shamt_flag_in_2 = cu_if.shamt_en;
   assign pr_if.ALUSrc_in_2 = cu_if.ALUSrc;
   assign pr_if.beq_in_2 = cu_if.PCSrc;
   assign pr_if.RegDst_in_2 = cu_if.RegDest;
   assign pr_if.ALUOP_in_2 = cu_if.ALUcode;
   assign pr_if.MemtoReg_in_2 = cu_if.MemReg;
   
   // Conncet register file
   assign rf_if.rsel1 = pr_if.instr_out_1[25:21];
   assign rf_if.rsel2 = pr_if.instr_out_1[20:16];
   assign pr_if.rdat1_in_2 = rf_if.rdat1;
   assign pr_if.rdat2_in_2 = rf_if.rdat2;
   // assign pr_if.JRaddr_in_2 = rf_if.rdat1;Use rdat1_in_3 instead
   // Going through signals
   assign pr_if.rt_in_2 = pr_if.instr_out_1[20:16];
   assign pr_if.rd_in_2 = pr_if.instr_out_1[15:11];
   assign pr_if.rs_in_2 = pr_if.instr_out_1[25:21];
   
   assign pr_if.imm_in_2 = pr_if.instr_out_1[15:0];
   assign pr_if.shamt_in_2 = pr_if.instr_out_1[10:6];
   assign pr_if.pc_4_in_2 = pr_if.pc_4_out_1; // Not added yet
   
   // assign cu_if.overflow = alu_if.overflow; // Need to change control unit module
   // assign rf_if.WEN = cu_if.WEN; // Change
   // assign rf_if.wsel = (cu_if.jal == 1) ? 5'b11111 : wsel_tmp; // Change
   // assign wsel_tmp = (cu_if.RegDest == 1) ? instr[20:16]:instr[15:11]; // Move the stage 2


   /***************************************************************************/
   
   // Connect stage 3, Execute
   //assign alu_if.portA = (pr_if.Lui_out_2 == 1) ? 32'h00000000:pr_if.rdat1_out_2;
   //assign alu_if.portB = (pr_if.ALUSrc_out_2 == 1) ? pr_if.rdat2_out_2 : imm_tmp;
   assign alu_if.aluop = aluop_t'(pr_if.ALUOP_out_2);

   // Calculate zero/sign extension
   assign unext_tmp = (pr_if.shamt_flag_out_2 == 1) ? pr_if.imm_out_2:{11'b0, pr_if.shamt_out_2}; //used shamt, should use shamt_flag
   assign signext_tmp = (unext_tmp[15] == 1) ? {16'hffff, unext_tmp}:{16'h0000, unext_tmp};
   assign zeroext_tmp = {16'h0000, unext_tmp};
   assign ext_tmp = (pr_if.sign_ext_out_2 == 1) ? signext_tmp:zeroext_tmp;
   assign imm_tmp = (pr_if.Lui_out_2 == 1) ? {unext_tmp, 16'h0000}: ext_tmp;

   // Calculate register wsel
   assign wsel_tmp = (pr_if.RegDst_out_2 == 1) ? pr_if.rt_out_2: pr_if.rd_out_2;
   assign pr_if.wsel_in_3 = (pr_if.jal_out_2 == 1) ? 5'b11111 : wsel_tmp;

   // Calculate branch addr
   assign imm_tmp_shift2 = imm_tmp << 2;
   assign pc_imm = pr_if.pc_4_out_2 + imm_tmp_shift2;
   assign pr_if.pc_imm_in_3 = pc_imm;
   
   // Connect alu output
   assign pr_if.zero_in_3 = alu_if.zero;
   assign pr_if.ALUout_in_3 = alu_if.output_port;
   // assign pr_if.dmemstore_in_3 = pr_if.rdat2_out_2; // Add a new mux here

   // Determine overflow logic
   assign overflow = pr_if.overflow_flag_out_2 & alu_if.overflow;
   assign pr_if.halt_or_in_3 = overflow | pr_if.halt_out_2;   
   
   // Connect going through signals
   assign pr_if.RegWrite_in_3 = pr_if.RegWrite_out_2;
   assign pr_if.dWEN_in_3 = pr_if.dWEN_out_2;
   assign pr_if.dREN_in_3 = pr_if.dREN_out_2;
   assign pr_if.jal_in_3 = pr_if.jal_out_2;
   assign pr_if.bne_in_3 = pr_if.bne_out_2;
   assign pr_if.beq_in_3 = pr_if.beq_out_2;
   assign pr_if.MemtoReg_in_3 = pr_if.MemtoReg_out_2;
   assign pr_if.pc_4_in_3 = pr_if.pc_4_out_2;

   /***************************************************************************/

   // Connect stage 4, MEM
   // Connect interface with datapath output (TO/FROM RAM)
   // Write to ram
   assign dpif.dmemaddr = pr_if.ALUout_out_3;
   assign dpif.dmemstore = pr_if.dmemstore_out_3;
   // Read from ram
   assign pr_if.dmemload_in_4 = dpif.dmemload;
   // Send out ram enables
   assign dpif.dmemREN = pr_if.dREN_out_3;
   assign dpif.dmemWEN = pr_if.dWEN_out_3;

   // Determine branch
   assign branch_eq = pr_if.zero_out_3 & pr_if.beq_out_3;
   assign branch_go = (pr_if.bne_out_3) ? (~branch_eq) : branch_eq;
   // assign pc_4_branch_out_3 = (branch_go) ? pr_if.pc_imm_out_3 : pr_if.pc_4_out_3; // Assign a local variable
   

   // Connect going through signals
   assign pr_if.RegWrite_in_4 = pr_if.RegWrite_out_3;
   assign pr_if.halt_or_in_4 = pr_if.halt_or_out_3;
   assign pr_if.jal_in_4 = pr_if.jal_out_3;
   assign pr_if.MemtoReg_in_4 = pr_if.MemtoReg_out_3;
   assign pr_if.pc_4_in_4 = pr_if.pc_4_out_3;
   assign pr_if.ALUout_in_4 = pr_if.ALUout_out_3;
   assign pr_if.wsel_in_4 = pr_if.wsel_out_3;
   

   /***************************************************************************/

   // Connect stage 5, Write Back

   // Connect Halt signal out from datapath to cache
   assign dpif.halt = pr_if.halt_or_out_4;
   
   // Connect write back signals
   assign rf_if.WEN = pr_if.RegWrite_out_4;
   assign rf_if.wsel = pr_if.wsel_out_4;

   // Calculate the write back data
   assign wdat_tmp = (pr_if.MemtoReg_out_4) ? pr_if.dmemload_out_4 : pr_if.ALUout_out_4;
   assign rf_if.wdat = (pr_if.jal_out_4) ? pr_if.pc_4_out_4 : wdat_tmp;

   // Connect instruction addr
   assign dpif.imemaddr = pc;
   
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
   // assign next_pc = pc_4;
   
   // assign pc_j = {pc_4[31:28], instr[25:0], 2'b00};
   // assign pc_jr = rf_if.rdat1;
   
   // assign pc_4_branch = (branch_go) ? pc_imm : pc_4;
   // // assign next_pc = (cu_if.jr & (~cu_if.j) ) ? pc_jr : (cu_if.j | cu_if.jal) ? pc_j : pc_4_branch;//add ~j
   
   
   // always_ff @ (posedge CLK, negedge nRST)
   //   begin
   // 	if(nRST == 1'b0)
   // 	  begin
   // 	     halt <= 1'b0;
   // 	  end
   // 	else
   // 	  begin
   // 	     halt = next_halt;
   // 	  end
   //   end

   // assign next_halt = cu_if.halt;
   

   /////////////// NEW ADDED: Hazard Unit 9/29/2015 ///////////////////////
   //assign hiif.instr_out_1 = pr_if.instr_out_1;
   assign hiif.wsel_out_3 = pr_if.wsel_out_3;
   assign hiif.wsel_out_4 = pr_if.wsel_out_4;
   assign hiif.RegWrite_out_3 = pr_if.RegWrite_out_3;
   assign hiif.RegWrite_out_4 = pr_if.RegWrite_out_4;
   assign hiif.rt_out_2 = pr_if.rt_out_2;
   assign hiif.rs_out_2 = pr_if.rs_out_2;

   assign hiif.dWEN_out_2 = pr_if.dWEN_out_2;
   assign hiif.dREN_out_2 = pr_if.dREN_out_2;
   assign hiif.rs_in_2 = pr_if.rs_in_2;
   assign hiif.rt_in_2 = pr_if.rt_in_2;
   


   assign forwardA = hiif.forwardA;
   assign forwardB = hiif.forwardB;
   
   // line 165, 166 are commented, new code is here
   assign alu_if.portA = (pr_if.Lui_out_2 == 1) ? 32'h00000000:tempA;
   assign alu_if.portB = (pr_if.ALUSrc_out_2 == 1) ? tempB : imm_tmp; 

   always_comb begin
      tempA = pr_if.rdat1_out_2;
      tempB = pr_if.rdat2_out_2;
      
      if (forwardA == 2'b01) begin
	 tempA = rf_if.wdat;
      end
      if (forwardB == 2'b01) begin
	 tempB = rf_if.wdat;
      end
      if(forwardA == 2'b10) begin
	 tempA = pr_if.ALUout_out_3;
      end
      if(forwardB == 2'b10) begin
	 tempB = pr_if.ALUout_out_3;
      end
      if (pr_if.lwForwardA_out_2 == 1) begin
	 tempA = pr_if.dmemload_in_4;
      end
      if (pr_if.lwForwardB_out_2 == 1) begin
	 tempB = pr_if.dmemload_in_4;
      end
      
   end // always_comb


   // Line 189 commented out
   assign pr_if.dmemstore_in_3 = (hiif.forwardC) ? pr_if.ALUout_out_3 : ((hiif.forwardD) ? pr_if.ALUout_out_4 : pr_if.rdat2_out_2);
   

   // New added pipeline register signals here
   assign pr_if.jumpAddr_in_2 = pr_if.instr_out_1[25:0];
   assign pr_if.jumpAddr_in_3 = pr_if.jumpAddr_out_2;
   assign pr_if.j_in_3 = pr_if.j_out_2;
   assign pr_if.JR_in_3 = pr_if.JR_out_2;
   assign pr_if.rdat1_in_3 = pr_if.rdat1_out_2;// JR addr
   
   // Combinational block to determine jump or not
   // BRJ is the output control signal
   always_comb
     begin
   	pc_final = 0;
	BRJ = 0;
	
   	if (pr_if.j_out_3 | pr_if.jal_out_3)
   	  begin
	     // Calculate pc jump addr
   	     pc_final = {pr_if.pc_4_out_3[31:28], pr_if.jumpAddr_out_3, 2'b00};
	     BRJ = 1;
   	  end
   	else if(pr_if.JR_out_3)
   	  begin
   	     pc_final = pr_if.rdat1_out_3;// JR addr
	     BRJ = 1;
   	  end
	else if(branch_go)
	  begin
	     pc_final = pr_if.pc_imm_out_3;// Branch address
	     BRJ = 1;
	  end
     end // always_comb
   
   // Assign the next pc
   assign next_pc = (BRJ) ? pc_final : pc_4;
   
   // Connet to the pipeline register, flush the first and second register
   assign pr_if.flush = BRJ;
 //|| hiif.lwForwardA || hiif.lwForwardB; // new added for lab7

   // assign the new added signal lwStall in pipe reg
   assign pr_if.lwForwardA_in_2 = hiif.lwForwardA;


   assign pr_if.lwForwardB_in_2 = hiif.lwForwardB;


   // for solve lw + sw
   assign hiif.dREN_out_3 = pr_if.dREN_out_3;
   

   
endmodule
