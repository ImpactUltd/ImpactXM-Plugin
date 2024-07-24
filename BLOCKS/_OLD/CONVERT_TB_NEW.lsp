
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

(defun f:tblk-attr-to-classic ( / sa)
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))
  
    (f:SheetSetTitleBlock nil nil)
  
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

;;;----------------------
;;;  SOME FUNCTIONS
;;;----------------------
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
           ("CLIENT"          . "%<\\AcSm SheetSet.01-CLIENT \\f \"%tc1\">%")
           ("PROJECT_NO"      . "%<\\AcSm SheetSet.02-PROJECT # \\f \"%tc1\">%")
           ("SHOW"            . "%<\\AcSm SheetSet.03-SHOW NAME \\f \"%tc1\">%")
           ("LOCATION"        . "%<\\AcSm SheetSet.04-SHOW LOCATION \\f \"%tc1\">%")
           ("SHOWDATE"        . "%<\\AcSm SheetSet.05-SHOW DATES \\f \"%tc1\">%")
           ("SHIP_DATE"       . "%<\\AcSm SheetSet.06-SHIP DATE \\f \"%tc1\">%")
           ("BOOTH_NO"        . "%<\\AcSm SheetSet.07-BOOTH # \\f \"%tc1\">%")
           ("PM"              . "%<\\AcSm SheetSet.08-PM \\f \"%tc1\">%")
           ("DET"             . "%<\\AcSm SheetSet.09-DETAILER \\f \"%tc1\">%")
           ("REV"             . "%<\\AcSm SheetSet.11-REVISION \\f \"%tc1\">%")
           ("CAD_DWG_TITLE"   . "%<$(substr,$(getvar, \"dwgname\"),11,$(-,$(strlen,$(getvar,\"dwgname\")),17))>%")
           ("PAGE_TITLE"      . "%<$(substr,$(getvar, \"ctab\"),7)>%")
           ("SHEET_NO"        . "%<\\AcSm Sheet.Number \\f \"%tc1\">%")
          ;("DATE"            . "%<\\AcVar PlotDate \\f \"MM/dd/yy\">%")
          ;("TIME"            . "%<\\AcVar PlotDate \\f \"h:mm tt\">%")
          )
  )

  (setq NonSheetSetAttr
         '(
           ("CLIENT"          . "-")
           ("PROJECT_NO"      . "-")
           ("SHOW"            . "-")
           ("LOCATION"        . "-")
           ("SHOWDATE"        . "-")
           ("SHIP_DATE"       . "-")
           ("BOOTH_NO"        . "-")
           ("PM"              . "-")
           ("DET"             . "-")
           ("REV"             . "%<$(substr,$(getvar, \"dwgname\"),$(-,$(strlen,$(getvar,\"dwgname\")),5),2)>%")
           ("CAD_DWG_TITLE"   . "%<$(substr,$(getvar, \"dwgname\"),11,$(-,$(strlen,$(getvar,\"dwgname\")),17))>%")
           ("PAGE_TITLE"      . "%<$(substr,$(getvar, \"ctab\"),7)>%" )
           ("SHEET_NO"        . "%<$(substr,$(getvar, \"ctab\"),4,2)>%" )
          ;("DATE"            . "%<\\AcVar PlotDate \\f \"MM/dd/yy\">%")
          ;("TIME"            . "%<\\AcVar PlotDate \\f \"h:mm tt\">%")
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
