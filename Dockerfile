FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY submodules/mktorrent /app/submodules/mktorrent

# script expects mktorrent binary in same dir
RUN cd /app/submodules/mktorrent && make && mv mktorrent /app/

ENTRYPOINT ["bash", "/app/create_monero_torrent.sh"]
