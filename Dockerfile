
FROM ubuntu:22.04 AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential \
      flex \
      bison \
      libicu-dev \
      libperl-dev \
      tcl \
      krb5-multidev \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/postgresql
COPY . .

RUN chmod +x configure && \
    echo "::group::Configure" && \
    ./configure --without-readline --prefix=/usr/local && \
    echo "::endgroup::" && \
    echo "::group::Make world-bin" && \
    make world-bin && \
    echo "::endgroup::" && \
    echo "::group::Install" && \
    make install DESTDIR=/install && \
    echo "::endgroup::"

FROM ubuntu:22.04
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      libicu70 \
      libperl5.36 \
      tcl8.6 \
      krb5-locales \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /install/usr/local /usr/local

RUN useradd --system --home /var/lib/postgresql --shell /bin/bash postgres && \
    mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql

USER postgres

ENV PATH="/usr/local/bin:${PATH}" \
    PGDATA="/var/lib/postgresql/data"

EXPOSE 5432

ENTRYPOINT ["bash", "-c"]
CMD ["if [ -z \"$(ls -A \\\"$PGDATA\\\")\" ]; then initdb; fi && exec postgres"]
