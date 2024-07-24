(defun GATTE_IXM (/ list_tag_retTxt sr:getAtt sr:createDialog sr:runTheDialog sr:updateSingle list_visible_attribs n list_tags list_txts list_prompts list_tag_txt list_tag_prompt num_tags name_file file_open incr_a dcl_id str_label list_retVal list_all_attribs list_Attrib_tag_obj list_objAttribs *error*)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
  )
  
  (vla-StartUndoMark (actvDoc))

  (defun f:clean-str (str_in / str_out chr_code)
    (foreach chr_code (vl-string->list str_in) 
      (if (= chr_code 34)
        (setq str_out (cons 92 str_out)
              str_out (cons 34 str_out))
        (setq str_out (cons chr_code str_out))
      )
    )
    (vl-list->string (reverse str_out))
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

  (defun f:ObjectID ( obj )
    (eval
      (list 'defun 'f:ObjectID '( obj )
        (if
          (and
            (vl-string-search "64" (getenv "PROCESSOR_ARCHITECTURE"))
            (vlax-method-applicable-p (vla-get-Utility (actvDoc)) 'getobjectidstring)
          )
          (list 'vla-getobjectidstring (vla-get-Utility (actvDoc)) 'obj ':vlax-false)
          '(itoa (vla-get-ObjectID obj))
        )
      )
    )
    (f:ObjectID obj)
  )

  (defun f:getAttribsFromBlockRef (obj_blockRef)
    (setq list_objAttribs (vlax-safearray->list (variant-value (vla-GetAttributes obj_blockRef))))
    (foreach obj_Attribs list_objAttribs
      (setq list_Attrib_tag_obj (cons (list (vla-get-TagString obj_Attribs) obj_Attribs) list_Attrib_tag_obj))
    )
    list_Attrib_tag_obj
  )

  (defun f:editSingleAtrrib (obj_attrib obj_blockRef)
    (setq obj_blockRef_Name (vla-get-EffectiveName obj_BlockRef)
          new_value (EditEnter "Edit Attribute" "New Value: " (vla-get-TextString obj_attrib) 20 ))
    (foreach obj_BlockRef_dwg (SelectionSet->objList (ssget "_X" '((0 . "INSERT"))))
      (if (= obj_blockRef_Name (vla-get-EffectiveName obj_BlockRef_dwg))
        (progn
          (setq list_objAttr (vlax-safearray->list (vlax-variant-value (vla-GetAttributes obj_BlockRef_dwg))))
          (foreach obj_Attr list_objAttr
            (if (= (vla-get-TagString obj_attrib) (vla-get-TagString obj_Attr))
                (vla-put-TextString obj_Attr new_value )
            );if
          );foreach
        );progn
      );if
    );foreach
    (princ "\n   ")
    (princ (pad-str  (vla-get-TagString obj_attrib) "" " " 14 ))
    (princ " :  ")
    (princ new_value)
    (princ "\n\n")
  )

  (defun f:editAllAtrribs ( block_ref)
    (defun sr:getAtt (obj_blockRef)
      (setq list_all_attribs (vlax-safearray->list (variant-value (vla-GetAttributes obj_blockRef)))
            obj_block_name (vla-get-EffectiveName obj_blockRef)
            obj_block (vla-Item (vla-get-Blocks (actvDoc)) obj_block_name)
      );setq

      (foreach n list_all_attribs
        (if (eq (vla-get-Visible n) :vlax-true)
          (setq list_visible_attribs (cons n list_visible_attribs))  ; List of VISIBLE attributes
        )
      );foreach
      (setq list_visible_attribs (reverse list_visible_attribs))
      
      ; Make associative list of attribute values ((TAG1 VALUE1) (TAG2 VALUE2) ...)
      ; (from block reference)
      (foreach n list_visible_attribs
        (setq list_tags    (cons (vla-get-TagString n) list_tags))
        (if (f:fieldCodeX n)
              (setq list_tag_txt (cons (list (vla-get-TagString n)(f:fieldCodeX n)) list_tag_txt))
              (setq list_tag_txt (cons (list (vla-get-TagString n)(vla-get-TextString n)) list_tag_txt))
        ) 
      );foreach

      ; Make associative list of attribute prompts ((TAG1 PROMPT1) (TAG2 PROMPT2) ...)
      ; (from block)
      (vlax-for obj_entity obj_block
        (if (= (vla-get-ObjectName obj_entity) "AcDbAttributeDefinition")      ; get the prompt attribute data
          (setq list_tag_prompt (cons (list (vla-get-TagString obj_entity) (vla-get-PromptString obj_entity)) list_tag_prompt))
        );if
      );vlax-for

      (setq list_tags (reverse list_tags)
            ;list_visible_attribs   (reverse list_visible_attribs)
            num_tags        (length  list_tags)
      )
    );defun sr:getAtt

    (defun sr:createDialog ()                                              ; create a temp DCL file
      (setq name_file (vl-filename-mktemp "dcl.dcl"))
      (setq file_open (open name_file "w"))                                     ; open it to write
      (write-line "temp : dialog { label = \"Global ATTribute Editor - Impact XM\";" file_open) 
      (setq incr_a 0)                                                    ; reset the incremental control number
      (repeat num_tags                                                     ; start the loop to create the edit boxes
        (write-line ": edit_box {" file_open)                               ; create the edit boxes
        (setq str_label (strcat "\"" "eb" (itoa incr_a) "\"" ";"))
        (write-line (strcat "    key = " str_label)  file_open)
        (setq str_label (cadr (assoc (nth incr_a list_tags) list_tag_prompt)))
        (write-line (strcat "    label = " "\"" (f:clean-str str_label) "\"" ";") file_open)
        (setq str_label (cadr (assoc (nth incr_a list_tags) list_tag_txt)))
        (write-line (strcat "    value = " "\"" (f:clean-str str_label) "\"" ";") file_open)
        (write-line "    allow_accept = true ;" file_open)
        (write-line "    width = 60; alignment = centered; edit_width = 20; " file_open)
        (write-line "}" file_open)
      (setq incr_a (1+ incr_a))                                              ; increment the counter
      );repeat
      (write-line ": toggle {" file_open)
      (write-line "    key = \"Update_All_Blocks\" ;" file_open)
      (write-line "    label = \"Update All Blocks\" ;" file_open)
      (write-line "    value = \"1\" ;" file_open)
      (write-line "    is_tab_stop = false ;" file_open)
      (write-line "    width = 60 ; height = 2 ; alignment = centered ;" file_open)
      (write-line "}" file_open)
      (write-line "ok_cancel; }" file_open)                                   ; ok and cancel button
      (close file_open)                                                       ; close the temp DCL file
    );defun sr:createDialog

    (defun sr:runTheDialog ()                                              ; load the dialog file and definition
      (setq dcl_id (load_dialog name_file))
        (if (not (new_dialog "temp" dcl_id))
          (exit)
        );if
      (mode_tile "eb0" 2)
      (action_tile "accept" "(sr:getDialogResults)")  ; if the OK button is selected
      (start_dialog)                                  ; start the dialog
      (unload_dialog dcl_id)                          ; unload the dialog
      (vl-file-delete name_file)                      ; delete the temp DCL file
    );defun sr:runTheDialog

    (defun sr:getDialogResults ()
      (setq incr_a 0)                                           ; reset the increment counter
      (repeat num_tags                                          ; start the loop
        (setq str_label (get_tile (strcat "eb" (itoa incr_a)))) ; retrieve the tile value
        (setq list_retVal (cons str_label list_retVal))         ; add it to the list
        (setq incr_a (1+ incr_a))                               ; increment the counter
      );repeat
      (setq UpdateAllBlocks (get_tile "Update_All_Blocks"))
      (setq list_retVal (reverse list_retVal))                            ; reverse list
      ; Make associative list of attribute returned values ((TAG1 VALUE1) (TAG2 VALUE2) ...)
      ; (from dialog results)
      (setq incr_a 0)
      (repeat num_tags
        ;(if (and ))
        (setq list_tag_retTxt (cons (list (nth incr_a list_tags) (nth incr_a list_retVal)) list_tag_retTxt)
              incr_a (1+ incr_a)
        );setq
      );foreach
      (foreach tag_retTxt (reverse list_tag_retTxt) 
        (princ "\n   ")
        (princ (pad-str (car tag_retTxt) "" " " 14 ))
        (princ " :  ")
        (princ (cadr tag_retTxt))
      )
      (done_dialog)                                             ; close the dialog
    );defun sr:getDialogResults

    (defun sr:updateSingle ()
      (setq incr_a 0)                                             ; reset the increment counter
      (repeat num_tags                                              ; start the loop
        (vla-put-TextString (nth incr_a list_visible_attribs) (nth incr_a list_retVal)) ; update the attribute
        (setq incr_a (1+ incr_a))                                     ; increment the counter
      );repeat
      (vla-Update block_ref)                                   ; update the block
    );defun sr:updateSingle

    (defun sr:updateAll ()
      (setq list_objBlockRefs (SelectionSet->objList (ssget "_X" '((0 . "INSERT")))))
      (foreach obj_BlockRef list_objBlockRefs
        (if (= obj_block_name (vla-get-EffectiveName obj_BlockRef))
          (progn
            (setq block_attribs (f:getAttribsFromBlockRef obj_BlockRef))
            (foreach tag_retTxt list_tag_retTxt
              (vla-put-TextString (cadr (assoc (car tag_retTxt) block_attribs)) (cadr tag_retTxt))
            )
            (vla-Update obj_BlockRef)                                   ; update the block
          )
        )
      )
    );defun sr:updateAll

    (if (= (vlax-get-property block_ref 'ObjectName) "AcDbBlockReference") ; check if it's a block
      (progn                                                               ; if it is, do the following
        (if (= (vlax-get-property block_ref 'HasAttributes) :vlax-true)    ; check if it has attributes
          (progn                                                           ; if yes, do the following
            (sr:getAtt block_ref)                                          ; get the attributes
            (sr:createDialog)                                              ; create the dialog
            (sr:runTheDialog)                                              ; run the dialog
            (if (= UpdateAllBlocks "1")                                    ; update the attributes
              (sr:updateAll)
              (sr:updateSingle)                                                     
            )
          );progn
          (alert "This Block has No Attributes!! - Please try again.")    ; No attributes, inform the user
        );if
      );progn
      (alert "This is not a Block!! - Please try again.")                 ; it's not a block, inform the user
    );if

    (princ)
  );defun f:editAllAtrribs

  (setq NothingSelected T)
  (while NothingSelected
    (setq ent_sel (nentsel "\nSelect block or attribute:")
          lngth (length (cdr ent_sel)))
    (cond
      ((= lngth 0) (princ "\nNothing selected. Try again."))
      ((= lngth 1) 
        (if (= (vla-get-ObjectName (vlax-ename->vla-object (car ent_sel))) "AcDbAttribute")
          (progn
            (princ "\nAttribute slected.")
            (setq NothingSelected nil)
            (setq obj_nested        (vlax-ename->vla-object (car ent_sel))
                  obj_blockRef      (vla-ObjectIDToObject (actvDoc) (vla-get-OwnerID (vlax-ename->vla-object (car ent_sel))))
                  obj_blockRef_Name (vla-get-EffectiveName obj_blockRef)
            )
            (princ "\nReference Block   :  ") (princ obj_blockRef_Name)
            (f:editSingleAtrrib obj_nested obj_blockRef)

          )      
          (princ "\nNeither block or attribute selected. Try again.")
        )
      )
      ((> lngth 1) 
        (if (= (vla-get-HasAttributes (vlax-ename->vla-object (last (last ent_sel)))) :vlax-true)
          (progn
            (princ "\nBlock Selected.")
            (princ "\nReference Block   :  ") (princ obj_blockRef_Name)
            (setq NothingSelected nil)
            (f:editAllAtrribs (vlax-ename->vla-object (last (last ent_sel))))
          )
          (progn 
            (princ "\nBlock selected, but no attributes present. Try again.")
          )
        );if
      );cond (> lngth 1)
    );cond
  );while

  (vla-Regen (actvDoc) acAllViewports)
  (vla-EndUndoMark (actvDoc))
  (princ)
);defun

(defun c:GATTE_IXM () 
  ;(load "L:/AutoCAD/LISP/AutoCAD Plugins/ImpactXM/BLOCKS/GATTE_IXM.lsp")
  (GATTE_IXM)
)


