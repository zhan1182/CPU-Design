/*
 Zhaoyang Han & Jinyi Zhang
 han221 & zhan1128
 
 instruction cache source file
 */

`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

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
   // {valid, tag 26bits, word 32 bits}
   logic [15:0][58:0] curr_cache;
   int 			  i;
   logic 		  hit;
   logic 		  miss;
   logic 		  valid;
   
   // This is a cache hit
   assign hit = (tag == curr_cache[idx][57:57-ITAG_W+1]) & valid;
   assign miss = ~hit;
   assign valid = curr_cache[idx][58];
   

   assign tag = dcif.imemaddr[31:31-ITAG_W+1];
   assign idx = dcif.imemaddr[31-ITAG_W:31-ITAG_W-IIDX_W+1];
   assign bytoff = dcif.imemaddr[31-ITAG_W-IIDX_W:0];

   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (nRST == 0) begin
	 for(i = 0; i < 16; i++)begin
	    curr_cache[i] <= -1;
	 end	 
      end
      else begin
	 if(~ccif.iwait && miss)
	   begin
	      curr_cache[idx] <= {1'b1, tag, ccif.iload};
	   end
      end
   end

   assign ccif.iREN = (hit) ? 0 : 1;
   assign ccif.iaddr = dcif.imemaddr;

   assign dcif.imemload = (hit) ? curr_cache[idx][31:0] : ((~ccif.iwait) ? ccif.iload : 0);
   
   assign dcif.ihit = hit | (~ccif.iwait && miss);
   

endmodule // caches
