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


(defun c:CONVERT_TB_TO_SHEET_SET ( / sa)
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))

  (setq sa (d:SingleOrAll))
  (cond
    ((= sa 1) (f:SheetSetTitleBlock T T))
    ((= sa 2) (f:SheetSetTitleBlock T nil))
  )
  (vla-EndUndoMark (actvDoc))
  (princ)

)

(defun c:CONVERT_TB_TO_NORMAL ()
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))

  (setq sa (d:SingleOrAll))
  (cond
    ((= sa 1) (f:SheetSetTitleBlock nil T))
    ((= sa 2) (f:SheetSetTitleBlock nil nil))
  )
  
  (vla-EndUndoMark (actvDoc))
  (princ)
)

(defun c:-CONVERT_TB_TO_SHEET_SET ( / sa)
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))

  (initget "Single All")
  (setq sa (getkword "\nSingle or All? [Single/All] <All>:"))
  (cond
    ((= sa "Single")               (f:SheetSetTitleBlock T T))
    ((or (not sa) (= sa "All"))    (f:SheetSetTitleBlock T nil))
  )
  
  (vla-EndUndoMark (actvDoc))
  (princ)
)

(defun c:-CONVERT_TB_TO_NORMAL ( / sa)
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))

  (initget "Single All")
  (setq sa (getkword "\nSingle or All? [Single/All] <All>:"))
  (cond
    ((= sa "Single")               (f:SheetSetTitleBlock nil T))
    ((or (not sa) (= sa "All"))    (f:SheetSetTitleBlock nil nil))
  )
  
  (vla-EndUndoMark (actvDoc))
  (princ)
)

(defun f:ConvertTbToNoPages ( / sa)
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))

  (f:SheetSetTitleBlock 0 nil)
  
  
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

;;;----------------------
;;;  SOME DATA
;;;----------------------
;|
    01-CLIENT
    02-PROJECT #
    03-SHOW NAME
    04-SHOW LOCATION
    05-SHOW DATES
    06-SHIP DATE
    07-BOOTH #
    08-PM
    09-DETAILER
    10-TOTAL SHEETS
    11-REVISION
