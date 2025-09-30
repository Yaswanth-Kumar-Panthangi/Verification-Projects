class sb extends uvm_scoreboard;
`uvm_component_utils(sb)
ahb_xtn ahb_h;
apb_xtn apb_h;
uvm_tlm_analysis_fifo #(ahb_xtn) ahb_fifo[];
uvm_tlm_analysis_fifo#(apb_xtn) apb_fifo[];
env_config m_cfg;

function new(string name="scoreboard",uvm_component parent);
super.new(name,parent); 
ahb=new();
apb=new();
endfunction

virtual function void build_phase(uvm_phase phase);
if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
`uvm_fatal(get_type_name(),"getting is failed")
ahb_fifo=new[m_cfg.no_of_master_agents];
apb_fifo=new[m_cfg.no_of_slave_agents];

       ahb_h = ahb_xtn::type_id::create("ahb_h");
       apb_h = apb_xtn::type_id::create("apb_h");

       foreach(ahb_fifo[i])
           ahb_fifo[i] = new($sformatf("ahb_fifo[%0d]", i), this);
       foreach(ahb_fifo[i])
           apb_fifo[i] = new($sformatf("apb_fifo[%0d]", i), this);

endfunction

covergroup ahb;
HADDR:coverpoint ahb_h.Haddr{
	bins slave1={[32'h8000_0000:32'h8000_03ff]};
	bins slave2={[32'h8400_0000:32'h8400_03ff]};
	bins slave3={[32'h8800_0000:32'h8800_03ff]};
	bins slave4={[32'h8c00_0000:32'h8c00_03ff]};
		}
HSIZE:coverpoint ahb_h.Hsize{
	bins one_byte={0};
	bins two_byte={1};
	bins four_byte={2};
  		}
HWRITE:coverpoint ahb_h.Hwrite{
	bins write0={0};
	bins write1={1};
	  	}
HTRANS:coverpoint ahb_h.Htrans{
	bins nseq={2};
	bins seq={3};
  		}

AHP:cross HADDR,HSIZE,HWRITE,HTRANS;

endgroup


covergroup apb;
PSELX:coverpoint apb_h.Psel{
	bins one={1};
	bins two={2};
	bins four={4};
	bins eight={8};
		}
PWRITE:coverpoint apb_h.Pwrite{
	bins writep0={0};
	bins writep1={1};
	  	}
PADDR:coverpoint apb_h.Paddr{
	bins mastre1={[32'h8000_0000:32'h8000_03ff]};
	bins master2={[32'h8400_0000:32'h8400_03ff]};
	bins master3={[32'h8800_0000:32'h8800_03ff]};
	bins master4={[32'h8c00_0000:32'h8c00_03ff]};
		}

APB:cross PSELX,PWRITE,PADDR;

endgroup

virtual task run_phase(uvm_phase phase);
forever
begin
	fork
		begin
			ahb_fifo[0].get(ahb_h);
			$display("from ahb scorboard$$$$$$$$$$$$$$$$$$$$$$");

			ahb_h.print();
			ahb.sample();
		end

		begin
			apb_fifo[0].get(apb_h);
			$display("from scorboard$$$$$$$$$$$$$$$$$$$$$$");
			apb_h.print();
			apb.sample();
		end
	join
chec(ahb_h,apb_h);
end
endtask


task compar(int Haddr,Paddr,Hdata,Pdata);

if(Haddr==Paddr)
	$display("addr is matched");
else 
	begin
	$display("addr is not matched");
//	$display("Haddr,Paddr");
	end
if(Hdata==Pdata)
	$display("data is matched");
else 
	begin
	$display("data is not matched");
//	$display("Hdata,Pdata");
	end

