# This is based on a combination of these Dockerfiles, then customized for the Mixxx builds
# for VS build tools: https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019
# for Python: https://github.com/docker-library/python/blob/master/2.7/windows/windowsservercore-1809/Dockerfile


# Use the latest Windows Server Core image with .NET Framework 4.8.
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\\TEMP\\vs_buildtools.exe

# Install Build Tools excluding workloads and components with known issues.
RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache \
    --installPath C:\BuildTools \
    --all \
	--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 \
    --remove Microsoft.VisualStudio.Component.Windows81SDK \
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

# Start developer command prompt with any other commands specified.
# ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&

# Python install scripts expect PowerShell
SHELL ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]

ENV PYTHON_VERSION 2.7.17
ENV PYTHON_RELEASE 2.7.17

RUN $url = ('https://www.python.org/ftp/python/{0}/python-{1}.amd64.msi' -f $env:PYTHON_RELEASE, $env:PYTHON_VERSION); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'python.msi'; \
	\
	Write-Host 'Installing ...'; \
	Start-Process msiexec -Wait \
		-ArgumentList @( \
			'/i', \
			'python.msi', \
			'/quiet', \
			'/qn', \
			'TARGETDIR=C:\Python', \
			'ALLUSERS=1', \
			'ADDLOCAL=DefaultFeature,Extensions,TclTk,Tools,PrependPath' \
		); \
	\
# the installer updated PATH, so we should refresh our local value
	$env:PATH = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::Machine); \
	\
	Write-Host 'Verifying install ...'; \
	Write-Host '  python --version'; python --version; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item python.msi -Force; \
	\
	Write-Host 'Complete.'

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 19.3.1
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/ffe826207a010164265d9cc807978e3604d18ca0/get-pip.py
ENV PYTHON_GET_PIP_SHA256 b86f36cc4345ae87bfd4f10ef6b2dbfa7a872fbff70608a1e43944d283fd0eee

RUN Write-Host ('Downloading get-pip.py ({0}) ...' -f $env:PYTHON_GET_PIP_URL); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $env:PYTHON_GET_PIP_URL -OutFile 'get-pip.py'; \
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:PYTHON_GET_PIP_SHA256); \
	if ((Get-FileHash 'get-pip.py' -Algorithm sha256).Hash -ne $env:PYTHON_GET_PIP_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host ('Installing pip=={0} ...' -f $env:PYTHON_PIP_VERSION); \
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		('pip=={0}' -f $env:PYTHON_PIP_VERSION) \
	; \
	Remove-Item get-pip.py -Force; \
	\
	Write-Host 'Verifying pip install ...'; \
	pip --version; \
	\
	Write-Host 'Complete.'

# install "virtualenv", since the vast majority of users of this image will want it
RUN pip install --no-cache-dir virtualenv
RUN pip install scons

# TODO: install git


# get dependent libraries
# TODO: different base URLs per release (2.2.x-windows vs 2.3.x-windows)
ADD golden_environment c:\\mixxx\\golden_environment
RUN mkdir c:\\mixxx\\winlib
WORKDIR c:\\mixxx
RUN $goldenEnvironment = (Get-Content c:\\mixxx\\golden_environment) \
         -replace 'PLATFORM', 'x64' \
         -replace 'CONFIGURATION', 'release'; \
    $libUrl = 'https://downloads.mixxx.org/builds/buildserver/2.3.x-windows/{0}.zip' -f $goldenEnvironment ; \
    Write-Host 'Fetching ' $libUrl; \
    curl.exe -L $libUrl -o golden_environment.zip; \
    cd winlib; \
    Expand-Archive -Force ..\\golden_environment.zip

RUN [System.Environment]::SetEnvironmentVariable('WINLIB_PATH', "$((Get-ChildItem -Path .\\winlib\\golden_environment -Directory).FullName)", [System.EnvironmentVariableTarget]::Machine)
WORKDIR c:\\mixxx\\src