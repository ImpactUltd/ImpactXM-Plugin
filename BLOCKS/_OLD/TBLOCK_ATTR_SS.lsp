;;;****************************************************************************
;;;
;;;   COMMAND SUMMARY
;;;
;;;   * IN PAPER SPACE *
;;;
;;;   CONVERT_TB_TO_SHEET_SET
;;;     Modifies a single (or all) Title Blocks for use with the  
;;;     Sheet Set Manager by replacing all attributes with Sheet Set Fields.
;;;
;;;   CONVERT_TB_TO_NORMAL
;;;     Returns a single (or all) Title Block to initial state with editable 
;;;     attributes
;;;
;;;
;;;****************************************************************************

;(initget "Yes No")
;(setq del (getkword "\nDelete source objects? [Yes / No] <No>:"))

(defun c:UPDATE_TB_SS_TO_SHEET_SET ( / sa)
  (SheetSetTitleBlock T nil)
)


;;;============================================================================
;;; Begin SheetSetTitleBlock
;;;============================================================================
(defun SheetSetTitleBlock (sheetSet
                           single
                           /
                           ss
                           blockName
                           ss2
                           GetEffectiveBlockName
                           GetTitleBlockVersion
                           SetAttributeValues
                           SheetSetAttr
                          )

;;;----------------------
;;;  SOME FUNCTIONS
;;;----------------------
  (defun GetEffectiveBlockName (obj)
    (vlax-get-property
      obj
      (if (vlax-property-available-p obj 'effectivename)
        'effectivename
        'name
      )
    )
  )
  (defun GetTitleBlockVersion (blk)
    (setq tag "TITLE_BLOCK_VERSION")
    (vl-some '(lambda (att)
                (if (= tag (strcase (vla-get-tagstring att)))
                  (vla-get-textstring att)
                )
              )
             (vlax-invoke blk 'getconstantattributes)
    )
  )

  (defun SetAttributeValues (blk lst / itm)
    (foreach att (vlax-invoke blk 'getattributes)
      (if (setq itm (assoc (vla-get-tagstring att) lst))
        (vla-put-textstring att (cdr itm))
      )
    )
  )

;;;----------------------
;;;  SOME DATA
;;;----------------------
  (setq SheetSetAttr
         '(
           ("CLIENT"                 .  "%<\\AcSm SheetSet.01-CLIENT        \\f \"%tc1\">%")
           ("PROJECT_NO"             .  "%<\\AcSm SheetSet.02-PROJECT #     \\f \"%tc1\">%")
           ("SHOW"                   .  "%<\\AcSm SheetSet.03-SHOW NAME     \\f \"%tc1\">%")
           ("LOCATION"               .  "%<\\AcSm SheetSet.04-SHOW LOCATION \\f \"%tc1\">%")
           ("SHOWDATE"               .  "%<\\AcSm SheetSet.05-SHOW DATES    \\f \"%tc1\">%")
           ("SHIP_DATE"              .  "%<\\AcSm SheetSet.06-SHIP DATE     \\f \"%tc1\">%")
           ("BOOTH_NO"               .  "%<\\AcSm SheetSet.07-BOOTH #       \\f \"%tc1\">%")
           ("PM"                     .  "%<\\AcSm SheetSet.08-PM            \\f \"%tc1\">%")
           ("DET"                    .  "%<\\AcSm SheetSet.09-DETAILER      \\f \"%tc1\">%")
           ("REV"                    .  "%<\\AcSm SheetSet.11-REVISION      \\f \"%tc1\">%")
           ("CAD_DWG_TITLE"          .  "%<$(substr,$(getvar, \"dwgname\"),11,$(-,$(strlen,$(getvar,\"dwgname\")),17))>%")
           ("PAGE_TITLE"             .  "%<$(substr,$(getvar, \"ctab\"),7)>%")
           ("SHEET_NO"               .  "%<\\AcSm Sheet.Number \\f \"%tc1\">%")
           ("DATE:"                  .  "%<\\AcVar PlotDate \\f \"MM/dd/yy\">%")
           ("TIME"                   .  "%<\\AcVar PlotDate \\f \"h:mm tt\">%")
           ("TOTAL_SHEETS"           .  "")
           ;("ORIGINAL_PROJECT_NO"    .  "-")
          )
  )


;;;----------------------
;;;  MAIN ROUTINE
;;;----------------------   
  (if single
    (progn
      (setq ssAll nil)
      (while (not ssAll)
        (if
          (setq ssAll (ssget ":S:E" '((0 . "INSERT"))))
           (if
             (= (vla-get-effectivename (vlax-ename->vla-object (ssname ssAll 0)))
                "@COMBINED-TITLE BLOCK-02"
             )
              (if
                (<=
                  2.5
                  (if
                    (not (GetTitleBlockVersion
                           (vlax-ename->vla-object (ssname ssAll 0))
                         )
                    )
                     0.0
                     (ATOF (GetTitleBlockVersion
                             (vlax-ename->vla-object (ssname ssAll 0))
                           )
                     )
                  ) 
                )
                 (princ "\nTitle Block and Version Verified.")
                 (progn
                   (alert
                     "Incompatible version of \"@COMBINED-TITLE BLOCK-02\". \nPlease redefine with the latest."
                   )
                 )
              )
              (progn
                (alert "Invalid Block. Block must be \"@COMBINED-TITLE BLOCK-02\""
                )
                (setq ssAll nil)
              )
           ) ;end if
           (alert "Please select a Title Block.")
        ) ;end if
      ) ;end while
    )
    (setq ssAll (ssget "_X" '((0 . "INSERT"))))
  )

  
  (setq n -1)
  
  (while
    (setq e (ssname ssAll (setq n (1+ n))))
     (if
       (= (GetEffectiveBlockName (vlax-ename->vla-object e)) "@COMBINED-TITLE BLOCK-02")
        (progn
          (if sheetSet
            (SetAttributeValues
              (vlax-ename->vla-object e)
              SheetSetAttr
            )
            (SetAttributeValues
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
