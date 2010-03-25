@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd
if "%OS_NAME%"=="" goto NoOSName
if "%OS_LANGUAGE%"=="" goto NoOSLang
if "%OS_ARCHITECTURE%"=="" goto NoOSArch

:EvalParams
if "%1"=="" goto NoMoreParams
if /i "%1"=="/excludestatics" set EXCLUDE_STATICS=/excludestatics
shift /1
goto EvalParams

:EvalStatics
if exist %1 (
  if exist "%TEMP%\InstalledUpdateIds.txt" (
    %SystemRoot%\system32\findstr.exe /I /V /G:"%TEMP%\InstalledUpdateIds.txt" %1 >>"%TEMP%\MissingUpdateIds.txt"
  ) else (
    for /F %%i in (%1) do echo %%i>>"%TEMP%\MissingUpdateIds.txt" 
  )
)
goto :eof

:NoMoreParams
rem *** Add statically defined update ids ***
if "%EXCLUDE_STATICS%"=="/excludestatics" goto ExcludeStatics
if exist ..\static\StaticUpdateIds-%OS_NAME%-%OS_ARCHITECTURE%.txt call :EvalStatics ..\static\StaticUpdateIds-%OS_NAME%-%OS_ARCHITECTURE%.txt
if exist ..\static\custom\StaticUpdateIds-%OS_NAME%-%OS_ARCHITECTURE%.txt call :EvalStatics ..\static\custom\StaticUpdateIds-%OS_NAME%-%OS_ARCHITECTURE%.txt
if exist ..\static\StaticUpdateIds-%OFFICE_NAME%.txt call :EvalStatics ..\static\StaticUpdateIds-%OFFICE_NAME%.txt
if exist ..\static\custom\StaticUpdateIds-%OFFICE_NAME%.txt call :EvalStatics ..\static\custom\StaticUpdateIds-%OFFICE_NAME%.txt
if exist ..\static\StaticUpdateIds-%OFFICE_NAME%-%OS_ARCHITECTURE%.txt call :EvalStatics ..\static\StaticUpdateIds-%OFFICE_NAME%-%OS_ARCHITECTURE%.txt
if exist ..\static\custom\StaticUpdateIds-%OFFICE_NAME%-%OS_ARCHITECTURE%.txt call :EvalStatics ..\static\custom\StaticUpdateIds-%OFFICE_NAME%-%OS_ARCHITECTURE%.txt

:ExcludeStatics
if exist "%TEMP%\InstalledUpdateIds.txt" del "%TEMP%\InstalledUpdateIds.txt"
rem *** List update files ***
if not exist "%TEMP%\MissingUpdateIds.txt" goto NoMissingUpdateIds
if exist "%TEMP%\UpdatesToInstall.txt" del "%TEMP%\UpdatesToInstall.txt"
if exist ..\exclude\ExcludeList.txt copy /Y ..\exclude\ExcludeList.txt "%TEMP%\ExcludeList.txt" >nul
if exist ..\exclude\custom\ExcludeList.txt (
  for /F %%i in (..\exclude\custom\ExcludeList.txt) do echo %%i>>"%TEMP%\ExcludeList.txt"
)
for /F "usebackq tokens=1,2 delims=," %%i in ("%TEMP%\MissingUpdateIds.txt") do (
  if exist "%TEMP%\Update.txt" del "%TEMP%\Update.txt"
  %SystemRoot%\system32\find.exe /I "%%i" "%TEMP%\ExcludeList.txt" >nul 2>&1
  if errorlevel 1 (
    for %%k in (%OS_NAME%-%OS_ARCHITECTURE% %OS_NAME% win) do (
      for %%l in (%OS_LANGUAGE% glb) do (
        call ListUpdateFile.cmd ie%IE_VERSION_MAJOR%-*%%i ..\%%k\%%l
        call ListUpdateFile.cmd windowsmedia%WMP_VERSION_MAJOR%-*%%i ..\%%k\%%l
        call ListUpdateFile.cmd windowsmedia-*%%i ..\%%k\%%l
        call ListUpdateFile.cmd mdac%MDAC_VERSION_MAJOR%%MDAC_VERSION_MINOR%-*%%i ..\%%k\%%l
        call ListUpdateFile.cmd windows2000*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd windowsxp*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd windowsserver2003*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd windows6*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd windows*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd %%i ..\%%k\%%l
      )
    )
    call ListUpdateFile.cmd ndp*%%i*-%OS_ARCHITECTURE% ..\dotnet\%OS_ARCHITECTURE%-glb /searchleftmost
    for %%k in (%OFFICE_NAME%-%OS_ARCHITECTURE% %OFFICE_NAME% ofc oxp o2k3 o2k7 o2k7-x64) do (
      for %%l in (%OFFICE_LANGUAGE% glb) do (
        call ListUpdateFile.cmd %%i ..\%%k\%%l
      )
    )
    if exist "%TEMP%\Update.txt" (
      del "%TEMP%\Update.txt"
    ) else (
      echo Warning: Update KB%%i not found.
      echo %DATE% %TIME% - Warning: Update KB%%i not found >>%UPDATE_LOGFILE%
    )
  ) else (
    echo Info: Skipping update KB%%i due to matching black list entry.
    echo %DATE% %TIME% - Info: Skipped update KB%%i due to matching black list entry >>%UPDATE_LOGFILE%
  )
)
del "%TEMP%\MissingUpdateIds.txt"
del "%TEMP%\ExcludeList.txt"
goto EoF

:NoExtensions
echo ERROR: No command extensions available.
goto Error

:NoTemp
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set >>%UPDATE_LOGFILE%
goto Error

:NoTempDir
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found >>%UPDATE_LOGFILE%
goto Error

:NoOSName
echo ERROR: Environment variable OS_NAME not set.
echo %DATE% %TIME% - Error: Environment variable OS_NAME not set >>%UPDATE_LOGFILE%
goto Error

:NoOSLang
echo ERROR: Environment variable OS_LANGUAGE not set.
echo %DATE% %TIME% - Error: Environment variable OS_LANGUAGE not set >>%UPDATE_LOGFILE%
goto Error

:NoOSArch
echo ERROR: Environment variable OS_ARCHITECTURE not set.
echo %DATE% %TIME% - Error: Environment variable OS_ARCHITECTURE not set >>%UPDATE_LOGFILE%
goto Error

:NoMissingUpdateIds
echo ERROR: File "%TEMP%\MissingUpdateIds.txt" not found.
echo %DATE% %TIME% - Error: File "%TEMP%\MissingUpdateIds.txt" not found >>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
