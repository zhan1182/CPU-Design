/*
 Zhaoyang Han
 han221@purdue.edu
 
 Lab1 alu
*/

`include "alu_if.vh"
`include "cpu_types_pkg.vh"

module alu(
	   alu_if.aluif aluif
	   );
   import cpu_types_pkg::*;


   assign aluif.zero = (aluif.out == 0) ? 1:0;
   assign aluif.negative = (aluif.out[31] == 1) ? 1:0;
   
   
   always_comb begin
      aluif.overflow = 0;
      
      case(aluif.ALUOP)
    ALU_SLL:begin
	aluif.out = aluif.porta << aluif.portb;
    end

    ALU_SRL:begin
	aluif.out = aluif.porta >> aluif.portb;
    end
	
    ALU_ADD:begin
	aluif.out = $signed(aluif.porta) + $signed(aluif.portb);
       if(aluif.porta[31] == 1 && aluif.porta[31] == aluif.portb[31] && aluif.out[31] == 0)begin
	  aluif.overflow = 1;
       end
       if(aluif.porta[31] == 0 && aluif.porta[31] == aluif.portb[31] && aluif.out[31] == 1)begin
	  aluif.overflow = 1;
       end
       
    end
	
    ALU_SUB:begin
       aluif.out = $signed(aluif.porta) - $signed(aluif.portb);
       
       if(aluif.porta[31] == 0 && aluif.porta[31] == 1 && aluif.out[31] == 1)begin
	  aluif.overflow = 1;
       end
       if(aluif.porta[31] == 1 && aluif.porta[31] == 0 && aluif.out[31] == 0)begin
	  aluif.overflow = 1;

       end
       
    end
	
    ALU_AND:begin
       aluif.out = aluif.porta & aluif.portb;
       
    end
	
    ALU_OR:begin
       aluif.out = aluif.porta | aluif.portb;
       
    end
	
    ALU_XOR:begin
       aluif.out = aluif.porta ^ aluif.portb;
       
    end
	
    ALU_NOR:begin
       aluif.out = ~(aluif.porta | aluif.portb);
       
    end
	
    ALU_SLT:begin
       aluif.out = $signed(aluif.porta) < $signed(aluif.portb);
       
    end
	
    ALU_SLTU:begin
       aluif.out = aluif.porta < aluif.portb;
    end
	
    endcase
	
   end // always_comb
endmodule // alu

   
