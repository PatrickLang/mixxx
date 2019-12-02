# Building with Docker Desktop on Windows

There are two different combos that work with this Dockerfile for setting up clean build environments:

- [Windows 10](#using-windows-10) version 1903 or later with Docker Desktop
- [Windows Server 2019](#using-windows-server-2019) with Docker EE-basic


## Using Windows Server 2019

This is the fastest option as it can use process isolation and doesn't need extra settings to use all CPU & RAM. However, you may want to add those if you're running other services on the same host to avoid resource contention.

`docker build -t mixxx-build -f Dockerfile .`



## Using Windows 10

Docker Desktop defaults to 2 cores, 1GB of RAM which isn't sufficient. `-m 2g` or higher is needed to give the container more memory.

`docker build -m 4g -t mixxx-build -f Dockerfile .`


## Starting build environment

From the root of your repo, run this:

```powershell
.\build\windows\container-build.ps1
```

Once the container has started, do a build with `build\windows\build.bat`

> TODO - still need some adjustments for build to pass