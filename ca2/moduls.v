`timescale 1ns/1ns

module PC(d, clk, rst, q);
    input [31:0]d;
    input clk, rst;
    output [31:0]q;
    reg [31:0]q;
       
    always @(posedge clk) begin
        if(rst)
            q <= 32'b0;
        else
            q<=d;
    end

endmodule

module adder(a,b,y);
    input [31:0] a,b;
    output [31:0] y;
    assign y = a+b ;
endmodule

module shifter32(a,y);
    input [31:0] a;
    output [31:0] y;
    assign y = a<<2 ;
endmodule

module shifter26(a,y);
    input [25:0] a;
    output [25:0] y;
    assign y = a<<2 ;
endmodule

module mux3_5bit(i0,i1,i2,sel,y);
    input [4:0]i0,i1,i2;
    input [1:0]sel;
    output [4:0]y;
    assign y = (sel == 2'b10)?i2:
               (sel == 2'b01)?i1:i0;
    
endmodule

module mux2_32bit(i0,i1,sel,y);
    input [31:0]i0,i1;
    input sel;
    output [31:0]y;
    assign y = sel?i1:i0;
    
endmodule



module inst_mem(address,instruction);
    input [31:0]address;
    output [31:0]instruction;
    
    reg [7:0] mem[0:2**22-1];

    initial
    begin
        $readmemb("inst_mem.txt",mem);
    end

    assign instruction = {mem[address],mem[address+1],mem[address+2],mem[address+3]};
endmodule

module reg_file(read_reg1, read_reg2, write_reg, write_data,
                 reg_write, read_data1, read_data2, clk);
    input [4:0] read_reg1, read_reg2, write_reg;
    input [31:0] write_data;
    input reg_write, clk;
    output [31:0] read_data1, read_data2;

    reg [31:0] registers[0:31];
    assign registers[0] = 32'b0;

    always @(posedge clk) begin
        if(reg_write)
            if(write_reg!=0)            
            registers[write_reg] = write_data;
    end


    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];
endmodule

module data_memory(address, write_data, mem_read,
                   mem_write, read_data, clk);

        input [31:0]address, write_data;
        input mem_read, mem_write, clk;
        output [31:0]read_data;
        reg [31:0] read_data;
        
        reg [7:0] memory_file[0:2**22-1];

        initial begin
            $readmemh("data_mem.txt", memory_file);
        end
	reg[31:0] mem2000, mem2004;
	assign mem2000 = {memory_file[2000], memory_file[2001], memory_file[2002], memory_file[2003]};
	assign mem2004 = {memory_file[2004], memory_file[2005], memory_file[2006], memory_file[2007]};
    initial begin

        #3615
        $display("value of biggest number: %d, ", mem2000);
        $display("index of biggest number: %d, ", mem2004);
    end
        always @(posedge clk) begin
            if(mem_write)
                {memory_file[address],memory_file[address+1],
                 memory_file[address+2],memory_file[address+3]} = write_data;
        end

        always @(mem_read) begin
            if(mem_read)
                read_data = {memory_file[address],memory_file[address+1],
                memory_file[address+2],memory_file[address+3]};
        end
    
endmodule

module ALU(a, b, alu_op, result, zero);

    input [31:0] a,b;
    input [2:0]alu_op;
    output [31:0]result;
    output zero;
    reg [31:0] comp;
    assign zero = (result==32'b0)? 1'b1 :1'b0;
    assign comp = a-b;
    assign result = (alu_op == 3'b000)? (a+b):
                    (alu_op == 3'b001)? (a-b):
                    (alu_op == 3'b010)? (a&b):
                    (alu_op == 3'b011)? (a|b):
                    (alu_op == 3'b100)? (comp[31]) ? 32'b1: 32'b0 : 32'b0;


endmodule
