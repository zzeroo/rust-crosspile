FROM fedora:32
WORKDIR /app
# https://github.com/gsauthof/pe-util
RUN dnf install -y \
    git \
    clang \
    gcc \
    make \
    cmake \
    gcc-c++ \
    boost-devel

RUN git clone https://github.com/gsauthof/pe-util.git \
    && cd pe-util \
    && git submodule update --init \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make VERBOSE=1

RUN cp /app/pe-util/build/peldd /usr/bin/

RUN dnf install -y \
  mingw64-gcc \
  mingw64-freetype \
  mingw64-cairo \
  mingw64-harfbuzz \
  mingw64-pango \
  mingw64-poppler \
  mingw64-gtk3 \
  mingw64-winpthreads-static \
  mingw64-glib2-static \
  mingw32-gcc \
  mingw32-freetype \
  mingw32-cairo \
  mingw32-harfbuzz \
  mingw32-pango \
  mingw32-poppler \
  mingw32-gtk3 \
  mingw32-winpthreads-static \
  mingw32-glib2-static \
  zip \
  && dnf clean all -y

RUN useradd -ms /bin/bash rust

ADD package.sh /usr/bin/package.sh
RUN chmod 755 /usr/bin/package.sh

# User tasks
USER rust

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=stable --profile=minimal

RUN . ~/.cargo/env && \
    rustup target add i686-pc-windows-gnu && \
    rustup target add x86_64-pc-windows-gnu

ADD cargo.config /home/rust/.cargo/config

VOLUME /home/rust/src
WORKDIR /home/rust/src

# This calls the final job
## Create a package.sh in your project folder overrides the one in /usr/bin/ (don't forget `chmod +x packages.sh`)
CMD ["package.sh"]

# ## Usage:
# First you have to build the container, from within this repo dir.
#
# ```bash
# docker build . -t rust-crosspile
# ```
#
# Now build a image **in your source directory!**. Your sources are mounted as a docker VOLUME
# ```bash
# # cd /path/to/your/src
# docker create -v `pwd`:/home/rust/src --name PROJECT-build rust-crosspile:latest
# ```
#
# From now on everytime you want conpile and pack the latest version call `docker start`
#
# ```bash
# docker start -ai PROJECT-build
# ```
#
# ### Cleanup
# ```bash
# docker rm PROJECT-build
# ```
