@Echo Off && setlocal
rem Set working dir to local dir
PUSHD "%~dp0"
 
 
rem
rem Script to download an artifact from Nexus. Then unpack, and replace existing version of the artifact
rem
rem Usge: DeployFromNexus repogroup artifact version
rem
 
echo Verify parameters
call :VERIFYPARAMETERS
echo Set variables
call :SETVARIABLES
echo Download artifact
call :DOWNLOAD
echo Unpack
call :UNPACK
echo Run install script
call BackupAndInstall.bat %ARTIFACT% %VERSION% %ARTIFACT%-%VERSION%
 
goto :END
 
:SETVARIABLES
rem Unclear to test on my repo which is empty. set BASE_URL=http://127.0.0.1/nexus/service/local/artifact/maven/redirect?
set BASE_URL=http://repository.sonatype.org/service/local/artifact/maven/redirect?
set RELEASE_REPO=central-proxy
set SNAPSHOT_REPO=
set GROUP=log4j
set ARTIFACT=log4j
set VERSION=LATEST
EXIT /B
 
:DOWNLOAD
set URL="%BASE_URL%r=%RELEASE_REPO%&g=%GROUP%&a=%ARTIFACT%&v=%VERSION%"
set FILENAME=%ARTIFACT%-%VERSION%.zip
rem TODO improvement - filename should actually reflect the version downloaded
rem Setting static filename to be able to work on it after.
 
echo Url to be called: %URL%
call wget.exe --no-check-certificate -O %FILENAME% %URL%
 
if %errorlevel%==0 (
echo Downloaded ok from repo to file %FILENAME%
) else (
echo Download failed
 goto :END
)
EXIT /B
 
:UNPACK
call unzip -o %FILENAME% -d %ARTIFACT%-%VERSION%
EXIT /B
 
 
 
 
 
 
:END
rem
rem Done and exit
rem
endlocal
echo Done
EXIT /B
 
 
 
rem
rem Thanks to http://www.askapache.com for ideas and examples.
rem