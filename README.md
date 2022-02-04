Docker Image for Apache Traffic Server (ATS) 9.1.1 on alpine 3.14.3
====
 - http://trafficserver.apache.org/

Instructions to Manually Build the Image
====
 - git clone https://github.com/shukitchan/ats-alpine.git
 - cd ats-alpine
 - docker build -f Dockerfile -t ats-alpine .
 - docker run -it ats-alpine
