interface intf(input bit clk);
    logic rd,scl,rst;
    wire  sda;
    logic [1:0]pointer_bit;
    logic [2:0]i_address;
    logic [15:0]i_data;
    logic [7:0] pointer_tb;
    logic [15:0]data_tb;
    logic [7:0]address_tb;
    logic [3:0]state;
    logic sda_en;
    logic sda_reg;
    logic sda_in;


endinterface

//---------------------------------------------------------------------------------------------

class transaction;
    randc bit  rd;
    randc bit  [1:0]pointer_bit;
    randc bit     [2:0]i_address;
    rand  bit    [15:0]i_data;
    bit        [7:0] pointer_tb;
    bit        [15:0]data_tb;
    bit        [7:0]address_tb;

  constraint cn1{pointer_bit inside{2'b00, 2'b10, 2'b11};}
  constraint cn2{rd dist{0:=50,1:=50};}

    function void display(string s);
        $display("%s\tRD=%0b\tpointer=%0d\taddress=%b\tdata=%b\t@%0d",s,rd,{6'd0,pointer_bit},{4'b1001,i_address},i_data,$time);
        
    endfunction

endclass
//---------------------------------------------------------------------------------------------

class refdata;
    bit [7:0]ad1;
    bit [7:0]ad2;
    bit [7:0]pr;
    bit [15:0]da;



endclass
//---------------------------------------------------------------------------------------------

class generator;

  mailbox #(transaction) gen2driv;
  mailbox #(transaction) gen2scb;
  mailbox gen2cov;
    int repeat_no;
    event drivnext;
    event scbnext;
    event ended;
    int i;

  function new(mailbox #(transaction) gen2driv, mailbox gen2cov,mailbox #(transaction) gen2scb);
        this.gen2driv=gen2driv;
        this.gen2cov=gen2cov;
        this.gen2scb=gen2scb;
    endfunction

    task main();
        transaction t;
        t=new();
        i=1;
        repeat(repeat_no) begin
            
            if(!t.randomize)
              $fatal("RANDOMIZATION FAILED");
            else begin
              $display("\nTRANSECTION NUMBER = %0d",i);
              t.display("GENERATOR ");
            end
          gen2driv.put(t);
          gen2scb.put(t);
          gen2cov.put(t);
          i++;
            // @(drivnext);
             @(scbnext);
        end
        ->ended;
    endtask
endclass

//--------------------------------------------------------------------------------------------------------------------------------------------------
class coverage;
    transaction t;
    mailbox gen2cov;

    covergroup cg;
     c1: coverpoint    t.pointer_bit{bins b0={2'd0}; bins b1={2'd2}; bins b3={2'd3};}
      c2: coverpoint    t.i_address;
      c3: coverpoint    t.i_data;
      c4: coverpoint    t.rd;
      c5: cross c1,c2,c3,c4;
        
    endgroup

  function new(mailbox gen2cov);
    	this.gen2cov=gen2cov; 
        t=new();
   	 	cg=new();
    endfunction

    task main();
      forever begin
       gen2cov.get(t);
       cg.sample(); 
      end
    endtask

    task display();
      $display("COVERAGE=%f",cg.get_coverage());
    endtask

endclass

//--------------------------------------------------------------------------------------------------------------------------------------------------
class driver;
  mailbox #(transaction)gen2driv;
   mailbox #(refdata) driv2scb;
    event drivnext;
    int no_trans=0;
    virtual intf intf_h;
    int i=0;
    bit [7:0]ad1;
    bit [7:0]ad2;
    bit [7:0]pr;
    bit [15:0]da;
    refdata r;
     

    function new(mailbox #(transaction) gen2driv, mailbox #(refdata) driv2scb,virtual intf intf_h);
        this.gen2driv=gen2driv;
        this.driv2scb=driv2scb;
        this.intf_h=intf_h;
        r=new();
    endfunction

    task reset();
        
        intf_h.rst<=1;
        intf_h.rd<=0;
        intf_h.sda_en<=0;
        intf_h.sda_reg<=0;
        intf_h.pointer_bit<=0;
        intf_h.i_address<=0; 
        intf_h.i_data<=0;
      repeat(2) @(posedge intf_h.clk);
        intf_h.rst<=0;
        
    endtask

    task main();
        transaction t;
        forever begin

            gen2driv.get(t);
            @(posedge intf_h.scl);
            if(t.rd==1) begin
                intf_h.rd<=t.rd;
                intf_h.pointer_bit<=t.pointer_bit;
                intf_h.i_address<=t.i_address;
                
                intf_h.sda_en<=0;
                intf_h.sda_reg<=0;
                
                repeat (4_999) @(posedge intf_h.clk);
                @(posedge intf_h.scl);
                i=0;

                repeat (8) begin  
                        intf_h.sda_en<=0;
                        intf_h.sda_reg<=0;
                        r.ad1[7-i]=intf_h.sda_in;
                        i++;
                        @(posedge intf_h.scl);        
                end

                    intf_h.sda_en<=1;
                    intf_h.sda_reg<=0;
                    @(posedge intf_h.scl);    //start address ack-1
                        
                i=0;
                repeat (8) begin    
                        intf_h.sda_en<=0;
                        intf_h.sda_reg<=0;
                        r.pr[7-i]=intf_h.sda_in;
                       i++;
                        @(posedge intf_h.scl);
                end
                  
                        intf_h.sda_en<=1;
                        intf_h.sda_reg<=0;   // reg pointer ack
                        @(posedge intf_h.scl);
             
              			
                        intf_h.sda_en<=0;      //should make low for start
                        intf_h.sda_reg<=0;
                     @(posedge intf_h.scl);
               
               
                    i=0; 
             	 repeat (8) begin
                        r.ad2[7-i]=intf_h.sda_in;
                        i++;
                        @(posedge intf_h.scl);
                       
                    end

                    intf_h.sda_en<=1;
                    intf_h.sda_reg<=0;
                    @(posedge intf_h.scl);  //start address ack-2
                 

                 
                i=0;
                repeat (8) begin 
                  intf_h.sda_en<=1;
                  intf_h.sda_reg<=t.i_data[15-i];    // sending msb data
                  i++;
                  @(posedge intf_h.scl);
                end
                
                @(posedge intf_h.scl);
                    intf_h.sda_en<=1;
                    intf_h.sda_reg<=0;      // data ack 
               

                 i=0;
                 repeat (8) begin
                  
                  intf_h.sda_reg<=t.i_data[7-i];    // sending lsb data
                  i++;
                  @(posedge intf_h.scl);
                end

                @(posedge intf_h.scl);
                    intf_h.sda_en<=1;
                    intf_h.sda_reg<=1;      // nack 

                @(posedge intf_h.scl);
                intf_h.sda_en<=0;
                driv2scb.put(r);

                @(posedge intf_h.scl);
                
                
                ->drivnext;
            end

            if(t.rd==0) begin
                intf_h.rd<=t.rd;
                intf_h.pointer_bit<=t.pointer_bit;
                intf_h.i_address<=t.i_address;
                intf_h.i_data<=t.i_data;
    
                
                intf_h.sda_en<=0;
                intf_h.sda_reg<=0;
                
                repeat (4_999) @(posedge intf_h.clk);
                @(posedge intf_h.scl);
                i=0;

                repeat (8) begin 
                        r.ad1[7-i]=intf_h.sda_in;
                        i++;
                        @(posedge intf_h.scl);        
                end

;
                    @(posedge intf_h.scl);    //start address ack-1
                        
                i=0;
                repeat (8) begin    
                        intf_h.sda_en<=0;
                        intf_h.sda_reg<=0;
                        r.pr[7-i]=intf_h.sda_in;
                       i++;
                        @(posedge intf_h.scl);
                end
                  
                                                   // reg pointer ack
                        @(posedge intf_h.scl);
        			

                    i=0;
                repeat (8) begin 
                        intf_h.sda_en=0;     
                        intf_h.sda_reg=0;   
                        r.da[15-i]=intf_h.sda_in;
                       i++;
                        @(posedge intf_h.scl);
                end
                 
                        @(posedge intf_h.scl);
						
              			
                        
              i=0;
                repeat (8) begin
                        r.da[7-i]=intf_h.sda_in;
                       i++;
                        @(posedge intf_h.scl);
                end
                  
                        intf_h.sda_en<=1;
                        intf_h.sda_reg<=0;   // data ack-2
                        @(posedge intf_h.scl);

                @(posedge intf_h.scl);
                intf_h.sda_en<=0;
                driv2scb.put(r);

                @(posedge intf_h.scl);
                

                
            end
          reset();
        end
    endtask


endclass
//--------------------------------------------------------------------------------------------------------------------------------------------------
class scoreboard;
    mailbox #(transaction) gen2scb;
    mailbox #(refdata) driv2scb;
    virtual intf intf_h;
    event scbnext;
    transaction t;
    refdata r;
    int qa[$];
    int qd[$];
    int qp[$];
    int i=1;

      function new( mailbox #(transaction) gen2scb,mailbox #(refdata) driv2scb,virtual intf intf_h);
        this.driv2scb=driv2scb;
        this.gen2scb=gen2scb;
        this.intf_h=intf_h;
        t=new();
        r=new();
    endfunction

    task main();
    
        forever begin
            driv2scb.get(r);
            gen2scb.get(t);

            if(t.rd==1)begin
              if(t.i_data==intf_h.data_tb)
                  $display("data sended succesfully\t%b",intf_h.data_tb);
              	else begin
                  $display("data not sended succesfully\t%b\t%b",intf_h.data_tb[15:8],intf_h.data_tb[7:0]);
                  qd.push_front(i);
                end

                if(t.i_address== r.ad1[3:1] )
                  $display("address sended succesfully\t%b",r.ad1);
              	else  begin
                  $display("address not  sended succesfully\t%b",r.ad1);
                qa.push_front(i);
                end

                if(t.i_address== r.ad2[3:1] )
                  $display("address sended succesfully\t%b",r.ad2);
              	else begin
                  $display("address 2 not  sended succesfully\t%b",r.ad2);
                  qa.push_front(i);
                end

                if(t.pointer_bit== r.pr[1:0] )
                  $display("pointer sended succesfully\t%b",r.pr[1:0]);
                else begin
                  $display("pointer not sended succesfully\t%b",r.pr);
                  qp.push_front(i);
                end
              i++;
            end

            if(t.rd==0) begin
              if(t.i_data==r.da)
                  $display("data sended succesfully\t%b",r.da);
              	else begin
                  $display("data not sended succesfully\t%b\t%b",r.da[15:8],r.da[7:0]);
                  qd.push_front(i);
                end

                if(t.i_address== r.ad1[3:1] )
                  $display("address sended succesfully\t%b",r.ad1);
              	else begin
                  $display("address not  sended succesfully\t%b",r.ad1);
                  qa.push_front(i);
                end

                if(t.pointer_bit== r.pr[1:0] )
                  $display("pointer sended succesfully\t%b",r.pr);
                else begin
                  $display("pointer not sended succesfully\t%b",r.pr);
                  qp.push_front(i);
                end
              i++;
            end
            ->scbnext;
            
        end
    endtask
  
  task report_g;
     transaction t;
      int i;
      int temp;
      
      if(qa.size()) begin
        $display("The  Failed address transmission Transections Numbers are ");
          foreach (qa[i]) begin
            $display("%0d",qa[i]);
          end
      end
      else
        $display("Passed all testcases for Address Transmissions");
      
        if(qp.size()) begin
        $display("The  Failed pointer transmission Transections Numbers are ");
          foreach (qa[i]) begin
            $display("%0d",qp[i]);
          end
      end
      else
        $display("Passed all testcases for Pointer Transmissions");

        if(qd.size()) begin
        $display("The  Failed Data transmission Transections Numbers are ");
          foreach (qa[i]) begin
            $display("%0d",qd[i]);
          end
      end
      else
        $display("Passed all testcases for Data Transmissions");
    endtask
  
endclass
//--------------------------------------------------------------------------------------------------------------------------------------------------
class environment;
    mailbox #(transaction) gen2driv;
  mailbox #(transaction) gen2scb;
  	mailbox gen2cov;
    mailbox #(refdata) driv2scb;

    event nextgd;
    event nextgs;
    generator g;
    driver d;
    scoreboard s;
  	coverage c;
    virtual intf intf_h;

    function new(virtual intf intf_h);
        this.intf_h=intf_h;
        gen2driv=new();
        driv2scb=new();
        gen2scb=new();
      	gen2cov=new();

        g=new(gen2driv,gen2cov,gen2scb);
        d=new(gen2driv,driv2scb,intf_h);
        s=new(gen2scb,driv2scb,intf_h);
        c=new(gen2cov);

        g.drivnext=nextgd;
        d.drivnext=nextgd;
        g.scbnext=nextgs;
        s.scbnext=nextgs;
    endfunction

    task pre_test();
        d.reset();
    endtask

    task test();
        fork
            g.main();
            d.main();
            s.main();
            c.main();
        join_any
    endtask

    task post_test();
        wait(g.ended.triggered);
         $display("-------------------------------------------------------------------------------");
         s.report_g();
        $display("-------------------------------------------------------------------------------");
        c.display();
        $display("-------------------------------------------------------------------------------");
        $finish();
         
    endtask

    task run();
         pre_test();
         test();
         post_test();
    endtask

endclass
//--------------------------------------------------------------------------------------------------------------------------------------------------
program test(intf intf_h);
    environment e;
    initial begin
        e=new(intf_h);
        e.g.repeat_no=1000;
        e.run();

    end
endprogram
//--------------------------------------------------------------------------------------------------------------------------------------------------
module i2c_tb;
    
    bit clk;

    initial begin
        clk=0;
        forever #5 clk=~clk;
    end

    
  
	initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
  intf intf_h(clk);
  assign intf_h.sda=intf_h.sda_en?intf_h.sda_reg:1'bz;
  assign intf_h.sda_in=intf_h.sda;
    test a(intf_h);
     i2c_read_write dut(intf_h.clk,intf_h.rst,intf_h.sda,intf_h.scl,intf_h.address_tb,intf_h.pointer_tb,intf_h.data_tb,intf_h.pointer_bit,intf_h.rd,intf_h.i_address,intf_h.i_data);
    

endmodule
