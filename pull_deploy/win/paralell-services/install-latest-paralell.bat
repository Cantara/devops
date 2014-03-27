@echo off

VERIFY BADVALUE 2> NUL
SETLOCAL ENABLEEXTENSIONS EnableDelayedExpansion
IF ERRORLEVEL 1 ECHO Unable to enable command extensions.

::Check that two parameters are available
IF [%1] == [] GOTO :USAGE
IF [%2] == [] GOTO :USAGE
IF [%3] == [] GOTO :USAGE

::Set variables from input line.
set group=%1
set module=%2
set name=%3

::Build URL
set BASE_URL=http://<nexus-host>:<port>/nexus/service/local/artifact/maven/
set GROUP=%1
set ARTIFACT=%module%
set VERSION=LATEST
set REPO=snapshots
set PACKAGING=zip
set METADATA_URL="%BASE_URL%resolve?r=%REPO%&g=%GROUP%&a=%ARTIFACT%&v=%VERSION%"
set DOWNLOAD_URL="%BASE_URL%redirect?r=%REPO%&g=%GROUP%&a=%ARTIFACT%&v=%VERSION%&p=%PACKAGING%"



:: Set some global constants
set BaseDir=.
set StatusMsg=Started
set WRAPPER_CONF_OVERRIDES=wrapper.ntservice.name=%name% wrapper.ntservice.displayname=%name% wrapper.ntservice.description=%name%

:: Clean and recreate tmp folder
set TmpDir=%BaseDir%\_tmp_%module%
rmdir /S /Q %TmpDir%
mkdir %TmpDir%

set VersionFile=%TmpDir%\%module%-version.txt

::Find the latest version from Nexus repository
echo Find version from %METADATA_URL% See %VersionFile% for latest version.
wget.exe -O %VersionFile% --content-disposition %METADATA_URL%


for /F "tokens=3 delims=<>" %%i in ('findstr "<version>" %VersionFile%') do set LatestVersion=%%i

:: Verify if new version is the same as the one installed
:: If so, exit
findstr /m %LatestVersion% %BaseDir%\%module%\%module%-version.txt
if %errorlevel%==0 (
	echo Exiting without updating
	set StatusMsg=Latest version is installed already %LatestVersion%. Exiting without replacing the running code.
    goto :END
)

:: Download latest snapshots
%~dp0\wget.exe -P "%TmpDir%" --content-disposition %DOWNLOAD_URL%


:: Store names of latest snapshot files in environment variables
dir %TmpDir%\%module%-*.zip /b /a-d /od > %TmpDir%\%module%-latest.txt
set /p ZipFile= < %TmpDir%\%module%-latest.txt

:: Check that download was success
if not exist %TmpDir%\%ZipFile% (
    set StatusMsg="Download failed of file %ZipFile%"
	goto :END
)


:: Uninstall
if exist %BaseDir%\%module%\bin (
    echo "Remove cmd: "%BaseDir%\%module%\bin\%module%.bat remove 
    call %BaseDir%\%module%\bin\%module%.bat remove 
)


:: Remove existing installed components
rmdir /S /Q %BaseDir%\%module%

:: Create new folders
mkdir %BaseDir%\%module%

:: Extract components
unzip -q -o %TmpDir%\%ZipFile% -d %BaseDir%\%module%

if exist %BaseDir%\config_override (
    echo "Use config overrides from %BaseDir%\config_override"
    copy %BaseDir%\config_override\*.* %BaseDir%\%module%\config_override\
)
:: Update Version Info in installed dir.
echo %LatestVersion% > %BaseDir%\%module%\%module%-version.txt



:: Install and start
if exist %BaseDir%\%module%\bin (
    call %BaseDir%\%module%\bin\%module%.bat install 
    call %BaseDir%\%module%\bin\%module%.bat start 
)

set StatusMsg=Succsssfully updated to the latest version %LatestVersion%


:END
echo
echo ****************************
echo *** Finished
echo *** !StatusMsg!
echo ***

pause
endlocal
EXIT /B

:USAGE
echo *****************************
echo usage:  %0 group module
echo where: group is eg: com.company.project
echo where: mudule is eg: webapp
echo where: name is service name to use
echo See how Maven is using group and artifact. Artifact equals module. http://maven.apache.org/pom.html
echo *****************************

