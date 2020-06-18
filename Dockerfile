FROM fedora:33
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

# User tasks
ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    groupadd -g ${GROUP_ID} rust &&\
    useradd -l -u ${USER_ID} -g rust rust &&\
    install -d -m 0755 -o rust -g rust /home/rust \
;fi

USER rust
WORKDIR /home/rust/

RUN id &&\
    ls -alt

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=stable --profile=minimal

RUN . ~/.cargo/env && \
    rustup target add i686-pc-windows-gnu && \
    rustup target add x86_64-pc-windows-gnu

VOLUME /home/rust/src
WORKDIR /home/rust/src

ADD --chown=rust:rust package.sh /home/rust/package.sh
RUN chmod 755 /home/rust/package.sh

# This calls the final job
CMD ["/home/rust/package.sh"]

# # Usage:
# First you have to build the container, from within **this** repo directory.
#
# The following example builds a container `rust-crosspile` named.
# I use the same name for all my buils systems.
#
# **The container only has to be created once!**
#
# ```bash
# docker image build \
#   --build-arg USER_ID=$(id -u ${USER}) \
#   --build-arg GROUP_ID=$(id -g ${USER}) \
#   -t rust-crosspile \
#   .
# ```
#
# Now build a image **in your source directory!**.
# Your sources are mounted as a docker VOLUME.
#
# The following example uses `PROJECT-build` as image name.
#
# **You have to create an image for each of your projects!**
#
# ```bash
# # cd /path/to/your/project
# docker create -v `pwd`:/home/rust/src --name PROJECT-build rust-crosspile:latest
# ```
#
# From now on everytime you want compile and pack the latest version
# just call `docker start IMAGE_NAME`. Replace **IMAGE_NAME** with the name of the
# correct image for that project.
#
# ```bash
# docker start -ai PROJECT-build
# ```
#
# ## Cleanup
# ```bash
# docker rm PROJECT-build
# ```
