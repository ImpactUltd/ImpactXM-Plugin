(defun sub:EditBOMpart ( / ent loop promptString blockObject *error* tempSS)
  (gc)
  (defun *error* ( msg )
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )
  (setq loop 1
        promptString "\nPick a BOM part..."
  )
  (if (setq tempSS (last (ssgetfirst)))
    (progn
      (setq ent (ssname tempSS 0))
      (sssetfirst nil nil)
    )
    (setq tempSS (ssadd))
  )
  (while (= loop 1)
    (if (= (sslength tempSS) 1)
      (progn
        (setq blockObject (vlax-ename->vla-object ent))
        (if (setq attribs (CL:GetConstantAttributeList blockObject))
          (if (eq (vla-get-tagstring (car attribs)) "TABL")
            (progn
              (setq partData (GetPartData blockObject)
                    loop 0
              )
            )
            (setq promptString "\nYou picked a BLOCK, but not a BOM Part. Try again...")
          )
          (progn
            (if (eq (cdr (assoc 0 (entget ent))) "INSERT")
              (progn
                (redraw ent 3)
                (setq promptString "\nYou picked a BLOCK, but not a BOM Part. Try again...")
              )
              (progn
                (redraw ent 3)
                (setq promptString (strcat "\nYou picked a " (cdr (assoc 0 (entget ent))) ", not a BOM Part. Try again..."))
              )
            )
            (redraw ent 4)
          )
        )
        (ssdel ent tempSS)
        (redraw ent 4)
      )
      (progn
        (cond 
          ((setq ent (car (entsel promptString)))
            (setq  tempSS (ssadd))
            (ssadd ent tempSS)
            (sssetfirst nil nil)
            (redraw ent 3)
          )
          ((= (getvar "ERRNO") 7)
              (setq promptString "\nNothing selected. Try again...")
          )
        )
      )
    )
  )
  (sub:CheckDictionaries)
  ;;(list blockName partTableName partDesc partSize partNote)
  (setq TitleBarText      "Edit BOM Part"
        blockName         (nth 0 partData)
        originalName      blockName
        partTableName     (nth 1 partData)
        partDesc          (nth 2 partData)
        partSize          (nth 3 partData)
        partNote          (nth 4 partData)
        loop              1
        checkBoxType      "Copy part with new name"
        processPartCheck  0
        dictLastUsed      "@BOM_LAST_USED"
  )
  (addRecord dictLastUsed "DIALOG"  (LIST
                                      TitleBarText
                                      partTableName
                                      blockName
                                      partSize
                                      partNote
                                      checkBoxType
                                      ;processPartCheck
                                    )
  )

  (while (= loop 1)
    (setq loop (dcl-Form-Show _Dialogs/CreateEditPart))
    (cond
      ((and (= loop 1) (not (snvalid blockName)))
        (princ "\n  WARNING - ENTERED INVALID PART NAME.")
        (setq loop (dcl-Form-Show _Dialogs/InvalidName))
        (sub:ListBOMparts)
      )
      ((and (tblsearch "BLOCK" blockName) (not (equal originalName blockName)) (= loop 1))
        (princ "\n  WARNING - ENTERED EXISTING PART NAME.")
        (setq loop (dcl-Form-Show _Dialogs/PartNameExists))
        (sub:ListBOMparts)
      )
      ((and (tblsearch "BLOCK" blockName) (equal originalName blockName) (= loop 1) (= processPartCheck 1))
        (princ "\n  WARNING - Copy part with new name already existing.")
        (setq loop (dcl-Form-Show _Dialogs/PartNameExists))
        (sub:ListBOMparts)
      )
      ((and (tblsearch "BLOCK" blockName) (equal originalName blockName) (= loop 1) (= processPartCheck 0))
        (princ "\n  SUCCESS - UPDATED PART (SAME NAME).")
        (setq loop (UpdatePartData blockObject blockName partTableName partDesc partSize partNote))
        (sub:ListBOMparts)
      )
      ((and (not (tblsearch "BLOCK" blockName)) (not (equal originalName blockName)) (= loop 1) (= processPartCheck 0))
        (princ "\n  SUCCESS - UPDATED PART (NEW NAME).")
        (setq loop (UpdatePartData blockObject blockName partTableName partDesc partSize partNote))
        (sub:ListBOMparts)
      )
      ((and (not (tblsearch "BLOCK" blockName)) (not (equal originalName blockName)) (= loop 1) (= processPartCheck 1))
        (princ "\n  SUCCESS - COPIED PART (NEW NAME).")
        (setq loop (CopyPartBlock blockObject blockName partTableName partDesc partSize partNote))
        (sub:ListBOMparts)
      )
      (T (princ "\nOPERATION CANCELLED."))
    )
  )
  (refreshBlocks)
  (princ)
)
