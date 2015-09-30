/*
 han221@purdue.edu
 Zhaoyang Han
 */

// interface
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
   cpu_ram_if crif();
    assign ccif.ramload = crif.ramload;
   assign ccif.ramstate = crif.ramstate;
   assign crif.ramstore = ccif.ramstore;
   assign crif.ramaddr = ccif.ramaddr;
   assign crif.ramWEN = ccif.ramWEN;
   assign crif.ramREN = ccif.ramREN;
  

  // test program
  test                                PROG (CLK,nRST,ccif);

  // dut
  memory_control                              DUT (CLK,nRST,ccif);
   ram sb (CLK, nRST, crif);

   
endmodule

program test(input logic CLK, output logic nRST, cache_control_if ccif);
  // import word type
  import cpu_types_pkg::word_t;

  // number of cycles
  int unsigned cycles = 0;

  initial
    begin
       nRST = 0;
       @(negedge CLK);
       
     nRST = 1;
     ccif.dstore = 0;
     ccif.iREN = 0;
     ccif.dREN = 0;
     ccif.dWEN = 0;
   
     ccif.iaddr = 0;
     ccif.daddr = 0;

       @(posedge CLK);
       
     //test 1 read instruction
     @(negedge CLK);
     ccif.iREN = 1;
       ccif.iaddr = 32'h0004;
       #(20ns);
       

     // test 2 read data
     @(negedge CLK);
    
     ccif.iREN = 0;
     ccif.dREN = 1;
       ccif.daddr = 32'h0008;
       
       #(20ns);
       

     //test 3 write data
     @(negedge CLK);
     ccif.dREN = 0;
     ccif.dWEN = 1;
     ccif.dstore = 32'h00F0;
       ccif.daddr = 32'h0004;
       
       @(posedge CLK);
     #(20ns);
     if (ccif.ramstore == ccif.dstore) begin
     	$display("test 3 write data PASSED.");
     end

       @(negedge CLK);
     ccif.dREN = 0;
     ccif.dWEN = 1;
     ccif.dstore = 32'h00F0;
       ccif.daddr = 32'h0008;
       
       @(posedge CLK);
     #(20ns);

          @(negedge CLK);
     ccif.dREN = 0;
     ccif.dWEN = 1;
     ccif.dstore = 32'h00F0;
       ccif.daddr = 32'h0012;
       
       @(posedge CLK);
     #(20ns);

          @(negedge CLK);
     ccif.dREN = 0;
     ccif.dWEN = 1;
     ccif.dstore = 32'h00F0;
       ccif.daddr = 32'h0016;
       
       @(posedge CLK);
     #(20ns);
          @(negedge CLK);
     ccif.dREN = 0;
     ccif.dWEN = 1;
     ccif.dstore = 32'hABCD;
       ccif.daddr = 32'h0020;
       
       @(posedge CLK);
     #(20ns);
    
    
       
       //test 4 data read address
       @(negedge CLK);
       ccif.daddr = 32'h1111;
       ccif.dWEN = 0;
       ccif.dREN = 1;
       @(posedge CLK);
       #(20ns);
       if (ccif.ramaddr == ccif.daddr) begin
	  $display("test 4 data read address PASSED.");
       end

       // test 5 data write address
       @(negedge CLK);
       ccif.daddr = 32'h2222;
       ccif.dWEN = 1;
       ccif.dREN = 0;
       @(posedge CLK);
       #(20ns);
       
       if(ccif.ramaddr == ccif.daddr) begin
	  $display("test 5 data write address PASSED.");
       end

       // test 6 instruction read address
       @(negedge CLK);
       ccif.iaddr = 32'h1234;
       ccif.dWEN = 0;
       ccif.iREN = 1;
       @(posedge CLK);
       #(20ns);
       if(ccif.ramaddr == ccif.iaddr) begin
	  $display("test 6 instruction read address PASSED.");
       end
       
     

     
    dump_memory();
    $finish;
  end

  task automatic dump_memory();
    string filename = "memcpu.hex";
    int memfd;

   // syif.tbCTRL = 1;
     
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
      if (ccif.dload === 0)
        continue;
      values = {8'h04,16'(i),8'h00,ccif.dload};
      foreach (values[j])
        chksum += values[j];
      chksum = 16'h100 - chksum;
      ihex = $sformatf(":04%h00%h%h",16'(i),ccif.dload,8'(chksum));
      $fdisplay(memfd,"%s",ihex.toupper());
    end //for
    if (memfd)
    begin
     // syif.tbCTRL = 0;
      ccif.dREN = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
  endtask
endprogram
