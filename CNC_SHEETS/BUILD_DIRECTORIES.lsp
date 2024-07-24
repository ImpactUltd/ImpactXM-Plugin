(defun f:BuildFabricationDirectory ( / str_Path_dwg str_Path_fab str_WO_number str_Assem str_Path_Assem )
  
    (setq str_Path_dwg    (getvar 'DWGPREFIX)
          str_Path_fab    (strcat str_Path_dwg "Fabrication" )
          str_WO_number   (substr (getvar 'DWGNAME) 2 8)
          str_Assem       (substr (getvar 'DWGNAME) 11 (- (strlen (getvar 'DWGNAME)) 14))
          str_Path_Assem  (strcat str_Path_fab "\\" str_WO_number "-" str_Assem)
    )
    (if (not (vl-file-directory-p str_Path_fab))
       (vl-mkdir str_Path_fab)
    )
    (if (not (vl-file-directory-p str_Path_Assem))
       (vl-mkdir str_Path_Assem)
    )
    str_Path_Assem
)


;| 
(f:BuildFabricationDirectory)
 |;


;; (defun sub:Build_PDF_Directory ( / str_path_dwg str_path_pdf str_path_rev )
;;   (setq str_path_dwg (getvar 'DWGPREFIX)
;;         str_path_pdf (strcat str_path_dwg "PDF" )
;;         str_path_rev (strcat str_path_pdf "\\" "@Old Revs" )
;;   )
;;   (if (not (vl-file-directory-p str_path_pdf))
;;      (vl-mkdir str_path_pdf)
;;   )
;;   (if (not (vl-file-directory-p str_path_rev))
;;      (vl-mkdir str_path_rev)
;;   )
;;   str_path_pdf
;; )

;; (princ "\nBUILD_DIRECTORIES.VLX loaded.")
