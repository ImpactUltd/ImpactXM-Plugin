;PURGES EVERYTHING THAT CAN BE PURGED WITH ONE COMMAND

(defun c:QP ()
  (setq test nil)
  (while (not test) 
    (setq test T)
    (command "-PURGE" "ALL")
    (if (getvar "WRITESTAT") 
      (command "*" "Yes")
    )
    (while (= 1 (logand 1 (getvar "CMDACTIVE"))) 
      ;keep answering 'yes' as long as it asks
      (command "_Yes")
      (setq test nil)
    )
  )
)



;;Computer\HKEY_CURRENT_USER\Software\Autodesk\AutoCAD\R24.2\ACAD-6101:409\Profiles\<<Unnamed Profile>>\Dialogs\PurgeDialog