
(defun f:dynamic->static (str_prefix obj_block  / *error* sub:RandomName sel_set ent_sel 
                          done
                         ) 
  (defun *error* (s) 
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )

  (defun sub:RandomName (/ sub:RandomChr listChr num) 

    (defun sub:RandomChr (/ a c m) 
      (setq m   4294967296.0
            a   1664525.0
            c   1013904223.0
            $xn (rem (+ c (* a (cond ($xn) ((getvar 'date))))) m)
      )
      (+ 48 (fix (* (/ $xn m) 43)))
    )
    ; Begin list of characters (eventually to be reversed )
    (setq listChr (list 95))
    (setq num (sub:RandomChr))
    (while (< (length listChr) 11) 
      (if (and (>= num 58) (<= num 64)) 
        (setq num (sub:RandomChr))
        (progn 
          (setq listChr (cons num listChr))
          (setq num (sub:RandomChr))
        )
      )
    )
    (strcat str_prefix (vl-list->string (reverse listChr)))
  )

  (setq str_BlockName (sub:RandomName))

  (vla-ConvertToStaticBlock obj_block str_BlockName)

  (setq obj_newBlock (vla-Item (vla-get-Blocks (actvDoc)) str_BlockName))
  (princ "\nDeleting invisible objects from block .")
  (vlax-for obj_x obj_newBlock 

    (if (eq (vla-get-Visible obj_x) :vlax-false) 
      (progn 
        (vl-catch-all-apply 'vla-delete (list obj_x))
        (princ ".")
      )
      (princ "o")
    )
  )
  str_BlockName
)

(defun c:DYNAMIC_TO_STATIC (/ *error* sel_set ent_sel obj_BlockRef func_run done) 

  (defun *error* (s) 
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )

  (vla-StartUndoMark (actvDoc))

  ; collect anything selected
  (setq sel_set (last (ssgetfirst)))
  ; check if a single block is selected
  (if 
    (and sel_set 
         (= (sslength sel_set) 1)
         (wcmatch (cdr (assoc 0 (entget (ssname sel_set 0)))) "INSERT")
    )
    (progn 
      (setq obj_BlockRef (vlax-ename->vla-object (ssname sel_set 0)))
      (if (eq :vlax-true (vla-get-IsDynamicBlock obj_BlockRef)) 
        (f:dynamic->static "Σ" obj_BlockRef)
        (princ "\nBlock not DYNAMIC. Ignoring.")
      )
    )
    (while (not done) 
      (setq ent_sel (entsel "Select a block to rename:"))
      (if (wcmatch (cdr (assoc 0 (entget (car ent_sel)))) "INSERT") 
        (progn 
          (setq obj_BlockRef (vlax-ename->vla-object (car ent_sel)))
          (if (eq :vlax-true (vla-get-IsDynamicBlock obj_BlockRef) ) 
            (f:dynamic->static "Σ" obj_BlockRef)
            (princ "\nBlock not DYNAMIC. Ignoring.")
          )
          (setq done T)
        )
        (princ "\nBlock not selected, try again.")
      )
    )
  )

  (vla-EndUndoMark (actvDoc))

  (princ)
)
 