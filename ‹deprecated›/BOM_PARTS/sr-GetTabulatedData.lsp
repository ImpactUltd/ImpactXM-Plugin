(defun GetTabulatedData ( oSSet 
                        / tableData tableHeader attdata attitem ent blockObject attribs tags 
                          SumAndGroupParts ATTS BLKDATA BLKNAME BLKOBJ COLUMNHEADERS)
  (defun SumAndGroupParts (lst / groups res sum tmp)
    (while lst
      (setq tmp     (car lst)
            sum     (apply '+ (mapcar 'car (setq res  (vl-remove-if-not '(lambda (a) (vl-every 'eq a tmp)) lst))))
            groups  (cons (subst (itoa sum) (car tmp) tmp) groups)
            lst     (vl-remove-if '(lambda (a) (member a res)) lst)
      )
    )
    (reverse groups)
  )

  (setq tableData nil
        attdata   nil
        attitem   nil
  )
  (setq ent (car oSSet))
  (setq blockObject (vlax-ename->vla-object ent))
  (setq attribs (vlax-invoke blockObject 'GetConstantAttributes))
  (setq tableHeader (vla-get-textstring (car attribs)))
  (foreach attrib attribs
    (setq tags (cons (vla-get-tagstring attrib) tags))
  )
  (setq tags (cdr (reverse tags)))
  (foreach entA oSSet
    (setq blkobj  (vlax-ename->vla-object entA)
          blkname (vla-get-effectivename blkobj)
    )
    (setq atts (vlax-invoke blkobj 'GetConstantAttributes))
    (foreach attobj atts
      (if (member (vla-get-tagstring attobj) tags)
        (progn
          (setq attitem (cons (vla-get-tagstring attobj) (vla-get-textstring attobj)))
          (setq attdata (cons attitem attdata))
        )
      )
    )
    (setq blkdata (append (list 1 blkname) (reverse attdata)))
    (setq tableData (cons blkdata tableData))
    (setq attdata nil
          attitem nil
    )
  )

  (setq tableData (mapcar '(lambda (x) (append (list (car x) (cadr x)) (mapcar 'cdr (cddr x)))) tableData))

  ;; Sum up similar items and Group them
  (setq tableData (SumAndGroupParts tableData))
  ;(princ tableData) (princ "\n")
  ;; Sort by "CALL OUT" :
  (setq tableData (vl-sort tableData '(lambda (a b) (< (cadr a) (cadr b)))))
  (setq columnHeaders (list "QTY" "CALL OUT" "DESCRIPTION" "SIZE" "NOTE"))
  (cons (list tableHeader) (cons columnHeaders tableData)) ; Return Table Data 
)
