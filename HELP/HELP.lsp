(defun c:HELP_IXM_PLUG_INS ( / *error*)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
  )
  (vla-StartUndoMark (actvDoc))
    
  (setq file_help_chm (strcat (f:GetPlugInPath "*IMPACT XM.BUNDLE*") "Help/Impact XM Plugins Help.chm" ))

  (startapp "hh.exe" file_help_chm)
    
  (vla-EndUndoMark (actvDoc))
  (princ)
)

(defun f:help-ixm-plugin-id ( map_id / *error*)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
  )
  (vla-StartUndoMark (actvDoc))
    
  (setq file_help_chm (strcat "-mapid " map_id " " (f:GetPlugInPath "*IMPACT XM.BUNDLE*") "Help/Impact XM Plugins Help.chm" ))

  (startapp "hh.exe" file_help_chm)
    
  (vla-EndUndoMark (actvDoc))
  (princ)
)


(defun f:CHECK-PLUG-IN-VERSION (/ *error* file)
  (defun *error*(s)
    (princ s)
    
    (princ)
  )
  
  (setq path_get_git_ver_bat (strcat (f:GetPlugInPath "*IMPACT XM.BUNDLE*") "Help\\get_plugin_git_version.bat")
        path_git_ver_tmp (vl-filename-mktemp "git-.ver")
  )
  
  (startapp path_get_ver_bat path_ver_tmp_file)
  
  (setq vfile (open path_ver_tmp_file "r")
        version (read-line vfile)
  )
  (close vfile)
  
  ; https://stackoverflow.com/questions/16174161/parse-xml-file-for-attribute-from-batch-file
  ; xpath.bat "PackageContent.xmp" "//ApplicationPackage/@AppVersion"
  ; xpath.bat = get_plugin_cur_version.bat
  
  (setq path_get_cur_ver_bat (strcat (f:GetPlugInPath "*IMPACT XM.BUNDLE*") "Help\\get_plugin_cur_version.bat")
        path_xml (vl-string-subst "\\PackageContents.xml" "\\CONTENTS\\" (f:GetPlugInPath "*IMPACT XM.BUNDLE*"))
        path_cur_ver_tmp (vl-filename-mktemp "cur-.ver")
        xpath_args (strcat path_xml " \"//ApplicationPackage/@AppVersion\" > " path_cur_ver_tmp)
  )
  (startapp path_get_cur_ver_bat xpath_args)
  
  
  
  
)

(defun open-pdf (pdfname / shell pdfpath_name) 
  (setq pdfname (vl-string-translate "|" "\\" pdfname))
  (setq shell (vla-getinterfaceobject 
                (vlax-get-acad-object)
                "Shell.Application"
              )
  )
  (setq pdfpath_name (findfile pdfname))
  (vlax-invoke-method shell 'Open pdfpath_name)
  (vlax-release-object shell)
  (princ (strcat " Opening PDF File: " (vl-filename-base pdfpath_name)))
  (princ)
)


;; (vl-directory-files "\\Manuals" "*.pdf" 1)
;; (findfile "\\Manuals\\*.pdf")