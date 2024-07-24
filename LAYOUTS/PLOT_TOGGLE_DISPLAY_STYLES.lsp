(defun c:PLOT_DISPLAY_STYLES_TOGGLE (/ *error*)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
  )
  (vla-StartUndoMark (actvDoc))
  
  ;; Get the layout object
  (setq ACADLayout (vla-get-ActiveLayout (actvDoc)))
  
  ;; Read and display the original value
  (setq originalValue (vla-get-ShowPlotStyles ACADLayout))

  ;; Modify the ShowPlotStyles preference by changing the value
  (vla-put-ShowPlotStyles ACADLayout (if (= originalValue :vlax-true) :vlax-false :vlax-true))

  ;; Regenerate viewports
  (vla-Regen (actvDoc) acAllViewports)
    
  (vla-EndUndoMark (actvDoc))
  (princ)
)


(defun f:PlotDisplayStylesAllLayouts ( state / *error* doc_layouts layout)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
  )
  (vla-StartUndoMark (actvDoc))

  ;; Set 'state' to boolean
  (cond 
    ((= state "ON")
      (setq state :vlax-true))
    ((= state "OFF")
      (setq state :vlax-false)
    )
  )

  ;; Get the layout objects
  (setq doc_layouts (vla-get-Layouts (actvDoc)))
  
  ;; Modify the ShowPlotStyles for all layouts by state
  (vlax-for layout doc_layouts
    (vla-put-ShowPlotStyles layout state)
  )

  ;; Regenerate viewports
  (vla-Regen (actvDoc) acAllViewports)
    
  (vla-EndUndoMark (actvDoc))
  (princ)
)

(defun c:PLOT_DISPLAY_STYLES_ON  () (f:PlotDisplayStylesAllLayouts "ON"))
(defun c:PLOT_DISPLAY_STYLES_OFF () (f:PlotDisplayStylesAllLayouts "OFF"))
