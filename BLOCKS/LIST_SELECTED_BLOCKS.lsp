(defun c:LIST_SELECTED_BLOCKS (/ *error* list_blocks ent_block list_names name_str )
  (defun *error* ( msg )
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )  
    (vla-EndUndoMark (actvDoc))
      (princ)
    )
  (vla-StartUndoMark (actvDoc))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
  (setq list_blocks (SelectionSet->objList (ssget '((0 . "INSERT")))))
  (foreach ent_block list_blocks
    (setq list_names (cons (vla-get-Name ent_block) list_names))
  )
  (setq list_names (acad_strlsort list_names))
  (foreach name_str list_names
    (princ "\n  ") (princ name_str)
  )
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
  (vla-EndUndoMark (actvDoc))
  (princ)
)
