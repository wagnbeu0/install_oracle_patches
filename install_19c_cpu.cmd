@echo off
REM Script for automatic upgrade for critical Oracle Patches on Windows

echo Script for automatic patch of Oracle

cd /d %~DP0

set SCRIPT_ROOT=%~DP0
set ORACLE_HOME=D:\Oracle\product\19c
set ORACLE_BASE=D:\Oracle
set PATH=%PATH%;%ORACLE_HOME%/bin/
set PATH=%PATH%;%ORACLE_HOME%/OPatch
set PATCH=%1
for /f "tokens=1 delims=_" %%i in ('echo %PATCH%') do set PATCH=%%i
set PATCH_FOLDER=%PATCH:~1%
set PATCH_NUMBER=%PATCH:~1,8%
set ROOT_FOLDER=%~DP0%PATCH_FOLDER%
set OPATCH_FILE=p6880880_190000_MSWIN-x86-64.zip

if not exist %ORACLE_HOME% (
        echo ================================================================
        echo Sorry: ORACLE_HOME $ORACLE_HOME does not exist. 
        echo Please enter the correct value and try again!
        echo ================================================================
		goto :EOF
)

if not exist %OPATCH_FILE% (
robocopy %PATCH_SOURCE%\%OPATCH_FILE% %SCRIPT_ROOT%
)

if "%1" == "" (
	echo ================================================================
	echo Wrong syntax:
	echo Please apply the name of the Patch file:
	echo.
	echo ./install_19c_cpu.cmd p^<Oracle Patch number^>.zip
	echo.
	echo ================================================================
	goto :EOF
)

echo.
echo Check if patch %PATCH_NUMBER% is already installed
opatch lsinventory | findstr %PATCH_NUMBER% | findstr applied
if "%ERRORLEVEL%" == "0" (
echo.
echo Oracle Patch %PATCH_NUMBER% already installed.
echo Will Skip Installation
echo.
goto :EOF) ELSE (
echo.
echo Oracle Patch %PATCH_NUMBER% not installed.
echo Will continue installation
echo.
)

if not exist %1 (
		echo ================================================================
		echo The Patch %1 does not exist in the current directory.
		echo Will copy it now:
		robocopy %PATCH_SOURCE% %SCRIPT_ROOT% %1
		robocopy %PATCH_SOURCE% %SCRIPT_ROOT% p6880880_190000_MSWIN-x86-64.zip
		if not exist %1 (
		echo File could not be copied.
		echo Please copy it to this folder and run again.
		echo ================================================================
		goto :EOF
		)
)


echo Patch OPatch to latest version
rmdir /s /q %ORACLE_HOME%\OPatch
D:\SW\7-zip\7za.exe x -aoa -o%ORACLE_HOME% %~DP0\%OPATCH_FILE%
D:\SW\7-zip\7za.exe x -aoa -o%SCRIPT_ROOT% %1
cd /d %PATCH_FOLDER%
set PATCH_FOLDER=%CD%
echo Current Patch folder is %ROOT_FOLDER%
call opatch prereq CheckConflictAgainstOHWithDetail -ph ./

echo Patch the following Oracle Home:	%ORACLE_HOME%
net stop "OracleServiceSANDBOX"
net stop "OracleOraDB19Home1TNSListener"
net stop "OracleVssWriterSANDBOX"

echo cd %ROOT_FOLDER%
cd /d %ROOT_FOLDER%
call opatch apply -silent

echo start all local listeners
net start "OracleOraDB19Home1TNSListener"
net start "OracleServiceSANDBOX"
net start "OracleVssWriterSANDBOX"

echo Patch Oracle PSU Tables
call %ORACLE_HOME%/OPatch/datapatch -verbose
echo Delete Patchfolder to clean up
cd /d %~DP0
rmdir /s /q %PATCH_FOLDER%
del /q %1

echo	All local databases has been successful patched with patch %PATCH%
