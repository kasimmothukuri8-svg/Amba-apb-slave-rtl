module amba_ahb_slave_core #(
    parameter ADDR_BUS_WIDTH = 8,
    parameter DATA_BUS_WIDTH = 32
)(
    input                            HCLK,
    input                            HRESETn,
    input                            HSEL,
    input  [31:0]                    HADDR,
    input  [1:0]                     HTRANS,
    input                            HWRITE,
    input  [2:0]                     HSIZE,
    input                            HREADYIN,
    input  [DATA_BUS_WIDTH-1:0]      HWDATA,
    output reg                       HREADY,
    output reg                       HRESP,
    output reg [DATA_BUS_WIDTH-1:0]  HRDATA
);

    localparam STORAGE_DEPTH = 1 << ADDR_BUS_WIDTH;
    reg [DATA_BUS_WIDTH-1:0] internal_ram_matrix [0:STORAGE_DEPTH-1];

    localparam TR_IDLE   = 2'b00;
    localparam TR_BUSY   = 2'b01;
    localparam TR_NONSEQ = 2'b10;
    localparam TR_SEQ    = 2'b11;

    reg [ADDR_BUS_WIDTH-1:0] r_latched_addr;
    reg                      r_latched_write;
    reg                      r_valid_data_phase;

    integer idx;

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            r_latched_addr     <= 0;
            r_latched_write    <= 0;
            r_valid_data_phase <= 0;
        end else begin
            if (HSEL && HREADYIN && ((HTRANS == TR_NONSEQ) || (HTRANS == TR_SEQ))) begin
                r_latched_addr     <= HADDR[ADDR_BUS_WIDTH-1:0];
                r_latched_write    <= HWRITE;
                r_valid_data_phase <= 1'b1;
            end else if (HREADYIN) begin
                r_valid_data_phase <= 1'b0;
            end
        end
    end

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HRDATA <= 0;
            for (idx = 0; idx < STORAGE_DEPTH; idx = idx + 1) begin
                internal_ram_matrix[idx] <= 0;
            end
        end else begin
            if (r_valid_data_phase) begin
                if (r_latched_write) begin
                    internal_ram_matrix[r_latched_addr] <= HWDATA;
                end else begin
                    HRDATA <= internal_ram_matrix[r_latched_addr];
                end
            end
        end
    end

    always @(*) begin
        HRESP = 1'b0; 
        HREADY = 1'b1; 
    end

endmodule
