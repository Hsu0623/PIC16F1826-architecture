module cpu(clk, reset, w_q);

  input clk, reset;
  output w_q;

  wire clk, reset;
  reg [13:0] ir_q;
  wire[13:0] prog_data;
  reg [10:0] pc_in, pc_q, mar_q, pc_next;
  reg [7:0] w_q, alu_out, mux1_out, databus, RAM_mux, bcf_mux, bsf_mux;
  reg [7:0] port_b_out;
  wire [7:0] ram_out;
  wire [10:0] stack_q;
  reg [3:0] op;
  reg [2:0] ns, ps;

  /*control sign*/
  parameter T0 = 0, T1 = 1, T2 = 2, T3 = 3, T4 = 4, T5 = 5;
  reg load_mar, load_ir, load_pc, load_w, sel_alu, ram_en;
  reg  sel_bus, load_port_b, pop, push;
  wire [2:0] sel_bit;
  reg[2:0] sel_ram_mux, sel_pc;

  wire MOVLW, ADDLW, SUBLW, ANDLW, IORLW, XORLW, ADDWF, ANDWF, CLRF;
  wire CLRW, COMF, DECF, GOTO, INCF, IORWF, SUBWF, MOVWF, MOVF, XORWF;
  wire DECFSZ, INCFSZ, BCF, BSF, BTFSC, BTFSS, ASRF, LSLF, LSRF, RLF;
  wire RRF, SWAPF, CALL, RETURN, BRA, BRW, NOP;
  wire btfsc_btfss_skip_bit, addr_port_b, alu_zero, btfsc_skip_bit;
  wire [10:0] w_change, k_change;



  //+
  always @(*)
  begin
    pc_in = pc_q+1;
  end

  //Stack
  //module stack(stack_out, stack_in, push, pop, reset, clk);
  stack stack(stack_q, pc_q, push, pop, reset, clk);
  
  //MUX_PC
  always @(*)
  begin
	if(sel_pc == 0) pc_next = pc_in;
	else if(sel_pc == 1) pc_next = ir_q[10:0];
	else if(sel_pc == 2) pc_next = stack_q;
	else if(sel_pc == 3) pc_next = pc_q + k_change;
	else if(sel_pc == 4) pc_next = pc_q + w_change;
  end

  //PC
  always @(posedge clk)
  begin
    if(reset) pc_q <= 11'b0;
    else if(load_pc) pc_q <= pc_next;
  end

  //MAR
  always @(posedge clk)
  begin
    if(reset) mar_q <= 0;
    else if(load_mar) mar_q <= pc_q;
  end

  //ROM
  //module Program_Rom(Rom_data_out, Rom_addr_in);
  Program_Rom rom(prog_data, mar_q);

  //IR
  always @(posedge clk)
  begin
    if(reset) ir_q <= 14'h0;
    else if(load_ir) ir_q <= prog_data;
  end

  //MUX_bus
  always@(*)
  begin
	if(sel_bus) databus = w_q;
	else databus = alu_out;
  end

  //Port_b
  always@(posedge clk)
  begin
	if(reset) port_b_out <= 0;
	else if(load_port_b) port_b_out <= databus;
  end

  //RAM
  //module single_port_ram_128x8(data, addr, en, clk, q);
  single_port_ram_128x8 ram(databus, ir_q[6:0], ram_en, clk, ram_out);


  assign sel_bit = ir_q[9:7];
  //BCF_MUX
  always@(*)
  begin
	case(sel_bit)
		3'b000: bcf_mux = ram_out & 8'hFE;
		3'b001: bcf_mux = ram_out & 8'hFD;
		3'b010: bcf_mux = ram_out & 8'hFB;
		3'b011: bcf_mux = ram_out & 8'hF7;
		3'b100: bcf_mux = ram_out & 8'hEF;
		3'b101: bcf_mux = ram_out & 8'hDF;
		3'b110: bcf_mux = ram_out & 8'hBF;
		3'b111: bcf_mux = ram_out & 8'h7F;
	endcase
  end

  //BSF_MUX
  always@(*)
  begin
	case(sel_bit)
		3'b000: bsf_mux = ram_out | 8'h01;
		3'b001: bsf_mux = ram_out | 8'h02;
		3'b010: bsf_mux = ram_out | 8'h04;
		3'b011: bsf_mux = ram_out | 8'h08;
		3'b100: bsf_mux = ram_out | 8'h10;
		3'b101: bsf_mux = ram_out | 8'h20;
		3'b110: bsf_mux = ram_out | 8'h40;
		3'b111: bsf_mux = ram_out | 8'h80;
	endcase
  end

  //RAM_MUX
  always@(*)
  begin
	case(sel_ram_mux)
		0: RAM_mux = ram_out;
		1: RAM_mux = bcf_mux;
		2: RAM_mux = bsf_mux;
		default: RAM_mux = 8'bx;
	endcase
  end

  //MUX_alu
  always @ (*)
  begin
	if(sel_alu) mux1_out = RAM_mux;
	else mux1_out = ir_q[7:0];
  end

  //ALU
  always @(*)
  begin
	case(op)
	  4'h0: alu_out = mux1_out + w_q;
	  4'h1: alu_out = mux1_out - w_q;
	  4'h2: alu_out = mux1_out & w_q;
	  4'h3: alu_out = mux1_out | w_q;
	  4'h4: alu_out = mux1_out ^ w_q;
	  4'h5: alu_out = mux1_out;
	  4'h6: alu_out = mux1_out + 1;
	  4'h7: alu_out = mux1_out - 1;
	  4'h8: alu_out = 0;
	  4'h9: alu_out = ~mux1_out;
	  4'hA: alu_out = {mux1_out[7], mux1_out[7:1]};
	  4'hB: alu_out = {mux1_out[6:0], 1'b0};
	  4'hC: alu_out = {1'b0, mux1_out[7:1]};
	  4'hD: alu_out = {mux1_out[6:0], mux1_out[7]};
	  4'hE: alu_out = {mux1_out[0], mux1_out[7:1]};
	  4'hF: alu_out = {mux1_out[3:0], mux1_out[7:4]};
	  default: alu_out = mux1_out + w_q;
	endcase
  end

  //W
  always @(posedge clk)
  begin
	if(~reset)
	begin
		if(load_w) w_q <= alu_out;
	end
  end


  //OP code
  assign MOVLW = (ir_q[13:8] == 6'b11_0000);
  assign ADDLW = (ir_q[13:8] == 6'b11_1110);
  assign SUBLW = (ir_q[13:8] == 6'b11_1100);
  assign ANDLW = (ir_q[13:8] == 6'b11_1001);
  assign IORLW = (ir_q[13:8] == 6'b11_1000);
  assign XORLW = (ir_q[13:8] == 6'b11_1010);
  assign CLRF = (ir_q[13:7] == 7'b00_0001_1);
  assign CLRW = (ir_q[13:2] == 12'b00_0001_0000_00);
  assign ADDWF = (ir_q[13:8] == 6'b00_0111);
  assign GOTO = (ir_q[13:11] == 3'b10_1);
  assign ANDWF = (ir_q[13:8] == 6'b00_0101);
  assign DECF = (ir_q[13:8] == 6'b00_0011);
  assign COMF = (ir_q[13:8] == 6'b00_1001);
  assign INCF = (ir_q[13:8] == 6'b00_1010);
  assign IORWF = (ir_q[13:8] == 6'b00_0100);
  assign SUBWF = (ir_q[13:8] == 6'b00_0010);
  assign MOVWF = (ir_q[13:7] == 7'b00_0000_1);
  assign MOVF = (ir_q[13:8] == 6'b00_1000);
  assign XORWF = (ir_q[13:8] == 6'b00_0110);
  assign DECFSZ = (ir_q[13:8] == 6'b00_1011);
  assign INCFSZ = (ir_q[13:8] == 6'b00_1111);
  assign BCF = (ir_q[13:10] == 4'b0100);
  assign BSF = (ir_q[13:10] == 4'b0101);
  assign BTFSC = (ir_q[13:10] == 4'b0110);
  assign BTFSS = (ir_q[13:10] == 4'b0111);
  assign ASRF = (ir_q[13:8] == 6'b11_0111);
  assign LSLF = (ir_q[13:8] == 6'b11_0101);
  assign LSRF = (ir_q[13:8] == 6'b11_0110);
  assign RLF = (ir_q[13:8] == 6'b00_1101);
  assign RRF = (ir_q[13:8] == 6'b00_1100);
  assign SWAPF = (ir_q[13:8] == 6'b00_1110);
  assign CALL = (ir_q[13:11] == 3'b10_0);
  assign RETURN = (ir_q[13:0] == 14'b00_0000_0000_1000);
  assign BRA = (ir_q[13:9] == 5'b11_001);
  assign BRW = (ir_q[13:0] == 14'b00_0000_0000_1011);
  assign NOP = (ir_q[13:0] == 14'b00_0000_0000_0000);
  
  assign alu_zero = (alu_out == 0)? 1'b1 : 1'b0;
  assign btfsc_skip_bit = ram_out[ir_q[9:7]] == 0;
  assign btfsc_skip_bit = ram_out[ir_q[9:7]] == 1;
  assign btfsc_btfss_skip_bit = (BTFSC&btfsc_skip_bit) | (BTFSS&btfsc_skip_bit);
  assign addr_port_b = (ir_q[6:0] == 7'h0d);
  assign w_change = {3'b0, w_q};
  assign k_change = {ir_q[8], ir_q[8], ir_q[8:0]};
  
  //Controller
  always @(*)
  begin
    load_pc = 0; load_mar = 0; load_ir = 0; load_w = 0; sel_alu = 0; 
	sel_pc = 0; ram_en = 0; sel_ram_mux = 0; load_port_b = 0;
	case(ps)
      T0: ns <= T1;
      T1: begin load_mar = 1; ns=T2; end
      T2: begin load_pc = 1; load_ir = 1; ns = T3; end
	  T3: begin
		ns = T4;
		if(MOVLW)	   begin op = 5; load_w = 1; end
		else if(ADDLW) begin op = 0; load_w = 1; end
		else if(SUBLW) begin op = 1; load_w = 1; end
		else if(ANDLW) begin op = 2; load_w = 1; end
		else if(IORLW) begin op = 3; load_w = 1; end
		else if(XORLW) begin op = 4; load_w = 1; end
		else if(ADDWF) begin op = 0; sel_alu = 1;
							if(ir_q[7]) ram_en = 1; else load_w = 1;
					   end
		else if(ANDWF) begin op = 2; sel_alu = 1;
							if(ir_q[7]) ram_en = 1; else load_w = 1;
					   end
		else if(CLRW)  begin op = 8; load_w = 1; end
		else if(CLRF)  begin op = 8; sel_bus = 0; ram_en = 1; end
		else if(COMF)  begin op = 9; sel_alu = 1;
							if(ir_q[7]) begin ram_en=1; sel_bus=0; end
							else load_w=1;
					   end
		else if(DECF)  begin op = 7; sel_alu = 1;
							if(ir_q[7]) begin ram_en = 1; sel_bus=0; end
							else load_w=1;
					   end
		else if(GOTO)  begin sel_pc = 1; load_pc = 1; end
		else if(ADDWF) begin op=0; sel_alu = 1;
							if(ir_q[7]) begin ram_en = 1; sel_bus=0;end
							else load_w = 1;
					   end
		else if(ANDWF) begin op=2; sel_alu = 1;
							if(ir_q[7]) begin ram_en = 1; sel_bus = 0; end
							else load_w = 1;
					   end
		else if(INCF)  begin sel_alu=1; op=6;
							if(ir_q[7]) begin ram_en=1; sel_bus=0;end
							else load_w=1;
					   end
		else if(IORWF) begin op=3; sel_alu=1;
							if(ir_q[7]) begin ram_en=1; sel_bus=0; end
							else load_w=1;
					   end
		else if(MOVF)  begin op=5; sel_alu=1;
							if(ir_q[7]) begin ram_en=1; sel_bus=0; end
							else load_w = 1;
					   end
		else if(MOVWF) begin sel_bus=1;
							if(addr_port_b) load_port_b = 1;
							else ram_en=1;
					   end
		else if(SUBWF) begin op=1; sel_alu=1;
							if(ir_q[7]) begin ram_en=1; sel_bus=0; end
							else load_w= 1;
					   end
		else if(XORWF) begin op=4; sel_alu=1;
							if(ir_q[7]) begin ram_en=1; sel_bus=0; end
							else load_w = 1;
					   end
		else if(DECFSZ)begin sel_alu=1; op=7;
							if(ir_q[7]) begin ram_en=1; sel_bus=0;
								if(alu_zero) begin load_pc=1; sel_pc=0; end
							end
							else begin load_w=1;
								if(alu_zero) begin load_pc=1; sel_pc=0; end
							end
					   end
		else if(INCFSZ)begin sel_alu = 1; op =6;
							if(ir_q[7]) begin ram_en=1; sel_bus=0;
								if(alu_zero) begin load_pc=1; sel_pc=0; end
							end
							else begin load_w=1;
								if(alu_zero) begin load_pc=1; sel_pc=0; end
							end
					   end
		else if(BCF)   begin
						sel_alu=1; sel_ram_mux=1; op=5; sel_bus=0; ram_en=1;
					   end
	    else if(BSF)   begin
						sel_alu=1; sel_ram_mux=2; op=5; sel_bus=0; ram_en=1;
					   end
		else if(BTFSC) begin
						if(btfsc_btfss_skip_bit) begin load_pc=1; sel_pc=0; end
					   end
		else if(BTFSS) begin
						if(btfsc_btfss_skip_bit) begin load_pc=1; sel_pc=0; end
				       end
	    else if(ASRF) begin sel_alu = 1; sel_ram_mux = 0; op= 4'hA;
						if(ir_q[7]) begin sel_bus = 0; ram_en = 1; end
						else load_w = 1;
					  end
		else if(LSLF) begin sel_alu = 1; sel_ram_mux = 0; op = 4'hB;
						if(ir_q[7]) begin sel_bus = 0; ram_en = 1; end
						else load_w = 1;
					  end
	    else if(LSRF) begin sel_alu = 1; sel_ram_mux = 0; op = 4'hC;
						if(ir_q[7]) begin sel_bus = 0; ram_en = 1; end
						else load_w = 1;
					  end
		else if(RLF)  begin sel_alu = 1; sel_ram_mux = 0; op=4'hD;
						if(ir_q[7]) begin sel_bus = 0; ram_en = 1; end
						else load_w = 1;
					  end
		else if(RRF)  begin sel_alu = 1; sel_ram_mux = 0; op = 4'hE;
						if(ir_q[7]) begin sel_bus = 0; ram_en = 1; end
						else load_w = 1;
					  end
		else if(SWAPF)begin sel_alu = 1; sel_ram_mux = 0; op = 4'hF;
						if(ir_q[7]) begin sel_bus = 0; ram_en = 1; end
						else load_w = 1;
					  end
		else if(CALL) begin
						sel_pc = 1;
						load_pc = 1;
						push = 1;
					  end
		else if(RETURN)begin
						sel_pc = 2;
						load_pc = 1;
						pop = 1;
					   end
		else if(BRA) begin
						load_pc = 1; sel_pc = 3;
					 end
		else if(BRW) begin 
						load_pc = 1; sel_pc = 4;
					 end
		else if(NOP) begin 
					 end
					   
		end

	  T4: begin ns = T5; end
	  T5: begin ns = T1; end
    endcase
  end

  always @(posedge clk)
  begin
    if(reset) ps <= T0;
    else ps <= ns;
  end


endmodule


