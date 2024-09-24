@echo off
REM Script for automatic upgrade for critical Oracle Patches on Windows

set SCRIPT_ROOT=%~DP0
set PATCH_SOURCE=D:\SW\Oracle\Oracle_CPU_Patches\
set OPATCH_FILE=p6880880_190000_MSWIN-x86-64.zip
cd /d %SCRIPT_ROOT%

echo Run Prechecks
echo Check access to folder containing patches...
if not exist %PATCH_SOURCE% (
echo No Patchfolder available
) ELSE (
echo ... Access to %PATCH_SOURCE% possible
)
echo.

echo Check if all scripts are available:
for %%i in ("install_19c_cpu.cmd" "patch_opatch_19c.cmd" "uninstall_ojvm_patches.cmd" ) do if not exist "%%i" (
echo Warning - Missing File:
echo Please copy %%i 
echo to local folder and retry
pause
goto :EOF
) Else ( 
echo ... Needed Script %%i is available 
)
echo.

echo Check if latest OPatch are available:
if not exist %OPATCH_FILE% (
robocopy /NJH /NJS %PATCH_SOURCE% %SCRIPT_ROOT% %OPATCH_FILE%
) Else ( 
echo ... Opatch Update is available 
)
echo.
echo Prechecks successful. Continue with Patch installation
echo.
echo.

echo #####################################
echo.
echo Step 1 - Check for OJVM Patches
call uninstall_ojvm_patches.cmd
echo.
echo Step 2 - Run Installer to download and install latest Oracle packages
for /f %%i in ('dir /O-S /b %PATCH_SOURCE%p3*MSWIN*') do %~DP0install_19c_cpu.cmd %%i

goto :EOF


:MISSING_FILE
goto :EOF

:EOF