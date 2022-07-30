`timescale 1ns/1ns


module controller(opcode, func, reg_dst, data_to_write, reg_write,
                  alusrc, alu_operation, mem_read, mem_write, mem_to_reg,
                  pcsrc, jump1, jump2, zero);
        input zero;
        input [5:0] opcode, func;
        output reg data_to_write, reg_write, alusrc, mem_read, mem_write,
               mem_to_reg, pcsrc, jump1, jump2;
        output reg [1:0] reg_dst;
        output [2:0] alu_operation;
        reg [1:0] alu_op;
        reg branch;

        always @(opcode) begin
            {data_to_write, reg_write, reg_dst, alu_op, branch,
            alusrc, mem_read, mem_write, mem_to_reg, jump1, jump2} = 13'd0;
            case (opcode)
                6'b000000: {reg_dst, reg_write, alu_op} = 5'b01111;

                6'b000001: {reg_write, alusrc} = 2'b11;
                
                6'b000010: {reg_write, alusrc, alu_op} = 4'b1110;

                6'b000011: {reg_write, alusrc, mem_read, mem_to_reg} = 4'b1111;

                6'b000100: {alusrc, mem_write} =2'b11;

                6'b000101: {branch, alu_op} = 3'b101;

                6'b000110: jump2 = 1'b1;

                6'b000111: {jump1, jump2} = 2'b11;

                6'b001000: {reg_dst, data_to_write, reg_write, jump2} = 5'b10111;

            endcase

        end


    alu_controller ALU_controller(alu_op, func, alu_operation);

    assign pcsrc = zero & branch;

endmodule



module alu_controller(alu_op, func, alu_operation);
    input [1:0] alu_op;
    input [5:0] func;
    output reg [2:0] alu_operation;

    always @(func, alu_op) begin
        alu_operation = 3'b0;

        if(alu_op == 2'b0)
            alu_operation = 3'd0;
        else if (alu_op == 2'd1)
            alu_operation = 3'd1;
        else if (alu_op == 2'd2)
            alu_operation = 3'd4;
        else begin
            case(func) //alu_op = 3'd3
            6'b000001: alu_operation = 3'd0;
            6'b000010: alu_operation = 3'd1;
            6'b000100: alu_operation = 3'd2;
            6'b001000: alu_operation = 3'd3;
            6'b010000: alu_operation = 3'd4;
            default: alu_operation = 3'd0;
            endcase
        end
        

        
    end
endmodule