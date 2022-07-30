`timescale 1ns/1ns


module datapath(reg_dst, data_to_write, reg_write,alusrc,
                alu_op, mem_to_reg, clk, rst, 
                zero, pcsrc, jump2, jump1, address,
                mem_in, mem_adr, mem_out, inst);

    input data_to_write , reg_write,mem_to_reg, pcsrc,
          alusrc, jump1, jump2, clk, rst;
    input [1:0] reg_dst;
    input [2:0] alu_op;
    input [31:0] inst, mem_in;
    output [31:0] address, mem_adr, mem_out;
    output zero;

    wire [31:0] pc_in, pc_out, reg_data_in, read_data1,
                read_data2, alu_bin, alu_out, mem_mux_out,
                pc_adder_out, shl1_out, se_out,
                pc_mux_in, pc_mux_out, jump_mux_in;
    wire [25:0] shl2_out;
    wire [4:0] write_reg_in;

    PC pc(pc_in, clk, rst, pc_out);

    adder Adder1(32'd4, pc_out, pc_adder_out);

    mux3_5bit mux1(inst[20:16], inst[15:11], 5'd31,
                   reg_dst, write_reg_in);

    mux2_32bit mux2(mem_mux_out, pc_adder_out,
                    data_to_write, reg_data_in);

    reg_file REG_FILE(inst[25:21], inst[20:16], write_reg_in,
                reg_data_in, reg_write, read_data1, read_data2, clk);
    
    mux2_32bit mux3(read_data2, se_out, alusrc, alu_bin);

    ALU alu(read_data1, alu_bin, alu_op, alu_out, zero);

    mux2_32bit mux4(alu_out,  mem_in, mem_to_reg, mem_mux_out);

    shifter32 shl1(se_out, shl1_out);

    shifter26 shl2(inst[25:0], shl2_out);

    adder Adder2(pc_adder_out, shl1_out, pc_mux_in);

    mux2_32bit mux5(pc_adder_out, pc_mux_in, pcsrc, pc_mux_out);

    mux2_32bit mux6({pc_adder_out[31:28], inst[25:0],2'b00},
                     read_data1, jump1, jump_mux_in);

    mux2_32bit mux7(pc_mux_out, jump_mux_in, jump2, pc_in);

    



    assign address = pc_out;
    assign se_out = {{16{inst[15]}}, inst[15:0]};
    assign mem_out = read_data2;
    assign mem_adr = alu_out;
    
endmodule
