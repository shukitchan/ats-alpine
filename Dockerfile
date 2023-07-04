FROM --platform=linux/amd64 alpine:3.16.6 as builder-amd64

FROM --platform=linux/arm64 arm64v8/alpine:3.16.6 as builder-arm64

ARG TARGETARCH

FROM builder-${TARGETARCH} as builder

RUN apk add --no-cache --virtual .tools \
  bzip2 curl=8.0.1-r0 git automake libtool autoconf make \
  sed file perl openrc openssl

# ATS
RUN apk add --no-cache --virtual .ats-build-deps \
  build-base openssl-dev tcl-dev pcre-dev zlib-dev \
  libexecinfo-dev linux-headers libunwind-dev \
  brotli-dev jansson-dev luajit-dev readline-dev \
  geoip-dev libxml2-dev

RUN apk add --no-cache --virtual .ats-extra-build-deps --repository https://dl-cdn.alpinelinux.org/alpine/edge/community hwloc-dev

# create ats user/group
RUN addgroup -Sg 1000 ats

RUN adduser -S -D -H -u 1000 -h /tmp -s /sbin/nologin -G ats -g ats ats

# download and build ATS
# patch 2 files due to pthread in musl vs glibc - see https://github.com/apache/trafficserver/pull/7611/files
RUN curl -L https://downloads.apache.org/trafficserver/trafficserver-9.2.1.tar.bz2 | bzip2 -dc | tar xf - \
  && cd trafficserver-9.2.1/ \
  && sed -i "s/PTHREAD_RWLOCK_WRITER_NONRECURSIVE_INITIALIZER_NP/PTHREAD_RWLOCK_INITIALIZER/" include/tscore/ink_rwlock.h \
  && sed -i "s/PTHREAD_RWLOCK_WRITER_NONRECURSIVE_INITIALIZER_NP/PTHREAD_RWLOCK_INITIALIZER/" include/tscpp/util/TsSharedMutex.h \
  && autoreconf -if \
  && ./configure --enable-debug=yes --prefix=/opt/ats --with-user=ats \
  && make \
  && make install

# enable traffic.out for alpine/gentoo
RUN sed -i "s/TM_DAEMON_ARGS=\"\"/TM_DAEMON_ARGS=\" --bind_stdout \/opt\/ats\/var\/log\/trafficserver\/traffic.out --bind_stderr \/opt\/ats\/var\/log\/trafficserver\/traffic.out \"/" /opt/ats/bin/trafficserver
RUN sed -i "s/TS_DAEMON_ARGS=\"\"/TS_DAEMON_ARGS=\" --bind_stdout \/opt\/ats\/var\/log\/trafficserver\/traffic.out --bind_stderr \/opt\/ats\/var\/log\/trafficserver\/traffic.out \"/" /opt/ats/bin/trafficserver

# entry.sh
COPY ["./entry.alpine.sh", "/opt/ats/bin/entry.sh"]
WORKDIR /opt/ats/bin/
RUN chmod 755 entry.sh

ENTRYPOINT ["/opt/ats/bin/entry.sh"]

FROM --platform=linux/amd64 alpine:3.16.6 as worker-amd64

FROM --platform=linux/arm64 arm64v8/alpine:3.16.6 as worker-arm64

FROM worker-${TARGETARCH} as worker

# essential library
RUN apk add --no-cache -U \
  bash build-base curl=8.0.1-r0 ca-certificates pcre \
  zlib openssl brotli jansson luajit libunwind \
  readline geoip libexecinfo tcl openrc libxml2

RUN apk add --no-cache -U --repository https://dl-cdn.alpinelinux.org/alpine/edge/community hwloc

# create ats user/group
RUN addgroup -Sg 1000 ats

RUN adduser -S -D -H -u 1000 -h /tmp -s /sbin/nologin -G ats -g ats ats

COPY --from=builder --chown=ats:ats /opt/ats /opt/ats

USER ats

ENTRYPOINT ["/opt/ats/bin/entry.sh"] 
