(defun c:PURGE_ALL( / test *error* )
  (defun *error* (s)
    (princ s)
    (princ)
  )
  
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
  
  (princ)
)

