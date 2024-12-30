FROM rust:1-slim-bookworm AS builder

ARG VERSION

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    clang \
    cmake \
    build-essential \
    libsnappy-dev \
    librocksdb-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone --branch $VERSION https://github.com/romanz/electrs .
ENV CARGO_NET_GIT_FETCH_WITH_CLI true
RUN cargo build --release --bin electrs

FROM debian:bookworm-slim

RUN adduser --disabled-password --uid 1000 --home /data --gecos "" electrs
USER electrs
WORKDIR /data

COPY --from=builder /build/target/release/electrs /bin/electrs
EXPOSE 50001
STOPSIGNAL SIGINT
ENTRYPOINT ["electrs"]
