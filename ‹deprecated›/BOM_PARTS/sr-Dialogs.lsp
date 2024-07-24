;╔═════════════════════╤══════════════════════╤═══════════════════════════════════════════════╗
;║ OpenDCL Initialize  │ CreateEditPart       │                                               ║
;╚═════════════════════╧══════════════════════╧═══════════════════════════════════════════════╝
(defun c:_Dialogs/CreateEditPart#OnInitialize (/ dictTableHdrsDsc dictPartsInDwg)
  
  (setq dictTableHdrsDsc  "@BOM_TABLE_HEADERS_AND_DESC"
        dictPartsInDwg    "@BOM_PARTS_IN_DWG"
        dictLastUsed      "@BOM_LAST_USED"
        dialogData        (getRecord dictLastUsed "DIALOG")
        TitleBarText      (nth 0 dialogData)
        partTableName     (nth 1 dialogData)
        blockName         (nth 2 dialogData)
        partSize          (nth 3 dialogData)
        partNote          (nth 4 dialogData)
        checkBoxType      (nth 5 dialogData)
  )
  (dcl-Form-Center              _Dialogs/CreateEditPart)
  (dcl-Control-SetTitleBarIcon  _Dialogs/CreateEditPart 101)
  (dcl-Control-SetTitleBarText  _Dialogs/CreateEditPart TitleBarText)
  (dcl-Control-SetList          _Dialogs/CreateEditPart/ComboBox1 (getKeys dictTableHdrsDsc))
  (dcl-Control-SetText          _Dialogs/CreateEditPart/ComboBox1 partTableName)
  (dcl-Control-SetText          _Dialogs/CreateEditPart/TextBox1  blockName)
  (dcl-Control-SetCaption       _Dialogs/CreateEditPart/CheckBox1 checkBoxType)
  (dcl-Control-SetValue         _Dialogs/CreateEditPart/CheckBox1 0)
  (dcl-Control-SetList          _Dialogs/CreateEditPart/ComboBox2 (getRecord dictTableHdrsDsc partTableName))
  (if (= TitleBarText "Create BOM Part")
    (dcl-Control-SetText        _Dialogs/CreateEditPart/ComboBox2 (car (getRecord dictTableHdrsDsc partTableName)))
    (dcl-Control-SetText        _Dialogs/CreateEditPart/ComboBox2 partDesc)
  )
  (dcl-Control-SetText          _Dialogs/CreateEditPart/TextBox3  partSize)
  (dcl-Control-SetText          _Dialogs/CreateEditPart/TextBox4  partNote)
  
  (dcl-Control-SetColumnWidthList   _Dialogs/CreateEditPart/Grid1 (LIST 100 175 175 175))
  (dcl-Control-SetRowHeight         _Dialogs/CreateEditPart/Grid1 18)
  (dcl-Control-SetColumnCaptionList _Dialogs/CreateEditPart/Grid1 (LIST "PART ID" "DESCRIPTION" "SIZE" "NOTE"))
  (dcl-Grid-FillList                _Dialogs/CreateEditPart/Grid1 (reverse (getRecord dictPartsInDwg partTableName)))
)

