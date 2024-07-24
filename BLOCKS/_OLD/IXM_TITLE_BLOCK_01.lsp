(setq *acadObj* nil) ; Initialize global variable
(defun acadObj ()
  (cond (*acadObj*) ; Return the cached object
    (t
      (setq *acadObj* (vlax-get-acad-object))
    )
  )
)

(setq *actvDoc* nil) ; Initialize global variable
(defun actvDoc ()
  (cond (*actvDoc*) ; Return the cached object
    (t
      (setq *actvDoc* (vla-get-ActiveDocument (acadObj)))
    )
  )
)

(setq *modelSpace* nil) ; Initialize global variable
(defun modelSpace ()
  (cond (*modelSpace*) ; Return the cached object
    (t
      (setq *modelSpace* (vla-get-ModelSpace (actvDoc)))
    )
  )
)

(setq *paperSpace* nil) ; Initialize global variable
(defun paperSpace ()
  (cond (*paperSpace*) ; Return the cached object
    (t
      (setq *paperSpace* (vla-get-PaperSpace (actvDoc)))
    )
  )
)

(defun string->list ( string delimiter / position )
    (if (setq position (vl-string-search delimiter string))
        (cons 
          (substr string 1 position) 
          (string->list (substr string (+ position 1 (strlen delimiter))) delimiter)
        )
        (list string)
    )
)

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

