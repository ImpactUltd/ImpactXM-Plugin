
(defun f:GetPlugInPath ( str_plug_in / *error* list_path_prefix path_prefix path_plugin)
  (defun *error* (s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )

  (if str_plug_in
    (progn
      (setq list_path_prefix (string->list (getvar 'ACADPREFIX) ";"))
      (foreach path_prefix list_path_prefix
        (setq path_prefix (strcase path_prefix))
        (if (wcmatch path_prefix str_plug_in)
          (setq path_plugin (strcat path_prefix "\\"))
        )
      )
    )
    (progn
      (setq list_path_prefix (string->list (getvar 'ACADPREFIX) ";"))
      (foreach path_prefix list_path_prefix
        (setq path_prefix (strcase path_prefix))
        (if (wcmatch path_prefix "*APPLICATIONPLUGINS*")
          (setq path_plugin (strcat path_prefix "\\"))
        )
      )
      (setq n (vl-string-search "APPLICATIONPLUGINS" path_plugin)
            n (+ n 19)
            path_plugin (substr path_plugin 1 n)
      )
    )
  )
  path_plugin
)


(defun f:GetDWTname ( / *error*)
  (defun *error* (s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (setq 
    file_name (car (vl-directory-files "Template\\E30000000-IMPERIAL TEMPLATE*.dwt"))
    file_dwt (strcat file_path "\\" file_name)
  )
  file_dwt
)

