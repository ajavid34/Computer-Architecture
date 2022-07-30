`timescale 1ns/1ns

module mips(mem_in, mem_adr, mem_out, mem_read, mem_write, 
            inst, address, clk, rst);

    input clk, rst;
    input [31:0] mem_in, inst;
    output mem_read, mem_write;
    output [31:0] mem_out, address, mem_adr;
    
    wire reg_write, alusrc, mem_to_reg, pcsrc,
         zero, data_to_write, jump1, jump2;
    wire [1:0]reg_dst;
    wire[2:0] alu_operation;

    datapath DP(reg_dst, data_to_write, reg_write,alusrc,
                alu_operation, mem_to_reg, clk, rst, 
                zero, pcsrc, jump2, jump1, address,
                mem_in, mem_adr, mem_out, inst);

    controller CO(inst[31:26], inst[5:0], reg_dst, data_to_write, reg_write,
                  alusrc, alu_operation, mem_read, mem_write, mem_to_reg,
                  pcsrc, jump1, jump2, zero);

endmodule

