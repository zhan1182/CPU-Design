/*
 Zhaoyang Han
 han221@purdue.edu
 
 Request Unit Interface
 */
`ifndef REQUEST_UNIT_IF_VH
 `define REQUEST_UNIT_IF_VH

 `include "cpu_types_pkg.vh"

interface request_unit_if;
   import cpu_types_pkg::*;

   logic ihit, dhit, imemREN, dmemREN, dmemWEN, dREN, dWEN;
   
   
   

   modport ru (
	       input ihit, dhit, dREN, dWEN,
	       output imemREN, dmemREN, dmemWEN
	       );

   modport tb (
	       input imemREN, dmemREN, dmemWEN,
	       output ihit, dhit, dREN, dWEN
	       );

endinterface // request_unit_if
`endif //  `ifndef REQUEST_UNIT_IF_VH

