`timescale 1ns/1ns

`define START 4'b0000
`define IF 4'b0001
`define ID 4'b0010
`define TRANSFER 4'b0011
`define PROCESSING 4'b0100
`define BRANCH 4'b0101
`define LINK 4'b0110
`define STORE 4'b0111
`define LOAD 4'b1000
`define LOAD2 4'b1001
`define PROC1 4'b1010
`define PROC2 4'b1011
`define PROC3 4'b1100
`define PROC4 4'b1110

module controller(inst, func, pc_write, lord, mem_write, mem_read,
                  ir_write, data_to_mem, link, reg_data, reg_write,
                  alusrca, alusrcb, z, c, n, v, ldz, ldc, ldn, ldv, 
                  alu_operation, pcsrc, c_op, clk, rst);

    input z, c, n, v, rst, clk;
    input [1:0] c_op;
    input [31:0] inst;
    input [2:0] func;
    output reg pc_write, lord, mem_write, mem_read, ir_write, link,pcsrc,
               data_to_mem, reg_write, alusrca, ldz, ldc, ldn, ldv;

    output reg [1:0] reg_data, alusrcb;
    output [2:0] alu_operation;

    reg [3:0] ps, ns;
    reg [1:0] alu_op;
    reg cond, condflag, condreg;

    wire [2:0] opc;
    assign opc = inst[29:27];
    always @(ps) begin #1
        case (ps)
        `START: ns = `IF;
        `IF: ns = `ID;
        `ID: if(~cond) ns = `IF;
			else  begin case(opc)
                                3'b000:  if(inst[23]== 1'b0) ns = condflag? `PROCESSING:`PROC1 ;
                                         else             ns =  condflag? `PROC2:`PROC3 ;
                                3'b010: ns = `TRANSFER   ;
                                3'b101: ns =  `BRANCH   ;
                                endcase end
        `BRANCH: ns = (inst[26])? `LINK:`IF;
        `LINK: ns = `IF;
        `TRANSFER: ns = (inst[20])? `STORE:`LOAD;
        `STORE: ns = `IF;
        `LOAD: ns = `LOAD2;
        `LOAD2: ns = `IF;
        `PROCESSING: ns = condreg? `PROC4:`IF;
        `PROC1: ns = condreg? `PROC4:`IF;
        `PROC2: ns = condreg? `PROC4:`IF;
        `PROC3: ns = condreg? `PROC4:`IF;
        `PROC4: ns = `IF;
	default:ns = `IF;
        endcase
    end

    always @(ps) begin
        {pc_write, lord, mem_write, mem_read, ir_write, link,pcsrc,
        data_to_mem, reg_write, alusrca, ldz, ldc, ldn, ldv} = 14'b0;
        {reg_data, alusrcb} = 4'b0;
        case (ps)
        `START:;
        `IF: {mem_read, alusrca, lord, ir_write, alusrcb,
            alu_op, pc_write, pcsrc} = 10'b1001010010;
        `ID: {alusrca, alusrcb, alu_op, data_to_mem} = 6'b011000;
        `BRANCH: {pcsrc, pc_write} = 2'b11;
        `LINK: {link, reg_data, reg_write} = 4'b1101;
        `TRANSFER: {data_to_mem, alusrca, alusrcb} = 4'b1110;
        `STORE: {lord, mem_write} = 2'b11;
        `LOAD: {lord, mem_read} = 2'b11;
        `LOAD2: {reg_write, reg_data} = 3'b101;
        `PROCESSING: {alusrca, alusrcb, alu_op, 
                    ldz, ldn, ldc, ldv} = 9'b100101111;
        `PROC1: {alusrca, alusrcb, alu_op, ldz, ldn} = 7'b1001011;
        `PROC2: {alusrca, alusrcb, alu_op,
                ldz, ldn, ldc, ldv} = 9'b110101111;
        `PROC3: {alusrca, alusrcb, alu_op, ldz, ldn} = 7'b1101011;
        `PROC4: {reg_data, link, reg_write} = 4'b0001;

        endcase
    end

    

    always @(posedge clk) begin
        if(rst)
            ps = 4'b0000;
        else 
            ps=ns;
    end


    alu_controller ALU_controller(alu_op, func, alu_operation);


    assign cond = (c_op ==2'b11)? 1'b1:
                  (c_op == 2'b01)? ((~z)&(v~^n)):
                  (c_op == 2'b10)? v^n:z;

    assign condflag = (func == 3'b0)|(func == 3'b001)|
                      (func == 3'b010)|(func == 3'b110)? 1:0;
    
    assign condreg = (func == 3'b101)|(func == 3'b110)? 0:1;



endmodule

module alu_controller(alu_op, func, alu_operation);
    input [1:0] alu_op;
    input [2:0] func;
    output reg [2:0] alu_operation;

    always @(func, alu_op) begin
        alu_operation = 3'b0;

        if(alu_op == 2'b0)
            alu_operation = 3'd0;
        else if (alu_op == 2'd1)
            alu_operation = 3'd1;
        else begin
            alu_operation = func;
        end
        

        
    end
endmodule