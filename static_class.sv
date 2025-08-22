class packet;
  byte id;
  static int no_of_pkts;
  
  function new();
    no_of_pkts++;
    id = no_of_pkts;    
  endfunction
  
  static function void display();
    $display("--------------------------------------");
//     $display("\t packet_id  = %0d",id);
    $display("\t %0d packets created.",no_of_pkts);
    $display("--------------------------------------");    
  endfunction
endclass


module test;
  packet pkt[5]; 
  packet p;
  
  initial begin 
    foreach(pkt[i]) begin
      pkt[i]=new;
//       pkt[i].display();
    end   
    p.display();
  end
endmodule