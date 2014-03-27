@echo off

VERIFY BADVALUE 2> NUL
SETLOCAL ENABLEEXTENSIONS EnableDelayedExpansion
IF ERRORLEVEL 1 ECHO Unable to enable command extensions.

::Check that two parameters are available
IF [%1] == [] GOTO :USAGE
IF [%2] == [] GOTO :USAGE


::Set variables from input line.
set group=%1
set module=%2
set VERSION=%3
set REPO=%4

IF [%VERSION%] == [] set VERSION=LATEST
IF [%REPO%] == [] set REPO=snapshots

::Build URL Wendy 
set BASE_URL=http://<nexus-host>:<port>/nexus/service/local/artifact/maven/
set GROUP=%1
set ARTIFACT=%module%
set PACKAGING=zip
set METADATA_URL="%BASE_URL%resolve?r=%REPO%&g=%GROUP%&a=%ARTIFACT%&v=%VERSION%"
set DOWNLOAD_URL="%BASE_URL%redirect?r=%REPO%&g=%GROUP%&a=%ARTIFACT%&v=%VERSION%&p=%PACKAGING%"


:: Set some global constants
set BaseDir=..\
set StatusMsg=Started

:: Clean and recreate tmp folder
set TmpDir=%BaseDir%\_tmp_%module%
if  exist %TmpDir% (
	rmdir /S /Q %TmpDir%	
) 
mkdir %TmpDir%

set VersionFile=%TmpDir%\%module%-version.txt

::Find the latest version from Nexus repository
echo Find version from %METADATA_URL% See %VersionFile% for latest version.
wget.exe -O %VersionFile% --content-disposition %METADATA_URL%

for /F "tokens=3 delims=<>" %%i in ('findstr "<version>" %VersionFile%') do set LatestVersion=%%i
:: Verify if new version is the same as the one installed
:: If so, exit
if exist %LatestVersion% %BaseDir%\%module%\%module%-version.txt {
	findstr /m %LatestVersion% %BaseDir%\%module%\%module%-version.txt
}

if %errorlevel%==0 (
	echo Exiting without updating
	set StatusMsg=Requested version, %LatestVersion%, is already installed. Exiting without replacing the running code.
	goto :END
)

:: Download artifact
%~dp0\wget.exe -P "%TmpDir%" --content-disposition %DOWNLOAD_URL%


:: Store names of latest snapshot files in environment variables
dir %TmpDir%\%module%-*.zip /b /a-d /od > %TmpDir%\%module%-latest.txt
set /p ZipFile= < %TmpDir%\%module%-latest.txt

:: echo 'Check that download was success'
if not exist %TmpDir%\%ZipFile% (
    set StatusMsg="Download failed of file %ZipFile%"
	goto :END
)
echo 'Download OK'

if exist %BaseDir%\%module%\bin (
	echo 'Uninstalling %module%'
	call %BaseDir%\%module%\bin\ServiceUninstall.bat -q
)

echo 'Remove existing installed components and create new folders'
if exist %BaseDir%\%module% (
	rmdir /S /Q %BaseDir%\%module%
	mkdir %BaseDir%\%module%
)

echo 'Extract components'
unzip -q -o %TmpDir%\%ZipFile% -d %BaseDir%\%module%

if exist %BaseDir%\%module%_config_override (
    echo "Use config overrides from %BaseDir%\%module%_config_override"
	if not exist %BaseDir%\%module%\config_override\ (
		mkdir %BaseDir%\%module%\config_override\
	)
    copy %BaseDir%\%module%_config_override\*.* %BaseDir%\%module%\config_override\
)

:: Update Version Info in installed dir.
echo %LatestVersion% > %BaseDir%\%module%\%module%-version.txt

:: Install and start
if exist %BaseDir%\%module%\bin (
	echo "Installing %module% %LatestVersion%"
	%BaseDir%\%module%\bin\ServiceInstall.bat -q
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
EXIT /B

:USAGE
echo *****************************
echo usage:  %0 group module version repo 
echo where: group is eg: com.company.project
echo where: module is eg: webapp
echo where: version is: 1.4, LATEST or 1.5-SNAPSHOT
echo where: repo is the id of the repo like: releases or snapshots 
echo See how Maven is using group and artifact. Artifact equals module. http://maven.apache.org/pom.html
echo *****************************

