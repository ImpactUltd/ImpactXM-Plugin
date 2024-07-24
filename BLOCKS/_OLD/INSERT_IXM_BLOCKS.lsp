(defun f:InsertImpactXMBlock (block_name block_opt 
                            / block_ins_name block_path block_latest block_name_m_drve 
                              block_name_plugin file_m_drve_ver file_plugin_ver path_cblcks
                               path_plugin path_tmplts sysvar_attdia sysvar_attreq)
  (gc)
  (defun *error* ( msg )
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nError: " msg))
    )
    (setvar "attreq" sysvar_ATTREQ)
    (setvar "attdia" sysvar_ATTDIA)
    (princ)
  )
  (setq sysvar_ATTREQ (getvar "attreq")
        sysvar_ATTDIA (getvar "attdia")
        path_plugin (strcat (f:GetPlugInPath "*IMPACT XM PLUG-INS.BUNDLE*") "Resources\\")
        path_blocks  "Blocks\\"
        path_cblcks  "Blocks\\@COMBINED Blocks\\"
        path_nblcks  "Blocks\\@COMBINED Blocks\\Nested"

  ) ; setq
  (setvar "attreq" 0)
  (setvar "attdia" 0)
  (if (tblsearch "BLOCK" block_name)
    (setq block_ins_name block_name)
    (foreach path_bt (list path_blocks path_cblcks path_nblcks)
      (if (findfile (strcat path_plugin path_bt block_name ".dwg"))
        (setq block_ins_name (strcat path_plugin path_bt block_name ".dwg"))
      )
    )
  )
  (if (or block_ins_name (tblsearch "BLOCK" block_name))
    (progn
      (princ "\nInserting: ") (princ block_ins_name)
      (cond
        ((and (= block_name "AVC TEMPLATE-01") (= block_opt ""))
          (command "-INSERT" block_ins_name pause "" "" "0")
        )
        ((and (= block_name "@COMBINED-FURNITURE-02") (= block_opt ""))
          (command "-INSERT" block_ins_name pause "" "" "0")
        )
        ((and (= block_name "@COMBINED-CARPET-GRID-02") (= block_opt ""))
          (command "-INSERT" block_ins_name pause "" "" "0")
        )
        ((and (= block_name "@COMBINED-HUMAN-PLAN-02") (= block_opt ""))
          (command "-INSERT" block_ins_name pause "" "0")
          (cl:SetDynPropValues (vlax-ename->vla-object (entlast)) '(("Block Table1" . 7)))
        )
        ((and (= block_name "@COMBINED-TITLE BLOCK-02") (= block_opt "24X18 BOOTH"))
            (command "-INSERT" block_ins_name pause "" "0")
            (cl:SetDynPropValues (vlax-ename->vla-object (entlast)) '(("Block Table1" . "1") ("DRAWING TYPE" . "Booth Control")))
        )
        ((and (= block_name "@COMBINED-TITLE BLOCK-02") (= block_opt "24X18 COMPONENT"))
            (command "-INSERT" block_ins_name pause "" "0")
            (cl:SetDynPropValues (vlax-ename->vla-object (entlast)) '(("Block Table1" . "1") ("DRAWING TYPE" . "Component Drawing")))
        )
        ((and (= block_name "@COMBINED-TITLE BLOCK-02") (= block_opt "CNC LAYOUT"))
            (command "-INSERT" block_ins_name pause "16" "0")
            (cl:SetDynPropValues (vlax-ename->vla-object (entlast)) '(("Block Table1" . "3")))
            ;;(command-s "scale" (ssget "L") "" (getvar 'LASTPOINT) "16")
        )
        ((and (= block_name "@COMBINED-TITLE BLOCK-02") (= block_opt "BEAMSAW"))
            (command "-INSERT" block_ins_name pause "16" "0")
            (cl:SetDynPropValues (vlax-ename->vla-object (entlast)) '(("Block Table1" . "4")))
            ;;(command-s "scale" (ssget "L") "" (getvar 'LASTPOINT) "16")
        )
        ((and (= block_name "@COMBINED-TITLE BAR-02") (= block_opt "Layout"))
          (setvar "attreq" 1)
          (command "-INSERT" block_ins_name pause "" "0" (strcat "%<" (chr 92) "AcDiesel " (chr 36) "(substr," (chr 36) "(getvar, " (chr 34) "ctab" (chr 34) "),4)>%") "" "")
          (cl:SetDynPropValues (vlax-ename->vla-object (entlast)) '(("BubbleView" . "View Bubble OFF")))
          (setvar "attreq" 0)
        )
        ((and (= block_name "@COMBINED-TITLE BAR-02") (= block_opt "View/Detail"))
          (command "-INSERT" block_ins_name pause "" "0")
          (cl:SetDynPropValues (vlax-ename->vla-object (entlast)) '(("BubbleView" . "View Bubble ON")))
        )
        ((and (= block_name "@COMBINED-TITLE BAR-02") (= block_opt ""))
          (command "-INSERT" block_ins_name pause "" "0")
          (cl:SetDynPropValues (vlax-ename->vla-object (entlast)) '(("BubbleView" . "View Bubble OFF")))
        )
        ((and (= block_name "@COMBINED-SYMBOLS-02") (= block_opt ""))
          (command "-INSERT" block_ins_name pause "" "0")
        )
        (t
          (command "-INSERT" block_ins_name pause "" "0")
        )
      ); cond
    ); progn
    (prompt "\nBlock does not exist in drawing and support path. Cannot insert.")
  ) ; if
  (setvar "attreq" sysvar_ATTREQ)
  (setvar "attdia" sysvar_ATTDIA)

  (princ)
)
;  (setq block_name (getstring T "Block Name: ")
;      block_option (getstring T "Block Option: ")
;  )
;  (f:InsertImpactXMBlock block_name block_option)
;)

(princ "\nINSERT_BLOCK Loaded")

(defun c:INSERT_IXM_AVC_TEMPLATE  () (f:InsertImpactXMBlock "AVC TEMPLATE-01" ""))
(defun c:INSERT_IXM_FURNITURE     () (f:InsertImpactXMBlock "@COMBINED-FURNITURE-02" ""))
(defun c:INSERT_IXM_CARPET_GRID   () (f:InsertImpactXMBlock "@COMBINED-CARPET-GRID-02" ""))
(defun c:INSERT_IXM_GRID          () (f:InsertImpactXMBlock "@COMBINED-GRID-02" ""))
(defun c:INSERT_IXM_HUMAN_ELEV    () (f:InsertImpactXMBlock "@COMBINED-HUMAN-PLAN-02" ""))
(defun c:INSERT_IXM_LEGENDS       () (f:InsertImpactXMBlock "@COMBINED-LEGENDS-02" ""))
(defun c:INSERT_IXM_SCHEDULES     () (f:InsertImpactXMBlock "@COMBINED-SCHEDULES-02" ""))
(defun c:INSERT_IXM_SCREENS       () (f:InsertImpactXMBlock "@COMBINED-SCREENS-02" ""))
(defun c:INSERT_IXM_SYMBOLS       () (f:InsertImpactXMBlock "@COMBINED-SYMBOLS-02" ""))
(defun c:INSERT_IXM_TBAR          () (f:InsertImpactXMBlock "@COMBINED-TITLE BAR-02" ""))
(defun c:INSERT_IXM_TBAR_LAYOUT   () (f:InsertImpactXMBlock "@COMBINED-TITLE BAR-02" "Layout"))
(defun c:INSERT_IXM_TBAR_VIEW     () (f:InsertImpactXMBlock "@COMBINED-TITLE BAR-02" "View/Detail"))
(defun c:INSERT_IXM_TBLK_24_BOOTH () (f:InsertImpactXMBlock "@COMBINED-TITLE BLOCK-02" "24X18 BOOTH"))
(defun c:INSERT_IXM_TBLK_24_COMP  () (f:InsertImpactXMBlock "@COMBINED-TITLE BLOCK-02" "24X18 COMPONENT"))
(defun c:INSERT_IXM_TBLK_MS_CNC   () (f:InsertImpactXMBlock "@COMBINED-TITLE BLOCK-02" "CNC LAYOUT"))
(defun c:INSERT_IXM_TBLK_MS_BSW   () (f:InsertImpactXMBlock "@COMBINED-TITLE BLOCK-02" "BEAMSAW"))