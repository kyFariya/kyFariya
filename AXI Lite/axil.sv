 1 module axil  #(                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               2   parameter ADDR_WIDTH = 0,
  3   parameter DATA_WIDTH = 0
  4 )
  5   (
  6     input wire                     clk,
  7     input wire                     rst_n,
  8
  9     input wire [ADDR_WIDTH-1:0]    awaddr,
 10     input wire                     awvalid,
 11     output reg                     awready,
 12
 13     input wire [DATA_WIDTH-1:0]    wdata,
 14     input wire [DATA_WIDTH/8-1:0]  wstrb,
 15     input wire                     wvalid,
 16     output reg                     wready,
 17
 18     output reg [1:0]               bresp,
 19     output reg                     bvalid,
 20     input wire                     bready,
 21
 22     input wire [ADDR_WIDTH-1:0]    araddr,
 23     input wire                     arvalid,
 24     output reg                     arready,
 25
 26     output reg [DATA_WIDTH-1:0]    rdata,
 27     output reg [1:0]               rresp,
 28     output reg                     rvalid,
 29     input wire                     rready
 30   );
 31
 32   reg [(2**ADDR_WIDTH-1):0][7:0] mem ;
 33
 34   reg aw_found;
 35   reg  w_found;
 36   reg ar_found;
 37
 38   reg [ADDR_WIDTH-1:0]         buff_awaddr;
 39   reg [DATA_WIDTH/8-1:0][7:0]  buff_wdata;
 40   reg [DATA_WIDTH/8-1:0]       buff_wstrb;
 41   reg [ADDR_WIDTH-1:0]         buff_araddr;
 42
 43   always @ (posedge clk)
 44     begin
 45       if (rst_n) // not reset
 46         begin
 47
 48           if (bvalid && bready) // complete write
 49             begin
 50               awready = '1;
 51               wready  = '1;
 52               bvalid  = '0;
 53             end
 54
 55           if (awready && awvalid) // capture awaddr
 56             begin
 57               awready = '0;
 58               buff_awaddr = awaddr;
 59             end
 60
 61           if (wready && wvalid) // capture winfo
 62             begin
 63               wready = '0;
 64               buff_wdata = wdata;
 65               buff_wstrb = wstrb;
 66             end
 67
 68           if ((!awready) && (!wready)) // do write
 69             begin
 70               foreach(buff_wdata[i])
 71                 begin
 72                   if (buff_wstrb[i])
 73                     begin
 74                       mem[buff_awaddr+i] = buff_wdata[i];
 75                     end
 76                 end
 77               bresp = '0;
 78               bvalid = '1;
 79             end
 80
 81           if (rvalid && rready) // complete read
 82             begin
 83               arready = '1;
 84               rvalid  = '0;
 85             end
 86
 87           if (arready && arvalid) // capture araddr & do read
 88             begin
 89               reg [DATA_WIDTH/8-1:0][7:0] r_data;
 90               arready = '0;
 91               buff_araddr = araddr;
 92               foreach (r_data[i])
 93                 begin
 94                   r_data[i] = mem[buff_araddr + i];
 95                 end
 96               rdata  = r_data;
 97               rresp  = '0;
 98               rvalid = '1;
 99             end
100
101         end
102
103       else // reset
104         begin
105           awready  = '1;
106           wready   = '1;
107           bvalid   = '0;
108           arready  = '1;
109           rvalid   = '0;
110         end
111     end
112
113 endmodule

