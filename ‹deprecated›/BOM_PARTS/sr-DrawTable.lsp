(defun DrawTable  ( tabulatedData tableLocation layoutName / 
                    col row ColWidth layoutBlk tableObj colHeader rowData cellData )
  (setvar 'ctab layoutName)

  (setq papSpace      (vla-get-PaperSpace (vla-get-ActiveDocument (vlax-get-acad-object)))
        ColWidth      1.00
        tableTitle    (car  tabulatedData)
        tableHeaders  (cadr tabulatedData)
        tableObj      (vla-AddTable papSpace tableLocation (length tabulatedData) (length tableHeaders) 0.25 ColWidth )
  )
  (vla-put-regeneratetablesuppressed tableObj :vlax-true)

  ;(princ "\nInsert Title");
  (vla-setText tableObj 0 0 (car tableTitle))
  (vla-SetRowHeight tableObj 0 0.36)
  (vla-SetCellAlignment tableObj 0 0 acMiddleCenter)

  ;(princ "\nInsert Headers")
  (setq col -1)
  (foreach colHeader tableHeaders
    (vla-setText tableObj 1 (setq col (1+ col)) colHeader)
    (vla-SetCellAlignment tableObj 1 col acMiddleCenter)
    (vla-SetRowHeight tableObj 1 0.25)
    (cond
      ((= colHeader "QTY")          (setq ColWidth 0.55))
      ((= colHeader "CALL OUT")     (setq ColWidth 1.65))
      ((= colHeader "DESCRIPTION")  (setq ColWidth 3.25))
      ((= colHeader "SIZE")         (setq ColWidth 2.00))
      ((= colHeader "NOTE")         (setq ColWidth 2.2875))
    )
    (vla-SetColumnWidth tableObj col ColWidth)
  )

  ;(princ "\nInsert Data\n")
  (setq row 2)
  (foreach rowData (cddr tabulatedData)
    (vla-SetRowHeight tableObj row 0.25)
    (setq col 0)
    (foreach cellData rowData
      (vla-setText tableObj row col cellData)
      (if (< col 2)
        (vla-SetCellAlignment tableObj row col acMiddleCenter)
        (progn
          (vla-SetCellAlignment tableObj row col acMiddleLeft)
          (vla-SetMargin        tableObj row col (+ acCellMarginLeft acCellMarginRight) 0.1)
        )
      )
      (setq col (1+ col))
    )
    (setq row (1+ row))
  )
  (vla-put-regeneratetablesuppressed tableObj :vlax-false)
  (vla-get-width tableObj) ; Return Width of Table
)
