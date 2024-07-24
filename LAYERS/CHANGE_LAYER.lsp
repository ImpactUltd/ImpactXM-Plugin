(defun f:change-layer-to ( sset_ents layer_name layer_state / f:SetObjectColor f:SetObjectLinetype f:ChangeToLayer)
  (defun *error* ( msg )
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nError: " msg))
      (princ (strcat "\n" msg " by User."))
    )
      (princ)
  )

  (defun f:RandomFromString ( a b string )
    (defun convert-string-to-number (string / str_num)
      (setq string (substr string 3)
            strSize 12)
      (while (< (strlen string) strSize)
        (setq string (strcat string string))
      )
      (setq list_nums (reverse (vl-string->list (substr string 1 strSize) ))
            str_num   "")
      (foreach int_num list_nums
        (setq str_num (strcat str_num (itoa int_num)))
      )
      (setq real_num  (atof (substr str_num 2 12))
            real_num2 (/ real_num 2517313849)
            int_num   (fix real_num2 )
            real_num3 (abs (-  (float int_num) real_num2 ))
      )
      real_num3
    )
    (+ (min a b) (fix (* (convert-string-to-number string) (1+ (abs (- a b))))))
  )

  (defun f:SetObjectColor (object listColor / colorMethod objColor) 
    (setq objColor    (vlax-create-object (strcat "AutoCAD.AcCmColor." (substr (getvar "ACADVER") 1 2))) 
          colorMethod (car listColor)
    )
    (vla-put-ColorMethod objColor colorMethod)
    (if (= colorMethod acColorMethodByRGB)
        (vla-SetRGB objColor (cadr listColor) (caddr listColor) (cadddr listColor) )
        (vla-put-ColorIndex objColor (cdr listColor))
    )
    (vla-put-TrueColor object objColor)
    (vlax-release-object objColor)
    object 
  )

  (defun f:SetObjectLinetype (object linetype / found entry )
    ;; Search the linetypes collection for the DashDot linetype.
    (setq found     :vlax-false)
    (vlax-for entry (vla-get-Linetypes (actvDoc))
      (if (= (vla-get-Name entry) linetype)
          (setq found :vlax-true)
      )
    )
    (if (= found :vlax-false)
        (vla-Load (vla-get-Linetypes (actvDoc)) linetype "acad.lin")
    )
    (vla-put-Linetype object linetype)
  )

  (defun f:ChangeToLayer (sSet layer frozen / *error* objLayer listIndexColors objLayer 
                                              layer_Color layer_LineType)
    (setq listIndexColors '( 10 13 15 16 21 22 23 24 25 26 27 31 32 33 34 35 36 37 40 41 42 43 44 45 46 47 51 52 53 54 55 56 57 60 62 63 64 65 66 67 70 71 72 73 74 75 76 77 82 83 84 85 86 87 90 91 92 93 94 95 96 99 100 101 102 103 104 105 106 107 111 112 113 114 115 116 117 120 122 124 125 126 127 130 131 132 133 135 136 140 141 142 143 144 145 146 147 150 151 152 153 154 155 156 157 162 163 164 165 166 167 170 171 172 174 175 176 177 181 182 183 184 185 186 187 191 192 193 194 195 196 197 201 202 203 205 206 207 210 212 213 214 215 216 217 220 221 222 223 224 225 226 227 231 232 233 234 235 236 237 240 241 242 243 246 247 )
          layer_LineType "Continuous"
          layer_Color    (cons 195 2)
    )
    ;; Create new layer
    (if (not (tblsearch "LAYER" layer))
      (progn
        (cond 
          ((= layer "Viewports")
            (setq layer_Color '(192 192 255))
          )
          ((= layer "Defpoints")
            (setq layer_Color '(255 128 128))
          )
          ((= layer "NC_Material")
            (setq layer_Color 5)
          )
          ((wcmatch layer "*CNC*")
            (setq layer_Color 2)
          )
          ((wcmatch layer "*BSW*")
            (setq layer_Color 1)
          )
          ((wcmatch layer "*HIDDEN*")
            (setq layer_Color '(128 128 128) 
                  layer_LineType "HIDDEN")
          )
          ((wcmatch layer "*2D*")
            (setq layer_Color 12 )
          )
          ((and (wcmatch layer "*RENTAL*") (wcmatch layer "*WALL PANEL*"))
            (setq layer_Color 94)
          )
          ((and (wcmatch layer "*CUSTOM*") (wcmatch layer "*WALL PANEL*"))
            (setq layer_Color 93)
          )
          ((wcmatch layer "*CARPET*")
            (setq layer_Color 5)
          )
          ((wcmatch layer "*ELEC*")
            (setq layer_Color 142)
          )
          ((and (wcmatch layer "*RENTAL*") (wcmatch layer "*COUNTER*"))
            (setq layer_Color 52)
          )
          ((and (wcmatch layer "*CUSTOM*") (wcmatch layer "*COUNTER*"))
            (setq layer_Color 54)
          )
          ((wcmatch layer "*METAL*")
            (setq layer_Color 170)
          )
          ((wcmatch layer "*BASE PLATE*,*BASEPLATE*")
            (setq layer_Color 5)
          )
          ((wcmatch layer "*GREY*,*GRAY*")
            (setq layer_Color 8)
          )
          ((wcmatch layer "*CONTROL*")
            (setq layer_Color 2)
          )
          ((wcmatch layer "Xref-*")
            (setq layer_Color 7)
          )
          (T 
            (setq layer_Color (nth (f:RandomFromString 0 (length listIndexColors) layer) listIndexColors))
          )
        )
        (setq objLayer (vla-Add (vla-get-Layers (actvDoc)) layer))
        (if (or (= layer "Viewports") (= layer "Defpoints"))
            (vla-put-Plottable objLayer :vlax-false)
        )
        (if (listp layer_Color)
            (f:SetObjectColor objLayer (cons 194 layer_Color))
            (f:SetObjectColor objLayer (cons 195 layer_Color))
        )
        (f:SetObjectLinetype objLayer layer_LineType)
        (vla-put-Freeze objLayer frozen)
      )
    )
    ;; Set the layer of        cl:SelectionSet->entListobjects
    ;(princ "\nsSet: ")
    ;(print sSet)
    (if sSet
      (foreach entity (SelectionSet->entList sSet)
        (vla-put-Layer (vlax-ename->vla-object entity) layer)
        ;(princ "\nLAYER CHANGED!\n")
      )
    )
    (setq objLayer (vla-Item (vla-get-Layers (actvDoc)) layer))
    (vla-put-Freeze objLayer frozen)
    (vla-Regen (actvDoc) :vlax-true)
    (princ)
  )
  
  (if (/= layer_name "0_")
    (f:ChangeToLayer sset_ents layer_name layer_state)
  )
)

(defun c:CHANGE_LAYER_TO_0          ( / sset_ents ) (if (setq sset_ents (ssget)) (f:change-layer-to sset_ents "0" :vlax-false)))
(defun c:CHANGE_LAYER_TO_DEFPOINTS  ( / sset_ents ) (if (setq sset_ents (ssget)) (f:change-layer-to sset_ents "Defpoints" :vlax-false)))
(defun c:CHANGE_LAYER_TO_VIEWPORTS  ( / sset_ents ) (if (setq sset_ents (ssget)) (f:change-layer-to sset_ents "Viewports" :vlax-false)))
(defun c:CHANGE_LAYER_TO_NEW        ( / sset_ents ) (if (setq sset_ents (ssget)) (f:change-layer-to sset_ents (EditEnter "New Layer Layer" "New Layer Name" "0_" 30) :vlax-false)))
(defun c:CHANGE_LAYER_TO_NEW_FREEZE ( / sset_ents ) (if (setq sset_ents (ssget)) (f:change-layer-to sset_ents (EditEnter "New Layer Layer" "New Layer Name" "0_" 30) :vlax-true)))
(defun c:NEW_LAYER                  ( / sset_ents layer_name ) (if (setq layer_name (EditEnter "New Layer Layer" "New Layer Name" "0_" 30)) (f:change-layer-to nil layer_name :vlax-false)))