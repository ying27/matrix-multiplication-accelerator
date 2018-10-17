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
    typedef logic[DATA_WIDTH-1:0] data_t;

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

endpackage
