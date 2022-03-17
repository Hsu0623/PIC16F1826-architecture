module Testbench();
  
  wire [7:0] w_q;
  reg clk, reset;
  
  //module cpu(clk, reset, w_q);
  cpu c(clk, reset, w_q);
  
  always #1 clk = ~clk;
  initial begin
    clk = 0; reset=1;
    #2 reset = 0;
    #50000 $stop;
  end
  
endmodule

