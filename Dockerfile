# Ubuntu 16.04
FROM jordi/openssl
LABEL Description="In order to create custom Tezos image."
LABEL maintainer="shogo.ochiai@protonmail.com>"
LABEL build_date="2019-11-22"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y install --no-install-suggests --no-install-recommends git
RUN apt-get -y install --no-install-suggests --no-install-recommends make
RUN apt-get -y install --no-install-suggests --no-install-recommends curl
RUN apt-get -y install --no-install-suggests --no-install-recommends wget
RUN apt-get -y install --no-install-suggests --no-install-recommends patch
RUN apt-get -y install --no-install-suggests --no-install-recommends unzip
RUN apt-get -y install --no-install-suggests --no-install-recommends bubblewrap
RUN apt-get -y install --no-install-suggests --no-install-recommends m4
RUN apt-get -y install --no-install-suggests --no-install-recommends gcc
RUN apt-get -y install --no-install-suggests --no-install-recommends g++
RUN apt-get -y install --no-install-suggests --no-install-recommends build-essential

COPY cacert.pem /etc/ssl/certs/ca-certificates.crt
WORKDIR /usr/local

COPY opam-2.0.0-x86_64-linux /usr/local/bin/opam
COPY tz1UnFzTB3KjSXo27WfyzzpAw33jqjAdohvR.json /usr/local/faucet.json
RUN opam init --disable-sandboxing --compiler=4.07.1
RUN eval $(opam env)
RUN opam install dune

COPY ./tezos ./tezos
WORKDIR /usr/local/tezos
RUN useradd tezos
RUN make build-deps
WORKDIR /usr/local
RUN rm -rf tezos
