@echo off
REM Script for automatic upgrade for OPATCH on Windows
REM Version 1.0 - 13.04.2021

set ORACLE_HOME=D:\Oracle\product\19c
set ORACLE_BASE=D:\Oracle
set OPATCH_FILE=p6880880_190000_MSWIN-x86-64.zip
echo Patch OPatch to latest version
rmdir /s /q %ORACLE_HOME%\OPatch
D:\SW\7-zip\7za.exe x -aoa -o%ORACLE_HOME% %~DP0\%OPATCH_FILE%