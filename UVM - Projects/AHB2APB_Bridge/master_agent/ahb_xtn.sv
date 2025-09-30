class ahb_xtn extends uvm_sequence_item;
	`uvm_object_utils(ahb_xtn)
	
	rand bit[1:0] Htrans;
	rand bit[31:0] Haddr;
	rand bit[31:0] Hwdata;
	rand bit[2:0] Hsize;
	rand bit[2:0]Hburst;
	rand bit[9:0]Hlength;
	rand bit Hwrite;

	bit Hresetn;
	bit Hready_in;
	bit Hready_out;
	bit [31:0] Hrdata;
	bit [1:0] Hresp;
	
//========================  Each range is declared 1kb memory so, total 4 1kb memories are there  ====================//
	constraint c1{soft Haddr inside{[32'h8000_0000 : 32'h8000_03ff],
				   [32'h8400_0000 : 32'h8400_03ff],
				   [32'h8800_0000 : 32'h8800_03ff],
				   [32'h8c00_0000 : 32'h8c00_03ff]};}

//========================== valid_size ==================//
	constraint valid_size{Hsize inside{0,1,2};}


//=================================== aligned addr base on Hsize ==============================//
	constraint aligned_addr{Hsize==2'b01 -> Haddr%2==0;
				Hsize==2'b10 -> Haddr%4==0;}


	constraint valid_length1{Haddr%1024+ (Hlength*(2**Hsize))<= 1024;}


//=================================== based on Hburst generate Hlegth =======================//
	constraint valid_length2{Hburst==3'b000 -> Hlength==1;
				Hburst==3'b010 -> Hlength==4;
				Hburst==3'b011 -> Hlength==4;
				Hburst==3'b100 -> Hlength==8;
				Hburst==3'b101 -> Hlength==8;
				Hburst==3'b110 -> Hlength==16;
				Hburst==3'b111 -> Hlength==16;}

	extern function new(string name="ahb_xtn");
	extern function void do_print(uvm_printer printer); 

endclass

function ahb_xtn::new(string name="ahb_xtn");
	super.new(name);
endfunction



function void ahb_xtn::do_print(uvm_printer printer);
	super.do_print(printer);

//                   srting name   		bitstream value     	size    radix for printing
    printer.print_field( "Haddr", 		this.Haddr, 	    	32,	UVM_HEX);
    printer.print_field( "Hwdata",		this.Hwdata,  		32,	UVM_DEC);
    printer.print_field( "Hresetn",		this.Hresetn,		1,	UVM_DEC);
    printer.print_field( "Htrans",		this.Htrans,		2,	UVM_DEC);
    printer.print_field( "Hsize",		this.Hsize,		3,	UVM_DEC);
    printer.print_field( "Hburst",		this.Hburst,		3,	UVM_DEC);
    printer.print_field( "Hresp",		this.Hresp,		2,	UVM_DEC);
    printer.print_field( "Hlength",		this.Hlength,		10,	UVM_DEC);
    printer.print_field( "Hrdata",		this.Hrdata,		32,	UVM_DEC);
    printer.print_field( "Hwrite",		this.Hwrite,		1,	UVM_DEC);

endfunction
