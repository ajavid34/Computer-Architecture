
`timescale 1ns/1ns

module controller (opcode, func, zero, reg_dst, mem_to_reg, reg_write, alu_src,
		   mem_read, mem_write, pc_src, operation, IFflush, operands_equal);
    
    input [5:0] opcode, func;
    output reg reg_write, alu_src, mem_read, mem_write, IFflush;
    output reg [1:0] mem_to_reg, pc_src, reg_dst;
    output [2:0] operation;
    input operands_equal, zero;

    
    reg [1:0] alu_op;
    reg branch;
    
    
    always @(opcode)
    begin
        {reg_dst, mem_to_reg, reg_write, alu_src, mem_read, mem_write, pc_src, alu_op,
	 IFflush} = {2'b00, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 1'b0};
        case (opcode)
            6'b000000 : {reg_dst, reg_write, alu_op} = {2'b01, 1'b1, 2'b10};
            6'b100011 : {alu_src, mem_to_reg, reg_write, mem_read} = {1'b1, 2'b01, 1'b1, 1'b1};
            6'b101011 : {alu_src, mem_write} = 2'b11;
	    6'b000100 : {pc_src, IFflush} = {1'b0, operands_equal, operands_equal};
            6'b001001: {reg_write, alu_src} = 2'b11;
            6'b000010: {pc_src, IFflush} = {2'b10, 1'b1};
            6'b000011: {reg_dst, mem_to_reg, pc_src} = {2'b10, 2'b10, 2'b10};
            6'b000110: {pc_src} = {2'b11};
            6'b001010: {alu_src, reg_dst, reg_write, alu_op, mem_to_reg} = {1'b1, 2'b00, 1'b1, 2'b11, 2'b00}; 
        endcase
    end
    

    alu_controller ALU_CTRL(alu_op, func, operation);
    
endmodule

module alu_controller (alu_op,
                       func,
                       operation);
    input [1:0] alu_op;
    input [5:0] func;
    output [2:0] operation;
    reg [2:0] operation;
    
    always @(alu_op, func) begin
        operation = 3'b000;
        if (alu_op == 2'b00)        
            operation = 3'b010;
        else if (alu_op == 2'b01)   
            operation = 3'b110;
        else if (alu_op == 2'b11)
            operation = 3'b111; 
        else
        begin
            case (func)
                6'b100000: operation = 3'b010;  
                6'b100011: operation = 3'b110; 
                6'b100100: operation = 3'b000;  
                6'b100101: operation = 3'b001;  
                6'b101010: operation = 3'b111;  
                default:   operation = 3'b000;
            endcase
        end
    end
    
endmodule
