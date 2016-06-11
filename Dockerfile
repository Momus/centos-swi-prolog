
#Version 0.0.1
FROM centos
MAINTAINER Dmitri Brengauz "dmitri@momus.net"
LABEL "rating"="One Star" 
USER root
RUN [ "yum" ,  "install -y git" ]
