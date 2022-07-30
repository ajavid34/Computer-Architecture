
`timescale 1ns/1ns
module mips( mem_in, address, mem_out, mem_read, mem_write, clk, rst);
    input rst, clk;
    input [31:0] mem_in;
    output [31:0] mem_out, address;
    output mem_read, mem_write;

    wire pc_write, lord, data_to_mem, reg_write, alusrca, link,
         ir_write, pcsrc, ldz, ldc, ldn, ldv, z, c, n, v;

    wire [1:0] reg_data, alusrcb;
    wire[2:0] alu_op;
    wire [31:0] inst;

    datapath DP(pc_write, lord, data_to_mem, reg_write, alusrca,
                alusrcb, link, ir_write, reg_data, alu_op,
                clk, rst, pcsrc, address, mem_in, mem_out,
                inst, ldz, ldc, ldn, ldv, z, c, n, v);

    controller CU(inst, inst[22:20], pc_write, lord, mem_write, mem_read,
                  ir_write, data_to_mem, link, reg_data, reg_write,
                  alusrca, alusrcb, z, c, n, v, ldz, ldc, ldn, ldv, 
                  alu_op, pcsrc, inst[31:30], clk, rst);

endmodule
