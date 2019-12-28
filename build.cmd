@echo off
SETLOCAL enableDelayedExpansion

if "%1" == "clean" (
REM Clean up after old builds.
del /q /f *.exe
del /q /f .sconsign.dblite
del config.h
rmdir /s /q dist32
rmdir /s /q dist64
rmdir /s /q .sconf_temp
rmdir /s /q win32_build
rmdir /s /q win64_build
rmdir /s /q cache
)

REM x86 or x64
SET LOCAL_PROCESSOR=x64

REM debug, release or release-fastbuild. Warning: The debug buildenv is not prebuilt so you need to build it yourself.
SET LOCAL_BUILDMODE=release-fastbuild

REM The name of the directory where the libraries are located (and the name of the file to download).
REM For the precompiled ones, it is automatically filled from ./build/windows/golden_environment 
REM You can replace this detection with the correct name if it does not apply to your setup.
set /P LOCAL_WINLIB_NAME=<build/windows/golden_environment
set LOCAL_WINLIB_NAME=!LOCAL_WINLIB_NAME:PLATFORM=%LOCAL_PROCESSOR%!
set LOCAL_WINLIB_NAME=!LOCAL_WINLIB_NAME:CONFIGURATION=%LOCAL_BUILDMODE%!

REM %~dp0.. means the parent folder of your mixxx source code.
SET LOCAL_WINLIB_PARENT=%~dp0..

REM This sets the number of processors to half or what Windows reports. 
REM This is done because most processors have some sort of hyperthreading and we want only real cores.
REM IF %NUMBER_OF_PROCESSORS% GTR 1 (
REM   SET /A LOCAL_NUMBER_PROCS=%NUMBER_OF_PROCESSORS%/2
REM ) ELSE (
REM   SET /A LOCAL_NUMBER_PROCS=%NUMBER_OF_PROCESSORS%
REM )

for /f "usebackq tokens=*" %%i in (`powershell.exe -Command "(Get-WmiObject -Namespace root\cimv2 Win32_Processor).NumberOfCores"`) do SET /A LOCAL_NUMBER_PROCS=%%i
SET SCONS_NUMBER_PROCESSORS=-j%LOCAL_NUMBER_PROCS%

call ./build/windows/install_buildenv.bat http://downloads.mixxx.org/builds/buildserver/2.3.x-windows/ %LOCAL_WINLIB_NAME% %LOCAL_WINLIB_PARENT%
if ERRORLEVEL 1 ENDLOCAL && EXIT /b

REM skiptest means that we don't want to build and execute the mixxx-test.
REM skipinstaller means that we don't want to generate the installer after the build.
./build/appveyor/build_mixxx.bat %LOCAL_PROCESSOR% %LOCAL_BUILDMODE% %LOCAL_WINLIB_PARENT%\%LOCAL_WINLIB_NAME% skiptest skipinstaller

ENDLOCAL