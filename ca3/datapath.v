
`timescale 1ns/1ns

module datapath(pc_write, lord, data_to_mem, reg_write, alusrca,
                alusrcb, link, ir_write, reg_data, alu_op,
                clk, rst, pcsrc, address, mem_in, mem_out,
                inst, ldz, ldc, ldn, ldv, z, c, n, v);

    input pc_write, reg_write, lord, pcsrc,
          data_to_mem, clk, rst,
          alusrca, link, ir_write,
          ldz, ldc, ldn, ldv;
    input [1:0] reg_data, alusrcb;
    input [2:0] alu_op;
    input [31:0] mem_in;
    output [31:0] address, mem_out, inst;
    output z, c, n, v;

    wire [31:0] pc_in, pc_out, ir_out, write_data_in, read_data1, 
                read_data2, a_out, alu_out_in, alu_out_out,
                mdr_out, alusrca_out, alusrcb_out, b_out,
                se_out1, se_out2;

    wire z_in, c_in, n_in, v_in;

    wire [3:0] reg_file_in2, write_reg_in;



    register32bit pc(pc_in, clk, rst, pc_out, pc_write);

    mux2_32bit mux1(pc_out, alu_out_out, lord, address);

    register32bitir ir(mem_in, clk, rst, ir_out, ir_write);

    register32bit mdr(mem_in, clk, rst, mdr_out, 1'b1);

    mux2_4bit mux2(ir_out[3:0], ir_out[15:12], data_to_mem, reg_file_in2);

    mux2_4bit mux3(ir_out[15:12], 4'd15, link, write_reg_in);

    mux3_32bit mux4(alu_out_out, mdr_out, pc_out, reg_data, write_data_in);

    reg_file REG_FILE(ir_out[19:16], reg_file_in2, write_reg_in, write_data_in,
                      reg_write, read_data1, read_data2, clk);

    register32bit a(read_data1, clk, rst, a_out, 1'b1);

    register32bit b(read_data2, clk, rst, b_out, 1'b1);

    mux2_32bit mux5(pc_out, a_out, alusrca, alusrca_out);

    mux4_32bit mux6(b_out, 32'd1, se_out1, se_out2,
                    alusrcb, alusrcb_out);

    ALU alu(alusrca_out, alusrcb_out, alu_op, alu_out_in, z_in,c_in,n_in,v_in);

    register32bit alu_out(alu_out_in, clk, rst, alu_out_out, 1'b1);

    mux2_32bit mux7(alu_out_in, alu_out_out, pcsrc, pc_in);

    register1bit Z(z_in, clk, rst, z, ldz);
    
    register1bit C(c_in, clk, rst, c, ldc);
    
    register1bit N(n_in, clk, rst, n, ldn);
    
    register1bit V(v_in, clk, rst, v, ldv);



    assign se_out1 = {{20{ir_out[11]}}, ir_out[11:0]};
    assign se_out2 = {{6{ir_out[25]}}, ir_out[25:0]};
    assign inst = ir_out;
    assign mem_out = b_out;

endmodule


