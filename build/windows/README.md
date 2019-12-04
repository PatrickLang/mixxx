# Building Mixxx using Containers

Containers can provide a cleaner build environment and avoid problems with conflicting versions of build tools or libraries from other projects you may need to build. You can also share it privately among your machines, just don't post it publically since Microsoft doesn't allow things like Visual Studio build tools to be shared on sites other than the official ones on Microsoft.com.

## Building the container

There are two different combos that work with this Dockerfile for setting up clean build environments:

- [Windows 10](#using-windows-10) version 1903 or later with Docker Desktop
- [Windows Server 2019](#using-windows-server-2019) with Docker EE-basic

### Using Windows Server 2019

> TODO: Update daemon.conf to set >100GB
```
  "storage-opts": [
    "size=120Gb"
  ]
```

This is the fastest option as it can use process isolation and doesn't need extra settings to use all CPU & RAM. However, you may want to add those if you're running other services on the same host to avoid resource contention.

`docker build -t mixxx-build -f Dockerfile .`

### Using Windows 10

> TODO: Update daemon.conf to set >100GB
```
  "storage-opts": [
    "size=120Gb"
  ]
```
> This also needs a fix tracked in https://github.com/docker/engine/pull/429 and a new release of Docker for Windows to succeed :(



Docker Desktop defaults to 2 cores, 1GB of RAM which isn't sufficient. `-m 2g` or higher is needed to give the container more memory.

`docker build -m 4g -t mixxx-build -f Dockerfile .`


### Troubleshooting builds

The Visual Studio installer doesn't give detailed output during the `docker build`. If something doesn't install completely, you may see errors like msbuild.exe not found.

To get more details on that, run `c:\temp\vscollect.exe` inside the build container, and copy the zip file out that it creates. The `dd_client_<timestamp>.log` file is the first one to look at. Look for lines with `| Error |` in them such as this:

```
2019-12-03T21:34:40 : Error : Visual Studio needs at least 92.95 GB of disk space. Try to free up space on C:\ or change your target drive.
```

That's the error you would get if you don't update the Docker daemon config before building the container.

## Running the build environment

From the root of your repo, run this:

```powershell
.\build\windows\container-build.ps1
```

Once the container has started, do a build with `build\windows\build.bat`

> TODO - still need some adjustments for build to pass