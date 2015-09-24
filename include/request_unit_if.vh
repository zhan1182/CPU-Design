
`ifndef REQUEST_UNIT_IF_VH
`define REQUEST_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface request_unit_if;
   // import types
   import cpu_types_pkg::*;

   logic iREN;
   logic dREN;
   logic dWEN;      
   // logic halt;
   
   // logic PC_en;
   logic imemREN;
   logic dmemREN;
   logic dmemWEN;

   // logic ihit;
   logic dhit;   
   
   // request unit ports
   modport ru (
	      input  iREN, dREN, dWEN, dhit,
	      output imemREN, dmemREN, dmemWEN
	      );
   // request unit tb
   modport rutb (
		 input  imemREN, dmemREN, dmemWEN,
		 output iREN, dREN, dWEN, dhit
		 );
endinterface

`endif //  `ifndef REQUEST_UNIT_IF_VH

