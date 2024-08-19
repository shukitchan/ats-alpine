Docker Image for Apache Traffic Server (ATS) 9.2.5 on alpine 3.20.2
====
 - http://trafficserver.apache.org/

Instructions to Manually Build the Dev Image
====
 - `git clone https://github.com/shukitchan/ats-alpine.git`
 - `cd ats-alpine`
 - `docker build -f Dockerfile --target builder -t ats-alpine-devel .`
 - `docker run -it ats-alpine-devel`

Instructions to Manually Build the Image
====
 - `git clone https://github.com/shukitchan/ats-alpine.git`
 - `cd ats-alpine`
 - `docker build -f Dockerfile -t ats-alpine .`
 - `docker run -it ats-alpine`

Instructions to use the Dev Image
====
 - `docker pull ghcr.io/shukitchan/ats-alpine-devel:latest`
 - `docker run -it ghcr.io/shukitchan/ats-alpine-devel`

Instructions to use the Image
====
 - `docker pull ghcr.io/shukitchan/ats-alpine:latest`
 - `docker run -it ghcr.io/shukitchan/ats-alpine`

Stop/Start/Restart ATS
====
 - To stop, `DISTRIB_ID=gentoo /opt/ats/bin/trafficserver stop`
 - To start, `DISTRIB_ID=gentoo /opt/ats/bin/trafficserver start`
 - To restart, `DISTRIB_ID=gentoo /opt/ats/bin/trafficserver restart`
