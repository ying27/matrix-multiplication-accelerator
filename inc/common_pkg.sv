//////////////////////////////////////////////////////////////////////////////////////
//    TITLE:          Common definitions package                                    //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//    REVISION:       0.1 - Common basic data types and data length                 //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

package common_pkg;

    // --------------------
    // Global Config
    // --------------------
    localparam DATA_WIDTH = 8;
    localparam SYS_ARRAY_SIZE = 2;
    localparam ADDR_WIDTH = 64;
    localparam T_D = 2*SYS_ARRAY_SIZE;
    localparam T_C = SYS_ARRAY_SIZE;
    typedef logic[DATA_WIDTH-1:0] data_t;
    typedef logic[ADDR_WIDTH-1:0] addr_t;

    // --------------------
    // PE data struct
    // --------------------
    typedef struct packed {
        data_t data;
        logic  last;
    } matrix_data_t;

    typedef struct packed {
        data_t data;
        logic  enable;
    } drain_data_t;

    // --------------------
    // Control Commands
    // --------------------
    typedef struct packed {
        logic compute_req;
        logic drain_en;
        addr_t a_addr;
        addr_t b_addr;
        addr_t c_addr;
    } ctrl_t;
    
    // --------------------
    // Memory data struct
    // --------------------
    localparam COUNT_WIDTH = $clog2(T_C);
    typedef logic[COUNT_WIDTH-1:0] mcount_t;
    

endpackage
