\m4_TLV_version 1d: tl-x.org
\SV

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
   
   /imp_val 
      \viz_alpha 
         initEach: function() {
               let r_addr_q_val = new fabric.Text("r_addr_q_val", {
                  top: 630,
                  left: 610,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               let sram_val = new fabric.Text("sram_addr_val", {
                  top: 610,
                  left: 610,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               let rdata_o_arrow = new fabric.Line([1120, 0, 1250, 0], {
                  stroke: "#00bfff",
                  strokeWidth: 3, 
                  visible: true 
               })
               let rdata_o_val = new fabric.Text("rdata_o", {
                  top: -20,
                  left: 1130,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               let addr_i_arrow = new fabric.Line([400, 0, 530, 0], {
                  stroke: "#00bfff",
                  strokeWidth: 3, 
                  visible: true 
               })
               let addr_i_val = new fabric.Text("addr_i", {
                  top: -20,
                  left: 350,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               
               let req_i_arrow = new fabric.Line([400, 100, 530, 100], {
                  stroke: "#00bfff",
                  strokeWidth: 3, 
                  visible: true 
               })
               let req_i_val = new fabric.Text("req_i", {
                  top: 80,
                  left: 350,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               
               let we_i_arrow = new fabric.Line([400, 200, 530, 200], {
                  stroke: "#00bfff",
                  strokeWidth: 3, 
                  visible: true 
               })
               let we_i_val = new fabric.Text("we_i", {
                  top: 180,
                  left: 350,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               
               let wdata_i_arrow = new fabric.Line([400, 300, 530, 300], {
                  stroke: "#00bfff",
                  strokeWidth: 3, 
                  visible: true 
               })
               let wdata_i_val = new fabric.Text("wdata_i", {
                  top: 280,
                  left: 340,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               
               let be_i_arrow = new fabric.Line([400, 400, 530, 400], {
                  stroke: "#00bfff",
                  strokeWidth: 3, 
                  visible: true 
               })
               let be_i_val = new fabric.Text("be_i", {
                  top: 380,
                  left: 350,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               
               let bank_box = new fabric.Rect({
                  top: -60,
                  left: 530,
                  fill: "#208028",
                  width: 590,
                  height: 650,
                  stroke: "black", 
                  visible: false 
               })
            return {objects: {r_addr_q_val, sram_val, rdata_o_arrow, rdata_o_val, addr_i_arrow, addr_i_val, req_i_arrow, req_i_val, we_i_arrow, we_i_val, wdata_i_arrow, wdata_i_val, be_i_arrow, be_i_val, bank_box}};
         },
         renderEach: function() {
            /*let addr_i = this.svSigRef(`dut.addr_i`).asInt().toString(16) ;
            let wdata_i = this.svSigRef(`dut.wdata_i`).asInt().toString(16) ;
            let we_i = this.svSigRef(`dut.we_i`).asBool(false) ;
            let req_i = this.svSigRef(`dut.req_i`).asBool(false) ;
            let be_i = this.svSigRef(`dut.be_i`).asInt().toString(16) ;
            let sram_val = this.svSigRef(`dut.sram[addr_i]`).asBool(false) ;
            let rdata_o = this.svSigRef(`dut.rdata_o`).asInt().toString(16) ;
            let r_addr_q = this.svSigRef(`dut.r_addr_q`).asInt().toString(16) ;
            
            this.getInitObject("addr_i_val").setText("addr_i : " + addr_i.padStart(2,"0"));
            this.getInitObject("wdata_i_val").setText("wdata_i : " + wdata_i.padStart(8,"0"));
            this.getInitObject("we_i_val").setText("we_i : " + we_i);
            this.getInitObject("be_i_val").setText("be_i : " + be_i);
            this.getInitObject("req_i_val").setText("req_i : " + req_i);
            this.getInitObject("r_addr_q_val").setText("r_addr_q : " + r_addr_q);
            
            var mod = (!we_i && req_i) ; 
            this.getInitObject("rdata_o_val").setText(mod ? "rdata_o : " + rdata_o.padStart(8,"0") :  "x");
            this.getInitObject("sram_val").setText("sram[addr]_val : " + sram_val.prevCycle().padStart(8,"0") + "->" + sram_val.padStart(8,"0"));
            */
            this.getInitObject("bank_box").setVisible(true);
         }
   
   /bank_size[3:0]
      /mem_size[31:0] 
         \viz_alpha
            initEach: function() {
               
               let index_val_box = new fabric.Rect({
                  top: 18 * this.getIndex(),
                  left:  540,
                  fill: "white",
                  width: 40,
                  height: 14,
                  stroke: "black",
                  visible: false
               })
               let bank_val_box = new fabric.Rect({
                  top: 18 * this.getIndex(),
                  left: 500 + (4 - this.getScope("bank_size").index) * 120 + 10,
                  fill: "white",
                  width: 100,
                  height: 14,
                  stroke: "black",
                  visible: false
               })
               let regname = new fabric.Text("Data Memory (hex)", {
                        top: -40,
                        left: 500 + 4 * 15, // Center aligned
                        fontSize: 14,
                        fontFamily: "monospace"
                     })
               let bankname = new fabric.Text("bank", {
                  top: -20,
                  left: 545,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               let banknum = new fabric.Text(String(this.getScope("bank_size").index), {
                  top: -20,
                  left: 490 + (4 - this.getScope("bank_size").index) * 120 + 60,
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               let data = new fabric.Text("00000000", {
                  top: 18 * this.getIndex(),
                  left: 515 + (4 - this.getScope("bank_size").index) * 120 + 10, // bank: 3 2 1 0 format
                  fontSize: 14,
                  fontFamily: "monospace"
               })
               //let index = (this.getScope("bank").index != 0) ? null : // resulting in "Cannot read property 'setupState' of null" error
               let index =
                  new fabric.Text("", {
                     top: 18 * this.getIndex(),
                     left: 550,
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
               
               return {objects: {index_val_box, bank_val_box, banknum, bankname, regname, data, index}};
            },
            renderEach: function() {
               //console.log(`Render ${this.getScope("bank").index},${this.getScope("mem").index}`);
               /*let addr_i = this.svSigRef(`dut.addr_i`).asInt() ;
               let we_i = this.svSigRef(`dut.we_i`).asBool(false) ;
               let req_i = this.svSigRef(`dut.req_i`).asBool(false) ;
               let wdata_i = this.svSigRef(`dut.wdata_i`).asInt() ;
               
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
