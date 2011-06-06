@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=
if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

if "%1"=="" goto NoParam
if not exist %1 goto InvalidParam

if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd

:EvalParams
if "%2"=="" goto NoMoreParams
if /i "%2"=="/selectoptions" (
  set SELECT_OPTIONS=1
  shift /2
  goto EvalParams
)
if /i "%2"=="/nobackup" (
  set BACKUP_FILES=0
  shift /2
  goto EvalParams
)
if /i "%2"=="/verify" (
  set VERIFY_FILES=1
  shift /2
  goto EvalParams
)
if /i "%2"=="/errorsaswarnings" (
  set ERRORS_AS_WARNINGS=1
  shift /2
  goto EvalParams
)
if /i "%2"=="/ignoreerrors" (
  set IGNORE_ERRORS=1
  shift /2
  goto EvalParams
)

:NoMoreParams
if "%VERIFY_FILES%" NEQ "1" goto SkipVerification
if not exist ..\bin\hashdeep.exe (
  echo Warning: Hash computing/auditing utility ..\bin\hashdeep.exe not found.
  echo %DATE% %TIME% - Warning: Hash computing/auditing utility ..\bin\hashdeep.exe not found >>%UPDATE_LOGFILE%
  goto SkipVerification
)
echo Verifying integrity of %1...
for /F "tokens=2,3 delims=\" %%i in ("%1") do (
  if exist ..\md\hashes-%%i-%%j.txt (
    %SystemRoot%\system32\findstr.exe /C:%% /C:## /C:%1 ..\md\hashes-%%i-%%j.txt >"%TEMP%\hash-%%i-%%j.txt"
    ..\bin\hashdeep.exe -a -l -k "%TEMP%\hash-%%i-%%j.txt" %1
    if errorlevel 1 (
      if exist "%TEMP%\hash-%%i-%%j.txt" del "%TEMP%\hash-%%i-%%j.txt"
      goto IntegrityError
    )
    if exist "%TEMP%\hash-%%i-%%j.txt" del "%TEMP%\hash-%%i-%%j.txt"
    goto SkipVerification
  )
  if exist ..\md\hashes-%%i.txt (
    %SystemRoot%\system32\findstr.exe /C:%% /C:## /C:%1 ..\md\hashes-%%i.txt >"%TEMP%\hash-%%i.txt"
    ..\bin\hashdeep.exe -a -l -k "%TEMP%\hash-%%i.txt" %1
    if errorlevel 1 (
      if exist "%TEMP%\hash-%%i.txt" del "%TEMP%\hash-%%i.txt"
      goto IntegrityError
    )
    if exist "%TEMP%\hash-%%i.txt" del "%TEMP%\hash-%%i.txt"
    goto SkipVerification
  )
  echo Warning: Hash files ..\md\hashes-%%i-%%j.txt and ..\md\hashes-%%i.txt not found.
  echo %DATE% %TIME% - Warning: Hash files ..\md\hashes-%%i-%%j.txt and ..\md\hashes-%%i.txt not found >>%UPDATE_LOGFILE%
)
:SkipVerification
echo %1 | %SystemRoot%\system32\find.exe /I ".exe" >nul 2>&1
if not errorlevel 1 goto InstExe
echo %1 | %SystemRoot%\system32\find.exe /I ".msi" >nul 2>&1
if not errorlevel 1 goto InstMsi
if /i "%OS_NAME%" EQU "w60" goto FindCabMsu
if /i "%OS_NAME%" EQU "w61" goto FindCabMsu
goto UnsupType

:FindCabMsu
echo %1 | %SystemRoot%\system32\find.exe /I ".cab" >nul 2>&1
if not errorlevel 1 goto InstCab
echo %1 | %SystemRoot%\system32\find.exe /I ".msu" >nul 2>&1
if not errorlevel 1 goto InstMsu
goto UnsupType

