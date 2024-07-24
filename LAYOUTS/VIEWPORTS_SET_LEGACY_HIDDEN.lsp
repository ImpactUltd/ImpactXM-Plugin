;;; File:           MakeShadePlotHidden.lsp
;;; Version:        1.0
;;; Last changed:   2015-10-19
;;; Author:         C. Lipinski
;;; Copyright:      (C) 2015
;;; Purpose:        Change the Shade Plot setting of a viewport to (Legacy) Hidden
;;;
;;;
;;; THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
;;; KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
;;; PARTICULAR PURPOSE.

(defun c:VIEWPORTS_SET_LEGACY_HIDDEN (/ A)
  (setq A (ssget))
  (command "-vports" "shadeplot" "hidden" A "")
  (princ)
)