;┌─────────────────────┬──────────────────────┬─────────┬──────────────────────────────────────┐
;│ OpenDCL Event       │ CreateEditPart       │ {ENTER} │ OnOK                                 │
;└─────────────────────┴──────────────────────┴─────────┴──────────────────────────────────────┘
(defun c:_Dialogs/CreateEditPart#OnOK (/)
  ;(GetPartDataDCL)

  (setq partTableName     (strcase (dcl-Control-GetText _Dialogs/CreateEditPart/ComboBox1))
        blockName         (strcase (dcl-TextBox-GetLine _Dialogs/CreateEditPart/TextBox1 0))
        partDesc          (strcase (dcl-Control-GetText _Dialogs/CreateEditPart/ComboBox2))
        partSize          (strcase (dcl-TextBox-GetLine _Dialogs/CreateEditPart/TextBox3 0))
        partNote          (strcase (dcl-TextBox-GetLine _Dialogs/CreateEditPart/TextBox4 0))
        dictHeadersDesc   "@BOM_TABLE_HEADERS_AND_DESC"
        dictTableLastUsed "@BOM_LAST_USED"
  )
  (if (not (member partTableName (getKeys dictHeadersDesc)))
      (addRecord dictHeadersDesc partTableName  (LIST partDesc))
  )
  (if (not (member partDesc (getRecord dictHeadersDesc partTableName)))
    (changeRecord dictHeadersDesc partTableName (cons partDesc (getRecord dictHeadersDesc partTableName)))
  )
  (addRecord dictTableLastUsed "LAST TABLE" partTableName)
  (addRecord dictTableLastUsed "LAST PART"  (LIST partTableName blockName partDesc partSize partNote))

  (dcl-Form-Close _Dialogs/CreateEditPart 1)
)

;┌─────────────────────┬──────────────────────┬───────┬────────────────────────────────────────┐
;│ OpenDCL Event       │ CreateEditPart       │ {ESC} │ OnCancel                               │
;└─────────────────────┴──────────────────────┴───────┴────────────────────────────────────────┘
(defun c:_Dialogs/CreateEditPart#OnCancel (/)
  (dcl-Form-Close _Dialogs/CreateEditPart 0)
)

;┌─────────────────────┬──────────────────────┬───────────┬────────────────────────────────────┐
;│ OpenDCL Event       │ CreateEditPart       │ OK_Button │ On Clicked                         │
;└─────────────────────┴──────────────────────┴───────────┴────────────────────────────────────┘
(defun c:_Dialogs/CreateEditPart/OK_Button#OnClicked (/)
  ;(GetPartDataDCL)
  
  (setq partTableName     (strcase (dcl-Control-GetText _Dialogs/CreateEditPart/ComboBox1))
        blockName         (strcase (dcl-TextBox-GetLine _Dialogs/CreateEditPart/TextBox1 0))
        partDesc          (strcase (dcl-Control-GetText _Dialogs/CreateEditPart/ComboBox2))
        partSize          (strcase (dcl-TextBox-GetLine _Dialogs/CreateEditPart/TextBox3 0))
        partNote          (strcase (dcl-TextBox-GetLine _Dialogs/CreateEditPart/TextBox4 0))
        dictHeadersDesc   "@BOM_TABLE_HEADERS_AND_DESC"
        dictTableLastUsed "@BOM_LAST_USED"
  )
  (if (not (member partTableName (getKeys dictHeadersDesc)))
      (addRecord dictHeadersDesc partTableName  (LIST partDesc))
  )
  (if (not (member partDesc (getRecord dictHeadersDesc partTableName)))
    (changeRecord dictHeadersDesc partTableName (cons partDesc (getRecord dictHeadersDesc partTableName)))
  )
  (addRecord dictTableLastUsed "LAST TABLE" partTableName)
  (addRecord dictTableLastUsed "LAST PART"  (LIST partTableName blockName partDesc partSize partNote))

  (dcl-Form-Close _Dialogs/CreateEditPart 1)
)

;┌─────────────────────┬──────────────────────┬───────────────┬────────────────────────────────┐
;│ OpenDCL Event       │ CreateEditPart       │ Cancel_Button │ OnClicked                      │
;└─────────────────────┴──────────────────────┴───────────────┴────────────────────────────────┘
(defun c:_Dialogs/CreateEditPart/Cancel_Button#OnClicked (/)
  (dcl-Form-Close _Dialogs/CreateEditPart 0)
)

;┌─────────────────────┬──────────────────────┬───────────┬───────────────────────────────────┐
;│ OpenDCL Event       │ CreateEditPart       │ CheckBox1 │ OnClicked                         │
;└─────────────────────┴──────────────────────┴───────────┴───────────────────────────────────┘
(defun c:_Dialogs/CreateEditPart/CheckBox1#OnClicked (Value /)
  (setq processPartCheck Value)
)

