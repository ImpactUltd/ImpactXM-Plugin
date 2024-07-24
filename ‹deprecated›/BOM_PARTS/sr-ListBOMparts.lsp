(defun sub:ListBOMparts ( / ACTVDOC BLOCKITEM BLOCKITEMTYPE BLOCKNAME BLOCK_NAME COLLECTION_BLOCKS COUNT DICT_HEADERSDESC DICT_PARTSDEFS DICT_PARTSINDWG DICT_PARTTYPES LIST_BOMPARTS MODELSPACE NUM_BLOCKS_ACDB NUM_BLOCKS_MS NUM_BOMPARTS_ACDB NUM_BOMPARTS_MS NUM_PARTTYPES OBJACAD PARTDATA PARTSQTYDESCNOTE posAttribCount START_1 START_2 START_3 START_4 STR_LENGTH_A TPARTDES TPARTNOT TPARTSIZ TPARTTYP)

  (setq objACAD           (vlax-get-acad-object)
        actvDoc           (vla-get-ActiveDocument objACAD)
        modelSpace        (vla-get-ModelSpace actvDoc)
        collection_Blocks (vla-get-Blocks actvDoc)
        ;; DICTIONARIES
        dict_PartsInDwg   "@BOM_PARTS_IN_DWG"
        dict_HeadersDesc  "@BOM_TABLE_HEADERS_AND_DESC"
        ;; TEMP DICTIONARIES
        dict_PartsDefs    "@BOM_PARTS_TEMP"
        dict_PartTypes    "@BOM_PART_TYPES_TEMP"
        str_length_A      100
        num_blocks_AcDb   0
        num_blocks_MS     0
        num_BOMParts_AcDb 0
        num_BOMParts_MS   0
        num_PartTypes     0
        posAttribCount    0
        debug_timing      nil
  );; setq
  
  ;;;; Reset Dictionary ;;;;
  (delDict dict_PartsInDwg)

  ;; Filter out BOM Parts from all blocks in Drawing Database
  (setq start_1 (getvar "MILLISECS"))
  (vlax-for objBlock collection_Blocks 
      (setq num_blocks_AcDb (1+ num_blocks_AcDb))
      (if (not (wcmatch (vla-get-Name objBlock) "`**,_*,@$*"))
        (progn
          (setq count (vla-get-Count objBlock)
                index (1- count)
          )
          (while (>= index 0)
            (setq blockItem      (vla-Item objBlock index)
                  blockItemType  (vla-get-ObjectName blockItem)
            )
            (if (and  (= blockItemType "AcDbAttributeDefinition") 
                      (member (vla-get-TagString blockItem) (list "TABL" "DESC" "SIZE" "NOTE" "PIECE_MARK"))
                )
                (setq posAttribCount (1+ posAttribCount))
            )
            (setq index (1- index))
            (if (= posAttribCount 5)
                (setq list_BOMparts (cons objBlock list_BOMparts)
                      index -1
                      num_BOMParts_AcDb (1+ num_BOMParts_AcDb)
                      posAttribCount 0
                )
            )
          )
        )
      )
  )
  (if debug_timing
    (princ  (pad-str
              (strcat "\n Gather all (" (itoa num_blocks_AcDb) ") blocks from AcDb and filter (" (itoa num_BOMParts_AcDb) ") BOM Parts.")
              (strcat "(" (itoa (- (getvar "MILLISECS") start_1)) " ms)")
              "."
              str_length_A
            )
    )
  )

  
  ;; Fill dict_PartTypes dict_PartsDefs dict_HeadersDesc with part data
  (setq start_2 (getvar "MILLISECS"))
  (foreach BOMpart list_BOMparts 
      (setq blockName (vla-get-Name BOMpart)
            count     (vla-get-Count BOMpart)
      )
      (repeat count
        (setq blockItem      (vla-Item BOMpart (- count 1))
              blockItemType  (vla-get-ObjectName blockItem)
        )
        (if (= blockItemType "AcDbAttributeDefinition")
            (cond
              ((= (vla-get-TagString blockItem) "TABL")
                  (setq tPartTyp (vla-get-TextString blockItem))
                  (if (vlax-ldata-get dict_PartTypes "TYPES IN DRAWING")
                      (vlax-ldata-put dict_PartTypes "TYPES IN DRAWING" (appendU tPartTyp (vlax-ldata-get dict_PartTypes "TYPES IN DRAWING")))
                      (vlax-ldata-put dict_PartTypes "TYPES IN DRAWING" (list tPartTyp))
                  )
              )
              ((= (vla-get-TagString blockItem) "DESC")
                  (setq tPartDes (vla-get-TextString blockItem))
              )
              ((= (vla-get-TagString blockItem) "SIZE")
                  (setq tPartSiz (vla-get-TextString blockItem))
              )
              ((= (vla-get-TagString blockItem) "NOTE")
                  (setq tPartNot (vla-get-TextString blockItem))
              )
            );; cond
            
        )
        (setq count (1- count))
      );; repeat
      (vlax-ldata-put dict_PartsDefs blockName (list tPartTyp tPartDes tPartSiz tPartNot "0"))
      (if (not (member tPartDes (getRecord dict_HeadersDesc tPartTyp)))
          (addRecord dict_HeadersDesc tPartTyp (cons tPartDes (getRecord dict_HeadersDesc tPartTyp)))
      )
  );; foreach
  (if debug_timing
    (princ  (pad-str 
              (strcat "\n Extract data from (" (itoa num_BOMParts_AcDb) ") BOM Parts for BOMdb.")
              (strcat "(" (itoa (- (getvar "MILLISECS") start_2)) " ms)")
              "."
              str_length_A
            )
    )
  )

  


  ;;(vla-ZoomAll objACAD)
  
  (setq start_3 (getvar "MILLISECS"))
  (vlax-for obj_MS modelSpace
    (setq num_blocks_MS (1+ num_blocks_MS))
    (if (and
          (= (vla-get-ObjectName obj_MS) "AcDbBlockReference")
          (not (wcmatch (vla-get-Name obj_MS) "`**,_*,@$*"))
          (member (vla-get-Name obj_MS) (getKeys dict_PartsDefs))
        )
        (progn
          ;;;;(princ (strcat "\n" (vla-get-Name obj_MS)))
          (setq num_BOMParts_MS (1+ num_BOMParts_MS)
                block_Name  (vla-get-Name obj_MS)
                partData    (list (nth 0 (vlax-ldata-get dict_PartsDefs block_Name));; part type
                                  (nth 1 (vlax-ldata-get dict_PartsDefs block_Name));; part desc
                                  (nth 2 (vlax-ldata-get dict_PartsDefs block_Name));; part size
                                  (nth 3 (vlax-ldata-get dict_PartsDefs block_Name));; part note
                                  (itoa (1+ (atoi (nth 4 (vlax-ldata-get dict_PartsDefs block_Name)))));; part ref
                            );; list
          );; setq
          ;;;;(princ partData)
          (vlax-ldata-put dict_PartsDefs (vla-get-Name obj_MS) partData)
        );; prog
    )
  );; vlax-for
  (if debug_timing
    (princ  (pad-str
              (strcat "\n Examine (" (itoa num_blocks_MS) ") blocks from modelspace and filter out (" (itoa num_BOMParts_MS) ") BOM Parts")
              (strcat "(" (itoa (- (getvar "MILLISECS") start_3)) " ms)")
              "."
              str_length_A
            )
    )
  )


  ;; Create dictionary for part block references by part type
  ;; by combining dict_PartTypes and dict_PartsDefs
  (setq start_4 (getvar "MILLISECS"))
  (foreach partType (vlax-ldata-get dict_PartTypes "TYPES IN DRAWING")
    (setq partsQtyDescNote nil)
    (foreach blockName (getKeys dict_PartsDefs)
      (if (= (car (vlax-ldata-get dict_PartsDefs blockName)) partType)
          (setq partsQtyDescNote  (cons (list blockName 
                                              (nth 1 (vlax-ldata-get dict_PartsDefs blockName));; part desc
                                              (nth 2 (vlax-ldata-get dict_PartsDefs blockName));; part size
                                              (nth 3 (vlax-ldata-get dict_PartsDefs blockName));; part note
                                              (nth 4 (vlax-ldata-get dict_PartsDefs blockName));; part ref
                                        )
                                        partsQtyDescNote
                                  )
          )
      )
    )
    (vlax-ldata-put dict_PartsInDwg partType partsQtyDescNote)
  );; foreach
  (setq num_PartTypes (length (vlax-ldata-get dict_PartTypes "TYPES IN DRAWING")))
  (delDict dict_PartsDefs)
  (delDict dict_PartTypes)
  (if debug_timing
    (progn
      (princ  (pad-str 
                (strcat "\n Sorting (" (itoa num_BOMParts_AcDb) ") BOM Parts into (" (itoa num_PartTypes) ") Part Types and writing data to BOM-Db")
                (strcat "(" (itoa (- (getvar "MILLISECS") start_4)) " ms)")
                "."
                str_length_A
              )
      )
      (princ  (pad-str 
                "\n BOM-Db Update complete. "
                (strcat " " (itoa (- (getvar "MILLISECS") start_1)) " milliseconds.")
                "-" 
                str_length_A
              )
      )
      (princ "\n")
    )
  )
  (princ)
)
