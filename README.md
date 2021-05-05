Docker Image for Apache Traffic Server (ATS) 9.0.1 on alpine 3.12.7
====
 - http://trafficserver.apache.org/

Instructions to Manually Build the Image
====
 - git clone https://github.com/shukitchan/ats-alpine.git
 - cd ats-alpine
 - docker build -f Dockerfile -t ats_alpine .
 - docker run -it ats_alpine
