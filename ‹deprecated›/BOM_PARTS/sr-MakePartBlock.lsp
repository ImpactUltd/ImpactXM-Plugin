(defun sub:MakePartBlock ( sSet originPnt blockName partTableName partDesc partSize partNote 
                     / actvDoc obj blockObj objList ATTHEIGHT ATTMODE ATTPROMPT ATTRIBUTEOBJ ATTTAG ATTVALUE INC INSERTIONPOINT MODELSPACE PARTDATA)
  (setq actvDoc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (if (tblsearch "BLOCK" blockName)
    (vlax-for item
      (vla-item (vla-get-blocks actvDoc) blockName)
      (vla-Delete item)
    )
  )
  (vlax-for obj sSet
    (if (= (vlax-get-property obj 'ObjectName) "AcDbAttributeDefinition")
      (vla-delete obj)
      (setq objList (cons obj objList))
    )
  )
  (setq inc 0.0)
  (setq partData  (list 
                    (list "NOTE" "NOTE"         partNote)
                    (list "SIZE" "SIZE"         partSize)
                    (list "DESC" "DESCRIPTION"  partDesc)
                    (list "TABL" "TABLE_HEADER" partTableName)
                  )
  )
  (setq modelSpace (vla-get-ModelSpace actvDoc)
        attHeight 0.1
        attMode   17
        attPrompt "PIECE MARK"
        insertionPoint (vlax-3d-point (car originPnt) (+ (cadr originPnt) inc) (caddr originPnt))
        attTag    "PIECE_MARK"
        attValue  "XXX-00"
        attributeObj (vla-AddAttribute modelSpace attHeight attMode attPrompt insertionPoint attTag attValue)
        objList (cons attributeObj objList)
        inc (+ inc 0.15)
  )
  (foreach attDef partData
    (setq insertionPoint (vlax-3d-point (car originPnt) (+ (cadr originPnt) inc) (caddr originPnt)) 
          attHeight 0.1
          attMode   19
          attTag    (car attDef)
          attPrompt (cadr attDef)
          attValue  (caddr attDef)
          modelSpace (vla-get-ModelSpace actvDoc)
          attributeObj (vla-AddAttribute modelSpace attHeight attMode attPrompt insertionPoint attTag attValue)
          objList (cons attributeObj objList)
          inc (+ inc 0.15)
    )
  )
  (vla-delete sSet)
  (vlax-invoke actvDoc 'copyobjects objList (setq blockObj (vlax-Invoke (vla-get-blocks actvDoc) 'add (trans originPnt 1 0) blockName)))
  (vlax-invoke
    (vlax-get-property actvDoc (if (= 1 (getvar 'cvport)) 'paperspace 'modelspace))
    'insertblock
    (trans originPnt 1 0)
    (vla-get-name blockObj) 1.0 1.0 1.0 0.0
  )
  (foreach obj objList (vla-delete obj))
  0
)
