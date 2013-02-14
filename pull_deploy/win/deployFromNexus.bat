@Echo Off && setlocal
rem Set working dir to local dir
PUSHD "%~dp0"
 
 
rem
rem Script to download an artifact from Nexus. Then unpack, and replace existing version of the artifact
rem
rem Usge: DeployFromNexus repogroup artifact version
rem
 
rem echo Verify parameters
rem call :VERIFYPARAMETERS
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
rem 
rem
rem
rem To get a proper file name when wget follows redirects
rem wget --content-disposition --no-check-certificate --trust-server-names=on "http://mvnrepo.cantara.no/service/local/artifact/maven/content?r=snapshots&g=no.yenka.giftit&a=giftit-deploy-mobile&v=LATEST&c=android&p=apk"
rem
rem
rem Find latest file on the file system: http://stackoverflow.com/questions/97371/how-do-i-write-a-windows-batch-script-to-copy-the-newest-file-from-a-directory
rem
rem 
rem TODO Add support for username and password when downloading
rem
rem
rem Unclear to test on my repo which is empty. set BASE_URL=http://127.0.0.1/nexus/service/local/artifact/maven/redirect?
rem set BASE_URL=http://repository.sonatype.org/service/local/artifact/maven/redirect?
set BASE_URL=http://mvnrepo.cantara.no/service/local/artifact/maven/redirect?
rem set RELEASE_REPO=central-proxy
rem set SNAPSHOT_REPO=
set REPO=snapshots
set GROUP=no.yenka.giftit
set ARTIFACT=giftit-deploy-mobile
set VERSION=LATEST
set CLASSIFIER=android
set PACKAGING=apk
EXIT /B
 
:DOWNLOAD
set URL="%BASE_URL%r=%REPO%&g=%GROUP%&a=%ARTIFACT%&v=%VERSION%&c=%CLASSIFIER%&p=%PACKAGING%"
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
