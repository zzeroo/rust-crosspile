FROM fedora:latest AS builder
WORKDIR /app
# https://github.com/gsauthof/pe-util
RUN dnf install -y \
    git \
    clang \
    gcc \
    make \
    cmake \
    gcc-c++ boost-devel  \
   && yum clean all

RUN git clone https://github.com/gsauthof/pe-util.git \
    && cd pe-util \
    && git submodule update --init \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make VERBOSE=1

CMD ["ls", "-al"]
