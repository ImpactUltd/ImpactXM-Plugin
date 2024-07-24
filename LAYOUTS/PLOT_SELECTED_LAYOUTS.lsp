(defun c:PLOT_SELECTED_LAYOUTS ( /  *error* 
                                num_component count_components var_CTAB var_CMDDIA var_FILEDIA var_BACKGROUNDPLOT Good tab FileNme FilePth dcl:listbox booth)
  (defun *error* (emsg)
    (if (not
          (member emsg '("Function cancelled" "quit / exit abort"))
        )
      (princ (strcat "\nError: " emsg))
    )
    (setvar 'FILEDIA        var_FILEDIA)
    (setvar 'CMDDIA         var_CMDDIA)
    (setvar 'BACKGROUNDPLOT var_BACKGROUNDPLOT)
    (setvar 'CTAB           var_CTAB)
    
    (princ)
  )

  (setq var_CTAB            (getvar 'CTAB)
        var_FILEDIA         (getvar 'FILEDIA)
        var_CMDDIA          (getvar 'CMDDIA)
        var_BACKGROUNDPLOT  (getvar 'BACKGROUNDPLOT)
  )

  (setvar "FILEDIA" 0)
  (setvar "CMDDIA" 0)
  (setvar "BACKGROUNDPLOT" 0)
  (command-s "-PLOTSTAMP" "OFF" "")

  ;; List Box
  ;; Displays a DCL list box allowing the user to make a selection from the supplied data.
  ;; msg - [str] Dialog label
  ;; lst - [lst] List of strings to display
  ;; bit - [int] 1=allow multiple; 2=return indexes
  ;; val - [int]
  ;; Returns: [lst] List of selected items/indexes, else nil

  (defun dcl:listbox (msg lst index bit / dch des tmp rtn)
    (cond
      (
       (not
         (and
           (setq tmp (vl-filename-mktemp nil nil ".dcl"))
           (setq des (open tmp "w"))
           (write-line
             (strcat "listbox:dialog{label=\""
                     msg
                     "\";spacer;:list_box{key=\"list\";multiple_select="
                     (if (= 1 (logand 1 bit))
                       "true"
                       "false"
                     )
                     ";width=50;height=15;}spacer;ok_cancel;}"
             )
             des
           )
           (not (close des))
           (< 0 (setq dch (load_dialog tmp)))
           (new_dialog "listbox" dch)
         )
       )
       (prompt "\nError Loading List Box Dialog.")
      )
      (t
       (start_list "list")
       (foreach itm lst (add_list itm))
       (end_list)
       (setq rtn (set_tile "list" index))
       (action_tile "list" "(setq rtn $value)")
       (setq rtn
              (if (= 1 (start_dialog))
                (if (= 2 (logand 2 bit))
                  (read (strcat "(" rtn ")"))
                  (mapcar '(lambda (x) (nth x lst))
                          (read (strcat "(" rtn ")"))
                  )
                )
              )
       )
      )
    )
    (if (< 0 dch)
      (unload_dialog dch)
    )
    (if (and tmp (setq tmp (findfile tmp)))
      (vl-file-delete tmp)
    )
    rtn
  ) ;; defun dcl:listbox
  (if (= var_CTAB "Model")
      (setq str_index "0")
      (setq str_index         (itoa (vl-position var_CTAB (layoutlist))))
  )
  (setq layouts           (dcl:ListBox "Select Layouts to Plot.. " (layoutlist) str_index 1)
        file_name         (vl-filename-base (getvar 'DWGNAME))
        str_component     (substr file_name 11 (strlen file_name))
        FilePth           (strcat (getvar 'DWGPREFIX) "PDF")
        list_directories  (vl-directory-files FilePth nil -1)
        count_components  0
        num_component     nil
        booth             nil
  )

  (foreach directory list_directories
    (if (wcmatch directory "####`-*")
        (setq count_components (1+ count_components))
    )
    (if (wcmatch directory (strcat "####`-" str_component))
        (setq num_component (substr directory 1 2))
    )
    (if (wcmatch directory "0000`-*")
        (setq booth "yes")
    )
  )
  (if (wcmatch (getvar 'DWGNAME) "*BOOTH CONTROL*")
        (setq num_component "00")
  )
  (if booth
    nil ;; (setq count_components (1- count_components))
    (setq count_components (1+ count_components))
  )
  (if (not num_component)
      (setq num_component (itoa count_components))
  )
  

  (foreach tab layouts
    (setvar 'CTAB tab)
    (setq FilePth (strcat (getvar 'DWGPREFIX) "PDF")
          FileNme (strcat FilePth
                          "\\"
                          (pad-str nil num_component "0" 2) "00-"
                          str_component
                          "\\"
                          (pad-str nil num_component "0" 2)
                          (substr tab 1 3)
                          file_name
                          "-"
                          tab
                  )
    )
    (setq FilePth (strcat FilePth "\\" (pad-str nil num_component "0" 2) "00-" str_component))
    (princ (strcat "\nCheck path:" FilePth "\n"))
    (princ (strcat "\nCheck file:" FileNme "\n"))
    (if (findfile FilePth)
      (progn ;; IF PATH EXISTS
        (princ (strcat "\n" FilePth " path exists."))
        (if (findfile (strcat FileNme ".pdf"))
          (progn ;; IF FILE EXISTS
            (princ (strcat "\n" "File Exists = " FileNme))
            (while (CL:IsFileReadOnly (strcat FileNme ".pdf"))
              (alert
                (strcat
                  "The file "
                  (strcat FileNme ".pdf")
                  " is open in another application, perhaps a PDF reader. \nPlease close the file and hit 'OK' to proceed."
                )
              ) ;; alert
            ) ;; while
          ) ;; progn
          (progn
            (setq FileDoesNotExists T)
            (princ (strcat "\n" "File Does Not Exist"))
          ) ;; progn
        )
      ) ;; progn
      (progn  ;; IF PATH DOES NOT EXIST (AND SO THE FILE)
        (princ
          (strcat "\n" FilePth " path does not exist. Creating path.")
        )
        (vl-mkdir (strcat (getvar 'DWGPREFIX) "PDF"))
        (vl-mkdir (strcat (getvar 'DWGPREFIX) "PDF" "\\@Old Revs"))
        (vl-mkdir FilePth)
        ;; (vl-mkdir (strcat FilePth "\\@Old Revs"))
      ) ;; progn
    )

    (command-s "ZOOM" "ALL")
    (command-s "-PLOT" "NO"             ;; Detailed plot configuration? [Yes/No]
               ""                       ;; Enter a layout name or [?] <>:
               ""                       ;; Enter a page setup name <>:
               ""                       ;; Enter an output device name or [?] <>:
               FileNme                  ;; Enter file name <>:
               "NO"                     ;; Save changes to page setup [Yes/No]?
               "YES"                    ;; proceed with plot
    )
  );; foreach

  ;; (princ "\nSelected Layouts have been plotted.")

  (setvar 'FILEDIA        var_FILEDIA)
  (setvar 'CMDDIA         var_CMDDIA)
  (setvar 'BACKGROUNDPLOT var_BACKGROUNDPLOT)
  (setvar 'CTAB           var_CTAB)
  
  (princ)
)

;; (progn
;; (setq var_CTAB (getvar 'CTAB))
;; (vl-position var_CTAB (layoutlist))
;; )
