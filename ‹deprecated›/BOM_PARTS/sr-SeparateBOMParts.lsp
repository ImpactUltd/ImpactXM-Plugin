(defun SeparateBOMParts ( ssetEnts 
                          / SeparateEnts
                            listEnts listPartTypes ent partType results listListEnts newListEnts
                        )
  (defun SeparateEnts (listEnts partType / ent tempList )
    (foreach ent listEnts
      (if (= (vla-get-textstring (car (vlax-invoke (vlax-ename->vla-object ent) 'GetConstantAttributes))) partType)
        (progn
          (setq tempList (cons ent tempList))
          (vl-remove ent listEnts)
        )
      )
    )
    (list tempList listEnts)
  )
  ;;----------------------------------------------------------------------------------------------------------------
  (setq listEnts      (SelectionSet->entList ssetEnts)
        listPartTypes nil
        newListEnts   nil
  )
  (foreach ent listEnts
    (if (equal :vlax-true (vla-get-hasattributes (vlax-ename->vla-object ent)))
        (if (= (vla-get-tagstring (car (vlax-invoke (vlax-ename->vla-object ent) 'GetConstantAttributes))) "TABL")
          (setq listPartTypes (consU (vla-get-textstring (car (vlax-invoke (vlax-ename->vla-object ent) 'GetConstantAttributes))) listPartTypes)
                newListEnts   (cons ent newListents)
          )
        )
    )
  )
  (foreach partType listPartTypes
    (setq results       (SeparateEnts newListEnts partType)
          listListEnts  (cons (car results) listListEnts)
          listEnts      (cadr results)
    )
  )
  listListEnts
)

(defun c:BOM_COUNT_PARTS ( / numParts numGroups numTotalParts groupName)
  (setq numParts      0
        numGroups     0
        numTotalParts 0
  )
  ;;(LOAD "L:/AutoCAD/LISP/AutoCAD Plugins/IXM-BOM-Tables.bundle/Contents/SeparateBOMParts.lsp") 
  (foreach group (SeparateBOMParts (ssget '((410 . "Model") (0 . "INSERT"))))
    (if (= numGroups 0) (princ "\n"))
    (setq numParts   0
          numGroups (1+ numGroups)
          groupName  (vla-get-textstring (car (vlax-invoke (vlax-ename->vla-object (car group)) 'GetConstantAttributes)))
    )
    (foreach part group
      (setq numParts      (1+ numParts)
            numTotalParts (1+ numTotalParts)
      )
    )
    (princ (strcat "\n " (pad-str "" (itoa numParts) " " 4) " part(s) in " groupName))
  )
  (princ (strcat "\n\n " (pad-str "" (itoa numTotalParts) " " 4) " part(s) total in " (itoa numGroups) " group(s) found."))
  (princ)
)