;;(setq libPath "L:/AutoCAD/LISP/AutoCAD Plugins/Impact XM Plug-Ins.bundle/Contents/")

;;┌──────────────────────────────────────────────────────────────────────┐
;;│ Take out the garbage and load ActiveX AutoLISP functions             │
;;└──────────────────────────────────────────────────────────────────────┘
(gc)
(vl-load-com)

;;┌──────────────────────────────────────────────────────────────────────┐
;;│ Load Dialog GUI Data and Dialog Subroutines                          │
;;└──────────────────────────────────────────────────────────────────────┘
(progn
  (setq file_Dialogs (findfile "Resources/_Dialogs.lsp"))
  (if file_Dialogs
    (setq ODCLdata (load file_Dialogs))
    ; (setq ODCLdata (load (strcat libPath "Resources/_Dialogs.lsp")))
  )
  ;;(setq ODCLdata (load (strcat libPath "Resources/_Dialogs.lsp")))
  ;;(load (strcat libPath "_Dialog_Subroutines.lsp"))
  (command "OPENDCL")
  (dcl-project-import ODCLdata "impactxm")
)

;;┌──────────────────────────────────────────────────────────────────────┐
;;│ Define command line functions                                        │
;;└──────────────────────────────────────────────────────────────────────┘
(defun c:BOM_CREATE_PART        nil (sub:CreateBOMpart))
(defun c:BOM_EDIT_PART          nil (sub:EditBOMpart))
(defun c:BOM_DRAW_TABLES        nil (sub:DrawBOMTables))
(defun c:BOM_EXPORT_PARTS       nil (sub:ExportBOMParts))


(sub:InitializeBOMdwg)