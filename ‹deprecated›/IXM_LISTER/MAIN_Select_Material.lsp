(progn
  (setq file_Dialogs (findfile "L:\\AutoCAD\\LISP\\AutoCAD Plugins\\ImpactXM\\IXM_LISTER\\DCL_Select_Material.lsp"))
  (if file_Dialogs
    (progn
      (princ "\nDialog loaded")
      (setq ODCLdata (load file_Dialogs))
      (dcl-Project-Import ODCLdata ) 
    )
    (princ "\nDialog file not found.")
  )
)

(defun c:DCL_Select_Material/Main_Form#OnInitialize (/)
  (dcl-Control-SetList DCL_Select_Material/Main_Form/ListBox1 (list "PLY" "LUAN" "KMWH" "MELW" "PLCL"))
  (dcl-Control-SetList DCL_Select_Material/Main_Form/ListBox2 (list "SILVER" "949 WHITE" "1100" "ABET 409 GRAY" "ALMOND ALDER" "CINDER 2110" "COLORCORE WHITE" "423 PURPLE" "468 YELLOW" "BLACK 909"))
)

(defun c:DCL_Select_Material/Main_Form#OnOK (/)
  (dcl-Form-Close DCL_Select_Material/Main_Form)
)

(defun c:DCL_Select_Material/Main_Form#OnCancel (/)
  (dcl-Form-Close DCL_Select_Material/Main_Form)
)

(defun c:DCL_Select_Material/Main_Form/OK_Button#OnClicked (/)
  (dcl-Form-Close DCL_Select_Material/Main_Form) 
)

(defun c:DCL_Select_Material/Main_Form/Cancel_Button#OnClicked (/)
  (dcl-Form-Close DCL_Select_Material/Main_Form)
)



(defun c:CNC_ASSIGN_MATERIAL ()
  (LOAD "L:/AutoCAD/LISP/AutoCAD Plugins/ImpactXM/IXM_LISTER/MAIN_Select_Material.lsp")
  (dcl-Form-Show DCL_Select_Material/Main_Form)
)