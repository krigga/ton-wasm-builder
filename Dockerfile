FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

RUN apt update
RUN apt upgrade -y
RUN apt install -y build-essential git make cmake ninja-build clang libgflags-dev zlib1g-dev libssl-dev \
                    libreadline-dev libmicrohttpd-dev pkg-config libgsl-dev python3 python3-dev python3-pip \
                    nodejs libsodium-dev automake libtool libjemalloc-dev liblz4-dev ccache

WORKDIR /libs

RUN git clone --branch openssl-3.1.4 --depth 1 https://github.com/openssl/openssl
WORKDIR /libs/openssl
RUN ./config
RUN make build_libs -j$(nproc)
ENV regularOpensslPath=/libs/openssl

WORKDIR /libs

RUN git clone --depth 1 https://github.com/emscripten-core/emsdk.git
WORKDIR /libs/emsdk
RUN ./emsdk install 4.0.9
RUN ./emsdk activate 4.0.9
ENV EMSDK_DIR=/libs/emsdk

WORKDIR /libs

RUN git clone --branch openssl-3.1.4 --depth 1 https://github.com/openssl/openssl openssl_em
WORKDIR /libs/openssl_em
RUN source $EMSDK_DIR/emsdk_env.sh && emconfigure ./Configure linux-generic32 no-shared no-dso no-engine no-unit-test no-tests no-fuzz-afl no-fuzz-libfuzzer
RUN sed -i 's/CROSS_COMPILE=.*/CROSS_COMPILE=/g' Makefile
RUN sed -i 's/-ldl//g' Makefile
RUN sed -i 's/-O3/-Os/g' Makefile
RUN source $EMSDK_DIR/emsdk_env.sh && emmake make depend
RUN source $EMSDK_DIR/emsdk_env.sh && emmake make -j$(nproc)
ENV opensslPath=/libs/openssl_em

WORKDIR /libs

RUN git clone --branch v1.3.1 --depth 1 https://github.com/madler/zlib.git
WORKDIR /libs/zlib
RUN source $EMSDK_DIR/emsdk_env.sh && emconfigure ./configure --static
RUN source $EMSDK_DIR/emsdk_env.sh && emmake make -j$(nproc)
ENV ZLIB_DIR=/libs/zlib

WORKDIR /libs

RUN git clone --branch v1.9.4 --depth 1 https://github.com/lz4/lz4.git
WORKDIR /libs/lz4
RUN source $EMSDK_DIR/emsdk_env.sh && emmake make -j$(nproc)
ENV LZ4_DIR=/libs/lz4

WORKDIR /libs

RUN git clone --branch 1.0.18-RELEASE --depth 1 https://github.com/jedisct1/libsodium
WORKDIR /libs/libsodium
RUN source $EMSDK_DIR/emsdk_env.sh && emconfigure ./configure --disable-ssp
RUN source $EMSDK_DIR/emsdk_env.sh && emmake make -j$(nproc)
ENV SODIUM_DIR=/libs/libsodium

WORKDIR /workspace

COPY build-smc-envelope.sh .
COPY configure-wasm-build.sh .