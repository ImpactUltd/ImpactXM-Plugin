(defun c:CNC_NUMBER_SHEETS (/   *error* 
                                sub_numbox list_obj_blocks list_obj_TBlocks str_SheetNum)
  (defun *error* (msg)
    (if (not
          (member msg '("Function cancelled" "quit / exit abort"))
        )
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  (defun sub_numbox (str / han)
    (and (< 0 (setq han (load_dialog "acad")))
         (new_dialog "acad_txtedit" han)
         (set_tile "text_edit" str)
         (action_tile "text_edit" "(setq str $value)")
         (if (zerop (start_dialog))
           (setq str nil)
         )
    )
    (if (< 0 han)
      (unload_dialog han)
    )
    str
  )
  
  ;; MAIN
  (setq list_obj_blocks (SelectionSet->objList (ssget '((0 . "INSERT")))))
  (foreach obj_block list_obj_blocks      
      (if (= (CL:GetConstantAttributeValue obj_block "TITLE_BLOCK_VERSION") "2.6" )
          (setq list_obj_TBlocks (cons obj_block list_obj_TBlocks))
      )
  )
  (setq list_obj_TBlocks (reverse list_obj_TBlocks))
  (setq pref  (sub_numbox "ENTER PREFIX")
        index 1
  )
  (foreach obj_TBlock list_obj_TBlocks
    (setq str_SheetNum (strcat pref "-" (pad-str nil (itoa index) "0" 3)))
    (CL:SetAttributeValue obj_TBlock "NC_PROG" str_SheetNum)
    (setq index (1+ index))
  )
  (princ)
)

;; (princ "\nCNC_NUMBER_SHEETS.VLX loaded.")
