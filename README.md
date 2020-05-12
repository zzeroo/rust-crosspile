# rust-crosspile

Docker Container to cross compile and pack rust binaries for Windows.
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

# Complete Usage Examples
## i686
```bash
git clone https://gitlab.com/zzeroo/rust-crosspile -b i686
cd rust-crosspile
docker build . -t rust-crosspile

cd /tmp
cargo build --bin hello-world
cd example
docker create -v `pwd`:/home/rust/src --name HELLO-build rust-crosspile:latest
docker start -ai HELLO-build
```


[erste idee]: https://github.com/LeoTindall/rust-mingw64-gtk-docker
[zweite idee]: https://github.com/etrombly/rust-crosscompile
