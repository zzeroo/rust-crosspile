Docker Container to cross compile and pack rust binaries for Windows 32/ 64Bit.

This project has strong gkt+3 support.
And it includes the [NSIS (Nullsoft Scriptable Install System)].

[![GitLab CI status](https://gitlab.com/zzeroo/rust-crosspile/badges/master/pipeline.svg)](https://gitlab.com/zzeroo/rust-crosspile/pipelines)

![Rust Crosspile Logo](resources/Docker_Rust.svg)

# Usage:
First you have to build the container, from within **this** repo directory.
Your have to pass the user and group id of the your user to the build command.
See [here][docker containers as current user] why.

The following example builds a container named `rust-crosspile`.
This container builds the foundation for all your projects you whant to
cross compile.

**The container only has to be created once!**

```bash
docker image build \
  --build-arg USER_ID=$(id -u ${USER}) \
  --build-arg GROUP_ID=$(id -g ${USER}) \
  -t rust-crosspile \
  .
```

Now build a image **in your project's source directory!**.
Your sources are mounted as a docker VOLUME into this new created container.

The following example uses `PROJECT-build` as image name for that container.

**You have to create an image for each of your projects!**

```bash
# cd /path/to/your/project
docker create -v `pwd`:/home/rust/src --name PROJECT-build rust-crosspile:latest
```

From now on everytime you want compile and pack the latest version
just call `docker start IMAGE_NAME` from the root ouf your project's source dir.
Replace **IMAGE_NAME** with the name of the correct container for that project.
Use the parameter `-ai` to get the output in your current terminal sessison.

```bash
# cd /path/to/your/project
docker start -ai PROJECT-build
```

## The build process `package.sh`

The containers command is to run the file `package.sh` (see [that file])
from the path `/usr/bin/package.sh`.

**If you create such a file `package.sh` in the root of your own project you
have full controll of what commands are run in the crosscompile environment.
You can fully customize the whole script.**

## Cleanup
For cleanup just remove the project's container.

```bash
docker rm PROJECT-build
```

Then remove all `rust-crosspile` docker images.

```bash
docker rmi rust-crosspile
```

# Complete Usage Example

```bash
cd /tmp
git clone https://gitlab.com/zzeroo/rust-crosspile
cd rust-crosspile
docker build . -t rust-crosspile

cd /tmp
cargo new --bin hello-world
cd hello-world
docker create -v `pwd`:/home/rust/src --name HELLO-build rust-crosspile:latest
docker start -ai HELLO-build
```

## Cleanup

```bash
docker rm HELLO-build
# docker rmi rust-crosspile
cd /tmp
rm -rf hello-world
rm -rf rust-crosspile
```

# Tipps

One can test the environment with the following command:
```bash
docker run --rm -it -v$(pwd):/home/rust/src rust-crosspile /bin/bash
```

This will start an environment exactly like the one `docker start` creates.
Look at the file `package.sh` (You can `cat /usr/bin/package.sh` from within
the session) for the commands the container would execute.

# [NSIS (Nullsoft Scriptable Install System)]

If your project contains a .nis (stored in the root dir) the `package.sh` script
builds an NSIS installer as well.


[erste idee]: https://github.com/LeoTindall/rust-mingw64-gtk-docker
[zweite idee]: https://github.com/etrombly/rust-crosscompile
[NSIS (Nullsoft Scriptable Install System)]: https://nsis.sourceforge.io/Main_Page
[docker containers as current user]: https://github.com/jtreminio/jtreminio.com/issues/14
[that file]: package.sh
