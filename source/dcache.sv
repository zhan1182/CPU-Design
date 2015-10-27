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
   logic 		  curr_used, next_used;

   //logic [31:0]		  blk0, blk1; // the data block 0 and data block 1
   logic [31:0] 	  curr_data1, next_data1, curr_data2, next_data2; // data from first and second read or write
   

   logic 		  hit, miss;
   //logic 		  update; // use for update curr_cache
   logic [3:0] 		  curr_count, next_count; // flush count
   logic [2:0] 		  curr_blk, next_blk;
   logic [2:0] 		  curr_idx, next_idx; // index for flushing
   word_t next_hitnum, curr_hitnum;
   
   
   

   ///////// state machine /////////////
   typedef enum 	  logic [3:0] {IDLE, READ1, READ2, READ_WAIT1, READ_WAIT2, WRITE1, WRITE2, FLUSH1, FLUSH_WAIT1, FLUSH_WAIT2, HIT_WRITE, HIT_WAIT, DONE} cacheState;
   cacheState curr_state, next_state;


      // check this
   always_ff @ (posedge CLK, negedge nRST) begin
      if (nRST == 0) begin
	 curr_used <= 0;
	 
	 for(i = 0; i < 8; i++)begin
	    curr_cache1[i] <= 0;
	    curr_cache2[i] <= 0;
     	 end	 
      end
      else begin
	 curr_used <= next_used;

	 curr_cache1 <= next_cache1;
	 curr_cache2 <= next_cache2;
	 

      end
   end
   always_ff @ (posedge CLK, negedge nRST) begin
      if (nRST == 0) begin
	 curr_state <= IDLE;
	 curr_data1 <= 0;
	 curr_data2 <= 0;
	 curr_count <= 4'b0001;
	 curr_blk <= 3'b000;
	 curr_idx <= 0;
	 curr_hitnum <= 0;
	 
	 
	 
	 
	 
      end
      else begin
	 curr_state <= next_state;
	 curr_data1 <= next_data1;
	 curr_data2 <= next_data2;
	 curr_count <= next_count;
	 curr_blk <= next_blk;
	 curr_idx <= next_idx;
	 curr_hitnum <= next_hitnum;
	 
	 
	 
	 
	 
      end
     
   end // always_ff @

   
   always_comb begin
      next_state = IDLE;
      ccif.dREN = 0;
      ccif.dWEN = 0;
      ccif.daddr = 0;
      ccif.dstore = 0;
      next_data1 = curr_data1;
      next_data2 = curr_data2;
      next_count = curr_count;
      next_blk = curr_blk;
      next_idx = curr_idx;
      dcif.flushed = 0;
      
      
      
      
      case(curr_state)
	IDLE: begin
	   if (dcif.dmemREN && miss) begin
	      next_state = READ1;
	   end
	   else if(dcif.dmemWEN && miss && dirty) begin
	      next_state = WRITE1;
	   end
	   else if(dcif.halt == 1) begin
	      next_state = FLUSH1;
	   end
	   
	end
	READ1: begin
	   
	   ccif.daddr = dcif.dmemaddr;
	   ccif.dREN = 1;
	   next_state = READ_WAIT1;
	   
	   
	end // case: READ1
	READ_WAIT1: begin
	   if (ccif.dwait == 0) begin
	      next_state = READ2;
	      next_data1 = ccif.dload;
	      
	   end
	   else begin
	      next_state = READ_WAIT1;	      
	   end
	end
	
	READ2: begin
	   ccif.dREN = 1;
	   if(blkoff == 0) begin
	      ccif.daddr = dcif.dmemaddr + 4;
	   end
	   else begin
	      ccif.daddr = dcif.dmemaddr - 4;
	   end
	  
	end // case: READ2
	READ_WAIT2: begin
	    if (ccif.dwait == 0) begin
	      next_state = dirty == 0 ? IDLE : WRITE1;
	      next_data2 = ccif.dload;
	   end
	   else begin
	      next_state = READ_WAIT2;
	   end

	end
	
	WRITE1: begin
	   ccif.dWEN = 1;
	   ccif.daddr = dcif.dmemaddr;
	   if (curr_used == 0)begin
	      ccif.dstore = blkoff ? curr_cache2[idx][63:32] : curr_cache2[idx][31:0];
	   end
	   else begin
	      ccif.dstore = blkoff ? curr_cache1[idx][63:32] : curr_cache1[idx][31:0];
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
	   if (curr_used == 0)begin
	      ccif.dstore = blkoff ? curr_cache2[idx][63:32] : curr_cache2[idx][31:0];
	   end
	   else begin
	      ccif.dstore = blkoff ? curr_cache1[idx][63:32] : curr_cache1[idx][31:0];
	   end
	   
	   if (ccif.dwait == 0) begin
	      next_state = IDLE;
	   end
	   else begin
	      next_state = WRITE2;
	   end
	end // case: WRITE2
	
 	FLUSH1: begin
	   if(curr_count >= 17) begin
	      next_state = HIT_WRITE;
	   end
	   else if((curr_count <= 8 && curr_cache1[curr_idx][90] == 0) || (curr_count > 8 && curr_cache2[curr_idx][90] == 0))begin
	      next_count = curr_count + 1;
	      next_idx = curr_count == 8 ? 0:curr_idx + 1;
	      
	      next_state = FLUSH1;
	      next_blk = 3'b000;
	   end
	   
	   else if(curr_count <= 8 && curr_cache1[curr_idx][90] == 1 && curr_blk == 0)begin
	      ccif.dWEN = 1;
	      ccif.dstore = curr_cache1[curr_idx][31:0];
	      ccif.daddr = {curr_cache1[curr_idx][89:64], curr_idx, curr_blk};
	      //next_blk = 3'b100;
	      next_state = FLUSH_WAIT1;
	      
	   end
	   
	   else if(curr_count <= 8 && curr_cache1[curr_idx][90] == 1 && curr_blk == 3'b100) begin
	      ccif.dWEN = 1;
	      ccif.dstore = curr_cache1[curr_idx][63:32];
	      ccif.daddr = {curr_cache1[curr_idx][89:64], curr_idx, curr_blk};
	      //next_count = curr_count + 1;
	      //next_blk = 3'b000;
	      next_state = FLUSH_WAIT2;
	   end
	   else if(curr_count > 8 && curr_cache2[curr_idx][90] == 1 && curr_blk == 0) begin
	      ccif.dWEN = 1;
	      ccif.dstore = curr_cache2[curr_idx][31:0];
	      ccif.daddr = {curr_cache2[curr_idx][89:64], curr_idx, curr_blk};
	      next_state = FLUSH_WAIT1;
	   end
	   else if(curr_count > 8 && curr_cache2[curr_idx][90] == 1 && curr_blk == 3'b100) begin
	      ccif.dWEN = 1;
	      ccif.dstore = curr_cache2[curr_idx][63:32];
	      ccif.daddr = {curr_cache2[curr_idx][89:64], curr_idx, curr_blk};
	      next_state = FLUSH_WAIT2;
	   end
	   	   
	end // case: FLUSH1
	
	
	FLUSH_WAIT1: begin
	   if(ccif.dwait == 0)begin
	      next_blk = 3'b100;
	      next_state = FLUSH1;
	   end
	   else begin
	      next_state = FLUSH_WAIT1;
	   end
	end
	
	
	FLUSH_WAIT2: begin
	   if(ccif.dwait == 0)begin
	      next_blk = 3'b000;
	      next_count = curr_count + 1;
	      next_idx = curr_count == 8 ? 0:curr_idx + 1;
	      
	      next_state = FLUSH1;
	   end
	   else begin
	      next_state = FLUSH_WAIT2;
	   end
	end // case: FLUSH_WAIT2

	HIT_WRITE: begin
	   ccif.dWEN = 1;
	   ccif.dstore = curr_hitnum;
	   ccif.daddr = 32'h3100;
	   next_state = HIT_WAIT;
	end
	HIT_WAIT: begin
	   if(ccif.dwait == 0)begin
	      next_state = DONE;
	   end
	   else begin
	      next_state = HIT_WAIT;
	   end
	end
	DONE: begin
	   dcif.flushed = 1;
	end
	
			 
      endcase // case (curr_state)
      
   end // always_comb
   
   


   
   //assign data = blkoff*32 + 31; //the left most bit # of chosen data block
   assign tag = dcif.dmemaddr[31:31-DTAG_W+1];
   assign idx = dcif.dmemaddr[31-DTAG_W:31-DTAG_W-DIDX_W+1];
   assign blkoff = dcif.dmemaddr[31-DTAG_W-DIDX_W:31-DTAG_W-DIDX_W-DBLK_W+1];
   assign bytoff = dcif.dmemaddr[31-DTAG_W-DIDX_W-DBLK_W:0];



   

   
   always_comb begin
      hit = 0;
      miss = 0;
      next_cache1 = curr_cache1;
      next_cache2 = curr_cache2;
      dcif.dmemload = 0;
      dirty = 0;
      //update = 0;
      next_used = curr_used;
      next_hitnum = curr_hitnum;
      dcif.dhit = 0;
      valid = 0;
      
      
      
      if (dcif.dmemREN == 1) begin
	 if (tag == curr_cache1[idx][89:89-DTAG_W+1] && curr_cache1[idx][91] == 1) begin
	    dcif.dmemload = blkoff ? curr_cache1[idx][63:32] : curr_cache1[idx][31:0];
	    hit = 1;
	    next_used = 0;
	    next_hitnum = curr_hitnum + 1;
	    dcif.dhit = 1;
	    
	    
	    
	 end
	 else if (tag == curr_cache2[idx][89:89-DTAG_W+1] && curr_cache2[idx][91] == 1) begin
	    //check other table
	    dcif.dmemload = blkoff ? curr_cache2[idx][63:32] : curr_cache2[idx][31:0];
	    hit = 1;
	    next_used = 1;
	    next_hitnum = curr_hitnum + 1;
	    dcif.dhit = 1;
	    
	 end
	 else begin
	    // read from ram
	    miss = 1;
	    dirty = curr_used ? curr_cache1[idx][90] : curr_cache2[idx][90];
	    valid = curr_cache1[idx][91] && curr_cache2[idx][91];
	    
	    if (curr_state == READ_WAIT2 && !ccif.dwait && valid == 0) begin
	       dcif.dmemload = curr_data1;
	       //update = 1;
	       dcif.dhit = 1;
	       
	       if (curr_cache1[idx][91] == 0) begin
		  // cache 1 invalid, empty
		  next_used = 0;
		  if (blkoff == 0) begin
		     next_cache1[idx] = {1'b1, 1'b0, tag, next_data2, curr_data1};
		  end
		  else begin
		     next_cache1[idx] = {1'b1, 1'b0, tag, curr_data1, next_data2};
		  end
		  
	       end
	       else if (curr_cache2[idx][91] == 0) begin
		  if (blkoff == 0) begin
		     next_cache2[idx] = {1'b1, 1'b0, tag, next_data2, curr_data1};
		  end
		  else begin
		     next_cache2[idx] = {1'b1, 1'b0, tag, curr_data1, next_data2};
		  end
		  next_used = 1;
		  
	       end
	    end // if (curr_state == READ2 && !ccif.dwait && valid == 0)
	    
	    else if (curr_state == READ_WAIT2 && !ccif.dwait && dirty == 0) begin
	       dcif.dhit = 1;
 
	       if (curr_used == 0) begin
		  next_used = 1;
		  
		  if (blkoff == 0) begin
		     next_cache2[idx] = {1'b1, 1'b0, tag, next_data2, curr_data1};
		  end
		  else begin
		     next_cache2[idx] = {1'b1, 1'b0, tag, curr_data1, next_data2};
		  end
	       end
	       else begin
		  next_used = 0;
		  
		  if (blkoff == 0) begin
		     next_cache1[idx] = {1'b1, 1'b0, tag, next_data2, curr_data1};
		  end
		  else begin
		     next_cache1[idx] = {1'b1, 1'b0, tag, curr_data1, next_data2};
		  end
		  
	       end // else: !if(used == 0)
		  
	    end // if (curr_state == READ2 && !ccif.dwait && dirty == 0)
	    
	    else if (curr_state == WRITE2 && !ccif.dwait && dirty == 1) begin
	       dcif.dhit = 1;
	       
	       if (curr_used == 0) begin
		  next_used = 1;
		  
		  if (blkoff == 0) begin
		     next_cache2[idx] = {1'b1, 1'b0, tag, next_data2, curr_data1};
		  end
		  else begin
		     next_cache2[idx] = {1'b1, 1'b0, tag, curr_data1, next_data2};
		  end
		  
	       end
	       
	       else begin
		  next_used = 0;
		  
		  if (blkoff == 0) begin
		     next_cache1[idx] = {1'b1, 1'b0, tag, next_data2, curr_data1};
		  end
		  else begin
		     next_cache1[idx] = {1'b1, 1'b0, tag, curr_data1, next_data2};
		  end
	       end // else: !if(used == 0)
	       dcif.dmemload = curr_data1;
	       //update = 1;
	    end // if (curr_state = WRITE2 && !ccif.dwait && dirty == 1)
	 end // else: !if(tag == curr_cache2[idx][89:89-DTAG_W+1] && curr_cache2[idx][91] == 1)
      end // if (dcif.dmemREN == 1)
      else if (dcif.dmemWEN == 1) begin
	 valid = curr_cache1[idx][91] && curr_cache2[idx][91];
	 if (valid == 0) begin
	    //update = 1;
	    dcif.dhit = 1;
	    if (curr_cache1[idx][91] == 0) begin
	       // cache 1 invalid, empty
	       next_used = 0;
	       
	       
	       next_cache1[idx][90] = 1;
	       next_cache1[idx][91] = 1;
	       
	       if (blkoff == 0) begin
		  next_cache1[idx][31:0] = dcif.dmemstore;
	       end
	       else begin
		  next_cache1[idx][63:32] = dcif.dmemstore;
	       end

	    end
	    else if (curr_cache2[idx][91] == 0) begin
	       next_cache2[idx][90] = 1;
	       next_cache2[idx][91] = 1;
	       
	       if (blkoff == 0) begin
		  next_cache2[idx][31:0] = dcif.dmemstore;
	       end
	       else begin
		  next_cache2[idx][63:32] = dcif.dmemstore;
	       end
	       next_used = 1;
	       
	    end
	 end // if (valid == 0)
	 else if (tag == curr_cache1[idx][89:89-DTAG_W+1]) begin
	    hit = 1;
	    next_hitnum = curr_hitnum + 1;
	    
	    next_used = 0;
	    //update = 1;
	    dcif.dhit = 1;
	    
	    next_cache1[idx][90] = 1;
	    
	    if (blkoff == 1) begin
	       next_cache1[idx][63:32] = dcif.dmemstore;
	    end
	    else begin
	       next_cache1[idx][31:0] = dcif.dmemstore;
	    end
	    
	 end // if (tag == curr_cache1[id][89:89-DTAG_W+1])
	 
	 else if (tag == curr_cache2[idx][89:89-DTAG_W+1]) begin
	    //check other table
	    hit = 1;
	    next_hitnum = curr_hitnum + 1;
	    
	    next_used = 1;
	    //update = 1;
	    dcif.dhit = 1;
	    
	    next_cache2[idx][90] = 1;
	    
	    if (blkoff == 1) begin
	       next_cache2[idx][63:32] = dcif.dmemstore;
	    end
	    else begin
	       next_cache2[idx][31:0] = dcif.dmemstore;
	    end
	 end // if (tag == curr_cache2[idx][89:89-DTAG_W+1])
	 
	 else begin
	    // check dirty
	    dirty = curr_used ? curr_cache1[idx][90] : curr_cache2[idx][90];
	    miss = 1;
	    if (dirty == 0) begin
	       if(curr_used == 0)begin
		  next_cache2[idx][90] = 1;
		  //update = 1;
		  next_cache2[idx][89:64] = tag;
		  dcif.dhit = 1;
		  
		  if (blkoff == 1) begin
		     next_cache2[idx][63:32] = dcif.dmemstore;
		  end
		  else begin
		     next_cache2[idx][31:0] = dcif.dmemstore;
		  end
	       end // if (used == 0)
	       else begin
		  next_cache1[idx][90] = 1;
		  //update = 1;
		  dcif.dhit = 1;
		  
		  next_cache2[idx][89:64] = tag;
		  if (blkoff == 1) begin
		     next_cache1[idx][63:32] = dcif.dmemstore;
		  end
		  else begin
		     next_cache1[idx][31:0] = dcif.dmemstore;
		  end
	       end // else: !if(used == 0)
	    end // if (dirty == 0)
	    else begin
	       // miss = 1, dirty = 1, goto WRITE1, write old into ram, overwrite new to cache
	       if (curr_state == WRITE2 && !ccif.dwait) begin
		  dcif.dhit = 1;
		  
		  if(curr_used == 0)begin
		     next_cache2[idx][90] = 1;
		     //update = 1;
		     next_cache2[idx][89:64] = tag;
		     if (blkoff == 1) begin
			next_cache2[idx][63:32] = dcif.dmemstore;
		     end
		     else begin
			next_cache2[idx][31:0] = dcif.dmemstore;
		     end
		  end // if (used == 0)
		  else begin
		     next_cache1[idx][90] = 1;
		     //update = 1;
		     next_cache2[idx][89:64] = tag;
		     if (blkoff == 1) begin
			next_cache1[idx][63:32] = dcif.dmemstore;
		     end
		     else begin
			next_cache1[idx][31:0] = dcif.dmemstore;
		     end
		  end // else: !if(used == 0)
	       end // if (curr_state == WRITE2 && !ccif.dwait)
	    end // else: !if(dirty == 0)
	 end // else: !if(tag == curr_cache2[idx][89:89-DTAG_W+1])
      end // if (dcif.dmemWEN == 1)
      
	    
	       
	 
   end // always_comb
   




      
   //    if (used == 0) //table 1 was used last time
   // 	begin
   // 	   used = 1;
   // 	   dcif.dhit = (dcif.dmemREN|dcif.dmemWEN) ? ~ccif.dwait : 0; //??
   // 	   dcif.dmemload = 0;
   // 	   hit = 0;
   // 	   miss = 0;
   // 	   valid = 0;
   // 	   dirty = 0;
   // 	   next_cache2[idx] = curr_cache2[idx];
   // 	   update = 0;
   // 	   blk0 = curr_cache2[idx][31:0];
   // 	   blk1 = curr_cache2[idx][63:32];
	   
	   
   // 	   if (dcif.dmemREN == 1) begin
   // 	      if (tag == curr_cache2[idx][89:89-DTAG_W+1]) begin
   // 		 dcif.dmemload = blkoff ? blk1 : blk0;
   // 		 hit = 1;
   // 	      end
   // 	      else begin
   // 		 miss = 1;
   // 		 dirty = 0;
   // 		 valid = 1;
   // 		 if (curr_state == READ2 && !ccif.dwait) begin
   // 		    if (blkoff == 0) begin
   // 		       next_cache2[idx] = {valid, dirty, next_data2, curr_data1};
   // 		    end
   // 		    else begin
   // 		       next_cache2[idx] = {valid, dirty, curr_data1, next_data2};
   // 		    end
   // 		    dcif.dmemload = curr_data1;
   // 		    update = 1;
		    
   // 		 end
   // 	      end
   // 	   end
   // 	   else if (dcif.dmemWEN == 1) begin
   // 	      if (tag == curr_cache2[idx][89:89-DTAG_W+1]) begin
   // 		 hit = 1;
   // 		 dirty = 1;
   // 		 valid = 1;
   // 		 next_cache2[idx][91] = valid;
   // 		 next_cache2[idx][90] = dirty;
   // 		 if (blkoff == 1) begin
   // 		    next_cache2[idx][63:32] = dcif.dmemstore;
   // 		 end
   // 		 else begin
   // 		    next_cache2[idx][31:0] = dcif.dmemstore;
   // 		 end
		 
   // 		 update = 1;
		 
   // 	      end
   // 	      else begin
   // 		 miss = 1;
   // 		 valid = 1;
		 
   // 		 if (dirty == 0) begin
   // 		    dirty = 1;
   // 		    next_cache2[idx][91] = valid;
   // 		    next_cache2[idx][90] = dirty;
   // 		    if (blkoff == 1) begin
   // 		       next_cache2[idx][63:32] = dcif.dmemstore;
   // 		    end
   // 		    else begin
   // 		       next_cache2[idx][31:0] = dcif.dmemstore;
   // 		    end
		    
   // 		    update = 1;
		    
   // 		 end
   // 		 else begin
   // 		    if (curr_state == WRITE2 && !ccif.dwait) begin
   // 		       next_cache2[idx][91] = valid;
   // 		       if (blkoff == 1) begin
   // 			  next_cache2[idx][63:32] = dcif.dmemstore;
   // 		       end
   // 		       else begin
   // 			  next_cache2[idx][31:0] = dcif.dmemstore;
   // 		       end
		       
   // 		       update = 1;
		       
   // 		    end
   // 		 end // else: !if(dirty == 0)
   // 	      end // else: !if(tag == curr_cache2[idx][89:89-DTAG_W+1])
   // 	   end
   //   	end
      
      
   //    else begin
   // 	 // table 2 was used last time
   // 	 used = 0;
	 
   // 	 dcif.dhit = (dcif.dmemREN|dcif.dmemWEN) ? ~ccif.dwait : 0; //??
   // 	 dcif.dmemload = 0;
   // 	 hit = 0;
   // 	 miss = 0;
   // 	 valid = 1;
   // 	 dirty = 0;
   // 	 next_cache1[idx] = curr_cache1[idx];
   // 	 blk0 = curr_cache1[idx][31:0];
   // 	 blk1 = curr_cache1[idx][63:32];
	 
   // 	 if (dcif.dmemREN == 1) begin
   // 	    if (tag == curr_cache1[idx][89:89-DTAG_W+1]) begin
   // 	       if(blkoff == 1) begin
   // 		  dcif.dmemload = blk1;
   // 	       end
   // 	       else begin
   // 		  dcif.dmemload = blk0;
   // 	       end
	       
	       
   // 	       hit = 1;
   // 	    end
   // 	    else begin
   // 	       miss = 1;
   // 	       dirty = 0;
   // 	       valid = 1;
   // 	       if (curr_state == READ2 && !ccif.dwait) begin
   // 		  if (blkoff == 0) begin
   // 		     next_cache1[idx] = {valid, dirty, next_data2, curr_data1};
		     
   // 		  end
   // 		  else begin
   // 		     next_cache1[idx] = {valid, dirty, curr_data1, next_data2};
   // 		  end
   // 		  dcif.dmemload = curr_data1;
   // 		  update = 1;
		  
   // 	       end
   // 	     end
   // 	 end
   // 	 else if (dcif.dmemWEN == 1) begin
   // 	    if (tag == curr_cache1[idx][89:89-DTAG_W+1]) begin
   // 	       hit = 1;
   // 	       dirty = 1;
   // 	       valid = 1;
   // 	       next_cache1[idx][91] = valid;
   // 	       next_cache1[idx][90] = dirty;
   // 	       if(blkoff == 1)begin
   // 		  next_cache1[idx][63:32] = dcif.dmemstore;
   // 	       end
   // 	       else begin
   // 		  next_cache1[idx][31:0] = dcif.dmemstore;
   // 	       end
	       
   // 	       update = 1;
	       
   // 	    end
   // 	    else begin
   // 	       miss = 1;
   // 	       valid = 1;
	       
   // 	       if (dirty == 0) begin
   // 		  dirty = 1;
   // 		  next_cache1[idx][91] = valid;
   // 		  next_cache1[idx][90] = dirty;
   // 		  if(blkoff == 1) begin
   // 		     next_cache1[idx][63:32] = dcif.dmemstore;
   // 		  end
   // 		  else begin
   // 		     next_cache1[idx][31:0] =dcif.dmemstore;
   // 		  end
		  
		  
   // 		  update = 1;
		  
   // 	       end
   // 	       else begin
   // 		  if (curr_state == WRITE2 && !ccif.dwait) begin
   // 		     next_cache1[idx][91] = valid;
   // 		     if(blkoff == 1) begin
   // 			next_cache1[idx][63:32] = dcif.dmemstore;
   // 		     end
   // 		     else begin
   // 			next_cache1[idx][31:0] =dcif.dmemstore;
   // 		     end
		     
   // 		     update = 1;
		     
   // 		  end
   // 	       end // else: !if(dirty == 0)
   // 	    end // else: !if(tag == curr_cache2[idx][89:89-DTAG_W+1])
   // 	 end
   //    end // else: !if(used == 0
   // end // always_comb

endmodule // dcache

