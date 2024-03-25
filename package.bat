@echo off
setlocal

set TARGET_ARCH=x64
set SDK_BUILD_NUMBER=10.0.18362.0
set WINDOWS_KITS_PATH=C:\Program Files (x86)\Windows Kits\10\bin
set Path=%WINDOWS_KITS_PATH%\%SDK_BUILD_NUMBER%\%TARGET_ARCH%;%Path%

rem Generate the self-signed certificate using PowerShell
powershell -Command "$certificate = New-SelfSignedCertificate -Type Custom -Subject 'CN=MyCompany, O=MyCompany, L=MyCity, S=MyState, C=MyCountry' -KeyUsage DigitalSignature -FriendlyName 'UWPApp Certificate' -CertStoreLocation 'Cert:\CurrentUser\My' -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3', '2.5.29.19={text}'); $thumbprint = $certificate.Thumbprint; Write-Output $thumbprint > %TEMP%\certificate_sha.txt"

rem Read the certificate SHA from the file
set /p CERTIFICATE_SHA=<%TEMP%\certificate_sha.txt

rem Run makepri commands
makepri createconfig /cf priconfig.xml /dq en-US /o /pv 10.0.0
del resources.pri
makepri new /pr "%CD%" /cf priconfig.xml
makeappx pack /m AppxManifest.xml /f filemap.txt /p UWPApp.msix /o

rem Sign the package with the generated certificate SHA
SignTool sign /v /a /sha1 %CERTIFICATE_SHA% /fd SHA256 UWPApp.msix

endlocal
