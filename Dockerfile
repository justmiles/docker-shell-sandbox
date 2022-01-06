FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

# Install Apt Packages
RUN apt-get update \
  && apt-get install -y apt-file netcat net-tools dnsutils curl wget vim zsh less sudo g++ git unzip busybox iputils-ping traceroute nmap \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install AWS CLI
RUN apt-get install -y awscli

# Install https://github.com/stedolan/jq
RUN curl -sfLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
  && chmod +x /usr/local/bin/jq

# Install https://github.com/justmiles/go-get-ssm-params
RUN curl -sfLo /usr/local/bin/get-ssm-params https://github.com/justmiles/go-get-ssm-params/releases/download/v1.7.0/get-ssm-params.v1.7.0.linux-amd64 \
  && chmod +x /usr/local/bin/get-ssm-params

# Install https://github.com/justmiles/ssm-parameter-store
RUN curl -sfLo - https://github.com/justmiles/ssm-parameter-store/releases/download/v0.0.6/ssm-parameter-store_0.0.6_Linux_x86_64.tar.gz | tar -xzvf - -C /usr/local/bin ssm-parameter-store

# Install https://github.com/justmiles/ecs-deploy
RUN curl -sfLo - https://github.com/justmiles/ecs-deploy/releases/download/v0.2.5/ecs-deploy_0.2.5_Linux_arm64.tar.gz | tar -xzvf - -C /usr/local/bin ecs-deploy

# Install https://github.com/justmiles/athena-cli
RUN curl -sfLo - https://github.com/justmiles/athena-cli/releases/download/v0.1.8/athena-cli_0.1.8_linux_x86_64.tar.gz | tar -xzvf - -C /usr/local/bin athena

# Install https://github.com/justmiles/ecs-cli
RUN curl -sfLo - https://github.com/justmiles/ecs-cli/releases/download/v0.0.20/ecs_0.0.20_Linux_x86_64.tar.gz | tar -xzvf - -C /usr/local/bin ecs

# Install https://github.com/justmiles/jumpcloud-cli
RUN curl -sfLo - https://github.com/justmiles/jumpcloud-cli/releases/download/v0.0.2/jumpcloud-cli_0.0.2_Linux_x86_64.tar.gz | tar -xzvf - -C /usr/local/bin jc

# Install https://github.com/mithrandie/csvq
RUN curl -sfLo - https://github.com/mithrandie/csvq/releases/download/v1.15.2/csvq-v1.15.2-linux-amd64.tar.gz | tar -xzvf - -C /usr/local/bin --strip-components=1 csvq-v1.15.2-linux-amd64/csvq

# Install https://github.com/pemistahl/grex
RUN curl -sfLo - https://github.com/pemistahl/grex/releases/download/v1.3.0/grex-v1.3.0-x86_64-unknown-linux-musl.tar.gz | tar -xzvf - -C /usr/local/bin grex

# Install gron
RUN curl -sfLo - https://github.com/tomnomnom/gron/releases/download/v0.6.1/gron-linux-amd64-0.6.1.tgz | tar -xzvf - -C /usr/local/bin

# Install whois
RUN curl -sfLo -  https://github.com/likexian/whois/releases/download/v1.12.1/whois-linux-amd64.zip | busybox unzip -qd /usr/local/bin/ - \
  && chmod +x /usr/local/bin/whois

# Install restic
RUN curl -sfLo - https://github.com/restic/restic/releases/download/v0.12.1/restic_0.12.1_linux_amd64.bz2 | bzip2 -d -qc > /usr/local/bin/restic \
  && chmod +x /usr/local/bin/restic

# Install golang
ENV GOLANG_VERSION="1.16"
RUN curl -sLO https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz \
  && tar -xzvf go${GOLANG_VERSION}.linux-amd64.tar.gz -C /usr/local \
  && echo 'export PATH=$PATH:/usr/local/go/bin:/root/go/bin' > /etc/profile.d/go.sh \
  && rm -rf go*.tar.gz

# Install kpwgen
RUN /usr/local/go/bin/go get github.com/lpar/kpwgen

# Install textql
RUN /usr/local/go/bin/go get -u github.com/dinedal/textql/...

# Install rclone
RUN curl -sfO https://downloads.rclone.org/rclone-current-linux-amd64.deb \
  && sudo dpkg -i rclone-current-linux-amd64.deb \
  && rm -rf rclone-current-linux-amd64.deb

# Setup sandbox user
RUN useradd --shell /usr/bin/zsh --create-home sandbox \
  && echo 'sandbox ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sandbox

USER sandbox

WORKDIR /home/sandbox

# Install ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

COPY .zshrc .

ENTRYPOINT [ "/usr/bin/zsh" ]

# TODO: consider installing java
