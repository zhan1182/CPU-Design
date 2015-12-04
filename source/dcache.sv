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

   logic [7:0]   curr_used, next_used;
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
   
   // FOR MULTI CORE
   logic [25:0]		  sp_tag;
   logic [DIDX_W:0] 	  sp_idx;
   logic [1:0] 		  sp_cache;
   logic 		  sp_blk;
   logic 		  sp_dirty0, sp_dirty1;
   
   word_t sp_cache0_data, sp_cache1_data, sp1_daddr0, sp1_daddr1, sp2_daddr0, sp2_daddr1, ccsnoopaddr, sp2_ccsnoopaddr;
   
   
   logic 		  ccwait, ccinv, ccwrite, cctrans;
   
   logic 		  dwait;
   logic 		  dREN, dWEN;
   word_t dload, dstore, daddr;
   
   // for linked load and store check
   logic [32:0] 	  curr_linkReg, next_linkReg;
   logic 		  linkValid;
   logic [31:0] 	  linkAddr;
   
   logic 		  storePass;
   
   
   
   // Define state machine
   typedef enum 	  logic [3:0] {IDLE, READ1, READ2, WRITE1, WRITE2, SPCHK, SP1, SP2, FLUSH0, FLUSH1, HIT_WRITE, HIT_DONE, DONE} cacheState;
   
   cacheState curr_state, next_state;

   
   assign valid0 = curr_cache0[info.idx][91];
   assign valid1 = curr_cache1[info.idx][91];
   assign valid = curr_used[info.idx] ? valid1 : valid0;

   assign dirty0 = curr_cache0[info.idx][90];
   assign dirty1 = curr_cache1[info.idx][90];
   assign dirty = curr_used[info.idx] ? dirty1 : dirty0;

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


   // for multicore snoop
   
   assign ccsnoopaddr = ccif.ccsnoopaddr[CPUID];
   assign sp_tag = ccsnoopaddr[31:6];
   assign sp_idx = ccsnoopaddr[5:3];
   assign sp_cache = (sp_tag == curr_cache0[sp_idx][89:64]) ? 2'b00 : (sp_tag == curr_cache1[sp_idx][89:64]) ? 2'b01 : 2'b11; // choose which cache to use
   // if sp_core is 00, match cache0, 01 -> cache1, 11 -> no match
   assign sp_blk = ccsnoopaddr[2];
   assign ccwait = ccif.ccwait[CPUID];
   assign ccinv = ccif.ccinv[CPUID];
   assign ccif.ccwrite[CPUID] = ccwrite;
   assign ccif.cctrans[CPUID] = cctrans;
   assign sp_cache0_data = sp_blk ? curr_cache0[sp_idx][63:32] : curr_cache0[sp_idx][31:0];
   assign sp_cache1_data = sp_blk ? curr_cache1[sp_idx][63:32] : curr_cache1[sp_idx][31:0];
   assign sp_dirty0 = curr_cache0[sp_idx][90];
   assign sp_dirty1 = curr_cache1[sp_idx][90];

   assign dwait = ccif.dwait[CPUID];
   assign dload = ccif.dload[CPUID];
   assign ccif.dREN[CPUID] = dREN;
   assign ccif.dWEN[CPUID] = dWEN;
   assign ccif.daddr[CPUID] = daddr;
   assign ccif.dstore[CPUID] = dstore;
   assign sp2_ccsnoopaddr = sp_blk ? ccsnoopaddr - 4 : ccsnoopaddr + 4;
   
   assign sp1_daddr1 = {curr_cache1[sp_idx][89:64], ccsnoopaddr[5:2], 2'b00};
   assign sp1_daddr0 = {curr_cache0[sp_idx][89:64], ccsnoopaddr[5:2], 2'b00};
   assign sp2_daddr1 = {curr_cache1[sp_idx][89:64], sp2_ccsnoopaddr[5:2], 2'b00};
   assign sp2_daddr0 = {curr_cache0[sp_idx][89:64], sp2_ccsnoopaddr[5:2], 2'b00};

   // for LL & SC
   
   

   assign linkValid = curr_linkReg[32];
   assign linkAddr = curr_linkReg[31:0];
   assign storePass = (dcif.datomic) ? ((curr_linkReg[31:0] != dcif.dmemaddr || !linkValid) ? 0:1):1;

   assign ccif.LLSCaddr[CPUID] = curr_linkReg[31:0];
   
   always_ff @ (posedge CLK, negedge nRST) 
     begin
	if (nRST == 0) 
	  begin
	     curr_used <= 0;
	     
	     curr_idx0 <= 0;
	     curr_blkoff0 <= 0;
	     
	     curr_idx1 <= 0;
	     curr_blkoff1 <= 0;
	     curr_linkReg <= 0;
	     
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
	     curr_linkReg <= next_linkReg;
	     
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

   always @ (*)
     begin
	next_state = curr_state;
	cctrans = 0;
	
	case(curr_state)
	  IDLE:
	    begin
	       
	       if(dcif.halt == 1) 
		 begin
		    next_state = FLUSH0;
		 end
	       else if(ccwait) // if ccwait, then check snoop
		 begin
		    next_state = SPCHK;
		 end
	       else if(miss && dirty && valid && (dcif.dmemREN || dcif.dmemWEN))
		 begin
		    next_state = WRITE1;
		    cctrans = 1;
		    
		 end
	       else if(miss && dirty == 0 && (dcif.dmemREN || dcif.dmemWEN))
		 begin
		    next_state = READ1;
		    cctrans = 1;
		    
		 end
	    end
	  READ1:
	    begin
	       cctrans = 1;
	       
	       if (dwait == 0) 
		 begin
		    next_state = READ2;
		 end
	       
	    end
	  READ2:
	    begin
	       cctrans = 1;
	       
	       if (dwait == 0) 
		 begin
		    next_state = IDLE;
		    cctrans = 0;
		    
		 end
	    end
	  // READ_DONE:
	  //   begin
	  //      next_state = IDLE;
	       

	  //   end
	  
	  WRITE1:
	    begin
	       cctrans = 1;
	       
	       if (dwait == 0) 
		 begin
		    next_state = WRITE2;
		 end
	    end
	  WRITE2:
	    begin
	       cctrans = 1;
	       
	       if (dwait == 0) 
		 begin
		    cctrans = 0;
		    
		    next_state = (dcif.dmemREN || dcif.dmemWEN) ? READ1:IDLE;
		 end
	    end
	  // WRITE_DONE:
	  //   begin
	  //      next_state = (dcif.dmemREN || dcif.dmemWEN) ? READ1:IDLE;
	  //   end
	  SPCHK:
	    begin
	       if (sp_cache == 2'b11)
		 begin
		    // when snoop tag does not match one of the caches
		    next_state = IDLE;
		 end
	       else
		 begin
		    // when match
		    if(!ccinv)
		      begin
			 if(sp_cache == 2'b00 && sp_dirty0)
			   begin
			      // cache0: M to S
			      next_state = SP1;
			   end
			 else if(sp_cache == 2'b01 && sp_dirty1)
			   begin
			      //cache1: M to S
			      next_state = SP1;
			   end
		      end // if (!ccinv)
		    else
		      begin
			 if(sp_cache == 2'b00 && sp_dirty0)
			   begin
			      // cache0: M to I
			      next_state = SP1;
			   end
			 else if(sp_cache == 2'b01 && sp_dirty1)
			   begin
			      //cache1: M to I
			      next_state = SP1;
			   end
			 else if(sp_cache == 2'b00 && !sp_dirty0)
			   begin
			      //cache0: S to I
			      next_state = IDLE;
			   end
			 else if(sp_cache == 2'b01 && !sp_dirty1)
			   begin
			      //cahce1: S to I
			      next_state = IDLE;
			   end
			 else
			   begin
			      next_state = IDLE;
			   end
			 
		      end // else: !if(!ccinv)
			   
		 end // else: !if(sp_cache == 2'b11)
	    end // case: SPCHK

	  SP1:
	    begin
	       if(dwait == 0)
		 begin
		    next_state = SP2;
		 end
	    end

	  SP2:
	    begin
	       if(dwait == 0)
		 begin
		    next_state = IDLE;
		 end
	    end
	  

	  
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
		    next_state = DONE;
		 end
	    end
	  HIT_WRITE:// Write number of hit to ram
	    begin
	       if(dwait == 0)
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

   always @ (*)
     begin

	dREN = 0;
        dWEN = 0;
	daddr = 0;
	dstore = 0;
	
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

	ccwrite = ccwait ? 0 : dcif.dmemWEN;

	next_linkReg = curr_linkReg;
	
	
	
	case(curr_state)
	  IDLE:
	    begin
	       
	       if(dcif.dmemREN && !ccwait)
		 begin
		    //for linked load
		    if(dcif.datomic == 1)
		      begin
			 next_linkReg = {1'b1, dcif.dmemaddr};
		      end
		    
			 
		    if(hit0)
		      begin
			 if(dcif.halt == 0)
			   begin
			      // increment hit number
			      next_number = curr_number + 1;
			      
			      dcif.dmemload = info.blkoff ? curr_cache0[info.idx][63:32] : curr_cache0[info.idx][31:0];
			      dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			   end
		      end
		    else if(hit1)
		      begin
			 if(dcif.halt == 0)
			   begin
			      // increment hit number
			      next_number = curr_number + 1;
			      
			      dcif.dmemload = info.blkoff ? curr_cache1[info.idx][63:32] : curr_cache1[info.idx][31:0];
			      dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			   end
		      end
		 end
	       else if(dcif.dmemWEN && !ccwait)
		 begin
		    // if(!storePass)
		    //   begin
		    // 	 dcif.dhit = 1;
			 
		    if(!dcif.datomic && curr_linkReg[31:0] == dcif.dmemaddr)
		      begin
			 next_linkReg[32] = 0;
		      end
		    
		    if(hit0)
		      begin
			 if(dcif.halt == 0)
			   begin
			      // increment hit number
			      next_number = curr_number + 1;
			      
			      dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			      
			      next_used[info.idx] = 1;
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
		      end
		    else if(hit1)
		      begin
			 if(dcif.halt == 0)
			   begin
			      // increment hit number
			      next_number = curr_number + 1;
			      
			      dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
			      
			      next_used[info.idx] = 0;
			      
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
			   end // if (dcif.halt == 0)
		      end // if (hit1)
		 end // if (dcif.dmemWEN)
	    end // case: IDLE
	  READ1:
	    begin
	       dREN = 1;
	       daddr = dcif.dmemaddr;

	       if(dwait == 0)
		 begin
		    // dcif.dmemload = ccif.dload;
		    if(curr_used[info.idx])
		      begin
			 next_cache1[info.idx][91] = 1;
			 next_cache1[info.idx][90] = 0;
			 next_cache1[info.idx][89:64] = info.tag;
			 
			 if(info.blkoff)
			   begin
			      next_cache1[info.idx][63:32] = dload;
			   end
			 else
			   begin
			      next_cache1[info.idx][31:0] = dload;
			   end
		      end // if (curr_used)
		    else
		      begin
			 next_cache0[info.idx][91] = 1;
			 next_cache0[info.idx][90] = 0;
			 next_cache0[info.idx][89:64] = info.tag;
			 
			 if(info.blkoff)
			   begin
			      next_cache0[info.idx][63:32] = dload;
			   end
			 else
			   begin
			      next_cache0[info.idx][31:0] = dload;
			   end
		      end // else: !if(curr_used)
		 end
	    end
	  READ2:
	    begin
	       dREN = 1;
	       daddr = info.blkoff ? dcif.dmemaddr - 4 : dcif.dmemaddr + 4;
	       if(dwait == 0)
		 begin
		    dcif.dhit = 1; // Set dhit to 1 to inform datapath data is ready
		    
		    if(curr_used[info.idx])
		      begin
			 // Update the next_used
			 next_used[info.idx] = 0;
			 
			 next_cache1[info.idx][91] = 1;
			 next_cache1[info.idx][90] = dcif.dmemWEN ? 1:0;
			 next_cache1[info.idx][89:64] = info.tag;
			 
			 if(info.blkoff)
			   begin
			      next_cache1[info.idx][31:0] = dload;
			      // Give the data to datapaht
			      dcif.dmemload = curr_cache1[info.idx][63:32];
			      next_cache1[info.idx][63:32] = dcif.dmemWEN ? dcif.dmemstore : curr_cache1[info.idx][63:32];
			      
			   end
			 else
			   begin
			      next_cache1[info.idx][31:0] = dcif.dmemWEN ? dcif.dmemstore : curr_cache1[info.idx][31:0];
			      
			      next_cache1[info.idx][63:32] = dload;
			      dcif.dmemload = curr_cache1[info.idx][31:0];
			   end
		      end // if (curr_used)
		    else
		      begin
			 // Update the next_used
			 next_used[info.idx] = 1;
		    
			 next_cache0[info.idx][91] = 1;
			 next_cache0[info.idx][90] = dcif.dmemWEN ? 1:0;
			 next_cache0[info.idx][89:64] = info.tag;
			 
			 if(info.blkoff)
			   begin
			      next_cache0[info.idx][31:0] = dload;
			      dcif.dmemload = curr_cache0[info.idx][63:32];
			      next_cache0[info.idx][63:32] = dcif.dmemWEN ? dcif.dmemstore : curr_cache0[info.idx][63:32];
			   end
			 else
			   begin
			      next_cache0[info.idx][63:32] = dload;
			      dcif.dmemload = curr_cache0[info.idx][31:0];
			      next_cache0[info.idx][31:0] = dcif.dmemWEN ? dcif.dmemstore : curr_cache0[info.idx][31:0];
			   end
		      end // else: !if(curr_used)

		 end // if (ccif.dwait == 0)
	       
	    end // case: READ2
	  WRITE1:
	    begin
	       // Turn on MEM write enable
	       dWEN = 1;
	       //ccif.daddr = dcif.dmemaddr;
	       if (curr_used[info.idx])
		 begin
		    dstore = info.blkoff ? curr_cache1[info.idx][63:32] : curr_cache1[info.idx][31:0];
		    daddr = {curr_cache1[info.idx][89:64], info.idx, info.blkoff, info.bytoff};
		    
		 end
	       else 
		 begin
		    dstore = info.blkoff ? curr_cache0[info.idx][63:32] : curr_cache0[info.idx][31:0];
		    daddr = {curr_cache0[info.idx][89:64], info.idx, info.blkoff, info.bytoff};
		    
		 end
	    end
	  WRITE2:
	    begin
	       dWEN = 1;

	       // Calculate the data address
	       //ccif.daddr = info.blkoff ? dcif.dmemaddr - 4 : dcif.dmemaddr + 4;
	       
	       if (curr_used[info.idx])
		 begin
		    // Give the data to mem. The data is from datapath
		    dstore = info.blkoff ? curr_cache1[info.idx][31:0] : curr_cache1[info.idx][63:32];
		    daddr = info.blkoff ? {curr_cache1[info.idx][89:64], info.idx, 1'b0, info.bytoff} : {curr_cache1[info.idx][89:64], info.idx, 1'b1, info.bytoff};
		    
		 end
	       else 
		 begin
		    dstore = info.blkoff ? curr_cache0[info.idx][31:0] : curr_cache0[info.idx][63:32];
		    daddr = info.blkoff ? {curr_cache0[info.idx][89:64], info.idx, 1'b0, info.bytoff} : {curr_cache0[info.idx][89:64], info.idx, 1'b1, info.bytoff};
		 end
	    end // case: WRITE2


	  SPCHK:
	    begin
	       if(sp_cache != 2'b11)
		 begin
		    // when match
		    if(sp_cache == 2'b00)
		      begin
	        
			 dstore = sp_blk ? curr_cache0[sp_idx][63:32] : curr_cache0[sp_idx][31:0];
			 
		      end
		    else
		      begin
	        
			 dstore = sp_blk ? curr_cache1[sp_idx][31:0] : curr_cache0[sp_idx][63:32];
			 
		      end
		    if(!ccinv)
		      begin
			 if(sp_cache == 2'b00 && sp_dirty0)
			   begin
			      // cache0: M to S
			      next_cache0[sp_idx][90] = 0;
			      ccwrite = 1;
			      			      
			   end
			 else if(sp_cache == 2'b01 && sp_dirty1)
			   begin
			      //cache1: M to S
			      next_cache1[sp_idx][90] = 0;
			      ccwrite = 1;
			      
			   end
		      end // if (!ccinv)
		    else
		      begin
			 if(sp_cache == 2'b00 && sp_dirty0)
			   begin
			      // cache0: M to I
			      next_cache0[sp_idx][90] = 0;
			      next_cache0[sp_idx][91] = 0;
			      ccwrite = 1;
			      
			   end
			 else if(sp_cache == 2'b01 && sp_dirty1)
			   begin
			      //cache1: M to I
			      next_cache1[sp_idx][90] = 0;
			      next_cache1[sp_idx][91] = 0;
			      ccwrite = 1;
			   end
			 else if(sp_cache == 2'b00 && !sp_dirty0)
			   begin
			      //cache0: S to I
			      next_cache0[sp_idx][90] = 0;
			      next_cache0[sp_idx][91] = 0;
			   end
			 else if(sp_cache == 2'b01 && !sp_dirty1)
			   begin
			      //cahce1: S to I
			      next_cache1[sp_idx][90] = 0;
			      next_cache1[sp_idx][91] = 0;
			   end
			 
		      end // else: !if(!ccinv)
			   
		 end // else: !if(sp_cache == 2'b11)
	    end // case: SPCHK

	  SP1:
	    begin
	       dWEN = 1;
	       daddr = (sp_cache == 2'b01) ? sp1_daddr1 : sp1_daddr0;
	       
	       if(sp_cache == 2'b00)
		 begin
		    next_cache0[sp_idx][90] = 0;
		    dstore = sp_blk ? curr_cache0[sp_idx][63:32] : curr_cache0[sp_idx][31:0];
		    
		 end
	       else
		 begin
		    next_cache1[sp_idx][90] = 0;
		    dstore = sp_blk ? curr_cache1[sp_idx][31:0] : curr_cache0[sp_idx][63:32];
		    
		 end
	       
	    end

	  SP2:
	    begin
	       dWEN = 1;
	       daddr = (sp_cache == 2'b01) ? sp2_daddr1 : sp2_daddr0;
	       if(sp_cache == 2'b00)
		 begin
		    dstore = sp_blk ? curr_cache0[sp_idx][31:0] : curr_cache0[sp_idx][63:32];
		    
		 end
	       else
		 begin
		    dstore = sp_blk ? curr_cache1[sp_idx][31:0] : curr_cache0[sp_idx][63:32];
		 end
	       
	    end
	  
	  
	  FLUSH0:
	    begin
	       flush_dirty0 = curr_cache0[curr_idx0][90];
	       
	       if(curr_cache0[curr_idx0][90] == 1)//If data is dirtry, write data to ram
		 begin
		    dWEN = 1;
		    dstore = curr_blkoff0 ? curr_cache0[curr_idx0][63:32] : curr_cache0[curr_idx0][31:0];
		    flush_tag = curr_cache0[curr_idx0][89:64];
		    
		    daddr = {curr_cache0[curr_idx0][89:64], curr_idx0[2:0], curr_blkoff0, 2'b0};
		    if(dwait == 0 && curr_blkoff0 == 0)
		      begin

			 
			 next_blkoff0 = 1;
		      end
		    else if(dwait == 0 && curr_blkoff0 == 1)
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
		    dWEN = 1;
		    dstore = curr_blkoff1 ? curr_cache1[curr_idx1][63:32] : curr_cache1[curr_idx1][31:0];
		    flush_tag = curr_cache1[curr_idx0][89:64];
		    daddr = {curr_cache1[curr_idx1][89:64], curr_idx1[2:0], curr_blkoff1, 2'b0};
		    if(dwait == 0 && curr_blkoff1 == 0)
		      begin
        
			 
			 next_blkoff1 = 1;
		      end
		    else if(dwait == 0 && curr_blkoff1 == 1)
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
	       //dWEN = 1;
	       dstore = curr_number;
	       daddr = 32'h3100;
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
