`include "cpu_types_pkg.vh"

module dcache (
	       input logic CLK, nRST,
	       datapath_cache_if dcif,
	       cache_control_if ccif
	       );
   import cpu_types_pkg::*;

   parameter CPUID = 0;

   logic 		   valid0, dirty0, valid;
   logic 		   valid1, dirty1;
   logic 		   dirty;
   
   logic 		   curr_used, next_used;
   
   
   logic [DTAG_W-1:0] tag;
   logic [DIDX_W-1:0] idx;
   logic [DBLK_W-1:0] blkoff;

   logic [7:0][91:0]  curr_cache0, next_cache0;
   logic [7:0][91:0]  curr_cache1, next_cache1;

   typedef enum 	  logic [3:0] {IDLE, READ1, READ1_DONE, READ2, READ2_DONE, WRITE1, WRITE2, WRITE_DONE, FLUSH1, HIT_WRITE, HIT_WAIT, DONE} cacheState;
   
   cacheState curr_state, next_state;


   logic 		  hit0, hit1, hit, miss;
   // logic 		  hit_write;

   // logic [4:0] 		  count, next_count;//32, larger than 16 we needed
   
   int 			  i;
   
   
   assign valid0 = curr_cache0[idx][91];
   assign valid1 = curr_cache1[idx][91];
   assign valid = curr_used ? valid1 : valid0;
   

   assign tag = dcif.dmemaddr[31:31-DTAG_W+1];
   assign idx = dcif.dmemaddr[31-DTAG_W:31-DTAG_W-DIDX_W+1];
   assign blkoff = dcif.dmemaddr[31-DTAG_W-DIDX_W:31-DTAG_W-DIDX_W-DBLK_W+1];

   assign hit0 = (tag == curr_cache0[idx][89:89-DTAG_W+1] && valid0 == 1);   
   assign hit1 = (tag == curr_cache1[idx][89:89-DTAG_W+1] && valid1 == 1);
   
   assign hit = hit0 | hit1;
   // assign miss = ~hit && valid0 == 1 && valid1 == 1;
   assign miss = ~hit;
   
   // assign dirty =  curr_used ? dirty0 : dirty1;

   assign dirty0 = curr_cache0[idx][90];
   assign dirty1 = curr_cache1[idx][90];
   assign dirty = curr_used ? dirty1 : dirty0;
   
   
   // assign hit_write = 

   
   always_ff @ (posedge CLK, negedge nRST) 
     begin
	if (nRST == 0) 
	  begin
	     curr_used <= 0;
	     // count <= 0;
	     for(i = 0; i < 8; i++)begin
		curr_cache0[i] <= 0;
		curr_cache1[i] <= 0;
     	     end	 
	  end
	else 
	  begin
	     curr_used <= next_used;
	     // count <= next_count;
	     curr_cache0 <= next_cache0;
	     curr_cache1 <= next_cache1;
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
	       if(miss && dirty && valid) 
		 begin
		    next_state = WRITE1;
		 end
	       else if(miss && dirty == 0 && dcif.dmemREN)
		 begin
		    next_state = READ1;
		 end
	       else if(dcif.halt == 1) 
		 begin
		    next_state = FLUSH1;
		 end
	    end
	  READ1:
	    begin
	       if (ccif.dwait == 0) 
		 begin
		    next_state = READ1_DONE;
		 end
	    end
	  READ1_DONE:
	    begin
	       next_state = READ2;
	    end
	  READ2:
	    begin
	       if (ccif.dwait == 0) 
		 begin
		    next_state = READ2_DONE;
		 end
	    end
	  READ2_DONE:
	    begin
	       next_state = IDLE;
	    end // case: READ2_DONE
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
		    next_state = WRITE_DONE;
		 end
	    end
	  WRITE_DONE:
	    begin
	       next_state = dcif.dmemREN ? READ1 : IDLE;
	    end
	  FLUSH1:
	    begin
	       // if(hit_write)
	       // 	 begin
	       // 	    next_state = HIT_WRITE;
	       // 	 end
	    end
	  HIT_WRITE:
	    begin
	       // next_state = HIT_WAIT;
	    end
	  HIT_WAIT:
	    begin
	       // if(ccif.dwait == 0)begin
	       // 	  next_state = DONE;
	       // end
	    end
	  DONE: 
	    begin
	       // dcif.flushed = 1;
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
	
	next_used = curr_used;
	next_cache0 = curr_cache0;
	next_cache1 = curr_cache1;
	
	case(curr_state)
	  IDLE:
	    begin
	       if(dcif.dmemREN)
		 begin
		    if(hit0)
		      begin
			 dcif.dmemload = blkoff ? curr_cache0[idx][63:32] : curr_cache0[idx][31:0];
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
		      end
		    else if(hit1)
		      begin
			 dcif.dmemload = blkoff ? curr_cache1[idx][63:32] : curr_cache1[idx][31:0];
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
		      end
		 end
	       else if(dcif.dmemWEN)
		 begin
		    if(valid0 == 0)
		      begin
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			 
			 next_used = 1;
			 next_cache0[idx][90] = 1;
			 next_cache0[idx][91] = 1;// Assign valid1 to 1
			 next_cache0[idx][89:64] = tag;// Assign tag
			 if (blkoff == 1)
			   begin
			      next_cache0[idx][63:32] = dcif.dmemstore;
			   end
			 else
			   begin
			      next_cache0[idx][31:0] = dcif.dmemstore;
			   end
		      end // if (valid0 == 0)
		    else if(valid1 == 0)
		      begin
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			 
			 next_used = 0;
			 next_cache1[idx][90] = 1;
			 next_cache1[idx][91] = 1;
			 next_cache1[idx][89:64] = tag;
			 if (blkoff == 1) 
			   begin
			      next_cache1[idx][63:32] = dcif.dmemstore;
			   end
			 else 
			   begin
			      next_cache1[idx][31:0] = dcif.dmemstore;
			   end
		      end // if (valid1 == 0)
		    else if(hit0)
		      begin
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			 
			 next_used = 1;
			 // Assign dirty to 1. The data is dirty, only exists in cache, need to be writen back to ram
			 next_cache0[idx][90] = 1;
			 next_cache0[idx][91] = 1;// Assign valid1 to 1
			 next_cache0[idx][89:64] = tag;
			 if (blkoff == 1) 
			   begin
			      next_cache0[idx][63:32] = dcif.dmemstore;
			   end
			 else 
			   begin
			      next_cache0[idx][31:0] = dcif.dmemstore;
			   end
		      end
		    else if(hit1)
		      begin
			 dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			 
			 next_used = 0;
			 
			 next_cache1[idx][90] = 1;
			 next_cache1[idx][91] = 1;
			 next_cache1[idx][89:64] = tag;
			 if (blkoff == 1) 
			   begin
			      next_cache1[idx][63:32] = dcif.dmemstore;
			   end
			 else 
			   begin
			      next_cache1[idx][31:0] = dcif.dmemstore;
			   end
		      end // if (hit1)
		 end // if (dcif.dmemWEN)
	    end // case: IDLE
	  READ1:
	    begin
	       ccif.dREN = 1;
	       ccif.daddr = dcif.dmemaddr;
	    end
	  READ1_DONE:
	    begin
	       // dcif.dmemload = ccif.dload;
	       if(curr_used)
		 begin
		    next_cache1[idx][91] = 1;
		    next_cache1[idx][90] = 0;
		    next_cache1[idx][89:64] = tag;
		    
		    if(blkoff)
		      begin
			 next_cache1[idx][63:32] = ccif.dload;
		      end
		    else
		      begin
			 next_cache1[idx][31:0] = ccif.dload;
		      end
		 end // if (curr_used)
	       else
		 begin
		    next_cache0[idx][91] = 1;
		    next_cache0[idx][90] = 0;
		    next_cache0[idx][89:64] = tag;
		    
		    if(blkoff)
		      begin
			 next_cache0[idx][63:32] = ccif.dload;
		      end
		    else
		      begin
			 next_cache0[idx][31:0] = ccif.dload;
		      end
		 end // else: !if(curr_used)
	    end
	  READ2:
	    begin
	       ccif.dREN = 1;
	       ccif.daddr = blkoff ? dcif.dmemaddr - 4 : dcif.dmemaddr + 4;
	    end
	  READ2_DONE:
	    begin
	       
	       dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
	       
	       if(curr_used)
		 begin
		    // Update the next_used
		    next_used = 0;
		    
		    next_cache1[idx][91] = 1;
		    next_cache1[idx][90] = 0;
		    next_cache1[idx][89:64] = tag;
		    
		    if(blkoff)
		      begin
			 next_cache1[idx][31:0] = ccif.dload;
			 // Give the data to datapaht
			 dcif.dmemload = curr_cache1[idx][63:32];
		      end
		    else
		      begin
			 next_cache1[idx][63:32] = ccif.dload;
			 dcif.dmemload = curr_cache1[idx][31:0];
		      end
		 end // if (curr_used)
	       else
		 begin
		    // Update the next_used
		    next_used = 1;
		    
		    next_cache0[idx][91] = 1;
		    next_cache0[idx][90] = 0;
		    next_cache0[idx][89:64] = tag;
		    
		    if(blkoff)
		      begin
			 next_cache0[idx][31:0] = ccif.dload;
			 dcif.dmemload = curr_cache0[idx][63:32];
		      end
		    else
		      begin
			 next_cache0[idx][63:32] = ccif.dload;
			 dcif.dmemload = curr_cache0[idx][31:0];
		      end
		 end // else: !if(curr_used)	       
	    end // case: READ2_DONE
	  WRITE1:
	    begin
	       // Turn on MEM write enable
	       ccif.dWEN = 1;
	       ccif.daddr = dcif.dmemaddr;
	       if (curr_used)
		 begin
		    ccif.dstore = blkoff ? curr_cache1[idx][63:32] : curr_cache1[idx][31:0];
		 end
	       else 
		 begin
		    ccif.dstore = blkoff ? curr_cache0[idx][63:32] : curr_cache0[idx][31:0];
		 end
	    end
	  WRITE2:
	    begin
	       ccif.dWEN = 1;

	       // Calculate the data address
	       ccif.daddr = blkoff ? dcif.dmemaddr - 4 : dcif.dmemaddr + 4;
	       
	       if (curr_used)
		 begin
		    // Give the data to mem. The data is from datapath
		    ccif.dstore = blkoff ? curr_cache1[idx][31:0] : curr_cache1[idx][63:32];
		 end
	       else 
		 begin
		    ccif.dstore = blkoff ? curr_cache0[idx][31:0] : curr_cache0[idx][63:32];
		 end
	    end // case: WRITE2
	  WRITE_DONE:
	    begin
	       if(dcif.dmemWEN)
		 begin

		    dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
		    
		    if(curr_used)
		      begin
			 // Update the next use cache
			 next_used = 0;
			 
			 next_cache1[idx][91] = 1;// valid = 0
			 next_cache1[idx][90] = 1;// ditry = 1
			 next_cache1[idx][89:64] = tag;
			 
			 if(blkoff == 0)
			   begin
			      next_cache1[idx][31:0] = dcif.dmemstore;
			   end
			 else
			   begin
			      next_cache1[idx][63:32] = dcif.dmemstore;
			   end
		      end // if (curr_used)
		    else
		      begin
			 // Update the next use cache
			 next_used = 1;
			 
			 next_cache0[idx][91] = 1;// valid = 0
			 next_cache0[idx][90] = 1;// ditry = 1
			 next_cache0[idx][89:64] = tag;
			 
			 if(blkoff == 0)
			   begin
			      next_cache0[idx][31:0] = dcif.dmemstore;
			   end
			 else
			   begin
			      next_cache0[idx][63:32] = dcif.dmemstore;
			   end
		      end
		 end // if (dcif.dmemWEN)
	    end
	  FLUSH1:
	    begin
	    end
	  HIT_WRITE:
	    begin
	    end
	  HIT_WAIT:
	    begin
	    end
	  DONE: 
	    begin
	    end
	endcase // case (curr_state)
     end
   
endmodule
