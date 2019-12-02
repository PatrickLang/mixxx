@echo off
SETLOCAL
REM Clean up after old builds.
del /q /f *.exe
rmdir /s /q dist32
rmdir /s /q dist64

REM this can be either release or debug. For development you want to use debug
set BUILD_TYPE=release

REM This determines if you build a 32bit or 64bit version of mixxx. 
REM 32bit = i386, 64bit = amd64
set ARCHITECTURE=amd64

REM set this to the folder where you built the dependencies
REM set WINLIB_PATH="**Enter Path to WINLIB_PATH**"    - commented out since set in container's machine registry hive
SET BIN_DIR=%WINLIB_PATH%\bin
REM make sure the Qt version matches the version in WINLIB_PATH.
set QT_VERSION=5.11.2
SET QTDIR=%WINLIB_PATH%\Qt-%QT_VERSION%

if "%ARCHITECTURE%" == "i386" (
  set TARGET_MACHINE=x86
  set VCVARS_ARCH=x86
) else ( 
  set TARGET_MACHINE=amd64
  set VCVARS_ARCH=x86_amd64
)

REM Adjust to your environment
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\vsdevcmd.bat" %VCVARS_ARCH%

rem /MP Use all CPU cores.
rem /FS force synchronous PDB writes (prevents PDB corruption with /MP)
rem /EHsc Do not handle SEH in try / except blocks.
set CL=/MP /FS /EHsc

set PATH=%BIN_DIR%;%PATH%
REM Set the -j value to the number of CPU cores (not HT "virtual" cores but physical cores) you have
scons -j2 toolchain=msvs winlib=%WINLIB_PATH% build=%BUILD_TYPE% staticlibs=1 staticqt=1 verbose=0 machine=%TARGET_MACHINE% qtdir=%QTDIR% hss1394=1 mediafoundation=1 opus=1 localecompare=1 optimize=portable virtualize=0 test=1 qt_sqlite_plugin=0 build_number_in_title_bar=0 bundle_pdbs=1
ENDLOCAL