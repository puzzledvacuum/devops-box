#!/usr/bin/env bash

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

# curl https://raw.githubusercontent.com/puzzledvacuum/devops-box/master/install.sh | sudo bash

# set -x # for debug

if [ -e /etc/redhat-release ] ; then
    REDHAT_BASED=true
fi

TERRAFORM_VERSION="0.11.14"
PACKER_VERSION="1.2.4"

# install packages
if [ ${REDHAT_BASED} ] ; then
    yum remove -y docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine
    # Install Utils:
    yum install -y yum-utils \
        device-mapper-persistent-data \
        lvm2 \
        unzip
    # Add the Docker repository:
    yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
    # Install Docker CE:
    yum -y install docker-ce
else 
    apt-get update
    apt-get -y install docker.io unzip
fi
# start docker and enable it:
systemctl start docker && systemctl enable docker
# add docker privileges
echo -e "${GREEN}Run to add docker user: sudo usermod -G docker ${USER}${NOCOLOR}"
# install pip
pip install -U pip && pip3 install -U pip
if [[ $? == 127 ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    python3 get-pip.py
fi
# install awscli, ebcli and ansible
pip install -U awscli
pip install -U awsebcli
pip install -U ansible

#terraform
T_VERSION=$(/usr/local/bin/terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# packer
P_VERSION=$(/usr/local/bin/packer -v)
P_RETVAL=$?

[[ $P_VERSION != $PACKER_VERSION ]] || [[ $P_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
&& unzip -o packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm packer_${PACKER_VERSION}_linux_amd64.zip

# clean up
if [ ! ${REDHAT_BASED} ] ; then
    apt-get clean
fi