(defun c:RESET_DYNAMIC_BLOCKS ()
	(setq list_blocks (SelectionSet->entList (ssget '((0 . "INSERT")))))
	(foreach block_ent list_blocks
		(command "ATTSYNC" "SELECT" block_ent "YES")
		(command "RESETBLOCK" block_ent "")
	)
	(princ)
)
