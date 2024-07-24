;(princ "\n\nUse REDEFINE_IXM_TBLOCK to redefine IXM Title Block to the latest version.")
;(princ "\n\nUser must have a block drawing path in their support path")
;(princ "\n    such as \"C:\\Users\\detailer\\Dropbox\\Library\\Blocks\\\"")
;(princ "\n         or \"M:\\Global Operations\\Engineering\\Library\\Blocks\\\"")
;(princ "\n\nTitle Block file should be located in subfolder \n    \"@@COMBINED Blocks\" \n\nand named \n    \"@COMBINED-TITLE BLOCK-02.dwg\"")
;(princ "\n\n")

(defun c:REDEFINE_IXM_TBLOCK (/ *error* )
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))
  
  ; C:\Users\customer\Dropbox (Personal)\Library-tmp\Blocks\@@COMBINED Blocks\@COMBINED-TITLE BLOCK-02.dwg
  (setq pt_insertion (vlax-3d-point 0 0 0)
        name_block (f:getBlockPath "Blocks\\@@COMBINED Blocks" "@COMBINED-TITLE BLOCK-02.dwg")
        name_logo  (f:getBlockPath "Blocks\\@@COMBINED Blocks" "TBLOCK-IMPACT LOGO-02.dwg")
  )

  (setq obj_blockRef  (vla-InsertBlock (paperSpace) pt_insertion name_block 1 1 1 0)
        obj_blockLogo (vla-InsertBlock (paperSpace) pt_insertion name_logo 1 1 1 0)
  )
  
  (vla-Delete obj_blockLogo)
  
  (setq ent_blockRef (vlax-vla-object->ename obj_blockRef))
  
  (command "ATTSYNC" "SELECT" ent_blockRef "YES")
  
  (vla-Delete obj_blockRef)
  
  (f:ConvertTbToNoPages)
  ;(command "ERASE" ent_blockRef "")
  
  
  (vla-EndUndoMark (actvDoc))
  (princ)
)

;(load "C:\\Users\\customer\\Dropbox (Personal)\\AutoCAD Plugins\\IMPACT XM PLUG-INS.source\\BLOCKS\\GetBlockPath.lsp")
