FROM alpine:3.12.4 as builder

RUN apk add --no-cache --virtual .tools \
  bzip2 curl git automake libtool autoconf make \
  sed file perl openrc openssl

# ATS
RUN apk add --no-cache --virtual .ats-build-deps \
  build-base openssl-dev tcl-dev pcre-dev zlib-dev \
  libexecinfo-dev linux-headers libunwind-dev \
  brotli-dev jansson-dev luajit-dev readline-dev \
  geoip-dev

RUN apk add --no-cache --virtual .ats-extra-build-deps --repository https://dl-cdn.alpinelinux.org/alpine/edge/community hwloc-dev

# create ats user/group
RUN addgroup -Sg 101 ats

RUN adduser -S -D -H -u 101 -h /tmp -s /sbin/nologin -G ats -g ats ats

# download and build ATS
RUN curl -L https://downloads.apache.org/trafficserver/trafficserver-9.0.0.tar.bz2 | bzip2 -dc | tar xf - \
  && cd trafficserver-9.0.0/ \
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

FROM alpine:3.12.4

# essential library
RUN apk add -U \
  bash build-base curl ca-certificates pcre \
  zlib openssl brotli jansson luajit libunwind \
  readline geoip libexecinfo tcl openrc

RUN apk add -U --repository https://dl-cdn.alpinelinux.org/alpine/edge/community hwloc

# create ats user/group
RUN addgroup -Sg 101 ats

RUN adduser -S -D -H -u 101 -h /tmp -s /sbin/nologin -G ats -g ats ats

COPY --from=builder --chown=ats:ats /opt/ats /opt/ats

USER ats

ENTRYPOINT ["/opt/ats/bin/entry.sh"] 
