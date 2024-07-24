;|
  Inserts Block. Uses the "getBlockPath" function for finding the latest version.
  @Param sub_fldr subfolder to extend the ACADPREFIX path
  @Param block_name Name of block
  @Param pt_insert Insertion Point : "get" to have user pick a point, or predefined coordinates '(x y z)
  @Returns Inserted Block and Object ID of Block Reference
|;
(defun insert-block (sub_fldr block_name pt_insert / doc docSpace obj_acad)
  (cond
    ((= pt_insert "get")
      (setq pt_xyz (getpoint "Insertion Point:"))
      (setq obj_pt_insert (vlax-3d-point (car pt_xyz) (cadr pt_xyz) (caddr pt_xyz)))
    )
    (T
      (setq obj_pt_insert (vlax-3d-point (car pt_insert) (cadr pt_insert) (caddr pt_insert)))
    )
  )

  (cond
    ((= (getvar "tilemode") 0)
      (setq full_block_name (f:getBlockPath sub_fldr block_name )
            blockRefObj (vla-InsertBlock (paperSpace) obj_pt_insert full_block_name 1 1 1 0)
      )
    )
    ((= (getvar "tilemode") 1)
      (setq full_block_name (f:getBlockPath sub_fldr block_name )
            blockRefObj (vla-InsertBlock (modelSpace) obj_pt_insert full_block_name 1 1 1 0)
      )
    )
   )
)

; (insert-block "Blocks\\Cnc & Hardware Parts" "ADJUSTABLE SHELF SOLID.dwg" "get")
; (insert-block "Blocks\\Cnc & Hardware Parts" "MODELSPACE FABRICATION DETAILS TO FREEZE-01.dwg" '(0 0 0))
; (insert-block "Blocks\\@@COMBINED Blocks" "@COMBINED-TITLE BLOCK-02.dwg" '(0 0 0))


;C:\Users\Chris Lipinski\Dropbox (Personal)\Library\Blocks\Cnc & Hardware Parts\ADJUSTABLE SHELF SOLID.dwg
;C:\Users\Chris Lipinski\Dropbox (Personal)\Library\Blocks\Cnc & Hardware Parts\MODELSPACE FABRICATION DETAILS TO FREEZE-01.dwg
;C:\Users\Chris Lipinski\Dropbox (Personal)\Library\Blocks\@@COMBINED Blocks\@COMBINED-TITLE BLOCK-02.dwg