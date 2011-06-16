@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

cd /D "%~dp0"

if "%DOWNLOAD_LOGFILE%"=="" set DOWNLOAD_LOGFILE=..\log\download.log
title %~n0 %1 %2 %3 %4 %5 %6 %7 %8 %9
echo Starting copying for %1 %2 %3 %4 %5 %6 %7 %8 %9...
if exist %DOWNLOAD_LOGFILE% (
  echo. >>%DOWNLOAD_LOGFILE%
  echo -------------------------------------------------------------------------------- >>%DOWNLOAD_LOGFILE%
  echo. >>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Starting copying for %1 %2 %3 %4 %5 %6 %7 %8 %9 >>%DOWNLOAD_LOGFILE%

for %%i in (all all-x86 all-x64 enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%1"=="%%i" goto V1EvalParams)
for %%i in (wxp w2k3 w2k3-x64) do (
  if /i "%1"=="%%i" (
    for %%j in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto V2EvalParams)
    goto V1EvalParams
  )
)
for %%i in (w60 w60-x64 w61 w61-x64) do (
  if /i "%1"=="%%i" (
    if /i "%2"=="glb" shift /2
    goto V1EvalParams
  )
)
for %%i in (ofc) do (
  if /i "%1"=="%%i" (
    for %%j in (glb enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto V2EvalParams)
    goto V1EvalParams
  )
)
goto InvalidParams

:V1EvalParams
if %OUTPUT_PATH%~==~ (
  if %2~==~ (goto InvalidParams) else (set OUTPUT_PATH=%~fs2)
  shift /2
)
if "%2"=="" goto V1CreateFilter
if /i "%2"=="/excludesp" set EXCLUDE_SP=1
if /i "%2"=="/includedotnet" set INCLUDE_DOTNET=1
if /i "%2"=="/includemsse" set INCLUDE_MSSE=1
if /i "%2"=="/includewddefs" set INCLUDE_WDDEFS=1
if /i "%2"=="/cleanup" set CLEANUP=1
shift /2
goto V1EvalParams

:V2EvalParams
if %OUTPUT_PATH%~==~ (
  if %3~==~ (goto InvalidParams) else (set OUTPUT_PATH=%~fs3)
  shift /3
)
if "%3"=="" goto V2CreateFilter
if /i "%3"=="/excludesp" set EXCLUDE_SP=1
if /i "%3"=="/includedotnet" set INCLUDE_DOTNET=1
if /i "%3"=="/includemsse" set INCLUDE_MSSE=1
if /i "%3"=="/includewddefs" set INCLUDE_WDDEFS=1
if /i "%3"=="/cleanup" set CLEANUP=1
shift /3
goto V2EvalParams

:CopyFilter
rem *** Copy USB filter ***
if exist ..\exclude\ExcludeListUSB-%1.txt (
  copy /Y ..\exclude\ExcludeListUSB-%1.txt %USB_FILTER% >nul
) else (
  copy /Y ..\exclude\ExcludeListUSB-%1-x86.txt %USB_FILTER% >nul
)
if exist ..\exclude\custom\ExcludeListUSB-%1.txt (
  for /F %%i in (..\exclude\custom\ExcludeListUSB-%1.txt) do echo %%i>>%USB_FILTER%
)
if exist ..\exclude\custom\ExcludeListUSB-%1-x86.txt (
  for /F %%i in (..\exclude\custom\ExcludeListUSB-%1-x86.txt) do echo %%i>>%USB_FILTER%
)
goto :eof

:LocaleFilter
for %%i in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (
  if /i "%1" NEQ "%%i" (
    echo %%i\>>%USB_FILTER%
  )
)
goto :eof

:ExtendFilter
if "%EXCLUDE_SP%"=="1" (
  for /F %%i in (..\exclude\ExcludeList-SPs.txt) do echo %%i>>%USB_FILTER%
)
if "%INCLUDE_DOTNET%" NEQ "1" (
  for /F %%i in (..\exclude\ExcludeListISO-dotnet.txt) do echo %%i>>%USB_FILTER%
)
if "%INCLUDE_MSSE%" NEQ "1" (
  for /F %%i in (..\exclude\ExcludeList-msse.txt) do echo %%i>>%USB_FILTER%
)
if "%INCLUDE_WDDEFS%" NEQ "1" (
  for /F %%i in (..\exclude\ExcludeList-wddefs.txt) do echo %%i>>%USB_FILTER%
)
goto :eof

:V1CreateFilter
rem *** Create USB filter ***
echo Creating USB filter for %1...
set USB_FILTER=..\ExcludeListUSB-%1.txt
for %%i in (all all-x86 all-x64 wxp w2k3 w2k3-x64 w60 w60-x64 w61 w61-x64 ofc) do (if /i "%1"=="%%i" goto V1CopyFilter)
copy /Y ..\exclude\ExcludeListUSB-all-x86.txt %USB_FILTER% >nul
if exist ..\exclude\custom\ExcludeListUSB-all-x86.txt (
  for /F %%i in (..\exclude\custom\ExcludeListUSB-all-x86.txt) do echo %%i>>%USB_FILTER%
)
call :LocaleFilter %1 
call :ExtendFilter
goto CreateImage

:V1CopyFilter
call :CopyFilter %1
call :ExtendFilter
goto CreateImage

:V2CreateFilter
rem *** Create USB filter ***
echo Creating USB filter for %1 %2...
set USB_FILTER=..\ExcludeListUSB-%1-%2.txt
call :CopyFilter %1
call :LocaleFilter %2 
call :ExtendFilter
goto CreateImage

:CreateImage
rem *** Copy client tree ***
if not exist %SystemRoot%\system32\xcopy.exe goto NoXCopy
echo Copying client tree for %1 %2 %3 %4 %5 %6 %7 %8 %9...
pushd ..\client
%SystemRoot%\system32\xcopy.exe *.* %OUTPUT_PATH% /D /E /I /Y /EXCLUDE:%USB_FILTER%
if errorlevel 1 (
  popd
  if exist %USB_FILTER% del %USB_FILTER%
  goto XCopyError
)
popd
if exist %USB_FILTER% del %USB_FILTER%
echo %DATE% %TIME% - Info: Copied client tree for %1 %2 %3 %4 %5 %6 %7 %8 %9 >>%DOWNLOAD_LOGFILE%

rem *** Clean up target directory ***
if "%CLEANUP%" NEQ "1" goto NoCleanup
echo Cleaning up target directory %OUTPUT_PATH%...
dir ..\client /A:-D /B /S >"%TEMP%\ValidClientFiles.txt"
for /F %%i in ('dir %OUTPUT_PATH% /A:-D /B /S') do (
  %SystemRoot%\system32\find.exe /I "%%~nxi" "%TEMP%\ValidClientFiles.txt" >nul 2>&1
  if errorlevel 1 (
    del %%i
    echo %DATE% %TIME% - Info: Deleted file %%i >>%DOWNLOAD_LOGFILE%
  )
)
del "%TEMP%\ValidClientFiles.txt"
echo %DATE% %TIME% - Info: Cleaned up target directory %OUTPUT_PATH% >>%DOWNLOAD_LOGFILE%

:NoCleanup
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit /b 1

:InvalidParams
echo.
echo ERROR: Invalid parameter: %*
echo Usage1: %~n0 {wxp ^| w2k3 ^| w2k3-x64 ^| ofc} {enu ^| fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| deu ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin} ^<OutputPath^> [/excludesp] [/includedotnet] [/includemsse] [/includewddefs] [/cleanup]
echo Usage2: %~n0 {all ^| all-x86 ^| all-x64 ^| wxp ^| w2k3 ^| w2k3-x64 ^| w60 ^| w60-x64 ^| w61 ^| w61-x64 ^| ofc ^| enu ^| fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| deu ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin} ^<OutputPath^> [/excludesp] [/includedotnet] [/includemsse] [/includewddefs] [/cleanup]
echo %DATE% %TIME% - Error: Invalid parameter: %* >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoXCopy
echo.
echo ERROR: Utility %SystemRoot%\system32\xcopy.exe not found.
echo %DATE% %TIME% - Error: Utility %SystemRoot%\system32\xcopy.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:XCopyError
echo.
echo ERROR: Copying failed.
echo %DATE% %TIME% - Error: Copying failed >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:Error
set COPY_ERROR=1

:EoF
echo %DATE% %TIME% - Info: Ending copying for %1 %2 %3 %4 %5 %6 %7 %8 %9 >>%DOWNLOAD_LOGFILE%
title %ComSpec%
if "%COPY_ERROR%"=="1" verify other 2>nul
endlocal
