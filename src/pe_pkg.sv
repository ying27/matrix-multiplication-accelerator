//////////////////////////////////////////////////////////////////////////////////////
//    TITLE:          Processing Element (PE) package                               //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//    REVISION:       0.1 - PE basic data types and data length                     //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

package pe_pkg;

    // --------------------
    // Global Config
    // --------------------
    localparam DATA_WIDTH = 8;

    // --------------------
    // PE data struct
    // --------------------
    typedef struct packed {
        logic [DATA_WIDTH-1:0] data;
        logic                  last;
    } matrix_data_t;

    typedef struct packed {
        logic [DATA_WIDTH-1:0] data;
        logic                  enable;
    } drain_data_t;

endpackage
