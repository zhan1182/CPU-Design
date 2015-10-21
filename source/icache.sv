/*
 Zhaoyang Han & Jinyi Zhang
 han221 & zhan1128
 
 instruction cache source file
 */

`include "cpu_types_pkg.vh"

module icache (
  input logic CLK, nRST,
  datapath_cache_if dcif,
  cache_control_if ccif
);
   import cpu_types_pkg::*;
   
  parameter CPUID = 0;

   //logic      valid;
   logic [ITAG_W-1:0] tag;
   logic [IIDX_W-1:0] idx;
   logic [IBYT_W-1:0] bytoff;
   logic [15:0][58:0]     curr_cache, next_cache;
   int 			  i;
   

   assign tag = dcif.imemaddr[31:31-ITAG_W+1];
   assign idx = dcif.imemaddr[31-ITAG_W:31-ITAG_W-IIDX_W+1];
   assign bytoff = dcif.imemaddr[31-ITAG_W-IIDX_W:0];

   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (nRST == 0) begin
	 for(i = 0; i < 16; i++)begin
	    curr_cache[i] <= 0;
	 end	 
      end
      
      else begin
	 curr_cache <= next_cache;
      end
   end

   assign ccif.iREN = (tag == cache[idx][57:57-ITAG_W+1]) ? 0:dcif.imemREN;
   assign ccif.iaddr = (tag != cache[idx][57:57-ITAG_W+1] && dcif.imemREN) ? dcif.imemaddr : 0;
   
   assign next_cache[idx] = (tag == cache[idx][57:57-ITAG_W+1]) ? curr_cache[idx]:(~ccif.iwait & {1'b1, tag, ccif.iload}); // ????
   
   assign dcif.imemload = (dcif.imemREN) ? curr_cache[idx] : 0;
   assign dcif.ihit = ~ccif.iwait;
 //???
   
   
      


endmodule // caches
