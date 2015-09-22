/*
 Zhaoyang Han
 han221@purdue.edu
 
 control unit source code
 */

`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"

module control_unit(
		    control_unit_if.cu cuif
		    );

   import cpu_types_pkg::*;

   always_comb begin
      cuif.MemWR = 0;
      cuif.MemtoReg = 0;
      cuif.RegDst = 0;
      cuif.Jal = 0;
      cuif.J = 0;
      cuif.ALUSrc = 0;
      cuif.shamt = 0;
      cuif.sign_ext = 0; //when?
      cuif.RegWrite = 0;
      cuif.JR = 0;
      cuif.halt = 0;
      cuif.bne = 0;
      cuif.beq = 0;
      cuif.zero_ext = 0;
      cuif.Lui = 0;
      cuif.dREN = 0;
      cuif.dWEN = 0;
      cuif.ALUOP = ALU_SLL;
      
      
      
      
      case(cuif.instr[31:26])
	RTYPE:begin
	   cuif.RegDst = 1;
	   cuif.RegWrite = 1;
	   cuif.shamt = 1;
	   
	   case(cuif.instr[5:0])
	     SLL:begin
		cuif.ALUOP = ALU_SLL;
		cuif.ALUSrc = 1; //do I need this?
		cuif.zero_ext = 1;
	     end
	     SRL:begin
		cuif.ALUOP = ALU_SRL;
		cuif.ALUSrc = 1;
		cuif.zero_ext = 1;
		
		
	     end
	     JR:begin
		cuif.JR = 1;
		
	     end
	     ADD:begin
		// truth table
		cuif.ALUOP = ALU_ADD;
		

	     end
	     ADDU:begin
		cuif.ALUOP = ALU_ADD;

	     end
	     SUB:begin
		// truth table
		cuif.ALUOP = ALU_SUB;
		
	     end
	     SUBU:begin
		cuif.ALUOP = ALU_SUB;

	     end
	     AND:begin
		cuif.ALUOP = ALU_AND;
		

	     end
	     OR:begin
		cuif.ALUOP = ALU_OR;
		

	     end
	     XOR:begin
		cuif.ALUOP = ALU_XOR;
		

	     end
	     NOR:begin
		cuif.ALUOP = ALU_NOR;
		

	     end
	     SLT:begin
		cuif.ALUOP = ALU_SLT;
		

	     end
	     SLTU:begin
		cuif.ALUOP = ALU_SLTU;
		

	     end
	   endcase // case (cuif.instr[5:0])		
	end // case: RTYPE
	
	// jtype
	J:begin
	   cuif.J = 1;
	end
	JAL:begin
	   cuif.Jal = 1;
	   cuif.RegWrite = 1;
	   
	end
	// itype
	BEQ:begin
	   cuif.ALUOP = ALU_SUB;
	   cuif.beq = 1;
	   
	   
	end
	BNE:begin
	   cuif.bne = 1;
	   cuif.ALUOP = ALU_SUB;
	   
	end
	ADDI:begin
	   cuif.RegWrite = 1;
	   cuif.ALUOP = ALU_ADD;
	   cuif.ALUSrc = 1;
	   cuif.sign_ext = 1;
	end
	ADDIU:begin
	   cuif.RegWrite = 1;
	   cuif.ALUOP = ALU_ADD;
	   
	   cuif.ALUSrc = 1;
	   cuif.sign_ext = 1;
	end
	SLTI:begin
	   cuif.ALUSrc = 1;
	   cuif.sign_ext = 1;
	   cuif.ALUOP = ALU_SLT;
	   //?
	   cuif.RegWrite = 1;
	   
	end
	SLTIU:begin
	   cuif.ALUSrc = 1;
	   cuif.sign_ext = 1;
	   cuif.ALUOP = ALU_SLT;
	   //?
	   cuif.RegWrite = 1;
	   
	end
	ANDI:begin
	   cuif.ALUOP = ALU_AND;
	   cuif.zero_ext = 1;
	   cuif.ALUSrc = 1;
	   cuif.RegWrite = 1;
	   
	   
	end
	ORI:begin
	   cuif.ALUSrc = 1;
	   cuif.RegWrite = 1;
	   cuif.ALUOP = ALU_OR;
	   cuif.zero_ext = 1;
	   
	   
	   
	end
	XORI:begin
	   cuif.ALUOP = ALU_XOR;
	   cuif.ALUSrc = 1;
	   cuif.RegWrite = 1;
	   cuif.zero_ext = 1;
	   

	   
	end
	LUI:begin
	   cuif.Lui = 1;
	   cuif.RegWrite = 1;
	   cuif.ALUSrc = 1;
	   cuif.ALUOP = ALU_ADD;
	   
	   
	end
	LW:begin
	   cuif.MemtoReg = 1;
	   cuif.ALUSrc = 1;
	   cuif.sign_ext = 1;
	   cuif.RegWrite = 1;
	   cuif.ALUOP = ALU_ADD;
	   cuif.dREN = 1;
	   
	   
	   
	end
	SW:begin
	   cuif.MemWR = 1;
	   cuif.ALUSrc = 1;
	   cuif.sign_ext = 1;
	   cuif.ALUOP = ALU_ADD;
	   cuif.dWEN = 1;
	   
	   

	end
	HALT:begin
	   cuif.halt = 1;
	   
	end
      endcase // case (cuif.instr[31:26])
      if (cuif.overf == 1)begin
	 //halt behavior
	 if (cuif.instr[31:26] == 0 && cuif.instr[5:0] != ADDU && cuif.instr[5:0] != SUBU)begin
	    cuif.halt = 1;
	    
	 end
	 if (cuif.instr[31:26] != ADDIU && cuif.instr[31:26] != SLTIU)begin
	    cuif.halt = 1;
	 end
	 
      end
      
   end
endmodule // control_unit
