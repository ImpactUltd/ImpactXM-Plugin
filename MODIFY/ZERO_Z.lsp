; =======================================================
;
; ZeroZ.lsp
;
; Change Z coordinate of all selected entities to 0 (OCS)
;
; Copyright (c) 2000 Michael Puckett All Rights Reserved
;
; =======================================================

  (defun c:ZERO_Z ( / *error* *begin* *end* *zeroz* *children* ss i ent ents )

  ; local defun *error*

  (defun *error* (s)
    (*end*)
    (princ (strcat "Error: " s ".\n"))
    (princ)
  )

  ; local defun *begin*

  (defun *begin* ()
    (setvar "cmdecho" 0)
      (while (eq 8 (logand 8 (getvar "undoctl")))
        (command ".undo" "_end")
      )
    (if (zerop (logand 2 (getvar "undoctl")))
      (if (eq 1 (logand 1 (getvar "undoctl")))
        (command ".undo" "_begin")
      )
    )
  )

  ; local defun *end*

  (defun *end* ()
    (if (eq 8 (logand 8 (getvar "undoctl")))
      (command ".undo" "_end")
    )
    (setvar "cmdecho" 1)
  )

  ; local defun *zeroz*

  (defun *zeroz* (ent)
    (entmod
      (mapcar
        '(lambda (x)
          (cond
            ( (member (car x) '(10 11 12 13 14))
              (cons (car x) (list (cadr x) (caddr x) 0.0))
            )
            ( (eq 38 (car x)) '(38 . 0.0))
            ( t x )
          )
        )
      (entget ent)
      )
    )
  )

  ; local defun *children*

  (defun *children* (ent / d r)
    (if (assoc 66 (entget ent))
      (reverse
        (while
          (/= "SEQEND"
          (cdr (assoc 0 (setq d (entget (setq ent (entnext ent))))))
          )
          (setq r (cons (cdr (assoc -1 d)) r))
        )
      )
    )
  )

  ; main

  (cond
    ( 
      (setq i -1 ss (ssget))
      (*begin*)
      (princ "\nZeroing Z's for entity(s) ...")
      (repeat (sslength ss)
        (*zeroz* (setq ent (ssname ss (setq i (1+ i)))))
        (foreach x (setq ents (*children* ent)) (*zeroz* x))
        (if ents (entupd ent))
        ; in case a bazillion entities were selected
        ; let the user know we have not died
        (if (zerop (rem i 100)) (princ "."))
      )
      (princ " [Done]")
      (*end*)
    )
    ( t (princ "\nNothing selected."))
  )
  ; terminate
  (princ)
)