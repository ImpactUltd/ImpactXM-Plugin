(defun CreateNewBOMLayout ( layoutName / acadDoc listLayouts layoutObj point1 point2 LayoutTransparency)
  (defun LayoutTransparency (layoutObj ON / xType xData )
    (setq xData (vlax-make-safearray vlax-vbVariant '(0 . 1)))
    (setq xType (vlax-make-safearray vlax-vbInteger '(0 . 1)))
    (vlax-safearray-fill xData (list(vlax-make-variant "PLOTTRANSPARENCY")(vlax-make-variant ON)))
    (vlax-safearray-fill xType (list 1001 1071))
    (vla-setXdata layoutObj  xType xData)
    (entmod(entget (vlax-vla-object->ename layoutObj) '("*")))
  )
  (setq acadDoc (vla-get-activedocument (vlax-get-acad-object)))
  (setq listLayouts (vla-get-layouts acadDoc))
  (vlax-for layoutObj listLayouts
    (if (= (vla-get-name layoutObj) layoutName) ; check if it exists
      (progn
        (vla-delete layoutObj) ;delete the Layout
        (vlax-release-object layoutObj) ; release the Layout Object
      )
    )
  )
  (setq point1 (vlax-make-safearray vlax-vbDouble '(0 . 1)))
    (vlax-safearray-put-element point1 0 -0.25)
    (vlax-safearray-put-element point1 1 -0.125)
  (setq point2 (vlax-make-safearray vlax-vbDouble '(0 . 1)))
    (vlax-safearray-put-element point2 0 23.25)
    (vlax-safearray-put-element point2 1 17.375)

  ; Create a layout named "XX-MATRIX BILL OF MATERIALS"
  (setq layoutObj (vla-add listLayouts layoutName))
  
  (vla-put-ConfigName layoutObj "DWG To PDF.pc3")
  (vla-RefreshPlotDeviceInfo layoutObj)
  ;(vla-put-StyleSheet layoutObj "@COLOR.ctb")
  ;(vla-put-ShowPlotStyles layoutObj :vlax-true)
  (vla-put-CanonicalMediaName layoutObj "ARCH_full_bleed_C_(24.00_x_18.00_Inches)")
  
  (vla-put-PlotRotation layoutObj ac0degrees)
  
  (vla-SetWindowToPlot layoutObj point1 point2)
  (vla-put-PlotType layoutObj acWindow)
  
  (vla-put-CenterPlot layoutObj :vlax-true)
  (vla-put-StandardScale layoutObj ac1_1)
  
  ;(LayoutTransparency layoutObj 1)
  
  (vla-ZoomAll (vlax-get-acad-object))
  layoutName
)
