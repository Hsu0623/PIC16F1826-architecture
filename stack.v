module stack(stack_out, stack_in, push, pop, reset, clk);

	output stack_out;
	input [10:0] stack_in;
	input push, pop, reset, clk;
	
	reg [3:0] stk_ptr;
	reg[10:0] stack[15:0];
	wire [10:0] stack_out;
	wire [3:0] stk_index;
	
	
	assign stk_index = stk_ptr + 1;
	assign stack_out = stack[stk_ptr[3:0]];
	
	
	always @(posedge clk)
		begin
			if(reset) 
				stk_ptr <= 4'b1111;
				
			else if(push)
				begin
				stack[stk_index[3:0]] <= stack_in;
				stk_ptr <= stk_ptr + 1;
				end
			
			else if(pop)
				stk_ptr <= stk_ptr - 1;
		
		end
		
endmodule