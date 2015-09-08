
// interface
`include "alu_if.vh"
`include "cpu_types_pkg.vh"

module alu_fpga (
  input logic CLOCK_50,
  input logic [3:0] KEY,
  input logic [17:0] SW,
  output logic [6:0]HEX0,
  output logic [6:0]HEX1,
  output logic [6:0]HEX2,		 
  output logic [6:0]HEX3,
  output logic [6:0]HEX4,
  output logic [6:0]HEX5,
  output logic [6:0]HEX6,
  output logic [6:0]HEX7,
  output logic [17:0] LEDR
);

   import cpu_types_pkg::*;
   
   // interface
   alu_if aluif();
   // rf
   alu ALU(aluif);

   logic toggle;
   
   assign aluif.aluop = aluop_t'(~KEY[3:0]);
   assign aluif.portA = {{16{SW[16]}}, SW[15:0]};
   assign LEDR[3:0] = aluif.portA[3:0];
   assign LEDR[7:4] = aluif.portB[3:0];
   assign LEDR[11:8] = aluif.output_port[3:0];
   
   assign toggle = SW[17];
   
   always_ff @ (posedge toggle)
     begin
	aluif.portB <= aluif.portA;
     end

   always_comb
     begin
	unique casez (aluif.output_port[3:0])
	  'h0: HEX0 = 7'b1000000;
	  'h1: HEX0 = 7'b1111001;
	  'h2: HEX0 = 7'b0100100;
	  'h3: HEX0 = 7'b0110000;
	  'h4: HEX0 = 7'b0011001;
	  'h5: HEX0 = 7'b0010010;
	  'h6: HEX0 = 7'b0000010;
	  'h7: HEX0 = 7'b1111000;
	  'h8: HEX0 = 7'b0000000;
	  'h9: HEX0 = 7'b0010000;
	  'ha: HEX0 = 7'b0001000;
	  'hb: HEX0 = 7'b0000011;
	  'hc: HEX0 = 7'b0100111;
	  'hd: HEX0 = 7'b0100001;
	  'he: HEX0 = 7'b0000110;
	  'hf: HEX0 = 7'b0001110;
	endcase
	unique casez (aluif.output_port[7:4])
	  'h0: HEX1 = 7'b1000000;
	  'h1: HEX1 = 7'b1111001;
	  'h2: HEX1 = 7'b0100100;
	  'h3: HEX1 = 7'b0110000;
	  'h4: HEX1 = 7'b0011001;
	  'h5: HEX1 = 7'b0010010;
	  'h6: HEX1 = 7'b0000010;
	  'h7: HEX1 = 7'b1111000;
	  'h8: HEX1 = 7'b0000000;
	  'h9: HEX1 = 7'b0010000;
	  'ha: HEX1 = 7'b0001000;
	  'hb: HEX1 = 7'b0000011;
	  'hc: HEX1 = 7'b0100111;
	  'hd: HEX1 = 7'b0100001;
	  'he: HEX1 = 7'b0000110;
	  'hf: HEX1 = 7'b0001110;
	endcase

	unique casez (aluif.output_port[11:8])
	  'h0: HEX2 = 7'b1000000;
	  'h1: HEX2 = 7'b1111001;
	  'h2: HEX2 = 7'b0100100;
	  'h3: HEX2 = 7'b0110000;
	  'h4: HEX2 = 7'b0011001;
	  'h5: HEX2 = 7'b0010010;
	  'h6: HEX2 = 7'b0000010;
	  'h7: HEX2 = 7'b1111000;
	  'h8: HEX2 = 7'b0000000;
	  'h9: HEX2 = 7'b0010000;
	  'ha: HEX2 = 7'b0001000;
	  'hb: HEX2 = 7'b0000011;
	  'hc: HEX2 = 7'b0100111;
	  'hd: HEX2 = 7'b0100001;
	  'he: HEX2 = 7'b0000110;
	  'hf: HEX2 = 7'b0001110;
	endcase

	unique casez (aluif.output_port[15:12])
	  'h0: HEX3 = 7'b1000000;
	  'h1: HEX3 = 7'b1111001;
	  'h2: HEX3 = 7'b0100100;
	  'h3: HEX3 = 7'b0110000;
	  'h4: HEX3 = 7'b0011001;
	  'h5: HEX3 = 7'b0010010;
	  'h6: HEX3 = 7'b0000010;
	  'h7: HEX3 = 7'b1111000;
	  'h8: HEX3 = 7'b0000000;
	  'h9: HEX3 = 7'b0010000;
	  'ha: HEX3 = 7'b0001000;
	  'hb: HEX3 = 7'b0000011;
	  'hc: HEX3 = 7'b0100111;
	  'hd: HEX3 = 7'b0100001;
	  'he: HEX3 = 7'b0000110;
	  'hf: HEX3 = 7'b0001110;
	endcase // unique casez (aluif.output_port[15:12])

	unique casez (aluif.output_port[19:16])
	  'h0: HEX4 = 7'b1000000;
	  'h1: HEX4 = 7'b1111001;
	  'h2: HEX4 = 7'b0100100;
	  'h3: HEX4 = 7'b0110000;
	  'h4: HEX4 = 7'b0011001;
	  'h5: HEX4 = 7'b0010010;
	  'h6: HEX4 = 7'b0000010;
	  'h7: HEX4 = 7'b1111000;
	  'h8: HEX4 = 7'b0000000;
	  'h9: HEX4 = 7'b0010000;
	  'ha: HEX4 = 7'b0001000;
	  'hb: HEX4 = 7'b0000011;
	  'hc: HEX4 = 7'b0100111;
	  'hd: HEX4 = 7'b0100001;
	  'he: HEX4 = 7'b0000110;
	  'hf: HEX4 = 7'b0001110;
	endcase // unique casez (aluif.output_port[19:16])

	unique casez (aluif.output_port[23:20])
	  'h0: HEX5 = 7'b1000000;
	  'h1: HEX5 = 7'b1111001;
	  'h2: HEX5 = 7'b0100100;
	  'h3: HEX5 = 7'b0110000;
	  'h4: HEX5 = 7'b0011001;
	  'h5: HEX5 = 7'b0010010;
	  'h6: HEX5 = 7'b0000010;
	  'h7: HEX5 = 7'b1111000;
	  'h8: HEX5 = 7'b0000000;
	  'h9: HEX5 = 7'b0010000;
	  'ha: HEX5 = 7'b0001000;
	  'hb: HEX5 = 7'b0000011;
	  'hc: HEX5 = 7'b0100111;
	  'hd: HEX5 = 7'b0100001;
	  'he: HEX5 = 7'b0000110;
	  'hf: HEX5 = 7'b0001110;
	endcase // unique casez (aluif.output_port[23:20])

	unique casez (aluif.output_port[27:24])
	  'h0: HEX6 = 7'b1000000;
	  'h1: HEX6 = 7'b1111001;
	  'h2: HEX6 = 7'b0100100;
	  'h3: HEX6 = 7'b0110000;
	  'h4: HEX6 = 7'b0011001;
	  'h5: HEX6 = 7'b0010010;
	  'h6: HEX6 = 7'b0000010;
	  'h7: HEX6 = 7'b1111000;
	  'h8: HEX6 = 7'b0000000;
	  'h9: HEX6 = 7'b0010000;
	  'ha: HEX6 = 7'b0001000;
	  'hb: HEX6 = 7'b0000011;
	  'hc: HEX6 = 7'b0100111;
	  'hd: HEX6 = 7'b0100001;
	  'he: HEX6 = 7'b0000110;
	  'hf: HEX6 = 7'b0001110;
	endcase // unique casez (aluif.output_port[27:24])

	unique casez (aluif.output_port[31:28])
	  'h0: HEX7 = 7'b1000000;
	  'h1: HEX7 = 7'b1111001;
	  'h2: HEX7 = 7'b0100100;
	  'h3: HEX7 = 7'b0110000;
	  'h4: HEX7 = 7'b0011001;
	  'h5: HEX7 = 7'b0010010;
	  'h6: HEX7 = 7'b0000010;
	  'h7: HEX7 = 7'b1111000;
	  'h8: HEX7 = 7'b0000000;
	  'h9: HEX7 = 7'b0010000;
	  'ha: HEX7 = 7'b0001000;
	  'hb: HEX7 = 7'b0000011;
	  'hc: HEX7 = 7'b0100111;
	  'hd: HEX7 = 7'b0100001;
	  'he: HEX7 = 7'b0000110;
	  'hf: HEX7 = 7'b0001110;
	endcase
	
     end

     
endmodule
