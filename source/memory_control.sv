/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 2;


   logic curr_selected, next_selected, other;
   
   typedef enum logic [2:0] {IDLE, DW1, DW2, DR1, DR2, IR, SP}coherence_state;
   coherence_state curr_state, next_state;
   
   
   // assign ccif.ramWEN = ccif.dWEN;
   // assign ccif.ramREN = (ccif.dREN | ccif.iREN) & (~ccif.dWEN);
   // assign ccif.ramaddr = (ccif.dWEN | ccif.dREN) ? ccif.daddr:((ccif.iREN == 1)?ccif.iaddr:0);
   

   // assign ccif.ramstore = ccif.dstore;
   // assign ccif.dload = ccif.ramload;
   // assign ccif.iload = (ccif.iREN == 1) ? ccif.ramload:0;

   // assign ccif.iwait = (ccif.ramstate == ACCESS) ? (((ccif.iREN == 1)&&(ccif.dREN == 0)&&(ccif.dWEN == 0))?0:1):1;
   // assign ccif.dwait = (ccif.ramstate == ACCESS) ? (((ccif.dREN == 1)||(ccif.dWEN == 1))?0:1):1;

   assign other = ~curr_selected;
   
   
   always_ff @ (posedge CLK, negedge nRST)
     begin
	if (!nRST)
	  begin
	     curr_state <= IDLE;
	     curr_selected <= 0;
	     
	     
	  end
	else
	  begin
	     curr_state <= next_state;
	     curr_selected <= next_selected;
	     
	  end
     end // always_ff @ (posedge CLK, negedge nRST)

   // state machine controller
   always_comb
     begin
	next_state = curr_state;
	next_selected = curr_selected;
	
	
	case(curr_state)
	  IDLE:
	    begin
	       // when data write
	       if(ccif.dWEN != 2'b00)
		 begin
		    next_state = DW1;
		    next_selected = ccif.dWEN[0] ? 0:1;
		    
		    
		 end
	       else if(ccif.dREN != 2'b00)
		 begin
		    next_state = DR1;
		    next_selected = ccif.dREN[0] ? 0 : 1;
		 end
	       
	       else if(ccif.cctrans != 2'b00)
		 begin
		    next_state = SP;
		    next_selected = ccif.cctrans[0] ? 0:1;
		    		    
		 end
	       // for instruction iread
	       else if(ccif.iREN != 2'b00)
		 begin
		    next_state = IR;
		    next_selected = ccif.iREN[0] ? 0:1;
		    
		 end
	       
	    end
	  DW1:
	    begin
	       ///????????
	       if(ccif.ramstate == ACCESS)
		 begin
		    next_state = DW2;
		 end
	       
	    end
	  DW2:
	    begin
	       //???????
	       if(ccif.ramstate == ACCESS)
		 begin
		    next_state = IDLE;
		 end
	       
	    end
	  DR1:
	    begin
	       if(ccif.ramstate == ACCESS)
		 begin
		    next_state = DR2;
		 end
	       
	    end
	  DR2:
	    begin
	       if(ccif.ramstate == ACCESS)
		 begin
		    next_state = IDLE;
		 end
	       

	    end
	  IR:
	    begin
	       if(ccif.ramstate == ACCESS)
		 begin
		    next_state = IDLE;
		 end
	       

	    end
	  SP:
	    begin
	       if(ccif.ccwrite[other] == 1)
		 begin
		    next_state = DW1;
		    next_selected = other;
		    
		 end

	    end
	  
	  


	endcase // case (curr_state)

     end


      // memory/ram controller
   always_comb
     begin
        ccif.ramstore = 0;
	ccif.ramaddr = 0;
	ccif.ramWEN = 0;
	ccif.ramREN = 0;

	ccif.ccwait = 0;
	ccif.ccinv = 0;
	ccif.ccsnoopaddr = ccif.daddr;

	ccif.iwait = 2'b11;
	ccif.dwait = 2'b11;
	ccif.iload[0] = 32'hBAD0BAD0;
	ccif.iload[1] = 32'hBAD1BAD1;
	
	ccif.dload[0] = 32'hBAD0BAD0; //???????
	ccif.dload[1] = 32'hBAD1BAD1;
	
	case(curr_state)
	  IDLE:
	    begin
	       if(ccif.cctrans != 2'b00)
		 begin
		    ccif.ccwait[ccif.cctrans[0]?1:0] = 1;
		 end
	       
	       
	    end
	  DW1:
	    begin
	       ccif.ramstore = ccif.dstore[curr_selected];
	       ccif.ramaddr = ccif.daddr[curr_selected];
	       ccif.ramWEN = 1;
	       ccif.ccwait[curr_selected] = 1;
	       
	       ccif.iwait[curr_selected] = 1;
	       if(ccif.ramstate == ACCESS)
		 begin
		    ccif.dwait[curr_selected] = 0;
		 end
	       
	    end
	  DW2:
	    begin
	       ccif.ramstore = ccif.dstore[curr_selected];
	       ccif.ramaddr = ccif.daddr[curr_selected];
	       ccif.ramWEN = 1;
	       ccif.ccwait[curr_selected] = 1;
	       
	       ccif.iwait[curr_selected] = 1;
	       if(ccif.ramstate == ACCESS)
		 begin
		    ccif.dwait[curr_selected] = 0;
		 end
	    end
	  DR1:
	    begin
	       ccif.ramREN = 1;
	       ccif.ramaddr = ccif.daddr[curr_selected];

	       ccif.dload[curr_selected] = ccif.ramload;
	       if(ccif.ramstate == ACCESS)
		 begin
		    ccif.dwait[curr_selected] = 0;
		    
		 end
	    end
	  DR2:
	    begin
	       ccif.ramREN = 1;
	       ccif.ramaddr = ccif.daddr[curr_selected];

	       ccif.dload[curr_selected] = ccif.ramload;
	       if(ccif.ramstate == ACCESS)
		 begin
		    ccif.dwait[curr_selected] = 0;
		    
		 end
	    end
	  IR:
	    begin
	       ccif.ramREN = 1;
	       ccif.ramaddr = ccif.iaddr[curr_selected];

	       ccif.iload[curr_selected] = ccif.ramload;
	       if (ccif.ramstate == ACCESS)
		 begin
		    ccif.iwait[curr_selected] = 0;
		 end
	       
	    end
	  SP:
	    begin
	       ccif.ramstore = ccif.dstore[other];
	       ccif.ramaddr = ccif.daddr[other];
	       ccif.ramWEN = ccif.dWEN[other];
	       
	       ccif.ccwait[other] = 1;
	       ccif.ccinv[other] = ccif.ccwrite[curr_selected];

	       if(curr_selected == 1)
		 begin
		    ccif.dload[curr_selected] = ccif.dWEN[other] ? ccif.dstore[other] : 32'hBAD1BAD1; //????
		 end
	       else
		 begin
		    ccif.dload[curr_selected] = ccif.dWEN[other] ? ccif.dstore[other] : 32'hBAD0BAD0; //????
		 end
	       
	       if(ccif.ramstate == ACCESS)
		 begin
		    ccif.dwait = ccif.dWEN[other] ? 0 : 2'b11;
		 end
	       
	    end
	  


	endcase // case (curr_state)
     end // always_comb begin


   // // coherence/bus controller
   // always_comb
   //   begin
   // 	ccif.ccwait = 0;
   // 	ccif.ccinv = 0;
   // 	ccif.ccsnoopaddr = ccif.daddr[curr_selected];
	
	
   // 	case(curr_state)
   // 	  IDLE:
   // 	    begin

	       
   // 	    end
   // 	  DW1:
   // 	    begin
	       
	       
		    
   // 	    end
   // 	  DW2:
   // 	    begin

   // 	    end
   // 	  DR1:
   // 	    begin

   // 	    end
   // 	  DR2:
   // 	    begin

   // 	    end
   // 	  IR:
   // 	    begin

   // 	    end
   // 	  SP:
   // 	    begin
   // 	       ccif.ccwait[other] = 1;
   // 	       ccif.ccinv[other] = ccif.ccwrite[curr_selected];
	       
   // 	    end
	  


   // 	endcase // case (curr_state)
   //   end // always_comb begin


   
   // // cache controller
   // always_comb
   //   begin
   //      ccif.iwait = 2'b11;
   // 	ccif.dwait = 2'b11;
   // 	ccif.iload[0] = 32'hBAD0BAD0;
   // 	ccif.iload[1] = 32'hBAD1BAD1;
	
   // 	ccif.dload[0] = 32'hBAD0BAD0; //???????
   // 	ccif.dload[1] = 32'hBAD1BAD1;
	
   // 	ccif.ccwait = 0;
   // 	ccif.ccinv = 0;
   // 	ccif.ccsnoopaddr = ccif.daddr[curr_selected];
	
	
   // 	case(curr_state)
   // 	  IDLE:
   // 	    begin

	       
   // 	    end
   // 	  DW1:
   // 	    begin
   // 	       ccif.iwait[curr_selected] = 1;
   // 	       if(ccif.ramstate == ACCESS)
   // 		 begin
   // 		    ccif.dwait[curr_selected] = 0;
   // 		 end
	       
   // 	    end
   // 	  DW2:
   // 	    begin
   // 	       ccif.iwait[curr_selected] = 1;
   // 	       if(ccif.ramstate == ACCESS)
   // 		 begin
   // 		    ccif.dwait[curr_selected] = 0;
   // 		 end
	       
   // 	    end
   // 	  DR1:
   // 	    begin
   // 	       ccif.dload[curr_selected] = ccif.ramload;
   // 	       if(ccif.ramstate == ACCESS)
   // 		 begin
   // 		    ccif.dwait[curr_selected] = 0;
		    
   // 		 end
	       
   // 	    end
   // 	  DR2:
   // 	    begin
   // 	       ccif.dload[curr_selected] = ccif.ramload;
   // 	       if(ccif.ramstate == ACCESS)
   // 		 begin
   // 		    ccif.dwait[curr_selected] = 0;
		    
   // 		 end

   // 	    end
   // 	  IR:
   // 	    begin
   // 	       ccif.iload[curr_selected] = ccif.ramload;
   // 	    end
   // 	  SP:
   // 	    begin
   // 	       if(curr_selected == 1)
   // 		 begin
   // 		    ccif.dload[curr_selected] = ccif.dWEN[other] ? ccif.dstore[other] : 32'hBAD1BAD1; //????
   // 		 end
   // 	       else
   // 		 begin
   // 		    ccif.dload[curr_selected] = ccif.dWEN[other] ? ccif.dstore[other] : 32'hBAD0BAD0; //????
   // 		 end
	       
   // 	       if(ccif.ramstate == ACCESS)
   // 		 begin
   // 		    ccif.dwait = ccif.dWEN[other] ? 0 : 2'b11;
   // 		 end
	       
	       
   // 	    end
	  


   // 	endcase // case (curr_state)
   //   end // always_comb begin




   

   
   

   
   
   /*
   always_comb
     begin
   	ccif.dwait = 1;
   	ccif.iwait = 1;
	/*
	ccif.ramWEN = 0;
	ccif.ramREN = 0;

	if(ccif.dREN || ccif.iREN)begin
	   if(ccif.dWEN == 0)begin
	      ccif.ramREN = 1;
	      ccif.ramWEN = 0;
	      
	   end
	end
	if(ccif.dWEN == 1 && ccif.iREN == 1)begin
	   ccif.ramWEN = 1;
	   ccif.ramREN = 0;
	end
	if(ccif.dWEN == 1 && ccif.dREN == 1)begin
	   ccif.ramWEN = 1;
	   ccif.ramREN = 0;
	end
	if(ccif.dWEN == 1 && ccif.dREN == 0 && ccif.iREN == 0)begin
	   ccif.ramWEN = 1;
	   ccif.ramREN = 0;
	end
	if(ccif.dWEN == 1 && ccif.dREN == 1 && ccif.iREN == 1)begin
	   ccif.ramWEN = 1;
	   ccif.ramREN = 0;
	end
	
	
   	casez(ccif.ramstate)

   	  FREE:
   	    begin
   	    end
   	  BUSY:
   	    begin
   	    end
   	  ACCESS:
   	    begin
   	       if(ccif.dWEN || ccif.dREN)
   		 begin
   		    ccif.dwait = 0;
   		 end
   	       if(ccif.iREN == 1 && ccif.dREN == 0 && ccif.dWEN == 0)
   		 begin
   		    ccif.iwait = 0;
   		 end
   	    end // case: ACCESS
   	  ERROR:
   	    begin
   	    end
	  
   	endcase // case (ccif.ramstate)
	
     end*/
endmodule
