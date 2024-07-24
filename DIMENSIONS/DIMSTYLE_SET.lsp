(defun c:DIMSTYLE_SET_BY_SEL (/ *error* dim_selected)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
    (setvar "selectioncycling" sysvar_selectioncycling)
  )
  (vla-StartUndoMark (actvDoc))
  (setq sysvar_selectioncycling (getvar "selectioncycling"))
  (setvar "selectioncycling" 0)

  (while (not dim_selected)
    (if (and (setq ent_dim (entsel "\nSelect Dimension to update Current Dimstyle:"))
             (setq obj_dim (vlax-ename->vla-object (car ent_dim)))
             (wcmatch (vla-get-ObjectName obj_dim) "*Dimension*"))
      (progn
        (setq name_dimStyle (vla-get-StyleName obj_dim))
        (setq obj_dimStyle  (vla-Item (vla-get-DimStyles (actvDoc)) name_dimStyle))
        ;(princ "\nobj_dimStyle: ") (prin1 obj_dimStyle)
        (vla-put-ActiveDimStyle (actvDoc) obj_dimStyle)
        (princ "\nCurrent DIMSTYLE set to ")
        (princ name_dimStyle)
        (setq dim_selected T)
      )
    );if
  );while

  (setvar "selectioncycling" sysvar_selectioncycling)
    
  (vla-EndUndoMark (actvDoc))
  (princ)
)