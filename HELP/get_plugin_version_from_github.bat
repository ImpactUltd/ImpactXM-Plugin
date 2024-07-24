
@Echo off & SetLocal EnableDelayedExpansion

Set "Version="
For /f "tokens=1,2 delims=:, " %%U in ('
curl "https://api.github.com/repos/ImpactUltd/ImpactXM-Plug-In/releases/latest" 2^>Nul ^| findstr /i "\"tag_name\""
') do Set "Version=!Version!,%%~V"
If defined Version (set "Version=%Version:~1%") Else (Set "Version=n/a")
:: Set Version
echo %Version:~1% > %1