;┌─────────────────────┬──────────────────────┬───────────┬───────────────────────────────────┐
;│ OpenDCL Event       │ CreateEditPart       │ ComboBox1 │ On Selection Changed              │
;└─────────────────────┴──────────────────────┴───────────┴───────────────────────────────────┘
(defun c:_Dialogs/CreateEditPart/ComboBox1#OnSelChanged (ItemIndexOrCount Value / textDesc tableHeaderName                                                                                dictTableHdrsDsc dictPartsInDwg)
  (setq textDesc (dcl-Control-GetText _Dialogs/CreateEditPart/ComboBox2)
        dictTableHdrsDsc "@BOM_TABLE_HEADERS_AND_DESC"
        dictPartsInDwg   "@BOM_PARTS_IN_DWG"
  )
  (foreach tableHeaderName (getKeys dictTableHdrsDsc)
    (if (= Value tableHeaderName)
      (progn
        (dcl-Control-SetList _Dialogs/CreateEditPart/ComboBox2 (getRecord dictTableHdrsDsc tableHeaderName))
        (dcl-Grid-FillList   _Dialogs/CreateEditPart/Grid1     (getRecord dictPartsInDwg tableHeaderName))
        (dcl-Control-SetText _Dialogs/CreateEditPart/ComboBox2 textDesc)
      )
    )
  )
)

;╔═════════════════════╤══════════════════════╤═══════════════════════════════════════════════╗
;║ OpenDCL Initialize  │ MessageBox           │                                               ║
;╚═════════════════════╧══════════════════════╧═══════════════════════════════════════════════╝
(defun c:_Dialogs/MessageBox#OnInitialize (/)
  (dcl-Control-SetTitleBarText _Dialogs/MessageBox        (nth 0 listMessageBox))
  (dcl-Control-SetPicture _Dialogs/MessageBox/PictureBox1 (nth 1 listMessageBox))
  (dcl-Control-SetCaption _Dialogs/MessageBox/Label1      (nth 2 listMessageBox))
  (dcl-Control-SetCaption _Dialogs/MessageBox/TextButton1 (nth 3 listMessageBox))
  (dcl-Control-SetCaption _Dialogs/MessageBox/TextButton2 (nth 4 listMessageBox))
)

;┌─────────────────────┬──────────────────────┬──────────────┬────────────────────────────────┐
;│ OpenDCL Event       │ MessageBox           │ {ENTER}      │ OnOk                           │
;└─────────────────────┴──────────────────────┴──────────────┴────────────────────────────────┘
(defun c:_Dialogs/MessageBox#OnOK (/)
  (dcl-Form-Close _Dialogs/MessageBox 1)
)

;┌─────────────────────┬──────────────────────┬──────────────┬────────────────────────────────┐
;│ OpenDCL Event       │ MessageBox           │ {ESC}        │ OnCancel                       │
;└─────────────────────┴──────────────────────┴──────────────┴────────────────────────────────┘
(defun c:_Dialogs/MessageBox#OnCancel (/)
  (dcl-Form-Close _Dialogs/MessageBox 0)
)

;┌─────────────────────┬──────────────────────┬───────────────┬───────────────────────────────┐
;│ OpenDCL Event       │ MessageBox           │ {TextButton1} │ OnClicked                     │
;└─────────────────────┴──────────────────────┴───────────────┴───────────────────────────────┘
(defun c:_Dialogs/MessageBox/TextButton1#OnClicked (/)
  (dcl-Form-Close _Dialogs/MessageBox 1)
)

;┌─────────────────────┬──────────────────────┬───────────────┬───────────────────────────────┐
;│ OpenDCL Event       │ MessageBox           │ {TextButton2} │ OnClicked                     │
;└─────────────────────┴──────────────────────┴───────────────┴───────────────────────────────┘
(defun c:_Dialogs/MessageBox/TextButton2#OnClicked (/)
  (dcl-Form-Close _Dialogs/MessageBox 0)
)

