(defun c:WBLOCK_MULTIPLE (/ *error* sset_blocks list_obj_blocks list_name_blocks)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
  )
  (vla-StartUndoMark (actvDoc))
    
  (setq sset_blocks (ssget '((0 . "INSERT")))
        list_obj_blocks (SelectionSet->objList sset_blocks)
  )

  (foreach obj_block list_obj_blocks 
    (setq name_block (cl:GetEffectiveBlockName obj_block)
          list_name_blocks (cons-unique name_block list_name_blocks))
  )
  
  (setq destFolderPath (f:browse-for-folder "Destination Folder for Blocks" nil 512))
  
  (if destFolderPath
      (progn
        (princ "\n  Exporting:")
        (foreach name_block list_name_blocks
          (princ (strcat "\n    " (pad-str nameBlock "" " " 14) " to " (strcat destFolderPath "\\" name_block)))
          (command-s "-WBLOCK" (strcat destFolderPath "\\" name_block) "=")
        )
      )
  )

  (vla-EndUndoMark (actvDoc))
  (princ)
)
