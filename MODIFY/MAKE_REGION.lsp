(defun c:MAKE_REGION ( / A)
  (setq A (ssget))
  (command "REGION" A "")
  (princ)
)