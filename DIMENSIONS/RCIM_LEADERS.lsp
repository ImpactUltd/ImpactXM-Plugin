(defun RcimLeader (/ *error* *cleanUp* f:get-view-port-obj f:get-scim-part-number-value f:add-mleader check_point ent_group ent_group_ID index list_obj_points list_obj_MLeaders list_obj_PartNums obj_partNum_handle obj_partNum_ID obj_point obj_vport paperSpace pt_1 pt_2 pt_label pt_llc pt_llc_m pt_location pt_start pt_urc pt_urc_m pt_y sset_ent_objects sset_points str_label sysvar_CMLEADERSTYLE sysvar_PDMODE sysvar_PDSIZE sysvar_SELECTIONCYCLING y_spacer zoom_previous vport_selected vport_VS list_label_points)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
    (*cleanUp*)
  )

  (defun *cleanUp* nil 
    (foreach x (dict-get-keys-values "RCIM_points")
      (setq obj_point (vlax-ename->vla-object (handent (cadr x))))
      (vla-Delete obj_point)
    )
    (if vport_VS
      (progn
        (princ "\nRESETTING...")
        (vla-put-VisualStyle obj_vport vport_VS)
        (vla-Display obj_vport :vlax-false)
        (vla-Display obj_vport :vlax-true)
      )
    )

    (dict-delete-dict "RCIM_points")
    (dict-delete-dict "RCIM_SPN_blocks")
    (dict-delete-dict "RCIM_leader_content")

    (setvar "SELECTIONCYCLING" sysvar_selectioncycling)
    (setvar "PDMODE"           sysvar_PDMODE)
    (setvar "PDSIZE"           sysvar_PDSIZE)
    (setvar "CMLEADERSTYLE"    sysvar_CMLEADERSTYLE)
    (setvar "LUNITS"           sysvar_LUNITS)
    (setvar "LUPREC"           sysvar_LUPREC)
    (setvar "AUNITS"           sysvar_AUNITS)
    (setvar "AUPREC"           sysvar_AUPREC)
    (setvar "INSUNITS"         sysvar_INSUNITS)
    (vla-put-ActiveLayer (actvDoc) layer_current)
  )

  (defun f:get-view-port-obj ( / num_ents obj_sel ent_sel sset_v obj_vport)
    (if (and  (setq ent_sel (entsel "\nSelect the viewport: "))
              (setq obj_sel (vlax-ename->vla-object (car ent_sel)))
        );and
          (if (not (= (vla-get-ObjectName obj_sel) "AcDbViewport"))
            (if (setq sset_v (ssget (cadr ent_sel)))
              (repeat (setq num_ents (sslength sset_v))
                (setq obj_sel (vlax-ename->vla-object (ssname sset_v (setq num_ents (1- num_ents)))))
                (if (= (vla-get-ObjectName obj_sel) "AcDbViewport")
                  (setq obj_vport obj_sel)
                )
              )
            )
            (setq obj_vport obj_sel)
          )
      )    
    obj_vport
  )

  (defun f:get-scim-part-number-value (obj_ScimPartNumber / list_Attributes)
    (setq list_Attributes (vlax-variant-value (vla-GetAttributes obj_ScimPartNumber))) 
    (vla-get-TextString (vlax-safearray-get-element list_Attributes 0))
  )

  (defun f:add-mleader (list_points str_label / array_points paperSpace obj_MLeader o)
    ;; Define the leader points
    (setq array_points (vlax-make-safearray vlax-vbDouble '(0 . 5)))
    (vlax-safearray-fill array_points list_points)
    ;; Get ready to draw MLeaders in paperSpace
    (setq paperSpace (vla-get-PaperSpace (actvDoc)))
    ;; Draw the MLeader
    (setq obj_MLeader (vla-AddMLeader paperSpace array_points 0))
    ;; Update MLeader Block Content
    (vlax-for o (vla-Item (vla-get-Blocks (actvDoc)) (vla-get-ContentBlockName obj_MLeader))
        (if (= (vla-get-ObjectName o) "AcDbAttributeDefinition")
          (vla-SetBlockAttributeValue obj_MLeader (vla-get-ObjectID o) str_label)
        )
    )
    ;; change the MLeader Style to truely update (vla-Update does not work)
    ;(vla-put-StyleName obj_MLeader "Standard")
    (vla-put-StyleName obj_MLeader "RCIM-PART")
    ;; Update again, for good measure
    obj_MLeader
  )

  (defun f:get-hangle (ent_A / reactors)
    (setq reactors (member '(102 . "{ACAD_REACTORS") (entget ent_A)))
    (if reactors
      (cdr (assoc 5 (entget (cdr (assoc 330 reactors)))))
      (cdr (assoc 5 (entget ent_A)))
    )
  )


  ;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀;
  ; MAIN
  ;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄;
  ; use (trans (trans pt 3 2) 2 0) with active vp to convert PS points to MS points
  ; use (trans (trans pt 1 2) 2 3) with active vp to convert MS points to PS points (and 3dPt->2dPt)
  (vla-StartUndoMark (actvDoc))

  (setq sysvar_SELECTIONCYCLING (getvar "SELECTIONCYCLING")
        sysvar_PDMODE           (getvar "PDMODE")
        sysvar_PDSIZE           (getvar "PDSIZE")
        sysvar_CMLEADERSTYLE    (getvar "CMLEADERSTYLE")
        sysvar_LUNITS           (getvar "LUNITS")
        sysvar_LUPREC           (getvar "LUPREC")
        sysvar_AUNITS           (getvar "AUNITS")
        sysvar_AUPREC           (getvar "AUPREC")
        sysvar_INSUNITS         (getvar "INSUNITS")
        collection_layers       (vla-get-Layers (actvDoc))
        layer_current           (vla-get-ActiveLayer (actvDoc))
        layer_0                 (vla-Item collection_layers "0")
        layer_ScimPartNumbers   (vl-catch-all-apply 'vla-Item (list collection_layers "_ScimPartNumbers"))
  )
  (if (vl-catch-all-error-p layer_ScimPartNumbers)
    (progn
      (alert "It appears that this drawing does NOT contain any RouterCIM parts.\nThis command is not available.")
      (setq is_RCIM_dwg nil)
    )
    (setq is_RCIM_dwg T)
  )
  (setvar "SELECTIONCYCLING" 0)
  (setvar "PDMODE"           99)
  (setvar "PDSIZE"           -2.5)
  (setvar "LUNITS"           2)
  (setvar "LUPREC"           6)
  (setvar "AUNITS"           0)
  (setvar "AUPREC"           2)
  (setvar "INSUNITS"         1)
  (setq MLeader_layer (vla-Add (vla-get-Layers (actvDoc)) "MD_Annotation"))
  (vla-put-Color MLeader_layer acCyan)
  
  ;(vla-put-ActiveLayer (actvDoc) layer_0)

  (if (and (= 1 (getvar 'cvport)) is_RCIM_dwg)
    (while (not vport_selected)
      (if (setq obj_vport (f:get-view-port-obj))
        (progn
          ;(vla-ZoomAll (acadObj))
          ;(vla-Regen (actvDoc) acAllViewports)
          (command-s "UCS" "WORLD")
          (vla-Display obj_vport :vlax-false)
          (vla-Display obj_vport :vlax-true)
          (vla-put-MSpace (actvDoc) :vlax-true)
          (vla-put-ActivePViewport (actvDoc) obj_vport)
          (setq vport_VS (vla-get-VisualStyle obj_vport))
          (command-s "-VISUALSTYLES" "C" "2D")
          (command-s "UCS" "WORLD")
          (command-s "VPLAYER" "THAW" "_ScimPartNumbers" "CURRENT" "")
          ;(vla-Regen (actvDoc) acActiveViewport)
          (vla-GetBoundingBox obj_vport 'pt_llc 'pt_urc)
          (setq pt_llc (vlax-safearray->list pt_llc)
                pt_urc (vlax-safearray->list pt_urc))
          (setq pt_llc_m (trans (trans pt_llc 3 2 ) 2 0)
                pt_urc_m (trans (trans pt_urc 3 2 ) 2 0)
          )
          (setq sset_ent_objects (ssget "_C" pt_llc_m pt_urc_m ))
          (princ "\n")
          (if sset_ent_objects
            (princ (setq num_objects-sel (sslength sset_ent_objects)))
            (princ "0")
          )
          (princ " object(s) selected.")

          (if (> num_objects-sel 0)
            (progn
              (setq list_obj_objects (SelectionSet->objList sset_ent_objects))
              (foreach obj_object list_obj_objects
                (if (= (vla-get-ObjectName obj_object) "AcDbBlockReference" )
                  (if (= (cl:GetEffectiveBlockName obj_object) "ScimPartNumber")
                    (setq list_obj_PartNums (cons obj_object list_obj_PartNums))
                  )
                )
              )
              (princ "\n")
              (princ (length list_obj_PartNums))
              (princ " \"ScimPartNumber\" block(s) filtered.")
              (foreach obj_PartNum list_obj_PartNums
                ;; TODO: create alternative for missing groups
                (setq ent_group_ID (f:get-hangle (vlax-vla-object->ename obj_PartNum)))

                ;(setq ent_group (entget (cdr (nth 7 (entget (vlax-vla-object->ename obj_PartNum))))))
                ;(setq ent_group_ID (cdr (assoc 5 ent_group)))
                (dict-add-record "RCIM_SPN_blocks" ent_group_ID obj_PartNum)
              )
              (setq list_obj_PartNums (dict-get-values "RCIM_SPN_blocks"))

              (foreach obj_PartNum list_obj_PartNums
                (setq str_label (f:get-scim-part-number-value obj_PartNum))
                (setq pt_label  (3dPt->2dPt (trans (trans (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint obj_PartNum))) 1 2 ) 2 3 )))
                (setq obj_partNum_ID (vla-get-ObjectID obj_PartNum))
                (setq obj_partNum_handle (vla-get-Handle obj_PartNum))
                (dict-add-record "RCIM_points" obj_partNum_handle (list (append pt_label '(0.0)) str_label))
              )
              (command-s "VPLAYER" "FREEZE" "_ScimPartNumbers" "CURRENT" "")
              (vla-put-MSpace (actvDoc) :vlax-false)
              (vla-put-VisualStyle obj_vport vport_VS)
              (vla-Display obj_vport :vlax-false)
              (setq paperSpace (vla-get-PaperSpace (actvDoc)))
              (foreach e (dict-get-keys-values "RCIM_points")
                (setq pt_location (vlax-3d-point (cadr e))
                      obj_point   (vla-AddPoint paperSpace pt_location))
                (vla-put-Layer obj_point "0")
                (if (setq check_point (ssget "_C" (cadr e) (cadr e) ))
                  (vla-put-Color obj_point acRed)
                  (vla-put-Color obj_point acYellow)
                )
                
                (dict-add-record "RCIM_points" (car e) (append (list (vla-get-Handle obj_point)) (cdr e)))
                (dict-add-record "RCIM_leader_content" (vla-get-Handle obj_point) (list (cadr e) (cddr e)))

              )
              (vla-Display obj_vport :vlax-true)
            );progn
          );if

          ;(foreach x (dict-get-keys-values "RCIM_points") (print x))

          (setq vport_selected T)
        );progn
      );if
    );while
    (princ "\nCommand not available in Modelspace.")
  );if

  ;(princ "\nRCIM_SPN_blocks") (foreach x (dict-get-keys-values "RCIM_SPN_blocks") (princ "\n   ") (prin1 x))  
  ;(princ "\nRCIM_points") (foreach x (dict-get-keys-values "RCIM_points") (princ "\n   ") (prin1 x))
  ;(princ "\nRCIM_leader_content") (foreach x (dict-get-keys-values "RCIM_leader_content") (princ "\n   ") (prin1 x))


  (vla-Regen (actvDoc) acAllViewports)
  (princ "\n")
  (princ (setq num_points_sel (length (dict-get-keys-values "RCIM_points"))))
  (princ " point label(s) generated.")
  
  (if (and (> num_points_sel 0) (setq sset_points (ssget '((0 . "POINT")))))
    (progn
      (princ (strcat "\n" (itoa (sslength sset_points)) " point(s) selected."))
      (progn 
        ; Insert block with RCIM-PART MLeader Style (and STANDARD in case it does not exist)
        (command "-INSERT" "Resources\\Blocks\\RCIM-PART.dwg")
        (command)
        (command)
      )
      (setvar "CMLEADERSTYLE" "RCIM-PART")
      (setq y_spacer 0.5312
            pt_y     0.0)
      (if (setq pt_start (getpoint "\nPick starting point for RCIM_Leaders: "))
        (progn
          ;(command-s "POINT" pt_start)
          (repeat (sslength sset_points)
            (setq list_label_points (cons (list (car pt_start) (+ pt_y (cadr pt_start)) 0.0) list_label_points))
            (setq pt_y (- pt_y y_spacer ))
          )
        )
      )
      ;(foreach x list_label_points (print x))
      ;(foreach x (dict-get-keys-values "RCIM_leader_content") (print x))
      (setq list_obj_points (SelectionSet->objList sset_points) 
            index 0)
      (foreach x list_obj_points
        (setq pt_1  (car (dict-get-record "RCIM_leader_content" (vla-get-Handle x)))
              pt_2  (nth index list_label_points)
              index (1+ index)
        )
        (vla-put-ActiveLayer (actvDoc) MLeader_layer)
        (setq list_obj_MLeaders (cons (f:add-mleader (append pt_1 pt_2) (caadr (dict-get-record "RCIM_leader_content" (vla-get-Handle x)))) list_obj_MLeaders))
      )
      (f:clean-intersections list_obj_MLeaders)
    )
    (progn
      (princ "\nNo points selected.")
    )
  );if
  
  
  ;; CLEAN UP
  (*cleanUp*)
  
  (vla-EndUndoMark (actvDoc))
  (princ)
);defun

(defun c:RCIM_LEADERS ()
  (if (vl-file-directory-p "L:/AutoCAD/LISP/AutoCAD Plugins/ImpactXM/DIMENSIONS")
    (progn
      (load "L:/AutoCAD/LISP/AutoCAD Plugins/ImpactXM/DIMENSIONS/RCIM_LEADERS.lsp")
      (RcimLeader)
    )
    (RcimLeader)
  )
)
