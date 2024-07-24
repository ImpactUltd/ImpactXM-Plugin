(defun c:REDEFINE_IXM_BLOCKS ( / f:RedefineBlocks)
  (defun f:RedefineBlocks ( / list_blocks list_nested_blocks name_block sysvar_CMDECHO)
    (defun *error* ( msg )
      (if (= 'file (type des)) (close des))
      (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
        (princ (strcat "\nError: " msg))
        (princ (strcat "\n" msg " by User"))
      )  
      (if sysvar_CMDECHO (setvar 'CMDECHO sysvar_CMDECHO))
      (princ)
    )

    
    (setq sysvar_CMDECHO (getvar 'CMDECHO)
          path_plugin  (strcat (f:GetPlugInPath "*IMPACT XM PLUG-INS.BUNDLE*") "Resources\\")
          path_cblocks (strcat path_plugin "Blocks\\@COMBINED Blocks\\")
          path_nblocks (strcat path_cblocks "Nested\\")
    ) ; setq

    (setvar 'CMDECHO 0)

    (foreach block_dwg (vl-directory-files path_cblocks "*.dwg" 1)
      (setq name_block (vl-filename-base block_dwg))
      (setq list_blocks (cons name_block list_blocks))
    )
    (foreach block_dwg (vl-directory-files (strcat path_nblocks) "*.dwg" 1)
      (setq name_block (vl-filename-base block_dwg))
      (setq list_nested_blocks (cons name_block list_nested_blocks))
    )

    (textscr)
    (foreach block_name list_blocks 
      (princ (strcat "\nInserting / Redefining combined block: " block_name))
      (princ (strcat "\nfrom " path_cblocks ))
      (command "-INSERT" (strcat block_name "=" path_cblocks block_name))
      (command)
      (command)
    )

    (foreach block_nested_name list_nested_blocks 
      (princ (strcat "\nInserting / Redefining  nested  block: " block_nested_name))
      (princ (strcat "\nfrom " path_nblocks ))
      (command "-INSERT" (strcat block_nested_name "=" path_nblocks block_nested_name))
      (command)
      (command)
    )
    (setvar 'CMDECHO sysvar_CMDECHO)
    (princ)
  )
  (f:RedefineBlocks)
)