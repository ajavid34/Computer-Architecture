`timescale 1ns/1ns


module IFID(clk, rst, ld, flush, inst, adder1, inst_out, adder1_out);
    input clk, rst, flush, ld;
    input [31:0] inst, adder1;

    output reg [31:0] inst_out, adder1_out;

    always @(posedge clk) begin
        if (flush) begin
            inst_out = 32'b0;
        end
        else
            if (rst) 
                {adder1_out,inst_out} = {64'b0};
        else begin
            if (ld) begin
                inst_out = inst;
                adder1_out = adder1;    
                end
            end
        end
endmodule



module IDEX (clk, rst, read_data1, read_data2, sgn_ext, Rt, Rd, Rs, adder1, read_data1_out,
		  read_data2_out, sgn_ext_out, Rt_out, Rd_out, Rs_out, adder1_out,alu_op_in, alu_src_in, reg_write_in,
		  reg_dst_in, mem_read_in, mem_write_in,
		  mem_to_reg_in, alu_op, alu_src, reg_write, reg_dst, mem_read, mem_write, mem_to_reg);

    input clk, rst, alu_src_in, reg_write_in, mem_read_in, mem_write_in;
    input [1:0] reg_dst_in, mem_to_reg_in;
    input [2:0] alu_op_in;
    input [4:0] Rt, Rd, Rs;
    input [31:0] read_data1, read_data2, sgn_ext, adder1;

    output reg alu_src, mem_read, mem_write, reg_write;
    output reg [2:0] alu_op;
    output reg [1:0] mem_to_reg, reg_dst;
    output reg [31:0] read_data1_out, read_data2_out, sgn_ext_out, adder1_out;
    output reg [4:0] Rt_out, Rd_out, Rs_out;

    always @(posedge clk) begin
        if (rst) begin
            {read_data1_out, read_data2_out, sgn_ext_out, adder1_out, Rt_out, Rd_out,
	     Rs_out, alu_op, alu_src, reg_write, reg_dst, mem_read, mem_write,
             mem_to_reg} = {128'b0, 15'b0,3'b000, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b00};
       		 end
        else begin
            {read_data1_out, read_data2_out, sgn_ext_out, adder1_out} = {read_data1, read_data2, sgn_ext, adder1};
            {Rt_out, Rd_out, Rs_out} = {Rt, Rd, Rs};
            {alu_op, alu_src, reg_write, reg_dst, mem_read, mem_write, mem_to_reg} = {alu_op_in, alu_src_in, reg_write_in, reg_dst_in, mem_read_in, mem_write_in, mem_to_reg_in};
        end
    end

endmodule

module EXMEM(clk, rst, adder1, zero, alu_result, mux3_out, mux5_out, adder1_out,
		   zero_out, alu_result_out, mux3_out_out, mux5_out_out, mem_write_in, mem_read_in, mem_to_reg_in, reg_write_in,
                  mem_write, mem_read, mem_to_reg, reg_write);
    input clk, rst, zero, reg_write_in, mem_read_in, mem_write_in;
    input [1:0] mem_to_reg_in;
    input [4:0] mux5_out;
    input [31:0] alu_result, mux3_out, adder1;
        

    output reg zero_out, mem_read, mem_write, reg_write;
    output reg [1:0] mem_to_reg;
    output reg [4:0] mux5_out_out;
    output reg [31:0] alu_result_out, mux3_out_out, adder1_out;
        
    always @(posedge clk) begin
        if (rst)
            {adder1_out, zero_out, alu_result_out, mux3_out_out, mux5_out_out, mem_write,
             mem_read, mem_to_reg, reg_write} = {32'b0, 1'b0, 32'b0, 32'b0, 5'b0, 1'b0, 1'b0, 2'b00, 1'b0};
        else
            {adder1_out, zero_out, alu_result_out, mux3_out_out, mux5_out_out} = {adder1, zero, alu_result, mux3_out, mux5_out};
            {mem_write, mem_read, mem_to_reg, reg_write} = {mem_write_in, mem_read_in, mem_to_reg_in, reg_write_in};
    end
endmodule

module MEMWB(clk, rst, data_from_data_memory_in, alu_result_in, mux5_out_in, adder1_in,
		           data_from_memory_out, alu_result_out, mux5_out_in_out, adder1_out,
                   mem_to_reg_in, reg_write_in, mem_to_reg_out, reg_write_out);
    input clk, rst, reg_write_in;
    input [1:0] mem_to_reg_in;
    input [4:0] mux5_out_in;
    input [31:0] data_from_data_memory_in, alu_result_in, adder1_in;

    output reg reg_write_out;
    output reg [1:0] mem_to_reg_out;
    output reg [31:0] data_from_memory_out, alu_result_out, adder1_out;
    output reg [4:0] mux5_out_in_out;

    always @(posedge clk) begin
        if (rst)
            {data_from_memory_out, alu_result_out, mux5_out_in_out, adder1_out,
             mem_to_reg_out, reg_write_out} = {32'b0, 32'b0, 5'b0, 32'b0, 2'b00, 1'b0};
        else
            {data_from_memory_out, alu_result_out, mux5_out_in_out, adder1_out} = {data_from_data_memory_in, alu_result_in, mux5_out_in, adder1_in};
            {mem_to_reg_out, reg_write_out} = {mem_to_reg_in, reg_write_in};
    end
endmodule








module hazard_detection_unit(IDEX_mem_read, IDEX_Rt, IFID_Rs, IFID_Rt, sel_signal, IFID_Ld, pc_load);
    input IDEX_mem_read;
    input [4:0] IDEX_Rt, IFID_Rs, IFID_Rt;
    output reg sel_signal, IFID_Ld, pc_load;

    always @(IDEX_mem_read, IDEX_Rt, IFID_Rs, IFID_Rt)
    begin
        sel_signal <= 1'b1;
        IFID_Ld <= 1'b1;
        pc_load <= 1'b1;

        if (IDEX_mem_read && ((IDEX_Rt == IFID_Rs) || (IDEX_Rt == IFID_Rt)) ) 
            {sel_signal, IFID_Ld, pc_load} = {1'b0,1'b0,1'b0};
    end
endmodule

module forward_unit(IDEX_Rs, IDEX_Rt, EXMEM_reg_write, EXMEM_Rd,
 MEMWB_reg_write, MEMWB_Rd, forwardA, forwardB);

    input EXMEM_reg_write, MEMWB_reg_write;
    input [4:0] IDEX_Rs, IDEX_Rt, EXMEM_Rd, MEMWB_Rd;
    output reg [1:0] forwardA, forwardB;

    always @(IDEX_Rs, IDEX_Rt, EXMEM_reg_write, EXMEM_Rd, MEMWB_reg_write, MEMWB_Rd) begin
	{forwardA, forwardB} <= {2'b00, 2'b00};
        if ((EXMEM_reg_write)&(EXMEM_Rd != 5'b0)&(EXMEM_Rd == IDEX_Rs))
            forwardA <= 2'b10;
        
        else if ((MEMWB_reg_write)&(MEMWB_Rd != 5'b0)&(MEMWB_Rd == IDEX_Rt))
            forwardA <= 2'b01;

        if ((EXMEM_reg_write)&(EXMEM_Rd != 5'b0)&(EXMEM_Rd == IDEX_Rs))
            forwardB <= 2'b10;
        
        else if ((MEMWB_reg_write)&(MEMWB_Rd != 5'b0)&(MEMWB_Rd == IDEX_Rt))
            forwardB <= 2'b01;
        
    end

endmodule
