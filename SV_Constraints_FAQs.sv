
///////// Pattern: 1234554321 ////////////////////////////////////////////
class pattern_gen;
  rand int a[];  
  constraint pattern_c {
  a.size == 10;
    
  foreach (a[i])
    if (i < 5) 
      a[i] == i+1;
    else 
//       a[i] == 10-i;
            a[i] == a.size()-i;
  }
  
// Alternate solution  -------------
// constraint pattern_alt_c {
// a.size == 10;
// foreach (a[i])
// if (i < 5)
// a[i] == i + 1;
// else
// // Constrain the second half to be a mirror of the first
// a[i] == a[a.size() - 1 - i]; // e.g., a[5]==a[4], a[6]==a[3]
// }  
  
  function void post_randomize();
    $display("Generated Pattern: %0p", a);
  endfunction
endclass

module test;
	pattern_gen h1;
  initial begin
  	h1 = new();
  	void'(h1.randomize());
  end
endmodule


///////////////////////////////////////////////////////////////////


///////// Pattern: 9 19 29 39 49 59 69 79 ///////////////////////////////////////
class pattern_gen;
  rand int a[];
  
  constraint pattern_c {
    a.size() == 10;
    foreach(a[i])
      a[i] == (i*10)+9;
  }
  
//   // Alternate Solution
//   constraint pattern_alt_c {
//     a.size == 8;
//     a[0] == 9;  // Anchor the first value

//     foreach (a[i])
//       if (i > 0)
//         a[i] == a[i-1] + 10;  // Each subsequent value is 10 more than the last
//   }
  
  function void post_randomize();
    $display("Generated Pattern: %0p", a);
  endfunction
endclass

module test;
  pattern_gen h1;
  initial begin
    h1 = new();
    void'(h1.randomize());
  end
endmodule



///////////////////////////////////////////////////////////////////


///////// Pattern: 5 -10 15 -20 25 -30 ////////////////////////////////////
class pattern_gen;
  rand int a[];
  
  constraint pattern_c {
    a.size() == 10;
    foreach(a[i])
      if(i%2 == 0)
        a[i] == 5*(i+1);
      else
        a[i] == -5*(i+1);
  }
  
// Alternate Solution
//   constraint pattern_alt_c {
//     a.size == 6;

//     foreach (a[i])
//       a[i] == ((i % 2 == 0) ? 1 : -1) * (5 * (i + 1));
//   }

  
  function void post_randomize();
    $display("Generated Pattern: %0p", a);
  endfunction
endclass

module test;
  pattern_gen h1;
  initial begin
    h1 = new();
    void'(h1.randomize());
  end
endmodule



///////////////////////////////////////////////////////////////////



///////// Pattern: 1122334455 ////////////////////////////////////
class pattern_gen;
  rand int a[];

  constraint pattern_c {
    a.size == 10;

    foreach (a[i])
      a[i] == (i / 2)+1;
  }
  
// Alternate solution  
//   constraint pattern_c {
//     a.size == 10;

//     foreach (a[i])
//       if(i%2==0)
//         if(i<1) a[i] ==1;
//     	else    a[i] == a[i-1]+1;
//       else
//         a[i] == a[i-1];
//   }  

  function void post_randomize();
    $display("Generated Pattern: %p", a);
  endfunction
endclass


module test;
  pattern_gen h1;

  initial begin
    h1 = new();
    void'(h1.randomize());
  end
endmodule
///////////////////////////////////////////////////////////////////



/////////// number between 1.35 and 2.57 ////////////////////////////////////
class real_gen;
  rand int scaled_val;
  real final_val;

  constraint scaled_c {
    // Randomize an integer in the scaled range [1350:2570]
    scaled_val inside {[1350:2570]};
  }

  function void post_randomize();
    // After randomization, scale it down to a real number
    final_val = scaled_val / 1000.0;
    $display("Generated Real Number: %f", final_val);
  endfunction
endclass

module test;
  real_gen h1;
  initial begin
    h1 = new();
    void'(h1.randomize());
  end
endmodule
///////////////////////////////////////////////////////////////////



/////////// Pattern: 0102030405 ////////////////////////////////////
class pattern_gen;
  rand int a[];
  constraint pattern_c {
    a.size == 10;
    foreach (a[i])
      if (i % 2 == 0)
        a[i] == 0;
      else
        a[i] == (i+1) / 2;
  }
  