(defun cl:SetDynPropValues ( blk lst / itm )
    (setq lst (mapcar '(lambda ( x ) (cons (strcase (car x)) (cdr x))) lst))
    (foreach x (vlax-invoke blk 'getdynamicblockproperties)
        (if (setq itm (assoc (strcase (vla-get-propertyname x)) lst))
            (vla-put-value x (vlax-make-variant (cdr itm) (vlax-variant-type (vla-get-value x))))
        )
    )
)

(defun f:removeNth ( n l )
    (if (and l (< 0 n))
        (cons (car l) (f:removeNth (1- n) (cdr l)))
        (cdr l)
    )
)

(defun f:filetime-compare ( a b /  )

  ;; remove day of the week (3rd item) from both a & b lists
  (setq a (f:removeNth 2 a)
        b (f:removeNth 2 b)
  )
  
  (cond 
    ((not a) 0)
    ((eq (car a) (car b)) (f:filetime-compare (cdr a) (cdr b)))
    ((> (car a) (car b)) 1)
    (t -1)
  ) 
)

(defun f:getBlockPath ( fldr blck / list_path_prefix path_prefix path_plugin list_path_block bx timeStamp0 timeStamp1)
    
  (setq list_path_prefix (string->list (getvar 'ACADPREFIX) ";"))
  
  (foreach path_prefix list_path_prefix
    (setq path_prefix (strcase path_prefix)
          file_block  (strcat "\\" fldr "\\" blck)
          path_block  (car (vl-directory-files path_prefix file_block ))
    )
    (if path_block
      (setq path_block (strcat path_prefix file_block )
            list_path_block (cons path_block list_path_block)
      )
    )
  )
  ;(princ (strcat "\nFound " (itoa (length list_path_block)) " versions of " blck ". \n\nSearching for most recent version. . . \n"))
  ;(princ (strcat "\nUsing " (car list_path_block) "\n\n"))
  (while (> (length list_path_block) 1)
    (setq timeStamp0 (vl-file-systime (car  list_path_block))
          timeStamp1 (vl-file-systime (cadr list_path_block))
    )
    (setq bx (f:filetime-compare timeStamp0 timeStamp1))
    (cond 
      ((= bx 1)  ; a > b
       (setq list_path_block (f:removeNth 1 list_path_block))
      )
      ((= bx 0)  ; a == b
       (setq list_path_block (f:removeNth 1 list_path_block))
      )
      ((= bx -1) ; a < b
       (setq list_path_block (f:removeNth 0 list_path_block))
      )
    )
  )

  (car list_path_block)
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


(defun f:insert-ixm-tblock ( redefine_tblk cnc_tblk / *error* name_block name_logo obj_blockRef obj_blockLogo ent_blockRef)
    
  ; C:\Users\customer\Dropbox (Personal)\Library-tmp\Blocks\@@COMBINED Blocks\@COMBINED-TITLE BLOCK-02.dwg
  
  (if cnc_tblk
    (setq pt_get_insert (getpoint "Title Block Insertion Point:")
          pt_insertion  (vlax-3d-point (car pt_get_insert) (cadr pt_get_insert) (caddr pt_get_insert))
    )
    (setq pt_insertion (vlax-3d-point 0 0 0))
  )
  
  
  (setq name_block (f:getBlockPath "Blocks\\@@COMBINED Blocks" "@COMBINED-TITLE BLOCK-02.dwg")
        name_logo  (f:getBlockPath "Blocks\\@@COMBINED Blocks" "TBLOCK-IMPACT LOGO-02.dwg")
  )

  (if cnc_tblk
    (setq obj_blockRef  (vla-InsertBlock (vla-get-modelspace (vla-get-activedocument (vlax-get-acad-object))) pt_insertion name_block 16 16 16 0))
    (setq obj_blockRef  (vla-InsertBlock (vla-get-paperspace (vla-get-activedocument (vlax-get-acad-object))) pt_insertion name_block 1 1 1 0))
  )
  
  (setq obj_blockLogo (vla-InsertBlock (vla-get-paperspace (vla-get-activedocument (vlax-get-acad-object))) pt_insertion name_logo  1 1 1 0))
    
  (vla-Delete obj_blockLogo)
  
  (if cnc_tblk
    (cl:SetDynPropValues obj_blockRef '(("Block Table1" . "3")))
  )
  
  (if redefine_tblk 
    (progn
      (setq ent_blockRef (vlax-vla-object->ename obj_blockRef))
      (command "ATTSYNC" "SELECT" ent_blockRef "YES")
      (vla-Delete obj_blockRef)
    )
  )
  
    
  (princ)
)

;|
  description
  @Param tb_ss nil = CLASSIC ; T = SHEETSET
  @Returns Inserts IXM Title Block accrding to version and Layout Tab
|;

(defun f:Insert-IXM-TitleBlock ( tb_ss / paperspace modelspace TBlk_exists count index obj_item *error* )
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

  ;; IF IN MODEL SPACE THEN JUST INSERT CNC TITLE BLOCK (redefine_tblk=T cnc_tblk=T)
  (if modelspace
    (f:insert-ixm-tblock nil T)
  )

  ;; IF TITLE BLOCK EXISTS IN LAYOUT THEN REDEFINE BLOCK ONLY (redefine_tblk=T cnc_tblk=nil)
  (if (and TBlk_exists paperspace) 
    (f:insert-ixm-tblock T nil)
  )
  
  ;; IF NO TITLE BLOCK IN LAYOUT THEN INSERT BLOCK (redefine_tblk=nil cnc_tblk=nil)
  (if (and (not TBlk_exists) paperspace)
    (f:insert-ixm-tblock nil nil)
  )
  
  ;; IF ATTRIBUTES ARE FOR SHEETSET (tb_ss=T) OR CLASSIC (tb_ss=nil)
  (if tb_ss
    (f:tblk-attr-sheetset)
    (f:tblk-attr-to-classic)
  )
  
  (vla-EndUndoMark (actvDoc))
  (princ)
)


(defun c:IXM_TITLE_BLOCK_CLASSIC  nil (f:Insert-IXM-TitleBlock nil))
(defun c:IXM_TITLE_BLOCK_SHEETSET nil (f:Insert-IXM-TitleBlock T))
(defun c:UT                       nil (c:IXM_TITLE_BLOCK_CLASSIC))
(defun c:UTSS                     nil (c:IXM_TITLE_BLOCK_SHEETSET))
