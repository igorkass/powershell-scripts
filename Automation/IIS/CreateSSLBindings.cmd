@ECHO OFF

REM Uniform date format in CMD/PS scripts
SET CURDATE=%DATE:~4,10%
SET CURTIME=%TIME:~0,8%

ECHO [%CURDATE% %CURTIME%] Executing CreateSSLBindings.ps1 under %username% >> "%WINDIR%\Temp\SSLBindings.log" 2>&1

powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command "& '%~dp0CreateSSLBindings.ps1'" < NUL >> NUL 2>> NUL

ECHO [%CURDATE% %CURTIME%] Completed executing CreateSSLBindings.ps1 >> "%WINDIR%\Temp\SSLBindings.log" 2>&1

EXIT /B 0
