FROM debian:bullseye-slim

LABEL authors="devops@wheniwork.com"

# install aws

ENV AWS_CLI_VERSION 2.2.8

RUN apt-get update -y && apt-get install -y \
  ca-certificates \
  curl \
  git \
  gnupg2 \
  jq \
  make \
  openssl \
  unzip \
  zip \
  wget \
  && update-ca-certificates \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$AWS_CLI_VERSION.zip" -o "/tmp/awscliv2.zip" \
  && unzip /tmp/awscliv2.zip -d /tmp \
  && /tmp/aws/install \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# install kubectl

ENV KUBECTL_VERSION 1.21.2/2021-07-05
ENV KUBECTL_URL https://amazon-eks.s3.us-west-2.amazonaws.com/$KUBECTL_VERSION/bin/linux/amd64/kubectl
ENV KUBECTL_SHA 178aad4c23894ad69781213dfdf170983066e8fab5ea6a05675f1b364977dd57
ENV KUBECTL_BIN /usr/local/bin/kubectl

RUN curl -fL $KUBECTL_URL -o /tmp/kubectl && sha256sum /tmp/kubectl \
 && echo "$KUBECTL_SHA  /tmp/kubectl" | sha256sum -c - \
 && mv /tmp/kubectl $KUBECTL_BIN \
 && chown -R root:root $KUBECTL_BIN && chmod 755 $KUBECTL_BIN && rm -f /tmp/kubectl

# install version and validation tools

ENV NODE_VERSION=node_18.x

# add node and npm
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN apt-get update -y \
 && apt-get install -y lsb-release \
 && apt-get clean all

RUN DISTRO="bullseye" \
 && echo "deb https://deb.nodesource.com/$NODE_VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list \
 && echo "deb-src https://deb.nodesource.com/$NODE_VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list \
 && apt-get update -y \
 && apt-get install -y git make nodejs \
 && apt-get clean all

RUN npm install -g standard-version salty-dog
