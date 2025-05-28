FROM ubuntu:latest AS builder

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
    
WORKDIR /app

COPY . .

RUN chmod +x ./configure && \
    ./configure --without-readline && \
    make world-bin && \
    make install

# Stage 2 
FROM ubuntu:latest AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libicu-dev \
    perl \
    tcl \
    libkrb5-3 \
    zlib1g \
    libssl3 \
    libxml2 \
    libxslt1.1 \
    locales \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/postgres postgres

COPY --from=builder /usr/local /usr/local

# Создаем директорию для базы данных
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql

USER postgres

RUN initdb -D $PGDATA

EXPOSE 5432

CMD ["/usr/local/bin/postgres"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=5 \
  CMD pg_isready -U postgres || exit 1