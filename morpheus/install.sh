#!/bin/sh

if [ -z "$MORPHEUS_USER"]; then 
    MORPHEUS_USER="<%=instance.createdByUsername%>"
fi

# Install basic required packages
apt-get install \
        git \
        make \
        python3-pip \
        -y

python3 -m pip install \
    wheel \
    setuptools


# install eccodes and magics
./install_magics.sh

# Prepare the python3 environment needed
python3 -m pip install \
	Flask
	xarray
    skinnywms

# needed if running the notebook servers locally
python3 -m pip install \
    notebook  \
    xarray \
    cfgrib \
    ecmwf-api-client \
    matplotlib



# copy skinnywms from github
SKINNYWMS_VERSION=0.3.2
set -eux \
    && mkdir -p /app/ \
    && cd /app \
    && git clone https://github.com/ecmwf/skinnywms.git \
    && cd skinnywms \
    && git checkout ${SKINNYWMS_VERSION} \
    && pip3 install -r /app/skinnywms/requirements.txt
    && chmod -R 777 /app/ \

mkdir -p /shared/data
mkdir -p /shared/src
chmod -R 777 /shared/

# run as service
git clone https://github.com/EduardRosert/morpheus-skinnywms.git
cd morpheus-skinnywms/morpheus
./install_service.sh
