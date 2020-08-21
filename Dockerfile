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
  mingw32-cairo \
  mingw32-freetype \
  mingw32-gcc \
  mingw32-glib2-static \
  mingw32-gtk3 \
  mingw32-harfbuzz \
  mingw32-nsiswrapper \
  mingw32-pango \
  mingw32-poppler \
  mingw32-winpthreads-static \
  mingw64-cairo \
  mingw64-freetype \
  mingw64-gcc \
  mingw64-glib2-static \
  mingw64-gtk3 \
  mingw64-harfbuzz \
  mingw64-pango \
  mingw64-poppler \
  mingw64-winpthreads-static \
  wine \
  zip \
  && dnf clean all -y \
  && rm -rf /var/cache/yum

# User tasks
ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    groupadd -g ${GROUP_ID} rust &&\
    useradd -l -u ${USER_ID} -g rust rust &&\
    install -d -m 0755 -o rust -g rust /home/rust \
;fi

RUN rm -rf /app

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

ADD --chown=rust:rust package.sh /usr/bin/package.sh
RUN chmod 755 /usr/bin/package.sh

ENV PATH /home/rust/src:$PATH

# This calls the final job
CMD ["package.sh"]
