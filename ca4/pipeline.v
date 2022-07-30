
`timescale 1ns/1ns

module Pipeline(clk, rst, inst_adr, inst, data_adr, data_out,
                data_in, mem_write_to_data_mem, mem_read_to_data_mem);
    
    input clk, rst;
    input [31:0] inst, data_in;

    output mem_write_to_data_mem, mem_read_to_data_mem;
    output [31:0] inst_adr, data_adr, data_out;

    wire [1:0] reg_dst, pc_src, mem_to_reg, forwardA, forwardB;
    wire alu_src, reg_write, flush, mem_read, mem_write, pc_load, IFID_Ld, sel_signal,
	 zero_out, operands_equal, IDEX_mem_read, EXMEM_reg_write, MEMWB_reg_write;
    wire [2:0] alu_ctrl;
    wire [4:0] IDEX_Rt, IFID_Rt, IFID_Rs, IDEX_Rs, EXMEM_Rd, MEMWB_Rd;
    wire [5:0] IFIDopcode_out, IFIDfunc_out;
    
    
    datapath DP(clk, rst, inst_adr, inst, data_adr, data_out, data_in, reg_dst,
    		mem_to_reg, alu_src, pc_src, alu_ctrl, reg_write, flush, mem_read,
    		mem_write, forwardA, forwardB, mem_write_to_data_mem, mem_read_to_data_mem,
                pc_load, IFID_Ld, sel_signal, IFIDopcode_out, IFIDfunc_out,
    		zero_out, operands_equal, IDEX_mem_read, IDEX_Rt, IFID_Rt, IFID_Rs,
    		IDEX_Rs, EXMEM_reg_write, EXMEM_Rd, MEMWB_reg_write, MEMWB_Rd);
    
    
    controller CU(IFIDopcode_out, IFIDfunc_out, zero_out, reg_dst, mem_to_reg,reg_write,
		  alu_src, mem_read, mem_write, pc_src, alu_ctrl, flush, operands_equal);
    
    hazard_detection_unit hazard_detecor(IDEX_mem_read, IDEX_Rt, IFID_Rs, IFID_Rt, sel_signal, IFID_Ld, pc_load);
    
    forward_unit Forward_unit(IDEX_Rs, IDEX_Rt, EXMEM_reg_write, EXMEM_Rd, MEMWB_reg_write, MEMWB_Rd, forwardA, forwardB);

endmodule