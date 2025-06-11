FROM alpine:latest AS build

RUN apk update && \
    apk upgrade && \
    apk add --no-cache linux-headers alpine-sdk cmake tcl openssl-dev zlib-dev spdlog-dev git


RUN git clone https://github.com/IRLServer/srt.git /tmp/srt; \
    cd /tmp/srt; \
    git checkout belabox-dev; \
    ./configure; \
    make -j${nproc}; \
    make install;


COPY . /tmp/srtla

WORKDIR /tmp/srtla



RUN git submodule update --init
RUN cmake . && \
    make -j$(nproc)


FROM alpine:latest AS production

RUN apk add --no-cache openssl zlib spdlog


COPY --from=build /tmp/srtla/srtla_rec /usr/local/bin/srtla_rec
COPY --from=build /tmp/srt/srtcore/srt_compat.h /usr/local/include/srt/

ENTRYPOINT ["/usr/local/bin/srtla_rec"]
