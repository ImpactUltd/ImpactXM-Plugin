(defun c:CNC_PLOT_SHEETS  (/ *error* 
                              f:PlotSheet var_FileDia var_bgPlot list_obj_blocks list_obj_TBlocks pt_1_plot_win pt_2_plot_win pt_TBlockIns pt_1_win pt_2_win file_name_dwg file_name_pdf 
                          )
  (defun *error* (msg)
    (if (not
          (member msg '("Function cancelled" "quit / exit abort"))
        )
      (princ (strcat "\nError: " msg))
    )
    (setvar 'FILEDIA        var_FileDia)
    (setvar 'BACKGROUNDPLOT var_bgPlot)
    (princ)
  )
  (defun f:PlotSheet ( pt_1_plot_win pt_2_plot_win file_path_name / )
    (command-s
      "-PLOT"
      "Yes"                                     ;; Detailed plot configuration? [Yes/No]
      "Model"                                   ;; Enter a layout name or [?]
      "DWG To PDF.pc3"                          ;; Enter an output device name or [?]
      "ANSI full bleed A (11.00 x 8.50 Inches)" ;; Enter paper size or [?]
      "Inches"                                  ;; Enter paper units [Inches/Millimeters]
      "Landscape"                               ;; Enter drawing orientation [Portrait/Landscape]
      "No"                                      ;; Plot upside down? [Yes/No]
      "Window"                                  ;; Enter plot area [Display/Extents/Layout/View/Window]
      "non" pt_1_plot_win                       ;; Enter lower left corner of window <>
      "non" pt_2_plot_win                       ;; Enter upper right corner of window <>
      "0.75=12"                                 ;; Enter plot scale (Plotted Millimeters=Drawing Units) 
                                                ;;   or [Fit]
      "Center"                                  ;; Enter plot offset (x,y) or [Center]
      "Yes"                                     ;; Plot with plot styles? [Yes/No]
      "@XEROX8830.ctb"                          ;; Enter plot style table name or [?]
      "Yes"                                     ;; Plot with lineweights? [Yes/No]
      "W"                                       ;; Enter shade plot setting [As displayed/legacy Wireframe/
                                                ;;  legacy Hidden/Visual styles/Rendered]
      file_path_name                            ;; Enter file name <>
      "No"                                      ;; Save changes to page setup [Yes/No]?
      "Yes"                                     ;; Proceed with plot [Yes/No] <Y>:
    )
  )

  ;; MAIN Routine
  ;; Select CNC Layouts and Filter Title Blocks
  (setq list_obj_blocks (SelectionSet->objList (ssget '((0 . "INSERT")))))
  ;;
  (foreach obj_block list_obj_blocks      
    (setq list_obj_TBlocks (cons obj_block list_obj_TBlocks))
  )
  ;;

  (setq var_bgPlot  (getvar 'BACKGROUNDPLOT)
        var_FileDia (getvar 'FILEDIA)
  )
  ;;
  (setvar 'BACKGROUNDPLOT 0)
  (setvar 'FILEDIA 0)
  (command-s "-PLOTSTAMP" "OFF" "")
  ;;
  (setq pt_1_plot_win   '( -4.0  -2.0  0.0)
        pt_2_plot_win   '(164.0 126.0  0.0)
        file_path_fab   (f:BuildFabricationDirectory)
        index           1
  )
  ;;
  (foreach obj_TBlock list_obj_TBlocks
    ;;
    (setq pt_TBlockIns  (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint obj_TBlock)))
          pt_1_win       (mapcar '+ pt_TBlockIns pt_1_plot_win)
          pt_2_win       (mapcar '+ pt_TBlockIns pt_2_plot_win)
          file_name_dwg (vl-string-right-trim ".dwg" (getvar 'DWGNAME))
    )
    (cond
      ((= (cl:GetDynPropValue obj_TBlock "DRAWING TYPE") "CNC (8.5 x 11 only)")
          (setq file_name_pdf (strcat file_name_dwg " - CNC - "(cl:GetAttributeValue obj_TBlock "NC_PROG")))
      )
      ((= (cl:GetDynPropValue obj_TBlock "DRAWING TYPE") "Beamsaw (8.5 x 11 only)")
          (setq file_name_pdf (strcat file_name_dwg " - BEAMSAW - " (cl:GetAttributeValue obj_TBlock "PAGE")))
      )
      (T
          (setq file_name_pdf (strcat file_name_dwg " - UNKNOWN - " index))
      )
    )
    ;;
    (f:PlotSheet pt_1_win pt_2_win (strcat file_path_fab "\\" file_name_pdf))
    (setq index (1+ index))
  )

  (setvar 'FILEDIA        var_FileDia)
  (setvar 'BACKGROUNDPLOT var_bgPlot)

  (princ)
)

;; (princ "\nCNC_PLOT_SHEETS.VLX loaded.")


