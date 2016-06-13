
#Version 0.0.1
FROM centos
MAINTAINER Dmitri Brengauz <dmitri@momus.net>
LABEL "rating"="One Star" 
USER root
ENV SRC_PATH "/swipl/"

#Install git and dependencies to build Prolog; grab the source from Github
RUN yum update -y \
    &&  yum groupinstall -y "Development Tools" \
    && yum install -y \
           git \
           autoconf \
           chrpath \
           libunwind \
           freetype-devel \
           gmp-devel \
           java-1.8.0-openjdk-devel \
           jpackage-utils \
           libICE-devel \
           libjpeg-devel \
           libSM-devel \
           libX11-devel \
           libXaw-devel \
           libXext-devel \
           libXft-devel \
           libXinerama-devel \
           libXmu-devel \
           libXpm-devel \
           libXrender-devel \
           libXt-devel \
           ncurses-devel \
           openssl-devel \
           pkgconfig \
           readline-devel \
           unixODBC-devel \
           zlib-devel \
           uuid-devel \
           libarchive-devel \
    &&  git clone  https://github.com/SWI-Prolog/swipl.git

ADD ./build.sh /swipl/build.sh

#Build Prolog
RUN cd swipl ; ./prepare --yes --all ; chmod +x build.sh ; ./build.sh

CMD ["bash"]
