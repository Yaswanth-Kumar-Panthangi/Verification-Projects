class yash;
  int x;
  int y;
  
  function new(int y);
    this.y = y;    
  endfunction
  
  function void set(int x);
   this.x=x; 
  endfunction
  
  function void print();
    $display("x=%0d",x);
    $display("y=%0d",y);
  endfunction    
endclass


module test;   
  yash class1;
  yash class2;

  initial begin
    class1 = new(2);
    class2 = new(4);    
    class1.set(1);
    class2.set(3);    
    $display("Class1:");
    class1.print();    
    $display("Class2:");
	class2.print();    
  end
endmodule