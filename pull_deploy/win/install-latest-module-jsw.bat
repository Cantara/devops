::Endringer:
::ip-adresse endret til mvnrepo
::set USER=%5
::set PWD=%6

@echo off
cls

VERIFY BADVALUE 2> NUL
SETLOCAL ENABLEEXTENSIONS EnableDelayedExpansion
IF ERRORLEVEL 1 ECHO Unable to enable command extensions.

::Check that two parameters are available
IF [%1] == [] GOTO :USAGE
IF [%2] == [] GOTO :USAGE


::Set variables from input line.
set GROUP=%1
set ARTIFACT=%2
set VERSION=%3
set REPO=%4
set USER=%5
set PWD=%6

IF [%VERSION%] == [] set VERSION=LATEST
IF [%REPO%] == [] set REPO=snapshots
IF [%INSTALL_DIR%] == [] set INSTALL_DIR=%ARTIFACT%

::Build URL to Nexus @ Wendy
::set BASE_URL=http://mvnrepo:8081/nexus/service/local/artifact/maven/
set BASE_URL=http://<nexus-host>:<port>/nexus/service/local/artifact/maven/
set PACKAGING=zip
set METADATA_URL="%BASE_URL%resolve?r=%REPO%&g=%GROUP%&a=%ARTIFACT%&v=%VERSION%"
set DOWNLOAD_URL="%BASE_URL%redirect?r=%REPO%&g=%GROUP%&a=%ARTIFACT%&v=%VERSION%&p=%PACKAGING%"

:: Set some global constants
set BaseDir=..
set StatusMsg=Started

:: Clean and recreate tmp folder
set TmpDir=%BaseDir%\_tmp_%INSTALL_DIR%
rmdir /S /Q %TmpDir%
mkdir %TmpDir%

set VersionFile=%TmpDir%\%ARTIFACT%-version.txt

::Find the latest version from Nexus repository
echo Find version from %METADATA_URL% See %VersionFile% for latest version.
wget.exe -O %VersionFile% --content-disposition %METADATA_URL%

for /F "tokens=3 delims=<>" %%i in ('findstr "<version>" %VersionFile%') do set LatestVersion=%%i
:: Verify if new version is the same as the one installed
:: If so, exit
if exist %LatestVersion% %BaseDir%\%INSTALL_DIR%\%ARTIFACT%-version.txt {
	findstr /m %LatestVersion% %BaseDir%\%INSTALL_DIR%\%ARTIFACT%-version.txt
}

if %errorlevel%==0 (
	echo Exiting without updating
	set StatusMsg=Requested version, %LatestVersion%, is already installed. Exiting without replacing the running code.
    goto :END
)

:: Download artifact
%~dp0\wget.exe -P "%TmpDir%" --content-disposition %DOWNLOAD_URL%


:: Store names of latest snapshot files in environment variables
dir %TmpDir%\%ARTIFACT%-*.zip /b /a-d /od > %TmpDir%\%ARTIFACT%-latest.txt
set /p ZipFile= < %TmpDir%\%ARTIFACT%-latest.txt

:: Check that download was success
if not exist %TmpDir%\%ZipFile% (
    set StatusMsg="Download failed of file %ZipFile%"
	goto :END
)
echo 'Download OK'


if exist %BaseDir%\%INSTALL_DIR%\bin (
	echo 'Uninstalling %INSTALL_DIR%'
    call %BaseDir%\%INSTALL_DIR%\bin\%ARTIFACT%.bat remove
)

echo 'Remove existing installed components and create new folders'
if exist %BaseDir%\%INSTALL_DIR% (
	rmdir /S /Q %BaseDir%\%INSTALL_DIR%
	mkdir %BaseDir%\%INSTALL_DIR%
)

echo 'Extract components'
unzip -q -o %TmpDir%\%ZipFile% -d %BaseDir%\%INSTALL_DIR%


echo "Use config overrides from %BaseDir%\%INSTALL_DIR%_config_override"
if not exist %BaseDir%\%INSTALL_DIR%_config_override\ (
	mkdir %BaseDir%\%INSTALL_DIR%_config_override\
)
if not exist %BaseDir%\%INSTALL_DIR%\config_override\ (
	mkdir %BaseDir%\%INSTALL_DIR%\config_override\
)	
copy %BaseDir%\%INSTALL_DIR%_config_override\*.* %BaseDir%\%INSTALL_DIR%\config_override\

:: Update Version Info in installed dir.
echo %LatestVersion% > %BaseDir%\%INSTALL_DIR%\%ARTIFACT%-version.txt

:: Install and start
if exist %BaseDir%\%INSTALL_DIR%\bin (	
	call %BaseDir%\%INSTALL_DIR%\bin\%ARTIFACT%.bat install
	IF NOT [%NTSERVICENAME%] == [] (	
		sc config "%NTSERVICENAME%" obj= "%COMPUTERNAME%\%USER%" password= "%PWD%"
	)
	REM %USER% must be added as logon user once manually 
    call %BaseDir%\%INSTALL_DIR%\bin\%ARTIFACT%.bat start
)

set StatusMsg=Succsssfully updated to the latest version %LatestVersion%

:END
echo
echo ****************************
echo *** Finished
echo *** !StatusMsg!
echo ***

REM pause
endlocal
set WRAPPER_CONF_OVERRIDES=
set NTSERVICENAME=
set INSTALL_DIR=
EXIT /B

:USAGE
echo *****************************
echo usage:  %0 group ARTIFACT version repo 
echo where: group is eg: com.company.project
echo where: ARTIFACT is eg: webapp
echo where: version is: 1.4, LATEST or 1.5-SNAPSHOT
echo where: repo is the id of the repo like: releases or snapshots 
echo See how Maven is using group and artifact. http://maven.apache.org/pom.html
echo *****************************

REM ECHO sc config "%wrapper.ntservice.name%" obj= "%COMPUTERNAME%\TPAdmin" password= "pwHere"
