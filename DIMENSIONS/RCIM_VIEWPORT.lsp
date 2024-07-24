(defun RcimViewport (/ *error* list_VP_freeze vport_selected f:get-view-port-obj)
  (vl-load-com)
  (defun *error* (msg)
    (vla-EndUndoMark (actvDoc))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User"))
    )
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

  (vla-StartUndoMark (actvDoc))

    ;(f:PurgeMain "A")
    (setq collection_layers   (vla-get-Layers (actvDoc))
          num_layers          (vla-get-Count collection_layers)
          layer_current       (vla-get-ActiveLayer (actvDoc))
          layer_0             (vla-Item collection_layers "0")
          index               0
          list_cabz_layers    (list "_CabzzHatch" 
                                    "_CabzzzTable" 
                                    "_ScimPartNumbers")
          list_tooling_layers (list "Bevel_*"
                                    "BevelInside_*"
                                    "CutOut_*"
                                    "DadoRec_*"
                                    "DoveTailDadoRec_*"
                                    "Hole_*"
                                    "OutSide_*"
                                    "PktCutOut_*"
                                    "Pocket_*"
                                    "PocketInside_*"
                                    "PocketOutside_*"
                                    "Profile_*"
                                    "RabbetRec_*")
    
          VPort_layer   (vla-Add (vla-get-Layers (actvDoc)) "Viewports")
          obj_TrueColor (vlax-create-object (strcat "AutoCAD.AcCmColor." (substr (getvar "ACADVER") 1 2)))
    )
    (vla-SetRGB obj_TrueColor 192 192 255)
    (vla-put-TrueColor VPort_layer obj_TrueColor)

    ;(vla-put-ActiveLayer  (actvDoc) layer_0)

    (foreach tooling_layer list_tooling_layers
      (setq index 0)
      (while (>= (- num_layers 1) index)
          (setq obj_layer (vla-Item collection_layers index)
                name_layer (vla-get-Name obj_layer)
                index (1+ index))
          (if (wcmatch name_layer tooling_layer)
            (setq list_VP_freeze (consU name_layer list_VP_freeze))
          )
      )
    )
    (setq list_VP_freeze (append list_VP_freeze list_cabz_layers)
          list_VP_freeze (list->string list_VP_freeze ","))
    (while (not vport_selected)
      (if (setq obj_vport (f:get-view-port-obj))
        (progn
          (vla-Regen (actvDoc) acAllViewports)
          (command-s "VPLAYER" "FREEZE" list_VP_freeze "SELECT" (vlax-vla-object->ename obj_vport) "" "")
        )
      )
      (setq vport_selected T)
    )
    (vla-put-Layer obj_vport (vla-get-Name VPort_layer))
    (vla-put-ShadePlot obj_vport acShadePlotHidden)

    ;(vla-put-ActiveLayer  (actvDoc) layer_current)
    
  (vla-EndUndoMark (actvDoc))
  (princ)
)
(defun c:RCIM_VIEWPORT ()
  (if (vl-file-directory-p "L:/AutoCAD/LISP/AutoCAD Plugins/ImpactXM/DIMENSIONS")
    (progn
      (load "L:/AutoCAD/LISP/AutoCAD Plugins/ImpactXM/DIMENSIONS/RCIM_VIEWPORT.lsp")
      (RcimViewport)
    )
    (RcimViewport)
  )
)
