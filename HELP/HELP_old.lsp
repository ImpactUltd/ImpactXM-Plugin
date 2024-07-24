(defun c:ABOUT_IXM_PLUG_INS (/ file_dialog DCLButton1_Action init_handler LoadDialog_ABOUT_IXM_PLUG_INS *error*)
    (vl-load-com)
    (defun *error* (msg)
        (vla-EndUndoMark (actvDoc))
        (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
            (princ (strcat "\nError: " msg))
            (princ (strcat "\n" msg " by User"))
        )
    )
    (vla-StartUndoMark (actvDoc))

    ;(load "L:/AutoCAD Plugins/impact-xm-plug-ins/Help/sr-CreateAboutDialog.lsp")

    (if (not (car (atoms-family 1 '("OPENDCL"))))
      (progn 
        (command "OPENDCL")
        (setq str_ODCL_version (dcl-GetVersionEx))
      )
      (setq str_ODCL_version "Not Installed") 
    )

    (setq file_version_txt (strcat (f:GetPlugInPath "*IMPACT XM.BUNDLE*") "Help/version.txt")
          file_version_ID  (open file_version_txt "r")
          str_IXMP_version (read-line file_version_ID)
          file_version_cls (close file_version_ID)
          str_ODCL_version (dcl-GetVersionEx)
          url_IXMP_Dropbox "https://www.dropbox.com/sh/h4dpu4wmw6uh0p7/AABSCR4ZlbMzCFODZb9niyata?dl=0&lst="
          url_ODCL_Dropbox "https://www.dropbox.com/sh/97v92mzmd27sjrh/AABYDFouTCcICJpDIOBXyG7Ta?dl=0&lst="
    )

    (defun DCLButton1_Action ()
      (vla-SendCommand (actvDoc) (strcat "BROWSER\r" url_IXMP_Dropbox "\r"))
    )

    (defun DCLButton2_Action ()
      (vla-SendCommand (actvDoc) (strcat "BROWSER\r" url_ODCL_Dropbox "\r"))
    )

    (defun init_handler ()   ;Initialation_Code
      (action_tile "DCLButton1" "(done_dialog)(DCLButton1_Action)")
      (action_tile "DCLButton2" "(done_dialog)(DCLButton2_Action)")
      (princ)
    );End of Initial Function


    (defun LoadDialog_ABOUT_IXM_PLUG_INS( / dcl_id)
      (if (setq dcl_id (load_dialog (sr:createAboutDialog str_IXMP_version str_ODCL_version)))
        (if (new_dialog "ABOUT_IXM_PLUG_INS" dcl_id)
            (progn
              (setq result nil)
              (init_handler)
              (action_tile "accept" "(done_dialog)")
              (start_dialog)
              (unload_dialog dcl_id)
            )
          )
      )
    )
    (LoadDialog_ABOUT_IXM_PLUG_INS)
        
    (vla-EndUndoMark (actvDoc))
    (princ)
)

(defun c:HELP_IXM_PLUG_INS (/ *error*)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
  )
  (vla-StartUndoMark (actvDoc))
    
  (setq file_help_pdf (strcat "file:///" (f:GetPlugInPath "*IMPACT XM PLUG-INS.BUNDLE*") "Help/ImpactXMPlugInsHelp.pdf")
        new "%20"
        old " "
        len (strlen new)
        inc 0
  )
  (while (setq inc (vl-string-search old file_help_pdf inc))
      (setq file_help_pdf (vl-string-subst new old file_help_pdf inc)
            inc (+ inc len)
      )
  )

  (vla-SendCommand (actvDoc) (strcat "BROWSER\r" file_help_pdf "\r"))
    
  (vla-EndUndoMark (actvDoc))
  (princ)
)
