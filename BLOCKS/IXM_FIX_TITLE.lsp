(defun f:tblk-attr-sheetset ( / sa)
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))

    (f:SheetSetTitleBlock T nil)
  
  (vla-EndUndoMark (actvDoc))
  (princ)
)




;;;============================================================================
;;; Begin f:SheetSetTitleBlock
;;;============================================================================
(defun f:SheetSetTitleBlock (sheetSet
                           single
                           /
                           ss
                           blockName
                           ss2
                           f:GetEffectiveBlockName
                           f:GetTitleBlockVersion
                           f:SetAttributeValues
                          )

  (defun f:GetEffectiveBlockName (obj)
    (vlax-get-property
      obj
      (if (vlax-property-available-p obj 'effectivename)
        'effectivename
        'name
      )
    )
  )
  (defun f:GetTitleBlockVersion (blk)
    (setq tag "TITLE_BLOCK_VERSION")
    (vl-some '(lambda (att)
                (if (= tag (strcase (vla-get-tagstring att)))
                  (vla-get-textstring att)
                )
              )
             (vlax-invoke blk 'getconstantattributes)
    )
  )

  (defun f:SetAttributeValues (blk lst / itm)
    (foreach att (vlax-invoke blk 'getattributes)
      (if (setq itm (assoc (vla-get-tagstring att) lst))
        (vla-put-textstring att (cdr itm))
      )
    )
  )

  (setq SheetSetAttr
         '(
           ("PAGE_TITLE"      . "%<$(substr,$(getvar, \"ctab\"),9)>%")
          )
  )
  
  (setq ssAll (ssget "_X" '((0 . "INSERT"))))
  
  (setq n -1)
  
  (while
    (setq e (ssname ssAll (setq n (1+ n))))
     (if
       (= (f:GetEffectiveBlockName (vlax-ename->vla-object e)) "@COMBINED-TITLE BLOCK-02")
        (progn
          (if sheetSet
            (f:SetAttributeValues
              (vlax-ename->vla-object e)
              SheetSetAttr
            )
            (f:SetAttributeValues
              (vlax-ename->vla-object e)
              NonSheetSetAttr
            )
          )
          (command-s "regenall")
        )
     )
  )
	(princ)
)



;|
  description
  @Param tb_ss nil = CLASSIC ; T = SHEETSET
  @Returns Inserts IXM Title Block accrding to version and Layout Tab
|;

(defun f:Fix-IXM-Title ( tb_ss / paperspace modelspace TBlk_exists count index obj_item *error* )
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))
  
  (setq paperspace  nil
        modelspace  nil
        TBlk_exists nil
  )
  
    
  (if (= (getvar "tilemode") 0)
    (setq paperspace T)
    (setq modelspace T)
  )
  
  ;; CHECK IF THERE IS A TITLE BLOCK IN LAYOUT
  (if paperspace
    (progn
      (setq TBlk_exists nil
            count (vla-get-Count (vla-get-paperspace (vla-get-activedocument (vlax-get-acad-object))))
            index 0)
      (while (>= (1- count) index)
        (setq obj_item (vla-Item (vla-get-paperspace (vla-get-activedocument (vlax-get-acad-object))) index))
        
        (if (= (vla-get-objectname obj_item) "AcDbBlockReference")
          (if (= (vla-get-effectivename obj_item) "@COMBINED-TITLE BLOCK-02")
            (setq TBlk_exists T)
          )
        )
        (if TBlk_exists
          (setq index count)
          (setq index (1+ index))
        )
      )
    );end_progn
  );end_if

     
  ;; IF ATTRIBUTES ARE FOR SHEETSET (tb_ss=T) OR CLASSIC (tb_ss=nil)
  (if tb_ss
    (f:tblk-attr-sheetset)
    (f:tblk-attr-to-classic)
  )
  
  (vla-EndUndoMark (actvDoc))
  (princ)
)


(defun c:IXM_FIX_TITLE  () (f:Fix-IXM-Title T))





