(defun c:PAGE_SETUPS_IXM (/ file_path file_name ps *error*) 
  (defun *error* (s) 
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))


  (vlax-for ps 
    (vla-get-plotconfigurations 
      (vla-get-ActiveDocument 
        (vlax-get-acad-object)
      )
    )
    (vla-delete ps)
  )
    
  (setq file_path (f:getBlockPath "Template" (f:GetDWTname "E30000000-IMPERIAL TEMPLATE" )))
    
  ;; (getenv "ACAD") for a list of autocad's seach pathes
  
  (if (setq file_name (f:GetDWTname "E30000000-IMPERIAL TEMPLATE" ))
    (progn 
      (command "._-PSETUPIN" file_path "*")
      (command "PAGESETUP")
    )
    (princ "\nIXM Template File does not exist. Check you template folder.")
  )
  
  (vla-EndUndoMark (actvDoc))
  (princ)
)
