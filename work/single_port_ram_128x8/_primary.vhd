library verilog;
use verilog.vl_types.all;
entity single_port_ram_128x8 is
    port(
        data            : in     vl_logic_vector(7 downto 0);
        addr            : in     vl_logic_vector(6 downto 0);
        en              : in     vl_logic;
        clk             : in     vl_logic;
        q               : out    vl_logic_vector(7 downto 0)
    );
end single_port_ram_128x8;
