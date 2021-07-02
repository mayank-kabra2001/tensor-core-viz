\m4_TLV_version 1d: tl-x.org
\SV

   m4_define(['M4_VECTOR_REG'], 4)
   m4_define(['M4_BANK_SIZE'], 4)
   m4_define(['M4_MEM_SIZE'], 8)
	m4_define(['M4_NO_OF_PORTS'], 2)

   //m4_sv_get_url(['https://raw.githubusercontent.com/mayank-kabra2001/tensor-core-viz-/main/tc_sram.sv'])
                  // Copyright (c) 2020 ETH Zurich and University of Bologna.
   // Copyright and related rights are licensed under the Solderpad Hardware
   // License, Version 0.51 (the "License"); you may not use this file except in
   // compliance with the License.  You may obtain a copy of the License at
   // http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
   // or agreed to in writing, software, hardware and materials distributed under
   // this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   // CONDITIONS OF ANY KIND, either express or implied. See the License for the
   // specific language governing permissions and limitations under the License.

   // Author: Wolfgang Roenninger <wroennin@ethz.ch>

   // Description: Functional module of a generic SRAM
   //
   // Parameters:
   // - NumWords:    Number of words in the macro. Address width can be calculated with:
   //                `AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1`
   //                The module issues a warning if there is a request on an address which is
   //                not in range.
   // - DataWidth:   Width of the ports `wdata_i` and `rdata_o`.
   // - ByteWidth:   Width of a byte, the byte enable signal `be_i` can be calculated with the
   //                ceiling division `ceil(DataWidth, ByteWidth)`.
   // - NumPorts:    Number of read and write ports. Each is a full port. Ports with a higher
   //                index read and write after the ones with lower indices.
   // - Latency:     Read latency, the read data is available this many cycles after a request.
   // - SimInit:     Macro simulation initialization. Values are:
   //                "zeros":  Each bit gets initialized with 1'b0.
   //                "ones":   Each bit gets initialized with 1'b1.
   //                "random": Each bit gets random initialized with 1'b0 or 1'b1.
   //                "none":   Each bit gets initialized with 1'bx. (default)
   // - PrintSimCfg: Prints at the beginning of the simulation a `Hello` message with
   //                the instantiated parameters and signal widths.
   //
   // Ports:
   // - `clk_i`:   Clock
   // - `rst_ni`:  Asynchronous reset, active low
   // - `req_i`:   Request, active high
   // - `we_i`:    Write request, active high
   // - `addr_i`:  Request address
   // - `wdata_i`: Write data, has to be valid on request
   // - `be_i`:    Byte enable, active high
   // - `rdata_o`: Read data, valid `Latency` cycles after a request with `we_i` low.
   //
   // Behaviour:
   // - Address collision:  When Ports are making a write access onto the same address,
   //                       the write operation will start at the port with the lowest address
   //                       index, each port will overwrite the changes made by the previous ports
   //                       according how the respective `be_i` signal is set.
   // - Read data on write: This implementation will not produce a read data output on the signal
   //                       `rdata_o` when `req_i` and `we_i` are asserted. The output data is stable
   //                       on write requests.

   module tc_sram #(
     parameter int NumWords     = 32'd128, // Number of Words in data array
     parameter int DataWidth    = 32'd32,  // Data signal width
     parameter int ByteWidth    = 32'd8,    // Width of a data byte
     parameter int NumPorts     = 32'd2,    // Number of read and write ports
     parameter int Latency      = 32'd1,    // Latency when the read data is available
     //parameter              SimInit      = "none",   // Simulation initialization
     parameter bit          PrintSimCfg  = 1'b0,     // Print configuration
     // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
     parameter int AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
     parameter int BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth, // ceil_div
     parameter type         addr_t    = logic [AddrWidth-1:0],
     parameter type         data_t    = logic [DataWidth-1:0],
     parameter type         be_t      = logic [BeWidth-1:0]
   ) (
     input  logic                 clk_i,      // Clock
     input  logic                 rst_ni,     // Asynchronous reset active low
     // input ports
     input  logic  [NumPorts-1:0] req_i,      // request
     input  logic  [NumPorts-1:0] we_i,       // write enable
     input  addr_t [NumPorts-1:0] addr_i,     // request address
     input  data_t [NumPorts-1:0] wdata_i,    // write data
     input  be_t   [NumPorts-1:0] be_i,       // write byte enable
     // output ports
     output data_t [NumPorts-1:0] rdata_o     // read data
   );

     // memory array
     data_t sram [NumWords-1:0];
     // hold the read address when no read access is made
     addr_t [NumPorts-1:0] r_addr_q;

     // SRAM simulation initialization
     data_t [NumWords-1:0] init_val;
     initial begin : proc_sram_init
       for (int i = 0; i < NumWords; i++) begin
         for (int j = 0; j < DataWidth; j++) begin
           init_val[i][j] = 1'bx;
         end
       end
     end

     // set the read output if requested
     // The read data at the highest array index is set combinational.
     // It gets then delayed for a number of cycles until it gets available at the output at
     // array index 0.
	genvar i ; 
   //int k ; 
     // read data output assignment
     data_t [NumPorts-1:0][Latency-1:0] rdata_q,  rdata_d;
     if (Latency == 32'd0) begin : gen_no_read_lat
       for (i = 0; i < NumPorts; i++) begin : gen_port
         assign rdata_o[i] = (req_i[i] && !we_i[i]) ? sram[addr_i[i]] : sram[r_addr_q[i]];
       end
     end else begin : gen_read_lat

       always_comb begin
         for (int i = 0; i < NumPorts; i++) begin
           rdata_o[i] = rdata_q[i][0];
           for (int j = 0; j < (Latency-1); j++) begin
             rdata_d[i][j] = rdata_q[i][j+1];
           end
           rdata_d[i][Latency-1] = (req_i[i] && !we_i[i]) ? sram[addr_i[i]] : sram[r_addr_q[i]];
         end
       end
     end

     // write memory array
     always_ff @(posedge clk_i or negedge rst_ni) begin
       if (!rst_ni) begin
         for (int i = 0; i < NumWords; i++) begin
           sram[i] = init_val[i];
         end
         for (int i = 0; i < NumPorts; i++) begin
           r_addr_q[i] <= {AddrWidth{1'b0}};
           // initialize the read output register for each port
           if (Latency != 32'd0) begin
             for (int j = 0; j < Latency; j++) begin
               rdata_q[i][j] <= init_val[{AddrWidth{1'b0}}];
             end
           end
         end
       end else begin
         // read value latch happens before new data is written to the sram
         for (int i = 0; i < NumPorts; i++) begin
           if (Latency != 0) begin
             for (int j = 0; j < Latency; j++) begin
               rdata_q[i][j] <= rdata_d[i][j];
             end
           end
         end
         // there is a request for the SRAM, latch the required register
         for (int i = 0; i < NumPorts; i++) begin
           if (req_i[i]) begin
             if (we_i[i]) begin
               // update value when write is set at clock
               for (int j = 0; j < DataWidth; j++) begin
                 if (be_i[i][j/ByteWidth]) begin
                   sram[addr_i[i]][j] <= wdata_i[i][j];
                 end
               end
             end else begin
               // otherwise update read address for subsequent non request cycles
               r_addr_q[i] <= addr_i[i];
             end
           end // if req_i
         end // for ports
       end // if !rst_ni
     end

   // Validate parameters.
   // pragma translate_off
   `ifndef VERILATOR
   `ifndef TARGET_SYNTHESYS
     initial begin: p_assertions
       assert ($bits(addr_i)  == NumPorts * AddrWidth) else $fatal(1, "AddrWidth problem on `addr_i`");
       assert ($bits(wdata_i) == NumPorts * DataWidth) else $fatal(1, "DataWidth problem on `wdata_i`");
       assert ($bits(be_i)    == NumPorts * BeWidth)   else $fatal(1, "BeWidth   problem on `be_i`"   );
       assert ($bits(rdata_o) == NumPorts * DataWidth) else $fatal(1, "DataWidth problem on `rdata_o`");
       assert (NumWords  >= 32'd1) else $fatal(1, "NumWords has to be > 0");
       assert (DataWidth >= 32'd1) else $fatal(1, "DataWidth has to be > 0");
       assert (ByteWidth >= 32'd1) else $fatal(1, "ByteWidth has to be > 0");
       assert (NumPorts  >= 32'd1) else $fatal(1, "The number of ports must be at least 1!");
     end
     initial begin: p_sim_hello
       if (PrintSimCfg) begin
         $display("#################################################################################");
         $display("tc_sram functional instantiated with the configuration:"                          );
         $display("Instance: %m"                                                                     );
         $display("Number of ports   (dec): %0d", NumPorts                                           );
         $display("Number of words   (dec): %0d", NumWords                                           );
         $display("Address width     (dec): %0d", AddrWidth                                          );
         $display("Data width        (dec): %0d", DataWidth                                          );
         $display("Byte width        (dec): %0d", ByteWidth                                          );
         $display("Byte enable width (dec): %0d", BeWidth                                            );
         $display("Latency Cycles    (dec): %0d", Latency                                            );
         $display("Simulation init   (str): %0s", SimInit                                            );
         $display("#################################################################################");
       end
     end
     for (i = 0; i < NumPorts; i++) begin : gen_assertions
       assert property ( @(posedge clk_i) disable iff (!rst_ni)
           (req_i[i] |-> (addr_i[i] < NumWords))) else
         $warning("Request address %0h not mapped, port %0d, expect random write or read behavior!",
             addr_i[i], i);
     end

   `endif
   `endif
   // pragma translate_on
   endmodule
   //////////////////////////////////////////////////////////////////////////
   module sram_tb #(
     parameter int NumWords     = 32'd128, // Number of Words in data array
     parameter int DataWidth    = 32'd32,  // Data signal width
     parameter int ByteWidth    = 32'd8,    // Width of a data byte
     parameter int NumPorts     = 32'd2,    // Number of read and write ports
     parameter int Latency      = 32'd1,    // Latency when the read data is available
     parameter bit          PrintSimCfg  = 1'b0,     // Print configuration
     // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
     parameter int AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
     parameter int BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth, // ceil_div
     parameter type         addr_t    = logic [AddrWidth-1:0] ,
     parameter type         data_t    = logic [DataWidth-1:0],
     parameter type         be_t      = logic [BeWidth-1:0]
   ) (); 
     logic clk_i ;       // Clock
     logic rst_ni ;      // Asynchronous reset active low
     // input ports
     logic  [NumPorts-1:0] req_i ;       // request
     logic  [NumPorts-1:0] we_i ;        // write enable
     addr_t [NumPorts-1:0] addr_i ;      // request address
     data_t [NumPorts-1:0] wdata_i ;    // write data
     be_t   [NumPorts-1:0] be_i ;       // write byte enable
     // output ports
     data_t [NumPorts-1:0] rdata_o ;      // read data
      
     tc_sram dut(.clk_i(clk_i) , .rst_ni(rst_ni) , .req_i(req_i) , .we_i(we_i) , .addr_i(addr_i) , .wdata_i(wdata_i) , .be_i(be_i) , .rdata_o(rdata_o)) ;   
   endmodule
                  
   /////////////////////////////////////////////////////////////////////////               
                  
   // =========================================
   // Welcome!  Try the tutorials via the menu.
   // =========================================

   // Default Makerchip TL-Verilog Code Template
   
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   sram_tb sram_tb() ; 
                  
\TLV
   $reset = *reset;
   //...
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   /main 
      \viz_alpha 
            initEach: function() {
                  let memory = new fabric.Text("SRAM MEMORY (HEX)", {
                     top: -150,
                     left: 650,
                     fontSize: 40,
                     fontFamily: "monospace"
                  })
                  let sram_box = new fabric.Rect({
                     top: -200  ,
                     left: 300,
                     fill: "lightblue",
                     width: 50 + 250 * M4_BANK_SIZE,
                     height: (250 + 14 * M4_MEM_SIZE) * M4_VECTOR_REG ,
                     stroke: "black" 
                  })
                  
                  let rdata_o_arrow = new fabric.Line([350 + 250 * M4_BANK_SIZE , 200 , 550 + 250 * M4_BANK_SIZE, 200], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let rdata_o_val = new fabric.Text("rdata_o", {
                     top: 180,
                     left: 380 + 250 * M4_BANK_SIZE,
                     fontSize: 16,
                     fontFamily: "monospace"
                  })
                  let addr_i_arrow = new fabric.Line([100 , 120 , 300 , 120], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let addr_i_val = new fabric.Text("addr_i", {
                     top: 100,
                     left: 10,
                     fontSize: 16,
                     fontFamily: "monospace"
                  })
                  
                  let req_i_arrow = new fabric.Line([100 , 250 , 300 , 250], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let req_i_val = new fabric.Text("req_i", {
                     top: 230,
                     left: 10,
                     fontSize: 16,
                     fontFamily: "monospace"
                  })
                  
                  let we_i_arrow = new fabric.Line([100 , 380 , 300 , 380], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let we_i_val = new fabric.Text("we_i", {
                     top: 360,
                     left: 10,
                     fontSize: 16,
                     fontFamily: "monospace"
                  })
                  
                  let wdata_i_arrow = new fabric.Line([100 , 560 , 300 , 560], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let wdata_i_val = new fabric.Text("wdata_i", {
                     top: 540,
                     left: 10,
                     fontSize: 16,
                     fontFamily: "monospace"
                  })
                  
                  let be_i_arrow = new fabric.Line([100 , 740 , 300 , 740], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let be_i_val = new fabric.Text("be_i", {
                     top: 720,
                     left: 10,
                     fontSize: 16,
                     fontFamily: "monospace"
                  })
                  
                  return{objects: {sram_box, memory ,rdata_o_arrow, rdata_o_val, addr_i_arrow, addr_i_val, req_i_arrow, req_i_val, we_i_arrow, we_i_val, wdata_i_arrow, wdata_i_val, be_i_arrow, be_i_val}}; 
               },
            renderEach: function(){
               
            }
   
   /ports[m4_eval(M4_NO_OF_PORTS - 1) : 0]
      \viz_alpha 
         initEach: function() { 
            let addr_i_box = new fabric.Rect({
                  top: 90 + 25 * this.getIndex(),
                  left: 330,
                  fill: "white",
                  width: 100,
                  height: 14,
                  stroke: "black"
               })
            let addr_i_data = new fabric.Text("x", {
                  top: 90 + 25 * this.getIndex() ,
                  left: 340,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               
            let req_i_box = new fabric.Rect({
                  top: 230 + 25 * this.getIndex(),
                  left: 330,
                  fill: "white",
                  width: 100,
                  height: 14,
                  stroke: "black"
               })
            let req_i_data = new fabric.Text("x", {
                  top: 230 + 25 * this.getIndex() ,
                  left: 340,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
            let we_i_box = new fabric.Rect({
                  top: 360 + 25 * this.getIndex(),
                  left: 330,
                  fill: "white",
                  width: 100,
                  height: 14,
                  stroke: "black"
               })
            let we_i_data = new fabric.Text("x", {
                  top: 360 + 25 * this.getIndex() ,
                  left: 340,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
            let wdata_i_box = new fabric.Rect({
                  top: 540 + 25 * this.getIndex(),
                  left: 330,
                  fill: "white",
                  width: 100,
                  height: 14,
                  stroke: "black"
               })
            let wdata_i_data = new fabric.Text("x", {
                  top: 540 + 25 * this.getIndex() ,
                  left: 340,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
            let be_i_box = new fabric.Rect({
                  top: 720 + 25 * this.getIndex(),
                  left: 330,
                  fill: "white",
                  width: 100,
                  height: 14,
                  stroke: "black"
               })
            let be_i_data = new fabric.Text("x", {
                  top: 720 + 25 * this.getIndex() ,
                  left: 340,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
            let rdata_o_box = new fabric.Rect({
                  top: 180 + 25 * this.getIndex(),
                  left: 1200,
                  fill: "white",
                  width: 100,
                  height: 14,
                  stroke: "black"
               })
            let rdata_o_data = new fabric.Text("x", {
                  top: 180 + 25 * this.getIndex() ,
                  left: 1210,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
           return{objects : {addr_i_box, addr_i_data, req_i_box, req_i_data, we_i_box, we_i_data, wdata_i_box, wdata_i_data, be_i_box, be_i_data, rdata_o_box, rdata_o_data}};
         },
         renderEach: function(){ 
            let vrf_val = this.getScope().index; 
            let addr_i = this.svSigRef(`sram_tb.dut.addr_i[vrf]`).asInt().toString(16) ;
            let wdata_i = this.svSigRef(`sram_tb.dut.wdata_i[vrf]`).asInt().toString(16) ;
            let we_i = this.svSigRef(`sram_tb.dut.we_i[vrf]`).asBool(false) ;
            let req_i = this.svSigRef(`sram_tb.dut.req_i[vrf]`).asBool(false) ;
            let be_i = this.svSigRef(`sram_tb.dut.be_i[vrf]`).asInt().toString(16) ;
            let sram_val = this.svSigRef(`sram_tb.dut.sram[addr_i][vrf]`).asBool(false) ;
            let rdata_o = this.svSigRef(`sram_tb.dut.rdata_o[vrf]`).asInt().toString(16) ;
            
            this.getInitObject("addr_i_data").setText(this.getIndex + ":" + addr_i);
            this.getInitObject("wdata_i_data").setText(this.getIndex + ":" + wdata_i);
            this.getInitObject("we_i_data").setText(this.getIndex + ":" + we_i);
            this.getInitObject("be_i_data").setText(this.getIndex + ":" + be_i);
            this.getInitObject("req_i_data").setText(this.getIndex + ":" + req_i);
            this.getInitObject("rdata_o_data").setText(this.getIndex + ":" + rdata_o);
            var mod1 = (!we_i && req_i) ; 
            if(mod1) { 
               this.getInitObject("rdata_o_data").setText(mod1 ? this.getScope().index + ":" + rdata_o  : this.getScope().index + ":" + "x");
            }
            var mod2 = (we_i && req_i) ; 
            if(mod2) { 
               this.getInitObject("wdata_i_data").setText(mod2 ? this.getScope().index + ":" + wdata_i : this.getScope().index + ":" + "x");
            }
         }
      
   /vector_register_file[m4_eval(M4_VECTOR_REG-1) : 0]
      /imp_val 
         \viz_alpha 
            initEach: function() {
                  let regname = new fabric.Text("VECTOR REGISTER " + this.getScope("vector_register_file").index.toString(), {
                     top: -50 + (this.getScope("vector_register_file").index) * 320,
                     left: 700,
                     fontSize: 23,
                     fontFamily: "monospace"
                  })
                  
                  let r_addr_q_val = new fabric.Text("r_addr_q_val_" + this.getScope("vector_register_file").index.toString(), {
                     top: 118 + (this.getScope("vector_register_file").index) * 320 + 14 * M4_MEM_SIZE ,
                     left: 540,
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  let sram_val = new fabric.Text("sram_addr_val_" + this.getScope("vector_register_file").index.toString(), {
                     top: 118 + (this.getScope("vector_register_file").index) * 320 + 14 * M4_MEM_SIZE ,
                     left: 900,
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  
                  let bank_box = new fabric.Rect({
                     top: -60 + (this.getScope("vector_register_file").index) * 320 ,
                     left: 530,
                     fill: "#208028",
                     width: 148 * M4_BANK_SIZE,
                     height: 163 + 14 * M4_MEM_SIZE,
                     stroke: "black", 
                     visible: false 
                  })
               return {objects: {r_addr_q_val, sram_val, bank_box, regname}};
            },
            renderEach: function() {
               let vrf_val = this.getScope("vector_register_file").index; 
               let sram_val = this.svSigRef(`sram_tb.dut.sram[addr_i][vrf]`).asBool(false) ;
               let r_addr_q = this.svSigRef(`sram_tb.dut.r_addr_q[vrf]`).asInt().toString(16) ;
               this.getInitObject("r_addr_q_val").setText("r_addr_q[" + this.getScope("vector_register_file").index.toString() + "] : " + r_addr_q);
               this.getInitObject("sram_val").setText("sram[addr_i]_val[" + this.getScope("vector_register_file").index.toString() + "] : " + sram_val.prevCycle().padStart(8,"0") + "->" + sram_val.padStart(8,"0"));
               this.getInitObject("bank_box").setVisible(true);
            }
            
      /bank_size[m4_eval(M4_BANK_SIZE-1):0]
         \viz_alpha 
            initEach: function(){
               let bankname = new fabric.Text("bank", {
                  top: 0 + (this.getScope("vector_register_file").index) * 320 ,
                  left: 545,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               let banknum = new fabric.Text(String(this.getScope("bank_size").index), {
                  top: 0 + (this.getScope("vector_register_file").index) * 320 ,
                  left: 122 * M4_BANK_SIZE + (4 - this.getScope("bank_size").index) * 120 + 60,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               return{objects: {bankname, banknum}}; 
            },
         
         
         /mem_size[m4_eval(M4_MEM_SIZE-1):0] 
            \viz_alpha
               initEach: function() {
                  let index_val_box = new fabric.Rect({
                     top: 30 + 18 * this.getIndex() + (this.getScope("vector_register_file").index) * 320,
                     left:  540,
                     fill: "white",
                     width: 40,
                     height: 14,
                     stroke: "black",
                     visible: false
                  })
                  let bank_val_box = new fabric.Rect({
                     top: 3.75 * M4_MEM_SIZE + 18 * this.getIndex() + (this.getScope("vector_register_file").index) * 320,
                     left: 125 * M4_BANK_SIZE + (4 - this.getScope("bank_size").index) * 120 + 10,
                     fill: "white",
                     width: 100,
                     height: 14,
                     stroke: "black",
                     visible: false
                  })
                  
                  let data = new fabric.Text("00000000", {
                     top: 3.75 * M4_MEM_SIZE + 18 * this.getIndex() + (this.getScope("vector_register_file").index) * 320,
                     left: 128 * M4_BANK_SIZE + (4 - this.getScope("bank_size").index) * 120 + 10, // bank: 3 2 1 0 format
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  //let index = (this.getScope("bank").index != 0) ? null : // resulting in "Cannot read property 'setupState' of null" error
                  let index =
                     new fabric.Text("", {
                        top: 30 + 18 * this.getIndex() + (this.getScope("vector_register_file").index) * 320,
                        left: 550,
                        fontSize: 14,
                        fontFamily: "monospace"
                     })
                     
                  return {objects: {index_val_box, bank_val_box, data, index}};
               },
               renderEach: function() {
                  //console.log(`Render ${this.getScope("bank").index},${this.getScope("mem").index}`);
                  let vrf = this.getScope("vector_register_file").index;
                  let addr_i = this.svSigRef(`sram_tb.dut.addr_i[vrf]`).asInt() ;
                  let we_i = this.svSigRef(`sram_tb.dut.we_i[vrf]`).asBool(false) ;
                  let req_i = this.svSigRef(`sram_tb.dut.req_i[vrf]`).asBool(false) ;
                  let wdata_i = this.svSigRef(`sram_tb.dut.wdata_i[vrf]`).asInt() ;
                  
                  var mod = (we_i && req_i) && (addr_i == (this.getScope("mem_size").index) * 4 + this.getScope("bank_size").index); // selects which bank to write on
                  //let oldValStr = mod ? `(${'$Value'.asInt(NaN).toString(16)})` : ""; // old value for dmem*/
                  if (this.getInitObject("index")) {
                     let addrStr = parseInt(this.getIndex()).toString();
                     this.getInitObject("index").setText(addrStr + ":");
                  }
                  this.getInitObject("index_val_box").setVisible(true); 
                  this.getInitObject("bank_val_box").setVisible(true); 
                  if(mod == 1) {
                     this.getInitObject("data").setText(wdata_i.toString(16).padStart(8,"0"));
                  }
                  this.getInitObject("data").setFill(mod ? "blue" : "black");
                  
               }
   
\SV
   endmodule
