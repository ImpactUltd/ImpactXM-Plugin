(defun sub:ConvertToPartBlock ( block_name partTableName partDesc partSize partNote 
                     / actvDoc obj blockObj list_obj ATTHEIGHT ATTMODE ATTPROMPT ATTRIBUTEOBJ ATTTAG ATTVALUE increment INSERTIONPOINT MODELSPACE PARTDATA)
  (setq actvDoc (vla-get-ActiveDocument (vlax-get-acad-object)))
  ;; get insertionPoint = block_insPt
  (setq increment 0.0)
  (setq partData  (list 
                    (list "NOTE" "NOTE"         partNote)
                    (list "SIZE" "SIZE"         partSize)
                    (list "DESC" "DESCRIPTION"  partDesc)
                    (list "TABL" "TABLE_HEADER" partTableName)
                  )
  )
  (setq modelSpace (vla-get-ModelSpace actvDoc)
        attr_Height 0.1
        attr_Mode   17
        attr_Prompt "PIECE MARK"
        attr_insPt (vlax-3d-point (car block_insPt) (+ (cadr block_insPt) increment) (caddr block_insPt))
        attr_Tag    "PIECE_MARK"
        attr_Value  "XXX-00"
        obj_attribute (vla-AddAttribute modelSpace attr_Height attr_Mode attr_Prompt attr_insPt attr_Tag attr_Value)
        list_obj (cons obj_attribute list_obj)
        increment (+ increment 0.15)
  )
  (foreach attDef partData
    (setq attr_insPt (vlax-3d-point (car block_insPt) (+ (cadr block_insPt) increment) (caddr block_insPt)) 
          attr_Height 0.1
          attr_Mode   19
          attr_Tag    (car attDef)
          attr_Prompt (cadr attDef)
          attr_Value  (caddr attDef)
          modelSpace (vla-get-ModelSpace actvDoc)
          obj_attribute (vla-AddAttribute modelSpace attr_Height attr_Mode attr_Prompt attr_insPt attr_Tag attr_Value)
          list_obj (cons obj_attribute list_obj)
          increment (+ increment 0.15)
    )
  )
  (vla-delete sSet)
  (vlax-invoke actvDoc 'copyobjects list_obj (setq blockObj (vlax-Invoke (vla-get-blocks actvDoc) 'add (trans originPnt 1 0) block_name)))
  (vlax-invoke
    (vlax-get-property actvDoc (if (= 1 (getvar 'cvport)) 'paperspace 'modelspace))
    'insertblock
    (trans originPnt 1 0)
    (vla-get-name blockObj) 1.0 1.0 1.0 0.0
  )
  (foreach obj list_obj (vla-delete obj))
  0
)
