(defun C:INSERT_MULTIPLE ( / dir )
	(setq msg "Insert Multiple"
        ext "dwg;dxf"
        dir (vl-filename-directory (f:getBlockPath "Blocks" "."))
        list_files (cl:getfiles msg dir ext))
  (princ list_files)
  (setq pt_insert (getpoint "\nPick Point for insertion:"))
  (foreach block_path_file list_files 
      (setq block_name (vl-filename-base      block_path_file)
            block_path (vl-filename-directory block_path_file)
            block_extn (vl-filename-extension block_path_file)
      )
      (princ (strcat "\nInserting (and redefining) block: " block_name))
      (command "-INSERT" (strcat block_name "=" block_path "\\" block_name block_extn) pt_insert "" "" 0)
  )
  (princ)
)
