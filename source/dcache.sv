/*
 Zhaoyang Han & Jinyi Zhang
 han221 & zhan1128
 
 data cache source file
 */

`include "cpu_types_pkg.vh"

module dcache (
	       input logic CLK, nRST,
	       datapath_cache_if.dcache dcif,
	       cache_control_if.dcache ccif
	       );
   import cpu_types_pkg::*;

   parameter CPUID = 0;

   logic 		   valid, dirty;
   
   logic [DTAG_W-1:0] tag;
   logic [DIDX_W-1:0] idx;
   logic [DBLK_W-1:0] blkoff;
   logic [DBYT_W-1:0] bytoff;
   
   // logic [DTAG_W-1:0] tag2;
   // logic [DIDX_W-1:0] idx2;
   // logic [DBLK_W-1:0] blkoff2;
   // logic [DBYT_W-1:0] bytoff2;
   
   logic [7:0][91:0]     curr_cache1, next_cache1;
   logic [7:0][91:0] 	 curr_cache2, next_cache2;
   int 			  i;
   logic 		  used = 0;

   int 			  data; // the left most bit of data
   logic [31:0] 	  data1, data2, curr_data1, next_data1, curr_data2, next_data2; // data from first and second read or write
   

   logic 		  hit, miss;
   

   ///////// state machine /////////////
   typedef enum 	  logic [2:0] {IDLE, READ1, READ2, WRITE1, WRITE2} cacheState;
   cacheState curr_state, next_state;

   always_ff @ (posedge CLK, negedge nRST) begin
      if (nRST == 0) begin
	 curr_state <= 0;
	 curr_data1 <= 0;
	 curr_data2 <= 0;
	 
      end
      else begin
	 curr_state <= next_state;
	 curr_data1 <= next_data1;
	 curr_data2 <= next_data2;
	 
      end
     
   end // always_ff @

   assign next_data1 = (curr_state == READ1 && !ccif.dwait) ? data1 : curr_data1;
   assign next_data2 = (curr_state == READ2 && !ccif.dwait) ? data2 : curr_data2;
   
   
   always_comb begin
      next_state = IDLE;
      ccif.dREN = 0;
      ccif.dWEN = 0;
      ccif.daddr = 0;
      ccif.dstore = 0;
      data1 = 0;
      data2 = 0;
      
      case(curr_state)
	IDLE: begin
	   if (dcif.dmemREN && miss) begin
	      next_state = READ1;
	   end
	   else if(dcif.dmemWEN && miss && dirty) begin
	      next_state = WRITE1;
	   end
	end
	READ1: begin
	   if (ccif.dwait == 0) begin
	      next_state = READ2;
	      data1 = ccif.dload;
	      
	   end
	   else begin
	      next_state = READ1;
	      data1 = 0;
	      
	   end
	   ccif.daddr = dcif.dmemaddr;
	   ccif.dREN = 1;
	   
	end
	READ2: begin
	   ccif.dREN = 1;
	   if(blkoff == 0) begin
	      ccif.daddr = dcif.dmemaddr + 4;
	   end
	   else begin
	      ccif.daddr = dcif.dmemaddr - 4;
	   end
	   if (ccif.dwait == 0) begin
	      next_state = IDLE;
	      data2 = ccif.dload;
	   end
	   else begin
	      next_state = READ2;
	      data2 = 0;
	   end
	   
	end
	WRITE1: begin
	   ccif.dWEN = 1;
	   ccif.daddr = dcif.dmemaddr;
	   if (used == 0) begin
	      // table 1 was used last time
	      ccif.dstore = curr_cache2[idx][data:data-31];
	   end
	   else begin
	      ccif.dstore = curr_cache1[idx][data:data-31];
	   end
	   if (ccif.dwait == 0) begin
	      next_state = WRITE2;
	   end
	   else begin
	      next_state = WRITE1;
	   end
	   
	end
	WRITE2: begin
	   ccif.dWEN = 1;
	   if(blkoff == 0) begin
	      ccif.daddr = dcif.dmemaddr + 4;
	   end
	   else begin
	      ccif.daddr = dcif.dmemaddr - 4;
	   end
	   if (used == 0) begin
	      // table 1 was used last time
	      ccif.dstore = curr_cache2[idx][94-data:63-data];
	   end
	   else begin
	      ccif.dstore = curr_cache1[idx][94-data:63-data];
	   end
	   if (ccif.dwait == 0) begin
	      next_state = IDLE;
	   end
	   else begin
	      next_state = WRITE2;
	   end
	end
	endcase

   end
   


   
   assign data = blkoff*32 + 31; //the left most bit # of chosen data block
   
   assign tag = dcif.dmemaddr[31:31-DTAG_W+1];
   assign idx = dcif.dmemaddr[31-DTAG_W:31-DTAG_W-DIDX_W+1];
   assign blkoff = dcif.dmemaddr[31-DTAG_W-DIDX_W:31-DTAG_W-DIDX_W-DBLK_W+1];
   assign bytoff = dcif.dmemaddr[31-DTAG_W-DIDX_W-DBLK_W:0];


   always_ff @ (posedge CLK, negedge nRST) begin
      if (nRST == 0) begin
	 for(i = 0; i < 16; i++)begin
	    curr_cache1[i] <= 0;
	    curr_cache2[i] <= 0;
     	 end	 
      end
      else begin
	 

      end
   end
   

   
   always_comb begin
      if (used == 0) //table 1 was used last time
	begin
	   used = 1;
	   dcif.dhit = (dcif.dmemREN|dcif.dmemWEN) ? ~ccif.dwait : 0; //??
	   dcif.dmemload = 0;
	   hit = 0;
	   miss = 0;
	   valid = 0;
	   dirty = 0;
	   next_cache2[idx] = curr_cache2[idx];
	  
	   
	   if (dcif.dmemREN == 1) begin
	      if (tag == curr_cache2[idx][89:89-DTAG_W+1]) begin
		 dcif.dmemload = curr_cache2[idx][data:data-31];
		 hit = 1;
	      end
	      else begin
		 miss = 1;
		 dirty = 0;
		 valid = 1;
		 if (curr_state == READ2 && !ccif.dwait) begin
		    if (blkoff == 0) begin
		       next_cache2[idx] = {valid, dirty, next_data2, curr_data1};
		    end
		    else begin
		       next_cache2[idx] = {valid, dirty, curr_data1, next_data2};
		    end
		    dcif.dmemload = curr_cache2[idx][data:data-31];
		 end
	      end
	   end
	   else if (dcif.dmemWEN == 1) begin
	      if (tag == curr_cache2[idx][89:89-DTAG_W+1]) begin
		 hit = 1;
		 dirty = 1;
		 valid = 0;
		 next_cache2[idx][91] = valid;
		 next_cache2[idx][90] = dirty;
		 next_cache2[idx][data:data-31] = dcif.dmemstore;
	      end
	      else begin
		 miss = 1;
		 valid = 0;
		 
		 if (dirty == 0) begin
		    dirty = 1;
		    next_cache2[idx][91] = valid;
		    next_cache2[idx][90] = dirty;
		    next_cache2[idx][data:data-31] = dcif.dmemstore;
		 end
		 else begin
		    if (curr_state == WRITE2 && !ccif.dwait) begin
		       next_cache2[idx][91] = valid;
		       next_cache2[idx][data:data-31] = dcif.dmemstore; // ????
		    end
		 end // else: !if(dirty == 0)
	      end // else: !if(tag == curr_cache2[idx][89:89-DTAG_W+1])
	   end
     	end
      
      
      else begin
	 // table 2 was used last time
	 used = 0;
	 
	 dcif.dhit = (dcif.dmemREN|dcif.dmemWEN) ? ~ccif.dwait : 0; //??
	 dcif.dmemload = 0;
	 hit = 0;
	 miss = 0;
	 valid = 0;
	 dirty = 0;
	 next_cache1[idx] = curr_cache1[idx];
	 
	 
	 if (dcif.dmemREN == 1) begin
	    if (tag == curr_cache1[idx][89:89-DTAG_W+1]) begin
	       dcif.dmemload = curr_cache1[idx][data:data-31];
	       hit = 1;
	    end
	    else begin
	       miss = 1;
	       dirty = 0;
	       valid = 1;
	       if (curr_state == READ2 && !ccif.dwait) begin
		  if (blkoff == 0) begin
		     next_cache1[idx] = {valid, dirty, next_data2, curr_data1};
		  end
		  else begin
		     next_cache1[idx] = {valid, dirty, curr_data1, next_data2};
		  end
		  dcif.dmemload = curr_cache1[idx][data:data-31];
	       end
	     end
	 end
	 else if (dcif.dmemWEN == 1) begin
	    if (tag == curr_cache1[idx][89:89-DTAG_W+1]) begin
	       hit = 1;
	       dirty = 1;
	       valid = 0;
	       next_cache1[idx][91] = valid;
	       next_cache1[idx][90] = dirty;
	       next_cache1[idx][data:data-31] = dcif.dmemstore;
	    end
	    else begin
	       miss = 1;
	       valid = 0;
	       
	       if (dirty == 0) begin
		  dirty = 1;
		  next_cache1[idx][91] = valid;
		  next_cache1[idx][90] = dirty;
		  next_cache1[idx][data:data-31] = dcif.dmemstore;
	       end
	       else begin
		  if (curr_state == WRITE2 && !ccif.dwait) begin
		     next_cache1[idx][91] = valid;
		     next_cache1[idx][data:data-31] = dcif.dmemstore; // ????
		  end
	       end // else: !if(dirty == 0)
	    end // else: !if(tag == curr_cache2[idx][89:89-DTAG_W+1])
	 end
      end // else: !if(used == 0
   end // always_comb
   
   



endmodule // dcache

