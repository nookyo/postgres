FROM ubuntu:latest AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    flex \
    bison \
    libicu-dev \
    libperl-dev \
    tcl \
    krb5-multidev \
    ca-certificates \
    pkg-config \
    zlib1g-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

WORKDIR /app

RUN chmod +x ./configure && \
    ./configure --without-readline && \
    make world-bin && \
    make install
