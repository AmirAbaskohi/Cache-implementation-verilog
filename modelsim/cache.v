`timescale 1ns/1ns
module memory(input[14:0] address, output[31:0] out1, out2, out3, out4);
  reg[31:0] mem [0:32767];
  initial $readmemh("mem.data", mem);
  assign out1 = mem[address];
  assign out2 = mem[address+1];
  assign out3 = mem[address+2];
  assign out4 = mem[address+3];
endmodule

module cache(input[14:0] address, input clk, output reg isMissed, output reg[31:0] data);
    wire[31:0] mem_out1, mem_out2, mem_out3, mem_out4;
    reg[14:0] tempAddress;
    
    memory main_memory(tempAddress, mem_out1, mem_out2, mem_out3, mem_out4);

    reg[31:0] cache [0:1023][3:0];
    reg[2:0] cacheTags [0:1023];
    reg validTags [0:1023];

    always@(posedge clk)begin
      if(validTags[address[11:2]] && cacheTags[address[11:2]] == address[14:12]) begin
        isMissed = 0;
      end
      else isMissed =  1;

      if(isMissed)begin
        tempAddress = address & 15'b111111111111100;
        cacheTags[address[11:2]] = address[14:12];
        validTags[address[11:2]] = 1;
        cache[address[11:2]][0] = mem_out1;
        cache[address[11:2]][1] = mem_out2;
        cache[address[11:2]][2] = mem_out3;
        cache[address[11:2]][3] = mem_out4;
      end

      data = cache[address[11:2]][address[1:0]];

    end

endmodule

module cache_tb();
  reg[14:0] address;
  reg clk;
  wire [31:0] data;
  wire isMissed;
  real count, hit_rate;
  initial begin
    count = 0;
    hit_rate = 0;
    clk = 0;
    address = 1024;
  end
  always #2 clk = ~clk;
  cache test(address, clk, isMissed, data);
  always@(posedge clk)begin
    #1
    if (address  < 9216 )begin
      count = count + 1;
      if (~isMissed) hit_rate = hit_rate + 1;
      address = address + 1;
    end
    else begin
      $display ("Number of Access : %d", count);
      $display ("Number of Hits : %d", hit_rate);
      $display ("Hit Rate : %f", hit_rate / count);
    end
  end
  initial #32772 $stop;
endmodule

