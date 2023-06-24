module i2c_read_tb;

wire scl;
wire sda;
reg clk;
reg rst;
wire [7:0]address_tb;
wire [15:0]data_tb;
wire [7:0] pointer_tb;
reg [1:0]pointer_bit;
reg rd;
reg [2:0]i_address;

wire sda_in;   //to store address value for debug
reg sda_out;
reg sda_en;
reg [15:0]temp_data; 
reg [7:0]address_reg;
reg [7:0]pointer_reg;

wire scl_t;
integer i;

i2c_read_write dut(.clk(clk), .scl(scl), .sda(sda), .rst(rst), .address_tb(address_tb), .data_tb(data_tb), .pointer_tb(pointer_tb), .pointer_bit(pointer_bit), .rd(rd), .i_address(i_address));

assign scl_t=scl;
assign sda_in=sda;
assign sda=sda_en?sda_out:1'bz;

initial begin
    clk=0;
    forever begin
        #20 clk=~clk;
    end
end

initial begin
    rst=1;
    #300;
    rst=0;
    pointer_bit=2'b11;
    rd=1;
    i_address=3'b000;
end
    
initial begin
    repeat(1_000_000) @(posedge clk);
    repeat(1) @(posedge scl_t);
    sda_en=0;
    sda_out=0;
    address_reg=0;

    for(i=0;i<8;i=i+1) begin
        @(posedge scl_t);
        address_reg[7-i]=sda_in;
    end
    $display("-----------------------------------------------------------------------------------------------------------");
    if (address_tb==address_reg) begin
        $display("send address=%0b\trecieved address in tb=%0b",address_tb,address_reg);
        $display("task suscess");
        
    end
    else begin
        $display("send address=%0b\trecieved address in tb=%0b",address_tb,address_reg);
        $display("task failed");
    end
    $display("-----------------------------------------------------------------------------------------------------------");

    @(posedge scl_t);
    @(posedge clk); //complete reading 8th bit of address and start acking.
    sda_en=1;       //add ack
    sda_out=0;  
    pointer_reg=0;
    for(i=0;i<8;i=i+1) begin
        @(posedge scl_t);
          sda_en=0;                     //completes ack and start reading 1st bit of pointer register
        pointer_reg[7-i]=sda_in;
    end
    $display("-----------------------------------------------------------------------------------------------------------");
    if (pointer_tb==pointer_reg) begin
        $display("send pointer address=%b\trecieved address in tb=%b",pointer_tb,pointer_reg);
        $display("task suscess");
        
    end
    else begin
        $display("send address=%b\trecieved address in tb=%b",pointer_tb,pointer_reg);
        $display("task failed");
    end
    $display("-----------------------------------------------------------------------------------------------------------");
     @(posedge scl_t);
     @(posedge clk); //complete reading 8th bit of pointer register and start acking.
     sda_en=1;
     sda_out=0; 
    @(posedge scl_t);
     @(posedge clk); //completes the acking.
      sda_en=0;
      address_reg=0;

    for(i=0;i<8;i=i+1) begin
        @(posedge scl_t);          //start reading address again.
        address_reg[7-i]=sda_in;
    end
    $display("-----------------------------------------------------------------------------------------------------------");
    if (address_tb==address_reg) begin
        $display("send address=%0b\trecieved address in tb=%0b",address_tb,address_reg);
        $display("task suscess");
        
    end
    else begin
        $display("send address=%0b\trecieved address in tb=%0b",address_tb,address_reg);
        $display("task failed");
    end
    $display("-----------------------------------------------------------------------------------------------------------");

    @(posedge scl_t);
    @(posedge clk); //complete reading 8th bit of address 2nd time and start acking.
    sda_en=1;
    sda_out=0;  
    temp_data[15:8]=8'b1010_1010;
     for(i=0;i<8;i=i+1) begin
        @(posedge scl_t);
        sda_out=temp_data[15-i];
     end
     @(posedge scl_t);
     @(posedge clk);
    temp_data[7:0]=8'b1010_1010;
     for(i=0;i<8;i=i+1) begin
        @(posedge scl_t);
        sda_out=temp_data[7-i];
     end
     @(posedge scl_t);

       $display("-----------------------------------------------------------------------------------------------------------");
    if (data_tb==temp_data) begin
        $display("send address=%0b\trecieved address in tb=%0b",temp_data,data_tb);
        $display("task suscess");
        
    end
    else begin
        $display("send address=%0b\trecieved address in tb=%0b",temp_data,data_tb);
        $display("task failed");
    end
    $display("-----------------------------------------------------------------------------------------------------------");
     @(posedge scl_t);
      
    repeat(10)@(posedge scl_t);
end
endmodule