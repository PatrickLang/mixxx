rem This is based off https://www.mixxx.org/wiki/doku.php/compiling_on_windows
rem but simplified using vswhere, and using the tools installed using this Vagrantfile
rem   https://github.com/PatrickLang/buildserver/tree/2.3.x-windows-vs2019/Vagrant

for /f "usebackq tokens=*" %%i in (`vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set MSVC_PATH=%%i
if not exist "%MSVC_PATH%" (
    echo Couldn't find Visual Studio. Exiting.
    exit /b 1
)

SET "BUILDTOOLS_PATH=%MSVC_PATH%"

if "%WINLIB_PATH%" == "" (
    if exist "c:\source\buildserver\lib" (
        SET "WINLIB_PATH=c:\source\buildserver"
    ) else (
        echo WINLIB_PATH wasn't set, Exiting
        exit /b 1
    )
)

SET QTDIR=c:\source\buildserver\Qt-5.12.0
SET BIN_DIR=%WINLIB_PATH%\bin
set PATH=%BIN_DIR%;%PATH%
SET BUILDTOOLS_SCRIPT=VC\Auxiliary\Build\vcvarsall.bat

set CL=/MP /FS /EHsc
set BUILD_TYPE=release
set TARGET_MACHINE=amd64
set VCVARS_ARCH=x86_amd64
rem autodetect architecture?
call "%BUILDTOOLS_PATH%\%BUILDTOOLS_SCRIPT%" %VCVARS_ARCH%

scons -j%NUMBER_OF_PROCESSORS% toolchain=msvs winlib=%WINLIB_PATH% build=%BUILD_TYPE% staticlibs=1 staticqt=1 verbose=0 machine=%TARGET_MACHINE% qtdir=%QTDIR% hss1394=1 mediafoundation=1 opus=1 localecompare=1 optimize=portable virtualize=0 test=1 qt_sqlite_plugin=0 build_number_in_title_bar=0 bundle_pdbs=1