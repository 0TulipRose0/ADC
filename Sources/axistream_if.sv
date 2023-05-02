/*
 * axistream.sv -- AXI4Stream
 *
 * 2021, Alexander orlov <alxorlov@olvs.miee.ru>
 */


interface axistream_if #(int DWIDTH = 32, int ID_WIDTH = 4, int DEST_WIDTH = 1, int USER_WIDTH = 4) (
    input aclk
);

    localparam WIDTH_BYTES = DWIDTH / 8;

    typedef logic [DWIDTH-1:0] tdata_t;
    typedef logic [WIDTH_BYTES-1:0] tstrb_t;
    typedef logic [ID_WIDTH-1:0] tid_t;
    typedef logic [DEST_WIDTH-1:0] tdest_t;
    typedef logic [USER_WIDTH-1:0] tuser_t;

    logic tvalid;
    logic tready;
    tdata_t tdata;
    tstrb_t tstrb;
    tstrb_t tkeep;
    logic tlast;
    tid_t tid;
    tdest_t tdest;
    tuser_t tuser;

    clocking cbm @(posedge aclk);
        output tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser;
        input tready;
    endclocking

    clocking cbs @(posedge aclk);
        input tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser;
        output tready;
    endclocking

    modport tb_master (clocking cbm);

    modport tb_slave (clocking cbs);

    modport master (
        output tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser,
        input tready
    );

    modport slave (
        input tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser,
        output tready
    );

endinterface


module axis_connect (
    axistream_if.slave s_axis,
    axistream_if.master m_axis
);

    assign m_axis.tvalid = s_axis.tvalid;
    assign m_axis.tdata  = s_axis.tdata;
    assign m_axis.tstrb  = s_axis.tstrb;
    assign m_axis.tkeep  = s_axis.tkeep;
    assign m_axis.tlast  = s_axis.tlast;
    assign m_axis.tid    = s_axis.tid;
    assign m_axis.tdest  = s_axis.tdest;
    assign m_axis.tuser  = s_axis.tuser;
    assign s_axis.tready = m_axis.tready;

endmodule