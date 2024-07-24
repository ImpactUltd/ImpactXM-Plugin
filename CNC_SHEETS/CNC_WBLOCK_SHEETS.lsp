(defun c:CNC_WBLOCK_SHEETS  ( / *error* 
                             sysvar_OSMODE
                             list_obj_blocks list_obj_TBlocks obj_block 
                             sset_CNC pt1_CNC_win pt2_CNC_win pt1_CNC_org 
                             obj_TBlock pt_TBlockIns pt2_org pt1_org
                             pt1_win pt2_win pt1_org obj_cnc
                             enum_mode index file_name file_path file_name_path
                             obj_toHide sset_toHide
                            )
  (defun *error* (msg)
    (if (not
          (member msg '("Function cancelled" "quit / exit abort"))
        )
      (princ (strcat "\nError: " msg))
    )
    (setvar 'OSMODE sysvar_OSMODE)
    (vlax-for obj_toHide sset_toHide
      (vla-put-Visible obj_toHide :vlax-true)
    )
    (vla-Delete sset_CNC)
    (vla-Delete sset_toHide)
    (vla-ZoomPrevious (acadObj))
    (vla-Regen (actvDoc) acAllViewports)
    (princ)
  )
  (vla-StartUndoMark (actvDoc))
  (setq sysvar_OSMODE (getvar 'OSMODE))
  (setvar 'OSMODE 0)
  
  ;; Select CNC Layouts and Filter CNC Title Blocks
  (setq list_obj_blocks (SelectionSet->objList (ssget '((0 . "INSERT")))))
  (foreach obj_block list_obj_blocks      
      (if (and (= (cl:GetConstantAttributeValue obj_block "TITLE_BLOCK_VERSION") "2.6" )
               (= (cl:GetDynPropValue obj_block "DRAWING TYPE") "CNC (8.5 x 11 only)"))
          (setq list_obj_TBlocks (cons obj_block list_obj_TBlocks))
      )
      
  )

  (setq sset_CNC    (vla-Add (vla-get-SelectionSets (actvDoc)) "CNC_SET")
        sset_toHide (vla-Add (vla-get-SelectionSets (actvDoc)) "HIDE_SET")
        pt1_CNC_win '(20.0   41.0  0.0)
        pt2_CNC_win '(142.0 103.0  0.0)
        pt1_CNC_org '(21.0   42.0  0.0)
  )
  (command-s "VSCURRENT" "2dwireframe")
  (command-s "UCS" "WORLD")
  (vla-Regen (actvDoc) acAllViewports)

  
  
  ;; If it doesn't exist, create a folder based on drawing name in the "Fabrication" folder
  (setq file_path (f:BuildFabricationDirectory)
        index     1
  )
  ;; Iterate through Title Blocks and extract CNC entities
  (foreach obj_TBlock list_obj_TBlocks
    (setq pt_TBlockIns (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint obj_TBlock)))
          pt1_win   (vlax-3d-point (mapcar '+ pt_TBlockIns pt1_CNC_win))
          pt2_win   (vlax-3d-point (mapcar '+ pt_TBlockIns pt2_CNC_win))
          pt1_org   (vlax-3d-point (mapcar '+ pt_TBlockIns pt1_CNC_org))
          pt2_org   (vlax-3d-point 0.0  0.0  0.0)
          file_name (cl:GetAttributeValue obj_TBlock "NC_PROG")
          file_name_path (strcat file_path "\\" file_name ".dwg")
    )
    
    ;; Select CNC entities and Move them to the Origin (0,0)
    (vla-Select sset_CNC acSelectionSetWindow pt1_win pt2_win)
    (vlax-for obj_cnc sset_CNC
      (vla-Move obj_cnc pt1_org pt2_org)
    )
    
    ;; Zoom to Origin area and WBLOCK objects
    (vla-ZoomWindow (acadObj) (vlax-3d-point -1.0  -1.0) (vlax-3d-point 121.0  61.0))
    (vla-Wblock (actvDoc) file_name_path sset_CNC)
    (princ (strcat "\nCNC layout " file_name " saved to:\n" file_name_path))
    
    ;; Move objects back to original position and zoom out
    (vlax-for obj_cnc sset_CNC
      (vla-Move obj_cnc pt2_org pt1_org)
    )
    (vla-Clear sset_CNC)
    (vla-ZoomPrevious (acadObj))
    
    (setq index (1+ index))
    (princ)
  )
  
  ;; Unhide the entities are the Origin Area
  (vlax-for obj_toHide sset_toHide
      (vla-put-Visible obj_toHide :vlax-true)
  )
  (vla-Delete sset_CNC)
  (vla-Delete sset_toHide)
  (command-s "UCS" "PREVIOUS")
  (vla-Regen (actvDoc) acAllViewports)
  (setvar 'OSMODE sysvar_OSMODE)
  
  (vla-EndUndoMark (actvDoc))
  (princ)
)

;; (princ "\nCNC_WBLOCK_SHEETS.VLX loaded.")
