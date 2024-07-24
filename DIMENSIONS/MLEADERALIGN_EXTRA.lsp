(defun f:swap-leaders (obj_mldr_A obj_mldr_B / list_pts_A1 list_pts_B1 list_pts_A 
                       list_pts_B var_pts_A1 var_pts_B1
                      ) 
  (setq list_pts_A  (vlax-safearray->list 
                      (vlax-variant-value (vla-GetLeaderLineVertices obj_mldr_A 0))
                    )
        list_pts_B  (vlax-safearray->list 
                      (vlax-variant-value (vla-GetLeaderLineVertices obj_mldr_B 0))
                    )
        list_pts_A1 (append 
                      (list (car list_pts_A) (cadr list_pts_A) (caddr list_pts_A))
                      (cdddr list_pts_B)
                    )
        list_pts_B1 (append 
                      (list (car list_pts_B) (cadr list_pts_B) (caddr list_pts_B))
                      (cdddr list_pts_A)
                    )
        var_pts_A1  (vlax-make-safearray vlax-vbDouble '(0 . 5))
        var_pts_B1  (vlax-make-safearray vlax-vbDouble '(0 . 5))
  )
  (vlax-safearray-fill var_pts_A1 list_pts_A1)
  (vlax-safearray-fill var_pts_B1 list_pts_B1)
  (vla-SetLeaderLineVertices obj_mldr_A 0 var_pts_A1)
  (vla-SetLeaderLineVertices obj_mldr_B 0 var_pts_B1)
  (princ)
)

(defun f:swap-if-intersect (obj_mldr_A obj_mldr_B / obj_intersect) 
  (setq obj_intersect (vlax-safearray-get-u-bound 
                        (vlax-variant-value 
                          (vla-IntersectWith obj_mldr_A obj_mldr_B acExtendNone)
                        )
                        1
                      )
  )
  (if (> obj_intersect 0) 
    (f:swap-leaders obj_mldr_A obj_mldr_B)
  )
  obj_intersect
)

(defun f:clean-intersections (list_obj_mldrs / count ML1 ML2 int_test_inters 
                              num_mldrs
                             ) 
  (setq int_test_inters 1
        count           1
        num_mldrs       (length list_obj_mldrs)
        int_max_loops   0
  )
  (princ "\nDetecting intersections .")
  (while (< int_test_inters num_mldrs) 
    (setq ML2 1)
    (repeat (1- num_mldrs) 
      (setq ML1 0)
      (repeat num_mldrs 
        (if 
          (= 
            (f:swap-if-intersect (nth ML1 list_obj_mldrs) (nth ML2 list_obj_mldrs))
            -1
          )
          (setq count (1+ count))
        )
        (setq ML1 (1+ ML1))
      )
      (setq ML2 (1+ ML2))

      (if (= count num_mldrs) 
        (setq int_test_inters (1+ int_test_inters))
      )
      (setq count 1)
      (princ ".")
    )
    (if (= int_max_loops 25) 
      (progn (setq int_test_inters num_mldrs) 
             (princ "\nComplete non-intersecting solution not found")
      )
      (progn (setq int_max_loops (1+ int_max_loops)) (princ "."))
    )
  )
  (princ)
)

(defun c:MLEADER_SWAP (/ ent_mldr_A ent_mldr_B obj_mldr_A obj_mldr_B) 
  (setq ent_mldr_A (car (entsel "\nSelect first MLeader:"))
        obj_mldr_A (vlax-ename->vla-object ent_mldr_A)
        ent_mldr_B (car (entsel "\nSelect second MLeader:"))
        obj_mldr_B (vlax-ename->vla-object ent_mldr_B)
  )
  (f:swap-leaders obj_mldr_A obj_mldr_B)
  (princ)
)

(defun c:MLEADERALIGN_CLEAN_DISTRIBUTE () 
  (setq sset_mldrs     (ssget '((0 . "MULTILEADER")))
        list_obj_mldrs (SelectionSet->objList sset_mldrs)
  )
  (command-s "MLEADERALIGN" sset_mldrs "" "OPTIONS" "DISTRIBUTE" pause pause)
  (f:clean-intersections list_obj_mldrs)
)
