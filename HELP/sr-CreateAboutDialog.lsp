(defun sr:createAboutDialog (str_IXMP_version str_ODCL_version / name_file file_open)
  (setq name_file (vl-filename-mktemp "dcl.dcl"))
  (setq file_open (open name_file "w"))
  (write-line "ABOUT_IXM_PLUG_INS : dialog { " file_open)
  (write-line "    label=\"About Impact XM Plug-Ins\" ;" file_open)

  (write-line "        : spacer {" file_open)
  (write-line "            height = 1 ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : text {" file_open)
  (write-line "            key = \"DCLLabel1\" ;" file_open)
  (write-line "            label = \"Impact XM Plug-Ins\" ;" file_open)
  (write-line "            width = 40 ;" file_open)
  (write-line "            alignment = centered ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : spacer {" file_open)
  (write-line "            height = 1 ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : text {" file_open)
  (write-line "            key = \"DCLLabel2\" ;" file_open)
  (write-line (strcat 
              "            label = \"Version: " str_IXMP_version "\" ;") file_open)
  (write-line "            width = 40 ;" file_open)
  (write-line "            alignment = centered ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : spacer {" file_open)
  (write-line "            height = 1 ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : button {" file_open)
  (write-line "            key = \"DCLButton1\" ;" file_open)
  (write-line "            label = \"Impact XM Plug-Ins on Dropbox.com\" ;" file_open)
  (write-line "            alignment = top ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : spacer {" file_open)
  (write-line "            height = 1 ;" file_open)
  (write-line "        }" file_open)



  (write-line "        : spacer {" file_open)
  (write-line "            height = 1 ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : text {" file_open)
  (write-line "            key = \"DCLLabel3\" ;" file_open)
  (write-line "            label = \"OpenDCL Runtime\" ;" file_open)
  (write-line "            width = 40 ;" file_open)
  (write-line "            alignment = centered ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : spacer {" file_open)
  (write-line "            height = 1 ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : text {" file_open)
  (write-line "            key = \"DCLLabel4\" ;" file_open)
  (write-line (strcat 
              "            label = \"Version: " str_ODCL_version "\" ;") file_open)
  (write-line "            width = 40 ;" file_open)
  (write-line "            alignment = centered ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : spacer {" file_open)
  (write-line "            height = 1 ;" file_open)
  (write-line "        }" file_open)
  (write-line "        : button {" file_open)
  (write-line "            key = \"DCLButton2\" ;" file_open)
  (write-line "            label = \"OpenDCL on Dropbox.com\" ;" file_open)
  (write-line "            alignment = top ;" file_open)
  (write-line "        }" file_open)

  (write-line "        : spacer {" file_open)
  (write-line "            height = 1 ;" file_open)
  (write-line "        }" file_open)



  (write-line "        :row {" file_open)
  (write-line "            :column {" file_open)
  (write-line "                width = 10 ;" file_open)
  (write-line "            }" file_open)
  (write-line "            :column {" file_open)
  (write-line "                : button {" file_open)
  (write-line "                    key = \"DCLButton3\" ;" file_open)
  (write-line "                    label = \"Close\" ;" file_open)
  (write-line "                    alignment = centered ;" file_open)
  (write-line "                    is_tab_stop = false ;" file_open)
  (write-line "                    is_default = true ;" file_open)
  (write-line "                    is_cancel = true ;" file_open)
  (write-line "                }" file_open)
  (write-line "            }" file_open)
  (write-line "            :column {" file_open)
  (write-line "                width = 10 ;" file_open)
  (write-line "            }" file_open)
  (write-line "        }" file_open)
  (write-line "}" file_open)
  (close file_open)
  name_file
)
