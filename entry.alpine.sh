#!/usr/bin/env bash

set +x

# start basic service
syslogd
crond

# start ats
DISTRIB_ID=gentoo /usr/local/bin/trafficserver start

/bin/bash
