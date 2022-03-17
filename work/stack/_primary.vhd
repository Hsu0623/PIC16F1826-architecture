library verilog;
use verilog.vl_types.all;
entity stack is
    port(
        stack_out       : out    vl_logic_vector(10 downto 0);
        stack_in        : in     vl_logic_vector(10 downto 0);
        push            : in     vl_logic;
        pop             : in     vl_logic;
        reset           : in     vl_logic;
        clk             : in     vl_logic
    );
end stack;