endtask
task chec(ahb_xtn ahb_h,apb_xtn apb_h);
	if(ahb_h.Hwrite==1)
		begin
			if(ahb_h.Hsize==2'b00)
			begin
			if(ahb_h.Haddr[1:0]==2'b00)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hwdata[7:0],apb_h.Pwdata[7:0]);
			if(ahb_h.Haddr[1:0]==2'b01)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hwdata[15:8],apb_h.Pwdata[15:8]);
			if(ahb_h.Haddr[1:0]==2'b10)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hwdata[23:16],apb_h.Pwdata[23:16]);
			if(ahb_h.Haddr[1:0]==2'b11)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hwdata[31:24],apb_h.Pwdata[31:24]);
		end
	if(ahb_h.Hsize==2'b01)
		begin
			if(ahb_h.Haddr[1:0]==2'b00)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hwdata[15:0],apb_h.Pwdata[15:0]);
			if(ahb_h.Haddr[1:0]==2'b10)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hwdata[31:16],apb_h.Pwdata[31:16]);
		end
	if(ahb_h.Hsize==2'b10)
		begin
			if(ahb_h.Haddr[1:0]==2'b10)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hwdata[31:0],apb_h.Pwdata[31:0]);
		end
end

if(ahb_h.Hwrite==0)
		begin
			if(ahb_h.Hsize==2'b00)
			begin
			if(ahb_h.Haddr[1:0]==2'b00)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hrdata[7:0],apb_h.Prdata[7:0]);
			if(ahb_h.Haddr[1:0]==2'b01)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hrdata[15:8],apb_h.Prdata[15:8]);
			if(ahb_h.Haddr[1:0]==2'b10)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hrdata[23:16],apb_h.Prdata[23:16]);
			if(ahb_h.Haddr[1:0]==2'b11)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hrdata[31:24],apb_h.Prdata[31:24]);
		end
	if(ahb_h.Hsize==2'b01)
		begin
			if(ahb_h.Haddr[1:0]==2'b00)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hrdata[15:0],apb_h.Prdata[15:0]);
			if(ahb_h.Haddr[1:0]==2'b10)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hrdata[31:16],apb_h.Prdata[31:16]);
		end
	if(ahb_h.Hsize==2'b10)
		begin
			if(ahb_h.Haddr[1:0]==2'b10)
			compar(ahb_h.Haddr,apb_h.Paddr,ahb_h.Hrdata[31:0],apb_h.Prdata[31:0]);
		end
end

endtask
endclass










/*class sb extends uvm_scoreboard;
	`uvm_component_utils(sb)
	
	uvm_tlm_analysis_fifo #(src_xtn) af_m;
	uvm_tlm_analysis_fifo #(apb_xtn) af_s;
	
	src_xtn ahb_h;
	apb_xtn apb_h;
	
	src_xtn ahb_cov_data;
	apb_xtn apb_cov_data;


	extern function new(string name="scoreboard", uvm_component parent);
	extern task run_phase(uvm_phase phase);
	extern task check_data(src_xtn ahb_h, apb_xtn apb_h);
	extern task compare_ahb_data(int unsigned Hwdata, Pwdata, Haddr, Paddr);
	extern task compare_apb_data(int unsigned Hrdata, Prdata, Haddr, Paddr);

	



	
	covergroup ahb_cg;
		option.per_instance = 1;

		HTRANS   : coverpoint ahb_cov_data.Htrans {bins htrans[] = {[2:3]};}

		HSIZE    : coverpoint ahb_cov_data.Hsize  {bins hsize[] = {[0:2]};}

		HBURST   : coverpoint ahb_cov_data.Hburst {bins hburst[] = {[0:7]};}

		HADDR    : coverpoint ahb_cov_data.Haddr  {bins first_slave  = {[32'h8000_0000 : 32'h8000_03ff]};
						           bins second_slave = {[32'h8400_0000 : 32'h8400_03ff]};
							   bins third_slave  = {[32'h8800_0000 : 32'h8800_03ff]};
							   bins fourth_slave = {[32'h8c00_0000 : 32'h8c00_03ff]};}
													
		HWRITE   : coverpoint ahb_cov_data.Hwrite;
			
	//	DATA_IN  : coverpoint ahb_cov_data.Hwdata

	//	DATA_OUT :

		
	endgroup



//=================================================================FUNCTIONAL COVERAGE APB SIDE==============================================================//

	covergroup apb_cg;
	
		option.per_instance=1;

		PADDR    : coverpoint apb_cov_data.Paddr  {bins first_slave  = {[32'h8000_0000 : 32'h8000_03ff]};
						           bins second_slave = {[32'h8400_0000 : 32'h8400_03ff]};
							   bins third_slave  = {[32'h8800_0000 : 32'h8800_03ff]};
							   bins fourth_slave = {[32'h8c00_0000 : 32'h8c00_03ff]};}
																
		PWRITE   : coverpoint apb_cov_data.Pwrite;

		PSEL     : coverpoint apb_cov_data.Psel   {bins first_slave   = {4'b0001};
							   bins second_slave  = {4'b0010};
							   bins third_slave   = {4'b0100};
							   bins fourth_slave  = {4'b1000};}

	
	endgroup
		
	
endclass

	


//=================================================================FUNCTIONAL COVERAGE AHB SIDE==============================================================//


	function scoreboard::new(string name="scoreboard", uvm_component parent);
		super.new(name,parent);
		
		af_m = new("src_xtn",this);
		af_s = new("apb_xtn",this);
		ahb_cg = new();
		apb_cg = new();

	endfunction



	task scoreboard::run_phase(uvm_phase phase);
		forever 
			begin
				fork

					begin
						
						af_m.get(ahb_h);	
					//	`uvm_info("SCOREBOARD",$sformatf("src_xtn data getting from tlm fifo \n %s", ahb_h.sprint()),UVM_LOW)
						ahb_cov_data = ahb_h;
						ahb_cg.sample();
					end

					begin
						af_s.get(apb_h);
					//	`uvm_info("SCOREBOARD",$sformatf("apb_xtn data getting from tlm fifo \n %s", apb_h.sprint()),UVM_LOW)
						apb_cov_data = apb_h;
						apb_cg.sample();
					end


				join
		check_data(ahb_h, apb_h);

			end
	endtask





//=====================================================CHECK DATA TASK========================================================================//
	task scoreboard::check_data(src_xtn ahb_h, apb_xtn apb_h);
		
		if(ahb_h.Hwrite)
			begin
				case(ahb_h.Hsize)
				
				2'b00 : begin
						 if(ahb_h.Haddr[1:0] == 2'b00)
							compare_ahb_data(ahb_h.Hwdata[7:0], apb_h.Pwdata, ahb_h.Haddr, apb_h.Paddr);
					
						 else if(ahb_h.Haddr[1:0] == 2'b01)
							compare_ahb_data(ahb_h.Hwdata[15:8], apb_h.Pwdata, ahb_h.Haddr, apb_h.Paddr);
						
						 else if(ahb_h.Haddr[1:0] == 2'b10)
							compare_ahb_data(ahb_h.Hwdata[23:16], apb_h.Pwdata, ahb_h.Haddr, apb_h.Paddr);
	
						 else
							compare_ahb_data(ahb_h.Hwdata[31:24], apb_h.Pwdata, ahb_h.Haddr, apb_h.Paddr);

					end
			
				2'b01: begin
						if(ahb_h.Haddr[1:0] == 2'b00)
							compare_ahb_data(ahb_h.Hwdata[15:0], apb_h.Pwdata, ahb_h.Haddr, apb_h.Paddr);
						else
							compare_ahb_data(ahb_h.Hwdata[31:16], apb_h.Pwdata, ahb_h.Haddr, apb_h.Paddr);
					
					end


				2'b10 : begin
						compare_ahb_data(ahb_h.Hwdata, apb_h.Pwdata, ahb_h.Haddr, apb_h.Paddr);
					end
				
				endcase

			end

		else
			begin
				case(ahb_h.Hsize)
				
				2'b00 : begin
						 if(ahb_h.Haddr[1:0] == 2'b00)
							compare_apb_data(ahb_h.Hrdata[7:0], apb_h.Prdata[7:0], ahb_h.Haddr, apb_h.Paddr);
					
						 else if(ahb_h.Haddr[1:0] == 2'b01)
							compare_apb_data(ahb_h.Hrdata[15:8], apb_h.Prdata[15:8], ahb_h.Haddr, apb_h.Paddr);
						
						 else if(ahb_h.Haddr[1:0] == 2'b10)
							compare_apb_data(ahb_h.Hrdata[23:16], apb_h.Prdata[23:16], ahb_h.Haddr, apb_h.Paddr);
	
						 else
							compare_apb_data(ahb_h.Hrdata[31:24], apb_h.Prdata[31:24], ahb_h.Haddr, apb_h.Paddr);

					end
			
				2'b01: begin
						if(ahb_h.Haddr[1:0] == 2'b00)
							compare_apb_data(ahb_h.Hrdata[15:0], apb_h.Prdata[15:0], ahb_h.Haddr, apb_h.Paddr);
						else
							compare_apb_data(ahb_h.Hrdata[31:16], apb_h.Prdata[31:16], ahb_h.Haddr, apb_h.Paddr);
					
					end


				2'b10 : begin
						compare_apb_data(ahb_h.Hrdata, apb_h.Prdata, ahb_h.Haddr, apb_h.Paddr);
					end
				
				endcase

			end
	
	endtask



//======================================================COMPARE AHB DATA TASK============================================================================//
	task scoreboard::compare_ahb_data(int unsigned Hwdata, Pwdata, Haddr, Paddr);
	src_xtn h;
//	if(h.Hwrite==1)
		begin
			if(Haddr==Paddr) begin
				$display("ADDRESS COMPARED SUCESSFULLY");
				$display("Haddr = %0d, Paddr = %0d",Haddr, Paddr);
			
			end

			else
				begin	
				$display("ADDRESS MISMATCHED");
				$display("Haddr = %0d, Paddr = %0d",Haddr, Paddr);
		
				end
	
			if(Hwdata==Pwdata) begin
				$display("DATA COMPARED SUCESSFULLY");
				$display("Hwdata = %0d, Pwdata = %0d",Hwdata, Pwdata);
		
			end

			else
			begin	
				$display("DATA MISMATCH");
				$display("Hwdata = %0d, Pwdata = %0d",Hwdata, Pwdata);
			end
		end
	endtask




//======================================================COMPARE APB DATA TASK============================================================================//

	task scoreboard::compare_apb_data(int unsigned Hrdata, Prdata, Haddr, Paddr);
	src_xtn t;
//	if(t.Hwrite==0)

		begin
			if(Haddr==Paddr) begin
				$display("ADDRESS COMPARED SUCESSFULLY");
				$display("Haddr = %0d, Paddr = %0d",Haddr, Paddr);
			
			end

			else
				begin	
				$display("ADDRESS MISMATCHED");
				$display("Haddr = %0d, Paddr = %0d",Haddr, Paddr);
		
				end
	
			if(Hrdata==Prdata) begin
				$display("DATA COMPARED SUCESSFULLY");
				$display("Hrdata = %0d, Prdata = %0d",Hrdata, Prdata);
		
			end

			else
			begin	
				$display("DATA MISMATCHD");
				$display("Hrdata = %0d, Prdata = %0d",Hrdata, Prdata);
			end
		end

		
	endtask*/

		

