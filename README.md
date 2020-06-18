Docker Container to cross compile and pack rust binaries for Windows 32/ 64Bit.

This project has strong gkt+3 support.

[![GitLab CI status](https://gitlab.com/zzeroo/rust-crosspile/badges/master/pipeline.svg)](https://gitlab.com/zzeroo/rust-crosspile/pipelines)

![Rust Crosspile Logo](resources/Docker_Rust.svg)

# Usage:
First you have to build the container, from within **this** repo directory.

The following example builds a container `rust-crosspile` named.
I use the same name for all my buils systems.

**The container only has to be created once!**

```bash
docker image build \
  --build-arg USER_ID=$(id -u ${USER}) \
  --build-arg GROUP_ID=$(id -g ${USER}) \
  -t rust-crosspile \
  .
```

Now build a image **in your source directory!**.
Your sources are mounted as a docker VOLUME.

The following example uses `PROJECT-build` as image name.

**You have to create an image for each of your projects!**

```bash
# cd /path/to/your/project
docker create -v `pwd`:/home/rust/src --name PROJECT-build rust-crosspile:latest
```

From now on everytime you want compile and pack the latest version
just call `docker start IMAGE_NAME`. Replace **IMAGE_NAME** with the name of the
correct image for that project.

```bash
docker start -ai PROJECT-build
```

## Cleanup
```bash
docker rm PROJECT-build
```

# Complete Usage Example

```bash
cd /tmp
git clone https://gitlab.com/zzeroo/rust-crosspile -b development
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


[erste idee]: https://github.com/LeoTindall/rust-mingw64-gtk-docker
[zweite idee]: https://github.com/etrombly/rust-crosscompile
