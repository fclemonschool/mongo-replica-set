FROM ubuntu:20.04 AS base

# MongoDB download URL
ARG DB_URL=https://repo.mongodb.org/apt/ubuntu/dists/focal/mongodb-org/7.0/multiverse/binary-arm64/mongodb-org-server_7.0.5_arm64.deb
ARG SHELL_URL=https://downloads.mongodb.com/compass/mongosh-2.1.4-linux-arm64.tgz

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl tzdata && \
    apt-get clean && \
    curl -OL ${DB_URL} && \
    dpkg -i mongodb-org-server_7.0.5_arm64.deb && \
    rm mongodb-org-server_7.0.5_arm64.deb && \
    curl -OL ${SHELL_URL} && \
    tar -zxvf mongosh-2.1.4-linux-arm64.tgz && \
    chmod +x mongosh-2.1.4-linux-arm64/bin/mongosh && \
    cp mongosh-2.1.4-linux-arm64/bin/mongosh /usr/local/bin/ && \
    cp mongosh-2.1.4-linux-arm64/bin/mongosh_crypt_v1.so /usr/local/lib/ && \
    rm -r mongosh-2.1.4-linux-arm64 && \
    rm mongosh-2.1.4-linux-arm64.tgz

ENV PATH="/usr/local/bin:${PATH}"

COPY ./init-mongodbs.sh ./init-replica.sh ./entry-point.sh /

RUN chmod +x /init-mongodbs.sh && \
    chmod +x /init-replica.sh && \
    chmod +x /entry-point.sh

# Data directory
ARG DB1_DATA_DIR=/var/lib/mongo1
ARG DB2_DATA_DIR=/var/lib/mongo2
ARG DB3_DATA_DIR=/var/lib/mongo3

# Log directory
ARG DB1_LOG_DIR=/var/log/mongodb1
ARG DB2_LOG_DIR=/var/log/mongodb2
ARG DB3_LOG_DIR=/var/log/mongodb3

# DB Ports
ARG DB1_PORT=27017
ARG DB1_PORT=27018
ARG DB1_PORT=27019

RUN mkdir -p ${DB1_DATA_DIR} && \
    mkdir -p ${DB1_LOG_DIR} && \
    mkdir -p ${DB2_DATA_DIR} && \
    mkdir -p ${DB2_LOG_DIR} && \
    mkdir -p ${DB3_DATA_DIR} && \
    mkdir -p ${DB3_LOG_DIR} && \
    chown `whoami` ${DB1_DATA_DIR} && \
    chown `whoami` ${DB1_LOG_DIR} && \
    chown `whoami` ${DB2_DATA_DIR} && \
    chown `whoami` ${DB2_LOG_DIR} && \
    chown `whoami` ${DB3_DATA_DIR} && \
    chown `whoami` ${DB3_LOG_DIR}

EXPOSE ${DB1_PORT}
EXPOSE ${DB2_PORT}
EXPOSE ${DB3_PORT}

ENTRYPOINT [ "bash", "entry-point.sh" ]