;╔═════════════════════╤══════════════════════╤═══════════════════════════════════════════════╗
;║ OpenDCL Initialize  │ PaletteForm1         │                                               ║
;╚═════════════════════╧══════════════════════╧═══════════════════════════════════════════════╝
(defun c:_Dialogs/PaletteForm1#OnInitialize (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1#OnInitialize" "To do")
)

;┌─────────────────────┬──────────────────────┬───────────────────────┬───────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ OnEnteringNoDocState  │                       │
;└─────────────────────┴──────────────────────┴───────────────────────┴───────────────────────┘
(defun c:_Dialogs/PaletteForm1#OnEnteringNoDocState (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1#OnEnteringNoDocState" "To do")
)

;┌─────────────────────┬──────────────────────┬───────────────────────┬───────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ OnClose               │                       │
;└─────────────────────┴──────────────────────┴───────────────────────┴───────────────────────┘
(defun c:_Dialogs/PaletteForm1#OnClose (UpperLeftX UpperLeftY /)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1#OnClose" "To do")
)

;┌─────────────────────┬──────────────────────┬───────────────────────┬───────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ OnMouseEntered        │                       │
;└─────────────────────┴──────────────────────┴───────────────────────┴───────────────────────┘
(defun c:_Dialogs/PaletteForm1#OnMouseEntered (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1#OnMouseEntered" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton1}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton1#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton2}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton2#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton3}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton3#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton4}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton4#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton4}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton4#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton5}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton5#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton6}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton6#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton7}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton7#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton8}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton8#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")
)

;┌─────────────────────┬──────────────────────┬──────────────────────┬────────────────────────┐
;│ OpenDCL Event       │ PaletteForm1         │ {TextButton9}        │ OnClicked              │
;└─────────────────────┴──────────────────────┴──────────────────────┴────────────────────────┘
(defun c:_Dialogs/PaletteForm1/TextButton9#OnClicked (/)
  (dcl-MessageBox "To Do: code event handler\r\nc:_Dialogs/PaletteForm1/TextButton1#OnClicked" "To do")

)



; INITIALIZE ======================================================================================
(defun c:_Dialogs/InvalidName#OnInitialize (/)
  (dcl-Control-SetTitleBarText _Dialogs/InvalidName
      (strcat "Part Name Invalid"))
  (dcl-Control-SetCaption _Dialogs/InvalidName/Label1
      (strcat "The name of the part is invalid.\n\nPlease make sure the name does not contain any of these characters: < > / \\ " (chr 34) " : ? * | , = `"))
  (dcl-Control-SetCaption _Dialogs/InvalidName/TextButton1
      (strcat "Go Back To Edit Name"))
  (dcl-Control-SetCaption _Dialogs/InvalidName/TextButton2
      (strcat "Cancel Create/Edit Part"))
)

; ENTER KEY
(defun c:_Dialogs/InvalidName#OnOK (/)
  (dcl-Form-Close _Dialogs/InvalidName 1)
)

; ESCAPE KEY
(defun c:_Dialogs/InvalidName#OnCancel (/)
  (dcl-Form-Close _Dialogs/InvalidName 0)
)

; RETURN TO EDIT NAME BUTTON
(defun c:_Dialogs/InvalidName/TextButton1#OnClicked (/)
  (dcl-Form-Close _Dialogs/InvalidName 1)
)

(defun c:_Dialogs/InvalidName/TextButton2#OnClicked (/)
  (dcl-Form-Close _Dialogs/InvalidName 0)
)

; INITIALIZE ======================================================================================
(defun c:_Dialogs/PartNameExists#OnInitialize (/)
  (dcl-Control-SetTitleBarText  _Dialogs/PartNameExists
      (strcat blockName " already exists!"))
  (dcl-Control-SetCaption       _Dialogs/PartNameExists/Label1
      (strcat "The part " (chr 34) blockName (chr 34) " already exists!\n\nIf you want to redefine the part, create a new part and choose " (chr 34) "Redefine Existing Part" (chr 34) "."))
  (dcl-Control-SetCaption       _Dialogs/PartNameExists/TextButton1 "Go Back To Edit Name")
  (dcl-Control-SetCaption       _Dialogs/PartNameExists/TextButton2 "Cancel Create/Edit Part")
)

