@Echo Off 
setlocal
rem Set working dir to local dir
PUSHD "%~dp0"
 
rem
rem Purpose of this script is to backup existing working software, then replace this with new version.
rem Stop service
rem Move old directory to backup dir.
rem Move newly unpacked dir into prod dir.
rem Start service again
rem
 
 
rem ERROR CODES
set ERR-OK=0
set ERR-NO-DIR=2
 
 
rem Usage: BackupAndInstall.bat artifact version new-directory
 
echo Set variables
goto SETVARIABLES
:DOSTUFF
echo Stop the service
rem call :STOPSERVICE
echo Backup exising prod environment
call :BACKUP
if %ERRORLEVEL%==0 (
  echo Upgrade to new versionx
  rem call :UPGRADE
  rem call :RUNSCRIPT
)
rem Start the service again.
rem call :STARTSERVICE
 
 
goto :END
 
:SETVARIABLES
set ARTIFACT=%~1
set VERSION=%2
set EXPANDED-DIR=%3
 
echo Variables: ARTIFACT=%ARTIFACT%, VERSION=%VERSION%, EXPANDED-DIR=%EXPANDED-DIR%
goto DOSTUFF
 
:STOPSERVICE
net stop %ARTIFACT%
EXIT /B
 
:BACKUP
rem Verify new directory exist
if not exist %EXPANDED-DIR% (
  echo New Directory does not exist, exiting
  EXIT /B %ERR-NO-DIR%
) 
 
rem delete old backup dir
if exist %ARTIFACT%-OLD (
    echo Deliting %ARTIFACT%-OLD
  call rmdir /S /Q %ARTIFACT%-OLD
)
rem move old directory to backup
echo Moving %ARTIFACT% to %ARTIFACT%-OLD
call move %ARTIFACT% %ARTIFACT%-OLD
 
EXIT /B
 
:UPGRADE
rem move new filsystem to production
echo Moving new content %EXPANDED-DIR% to %ARTIFACT%
call move %EXPANDED-DIR% %ARTIFACT% 
EXIT /B
 
:STARTSERVICE
net start %ARTIFACT%
EXIT /B
 
:RUNSCRIPT
rem %~nx1 Expands %1 to a file name and extension.
 
:END
rem
rem Done with install and exit
rem
endlocal
echo Done
EXIT /B