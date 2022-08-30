FROM alpine:3 AS build
RUN apk add --update --no-cache \
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

RUN apk add --update --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    ca-certificates \
    git \
    openjdk8-jre \
    fontforge \
    imagemagick \
    potrace \
    font-util \
    bdftopcf \
    zip \
    py-pip \
    make && \
    pip install --no-cache-dir bdflib

# Install MS fonts for common usage and so Imagemagick doesn't crap itself
RUN apk add --update --no-cache --virtual .ms-fonts msttcorefonts-installer && \
    update-ms-fonts 2>/dev/null && \
    fc-cache -f && \
    apk del .ms-fonts

ADD https://github.com/kreativekorp/bitsnpicas/raw/master/downloads/BitsNPicas.jar /fonttools/
ADD https://raw.githubusercontent.com/Lokaltog/vim-powerline/develop/fontpatcher/fontpatcher /fonttools/
ADD https://raw.githubusercontent.com/Lokaltog/vim-powerline/develop/fontpatcher/PowerlineSymbols.sfd /fonttools/
COPY --from=build /build/mkbold-mkitalic-0.11/mkbold /build/mkbold-mkitalic-0.11/mkitalic /build/mkbold-mkitalic-0.11/mkbolditalic /fonttools
COPY --from=build /build/woff2/woff2_compress /fonttools
ENV PATH="$PATH:/fonttools"
WORKDIR /build
