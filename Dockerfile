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

COPY . .

WORKDIR /src

RUN chmod +x ./configure && \
    ./configure --without-readline && \
    make world-bin && \
    make install

# Stage 2 
# FROM ubuntu:latest

# ENV DEBIAN_FRONTEND=noninteractive
# ENV PATH="/usr/local/bin:$PATH"
# ENV PGDATA="/var/lib/postgresql/data"

# RUN apt-get update && apt-get install -y \
#     libicu74 \
#     libperl5.38 \
#     tcl \
#     krb5-user \
#     && rm -rf /var/lib/apt/lists/*

# COPY --from=builder /build/usr/local /usr/local

# VOLUME /var/lib/postgresql/data

# EXPOSE 5432

# HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=3 \
#   CMD pg_isready -U postgres || exit 1

# CMD if [ ! -s "$PGDATA/PG_VERSION" ]; then \
#       initdb -D "$PGDATA"; \
#     fi && \
#     exec postgres -D "$PGDATA"    