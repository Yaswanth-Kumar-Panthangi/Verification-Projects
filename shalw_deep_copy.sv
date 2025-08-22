// Shallow copy

module test;

  class sub;
    int b;  
  endclass

  class main;
    int a;
    sub sub_h = new();
  endclass
  
  main m1,m2;
  
  initial begin
    m1 = new();
    m1.a =10;
    m1.sub_h.b=20;
           
    m2 = new m1;
    m2.a =30;
    m2.sub_h.b=40;

    $display(" m1.a = %0d,  m1.sub_h.b= %0d",m1.a,m1.sub_h.b);    
    $display(" m2.a = %0d,  m2.sub_h.b= %0d",m2.a,m2.sub_h.b);
    
  end

endmodule






// // Deep copy

// module test;

//   class sub;
//     int b;  
//     function sub copy();
//       copy = new();
//       copy.b = this.b;   
//     endfunction
//   endclass

//   class main;
//     int a;
//     sub sub_h = new();
//     function main copy();
//       copy = new();
//       copy.a = this.a;
//       copy.sub_h = this.sub_h.copy();
//     endfunction
//   endclass
  
//   main m1,m2;
  
//   initial begin
//     m1 = new();
//     m1.a =10;
//     m1.sub_h.b=20;
           
//     m2 = m1.copy();

//     m2 = new();
//     m2.a =30;
//     m2.sub_h.b=40;

//     $display(" m1.a = %0d, \n m1.sub_h.b= %0d",m1.a,m1.sub_h.b);    
//     $display(" m2.a = %0d, \n m2.sub_h.b= %0d",m2.a,m2.sub_h.b);
    
//   end

// endmodule