; ENTER KEY
(defun c:_Dialogs/PartNameExists#OnOK (/)
  (dcl-Form-Close _Dialogs/PartNameExists 1)
)

; ESCAPE KEY
(defun c:_Dialogs/PartNameExists#OnCancel (/)
  (dcl-Form-Close _Dialogs/PartNameExists 0)
)

; RETURN TO EDIT PART BUTTON
(defun c:_Dialogs/PartNameExists/TextButton1#OnClicked (/)
  (dcl-Form-Close _Dialogs/PartNameExists 1)
)

; CANCEL BUTTON
(defun c:_Dialogs/PartNameExists/TextButton2#OnClicked (/)
  (dcl-Form-Close _Dialogs/PartNameExists 0)
)

; INITIALIZE ======================================================================================
(defun c:_Dialogs/PickNewBasePoint#OnInitialize (/)
  (dcl-Control-SetTitleBarText _Dialogs/PickNewBasePoint "Pick A New Base Point")
  (dcl-Control-SetCaption _Dialogs/PickNewBasePoint/Label1
      (strcat "The BASE POINT you specified is not on an object in the block.\n\n"
              "Please pick a new BASE POINT that is on an edge or corner of an object in the block.")
  )
)

(defun c:_Dialogs/PickNewBasePoint/RetryButton#OnClicked (/)
  (dcl-Form-Close _Dialogs/PickNewBasePoint 1)
)

(defun c:_Dialogs/PickNewBasePoint#OnOK (/)
  (dcl-Form-Close _Dialogs/PickNewBasePoint 1)
)

(defun c:_Dialogs/PickNewBasePoint/CancelButton#OnClicked (/)
  (dcl-Form-Close _Dialogs/PickNewBasePoint 0)
)

(defun c:_Dialogs/PickNewBasePoint#OnCancel (/)
  (dcl-Form-Close _Dialogs/PickNewBasePoint 0)
)


; INITIALIZE ======================================================================================
(defun c:_Dialogs/RedefinePart#OnInitialize (/)
  (dcl-Control-SetTitleBarText  _Dialogs/RedefinePart BlockName)
  (dcl-Control-SetCaption       _Dialogs/RedefinePart/Label1
    (strcat "THE PART NAME\n\n" (chr 34) BlockName (chr 34) "\n\nALREADY EXISTS."))
  (dcl-Control-SetCaption       _Dialogs/RedefinePart/Label2
    (strcat "(there are " "X" " instances of " BlockName " in this drawing)"))
  (dcl-Control-SetCaption       _Dialogs/RedefinePart/RedefineButton
    (strcat "REDEFINE PART " BlockName "?\n(all instances of " BlockName " will be updated)"))
  (dcl-Control-SetCaption       _Dialogs/RedefinePart/DoNotRedifineButton
    (strcat "DO NOT REDEFINE PART " BlockName ".\n(return to create part)"))
  (dcl-Control-ZOrder           _Dialogs/RedefinePart/DoNotRedifineButton 1)
)

; ENTER KEY
(defun c:_Dialogs/RedefinePart#OnOK (/)
  (dcl-Form-Close _Dialogs/RedefinePart 0)
)

; ESCAPE KEY
(defun c:_Dialogs/RedefinePart#OnCancel (/)
  (dcl-Form-Close _Dialogs/RedefinePart 0)
)

; REDEFINE BUTTON
(defun c:_Dialogs/RedefinePart/RedefineButton#OnClicked (/)
  (dcl-Form-Close _Dialogs/RedefinePart 1)
)

; DO NOT REDIFINE BUTTON
(defun c:_Dialogs/RedefinePart/DoNotRedifineButton#OnClicked (/)
  (dcl-Form-Close _Dialogs/RedefinePart 0)
)
