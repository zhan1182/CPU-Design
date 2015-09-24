
`include "cpu_types_pkg.vh"
`include "alu_if.vh"
import cpu_types_pkg::*;

module alu
(
 alu_if.alu_port aluport
);
  
always_comb
  begin

     aluport.overflow = 0;
     
     case(aluport.aluop)
	  
       ALU_SLL:
	 begin
	    aluport.output_port = aluport.portA << aluport.portB[5:0];
	 end
       ALU_SRL:
	 begin
	    aluport.output_port = aluport.portA >> aluport.portB[5:0];
	 end
       ALU_ADD:
	 begin
	    aluport.output_port = $signed (aluport.portA) + $signed (aluport.portB);
	    aluport.overflow = (aluport.portA[31] == aluport.portB[31]) ? (aluport.output_port[31] != aluport.portB[31]):0;
	 end
       ALU_SUB:
	 begin
	    aluport.output_port = $signed (aluport.portA) - $signed (aluport.portB);
	    aluport.overflow = (aluport.portA[31] != aluport.portB[31]) ? (aluport.output_port[31] == aluport.portB[31]):0;
	 end
       ALU_AND:
	 begin
	    aluport.output_port = aluport.portA & aluport.portB;
	 end
       ALU_OR:
	 begin
	    aluport.output_port = aluport.portA | aluport.portB;
	 end
       ALU_XOR:
      	 begin
	    aluport.output_port = aluport.portA ^ aluport.portB;
	 end
       ALU_NOR:
      	 begin
	    aluport.output_port = ~(aluport.portA | aluport.portB);
	 end
       ALU_SLT:
      	 begin
	    aluport.output_port = ($signed (aluport.portA) < $signed (aluport.portB)) ? 1:0;
	 end
       ALU_SLTU:
	 begin
	    aluport.output_port = (aluport.portA < aluport.portB) ? 1:0;	    
	 end
       
     endcase
     
  end // always_comb

   assign aluport.negative = aluport.output_port[31];
   assign aluport.zero = (aluport.output_port == 0) ? 1:0;
   
   

endmodule
