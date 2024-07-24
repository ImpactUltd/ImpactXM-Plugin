(defun c:XREF_FORMAT_LAYER_BLOCK_NAMES (/ *error* list_block_names sset_xrefs list_xrefs obj_xref block_name block_obj)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
  )
  (vla-StartUndoMark (actvDoc))
    
  (setq sset_xrefs (ssget '((0 . "INSERT")))
        list_xrefs (SelectionSet->objList sset_xrefs))
  
  (foreach obj_xref list_xrefs
    (setq block_name (vla-get-Name obj_xref)
          block_obj  (vla-Item (vla-get-Blocks (actvDoc)) block_name))

    (if (wcmatch block_name "Xref-*")
      (setq block_name_new block_name)
      (setq block_name_new (strcat "Xref-" block_name))
    )
          
    (if (= (vla-get-IsXRef block_obj) :vlax-true)
      (progn
        (if (not (tblsearch "LAYER" block_name_new))
          (vla-Add (vla-get-Layers (actvDoc)) block_name_new)
        )
        (vla-put-Layer obj_xref block_name_new)
      )
    )
  )

  (foreach obj_xref list_xrefs
    (setq list_block_names (consU (vla-get-Name obj_xref) list_block_names))
  )
  
  (foreach block_name list_block_names
    (setq block_obj      (vla-Item (vla-get-Blocks (actvDoc)) block_name))
    (if (wcmatch block_name "Xref-*" )
      (setq block_name_new block_name)
      (setq block_name_new (strcat "Xref-" block_name))
    )
          
    (if (= (vla-get-IsXRef block_obj) :vlax-true)
      (vla-put-Name  block_obj  block_name_new)
    )
  )
  (vla-Regen (actvDoc) :vlax-true)
  (vla-EndUndoMark (actvDoc))
  (princ)
)
