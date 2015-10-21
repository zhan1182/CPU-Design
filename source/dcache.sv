/*
 Zhaoyang Han & Jinyi Zhang
 han221 & zhan1128
 
 data cache source file
 */

`include "cpu_types_pkg.vh"

module dcache (
	       input logic CLK, nRST,
	       datapath_cache_if dcif,
	       cache_control_if ccif
	       );
   import cpu_types_pkg::*;

   parameter CPUID = 0;

   logic [DTAG_W-1:0] tag;
   logic [DIDX_W-1:0] idx;
   logic [DBLK_W-1:0] blkoff;
   
   logic [DBYT_W-1:0] bytoff;
   logic [15:0][58:0]     curr_cache, next_cache;
   int 			  i;





endmodule // dcache

