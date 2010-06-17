@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

if "%OS_VERSION_MAJOR%"=="" goto NoOSVersion

set WUA_VERSION_TARGET_MAJOR=5
set WUA_VERSION_TARGET_MINOR=8
set WUA_VERSION_TARGET_BUILD=0
set WUA_VERSION_TARGET_REVISION=2694

set MSI_VERSION_TARGET_BUILD=0
set MSI_VERSION_TARGET_REVISION=0

set WSH_VERSION_TARGET_MAJOR=5
set WSH_VERSION_TARGET_MINOR=6
set WSH_VERSION_TARGET_BUILD=0
set WSH_VERSION_TARGET_REVISION=0

set IE_VERSION_TARGET_MINOR=0
set IE_VERSION_TARGET_BUILD=0
set IE_VERSION_TARGET_REVISION=0

set DIRECTX_VERSION_TARGET_MAJOR=4
set DIRECTX_VERSION_TARGET_MINOR=09
set DIRECTX_VERSION_TARGET_BUILD=00
set DIRECTX_VERSION_TARGET_REVISION=0904

set DOTNET_VERSION_TARGET_MAJOR=3
set DOTNET_VERSION_TARGET_MINOR=5
set DOTNET_VERSION_TARGET_BUILD=30729
set DOTNET_VERSION_TARGET_REVISION=1

if %OS_VERSION_MAJOR% LSS 5 goto SetOfficeName
if %OS_VERSION_MAJOR% GTR 6 goto SetOfficeName
if %OS_VERSION_MAJOR% EQU 5 (
  if %OS_VERSION_MINOR% GTR 2 goto SetOfficeName
)
if %OS_VERSION_MAJOR% EQU 6 (
  if %OS_VERSION_MINOR% GTR 0 goto SetOfficeName
)
goto Windows%OS_VERSION_MAJOR%.%OS_VERSION_MINOR%

:Windows5.0
rem *** Windows 2000 ***
set OS_NAME=w2k
set OS_SP_VERSION_TARGET_MAJOR=4
set OS_SP_TARGET_ID=W2KSP4
set MSI_VERSION_TARGET_MAJOR=3
set MSI_VERSION_TARGET_MINOR=1
set MSI_TARGET_ID=KB893803
set IE_VERSION_TARGET_MAJOR=6
goto SetOfficeName

:Windows5.1
rem *** Windows XP ***
set OS_NAME=wxp
set OS_SP_VERSION_TARGET_MAJOR=3
set OS_SP_TARGET_ID=KB936929
set MSI_VERSION_TARGET_MAJOR=4
set MSI_VERSION_TARGET_MINOR=5
set MSI_TARGET_ID=KB942288
if /i "%1"=="/instie8" (set IE_VERSION_TARGET_MAJOR=8) else (set IE_VERSION_TARGET_MAJOR=7)
for %%i in (chs cht deu esn fra ita jpn kor ptb rus) do (
  if "%%i"=="%OS_LANGUAGE%" set PSH_TARGET_ID=KB926140
)
if "%PSH_TARGET_ID%"=="" set PSH_TARGET_ID=KB926139
goto SetOfficeName

:Windows5.2
rem *** Windows Server 2003 ***
set OS_NAME=w2k3
set OS_SP_VERSION_TARGET_MAJOR=2
set OS_SP_TARGET_ID=KB914961
set MSI_VERSION_TARGET_MAJOR=4
set MSI_VERSION_TARGET_MINOR=5
set MSI_TARGET_ID=KB942288
if /i "%1"=="/instie8" (set IE_VERSION_TARGET_MAJOR=8) else (set IE_VERSION_TARGET_MAJOR=7)
if /i "%OS_ARCHITECTURE%"=="x86" (
  for %%i in (chs cht deu esn fra ita jpn kor ptb rus) do (
    if "%%i"=="%OS_LANGUAGE%" set PSH_TARGET_ID=KB926140
  )
)
if "%PSH_TARGET_ID%"=="" set PSH_TARGET_ID=KB926139
goto SetOfficeName

:Windows6.0
rem *** Windows Vista / Server 2008 ***
set OS_NAME=w60
set MSI_VERSION_TARGET_MAJOR=4
set MSI_VERSION_TARGET_MINOR=0
set MSI_TARGET_ID=KB942288
set PSH_TARGET_ID=KB928439
if /i "%1"=="/instie8" (set IE_VERSION_TARGET_MAJOR=8) else (set IE_VERSION_TARGET_MAJOR=7)
if "%OS_SP_VERSION_MAJOR%"=="" goto SetOfficeName
goto Windows%OS_VERSION_MAJOR%.%OS_VERSION_MINOR%.%OS_SP_VERSION_MAJOR%
:Windows6.0.0
set OS_SP_VERSION_TARGET_MAJOR=1
set OS_SP_TARGET_ID=KB936330
goto SetOfficeName
:Windows6.0.1
:Windows6.0.2
set OS_SP_VERSION_TARGET_MAJOR=2
set OS_SP_TARGET_ID=KB948465
goto SetOfficeName

:SetOfficeName
if "%O2K_VERSION_MAJOR%"=="" goto NoO2k
rem *** Office 2000 ***
set OFFICE_NAME=o2k
set OFFICE_LANGUAGE=%O2K_LANGUAGE%
set O2K_SP_VERSION_TARGET=3
set O2K_SP_TARGET_ID=O2kSp3
if %O2K_SP_VERSION% EQU 0 set O2K_PREC_SP_TARGET_ID=o2ksr1adl
:NoO2k
if "%OXP_VERSION_MAJOR%"=="" goto NoOxp
rem *** Office XP ***
set OFFICE_NAME=oxp
set OFFICE_LANGUAGE=%OXP_LANGUAGE%
set OXP_SP_VERSION_TARGET=3
set OXP_SP_TARGET_ID=KB832671
:NoOxp
if "%O2K3_VERSION_MAJOR%"=="" goto NoO2k3
rem *** Office 2003 ***
set OFFICE_NAME=o2k3
set OFFICE_LANGUAGE=%O2K3_LANGUAGE%
set O2K3_SP_VERSION_TARGET=3
set O2K3_SP_TARGET_ID=KB923618
:NoO2k3
if "%O2K7_VERSION_MAJOR%"=="" goto NoO2k7
rem *** Office 2007 ***
set OFFICE_NAME=o2k7
set OFFICE_LANGUAGE=%O2K7_LANGUAGE%
set O2K7_SP_VERSION_TARGET=2
set O2K7_SP_TARGET_ID=KB953195
:NoO2k7
goto EoF

:NoOSVersion
echo.
echo ERROR: Environment variable OS_VERSION_MAJOR not set.
echo.
exit /b 1

:EoF