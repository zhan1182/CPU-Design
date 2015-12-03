`include "cache_control_if.vh"
`include "cpu_types_pkg.vh"

module coherency (
		  input logic 	    CLK,
		  input logic 	    nRST,
		  input logic [31:0]	    daddr0,
		  input logic [31:0]	    daddr1,
		  input logic [1:0] cctrans,
		  input logic [1:0] ccwrite,
		  input logic [1:0] dwait,
		  output logic [31:0]	    ccsnoopaddr0,
		  output logic [31:0]	    ccsnoopaddr1,
		  output logic [1:0]	    ccwait,
		  output logic [1:0]	    ccinv
		  );
   import cpu_types_pkg::*;

   typedef enum 	      {IDLE, SP0, SP1, core0_DW1, core0_DW2, core1_DW1, core1_DW2} coherence_state;

   coherence_state next_state, curr_state;

   always_ff @ (posedge CLK, negedge nRST)
     begin
	if(!nRST)
	  begin
	     curr_state <= IDLE;
	  end
	else
	  begin
	     curr_state <= next_state;
	  end
     end // always_ff @ (posedge CLK, negedge nRST)

   assign ccsnoopaddr0 = daddr1;
   assign ccsnoopaddr1 = daddr0;
   always @ (*)
     begin
	
	next_state = curr_state;
	ccinv = 0;
	ccwait = 0;
	
	case(curr_state)
	  IDLE:
	    begin
	       if(cctrans[0])
		 begin
		    ccwait[1] = 1;
		    next_state = SP1;
		 end
	       else if(cctrans[1])
		 begin
		    ccwait[0] = 1;
		    next_state = SP0;
		 end

	       ccinv[0] = ccwrite[1];
	       ccinv[1] = ccwrite[0];
	       

	       

	    end
	  SP0:
	    begin
	       if(ccwrite[0])
		 begin
		    next_state = core0_DW1;
		 end
	       else
		 begin
		    next_state = IDLE;
		 end
	       ccwait[0] = 1;
	       
	       
	    end
	  SP1:
	    begin
	       if(ccwrite[1])
		 begin
		    next_state = core1_DW1;
		 end
	       else
		 begin
		    next_state = IDLE;
		 end
	       ccwait[1] = 1;
	    end
	  
	  core0_DW1:
	    begin
	       if(!dwait[0])
		 begin
		    next_state = core0_DW2;
		 end
	       ccwait[0] = 1;
	       
	    end
	  core0_DW2:
	    begin
	       if(!dwait[0])
		 begin
		    next_state = IDLE;
		 end
	       ccwait[0] = 1;
	       
	    end
	  core1_DW1:
	    begin
	       if(!dwait[1])
		 begin
		    next_state = core1_DW2;
		 end
	       ccwait[1] = 1;
	       
	    end
	  core1_DW2:
	    begin
	       if(!dwait[1])
		 begin
		    next_state = IDLE;
		 end
	       ccwait[1] = 1;
	    end
	  
	endcase // case (curr_state)
	



     end
   




endmodule // coherency
