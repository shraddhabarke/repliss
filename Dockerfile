FROM ubuntu:xenial
MAINTAINER Peter Zeller

ENV WHY3_VER 0.87.3
ENV WHY3_DL https://gforge.inria.fr/frs/download.php/file/36398/why3-0.87.3.tar.gz

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ENV Z3_VERSION "4.5.0"
RUN apt-get update -y \
  && apt-get install -y wget unzip libgomp1 \
  && mkdir /opt/z3 && cd /opt/z3 \
  && wget -q https://github.com/Z3Prover/z3/releases/download/z3-${Z3_VERSION}/z3-${Z3_VERSION}-x64-ubuntu-14.04.zip \
  && unzip z3-${Z3_VERSION}-x64-ubuntu-14.04.zip \
  && ln -s /opt/z3/z3-${Z3_VERSION}-x64-ubuntu-14.04/bin/z3 /usr/bin/z3 \
  # clean
  && rm -rf z3-${Z3_VERSION}-x64-ubuntu-14.04.zip \
  && apt-get autoremove -y wget unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


## download, compile and install z3
#RUN apt-get update -y \
# && apt-get install -y binutils g++ make wget
# && mkdir /opt/z3 && cd /opt/z3 \
# && wget -qO- https://github.com/Z3Prover/z3/archive/z3-${Z3_VERSION}.tar.gz | tar xz --strip-components=1 \
# && python scripts/mk_make.py \
# && cd build \
# && make \
# && make install
# # clean build-dependencies
# && apt-get autoremove -y \
# &&     binutils \
# &&     g++ \
# &&     make \
# &&     wget \
# && apt-get clean && \
# && rm -rf /var/lib/apt/lists/*


# Install why3
RUN apt-get update -y \
    #&& apt-get upgrade -y \
    && apt-get install -y \
        gcc \
        make \
        git \
        curl \
        ocaml \
        pkg-config \
        libgmp10 \
        libgmp-dev \
        libgtksourceview2.0 \
        libgtksourceview2.0-dev \
        menhir \
        libzip-ocaml \
        libzip-ocaml-dev \
        liblablgtksourceview2-ocaml \
        liblablgtksourceview2-ocaml-dev \
# install why3
    && cd /tmp && curl -L $WHY3_DL | tar zx \
    && cd /tmp/why3-$WHY3_VER \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && rm -rf /tmp/why3-$WHY3_VER \
# cleanup installed packages
    && apt-get autoremove -y \
         m4 \
         libc6-dev \
         make \
         libgmp-dev \
         manpages-dev \
         gcc \
         make \
         git \
         curl \
         pkg-config \
         libgtksourceview2.0-dev \
         dbus \
         libzip-ocaml-dev \
         liblablgtksourceview2-ocaml-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# let why3 find provers
RUN why3 config --detect-provers

# copy repliss jar
ADD target/scala-2.11/repliss-assembly-0.1.jar  /opt/repliss/repliss.jar


VOLUME ["/opt/repliss/model/"]

# start repliss
ENV HOST 0.0.0.0
ENV PORT 8080
EXPOSE $PORT
WORKDIR /opt/repliss/
CMD java -jar repliss.jar --server --host $HOST --port $PORT



