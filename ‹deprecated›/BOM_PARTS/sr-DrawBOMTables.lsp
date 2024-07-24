(defun sub:DrawBOMTables ( / layoutName allSelectedSS xLocation yLocation numTables tableDims 
                            listParts separatedParts
                            numTableColumn tableColumnWidth tableColumnHeight tableColumnPHeight
                        )
                  
  (setq acadDoc (vla-get-activeDocument (vlax-get-acad-object))
        isModelSpace (= acModelSpace (vla-get-activeSpace acadDoc))
  )
  (if isModelSpace
    (setq allSelectedSS (ssget '((410 . "Model")(0 . "INSERT"))))
    (progn
      (vla-put-ActiveSpace acadDoc acModelSpace)
      (setq allSelectedSS (ssget '((410 . "Model")(0 . "INSERT"))))
    )
  )
  
  ; Turn off "Create viewport in new layout" in registry
  ; [HKEY_CURRENT_USER\Software\Autodesk\AutoCAD\R23.1\ACAD-3001:409\Profiles\<<Unnamed Profile>>\Drawing Window]
  ; "CreateViewports"=dword:00000000


  ; Save table style original state

  ; Check if table style "LEGENDS-02" exists 

  ; If not, INSERT_DDB "..\Resources\Blocks\@COMBINED Blocks\@COMBINED-TITLE BAR-02.dwg" 

  ; Set current table style "LEGENDS-02"
  ;   return table style to original state

  (setq separatedParts  (SeparateBOMParts allSelectedSS)
        layoutName      "XX-BOM TABLES"
  )
  
  (CreateNewBOMLayout layoutName)
  (setq numTable               0
        numTableColumn         1
        tableColumnWidth       0.00
        tableColumnHeight      0.00
        tableVertPadding       0.35
        tableHorzPadding       0.35
        maxTableColumnHeight  16.55
        xOLocation             0.35
        yOLocation            16.90
  )
  (foreach listParts separatedParts 
    (setq numTable (1+ numTable)
          listTableData (GetTabulatedData listParts)
          tableHeight   (+ (* (- (length listTableData) 2.0) 0.25) 0.25 0.36)
          potTableColumnHeight  (+ tableColumnHeight tableHeight)
    )
    (cond
      ((= numTable 1)
          (setq xLocation xOLocation
                yLocation yOLocation
                tableColumnHeight (+ tableColumnHeight tableHeight)
          )
      )
      ((and (> numTable 1) (< potTableColumnHeight maxTableColumnHeight))
          (setq yLocation (- yOLocation tableColumnHeight tableVertPadding)
                tableColumnHeight (+ tableColumnHeight tableHeight tableVertPadding)
          )

      )
      ((and (> numTable 1) (> potTableColumnHeight maxTableColumnHeight) (= numTableColumn 1))
          (setq xLocation (+ xOLocation tableColumnWidth tableHorzPadding)
                xOLocation xLocation
                yLocation yOLocation
                numTableColumn (1+ numTableColumn)
                tableColumnHeight tableHeight
                tableColumnWidth 0
          )
      )
      ((and (> numTable 1) (< potTableColumnHeight maxTableColumnHeight) (> numTableColumn 1))
          (setq xLocation xOLocation
                yLocation (- yOLocation tableColumnHeight tableVertPadding)
                tableColumnHeight (+ tableColumnHeight tableHeight tableVertPadding)
          )
      )
    )
    (setq tableWidth (DrawTable listTableData (vlax-3d-point xLocation yLocation) layoutName))
    (if (> tableWidth tableColumnWidth)
      (setq tableColumnWidth tableWidth)
    )
  )
  (princ (strcat "\nNumber of table(s) generated: " (itoa numTable)))
  (princ)
)
