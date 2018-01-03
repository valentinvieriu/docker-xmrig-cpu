###
# Build image
###
FROM alpine:edge AS build

ENV XMRIG_VERSION v2.4.3

WORKDIR /usr/local/src

RUN apk add --no-cache \
      libuv-dev \
      libmicrohttpd-dev \
      build-base \
      cmake \
      git

RUN git clone --depth 1 https://github.com/xmrig/xmrig \
    && cd xmrig \
    && git checkout -b ${XMRIG_VERSION} \
    && sed -i 's/constexpr const int kDonateLevel.*/constexpr const int kDonateLevel = 0;/' src/donate.h \
    \
    && cmake -DCMAKE_BUILD_TYPE=Release . \
    && make -j$(nproc)

###
# Deployed image
###
FROM alpine:edge

WORKDIR /app

RUN apk add --no-cache \
      libuv \
      libmicrohttpd \
      curl 

COPY --from=build /usr/local/src/xmrig/xmrig .

ENTRYPOINT ["/app/xmrig"]

