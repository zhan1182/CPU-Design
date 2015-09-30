
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"


// types
`include "cpu_types_pkg.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns


module memory_control_tb;
   // clock period
   parameter PERIOD = 20;
   
   // signals
   logic CLK = 1, nRST;
   
   // clock
   always #(PERIOD/2) CLK++;
   
   // interface
   cache_control_if ccif();
   cpu_ram_if ram_if();

   assign ccif.ramstate = ram_if.ramstate;
   assign ccif.ramload = ram_if.ramload;
   assign ram_if.ramREN = ccif.ramREN;
   assign ram_if.ramWEN = ccif.ramWEN;
   assign ram_if.ramstore = ccif.ramstore;
   assign ram_if.ramaddr = ccif.ramaddr;

   
   // test program
   test PROG (CLK,nRST,ccif);
   
  // dut
// `ifndef MAPPED
   memory_control DUT (CLK,nRST,ccif);
   ram RAM(CLK, nRST, ram_if);      
// `else
//   memory_control DUT (,,,,//for altera debug ports
// 		      CLK,
// 		      nRST,
// 		      ccif.ramWEN,
// 		      ccif.ramREN,
// 		      ccif.ramstate,
// 		      ccif.ramstore,
// 		      ccif.ramload,
// 		      ccif.iwait,
// 		      ccif.dwait,
// 		      ccif.iREN,
// 		      ccif.dREN,
// 		      ccif.dWEN,
// 		      ccif.iload,
// 		      ccif.dload,
// 		      ccif.dstore,
// 		      ccif.iaddr,
// 		      ccif.daddr
//   );
// `endif

   
endmodule

program test(input logic CLK, output logic nRST, cache_control_if ccif);
  // import word type
  import cpu_types_pkg::word_t;

  initial
    begin
       // Init
       parameter PERIOD = 20;
       
       nRST = 1'b0;
       #(PERIOD);
       nRST = 1'b1;
       #(PERIOD);


       // Test write
       for(int ct = 0; ct < 15; ct++)
	 begin
	    @(negedge CLK);
	    ccif.iREN = 2'b00;
	    ccif.dREN = 2'b00;
	    ccif.dWEN = 2'b01;       
	    ccif.daddr = ct * 4;
	    ccif.dstore = ct;
	    @(negedge ccif.dwait[0]);
	    #(PERIOD);
	 end

       // Test read data prior to read instruction
       for (int ct = 0; ct < 15; ct++)
	 begin
	    @(negedge CLK);
	    ccif.iREN = 2'b01;
	    ccif.dREN = 2'b01;
	    ccif.dWEN = 2'b00;       
	    ccif.daddr = ct * 4;
	    @(negedge ccif.dwait[0]);
	    #(PERIOD);
	    if (ccif.dload[0] == ct)
	      $display("Default Test Case PASSED");
	    else // Test case failed
	      $display("Default Test Case FAILED");
	 end

       // Test write data prior to read data and read instruction 
       for(int ct = 0; ct < 15; ct++)
	 begin
	    @(negedge CLK);
	    ccif.iREN = 2'b01;
	    ccif.dREN = 2'b01;
	    ccif.dWEN = 2'b01;       
	    ccif.daddr = ct * 4;
	    ccif.dstore = ct + 1;
	    @(negedge ccif.dwait[0]);
	    #(PERIOD);
	 end
       
       // Test read instruction
       for (int ct = 0; ct < 15; ct++)
	 begin
	    @(negedge CLK);
	    ccif.iREN = 2'b01;
	    ccif.dREN = 2'b00;
	    ccif.dWEN = 2'b00;       
	    ccif.iaddr = ct * 4;
	    @(negedge ccif.iwait[0]);
	    #(PERIOD);
	    if (ccif.iload[0] == ct + 1)
	      $display("Default Test Case PASSED");
	    else // Test case failed
	      $display("Default Test Case FAILED");
	 end
       
     
       dump_memory();
       $finish;
  end

  task automatic dump_memory();
    string filename = "memram.hex";
    int memfd;

    // ccif.tbCTRL = 1;
    ccif.daddr = 0;
    ccif.dWEN = 0;
    ccif.dREN = 0;

    memfd = $fopen(filename,"w");
    if (memfd)
      $display("Starting memory dump.");
    else
      begin $display("Failed to open %s.",filename); $finish; end

    for (int unsigned i = 0; memfd && i < 16384; i++)
    begin
      int chksum = 0;
      bit [7:0][7:0] values;
      string ihex;

      ccif.daddr = i << 2;
      ccif.dREN = 1;
      repeat (4) @(posedge CLK);
      if (ccif.dload[0] === 0)
        continue;
      values = {8'h04,16'(i),8'h00,ccif.dload[0]};
      foreach (values[j])
        chksum += values[j];
      chksum = 16'h100 - chksum;
      ihex = $sformatf(":04%h00%h%h",16'(i),ccif.dload[0],8'(chksum));
      $fdisplay(memfd,"%s",ihex.toupper());
    end //for
    if (memfd)
    begin
      // ccif.tbCTRL = 0;
      ccif.dREN = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
  endtask
endprogram

