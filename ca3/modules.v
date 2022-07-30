`timescale 1ns/1ns

module register32bit(d, clk, rst, q, pc_write);
    input [31:0]d;
    input clk, rst, pc_write;
    output [31:0]q;
    reg [31:0]q;
       
    always @(posedge clk) begin
        if(rst)
            q <= 32'b0;
        else if(pc_write)
            q<=d;
    end

endmodule

module register32bitir(d, clk, rst, q, pc_write);
    input [31:0]d;
    input clk, rst, pc_write;
    output [31:0]q;
    reg [31:0]q;
       
    always @(posedge clk) begin
        if(rst)
            q <= 32'b11010000000000000011001111101000;
        else if(pc_write)
            q<=d;
    end

endmodule

module register1bit(d, clk, rst, q, pc_write);
    input d;
    input clk, rst, pc_write;
    output q;
    reg q;
       
    always @(posedge clk) begin
        if(rst)
            q <= 1'b0;
        else if(pc_write)
            q=d;
    end

endmodule

module mux2_32bit(i0,i1,sel,y);
    input [31:0]i0,i1;
    input sel;
    output [31:0]y;
    assign y = sel?i1:i0;
    
endmodule

module reg_file(read_reg1, read_reg2, write_reg, write_data,
                 reg_write, read_data1, read_data2, clk);

    input [3:0] read_reg1, read_reg2, write_reg;
    input [31:0] write_data;
    input reg_write, clk;
    output [31:0] read_data1, read_data2;

    reg [31:0] registers[0:15];
    assign registers[0] = 32'b0;

    always @(posedge clk) begin
        if(reg_write)
            if(write_reg!=0)            
            registers[write_reg] = write_data;
    end


    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];
endmodule

module memory(address, write_data, mem_read,
                   mem_write, read_data, clk);

        input [31:0]address, write_data;
        input mem_read, mem_write, clk;
        output [31:0]read_data;
        reg [31:0] read_data;
        
        reg [31:0] memory_file[0:2**16-1];

        initial begin
            $readmemb("data_mem.txt", memory_file);
        end
	reg[31:0] mem2000, mem2004;

	assign mem2000 = memory_file[2000];
	assign mem2004 = memory_file[2004];

    initial begin #6000
        $display("value of biggest number: %d, ",  $signed(mem2000));
        $display("index of biggest number: %d, ", mem2004);
    end

        always @(posedge clk) begin
            if(mem_write)
                memory_file[address] = write_data;
        end


	assign read_data = mem_read? memory_file[address+32'b0] : read_data;

endmodule

module mux2_4bit(i0,i1,sel,y);
    input [3:0]i0,i1;
    input sel;
    output [3:0]y;
    assign y = sel?i1:i0;
    
endmodule

module mux3_32bit(i0,i1,i2,sel,y);
    input [31:0]i0,i1,i2;
    input [1:0]sel;
    output [31:0]y;
    assign y = (sel == 2'b10)?i2:
               (sel == 2'b01)?i1:i0;
    
endmodule

module mux4_32bit(i0,i1,i2,i3,sel,y);
    input [31:0]i0,i1,i2,i3;
    input [1:0]sel;
    output [31:0]y;
    assign y = (sel == 2'b11)?i3:
               (sel == 2'b10)?i2:
               (sel == 2'b01)?i1:i0;
    
endmodule

module ALU(a, b, alu_op, result, z,c,n,v);

    input [31:0] a,b;
    input [2:0]alu_op;
    output [31:0]result;
    output z,c,n,v;
    reg [31:0] comp;
    assign zero = (result==32'b0)? 1'b1 :1'b0;
    assign comp = a-b;
    assign result = (alu_op == 3'b000)? (a+b):
                    (alu_op == 3'b001)? (a-b):
                    (alu_op == 3'b010)? (a-b):
                    (alu_op == 3'b011)? (a&b):
                    (alu_op == 3'b100)? -b :
                    (alu_op == 3'b101)? (a&b):
                    (alu_op == 3'b110)? (a-b):
                    (alu_op == 3'b111)? b: 32'b0;

    assign z = ~|result;
    assign n = result[31];
    assign v = (alu_op==3'b000)? (~(a[31]^b[31]))&(a[31]^result[31]):
               (alu_op==3'b001|alu_op==3'b010|alu_op==3'b110)?
               ((a[31]^b[31])&(a[31]^result[31])):1'b0;
    assign c = v;

endmodule










