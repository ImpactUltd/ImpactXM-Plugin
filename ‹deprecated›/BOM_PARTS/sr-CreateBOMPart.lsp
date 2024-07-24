(defun sub:CreateBOMpart ( / loop actvDoc sSets newSSet originPnt blockName *error*
                            dictLastUsed
                        )
  (defun *error* ( msg )
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nError: " msg))
    )
    (if (CL:GetCollectionItem (vla-get-selectionsets (vla-get-activedocument (vlax-get-acad-object))) "SS1")
      (vla-delete (vla-item (vla-get-selectionsets (vla-get-activedocument (vlax-get-acad-object))) "SS1"))
    )
    (princ)
  )

  (setq actvDoc             (vla-get-activedocument (vlax-get-acad-object))
        sSets               (vla-get-selectionsets actvDoc)   ;; retrieve a reference to the selection sets object
        newSSet             (vla-add sSets "SS1")             ;; add a new selection set
        dictLastUsed        "@BOM_LAST_USED"
  )
  (vla-selectOnScreen newSSet)                    ;; select your new selection set objects

  (sub:CheckDictionaries)
  
  (if     (> (vla-get-Count newSSet) 0)
    (setq loop 1)
  )
  
  (while (= loop 1)
    (if (setq originPnt (getpoint "\nSpecify Base Point: ")
              faceSet   (ssget originPnt))
      (progn
        (setq ojbType (cdr (assoc 0 (entget (ssname faceSet 0)))))
        (if (eq ojbType "3DSOLID")
          (command-s "UCS" "FACE" "non" originPnt "")
          (command-s "UCS" "OBJECT" "non" originPnt "")
        )
        (setq TitleBarText      "Create BOM Part"
              partTableName     (getRecord dictLastUsed "LAST TABLE")
              blockName         "PART ID"
              partSize          (subGetPartSize newSSet)
              partNote          ""
              checkBoxType      "Redefine part"
              processPartCheck  0

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
            ((and (= loop 1) (tblsearch "BLOCK" blockName) (= processPartCheck 0))
              (princ "\n  WARNING - ENTERED EXISTING PART NAME. REDEFINE?")
              (if (= (dcl-Form-Show _Dialogs/RedefinePart) 1)
                (setq loop (sub:MakePartBlock newSSet originPnt blockName partTableName partDesc partSize partNote))
              )
              (sub:ListBOMparts)
            )
            ((and (= loop 1) (tblsearch "BLOCK" blockName) (= processPartCheck 1))
              (princ "\n  SUCCESS - REDEFINED PART.")
              (setq loop (sub:MakePartBlock newSSet originPnt blockName partTableName partDesc partSize partNote))
              (sub:ListBOMparts)
            )
            ((and (= loop 1) (not (tblsearch "BLOCK" blockName)))
              (princ "\n  SUCCESS - CREATED NEW PART.")
              (setq loop (sub:MakePartBlock newSSet originPnt blockName partTableName partDesc partSize partNote))
              (sub:ListBOMparts)
            )
            (T (princ "\nOPERATION CANCELLED."))
          ) ;; cond
        ) ;; while
      ) ;; progn (if true)
      (setq loop (dcl-Form-Show _Dialogs/PickNewBasePoint)) ;; if false
    ) ;; if
  )
  (refreshBlocks)
  (vla-regen actvDoc acActiveViewport)
  (if (CL:GetCollectionItem (vla-get-selectionsets (vla-get-activedocument (vlax-get-acad-object))) "SS1")
    (vla-delete (vla-item (vla-get-selectionsets (vla-get-activedocument (vlax-get-acad-object))) "SS1"))
  )
  (princ)
)
