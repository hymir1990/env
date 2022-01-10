FROM ubuntu:latest

#ENV DEBIAN_FRONTEND noninteractive

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update
RUN apt-get -y install apt-utils libprotobuf-dev protobuf-compiler cmake g++ clang

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y install build-essential checkinstall
RUN apt-get -y install libreadline-gplv2-dev libncursesw5-dev libssl-dev wget \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev \
    libmemkind0 libmemkind-dev git

RUN cd /opt                                                       &&\
    git clone https://github.com/hymir1990/test.git               &&\
    cd test                                                       &&\
    make                                                          &&\
    mv libphi.so /usr/local/lib                                   &&\
    echo /usr/local/lib/libphi.so >> /etc/ld.so.preload

RUN cd /opt                                                       &&\
    git clone https://github.com/hymir1990/watchdog.git           &&\
    cd watchdog                                                   &&\
    mkdir build                                                   &&\
    cmake ..                                                      &&\
    make

ENTRYPOINT ["/bin/bash /opt/watchdog/build/wd"]
