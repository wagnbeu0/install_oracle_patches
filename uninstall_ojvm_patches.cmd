@echo off
REM Script for automatic upgrade for critical Oracle Patches on Windows

set SCRIPT_ROOT=%~DP0
set ORACLE_HOME=D:\Oracle\product\19c
set ORACLE_BASE=D:\Oracle
set PATH=%PATH%;%ORACLE_HOME%/bin/
set PATH=%PATH%;%ORACLE_HOME%/OPatch

set PATCH_SOURCE=D:\SW\Oracle\Oracle_CPU_Patches\
cd /d %SCRIPT_ROOT%

echo Check Oracle Inventory
opatch lsinventory | findstr /i OJVM
if "%ERRORLEVEL%"=="1" (
	echo.
	echo ... No OVJM Patch installed
	goto :EOF
) ELSE (
	echo.
	echo ... OJVM Patch installed
	echo    ... Check if patch can be uninstalled
)

for /F "tokens=2 delims=()" %%i in ('opatch lsinventory ^| findstr /i OJVM') do set ID=%%i
if not exist %PATCH_SOURCE%\p%ID%_190000_MSWIN-x86-64.zip (
	echo.
	echo    ... Old Oracle Java Patch detected
	echo.
	echo Shutdown Oracle Instance
	net stop "OracleServiceSANDBOX"
	net stop "OracleOraDB19Home1TNSListener"
	net stop "OracleVssWriterSANDBOX"
	echo.
	echo 	... Uninstall Patch
	call opatch rollback -id %ID% -silent
	echo.
	echo 	... Startup Oracle Instance
	net start "OracleOraDB19Home1TNSListener"
	net start "OracleServiceSANDBOX"
	net start "OracleVssWriterSANDBOX"
) ELSE (
	echo.
	echo	... Current OVJM Patch, will skip uninstallation
)