;;  Layer Isolate Freeze and Thaw [command names: LIT, LUT]
;;  To Isolate/Unisolate Layers of selected objects as to Thaw/freeze condition only.
;;  LIT isolates Layers of selected objects, leaving those Layers thawed and freezing
;;  all other Layers that are not already frozen.  If repeated before LUT re-thaws those
;;  Layers, makes further isolations, to as many levels as desired.
;;  LUT thaws latest set of frozen Layers, without undoing other Layer options that
;;  may have been used under isolated conditions [as happens with some (e.g. colors)
;;  if using AutoCAD's standard LAYUNISO to return to un-isolated conditions after
;;  using LAYISO (as to On/Off status)].  When repeated, steps back through as many
;;  isolations as done with LIT, in reverse order [LAYUNISO can reverse only one].
;;  Kent Cooper, last edited 10 January 2014


(defun litV (sub); = build Variable name for (set): subtype + current integer ending
  (read (strcat "lit" sub (itoa litinc)))
); defun

(defun litG (sub); = Get what's in variable made by (set) and (litV)
  (eval (read (strcat "lit" sub (itoa litinc))))
); defun

(defun c:LAYER_ISOLATE (/ ss laysel layname lithlist layobj); = Layer Isolate, Thaw/freeze
  (prompt "\nTo designate Layer(s) to remain thawed,")
  (if (setq ss (ssget)); object selection
    (progn
      (setq litdoc (vla-get-activedocument (vlax-get-acad-object)))
      (vla-startundomark litdoc)
      (repeat (sslength ss); make list of Layer names to remain thawed
        (setq laysel (cdr (assoc 8 (entget (ssname ss 0))))); Layer name
        (if (not (member laysel lithlist)) (setq lithlist (cons laysel lithlist))); add if not already there
        (ssdel (ssname ss 0) ss)
      ); repeat
      (setq litinc (if litinc (1+ litinc) 1)); litinc is global; 1 for first time, etc.
      (if
        (set (litV "cur"); global variable(s) litcur1, litcur2, etc., but only:
          (if (not (member (getvar 'clayer) lithlist)); nil if current Layer kept thawed
            (vlax-ename->vla-object (tblobjname "layer" (getvar 'clayer)))
          ); if
        ); set
        (setvar 'clayer (nth 0 lithlist)); then -- make some selected object's Layer current
      ); if
      (while (setq layname (cdadr (tblnext "layer" (not layname)))); step through Layer names
        (if
          (and
            (not (member layname lithlist)); not among selected objects' Layers
            (= (logand 1 (cdr (assoc 70 (tblsearch "layer" layname)))) 0); currently thawed
          ); and
          (progn ; then
            (setq layobj (vlax-ename->vla-object (tblobjname "layer" layname)))
            (set (litV "frz") (cons layobj (litG "frz")))
              ; put in list of frozen Layers -- makes global variables litfrz1, litfrz2, etc.
            (vla-put-freeze layobj 1); freeze it
          ); progn
        ); if
      ); while
      (prompt
        (strcat
          "\n"
          (itoa (length lithlist))
          " Layer(s) isolated, "
          (itoa (length (litG "frz")))
          " Layer(s) frozen."
          (if (litG "cur")
            (strcat "  Layer " (getvar 'clayer) " has been made current."); then
            "" ; else -- add nothing to prompt if current Layer remains thawed
          ); if
        ); strcat
      ); prompt
      (vla-endundomark litdoc)
    ); progn
    (prompt "\nNothing selected.")
  ); if
  (princ)
); defun

(defun c:LAYER_UNISOLATE (/ lutgone lutcur); = Layer Unisolate, Thaw-freeze
  (if (> litinc 0); at least one list of frozen Layers exists
    (progn ; then
      (vla-startundomark litdoc)
      (foreach lay (litG "frz"); latest numbered list of frozen Layers as VLA objects
        (if (vlax-vla-object->ename lay); still in drawing
          (vla-put-freeze lay 0); then -- thaw it
          (progn ; else
            (vl-remove lay (litG "frz")); to adjust number for prompt later
            (setq lutgone (if lutgone (1+ lutgone) 1))
              ; quantity of no-longer-present Layers that were frozen by LIT
          ); progn
        ); if
      ); foreach
      (if ; restore Layer current at time of corresponding LIT if it was frozen
        (and
          (litG "cur"); nil if it wasn't
          (vlax-vla-object->ename (litG "cur")); Layer still in drawing, even if renamed
        ); and
        (progn
          (setq lutcur (vla-get-Name (litG "cur"))); name [if renamed since its LIT, new]
          (setvar 'clayer lutcur); restore as current
        ); progn
      ); if
      (prompt
        (strcat
          "\n"
          (itoa (length (litG "frz")))
          " Layer(s) re-thawed."
          (if (litG "cur"); corresponding LIT froze current Layer at the time
            (strcat ; then
              "\nLayer "
              (cond
                (lutcur); saved above only if still in drawing -- name, even if renamed
                ("current at time of LIT purged, and not")
              ); if
              " restored as current."
            ); strcat
            "" ; else -- add nothing if corresponding LIT kept current Layer thawed
          ); if
          (if lutgone (strcat "\n" (itoa lutgone) " purged Layer(s) not re-thawed.") "")
        ); strcat
      ); prompt
      (set (litV "frz") nil); clear list ending with latest integer in use
      (set (litV "cur") nil); clear current-at-LIT-Layer-if-changed value with latest integer
      (setq litinc (1- litinc)); increment downward for next-earlier list
      (terpri)
      (vla-regen litdoc 1); make things on re-thawed Layer(s) visible
      (vla-endundomark litdoc)
    ); progn
    (prompt "\nNo Layers to Unisolate."); else
  ); if
  (princ)
); defun
