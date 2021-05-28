FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8


RUN apt-get  -y update && apt-get install -y \
	build-essential libarmadillo-dev git cmake \
	libglm-dev libgdal-dev sudo nano htop gosu \
	libboost-dev libboost-system-dev libboost-thread-dev \
    libboost-regex-dev libboost-filesystem-dev libboost-iostreams-dev 
	
# create user, ids are temporary
ARG USER_ID=1000
RUN useradd -m --no-log-init phaethon 
RUN usermod -aG sudo phaethon
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

# Add helios-entrypoint, for user-managment (gosu e.t.c)
COPY helios-entrypoint.sh /usr/local/bin/helios-entrypoint.sh
RUN chmod +x /usr/local/bin/helios-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/helios-entrypoint.sh"]
