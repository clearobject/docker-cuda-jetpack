#!/usr/bin/env bash
set -e

mkdir -p var

if ! [ -x "$(command -v rsync)" ]; then
  echo 'rsync needs to be installed!'
  sudo apt-get install -y rsync
fi

echo 'Syncing files for CUDA apt repo...'
cp /etc/apt/sources.list.d/nvidia-l4t-apt-source.list .

echo 'Exporting repo keys...'
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
apt-key exportall > apt-trusted-keys

echo 'Building cuda-jetpack:4.5-base container...'
sudo DOCKER_BUILDKIT=1 docker build \
    -t cuda-jetpack:4.5-base \
    -f Dockerfile.base .

echo 'Building cuda-jetpack:4.5-runtime container...'
sudo DOCKER_BUILDKIT=1 docker build \
    -t cuda-jetpack:4.5-runtime \
    --build-arg BASE_IMAGE=cuda-jetpack:4.5-base \
    -f Dockerfile.runtime .

echo 'Building cuda-jetpack:4.5-devel container...'
sudo DOCKER_BUILDKIT=1 docker build \
    -t cuda-jetpack:4.5-devel \
    --build-arg BASE_IMAGE=cuda-jetpack:4.5-runtime \
    -f Dockerfile.devel .

sudo docker tag cuda-jetpack:4.5-runtime cuda-jetpack:latest
