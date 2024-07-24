

;|
  Creates a string of the current drawing file name with current timestamp appended 
  @Returns filename_TIMESTAMP.dwg
|;
(defun f:file-timestamp (/ timestamp_RAW t_YYYY t_MM t_DD t_HH t_MIN t_SES timestamp)
  ; 20230831.092819
  ; 123456789012345
  (setq timestamp_RAW  (rtos (getvar "CDATE") 2 6)
        t_YYYY         (substr timestamp_RAW 1 4)
        t_MM           (substr timestamp_RAW 5 2)
        t_DD           (substr timestamp_RAW 7 2)
        t_HH           (substr timestamp_RAW 10 2)
        t_MIN          (substr timestamp_RAW 12 2)
        t_SES          (substr timestamp_RAW 14 2)
        timestamp      (strcat "_" t_YYYY t_MM t_DD t_HH t_MIN t_SES)
        file_timestamp (strcat (vl-filename-base (getvar "dwgname")) timestamp ".dwg" )
  )
  file_timestamp
)

(defun c:BACKUP_IXM_DWG (/ file_name file_name_path *error* )
  (defun *error*(s)
    (princ s)
    (vla-EndUndoMark (actvDoc))
    (princ)
  )
  (vla-StartUndoMark (actvDoc))
  
  (setq 
        file_path (vl-mkdir (strcat (getvar "dwgprefix") "\\@Old Revs"))
        file_path (vl-mkdir (strcat (getvar "dwgprefix") "\\@Old Revs\\@Backups"))
        file_name (f:file-timestamp)
        file_name_path (strcat (getvar "dwgprefix") "@Old Revs\\@Backups\\" file_name)
  )
  
  (command "_.SAVE" file_name_path)
  
  (princ (strcat "\nDrawing backed up to file: " (vl-filename-base file_name_path)))

  (vla-EndUndoMark (actvDoc))
  (princ)
)