:InstExe
if "%SELECT_OPTIONS%" NEQ "1" set INSTALL_SWITCHES=%2 %3 %4 %5 %6 %7 %8 %9
if "%INSTALL_SWITCHES%"=="" (
  for /F %%i in (..\opt\OptionList-Q.txt) do (
    echo %1 | %SystemRoot%\system32\find.exe /I "%%i" >nul 2>&1
    if not errorlevel 1 set INSTALL_SWITCHES=/Q
  )
)
if "%INSTALL_SWITCHES%"=="" (
  for /F %%i in (..\opt\OptionList-qn.txt) do (
    echo %1 | %SystemRoot%\system32\find.exe /I "%%i" >nul 2>&1
    if not errorlevel 1 set INSTALL_SWITCHES=/q /norestart
  )
)
if "%INSTALL_SWITCHES%"=="" (
  if "%BACKUP_FILES%"=="0" (set INSTALL_SWITCHES=/q /n /z) else (set INSTALL_SWITCHES=/q /z)
)
echo Installing %1...
%1 %INSTALL_SWITCHES%
set ERR_LEVEL=%errorlevel%
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
for %%i in (0 1641 3010 3011) do if %ERR_LEVEL% EQU %%i goto InstSuccess
goto InstFailure

:InstMsi
echo Installing %1...
pushd %~dp1
%SystemRoot%\system32\msiexec.exe /i %~nx1 /qn /norestart
set ERR_LEVEL=%errorlevel%
popd
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
for %%i in (0 1641 3010 3011) do if %ERR_LEVEL% EQU %%i goto InstSuccess
goto InstFailure

:InstMsu
echo Installing %1...
%SystemRoot%\system32\wusa.exe %1 /quiet /norestart
set ERR_LEVEL=%errorlevel%
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
for %%i in (0 1641 3010 3011) do if %ERR_LEVEL% EQU %%i goto InstSuccess
goto InstFailure

:InstCab
echo Installing %1...
set ERR_LEVEL=0
if "%OS_ARCH%"=="x64" (set TOKEN_KB=3) else (set TOKEN_KB=2)
for /F "tokens=%TOKEN_KB% delims=-" %%i in ("%1") do (
  call SafeRmDir.cmd "%TEMP%\%%i"
  md "%TEMP%\%%i"
  %SystemRoot%\system32\expand.exe %1 -F:* "%TEMP%\%%i" >nul
  %SystemRoot%\system32\pkgmgr.exe /ip /m:"%TEMP%\%%i" /quiet /norestart
  set ERR_LEVEL=%errorlevel%
  call SafeRmDir.cmd "%TEMP%\%%i"
)
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
for %%i in (0 1641 3010 3011) do if %ERR_LEVEL% EQU %%i goto InstSuccess
goto InstFailure

:NoExtensions
echo ERROR: No command extensions available.
goto Error

:NoParam
echo ERROR: Invalid parameter. Usage: %~n0 ^<filename^> [/selectoptions [/nobackup]] [/errorsaswarnings] [switches]
echo %DATE% %TIME% - Error: Invalid parameter. Usage: %~n0 ^<filename^> [/selectoptions [/nobackup]] [/errorsaswarnings] [switches] >>%UPDATE_LOGFILE%
goto Error

:InvalidParam
echo ERROR: File %1 not found.
echo %DATE% %TIME% - Error: File %1 not found >>%UPDATE_LOGFILE%
goto Error

:NoTemp
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set >>%UPDATE_LOGFILE%
goto Error

:NoTempDir
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found >>%UPDATE_LOGFILE%
goto Error

:UnsupType
echo ERROR: Unsupported file type (file: %1).
echo %DATE% %TIME% - Error: Unsupported file type (file: %1) >>%UPDATE_LOGFILE%
goto InstFailure

:IntegrityError
echo ERROR: File hash does not match stored value (file: %1).
echo %DATE% %TIME% - Error: File hash does not match stored value (file: %1) >>%UPDATE_LOGFILE%
goto InstFailure

:InstSuccess
echo %DATE% %TIME% - Info: Installed %1 >>%UPDATE_LOGFILE%
goto EoF

:InstFailure
if "%ERRORS_AS_WARNINGS%"=="1" (goto InstWarning) else (goto InstError)

:InstWarning
echo Warning: Installation of %1 failed (errorlevel: %ERR_LEVEL%).
echo %DATE% %TIME% - Warning: Installation of %1 %INSTALL_SWITCHES% failed (errorlevel: %ERR_LEVEL%) >>%UPDATE_LOGFILE%
goto EoF

:InstError
echo ERROR: Installation of %1 failed (errorlevel: %ERR_LEVEL%).
echo %DATE% %TIME% - Error: Installation of %1 %INSTALL_SWITCHES% failed (errorlevel: %ERR_LEVEL%) >>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
exit /b 0