//Alternate solution
//     constraint pattern_c {
//     a.size == 10;
//     foreach (a[i])
//       a[i] == (i % 2) * ((i / 2) + 1);
//   }

  function void post_randomize();
    $display("Generated Pattern: %p", a);
  endfunction
endclass

module test;
  pattern_gen h1;
  initial begin
    h1 = new();
    void'(h1.randomize());
  end
endmodule
///////////////////////////////////////////////////////////////////



//Generate values from {25, 27, 30, 36, 40, 45} without inside/////////////
class pattern_gen;
  rand int a;
  constraint c1 {
    a > 24;
    a < 46;
    ((a % 5) == 0) || ((a % 9) == 0);
    a != 35;
  }
  

  function void post_randomize();
    $display("Generated Value: %0d", val);
  endfunction
endclass


module test;
  pattern_gen h1;

  initial begin
    h1 = new();
    repeat (10) begin
      void'(h1.randomize());
    end
  end
endmodule
///////////////////////////////////////////////////////////////////


///////32-bit variable with 12 non-consecutive 1's/////////////////
class non_consecutive_gen;
  rand bit [31:0] data;

  constraint valid_data_c {
    // Constraint 1: Ensure there are exactly 12 ones
    $countones(data) == 12;
    // Constraint 2: Ensure no two ones are consecutive
    foreach (data[i])
      if (i > 0)
        // If a bit is 1, the previous bit must be 0
        (data[i] == 1) -> (data[i-1] == 0);
  }
  
//// Alternate solution
//   constraint valid_data_alt_c {
//     $countones(data) == 12;
//     foreach (data[i])
//       if (i > 0)
//         // It is illegal for a bit and its predecessor to both be 1
//         !(data[i] == 1 && data[i-1] == 1);
//   }  

  function void post_randomize();
    $display("Generated Data: %b", data);
    $display("Number of ones: %0d", $countones(data));
  endfunction
endclass

module test;
  non_consecutive_gen h1;
  initial begin
    h1 = new();
    void'(h1.randomize());
  end
endmodule



class factorial_gen;
  rand int even_fact[];
  rand int odd_fact[];
  // Helper function to calculate factorial
  function int fact(int n);
    if (n <= 1) return 1;
    else return n * fact(n - 1);
  endfunction
  constraint factorial_c {
    even_fact.size == 5;
    odd_fact.size == 5;
    // Constrain the array for even numbers (2!, 4!, 6!, 8!, 10!)
    foreach (even_fact[i])
      even_fact[i] == fact(2 * (i + 1));
    // Constrain the array for odd numbers (1!, 3!, 5!, 7!, 9!)
    foreach (odd_fact[i])
      odd_fact[i] == fact((2 * i) + 1);  }
  function void post_randomize();
    $display("Factorials of first 5 even numbers: %p", even_fact);
    $display("Factorials of first 5 odd numbers:  %p", odd_fact);
  endfunction
endclass

module test;
  factorial_gen h1;
  initial begin
    h1 = new();
    void'(h1.randomize());
  end
endmodule



class array_gen;
  rand int a[2][4];
  constraint array_eo_c {
    foreach (a[i, j]) {
      a[i][j] inside {[1:100]};
      if (i == 0) // First row (first 4 locations)
        a[i][j] % 2 == 0; // Must be even
      else // Second row (next 4 locations)
        a[i][j] % 2 != 0; // Must be odd
    }  }
  function void post_randomize();
    $display("Generated 2D Array: %p", a);
  endfunction
endclass

module test;
  array_gen h1;
  initial begin
    h1 = new();
    void'(h1.randomize());
  end
endmodule



class prime_gen;
  rand int prime_num;

  // Constraint: prime_num must be in the range 1–100
  constraint prime_c {
    prime_num inside {[1:100]};
  }

  // Function to check if a number is prime
  function bit is_prime(int n);
    if (n <= 1) return 0;
    for (int i = 2; i * i <= n; i++)
      if (n % i == 0) return 0;
    return 1;
  endfunction

  // Ensure prime_num is prime after randomization
  function void post_randomize();
    while (!is_prime(prime_num)) begin
      void'(this.randomize());
    end
    $display("Generated Prime Number: %0d", prime_num);
  endfunction
endclass

module test;
  prime_gen h1;
  initial begin
    h1 = new();
    repeat (10) void'(h1.randomize());
  end
endmodule
