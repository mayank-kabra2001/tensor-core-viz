\m4_TLV_version 1d: tl-x.org
\SV

   m4_define(['M4_VECTOR_REG'], 4)
   m4_define(['M4_BANK_SIZE'], 4)
   m4_define(['M4_MEM_SIZE'], 8)

   m4_sv_get_url(['https://raw.githubusercontent.com/mayank-kabra2001/tensor-core-viz-/main/tc_sram.sv'])
   //////////////////////////////////////////////////////////////////////////
                  
                 //TESTBENCH 
                  
   /////////////////////////////////////////////////////////////////////////               
                  
   // =========================================
   // Welcome!  Try the tutorials via the menu.
   // =========================================

   // Default Makerchip TL-Verilog Code Template
   
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   $reset = *reset;
   //...
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   /main 
      \viz_alpha 
            initEach: function() {
                  let memory = new fabric.Text("DATA MEMORY (HEX)", {
                     top: -100,
                     left: 650,
                     fontSize: 30,
                     fontFamily: "monospace"
                  })
                  return{objects: {memory}}; 
               },
      
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
                  let rdata_o_arrow = new fabric.Line([1120, 40 + (this.getScope("vector_register_file").index) * 320 , 1250, 40 + (this.getScope("vector_register_file").index) * 320 ], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let rdata_o_val = new fabric.Text("rdata_o", {
                     top: -92 + (this.getScope("vector_register_file").index) * 320 + 14 * M4_MEM_SIZE,
                     left: 1130,
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  let addr_i_arrow = new fabric.Line([400, 0 + (this.getScope("vector_register_file").index) * 320, 530, 0+ (this.getScope("vector_register_file").index) * 320], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let addr_i_val = new fabric.Text("addr_i", {
                     top: -132 + (this.getScope("vector_register_file").index) * 320 + 14 * M4_MEM_SIZE,
                     left: 350,
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  
                  let req_i_arrow = new fabric.Line([400, 50 + (this.getScope("vector_register_file").index) * 320, 530, 50 + (this.getScope("vector_register_file").index) * 320], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let req_i_val = new fabric.Text("req_i", {
                     top: -82 + (this.getScope("vector_register_file").index) * 320 + 14 * M4_MEM_SIZE,
                     left: 350,
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  
                  let we_i_arrow = new fabric.Line([400, 100 + (this.getScope("vector_register_file").index) * 320, 530, 100 + (this.getScope("vector_register_file").index) * 320], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let we_i_val = new fabric.Text("we_i", {
                     top: -32 + (this.getScope("vector_register_file").index) * 320 + 14 * M4_MEM_SIZE,
                     left: 350,
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  
                  let wdata_i_arrow = new fabric.Line([400, 150 + (this.getScope("vector_register_file").index) * 320, 530, 150 + (this.getScope("vector_register_file").index) * 320], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let wdata_i_val = new fabric.Text("wdata_i", {
                     top: 18 + (this.getScope("vector_register_file").index) * 320 + 14 * M4_MEM_SIZE,
                     left: 340,
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  
                  let be_i_arrow = new fabric.Line([400, 200 + (this.getScope("vector_register_file").index) * 320, 530, 200 + (this.getScope("vector_register_file").index) * 320], {
                     stroke: "#00bfff",
                     strokeWidth: 3, 
                     visible: true 
                  })
                  let be_i_val = new fabric.Text("be_i", {
                     top: 68 + (this.getScope("vector_register_file").index) * 320 + 14 * M4_MEM_SIZE,
                     left: 350,
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
               return {objects: {r_addr_q_val, sram_val, rdata_o_arrow, rdata_o_val, addr_i_arrow, addr_i_val, req_i_arrow, req_i_val, we_i_arrow, we_i_val, wdata_i_arrow, wdata_i_val, be_i_arrow, be_i_val, bank_box, regname}};
            },
            renderEach: function() {
               let vrf_val = this.getScope("vector_register_file").index; 
               /*let addr_i = this.svSigRef(`dut.addr_i[vrf]`).asInt().toString(16) ;
               let wdata_i = this.svSigRef(`dut.wdata_i[vrf]`).asInt().toString(16) ;
               let we_i = this.svSigRef(`dut.we_i[vrf]`).asBool(false) ;
               let req_i = this.svSigRef(`dut.req_i[vrf]`).asBool(false) ;
               let be_i = this.svSigRef(`dut.be_i[vrf]`).asInt().toString(16) ;
               let sram_val = this.svSigRef(`dut.sram[addr_i][vrf]`).asBool(false) ;
               let rdata_o = this.svSigRef(`dut.rdata_o[vrf]`).asInt().toString(16) ;
               let r_addr_q = this.svSigRef(`dut.r_addr_q[vrf]`).asInt().toString(16) ;
               
               this.getInitObject("addr_i_val").setText("addr_i[" + this.getScope("vector_register_file").index.toString() + "] : " + addr_i.padStart(2,"0"));
               this.getInitObject("wdata_i_val").setText("wdata_i[" + this.getScope("vector_register_file").index.toString() + "] : " + wdata_i.padStart(8,"0"));
               this.getInitObject("we_i_val").setText("we_i[" + this.getScope("vector_register_file").index.toString() + "] : " + we_i);
               this.getInitObject("be_i_val").setText("be_i[" + this.getScope("vector_register_file").index.toString() + "] : " + be_i);
               this.getInitObject("req_i_val").setText("req_i[" + this.getScope("vector_register_file").index.toString() + "] : " + req_i);
               this.getInitObject("r_addr_q_val").setText("r_addr_q[" + this.getScope("vector_register_file").index.toString() + "] : " + r_addr_q);
               
               var mod = (!we_i && req_i) ; 
               this.getInitObject("rdata_o_val").setText(mod ? "rdata_o[" + this.getScope("vector_register_file").index.toString() + "] : " + rdata_o.padStart(8,"0") :  "rdata_o[" + this.getScope("vector_register_file").index.toString() + "] : " + "x");
               this.getInitObject("sram_val").setText("sram[addr_i]_val[" + this.getScope("vector_register_file").index.toString() + "] : " + sram_val.prevCycle().padStart(8,"0") + "->" + sram_val.padStart(8,"0"));
               */
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
                  /*let vrf = this.getScope("vector_register_file").index.asInt();
                  let addr_i = this.svSigRef(`dut.addr_i[vrf]`).asInt() ;
                  let we_i = this.svSigRef(`dut.we_i[vrf]`).asBool(false) ;
                  let req_i = this.svSigRef(`dut.req_i[vrf]`).asBool(false) ;
                  let wdata_i = this.svSigRef(`dut.wdata_i[vrf]`).asInt() ;
                  
                  var mod = (we_i && req_i) && (addr_i == (this.getScope("mem_size").index) * 4 + this.getScope("bank_size").index); // selects which bank to write on
                  //let oldValStr = mod ? `(${'$Value'.asInt(NaN).toString(16)})` : ""; // old value for dmem*/
                  if (this.getInitObject("index")) {
                     let addrStr = parseInt(this.getIndex()).toString();
                     this.getInitObject("index").setText(addrStr + ":");
                  }
                  this.getInitObject("index_val_box").setVisible(true); 
                  this.getInitObject("bank_val_box").setVisible(true); 
                  /*if(mod == 1) {
                     this.getInitObject("data").setText(wdata_i.toString(16).padStart(8,"0"));
                  }
                  this.getInitObject("data").setFill(mod ? "blue" : "black");*/
                  
               }
   
\SV
   endmodule
