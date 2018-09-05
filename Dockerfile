FROM debian:jessie-slim
MAINTAINER Remo <remo@live.fi>

RUN echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu precise main\ndeb-src http://ppa.launchpad.net/git-core/ppa/ubuntu precise main" >> /etc/apt/sources.list.d/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A1715D88E1DF1F24

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
    locales \
    git \
    openssh-server \
    openssh-client \
    sudo \
    procps \
    wget \
    unzip \
    locales \
    ca-certificates \
    curl \
    build-essential \
    python-pip

RUN sudo localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    mkdir /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user && \
    PASS=$(openssl rand -base64 32) && \
    echo "$PASS\n$PASS" | passwd user && \
    echo "#! /bin/bash\n set -e\n sudo /usr/sbin/sshd -D &\n exec \"\$@\"" > /home/user/entrypoint.sh && chmod a+x /home/user/entrypoint.sh

ENV LANG en_US.utf8

RUN sudo pip install virtualenv -U && \
    pip install platformio==3.6.0 && \
    platformio settings set enable_telemetry No || 0

RUN sudo apt-get -y autoremove --purge && \
    sudo apt-get -y autoclean && \
    sudo apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

USER user
WORKDIR /projects
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null
