`include "control_unit_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module control_unit
(
 control_unit_if.cu cu_if
);

   r_t instr;
   assign instr = r_t'(cu_if.instruction);
   
   always_comb
     begin
	// Signals to datapath
	cu_if.sign_ext = 0;	
	cu_if.j = 0;
	cu_if.jr = 0;
	cu_if.jal = 0;
	cu_if.lui = 0;
	cu_if.shamt_en = 0;
	cu_if.ALUSrc = 0;
	cu_if.PCSrc = 0; // beq
	cu_if.RegDest = 0;
	cu_if.MemReg = 0;
	// cu_if.RegWrite = 0;
	cu_if.bne = 0;
	// Write enable for the register file
	cu_if.WEN = 1;	

	// Signals to requist unit
	cu_if.halt = 0;
	cu_if.iREN = 1;
	cu_if.dREN = 0;
	cu_if.dWEN = 0;

	// Initialize ALU code
	cu_if.ALUcode = ALU_SLL;

	// overflow flag
	cu_if.overflow_flag = 0;
	cu_if.atomic = 0;
	
	
	casez(instr.opcode)
	  RTYPE:
	    begin
	       // Choose rdata 2 to feed into ALU porB
	       cu_if.ALUSrc = 1;
	       
	       casez(instr.funct)
		 SLL:
		   begin
		      cu_if.ALUcode = ALU_SLL;
		      // Choose shamt to feed into ALU porB
		      cu_if.ALUSrc = 0;
		   end
		 SRL:
		   begin
		      cu_if.ALUcode = ALU_SRL;
		      // Choose shamt to feed into ALU porB
		      cu_if.ALUSrc = 0;
		   end
		 JR:
		   begin
		      cu_if.WEN = 0;
		      cu_if.jr = 1;
		   end
		 ADD:
		   begin
		      cu_if.ALUcode = ALU_ADD;
		      cu_if.overflow_flag = 1;
		   end
		 ADDU:
		   begin
		      cu_if.ALUcode = ALU_ADD;
		   end
		 SUB:
		   begin
		      cu_if.ALUcode = ALU_SUB;
		      cu_if.overflow_flag = 1;
		   end
		 SUBU:
		   begin
		      cu_if.ALUcode = ALU_SUB;
		   end
		 AND:
		   begin
		      cu_if.ALUcode = ALU_AND;
		   end
		 OR:
		   begin
		      cu_if.ALUcode = ALU_OR;
		   end
		 XOR:
		   begin
		      cu_if.ALUcode = ALU_XOR;
		   end
		 NOR:
		   begin
		      cu_if.ALUcode = ALU_NOR;
		   end
		 SLT:
		   begin
		      cu_if.ALUcode = ALU_SLT;
		   end
		 SLTU:
		   begin
		      cu_if.ALUcode = ALU_SLTU;
		   end
	       endcase // casez (instr.funct)
	       
	    end
	  J:
	    begin
	       // disable register write enable
	       cu_if.WEN = 0;
	       cu_if.j = 1;
	    end
	  JAL:
	    begin
	       cu_if.jal = 1;
	    end
	  BEQ:// sign ext
	    begin
	       // disable register write enable
	       cu_if.WEN = 0;
	       cu_if.PCSrc = 1;
	       cu_if.ALUcode = ALU_SUB;
	       // halt if overflow
	       cu_if.overflow_flag = 1;
	       
	       // use imm
	       cu_if.shamt_en = 1;
	       // sign ext
	       cu_if.sign_ext = 1;

	       // use rdat2
	       cu_if.ALUSrc = 1;
	       
	       
	    end
	  BNE:
	    begin
	       // disable register write enable
	       cu_if.WEN = 0;
	       cu_if.PCSrc = 1;
	       cu_if.ALUcode = ALU_SUB;
	       // halt if overflow
	       cu_if.overflow_flag = 1;
	       // cu_if.halt = (cu_if.overflow == 1) ? 1:0;
	       
	       // use imm
	       cu_if.shamt_en = 1;
	       // bne
	       cu_if.bne = 1;
	       // sign ext
	       cu_if.sign_ext = 1;

	       cu_if.ALUSrc = 1;
	    end
	  ADDI:
	    begin
	       // Sign ext
	       cu_if.sign_ext = 1;
	       // use imm
	       cu_if.shamt_en = 1;
	       cu_if.RegDest = 1;  // Chose rt instead of rd
	       cu_if.ALUcode = ALU_ADD;
	       // insert halt if overflow happens
	       cu_if.overflow_flag = 1;
	       // cu_if.halt = (cu_if.overflow == 1) ? 1:0;
	    end
	  ADDIU:
	    begin
	       // sign ext
	       cu_if.sign_ext = 1;
	       // use imm
	       cu_if.shamt_en = 1;
	       cu_if.RegDest = 1;
	       cu_if.ALUcode = ALU_ADD;
	    end
	  SLTI:
	    begin
	       // sign ext
	       cu_if.sign_ext = 1;
	       cu_if.RegDest = 1;
	       // use imm
	       cu_if.shamt_en = 1;
	       cu_if.ALUcode = ALU_SLT;
	    end
	  SLTIU:
	    begin
	       // sign ext
	       cu_if.sign_ext = 1;
	       cu_if.RegDest = 1;
	       cu_if.shamt_en = 1;
	       cu_if.ALUcode = ALU_SLTU;// deleted U here
	    end
	  ANDI:
	    begin
	       // zero extension
	       cu_if.RegDest = 1;
	       cu_if.shamt_en = 1;
	       cu_if.ALUcode = ALU_AND;
	    end
	  ORI:
	    begin
	       // zero ext
	       cu_if.RegDest = 1;
	       cu_if.shamt_en = 1;
	       cu_if.ALUcode = ALU_OR;
	    end
	  XORI:
	    begin
	       // Zero extention
	       cu_if.RegDest = 1;
	       cu_if.shamt_en = 1;
	       cu_if.ALUcode = ALU_XOR;
	    end
	  LUI:
	    begin
	       cu_if.lui = 1;
	       // rt as destination
	       cu_if.RegDest = 1;
	       // cu_if.go_through = 1;
	       cu_if.ALUcode = ALU_ADD;
	       cu_if.shamt_en = 1;	       
	    end
	  LW:
	    begin
	       // sign ext
	       cu_if.sign_ext = 1;
	       // alu calculates the addr for ram
	       cu_if.ALUcode = ALU_ADD;
	       // halt if overflow happens
	       cu_if.overflow_flag = 1;
	       // cu_if.halt = (cu_if.overflow == 1) ? 1:0;
	       
	       cu_if.RegDest = 1;
	       // Choose the data from ram
	       cu_if.MemReg = 1;
	       // Use imm
	       cu_if.shamt_en = 1;
	       // Enable ram data read
	       cu_if.dREN = 1;
	       
	    end
	  LBU:// Not found
	    begin
	       // disable register write enable
	       cu_if.WEN = 0;
	    end
	  LHU:// Not found
	    begin
	       // disable register write enable
	       cu_if.WEN = 0;
	    end
	  SB:// Not found
	    begin
	       // disable register write enable
	       cu_if.WEN = 0;
	    end
	  SH:// Not found
	    begin
	       // disable register write enable
	       cu_if.WEN = 0;
	    end
	  SW:
	    begin
	       // disable register write enable
	       cu_if.WEN = 0;
	       // sign ext
	       cu_if.sign_ext = 1;
	       // alu calculates the addr for ram
	       cu_if.ALUcode = ALU_ADD;
	       // halt if overflow happens
	       cu_if.overflow_flag = 1;
	       // cu_if.halt = (cu_if.overflow == 1) ? 1:0;
	       
	       // cu_if.RegDest = 1;
	       // Enable ram data write
	       cu_if.dWEN = 1;
	       // use imm
	       cu_if.shamt_en = 1;
	    end
	  LL:// No need
	    begin

	       // sign ext
	       cu_if.sign_ext = 1;
	       // alu calculates the addr for ram
	       cu_if.ALUcode = ALU_ADD;
	       // halt if overflow happens
	       cu_if.overflow_flag = 1;
	       // cu_if.halt = (cu_if.overflow == 1) ? 1:0;
	       
	       cu_if.RegDest = 1;
	       // Choose the data from ram
	       cu_if.MemReg = 1;
	       // Use imm
	       cu_if.shamt_en = 1;
	       // Enable ram data read
	       cu_if.dREN = 1;
	       // disable register write enable

	       cu_if.atomic = 1;
	       
	       
	    end
	  SC:// No need
	    begin
	       cu_if.WEN = 0;
	       // sign ext
	       cu_if.sign_ext = 1;
	       // alu calculates the addr for ram
	       cu_if.ALUcode = ALU_ADD;
	       // halt if overflow happens
	       cu_if.overflow_flag = 1;
	       // cu_if.halt = (cu_if.overflow == 1) ? 1:0;
	       
	       // cu_if.RegDest = 1;
	       // Enable ram data write
	       cu_if.dWEN = 1;
	       // use imm
	       cu_if.shamt_en = 1;
	       cu_if.atomic = 1;
	       
	    end
	  HALT:
	    begin
	       // disable register write enable
	       cu_if.WEN = 0;
	       cu_if.halt = 1;
	    end
	  
	endcase // casez (instruction[31:26])
	


	
     end // always_comb begin
   
   
endmodule
