(defun c:BOM_RESET_DICTIONARIES nil (sub:DelBOMdicts) (sub:InitializeBOMdwg))

(defun sub:CheckDictionaries ()
  (if (and (member "@BOM_TABLE_HEADERS_AND_DESC"  (listDictionaries))
           (member "@BOM_LAST_USED"               (listDictionaries))
           (member "@BOM_PARTS_IN_DWG"            (listDictionaries))
      ) ;; and
        ;| TRUE|; (sub:ListBOMparts)
        ;|FALSE|; (sub:InitializeBOMdwg)
  ) ;; if
)

(defun sub:InitializeBOMdwg  ( / ACTVDOC DICT_BOMPARTS DICT_LASTUSED DICT_TABLEHDRSDSC FILE_THD_LIST  LISTBOMTABLEHEADERS LIST_BOMTABLEHEADERS LIST_DICT_ALL)
                                
  (setq actvDoc               (vla-get-ActiveDocument (vlax-get-acad-object))
        list_dict_All     (listDictionaries)
        dict_TableHdrsDsc "@BOM_TABLE_HEADERS_AND_DESC"
        dict_LastUsed     "@BOM_LAST_USED"
        dict_BOMParts     "@BOM_PARTS_IN_DWG"
  )
  ;; Check if Table Headers Dictionary exists. If not then create it.
  (if (not (member dict_TableHdrsDsc list_dict_All))
    (progn
      (setq file_THD_list (findfile "Resources/BOM_Default_Table_Headers_&_Descriptions.list"))
      (if file_THD_list
        (setq list_BOMTableHeaders (load file_THD_list))
        (setq list_BOMTableHeaders (load (strcat libPath "Resources/BOM_Default_Table_Headers_&_Descriptions.list")))
      )
      (foreach tableTitle list_BOMTableHeaders
        (addRecord dict_TableHdrsDsc (car tableTitle) (cdr tableTitle))
      )
    )
  )
  ;; Check if Last Used Table Dictionary exists. If not then create it.
  (if (not (member dict_LastUsed list_dict_All))
    (progn
      (addRecord dict_LastUsed "LAST FOLDER" (vla-get-Path actvDoc))
      (addRecord dict_LastUsed "LAST TABLE" "SCHEDULE")
    )
  )
  
  (if (not (member dict_BOMParts list_dict_All))
      (createDict dict_BOMParts)
  )
  
  (sub:ListBOMparts)
  (princ "\n BOM Dictionaries initialized.")
  (princ)
)

(defun sub:DelBOMdicts  ( / listBOMdicts dictBOM )
  (setq listBOMdicts (listDictionaries))
  (foreach dictBOM listBOMdicts
    (if (= (vl-string-search "@" dictBOM) 0)
        (delDict dictBOM)
    )
  )
  (princ "\n BOM Dictionaries Deleted.")
  (princ)
)
(princ)