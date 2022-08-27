FROM alpine:3 AS build
RUN apk update && \
    apk add --no-cache \
    ca-certificates \
    g++ \
    make \
    git

# Build WOFF2 generator
RUN mkdir -p /build && \
    cd /build && \
    git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/google/woff2.git && \
    cd woff2 && \
    make clean all

# Build mkbold-mkitalic
RUN cd /build && \
    wget --no-verbose \
        http://hp.vector.co.jp/authors/VA013651/lib/mkbold-mkitalic-0.11.tar.bz2 \
    && tar xjf mkbold-mkitalic-0.11.tar.bz2 \
    && cd mkbold-mkitalic-0.11/ \
    && make

FROM alpine:3
MAINTAINER Andy Walker <andy@andy.dev>
RUN apk update && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    ca-certificates \
    openjdk8-jre \
    go \
    fontforge \
    potrace \
    font-util \
    bdftopcf \
    py-pip \
    make && \
    pip install --no-cache-dir bdflib

ADD https://github.com/kreativekorp/bitsnpicas/raw/master/downloads/BitsNPicas.jar /fonttools/
ADD https://raw.githubusercontent.com/Lokaltog/vim-powerline/develop/fontpatcher/fontpatcher /fonttools/
ADD https://raw.githubusercontent.com/Lokaltog/vim-powerline/develop/fontpatcher/PowerlineSymbols.sfd /fonttools/
COPY --from=build /build/mkbold-mkitalic-0.11/mkbold /build/mkbold-mkitalic-0.11/mkitalic /build/mkbold-mkitalic-0.11/mkbolditalic /fonttools
COPY --from=build /build/woff2/woff2_compress /fonttools
ENV PATH="$PATH:/fonttools"
