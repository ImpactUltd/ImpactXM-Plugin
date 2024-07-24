(defun CreatedBOMTableStyle ()
    ;; This example creates a TableStyle object and sets values for 
    ;; the style name and other attributes.
    (setq acadObj (vlax-get-acad-object))
    (setq doc (vla-get-ActiveDocument acadObj))
  
    (setq dictionaries (vla-get-Dictionaries doc))
    (setq dictObj (vla-Item dictionaries "acad_tablestyle"))
    
    ;; Create the custom TableStyle object in the dictionary
    (setq keyName "NewStyle"
          className "AcDbTableStyle")
  
    (setq customObj (vla-AddObject dictObj keyName className))
      
    (vla-put-Name customObj "NewStyle")
    (vla-put-Description customObj "New Style for My Tables")
  
    (vla-put-FlowDirection customObj acTableTopToBottome)
    (vla-put-HorzCellMargin customObj 0.05)
    (vla-put-VertCellMargin customObj 0.05)
    (vla-put-BitFlags customObj 1)
    (vla-SetTextHeight customObj (+ acDataRow acTitleRow) .1)
    (vla-SetTextStyle customObj (+ acDataRow acTitleRow) "Standard")

    (setq col (vlax-create-object (strcat "AutoCAD.AcCmColor." (substr (getvar "ACADVER") 1 2))))
    (vla-SetRGB col 12 23 45)
  
    ;(vla-SetBackgroundColor customObj (+ acDataRow acTitleRow) col)
    (vla-SetGridVisibility customObj (+ acHorzInside acHorzTop) (+ acDataRow acTitleRow) :vlax-true)
    (vla-SetAlignment customObj (+ acDataRow acTitleRow) acMiddleCenter)
    (vla-SetRGB col 244 0 0)
    (vla-SetGridColor customObj (+ acHorzTop acHorzInside) acDataRow col)
      
    (alert (strcat "Table Style Name = " (vla-get-Name customObj)
                   "\nStyle Description = " (vla-get-Description customObj)
                   "\nFlow Direction = " (itoa (vla-get-FlowDirection customObj))
                   "\nHorzontal Cell Margin = " (rtos (vla-get-HorzCellMargin customObj) 2)
                   "\nVertical Cell Margin = " (rtos (vla-get-VertCellMargin customObj) 2)
                   "\nBit Flags = " (itoa (vla-get-BitFlags customObj))
                   "\nTitle Row Text Height = " (rtos (vla-GetTextHeight customObj acTitleRow) 2)
                   "\nTitle Row Text Style = " (vla-GetTextStyle customObj acTitleRow)
                   "\nGrid Visibility for HorizontalBottom TitleRow  = " (if (= (vla-GetGridVisibility customObj acHorzBottom acTitleRow) :vlax-true) "True" "False")
                   "\nTitle Row Alignment = " (itoa (vla-GetAlignment customObj acTitleRow))
	           "\nHeader Suppression = " (if (= (vla-get-HeaderSuppressed customObj) :vlax-true) "True" "False")
	   )
    )
    (vlax-release-object col)
)

