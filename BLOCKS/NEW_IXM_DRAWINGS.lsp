;┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
;┃ Usage (read only):                                                         ┃
;┃   (f:openDrawing "G:\\Jobs\\Tax Maps\\Raritan Center Tax Map.dwg" T)       ┃
;┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

(defun f:openDrawing (str_dwg bol_ReadOnly / *error*) 
  
  (defun *error* (s) 
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  
  (vla-StartUndoMark (actvDoc))
  
  (if bol_ReadOnly
    (setq vlax_ReadOnly :vlax-true)
    (setq vlax_ReadOnly :vlax-false)

  )

  (vla-Open (vla-get-documents (acadObj)) str_dwg vlax_ReadOnly)

  (vlax-for obj_dwg 
            (vla-get-documents (acadObj))
            (if 
              (= (vla-get-Name obj_dwg) 
                 (strcat (vl-filename-base str_dwg) 
                         (vl-filename-extension str_dwg)
                 )
              )
              (vla-Activate obj_dwg)
            )
            (princ)
  )

  (vla-EndUndoMark (actvDoc))
  (princ)
)


;┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
;┃ Usage:                                                                     ┃
;┃   (f:newDrawing "G:\\AutoCAD\\Templates\\As-Built.dwt")                    ┃
;┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

(defun f:newDrawing (str_dwt / *error*) 
  
  (defun *error* (s) 
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  
  (vla-StartUndoMark (actvDoc))
    
  (vla-Add (vla-get-documents (acadObj)) str_dwt)
  (vlax-for obj_dwg (vla-get-documents (acadObj))
    (setq activeDwg obj_dwg) 
  )
  (vla-Activate activeDwg)  

  (vla-EndUndoMark (actvDoc))
  (princ)
)

; (f:newDrawing "G:\\AutoCAD\\Templates\\As-Built.dwt")