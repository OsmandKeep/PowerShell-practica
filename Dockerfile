FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    iptables \
    nftables \
    iproute2 \
    iputils-ping \
    tcpdump \
    curl \
    net-tools \
    procps \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /lab

COPY scripts/ /lab/scripts/
RUN chmod +x /lab/scripts/*.sh

RUN echo '<h1>Firewall Lab</h1><p>iptables vs nftables</p>' > /lab/index.html

EXPOSE 8080

CMD ["/bin/bash"]
