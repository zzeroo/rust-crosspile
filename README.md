# rust-crosspile

Docker Container to cross compile and pack rust binaries for Windows 32/ 64Bit.

This project has strong gkt+3 support.

## Usage:
First you have to build the container, from within this repo dir.

```bash
docker build . -t rust-crosspile
```

Now build a image **in your source directory!**. Your sources are mounted as a docker VOLUME
```bash
# cd /path/to/your/src
docker create -v `pwd`:/home/rust/src --name PROJECT-build rust-crosspile:latest
```

From now on everytime you want conpile and pack the latest version call `docker start`

```bash
docker start -ai PROJECT-build
```

### Cleanup
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