|;
  

  (setq SheetSetAttr
         '(
            ("CLIENT"              . "%<\\AcSm SheetSet.01-CLIENT \\f \"%tc1\">%")
            ("PROJECT_NO"          . "%<\\AcSm SheetSet.02-PROJECT # \\f \"%tc1\">%")
            ("SHOW"                . "%<\\AcSm SheetSet.03-SHOW NAME \\f \"%tc1\">%")
            ("LOCATION"            . "%<\\AcSm SheetSet.04-SHOW LOCATION \\f \"%tc1\">%")
            ("SHOWDATE"            . "%<\\AcSm SheetSet.05-SHOW DATES \\f \"%tc1\">%")
            ("SHIP_DATE"           . "%<\\AcSm SheetSet.06-SHIP DATE \\f \"%tc1\">%")
            ("BOOTH_NO"            . "%<\\AcSm SheetSet.07-BOOTH # \\f \"%tc1\">%")
            ("PM"                  . "%<\\AcSm SheetSet.08-PM \\f \"%tc1\">%")
            ("DET"                 . "%<\\AcSm SheetSet.09-DETAILER \\f \"%tc1\">%")
            ("REV"                 . "%<\\AcSm SheetSet.11-REVISION \\f \"%tc1\">%")
            ("CAD_DWG_TITLE"       . "%<$(substr,$(getvar, \"dwgname\"),11,$(-,$(strlen,$(getvar,\"dwgname\")),17))>%")
            ("PAGE_TITLE"          . "%<$(substr,$(getvar, \"ctab\"),4)>%")
            ("SHEET_NO"            . "%<\\AcSm Sheet.Number \\f \"%tc1\">%")
            ("TOTAL_SHEETS"        . "%<\\AcSm SheetSet.10-TOTAL SHEETS \\f \"%tc1\">%")
          )
  )

  (setq NonSheetSetAttr
         '(
            ("CLIENT"              . "-")
            ("PROJECT_NO"          . "-")
            ("SHOW"                . "-")
            ("LOCATION"            . "-")
            ("SHOWDATE"            . "-")
            ("SHIP_DATE"           . "-")
            ("BOOTH_NO"            . "-")
            ("PM"                  . "-")
            ("DET"                 . "-")
            ("REV"                 . "%<$(substr,$(getvar, \"dwgname\"),$(-,$(strlen,$(getvar,\"dwgname\")),5),2)>%")
            ("CAD_DWG_TITLE"       . "%<$(substr,$(getvar, \"dwgname\"),11,$(-,$(strlen,$(getvar,\"dwgname\")),17))>%")
            ("PAGE_TITLE"          . "%<$(substr,$(getvar, \"ctab\"),4)>%" )
            ;("SHEET_NO"            . "%<$(substr,$(getvar, \"ctab\"),1,2)>%" )
            ("SHEET_NO"            . "")
            ("TOTAL_SHEETS"        . "")
          )
  )

  (setq NoPageNumbers
         '(
            ("REV"                 . "%<$(substr,$(getvar, \"dwgname\"),$(-,$(strlen,$(getvar,\"dwgname\")),5),2)>%")
            ("CAD_DWG_TITLE"       . "%<$(substr,$(getvar, \"dwgname\"),11,$(-,$(strlen,$(getvar,\"dwgname\")),17))>%")
            ("SHEET_NO"            . "")
            ("TOTAL_SHEETS"        . "")
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
                    (not (f:GetTitleBlockVersion
                           (vlax-ename->vla-object (ssname ssAll 0))
                         )
                    )
                     0.0
                     (ATOF (f:GetTitleBlockVersion
                             (vlax-ename->vla-object (ssname ssAll 0))
                           )
                     )
                  ) ;end if
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
       (= (f:GetEffectiveBlockName (vlax-ename->vla-object e)) "@COMBINED-TITLE BLOCK-02")
        (progn
          (cond
            ((= sheetSet 0)
              (f:SetAttributeValues (vlax-ename->vla-object e) NoPageNumbers)
            )
            ((= sheetSet T)
              (f:SetAttributeValues (vlax-ename->vla-object e) SheetSetAttr)
            )
            ((= sheetSet nil)
              (f:SetAttributeValues (vlax-ename->vla-object e) NonSheetSetAttr)
            )
          )
          (command-s "regenall")
        )
     )
  )
	(princ)
)


(defun d:SingleOrAll (/ fname fn dcl_id ddiag)
  (progn
    (setq fname (vl-filename-mktemp "dcl.dcl"))
    (setq fn (open fname "w"))
    (write-line
      "ConvShSet
			: dialog {
			    label = \"Convert to Sheet Set Title Block\" ;
			: row {
			    : button {
			        label = \"Single\";
			        key = \"single\";
			        mnemonic = \"S\";
			        alignment = centered;
			        is_default = true;
			        width = 10; }
			    : button {
			        label = \"All\";
			        key = \"all\";
			        mnemonic = \"S\";
			        alignment = centered;
			        width = 10; }
			    : button {
			        label = \"Cancel\";
			        key = \"canel\";
			        mnemonic = \"C\";
			        alignment = centered;
			        is_cancel = true;
			        width = 10; }
			    }
			}"
      fn
    )
    (close fn)
  )

  (setq dcl_id (load_dialog fname))
  (if (not (new_dialog "ConvShSet" dcl_id))
    (exit)
  )

  (progn
    (action_tile "single" "(done_dialog 1)")
    (action_tile "all" "(done_dialog 2)")
    (setq ddiag (start_dialog))
    (unload_dialog dcl_id)
  )
  (vl-file-delete fname)
  ddiag
)
;
;(princ "\n\nFor converting TBlocks to sheet set attributes and manual fill attributes.")
;(princ "\n\nCommands to run:")
;(princ "\n\n    CONVERT_TB_TO_SHEET_SET (dialog version)")
;(princ   "\n    CONVERT_TB_TO_NORMAL    (dialog version)")
;(princ "\n\n   -CONVERT_TB_TO_SHEET_SET (commandline version, no dialog)")
;(princ   "\n   -CONVERT_TB_TO_NORMAL    (commandline version, no dialog)")
(princ "\n")
(princ)


;(f:ConvertTbToNoPages)