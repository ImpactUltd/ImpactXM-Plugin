(defun c:OPEN_WIN_EXPLORER_HERE nil
	(startapp "explorer.exe" (getvar 'DWGPREFIX))
	(princ)
)
(defun c:OPEN_WIN_EXP_APP_DIR nil
	(startapp "explorer.exe" (f:GetPlugInPath nil))
	(princ)
)
