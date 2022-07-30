
module datapath (clk, rst, inst_adr, inst, data_adr, data_out, data_in, 
                 reg_dst, mem_to_reg, alu_src, pc_src, alu_ctrl, reg_write, 
                 flush, mem_read, mem_write, forwardA, forwardB, mem_write_to_data_mem,
                 mem_read_to_data_mem, pc_load, IFID_Ld, sel_signal, IFIDopcode_out, 
                 IFIDfunc_out, zero_out, operands_equal, IDEX_mem_read, IDEX_Rt,
                 IFID_Rt, IFID_Rs, IDEX_Rs, EXMEM_reg_write, EXMEM_Rd, MEMWB_reg_write, MEMWB_Rd);
    
    input alu_src, reg_write, mem_read,mem_write, flush, pc_load, IFID_Ld, sel_signal, clk, rst;
    input [1:0] mem_to_reg, reg_dst, pc_src, forwardA, forwardB;
    input  [2:0] alu_ctrl;
    input  [31:0] data_in, inst; 
    output mem_read_to_data_mem, mem_write_to_data_mem, EXMEM_reg_write,
	   MEMWB_reg_write, IDEX_mem_read, operands_equal, zero_out;
    output [4:0] IDEX_Rt, IFID_Rt, IFID_Rs, IDEX_Rs, EXMEM_Rd, MEMWB_Rd;
    output [5:0] IFIDopcode_out, IFIDfunc_out;
    output [31:0] data_adr, data_out, inst_adr; 


    wire IDEX_reg_write_out, IDEX_mem_read_out, IDEX_mem_write_out,IDEX_mem_read_in, IDEX_mem_write_in, 
         MEMWB_reg_write_out,cout1,cout2, IDEX_alu_src_out, alu_zero, IDEX_alu_src_in, IDEX_reg_write_in,
         EXMEM_mem_write_out, EXMEM_mem_read_out, EXMEM_reg_write_out, EXMEM_zero_out;
    wire [1:0] IDEX_reg_dst_out, IDEX_mem_to_reg_out, IDEX_reg_dst_in,
               IDEX_mem_to_reg_in,MEMWB_mem_to_reg_out,EXMEM_mem_to_reg_out;
    wire [2:0]  IDEX_alu_ctrl_in, IDEX_alu_ctrl_out;
    wire [4:0]  IDEX_Rt_out, IDEX_Rd_out, IDEX_Rs_out, mux5_out, MEMWB_mux5_out, EXMEM_mux5_out;
    wire [10:0] mux7_out;
    wire [27:0] shl2_26b_out;
    wire [31:0] mux1_out, adder1_out, pc_out, IFIDinst_out, IFIDadder1_out,EXMEM_adder1_out, EXMEM_mux3_out, EXMEM_alu_result_out ,
		adder2_out, read_data1, sgn_ext_out, shl2_32_out, mux6_out,MEMWB_data_from_memory_out, MEMWB_alu_result_out, MEMWB_adder1_out,
		read_data2, IDEX_adder1_out, alu_result, mux2_out, mux3_out, mux4_out, IDEX_read1_out, IDEX_read2_out, IDEX_sgn_ext_out;


    reg_32b pc(mux1_out, rst, pc_load, clk, pc_out);
    
    adder_32b adder1(pc_out , 32'd4, cout1 , adder1_out);
    
    IFID ifid(clk, rst, IFID_Ld, flush, inst, adder1_out, IFIDinst_out, IFIDadder1_out);

    mux4to1_32b mux1(adder1_out, adder2_out, {IFIDadder1_out[31:28], shl2_26b_out}, read_data1, pc_src, mux1_out);

    shl2_32b shl2(sgn_ext_out, shl2_32_out);

    adder_32b adder2(shl2_32_out, IFIDadder1_out, cout2, adder2_out);

    shl2_26b SHL2_26(IFIDinst_out[25:0], shl2_26b_out);

    reg_file register_file(mux6_out, IFIDinst_out[25:21], IFIDinst_out[20:16], MEMWB_mux5_out, MEMWB_reg_write_out, rst, clk, read_data1, read_data2);

    mux2to1_11b MUX7(11'b0, {alu_ctrl, alu_src, reg_write, reg_dst, mem_read, mem_write, mem_to_reg}, sel_signal, mux7_out); 

    IDEX idex(clk, rst, read_data1, read_data2, sgn_ext_out, IFIDinst_out[20:16], IFIDinst_out[15:11], IFIDinst_out[25:21],
			  IFIDadder1_out, IDEX_read1_out, IDEX_read2_out, IDEX_sgn_ext_out, IDEX_Rt_out, IDEX_Rd_out, IDEX_Rs_out,
			  IDEX_adder1_out,IDEX_alu_ctrl_in, IDEX_alu_src_in, IDEX_reg_write_in, IDEX_reg_dst_in, IDEX_mem_read_in,
			  IDEX_mem_write_in, IDEX_mem_to_reg_in, IDEX_alu_ctrl_out, IDEX_alu_src_out, IDEX_reg_write_out, IDEX_reg_dst_out,
			  IDEX_mem_read_out, IDEX_mem_write_out, IDEX_mem_to_reg_out);

    mux3to1_5b mux5(IDEX_Rt_out, IDEX_Rd_out, 5'b11111, IDEX_reg_dst_out, mux5_out);

    mux2to1_32b mux4(mux3_out, IDEX_sgn_ext_out, IDEX_alu_src_out, mux4_out);

    mux3to1_32b mux3(IDEX_read2_out, mux6_out, EXMEM_alu_result_out, forwardB, mux3_out);

    mux3to1_32b mux2(IDEX_read1_out, mux6_out, EXMEM_alu_result_out, forwardA, mux2_out);

    alu ALU(mux2_out, mux4_out, IDEX_alu_ctrl_out, alu_result, alu_zero);
        
    EXMEM exmem(clk, rst, IDEX_adder1_out, alu_zero, alu_result, mux3_out, mux5_out, 
                EXMEM_adder1_out, EXMEM_zero_out, EXMEM_alu_result_out, EXMEM_mux3_out, EXMEM_mux5_out,
         	IDEX_mem_write_out, IDEX_mem_read_out, IDEX_mem_to_reg_out, IDEX_reg_write_out,
                EXMEM_mem_write_out, EXMEM_mem_read_out, EXMEM_mem_to_reg_out, EXMEM_reg_write_out);


    MEMWB memwb(clk, rst, data_in, EXMEM_alu_result_out, EXMEM_mux5_out, EXMEM_adder1_out,
                MEMWB_data_from_memory_out, MEMWB_alu_result_out, MEMWB_mux5_out, MEMWB_adder1_out,
		        EXMEM_mem_to_reg_out, EXMEM_reg_write_out,MEMWB_mem_to_reg_out, MEMWB_reg_write_out);

    mux3to1_32b mux6(MEMWB_alu_result_out, MEMWB_data_from_memory_out, MEMWB_adder1_out, MEMWB_mem_to_reg_out, mux6_out); 
    
    assign mem_write_to_data_mem = EXMEM_mem_write_out; 
    assign mem_read_to_data_mem = EXMEM_mem_read_out; 
    assign EXMEM_Rd = EXMEM_mux5_out;
    assign EXMEM_reg_write = EXMEM_reg_write_out;
    assign data_adr = EXMEM_alu_result_out; 
    assign data_out = EXMEM_mux3_out;  
    assign MEMWB_Rd = MEMWB_mux5_out;
    assign MEMWB_reg_write = MEMWB_reg_write_out;
    assign zero_out = alu_zero;    
    assign sgn_ext_out = {{16{IFIDinst_out[15]}}, IFIDinst_out[15:0]};    assign IFIDopcode_out = IFIDinst_out[31:26];
    assign IFIDfunc_out = IFIDinst_out[5:0];
    assign IFID_Rt = IFIDinst_out[20:16];
    assign IFID_Rs = IFIDinst_out[25:21];
    assign operands_equal = (read_data1 == read_data2) ? 1:0;
    assign IDEX_Rt = IDEX_Rt_out;
    assign IDEX_Rs = IDEX_Rs_out;
    assign {IDEX_alu_ctrl_in, IDEX_alu_src_in, IDEX_reg_write_in,
            IDEX_reg_dst_in, IDEX_mem_read_in, IDEX_mem_write_in, IDEX_mem_to_reg_in} = mux7_out;
    assign IDEX_mem_read = IDEX_mem_read_out;
    assign inst_adr = pc_out; 
    
endmodule
