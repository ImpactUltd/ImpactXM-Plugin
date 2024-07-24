(defun f:NewDwgWithTemplate ( str_template / *error*)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
  )
  (vla-StartUndoMark (actvDoc))
    
  (setq sysvar_CMDECHO (getvar 'CMDECHO)
        path_templates (strcat (f:GetPlugInPath "*IMPACT XM PLUG-INS.BUNDLE*") "Resources\\Templates\\")
  ) ; setq

  (cond
    ((= str_template "IMPERIAL")
      (vla-Activate (vla-Add (vla-get-Documents (vlax-get-acad-object)) (strcat path_templates "IXM-TEMPLATE-IMPERIAL.dwt")))
    )
    ((= str_template "METRIC")
      (vla-Activate (vla-Add (vla-get-Documents (vlax-get-acad-object)) (strcat path_templates "IXM-TEMPLATE-METRIC.dwt")))
    )
    ((= str_template "AVC")
      (vla-Activate (vla-Add (vla-get-Documents (vlax-get-acad-object)) (strcat path_templates "IXM-TEMPLATE-AVC.dwt")))
    )
    ((= str_template "BLANK")
      (vla-Activate (vla-Add (vla-get-Documents (vlax-get-acad-object)) (strcat path_templates "IXM-TEMPLATE-BLANK.dwt")))
    )
    (t
      (vla-Activate (vla-Add (vla-get-Documents (vlax-get-acad-object)) (strcat path_templates "IXM-TEMPLATE-BLANK.dwt")))
    )
  )
  (vla-EndUndoMark (actvDoc))
  (princ)
)

(defun c:NEW_IXM_IMPERIAL nil (f:NewDwgWithTemplate "IMPERIAL"))
(defun c:NEW_IXM_METRIC   nil (f:NewDwgWithTemplate "METRIC"))
(defun c:NEW_IXM_AVC nil (f:NewDwgWithTemplate "AVC"))
(defun c:NEW_IXM_BLANK nil (f:NewDwgWithTemplate "BLANK"))


