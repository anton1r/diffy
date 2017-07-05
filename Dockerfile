FROM java:7-jre
MAINTAINER Xabier de Zuazo "xabier@zuazo.org"

# apt-get install arguments
ENV APT_ARGS="-y --no-install-recommends --no-upgrade -o Dpkg::Options::=--force-confnew"

# Upgrade the system
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install $APT_ARGS \
      curl \
      git \
# Install netstat for integration tests:
      net-tools \
      openssl && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN cd /usr/local/src && \
    git clone https://github.com/anton1r/diffy.git && \
    cd diffy && \
    rm -rf .git && \
    ./sbt assembly && \
    mv target/scala-2.11 /opt/diffy && \
    groupadd -r diffy && \
    useradd -r -g diffy -d /opt/diffy diffy && \
    chown -R diffy:diffy /opt/diffy && \
    rm -r /usr/local/src/diffy

USER diffy

WORKDIR /opt/diffy

ENTRYPOINT ["java", "-jar", "/opt/diffy/diffy-server.jar"]
