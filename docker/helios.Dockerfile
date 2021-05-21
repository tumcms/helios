FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8


RUN apt-get  -y update && apt-get install -y \
	build-essential libarmadillo-dev git cmake \
	libglm-dev libgdal-dev 

#RUN echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/backports.list

RUN apt-get  -y update && apt-get install -y \
libboost-dev libboost-system-dev libboost-thread-dev \
libboost-regex-dev libboost-filesystem-dev libboost-iostreams-dev 
#libboost1.71-all-dev/buster-backports 



# create user
ARG USER_ID=1000
RUN useradd -m --no-log-init --system  --uid   ${USER_ID} phaethon -g sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# clone Helios++
WORKDIR /home/phaethon
RUN git clone https://github.com/3dgeo-heidelberg/helios.git helios++

# clone & build LAStools
WORKDIR /home/phaethon/helios++
RUN git clone https://github.com/LAStools/LAStools.git lib/LAStools
RUN mkdir lib/LAStools/_build && cd lib/LAStools/_build && cmake .. && make -j $(nproc)

# build helios ++
RUN mkdir _build && cd _build && cmake .. && make -j $(nproc)

RUN chown -R phaethon:sudo "/home/phaethon/helios++"
RUN chmod -R a=r,a+X,u+w "/home/phaethon/helios++"
RUN chmod 755 "/home/phaethon/helios++/_build/helios"

#RUN echo "PATH=$PATH:/home/phaethon/helios++/_build" >> /home/phaethon/.profile
ENV PATH "$PATH:/home/phaethon/helios++/_build"

WORKDIR /home/phaethon/

ENTRYPOINT /bin/bash
