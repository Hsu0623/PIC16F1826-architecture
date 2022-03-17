module Program_Rom(Rom_data_out, Rom_addr_in);

//---------
    output [13:0] Rom_data_out;
    input [10:0] Rom_addr_in; 
//---------
    
    reg   [13:0] data;
    wire  [13:0] Rom_data_out;
    
    always @(Rom_addr_in)
        begin
            case (Rom_addr_in)
                11'h0 : data = 14'h3018;
                11'h1 : data = 14'h00A6;
                11'h2 : data = 14'h303B;
                11'h3 : data = 14'h01A1;
                11'h4 : data = 14'h01A2;
                11'h5 : data = 14'h00A5;
                11'h6 : data = 14'h3207;
                11'h7 : data = 14'h0BA6;
                11'h8 : data = 14'h3201;
                11'h9 : data = 14'h33F6;
                11'ha : data = 14'h0AA1;
                11'hb : data = 14'h01A2;
                11'hc : data = 14'h303B;
                11'hd : data = 14'h00A5;
                11'he : data = 14'h0AA2;
                11'hf : data = 14'h0BA5;
                11'h10 : data = 14'h33FD;
                11'h11 : data = 14'h33F5;
                11'h12 : data = 14'h2812;
                11'h13 : data = 14'h3400;
                11'h14 : data = 14'h3400;
                default: data = 14'h0;   
            endcase
        end

     assign Rom_data_out = data;

endmodule
