`include "cpu_types_pkg.vh"

module dcache (
	       input logic CLK, nRST,
	       datapath_cache_if dcif,
	       cache_control_if ccif
	       );
   import cpu_types_pkg::*;

   parameter CPUID = 0;

   int 			   i;
   
   // logic [DTAG_W-1:0] tag;
   // logic [DIDX_W-1:0] idx;
   // logic [DBLK_W-1:0] blkoff;

   logic 	      curr_used, next_used;
   logic [7:0][91:0]  curr_cache0, next_cache0;
   logic [7:0][91:0]  curr_cache1, next_cache1;

   // Index and block offset used to flush cache0 and cache1
   logic [DIDX_W:0] curr_idx0, next_idx0;
   logic [DIDX_W:0] curr_idx1, next_idx1;
   logic [DBLK_W-1:0] curr_blkoff0, next_blkoff0;
   logic [DBLK_W-1:0] curr_blkoff1, next_blkoff1;

   // Record the hit number
   word_t curr_number, next_number;

   // cache done flag is set when all the dirty data has been writen to ram
   logic 	      cache0_done, cache1_done;
   
   dcachef_t info;   
   logic 		  valid0, dirty0, valid;
   logic 		  valid1, dirty1;
   logic 		  dirty;
   logic 		  hit0, hit1, hit, miss;

   logic [DTAG_W-1:0] 	  flush_tag;
   logic 		  flush_dirty0, flush_dirty1;
   
   
   // Define state machine
   typedef enum 	  logic [3:0] {IDLE, READ1, READ2, READ_DONE, WRITE1, WRITE2, FLUSH0, FLUSH1, HIT_WRITE, HIT_DONE, DONE} cacheState;
   
   cacheState curr_state, next_state;

   
   assign valid0 = curr_cache0[info.idx][91];
   assign valid1 = curr_cache1[info.idx][91];
   assign valid = curr_used ? valid1 : valid0;

   assign dirty0 = curr_cache0[info.idx][90];
   assign dirty1 = curr_cache1[info.idx][90];
   assign dirty = curr_used ? dirty1 : dirty0;

   // assign tag = dcif.dmemaddr[31:31-DTAG_W+1];
   // assign idx = dcif.dmemaddr[31-DTAG_W:31-DTAG_W-DIDX_W+1];
   // assign blkoff = dcif.dmemaddr[31-DTAG_W-DIDX_W:31-DTAG_W-DIDX_W-DBLK_W+1];

   assign info = dcachef_t'(dcif.dmemaddr);
   
   
   assign hit0 = (info.tag == curr_cache0[info.idx][89:89-DTAG_W+1] && valid0 == 1);   
   assign hit1 = (info.tag == curr_cache1[info.idx][89:89-DTAG_W+1] && valid1 == 1);
   
   assign hit = hit0 | hit1;
   // assign next_number = (hit) ? (curr_number + 1) : curr_number;
   
   assign miss = ~hit;


   // Flush cache0 is done
   assign cache0_done = (curr_idx0 >= 8) ? 1 : 0;
   assign cache1_done = (curr_idx1 >= 8) ? 1 : 0;

   
   always_ff @ (posedge CLK, negedge nRST) 
     begin
	if (nRST == 0) 
	  begin
	     curr_used <= 0;
	     
	     curr_idx0 <= 0;
	     curr_blkoff0 <= 0;
	     
	     curr_idx1 <= 0;
	     curr_blkoff1 <= 0;

	     curr_number <= 0;
	     
	     for(i = 0; i < 8; i++)begin
		curr_cache0[i] <= 0;
		curr_cache1[i] <= 0;
     	     end	 
	  end
	else 
	  begin
	     curr_used <= next_used;
	     
	     curr_idx0 <= next_idx0;
	     curr_blkoff0 <= next_blkoff0;
	     
	     curr_idx1 <= next_idx1;
	     curr_blkoff1 <= next_blkoff1;
	     
	     curr_cache0 <= next_cache0;
	     curr_cache1 <= next_cache1;

	     curr_number = next_number;	     
	  end
     end // always_ff @
   
   always_ff @ (posedge CLK, negedge nRST) begin
      if (nRST == 0) 
	begin
	   curr_state <= IDLE;
	end
      else 
	begin
	   curr_state <= next_state;
	end     
   end // always_ff @

   always_comb
     begin
	next_state = curr_state;
	case(curr_state)
	  IDLE:
	    begin
	       if(dcif.halt == 1) 
		 begin
		    next_state = FLUSH0;
		 end
	       else if(miss && dirty && valid && (dcif.dmemREN || dcif.dmemWEN))
		 begin
		    next_state = WRITE1;
		 end
	       else if(miss && dirty == 0 && (dcif.dmemREN || dcif.dmemWEN))
		 begin
		    next_state = READ1;
		 end
	    end
	  READ1:
	    begin
	       if (ccif.dwait == 0) 
		 begin
		    next_state = READ2;
		 end
	    end
	  READ2:
	    begin
	       if (ccif.dwait == 0) 
		 begin
		    next_state = IDLE;
		 end
	    end
	  // READ_DONE:
	  //   begin
	  //      next_state = IDLE;
	       

	  //   end
	  
	  WRITE1:
	    begin
	       if (ccif.dwait == 0) 
		 begin
		    next_state = WRITE2;
		 end
	    end
	  WRITE2:
	    begin
	       if (ccif.dwait == 0) 
		 begin
		    next_state = (dcif.dmemREN || dcif.dmemWEN) ? READ1:IDLE;
		 end
	    end
	  // WRITE_DONE:
	  //   begin
	  //      next_state = (dcif.dmemREN || dcif.dmemWEN) ? READ1:IDLE;
	  //   end
	  FLUSH0:// Write dirty data from the first cache to ram
	    begin
	       if(cache0_done)
	       	 begin
	       	    next_state = FLUSH1;
	       	 end
	    end
	  FLUSH1:
	    begin
	       if(cache1_done)
		 begin
		    next_state = HIT_WRITE;
		 end
	    end
	  HIT_WRITE:// Write number of hit to ram
	    begin
	       if(ccif.dwait == 0)
		 begin
	       	    next_state = HIT_DONE;
		 end
	    end
	  HIT_DONE:
	    begin
	       next_state = DONE;
	    end
	  DONE: 
	    begin
	       // No more state. Set datapath flush to 1
	    end
	endcase // case (curr_state)
     end

   always_comb
     begin

	ccif.dREN = 0;
	ccif.dWEN = 0;
	ccif.daddr = 0;
	ccif.dstore = 0;
	
	dcif.dmemload = 0;
	dcif.dhit = 0;
	dcif.flushed = 0;
	
	next_used = curr_used;
	next_cache0 = curr_cache0;
	next_cache1 = curr_cache1;

	next_idx0 = curr_idx0;
	next_blkoff0 = curr_blkoff0;

	next_idx1 = curr_idx1;
	next_blkoff1 = curr_blkoff1;

	flush_tag = 0;
	flush_dirty0 = 0;
	flush_dirty1 = 0;
	
	next_number = curr_number;
	
	case(curr_state)
	  IDLE:
	    begin
	       if(dcif.dmemREN)
		 begin
		    if(hit0)
		      begin
			 // increment hit number
			 next_number = curr_number + 1;
			 
			 dcif.dmemload = info.blkoff ? curr_cache0[info.idx][63:32] : curr_cache0[info.idx][31:0];
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
		      end
		    else if(hit1)
		      begin
			 // increment hit number
			 next_number = curr_number + 1;
			 
			 dcif.dmemload = info.blkoff ? curr_cache1[info.idx][63:32] : curr_cache1[info.idx][31:0];
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
		      end
		 end
	       else if(dcif.dmemWEN)
		 begin
		    // if(valid0 == 0)
		    //   begin
		    // 	 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			 
		    // 	 next_used = 1;
		    // 	 next_cache0[info.idx][90] = 1;
		    // 	 next_cache0[info.idx][91] = 1;// Assign valid1 to 1
		    // 	 next_cache0[info.idx][89:64] = info.tag;// Assign tag
		    // 	 if (info.blkoff == 1)
		    // 	   begin
		    // 	      next_cache0[info.idx][63:32] = dcif.dmemstore;
		    // 	   end
		    // 	 else
		    // 	   begin
		    // 	      next_cache0[info.idx][31:0] = dcif.dmemstore;
		    // 	   end
		    //   end // if (valid0 == 0)
		    // else if(valid1 == 0)
		    //   begin
		    // 	 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			 
		    // 	 next_used = 0;
		    // 	 next_cache1[info.idx][90] = 1;
		    // 	 next_cache1[info.idx][91] = 1;
		    // 	 next_cache1[info.idx][89:64] = info.tag;
		    // 	 if (info.blkoff == 1) 
		    // 	   begin
		    // 	      next_cache1[info.idx][63:32] = dcif.dmemstore;
		    // 	   end
		    // 	 else 
		    // 	   begin
		    // 	      next_cache1[info.idx][31:0] = dcif.dmemstore;
		    // 	   end
		    //   end // if (valid1 == 0)
		    if(hit0)
		      begin
			 // increment hit number
			 next_number = curr_number + 1;
			 
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			 
			 next_used = 1;
			 // Assign dirty to 1. The data is dirty, only exists in cache, need to be writen back to ram
			 next_cache0[info.idx][90] = 1;
			 next_cache0[info.idx][91] = 1;// Assign valid1 to 1
			 next_cache0[info.idx][89:64] = info.tag;
			 if (info.blkoff == 1) 
			   begin
			      next_cache0[info.idx][63:32] = dcif.dmemstore;
			   end
			 else 
			   begin
			      next_cache0[info.idx][31:0] = dcif.dmemstore;
			   end
		      end
		    else if(hit1)
		      begin
			 // increment hit number
			 next_number = curr_number + 1;
			 
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			 
			 next_used = 0;
			 
			 next_cache1[info.idx][90] = 1;
			 next_cache1[info.idx][91] = 1;
			 next_cache1[info.idx][89:64] = info.tag;
			 if (info.blkoff == 1) 
			   begin
			      next_cache1[info.idx][63:32] = dcif.dmemstore;
			   end
			 else 
			   begin
			      next_cache1[info.idx][31:0] = dcif.dmemstore;
			   end
		      end // if (hit1)
		 end // if (dcif.dmemWEN)
	    end // case: IDLE
	  READ1:
	    begin
	       ccif.dREN = 1;
	       ccif.daddr = dcif.dmemaddr;

	       if(ccif.dwait == 0)
		 begin
		    // dcif.dmemload = ccif.dload;
		    if(curr_used)
		      begin
			 next_cache1[info.idx][91] = 1;
			 next_cache1[info.idx][90] = 0;
			 next_cache1[info.idx][89:64] = info.tag;
			 
			 if(info.blkoff)
			   begin
			      next_cache1[info.idx][63:32] = ccif.dload;
			   end
			 else
			   begin
			      next_cache1[info.idx][31:0] = ccif.dload;
			   end
		      end // if (curr_used)
		    else
		      begin
			 next_cache0[info.idx][91] = 1;
			 next_cache0[info.idx][90] = 0;
			 next_cache0[info.idx][89:64] = info.tag;
			 
			 if(info.blkoff)
			   begin
			      next_cache0[info.idx][63:32] = ccif.dload;
			   end
			 else
			   begin
			      next_cache0[info.idx][31:0] = ccif.dload;
			   end
		      end // else: !if(curr_used)
		 end
	    end
	  READ2:
	    begin
	       ccif.dREN = 1;
	       ccif.daddr = info.blkoff ? dcif.dmemaddr - 4 : dcif.dmemaddr + 4;
	       if(ccif.dwait == 0)
		 begin
		    dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
		    
		    if(curr_used)
		      begin
			 // Update the next_used
			 next_used = 0;
			 
			 next_cache1[info.idx][91] = 1;
			 next_cache1[info.idx][90] = dcif.dmemWEN ? 1:0;
			 next_cache1[info.idx][89:64] = info.tag;
			 
			 if(info.blkoff)
			   begin
			      next_cache1[info.idx][31:0] = ccif.dload;
			      // Give the data to datapaht
			      dcif.dmemload = curr_cache1[info.idx][63:32];
			      next_cache1[info.idx][63:32] = dcif.dmemWEN ? dcif.dmemstore : curr_cache1[info.idx][63:32];
			      
			   end
			 else
			   begin
			      next_cache1[info.idx][31:0] = dcif.dmemWEN ? dcif.dmemstore : curr_cache1[info.idx][31:0];
			      
			      next_cache1[info.idx][63:32] = ccif.dload;
			      dcif.dmemload = curr_cache1[info.idx][31:0];
			   end
		      end // if (curr_used)
		    else
		      begin
			 // Update the next_used
			 next_used = 1;
		    
			 next_cache0[info.idx][91] = 1;
			 next_cache0[info.idx][90] = dcif.dmemWEN ? 1:0;
			 next_cache0[info.idx][89:64] = info.tag;
			 
			 if(info.blkoff)
			   begin
			      next_cache0[info.idx][31:0] = ccif.dload;
			      dcif.dmemload = curr_cache0[info.idx][63:32];
			      next_cache0[info.idx][63:32] = dcif.dmemWEN ? dcif.dmemstore : curr_cache0[info.idx][63:32];
			   end
			 else
			   begin
			      next_cache0[info.idx][63:32] = ccif.dload;
			      dcif.dmemload = curr_cache0[info.idx][31:0];
			      next_cache0[info.idx][31:0] = dcif.dmemWEN ? dcif.dmemstore : curr_cache0[info.idx][31:0];
			   end
		      end // else: !if(curr_used)

		 end // if (ccif.dwait == 0)
	       
	    end // case: READ2
	  // READ_DONE:
	  //   begin
	  //      if(dcif.dmemWEN)
	  // 	 begin

	  // 	    dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
		    
	  // 	    if(curr_used)
	  // 	      begin
	  // 		 // Update the next use cache
	  // 		 next_used = 0;
			 
	  // 		 next_cache1[info.idx][91] = 1;// valid = 0
	  // 		 next_cache1[info.idx][90] = 1;// ditry = 1
	  // 		 next_cache1[info.idx][89:64] = info.tag;
			 
	  // 		 if(info.blkoff == 0)
	  // 		   begin
	  // 		      next_cache1[info.idx][31:0] = dcif.dmemstore;
	  // 		   end
	  // 		 else
	  // 		   begin
	  // 		      next_cache1[info.idx][63:32] = dcif.dmemstore;
	  // 		   end
	  // 	      end // if (curr_used)
	  // 	    else
	  // 	      begin
	  // 		 // Update the next use cache
	  // 		 next_used = 1;
			 
	  // 		 next_cache0[info.idx][91] = 1;// valid = 0
	  // 		 next_cache0[info.idx][90] = 1;// ditry = 1
	  // 		 next_cache0[info.idx][89:64] = info.tag;
			 
	  // 		 if(info.blkoff == 0)
	  // 		   begin
	  // 		      next_cache0[info.idx][31:0] = dcif.dmemstore;
	  // 		   end
	  // 		 else
	  // 		   begin
	  // 		      next_cache0[info.idx][63:32] = dcif.dmemstore;
	  // 		   end
	  // 	      end
	  // 	 end // if (dcif.dmemWEN)
	  //   end
	  
	  WRITE1:
	    begin
	       // Turn on MEM write enable
	       ccif.dWEN = 1;
	       //ccif.daddr = dcif.dmemaddr;
	       if (curr_used)
		 begin
		    ccif.dstore = info.blkoff ? curr_cache1[info.idx][63:32] : curr_cache1[info.idx][31:0];
		    ccif.daddr = {curr_cache1[info.idx][89:64], info.idx, info.blkoff, info.bytoff};
		    
		 end
	       else 
		 begin
		    ccif.dstore = info.blkoff ? curr_cache0[info.idx][63:32] : curr_cache0[info.idx][31:0];
		    ccif.daddr = {curr_cache0[info.idx][89:64], info.idx, info.blkoff, info.bytoff};
		    
		 end
	    end
	  WRITE2:
	    begin
	       ccif.dWEN = 1;

	       // Calculate the data address
	       //ccif.daddr = info.blkoff ? dcif.dmemaddr - 4 : dcif.dmemaddr + 4;
	       
	       if (curr_used)
		 begin
		    // Give the data to mem. The data is from datapath
		    ccif.dstore = info.blkoff ? curr_cache1[info.idx][31:0] : curr_cache1[info.idx][63:32];
		    ccif.daddr = info.blkoff ? {curr_cache1[info.idx][89:64], info.idx, 1'b0, info.bytoff} : {curr_cache1[info.idx][89:64], info.idx, 1'b1, info.bytoff};
		    
		 end
	       else 
		 begin
		    ccif.dstore = info.blkoff ? curr_cache0[info.idx][31:0] : curr_cache0[info.idx][63:32];
		    ccif.daddr = info.blkoff ? {curr_cache0[info.idx][89:64], info.idx, 1'b0, info.bytoff} : {curr_cache0[info.idx][89:64], info.idx, 1'b1, info.bytoff};
		 end
	    end // case: WRITE2
	  // WRITE_DONE:
	  //   begin
	  //      // if(dcif.dmemWEN)
	  //      // 	 begin

	  //      // 	    dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
		    
	  //      // 	    if(curr_used)
	  //      // 	      begin
	  //      // 		 // Update the next use cache
	  //      // 		 next_used = 0;
			 
	  //      // 		 next_cache1[info.idx][91] = 1;// valid = 0
	  //      // 		 next_cache1[info.idx][90] = 1;// ditry = 1
	  //      // 		 next_cache1[info.idx][89:64] = info.tag;
			 
	  //      // 		 if(info.blkoff == 0)
	  //      // 		   begin
	  //      // 		      next_cache1[info.idx][31:0] = dcif.dmemstore;
	  //      // 		   end
	  //      // 		 else
	  //      // 		   begin
	  //      // 		      next_cache1[info.idx][63:32] = dcif.dmemstore;
	  //      // 		   end
	  //      // 	      end // if (curr_used)
	  //      // 	    else
	  //      // 	      begin
	  //      // 		 // Update the next use cache
	  //      // 		 next_used = 1;
			 
	  //      // 		 next_cache0[info.idx][91] = 1;// valid = 0
	  //      // 		 next_cache0[info.idx][90] = 1;// ditry = 1
	  //      // 		 next_cache0[info.idx][89:64] = info.tag;
			 
	  //      // 		 if(info.blkoff == 0)
	  //      // 		   begin
	  //      // 		      next_cache0[info.idx][31:0] = dcif.dmemstore;
	  //      // 		   end
	  //      // 		 else
	  //      // 		   begin
	  //      // 		      next_cache0[info.idx][63:32] = dcif.dmemstore;
	  //      // 		   end
	  //      // 	      end
	  //      // 	 end // if (dcif.dmemWEN)
	  //   end
	  FLUSH0:
	    begin
	       flush_dirty0 = curr_cache0[curr_idx0][90];
	       
	       if(curr_cache0[curr_idx0][90] == 1)//If data is dirtry, write data to ram
		 begin
		    ccif.dWEN = 1;
		    ccif.dstore = curr_blkoff0 ? curr_cache0[curr_idx0][63:32] : curr_cache0[curr_idx0][31:0];
		    flush_tag = curr_cache0[curr_idx0][89:64];
		    
		    ccif.daddr = {curr_cache0[curr_idx0][89:64], curr_idx0[2:0], curr_blkoff0, 2'b0};
		    if(ccif.dwait == 0 && curr_blkoff0 == 0)
		      begin
			 next_blkoff0 = 1;
		      end
		    else if(ccif.dwait == 0 && curr_blkoff0 == 1)
		      begin
			 next_blkoff0 = 0;
			 next_idx0 = curr_idx0 + 1;
		      end
		 end
	       else // If data is clean, do nothing. Go to next index.
		 begin
		    next_idx0 = curr_idx0 + 1;
		 end
	    end
	  FLUSH1:
	    begin
	       flush_dirty1 = curr_cache1[curr_idx1][90];
	       
	       if(curr_cache1[curr_idx1][90] == 1)//If data is dirtry, write data to ram
		 begin
		    ccif.dWEN = 1;
		    ccif.dstore = curr_blkoff1 ? curr_cache1[curr_idx1][63:32] : curr_cache1[curr_idx1][31:0];
		    flush_tag = curr_cache1[curr_idx0][89:64];
		    ccif.daddr = {curr_cache1[curr_idx1][89:64], curr_idx1[2:0], curr_blkoff1, 2'b0};
		    if(ccif.dwait == 0 && curr_blkoff1 == 0)
		      begin
			 next_blkoff1 = 1;
		      end
		    else if(ccif.dwait == 0 && curr_blkoff1 == 1)
		      begin
			 next_blkoff1 = 0;
			 next_idx1 = curr_idx1 + 1;
		      end
		 end
	       else // If data is clean, do nothing. Go to next index.
		 begin
		    next_idx1 = curr_idx1 + 1;
		 end
	    end
	  HIT_WRITE:
	    begin
	       ccif.dWEN = 1;
	       ccif.dstore = curr_number;
	       ccif.daddr = 32'h3100;
	    end
	  HIT_DONE:
	    begin
	    end
	  DONE: 
	    begin
	       dcif.flushed = 1;
	    end
	endcase // case (curr_state)
     end
   
endmodule
