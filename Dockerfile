FROM ubuntu

RUN apt update
RUN apt install -y build-essential git autoconf libtool libgmp-dev libreadline-dev zlib1g-dev wget

RUN mkdir /home/inst/ \
    && cd /home/inst/ \
    && git clone https://github.com/rbehrends/unward.git unward \
    && cd unward \
    && ./configure && make

RUN cd /home/inst/ \
    && git clone https://github.com/gap-system/gap hpcgap \
    && cd hpcgap \
    && ./autogen.sh \
    && ./configure --enable-hpcgap \
    && /home/inst/unward/bin/unward --inplace src \
    && make \
    && make bootstrap-pkg-full

RUN echo 'alias hpcgap="/home/inst/hpcgap/gap"' >> ~/.bashrc