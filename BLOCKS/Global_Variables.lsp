;;┌──────────────────────────────────────────────────────────────────────┐
;;│ Define Initialized global variables                                  │
;;└──────────────────────────────────────────────────────────────────────┘
(setq *acadObj* nil) ; Initialize global variable
(defun acadObj ()
  (cond (*acadObj*) ; Return the cached object
    (t
      (setq *acadObj* (vlax-get-acad-object))
    )
  )
)

;; (vla-get-ActiveDocument (vlax-get-acad-object))
(setq *actvDoc* nil) ; Initialize global variable
(defun actvDoc ()
  (cond (*actvDoc*) ; Return the cached object
    (t
      (setq *actvDoc* (vla-get-ActiveDocument (acadObj)))
    )
  )
)

(setq *modelSpace* nil) ; Initialize global variable
(defun modelSpace ()
  (cond (*modelSpace*) ; Return the cached object
    (t
      (setq *modelSpace* (vla-get-ModelSpace (actvDoc)))
    )
  )
)

(setq *paperSpace* nil) ; Initialize global variable
(defun paperSpace ()
  (cond (*paperSpace*) ; Return the cached object
    (t
      (setq *paperSpace* (vla-get-PaperSpace (actvDoc)))
    )
  )
)
