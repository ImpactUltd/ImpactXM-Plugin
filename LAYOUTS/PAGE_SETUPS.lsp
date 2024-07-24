(defun c:PAGE_SETUP_CUR_24x18 nil (PAGE_SETUP "Current" "24x18"))
(defun c:PAGE_SETUP_ALL_24x18 nil (PAGE_SETUP "All"     "24x18"))
(defun c:PAGE_SETUP_CUR_17x11 nil (PAGE_SETUP "Current" "17x11"))
(defun c:PAGE_SETUP_ALL_17x11 nil (PAGE_SETUP "All"     "17x11"))

(defun PAGE_SETUP ( option size / current_layout layout file_tmp_pdf list_layouts pt_BL pt_TR)
  (setq   current_layout      (getvar 'CTAB)
          plot_configuration  "DWG To PDF.pc3")
  (cond
    ((= option "Current")
      (setq list_layouts (list (getvar 'CTAB)))
    )
    ((= option "All")
      (setq list_layouts (layoutlist))
    )
  )
  (cond
    ((= size "24x18")
      (setq page_size "ARCH full bleed C (24.00 x 18.00 Inches)"
            pt_BL     '(-0.484375 -0.359375)
            pt_TR     '(23.453125 17.578125)
      )
    )
    ((= size "17x11")
      (setq page_size "ANSI full bleed B (17.00 x 11.00 Inches)"
            pt_BL     '(-0.25 -0.125)
            pt_TR     '(16.25 10.375)
      )
    )
  )
  
  (setq file_tmp_pdf (vl-filename-mktemp "temp.pdf"))
  
  (foreach layout (acad_strlsort list_layouts)
      (if (or (> (atoi (substr layout 1 2)) 0)
              (= (length list_layouts) 1))
          (progn
              (princ (strcat "\nLayout \"" layout "\" setup for " page_size "\n"))
              (setvar 'CTAB layout)
              (command-s "-PLOT"  "Y"   ""
                         plot_configuration
                         page_size
                         "Inches" "Landscape"   "No"
                         "Window"  "non" pt_BL  "non" pt_TR
                         "1:1" "0,0" "Yes" "@COLOR.ctb" 
                         "Yes" "No" "No" "No" file_tmp_pdf "Y" "N"
              )
              (C:PLOT_SET_TRANSPARENCY_ON)
              (command-s "ZOOM" "ALL")
          )
          (princ (strcat "\nLayout \"" layout "\" skipped.\n"))
      )
  )
  (setvar 'CTAB current_layout)
  (princ)
)

(defun c:PAGE_SETUP_COPY_TO_ALL (/ Adoc Layts clyt) 
  (setq aDoc  (vla-get-activedocument (vlax-get-acad-object))
        Layts (vla-get-layouts aDoc)
        clyt  (vla-get-activelayout aDoc)
  )
  (foreach itm (vl-remove (vla-get-name clyt) (layoutlist)) 
    (vla-copyfrom (vla-item Layts itm) clyt)
  )
  (princ)
)


; PrinterConfigPath
; PrinterDescPath 
; PrinterStyleSheetPath