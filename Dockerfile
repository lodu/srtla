# Build stage
FROM alpine:latest AS build

RUN apk update && \
    apk upgrade && \
    apk add --no-cache linux-headers alpine-sdk cmake tcl openssl-dev zlib-dev spdlog-dev git

WORKDIR /tmp

COPY . /tmp/srtla

WORKDIR /tmp/srtla

RUN git submodule update --init
RUN cmake . && \
    make -j$(nproc)

FROM alpine:latest AS production

RUN apk add --no-cache openssl zlib spdlog

COPY --from=build /tmp/srtla/srtla_rec /usr/local/bin/srtla_rec

ENTRYPOINT ["/usr/local/bin/srtla_rec"]
