FROM debian:jessie

RUN mkdir /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user && \
    PASS=$(openssl rand -base64 32) && \
    echo "$PASS\n$PASS" | passwd user && \
    sudo echo -e "deb http://ppa.launchpad.net/git-core/ppa/ubuntu precise main\ndeb-src http://ppa.launchpad.net/git-core/ppa/ubuntu precise main" >> /etc/apt/sources.list.d/sources.list && \
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A1715D88E1DF1F24 && \
    echo "#! /bin/bash\n set -e\n sudo /usr/sbin/sshd -D &\n exec \"\$@\"" > /home/user/entrypoint.sh && chmod a+x /home/user/entrypoint.sh

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
    git \
    openssh-server \
    sudo \
    procps \
    wget \
    unzip \
    mc \
    locales \
    ca-certificates \
    curl \
    build-essential \
    python3 \
    python3-dev \
    python-pip \
    python3-pip

RUN sudo pip3 install -U && \
    sudo pip install virtualenv && \
    pip install platformio && \
    platformio settings set enable_telemetry No || 0

RUN sudo apt-get -y autoremove --purge && \
    sudo apt-get -y autoclean && \
    sudo apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8
RUN sudo localedef -i en_US -f UTF-8 en_US.UTF-8

USER user
EXPOSE 22 4403
WORKDIR /projects
ENTRYPOINT ["/home/user/entrypoint.sh"]

CMD tail -f /dev/null
