(defun c:UPDATE_IXM_TBLOCK (/ obj_entity obj_block_name obj_block list_TB_BlockRefs list_objBlockRefs list_blockAttribs 
                            f:getAttribsFromBlockRef f:fieldCode f:ObjectID f:fieldCodeX f:putFieldCode f:updateAttributes f:updateMTexts
                            *error*)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
    (setvar "cmdecho" var_cmdecho)
  )
  
  (vla-StartUndoMark (actvDoc))
  (setq var_cmdecho (getvar "cmdecho"))
  (setvar "cmdecho" 0)

  (defun f:getAttribsFromBlockRef (obj_blockRef / list_X)
    (setq list_X (vlax-safearray->list (variant-value (vla-GetAttributes obj_blockRef))))
    list_X
  )

  (defun f:fieldCode ( ent / replacefield replaceobject fieldstring enx )
    (defun replacefield ( str enx / ent fld pos )
      (if (setq pos (vl-string-search "\\_FldIdx" (setq str (replaceobject str enx))))
        (progn
          (setq ent (assoc 360 enx)
                fld (entget (cdr ent))
          )
          (strcat
            (substr str 1 pos)
            (replacefield (fieldstring fld) fld)
            (replacefield (substr str (1+ (vl-string-search ">%" str pos))) (cdr (member ent enx)))
          )
        )
        str
      )
    )
    (defun replaceobject ( str enx / ent pos )
      (if (setq pos (vl-string-search "ObjIdx" str))
        (strcat
          (substr str 1 (+ pos 5)) " "
          (f:ObjectID (vlax-ename->vla-object (cdr (setq ent (assoc 331 enx)))))
          (replaceobject (substr str (1+ (vl-string-search ">%" str pos))) (cdr (member ent enx)))
        )
        str
      )
    )
    (defun fieldstring ( enx / itm )
      (if (setq itm (assoc 3 enx))
        (strcat (fieldstring (cdr (member itm enx))))
        (cond ((cdr (assoc 2 enx))) (""))
      )
    )
    (if (and (wcmatch  (cdr (assoc 0 (setq enx (entget ent)))) "TEXT,MTEXT,ATTRIB,MULTILEADER,*DIMENSION")
        (setq enx (cdr (assoc 360 enx)))
        (setq enx (dictsearch enx "ACAD_FIELD"))
        (setq enx (dictsearch (cdr (assoc -1 enx)) "TEXT"))
      )
      (vl-string-subst "" "AcDiesel " (replacefield (fieldstring enx) enx) 2)
    )
  )

  (defun f:fieldCodeX (obj)
    (f:fieldCode (vlax-vla-object->ename obj))
  )

  (defun f:putFieldCode (obj_mtext str_field / elemname elemdata elemnamevla tval dict)
    (setq elemname (vlax-vla-object->ename obj_mtext))
    (setq elemdata (entget elemname))
    (setq tval (cdr (assoc 1 elemdata)))
    (setq dict (vlax-vla-object->ename (vla-GetExtensionDictionary (vlax-ename->vla-object elemname))))
    (setq flst (entget (cdr (assoc 360 (entget (cdr (last (dictnext dict "ACAD_FIELD"))))))))					
    (setq fexp (cdr (assoc 2 flst)))
    (setq flst (subst (cons 2 str_field) (assoc 2 flst) flst))
    (entmod flst)
    (setq elemnamevla (vlax-ename->vla-object elemname))
    (vla-put-TextString elemnamevla (vla-FieldCode elemnamevla))
  )

  (defun f:updateAttributes ()
    (setq list_objBlockRefs (SelectionSet->objList (ssget "_X" '((0 . "INSERT")))))
    (foreach obj_BlockRef list_objBlockRefs
      (if (= (vla-get-EffectiveName obj_BlockRef) "@COMBINED-TITLE BLOCK-02")
        (setq list_TB_BlockRefs (cons obj_BlockRef list_TB_BlockRefs))
      )
    )

    (foreach obj_BlockRef list_TB_BlockRefs
      (setq list_blockAttribs (f:getAttribsFromBlockRef obj_BlockRef))
      (foreach obj_Attrib list_blockAttribs
        (cond
          ((= (vla-get-TagString obj_Attrib) "REV")
            ;(print "REV FOUND")
            (vla-put-TextString obj_Attrib "%<$(substr,$(getvar, \"dwgname\"),$(-,$(strlen,$(getvar,\"dwgname\")),5),2)>%")
          )
          ((= (vla-get-TagString obj_Attrib) "CAD_DWG_TITLE")
            ;(print "CAD_DWG_TITLE FOUND")
            (vla-put-TextString obj_Attrib "%<$(substr,$(getvar, \"dwgname\"),11,$(-,$(strlen,$(getvar,\"dwgname\")),17))>%")
          )
        )
      )
      (vla-Update obj_BlockRef)      ; update the block
      (if (>= (cl:GetDynPropValue obj_BlockRef "Block Table1" ) 3)
          (progn
            (command "RESETBLOCK" (vlax-vla-object->ename obj_BlockRef) "")
            (cl:SetDynPropValue  obj_BlockRef "Block Table1" 3 ) 
          )
      )
    )
  )

  (defun f:updateMTexts ( / )
    (setq obj_block_name "@COMBINED-TITLE BLOCK-02"
          obj_block (vla-Item (vla-get-Blocks (actvDoc)) obj_block_name)
    );setq
    (vlax-for obj_entity obj_block
      (cond 
        ((and (= (vla-get-ObjectName obj_entity) "AcDbMText") 
              (= (f:fieldCodeX obj_entity) "%<\\$(substr,$(getvar, \"dwgname\"),14,$(-,$(strlen,$(getvar,\"dwgname\")),17))>%"))
          ;(print "CAD_DWG_TITLE FOUND")
          (f:putFieldCode obj_entity "%<\\AcDiesel $(substr,$(getvar, \"dwgname\"),11,$(-,$(strlen,$(getvar,\"dwgname\")),17))>%")
        )        
        ((and (= (vla-get-ObjectName obj_entity) "AcDbMText") 
              (= (f:fieldCodeX obj_entity) "%<\\$(substr,$(getvar, \"dwgname\"),11,2)>%"))
          ;(print "REV FOUND")
          (f:putFieldCode obj_entity "%<\\AcDiesel $(substr,$(getvar, \"dwgname\"),$(-,$(strlen,$(getvar,\"dwgname\")),5),2)>%")
        )
      )      
    );vlax-for
  )
  
  (f:updateMTexts)
  (f:updateAttributes)
  (setvar "cmdecho" var_cmdecho)

  (vla-Regen (actvDoc) acActiveViewport)
  (vla-EndUndoMark (actvDoc))
  (princ)
);defun


;; REV (old)
;; %<\AcDiesel $(substr,$(getvar, "dwgname"),11,2)>%
;;
;; CAD_DWG_TITLE (old)
;; %<\AcDiesel $(substr,$(getvar, "dwgname"),14,$(-,$(strlen,$(getvar,"dwgname")),17))>%
;;
;;
;; REV 
;; %<$(substr,$(getvar, "dwgname"),$(-,$(strlen,$(getvar,"dwgname")),5),2)>%
;;
;; CAD_DWG_TITLE 
;; %<$(substr,$(getvar, "dwgname"),11,$(-,$(strlen,$(getvar,"dwgname")),17))>%
;;



