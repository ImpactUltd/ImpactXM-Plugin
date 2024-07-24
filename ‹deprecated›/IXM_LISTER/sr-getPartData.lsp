(progn
  (setq str_data1 
        str_data2
        list_data1 (string->list "PART-02, 0.75 PLY, " ", ")
        list_data2 (string->list "PART-03, 0.75 PLY, LM 949 1S" ", ")
  )
  (princ "\nlist_data1: ") (prin1 list_data1)
  (princ "\nlist_data2: ") (prin1 list_data2)
  (princ)
)
