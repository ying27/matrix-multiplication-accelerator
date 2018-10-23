FROM debian:stretch

WORKDIR /tmp
RUN apt-get -y update
RUN apt-get -y install apt-utils
RUN apt-get -y install zlib1g-dev bash build-essential git make autoconf perl gcc g++ flex bison   # First time prerequisites
RUN git clone http://git.veripool.org/git/verilator   # Only first time

# Each build:
RUN unset VERILATOR_ROOT  # For bash
WORKDIR /tmp/verilator
RUN git pull        # Make sure we're up-to-date
RUN git tag         # See what versions exist
#git checkout master      # Use development branch (e.g. recent bug fix)
RUN git checkout stable      # Use most recent release
#git checkout v{version}  # Switch to specified release version
RUN autoconf        # Create ./configure script
RUN ./configure
RUN make -j $(nproc)
RUN make install -j $(nproc)
WORKDIR /tmp
RUN rm -rf verilator 
#ENV VERILATOR_ROOT /usr/local/share/verilator
RUN apt-get -y install gtkwave
ENV PATH /usr/local/bin:$PATH 
ENV SHELL /bin/bash
