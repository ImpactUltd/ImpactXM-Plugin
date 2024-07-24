(defun f:file->string (fileName / fileHandle fileContent)
  (setq fileHandle (open fileName "r"))
  (setq fileContent (read-line fileHandle))
  (while (setq newLine (read-line fileHandle))
    (setq fileContent (strcat fileContent "\n" newLine))
  )
  (close fileHandle)
  ; Now the variable 'fileContent' contains the whole text file.
  fileContent
)

(defun c:appversion (/ xmlfile xmlstring xmltree appversion)
  (setq xmlfile "C:\\Users\\clipinski\\AppData\\Roaming\\Autodesk\\ApplicationPlugins\\Impact XM.bundle\\PackageContents.xml")
  (setq xmlstring (f:file->string xmlfile))
  (setq xmltree (vlax-create-object "MSXML2.DOMDocument"))
  (vlax-invoke-method xmltree 'load (strcat "<xml>" xmlstring "</xml>"))
  (setq appversion (vlax-invoke-method (vlax-invoke-method xmltree 'getElementsByTagName "ApplicationPackage") 'getAttribute "AppVersion"))
  (princ appversion)
)
(c:appversion)




(defun read-xml-file (file-path)
  (setq xml-file (vlax-create-object "Microsoft.XMLDOM"))
  (setq xml-file.async nil)
  (setq xml-file.validateOnParse nil)
  (setq xml-file.resolveExternals nil)
  (if (vlax-invoke-method xml-file 'load file-path)
    (progn
      (setq app-version-node (vlax-invoke-method xml-file 'selectSingleNode "//AppVersion"))
      (if app-version-node
        (vlax-get-property app-version-node 'text))
      )
    )
  )


;; check out https://stackoverflow.com/questions/36905877/microsoft-xmldom-object-required


;; find methods for "Microsoft.XMLDOM"