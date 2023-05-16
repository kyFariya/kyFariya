module axil  #(                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               2   parameter ADDR_WIDTH = 0,
     parameter DATA_WIDTH = 0
 )
   (
     input wire                     clk,
     input wire                     rst_n,

     input wire [ADDR_WIDTH-1:0]    awaddr,
     input wire                     awvalid,
     output reg                     awready,

     input wire [DATA_WIDTH-1:0]    wdata,
     input wire [DATA_WIDTH/8-1:0]  wstrb,
     input wire                     wvalid,
     output reg                     wready,

     output reg [1:0]               bresp,
     output reg                     bvalid,
     input wire                     bready,

     input wire [ADDR_WIDTH-1:0]    araddr,
     input wire                     arvalid,
     output reg                     arready,

     output reg [DATA_WIDTH-1:0]    rdata,
     output reg [1:0]               rresp,
     output reg                     rvalid,
     input wire                     rready
   );

   reg [(2**ADDR_WIDTH-1):0][7:0] mem ;

   reg aw_found;
   reg  w_found;
   reg ar_found;

   reg [ADDR_WIDTH-1:0]         buff_awaddr;
   reg [DATA_WIDTH/8-1:0][7:0]  buff_wdata;
   reg [DATA_WIDTH/8-1:0]       buff_wstrb;
   reg [ADDR_WIDTH-1:0]         buff_araddr;

   always @ (posedge clk)
     begin
       if (rst_n) // not reset
         begin

           if (bvalid && bready) // complete write
             begin
               awready = '1;
               wready  = '1;
               bvalid  = '0;
              end

           if (awready && awvalid) // capture awaddr
             begin
               awready = '0;
               buff_awaddr = awaddr;
             end

           if (wready && wvalid) // capture winfo
             begin
               wready = '0;
               buff_wdata = wdata;
               buff_wstrb = wstrb;
             end

           if ((!awready) && (!wready)) // do write
             begin
               foreach(buff_wdata[i])
                  begin
                    if (buff_wstrb[i])
                      begin
                        mem[buff_awaddr+i] = buff_wdata[i];
                      end
                  end
                bresp = '0;
                bvalid = '1;
              end
 
            if (rvalid && rready) // complete read
              begin
               arready = '1;
               rvalid  = '0;
             end

           if (arready && arvalid) // capture araddr & do read
             begin
               reg [DATA_WIDTH/8-1:0][7:0] r_data;
               arready = '0;
               buff_araddr = araddr;
               foreach (r_data[i])
                 begin
                   r_data[i] = mem[buff_araddr + i];
                 end
               rdata  = r_data;
               rresp  = '0;
               rvalid = '1;
             end

         end

       else // reset
         begin
           awready  = '1;
           wready   = '1;
           bvalid   = '0;
           arready  = '1;
           rvalid   = '0;
         end
     end

 endmodule

