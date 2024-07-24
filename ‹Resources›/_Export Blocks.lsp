(progn
  (setq collection_blocks     (vla-get-Blocks (actvDoc))
        path_dwg              (getvar 'DWGPREFIX)
        path_combined_blocks  "@COMBINED Blocks\\"
        path_nested_blocks     (strcat path_combined_blocks "Nested\\")
  )
  (textscr)
  (vlax-for obj_Block collection_blocks 
      (if (wcmatch (vla-get-Name obj_Block) "`@*-02")
          (progn
            (setq block_name  (vla-get-Name obj_Block))
            (princ (strcat "\nExporting @Combined Block " block_name))
            (command-s "-WBLOCK" (strcat path_dwg path_combined_blocks block_name) block_name )
          )
      )
  )

  (vlax-for obj_Block collection_blocks 
      (if (wcmatch (vla-get-Name obj_Block) "*-02")
          (if (not (wcmatch (vla-get-Name obj_Block) "`@*-02"))
            (progn
              (setq block_name  (vla-get-Name obj_Block))
              (princ (strcat "\nExporting Nested Block " block_name))
              (command-s "-WBLOCK" (strcat path_dwg path_nested_blocks block_name) block_name )
            )
          )
      )
  )
  (princ)
)
