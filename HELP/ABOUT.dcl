ABOUT_IXM_PLUG_INS : dialog { 
    label="About Impact XM Plug-Ins";
        : spacer {
            height = 1 ;
        }
        : text {
            key = "DCLLabel1" ;
            label = "Impact XM Plug-Ins" ;
            width = 40 ;
            alignment = centered ;
        }
        : spacer {
            height = 1 ;
        }
        : text {
            key = "DCLLabel2" ;
            label = "Version 2020-01-17" ;
            width = 40 ;
            alignment = centered ;
        }
        : spacer {
            height = 1 ;
        }
        : button {
            key = "DCLButton1" ;
            label = "Impact XM Plug-Ins on Dropbox.com" ;
            alignment = top ;
        }
        : spacer {
            height = 1 ;
        }
        :row {
            :column {
                width = 10 ;
            }
            :column {
                : button {
                    key = "DCLButton2" ;
                    label = "Close" ;
                    alignment = centered ;
                    is_tab_stop = false ;
                    is_default = true ;
                    is_cancel = true ;
                }
            }
            :column {
                width = 10 ;
            }
        }
}